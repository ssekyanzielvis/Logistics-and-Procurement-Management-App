-- Supabase Database Schema for Logistics Management App
-- Execute these SQL commands in your Supabase SQL Editor

-- Enable Row Level Security (RLS) and required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- USERS TABLE (Auto-created by Supabase trigger)
-- =============================================

-- Create the users table that will be populated automatically from auth.users
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    phone TEXT,
    role TEXT DEFAULT 'user' CHECK (role IN ('admin', 'client', 'driver', 'user', 'other_admin')),
    profile_image TEXT,
    is_active BOOLEAN DEFAULT true,
    is_online BOOLEAN DEFAULT false,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create trigger to automatically create user profile when auth.users record is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, phone, role, profile_image)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'phone',
        COALESCE(NEW.raw_user_meta_data->>'role', 'user'),
        NEW.raw_user_meta_data->>'profile_image'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add updated_at trigger to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- ADMINS TABLE (for admin-specific data)
-- =============================================

CREATE TABLE public.admins (
    id UUID REFERENCES public.users(id) PRIMARY KEY,
    admin_type TEXT DEFAULT 'admin' CHECK (admin_type IN ('admin', 'other_admin')),
    permissions JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add updated_at trigger to admins table
CREATE TRIGGER update_admins_updated_at
    BEFORE UPDATE ON public.admins
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- CONSIGNMENTS TABLE
-- =============================================

CREATE TABLE public.consignments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    client_id UUID REFERENCES public.users(id) NOT NULL,
    driver_id UUID REFERENCES public.users(id),
    pickup_location TEXT NOT NULL,
    delivery_location TEXT NOT NULL,
    item_description TEXT NOT NULL,
    weight DECIMAL(10,2) NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'assigned', 'in_transit', 'delivered', 'cancelled')),
    special_instructions TEXT,
    estimated_delivery_date TIMESTAMP WITH TIME ZONE,
    actual_delivery_date TIMESTAMP WITH TIME ZONE,
    tracking_number TEXT UNIQUE,
    document_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_consignments_client_id ON public.consignments(client_id);
CREATE INDEX idx_consignments_driver_id ON public.consignments(driver_id);
CREATE INDEX idx_consignments_status ON public.consignments(status);
CREATE INDEX idx_consignments_tracking_number ON public.consignments(tracking_number);

-- Add updated_at trigger to consignments table
CREATE TRIGGER update_consignments_updated_at
    BEFORE UPDATE ON public.consignments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Generate tracking number function
CREATE OR REPLACE FUNCTION generate_tracking_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tracking_number IS NULL THEN
        NEW.tracking_number := 'LG' || UPPER(substring(NEW.id::text from 1 for 8)) || 
                              to_char(NOW(), 'YYYYMMDD');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for tracking number generation
CREATE TRIGGER generate_consignment_tracking_number
    BEFORE INSERT ON public.consignments
    FOR EACH ROW EXECUTE FUNCTION generate_tracking_number();

-- =============================================
-- DELIVERY NOTES TABLE
-- =============================================

