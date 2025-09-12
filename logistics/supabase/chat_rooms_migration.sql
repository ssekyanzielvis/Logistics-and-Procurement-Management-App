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

-- Set proper permissions for the table
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to see their own chat rooms
CREATE POLICY chat_rooms_select_policy 
ON public.chat_rooms
FOR SELECT
USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Create policy to allow users to insert their own chat rooms
CREATE POLICY chat_rooms_insert_policy
ON public.chat_rooms
FOR INSERT
WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Create policy to allow users to update their own chat rooms
CREATE POLICY chat_rooms_update_policy
ON public.chat_rooms
FOR UPDATE
USING (auth.uid() = user1_id OR auth.uid() = user2_id);

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

-- Set proper permissions for messages
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to see messages in their chat rooms
CREATE POLICY messages_select_policy
ON public.messages
FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM public.chat_rooms cr
    WHERE cr.id = chat_room_id
    AND (cr.user1_id = auth.uid() OR cr.user2_id = auth.uid())
  )
);

-- Create policy to allow users to insert messages in their chat rooms
CREATE POLICY messages_insert_policy
ON public.messages
FOR INSERT
WITH CHECK (
  sender_id = auth.uid() AND
  EXISTS (
    SELECT 1 FROM public.chat_rooms cr
    WHERE cr.id = chat_room_id
    AND (cr.user1_id = auth.uid() OR cr.user2_id = auth.uid())
  )
);

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
