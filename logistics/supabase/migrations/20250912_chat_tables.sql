-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create chat_rooms table
CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL,
    user2_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_message_id UUID,
    CONSTRAINT unique_users UNIQUE(user1_id, user2_id)
);

-- Create messages table
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chat_room_id UUID NOT NULL REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    receiver_id UUID NOT NULL,
    message TEXT,
    type TEXT DEFAULT 'text',
    image_url TEXT,
    is_read BOOLEAN DEFAULT false,
    reply_to_id UUID REFERENCES public.messages(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_message CHECK (
        (type = 'text' AND message IS NOT NULL) OR
        (type = 'image' AND image_url IS NOT NULL) OR
        (type = 'emoji' AND message IS NOT NULL)
    )
);

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user1_id ON public.chat_rooms(user1_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user2_id ON public.chat_rooms(user2_id);
CREATE INDEX IF NOT EXISTS idx_messages_chat_room_id ON public.messages(chat_room_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver_id ON public.messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at);

-- Enable Row Level Security
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Create policies for chat_rooms
CREATE POLICY "Users can view their own chat rooms"
    ON public.chat_rooms FOR SELECT
    USING (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can create chat rooms they are part of"
    ON public.chat_rooms FOR INSERT
    WITH CHECK (auth.uid() = user1_id OR auth.uid() = user2_id);

CREATE POLICY "Users can update their own chat rooms"
    ON public.chat_rooms FOR UPDATE
    USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Drop all existing policies for messages
DROP POLICY IF EXISTS "Users can view messages in their chat rooms" ON public.messages;
DROP POLICY IF EXISTS "Users can insert messages in their chat rooms" ON public.messages;

-- Create simplified policies for messages
CREATE POLICY "Users can view messages in their chat rooms"
    ON public.messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM chat_rooms
            WHERE chat_rooms.id = messages.chat_room_id
            AND (chat_rooms.user1_id = auth.uid() OR chat_rooms.user2_id = auth.uid())
        )
    );

CREATE POLICY "Users can insert messages in their chat rooms"
    ON public.messages FOR INSERT
    WITH CHECK (
        sender_id = auth.uid()
    );

CREATE POLICY "Users can update their own messages"
    ON public.messages FOR UPDATE
    USING (sender_id = auth.uid());

CREATE POLICY "Users can delete their own messages"
    ON public.messages FOR DELETE
    USING (sender_id = auth.uid());

-- Create function to update last_activity and last_message_id
CREATE OR REPLACE FUNCTION update_chat_room_last_message()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE chat_rooms
    SET last_activity = NOW(),
        last_message_id = NEW.id
    WHERE id = NEW.chat_room_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for last message updates
CREATE TRIGGER update_chat_room_after_message
    AFTER INSERT ON public.messages
    FOR EACH ROW
    EXECUTE FUNCTION update_chat_room_last_message();

-- Create debugging functions to help troubleshoot RLS issues
CREATE OR REPLACE FUNCTION check_message_insert_permission(
    p_chat_room_id UUID,
    p_sender_id UUID
) RETURNS boolean AS $$
DECLARE
    v_result boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM public.chat_rooms
        WHERE id = p_chat_room_id
        AND (user1_id = p_sender_id OR user2_id = p_sender_id)
    ) INTO v_result;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