CREATE TABLE public.delivery_notes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    driver_id UUID REFERENCES public.users(id) NOT NULL,
    customer_id TEXT NOT NULL,
    customer_name TEXT NOT NULL,
    delivery_address TEXT NOT NULL,
    image_url TEXT NOT NULL,
    image_path TEXT,
    status TEXT DEFAULT 'delivered' CHECK (status IN ('delivered', 'failed', 'partial')),
    notes TEXT,
    consignment_id UUID REFERENCES public.consignments(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_delivery_notes_driver_id ON public.delivery_notes(driver_id);
CREATE INDEX idx_delivery_notes_consignment_id ON public.delivery_notes(consignment_id);

-- Add updated_at trigger to delivery_notes table
CREATE TRIGGER update_delivery_notes_updated_at
    BEFORE UPDATE ON public.delivery_notes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- FUEL CARD LOCKERS TABLE (Created first to avoid reference issues)
-- =============================================

CREATE TABLE public.fuel_card_lockers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    capacity INTEGER DEFAULT 10,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_fuel_card_lockers_name ON public.fuel_card_lockers(name);
CREATE INDEX idx_fuel_card_lockers_location ON public.fuel_card_lockers(location);

-- Add updated_at trigger to fuel_card_lockers table
CREATE TRIGGER update_fuel_card_lockers_updated_at
    BEFORE UPDATE ON public.fuel_card_lockers
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- FUEL CARDS TABLE
-- =============================================

CREATE TABLE public.fuel_cards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    card_number TEXT UNIQUE NOT NULL,
    card_holder_name TEXT,
    provider TEXT DEFAULT 'shell' CHECK (provider IN ('shell', 'bp', 'exxon', 'chevron', 'other')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked', 'expired')),
    card_type TEXT DEFAULT 'physical' CHECK (card_type IN ('physical', 'virtual', 'digital')),
    issue_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expiry_date TIMESTAMP WITH TIME ZONE,
    spending_limit DECIMAL(10,2) DEFAULT 1000.00,
    current_balance DECIMAL(10,2) DEFAULT 0.00,
    fuel_type_restrictions TEXT[] DEFAULT ARRAY['diesel', 'petrol'],
    assigned_driver_id UUID REFERENCES public.users(id),
    vehicle_id TEXT,
    locker_id UUID REFERENCES public.fuel_card_lockers(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_fuel_cards_assigned_driver_id ON public.fuel_cards(assigned_driver_id);
CREATE INDEX idx_fuel_cards_status ON public.fuel_cards(status);
CREATE INDEX idx_fuel_cards_card_number ON public.fuel_cards(card_number);

-- Add updated_at trigger to fuel_cards table
CREATE TRIGGER update_fuel_cards_updated_at
    BEFORE UPDATE ON public.fuel_cards
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- FUEL CARD ASSIGNMENTS TABLE
-- =============================================

CREATE TABLE public.fuel_card_assignments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    fuel_card_id UUID REFERENCES public.fuel_cards(id) NOT NULL,
    driver_id UUID REFERENCES public.users(id) NOT NULL,
    vehicle_id TEXT,
    assigned_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    unassigned_date TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'completed')),
    assigned_by UUID REFERENCES public.users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_fuel_card_assignments_fuel_card_id ON public.fuel_card_assignments(fuel_card_id);
CREATE INDEX idx_fuel_card_assignments_driver_id ON public.fuel_card_assignments(driver_id);
CREATE INDEX idx_fuel_card_assignments_status ON public.fuel_card_assignments(status);

-- Add updated_at trigger to fuel_card_assignments table
CREATE TRIGGER update_fuel_card_assignments_updated_at
    BEFORE UPDATE ON public.fuel_card_assignments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();



-- =============================================
-- FUEL TRANSACTIONS TABLE
-- =============================================

CREATE TABLE public.fuel_transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    fuel_card_id UUID REFERENCES public.fuel_cards(id) NOT NULL,
    driver_id UUID REFERENCES public.users(id) NOT NULL,
    vehicle_id TEXT,
    transaction_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    type TEXT DEFAULT 'fuel' CHECK (type IN ('fuel', 'carWash', 'convenience', 'maintenance')),
    amount DECIMAL(10,2) NOT NULL,
    quantity DECIMAL(8,2),
    price_per_unit DECIMAL(8,2),
    fuel_type TEXT,
    station TEXT,
    location TEXT,
    authorization_code TEXT,
    receipt_number TEXT,
    receipt_url TEXT,
    odometer_reading INTEGER,
    notes TEXT,
    status TEXT DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_fuel_transactions_fuel_card_id ON public.fuel_transactions(fuel_card_id);
CREATE INDEX idx_fuel_transactions_driver_id ON public.fuel_transactions(driver_id);
CREATE INDEX idx_fuel_transactions_transaction_date ON public.fuel_transactions(transaction_date);
CREATE INDEX idx_fuel_transactions_type ON public.fuel_transactions(type);

-- Add updated_at trigger to fuel_transactions table
CREATE TRIGGER update_fuel_transactions_updated_at
    BEFORE UPDATE ON public.fuel_transactions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- CHAT ROOMS TABLE
-- =============================================

CREATE TABLE public.chat_rooms (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT,
    type TEXT DEFAULT 'direct' CHECK (type IN ('direct', 'group')),
    created_by UUID REFERENCES public.users(id) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    last_message_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_chat_rooms_created_by ON public.chat_rooms(created_by);
CREATE INDEX idx_chat_rooms_type ON public.chat_rooms(type);

-- Add updated_at trigger to chat_rooms table
CREATE TRIGGER update_chat_rooms_updated_at
    BEFORE UPDATE ON public.chat_rooms
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- CHAT ROOM PARTICIPANTS TABLE
-- =============================================

CREATE TABLE public.chat_room_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_read_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_admin BOOLEAN DEFAULT false,
    UNIQUE(room_id, user_id)
);

-- Create index for better performance
CREATE INDEX idx_chat_room_participants_room_id ON public.chat_room_participants(room_id);
CREATE INDEX idx_chat_room_participants_user_id ON public.chat_room_participants(user_id);

-- =============================================
-- CHAT MESSAGES TABLE
-- =============================================

CREATE TABLE public.chat_messages (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.users(id) NOT NULL,
    content TEXT NOT NULL,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'file', 'system')),
    file_url TEXT,
    file_name TEXT,
    file_size INTEGER,
    reply_to_id UUID REFERENCES public.chat_messages(id),
    is_edited BOOLEAN DEFAULT false,
    edited_at TIMESTAMP WITH TIME ZONE,
    is_deleted BOOLEAN DEFAULT false,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for better performance
