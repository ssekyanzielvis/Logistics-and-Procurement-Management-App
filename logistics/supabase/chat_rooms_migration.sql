-- Ensure UUID extension exists (needed for uuid_generate_v4)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create chat_rooms table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.chat_rooms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user1_id UUID NOT NULL,
  user2_id UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_message_id UUID,
  UNIQUE(user1_id, user2_id)
);

-- Prevent self-chat rooms
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_schema = 'public'
      AND table_name = 'chat_rooms'
      AND constraint_name = 'chat_rooms_not_same_user_chk'
  ) THEN
    ALTER TABLE public.chat_rooms
      ADD CONSTRAINT chat_rooms_not_same_user_chk CHECK (user1_id <> user2_id);
  END IF;
END$$;

-- Enforce uniqueness on unordered user pairs (u1,u2) == (u2,u1)
CREATE UNIQUE INDEX IF NOT EXISTS chat_rooms_unique_pair_idx
  ON public.chat_rooms (LEAST(user1_id, user2_id), GREATEST(user1_id, user2_id));

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user1 ON public.chat_rooms(user1_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user2 ON public.chat_rooms(user2_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_last_activity ON public.chat_rooms(last_activity DESC);

-- Set proper permissions for the table
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;

-- Idempotent policies for chat_rooms
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='chat_rooms' AND policyname='chat_rooms_select_policy'
  ) THEN
    CREATE POLICY chat_rooms_select_policy
      ON public.chat_rooms FOR SELECT
      USING (auth.uid() = user1_id OR auth.uid() = user2_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='chat_rooms' AND policyname='chat_rooms_insert_policy'
  ) THEN
    CREATE POLICY chat_rooms_insert_policy
      ON public.chat_rooms FOR INSERT
      WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='chat_rooms' AND policyname='chat_rooms_update_policy'
  ) THEN
    CREATE POLICY chat_rooms_update_policy
      ON public.chat_rooms FOR UPDATE
      USING (auth.uid() = user1_id OR auth.uid() = user2_id);
  END IF;
END$$;

-- Create messages table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL,
  content TEXT NOT NULL,
  attachment_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  read_at TIMESTAMP WITH TIME ZONE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Backfill columns for legacy schemas where messages existed without these fields
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS attachment_url TEXT;
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS read_at TIMESTAMPTZ;
ALTER TABLE public.messages
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- Helpful indexes for messages
CREATE INDEX IF NOT EXISTS idx_messages_room_created_at ON public.messages (chat_room_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages (sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_not_deleted ON public.messages (chat_room_id) WHERE deleted_at IS NULL;

-- FK to auth.users (if available) for sender_id and chat participants
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_schema='public' AND table_name='messages' AND constraint_name='messages_sender_fk'
  ) THEN
    ALTER TABLE public.messages
      ADD CONSTRAINT messages_sender_fk
      FOREIGN KEY (sender_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_schema='public' AND table_name='chat_rooms' AND constraint_name='chat_rooms_user1_fk'
  ) THEN
    ALTER TABLE public.chat_rooms
      ADD CONSTRAINT chat_rooms_user1_fk
      FOREIGN KEY (user1_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_schema='public' AND table_name='chat_rooms' AND constraint_name='chat_rooms_user2_fk'
  ) THEN
    ALTER TABLE public.chat_rooms
      ADD CONSTRAINT chat_rooms_user2_fk
      FOREIGN KEY (user2_id) REFERENCES auth.users(id) ON DELETE CASCADE;
  END IF;
END$$;

-- Set proper permissions for messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Idempotent policies for messages
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='messages' AND policyname='messages_select_policy'
  ) THEN
    CREATE POLICY messages_select_policy
      ON public.messages FOR SELECT
      USING (
        EXISTS (
          SELECT 1 FROM public.chat_rooms cr
          WHERE cr.id = chat_room_id
          AND (cr.user1_id = auth.uid() OR cr.user2_id = auth.uid())
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='messages' AND policyname='messages_insert_policy'
  ) THEN
    CREATE POLICY messages_insert_policy
      ON public.messages FOR INSERT
      WITH CHECK (
        sender_id = auth.uid() AND
        EXISTS (
          SELECT 1 FROM public.chat_rooms cr
          WHERE cr.id = chat_room_id
          AND (cr.user1_id = auth.uid() OR cr.user2_id = auth.uid())
        )
      );
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='public' AND tablename='messages' AND policyname='messages_update_policy'
  ) THEN
    -- Allow participants to update message fields (e.g., read_at, deleted_at)
    CREATE POLICY messages_update_policy
      ON public.messages FOR UPDATE
      USING (
        EXISTS (
          SELECT 1 FROM public.chat_rooms cr
          WHERE cr.id = chat_room_id
          AND (cr.user1_id = auth.uid() OR cr.user2_id = auth.uid())
        )
      );
  END IF;
END$$;

-- Trigger to update the last_activity timestamp when a new message is created
CREATE OR REPLACE FUNCTION update_chat_room_last_activity()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE public.chat_rooms
  SET last_activity = NOW(),
      last_message_id = NEW.id
  WHERE id = NEW.chat_room_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
DROP TRIGGER IF EXISTS update_chat_room_on_message ON public.messages;
CREATE TRIGGER update_chat_room_on_message
AFTER INSERT ON public.messages
FOR EACH ROW
EXECUTE PROCEDURE update_chat_room_last_activity();

-- Helper: get existing chat room id for a pair of users or create it
CREATE OR REPLACE FUNCTION public.get_or_create_chat_room(u1 UUID, u2 UUID)
RETURNS UUID LANGUAGE plpgsql AS $$
DECLARE
  rid UUID;
  a UUID := LEAST(u1, u2);
  b UUID := GREATEST(u1, u2);
BEGIN
  IF u1 = u2 THEN
    RAISE EXCEPTION 'Cannot create chat room with the same users';
  END IF;

  SELECT id INTO rid FROM public.chat_rooms
  WHERE LEAST(user1_id, user2_id) = a AND GREATEST(user1_id, user2_id) = b
  LIMIT 1;

  IF rid IS NULL THEN
    INSERT INTO public.chat_rooms(user1_id, user2_id)
    VALUES (a, b)
    RETURNING id INTO rid;
  END IF;
  RETURN rid;
END;
$$;