CREATE INDEX idx_chat_messages_room_id ON public.chat_messages(room_id);
CREATE INDEX idx_chat_messages_sender_id ON public.chat_messages(sender_id);
CREATE INDEX idx_chat_messages_created_at ON public.chat_messages(created_at);

-- Add updated_at trigger to chat_messages table
CREATE TRIGGER update_chat_messages_updated_at
    BEFORE UPDATE ON public.chat_messages
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.consignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_card_lockers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_card_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_room_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Users table policies (FIXED - no infinite recursion)
CREATE POLICY "Users can view all active users" ON public.users
    FOR SELECT USING (is_active = true);

CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Separate admin policies to avoid recursion
CREATE POLICY "Admins can view all users" ON public.users
    FOR SELECT USING (
        auth.jwt() ->> 'role' IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

CREATE POLICY "Admins can update all users" ON public.users
    FOR UPDATE USING (
        auth.jwt() ->> 'role' IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

CREATE POLICY "Admins can delete users" ON public.users
    FOR DELETE USING (
        auth.jwt() ->> 'role' IN ('admin', 'other_admin')
    );

-- Admins table policies (FIXED - no recursion)
CREATE POLICY "Only admins can view admin data" ON public.admins
    FOR SELECT USING (
        auth.jwt() ->> 'role' IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

CREATE POLICY "Admins can insert admin data" ON public.admins
    FOR INSERT WITH CHECK (
        auth.jwt() ->> 'role' IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

CREATE POLICY "Admins can update admin data" ON public.admins
    FOR UPDATE USING (
        auth.jwt() ->> 'role' IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

-- Consignments table policies (FIXED - no recursion)
CREATE POLICY "Users can view their own consignments" ON public.consignments
    FOR SELECT USING (
        client_id = auth.uid() OR 
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

CREATE POLICY "Users can create consignments" ON public.consignments
    FOR INSERT WITH CHECK (
        client_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin', 'client')
    );

CREATE POLICY "Drivers and admins can update consignments" ON public.consignments
    FOR UPDATE USING (
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

-- Delivery notes table policies
CREATE POLICY "Users can view related delivery notes" ON public.delivery_notes
    FOR SELECT USING (
        driver_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
        )
    );

CREATE POLICY "Drivers can create delivery notes" ON public.delivery_notes
    FOR INSERT WITH CHECK (
        driver_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'driver'
        )
    );

-- Fuel cards table policies
CREATE POLICY "Users can view assigned fuel cards" ON public.fuel_cards
    FOR SELECT USING (
        assigned_driver_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
        )
    );

CREATE POLICY "Only admins can manage fuel cards" ON public.fuel_cards
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
        )
    );

-- Fuel card lockers table policies
CREATE POLICY "Admins can manage fuel card lockers" ON public.fuel_card_lockers
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
        )
    );

CREATE POLICY "Drivers can view fuel card lockers" ON public.fuel_card_lockers
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('driver', 'admin', 'other_admin')
        )
    );

-- Fuel card assignments table policies
CREATE POLICY "Users can view their fuel card assignments" ON public.fuel_card_assignments
    FOR SELECT USING (
        driver_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
        )
    );

-- Fuel transactions table policies
CREATE POLICY "Users can view their fuel transactions" ON public.fuel_transactions
    FOR SELECT USING (
        driver_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
        )
    );

CREATE POLICY "Drivers can create fuel transactions" ON public.fuel_transactions
    FOR INSERT WITH CHECK (
        driver_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'driver'
        )
    );

-- Chat room policies
CREATE POLICY "Users can view their chat rooms" ON public.chat_rooms
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_participants 
            WHERE room_id = id AND user_id = auth.uid()
        )
    );

-- Chat room participants policies
CREATE POLICY "Users can view participants of their rooms" ON public.chat_room_participants
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_participants crp 
            WHERE crp.room_id = room_id AND crp.user_id = auth.uid()
        )
    );

-- Chat messages policies
CREATE POLICY "Users can view messages in their rooms" ON public.chat_messages
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_participants 
            WHERE room_id = chat_messages.room_id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can send messages to their rooms" ON public.chat_messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid() AND
        EXISTS (
            SELECT 1 FROM public.chat_room_participants 
            WHERE room_id = chat_messages.room_id AND user_id = auth.uid()
        )
    );

-- =============================================
-- SAMPLE DATA (Optional - for testing)
-- =============================================

-- Insert sample admin user (you'll need to sign up this user first via Supabase Auth)
-- Then run this to make them an admin:
-- INSERT INTO public.admins (id, admin_type) 
-- VALUES ('your-admin-user-uuid-here', 'admin');

-- Create sample fuel cards
INSERT INTO public.fuel_cards (card_number, card_holder_name, provider, spending_limit) VALUES
('FC001234567890', 'Fleet Card 1', 'shell', 2000.00),
('FC001234567891', 'Fleet Card 2', 'bp', 1500.00),
('FC001234567892', 'Fleet Card 3', 'exxon', 3000.00);

-- =============================================
-- RPC FUNCTIONS FOR FUEL CARD LOCKER MANAGEMENT
-- =============================================

-- Function to add fuel card to locker
CREATE OR REPLACE FUNCTION public.add_fuel_card_to_locker(
    locker_id UUID,
    fuel_card_id UUID
)
RETURNS void AS $$
BEGIN
    -- Check if locker exists and has capacity
    IF NOT EXISTS (
        SELECT 1 FROM public.fuel_card_lockers 
        WHERE id = locker_id
    ) THEN
        RAISE EXCEPTION 'Locker not found';
    END IF;
    
    -- Check if fuel card exists and is not already in a locker
    IF NOT EXISTS (
        SELECT 1 FROM public.fuel_cards 
        WHERE id = fuel_card_id AND locker_id IS NULL
    ) THEN
        RAISE EXCEPTION 'Fuel card not found or already assigned to a locker';
    END IF;
    
    -- Add fuel card to locker
    UPDATE public.fuel_cards 
    SET locker_id = add_fuel_card_to_locker.locker_id,
        updated_at = NOW()
    WHERE id = fuel_card_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to remove fuel card from locker
CREATE OR REPLACE FUNCTION public.remove_fuel_card_from_locker(
    locker_id UUID,
    fuel_card_id UUID
)
RETURNS void AS $$
BEGIN
    -- Check if fuel card is in the specified locker
    IF NOT EXISTS (
        SELECT 1 FROM public.fuel_cards 
        WHERE id = fuel_card_id AND locker_id = remove_fuel_card_from_locker.locker_id
    ) THEN
        RAISE EXCEPTION 'Fuel card not found in the specified locker';
    END IF;
    
    -- Remove fuel card from locker
    UPDATE public.fuel_cards 
    SET locker_id = NULL,
        updated_at = NOW()
    WHERE id = fuel_card_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions on RPC functions
GRANT EXECUTE ON FUNCTION public.add_fuel_card_to_locker(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.remove_fuel_card_from_locker(UUID, UUID) TO authenticated;

COMMIT;
