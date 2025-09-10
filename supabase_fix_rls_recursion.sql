-- =============================================
-- RLS POLICIES FIX - ELIMINATES INFINITE RECURSION
-- =============================================

-- This script fixes the infinite recursion issue in RLS policies
-- Run this AFTER the main database schema to replace problematic policies

-- =============================================
-- DROP EXISTING PROBLEMATIC POLICIES
-- =============================================

-- Drop all existing policies that cause recursion
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
DROP POLICY IF EXISTS "Only admins can view admin data" ON public.admins;
DROP POLICY IF EXISTS "Users can view their own consignments" ON public.consignments;
DROP POLICY IF EXISTS "Clients can create consignments" ON public.consignments;
DROP POLICY IF EXISTS "Drivers and admins can update consignments" ON public.consignments;
DROP POLICY IF EXISTS "Users can view related delivery notes" ON public.delivery_notes;
DROP POLICY IF EXISTS "Drivers can create delivery notes" ON public.delivery_notes;
DROP POLICY IF EXISTS "Users can view assigned fuel cards" ON public.fuel_cards;
DROP POLICY IF EXISTS "Only admins can manage fuel cards" ON public.fuel_cards;
DROP POLICY IF EXISTS "Admins can manage fuel card lockers" ON public.fuel_card_lockers;
DROP POLICY IF EXISTS "Drivers can view fuel card lockers" ON public.fuel_card_lockers;
DROP POLICY IF EXISTS "Users can view their fuel card assignments" ON public.fuel_card_assignments;
DROP POLICY IF EXISTS "Users can view their fuel transactions" ON public.fuel_transactions;
DROP POLICY IF EXISTS "Drivers can create fuel transactions" ON public.fuel_transactions;

-- =============================================
-- FIXED USERS TABLE POLICIES (NO RECURSION)
-- =============================================

-- Users can view all active users
CREATE POLICY "Users can view all active users" ON public.users
    FOR SELECT USING (is_active = true);

-- Users can update their own profile
CREATE POLICY "Users can update their own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile
CREATE POLICY "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Admins have full access (using JWT claims instead of table lookup)
CREATE POLICY "Admins can manage all users" ON public.users
    FOR ALL USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

-- =============================================
-- FIXED ADMINS TABLE POLICIES
-- =============================================

CREATE POLICY "Admins can view admin data" ON public.admins
    FOR SELECT USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

CREATE POLICY "Admins can insert admin data" ON public.admins
    FOR INSERT WITH CHECK (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

CREATE POLICY "Admins can update admin data" ON public.admins
    FOR UPDATE USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

-- =============================================
-- FIXED CONSIGNMENTS TABLE POLICIES
-- =============================================

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

-- =============================================
-- FIXED DELIVERY NOTES TABLE POLICIES  
-- =============================================

CREATE POLICY "Users can view related delivery notes" ON public.delivery_notes
    FOR SELECT USING (
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

CREATE POLICY "Drivers can create delivery notes" ON public.delivery_notes
    FOR INSERT WITH CHECK (
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin', 'driver')
    );

-- =============================================
-- FIXED FUEL CARDS TABLE POLICIES
-- =============================================

CREATE POLICY "Users can view assigned fuel cards" ON public.fuel_cards
    FOR SELECT USING (
        assigned_driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

CREATE POLICY "Admins can manage fuel cards" ON public.fuel_cards
    FOR ALL USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

-- =============================================
-- FIXED FUEL CARD LOCKERS TABLE POLICIES
-- =============================================

CREATE POLICY "Admins can manage fuel card lockers" ON public.fuel_card_lockers
    FOR ALL USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

CREATE POLICY "Users can view fuel card lockers" ON public.fuel_card_lockers
    FOR SELECT USING (
        (auth.jwt() ->> 'role')::text IN ('driver', 'admin', 'other_admin') OR
        true  -- Allow all authenticated users to view lockers
    );

-- =============================================
-- FIXED FUEL CARD ASSIGNMENTS TABLE POLICIES
-- =============================================

CREATE POLICY "Users can view their fuel card assignments" ON public.fuel_card_assignments
    FOR SELECT USING (
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

CREATE POLICY "Admins can manage fuel card assignments" ON public.fuel_card_assignments
    FOR ALL USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

-- =============================================
-- FIXED FUEL TRANSACTIONS TABLE POLICIES
-- =============================================

CREATE POLICY "Users can view their fuel transactions" ON public.fuel_transactions
    FOR SELECT USING (
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

CREATE POLICY "Drivers can create fuel transactions" ON public.fuel_transactions
    FOR INSERT WITH CHECK (
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin', 'driver')
    );

CREATE POLICY "Admins and drivers can update fuel transactions" ON public.fuel_transactions
    FOR UPDATE USING (
        driver_id = auth.uid() OR
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin')
    );

-- =============================================
-- VERIFICATION QUERY
-- =============================================

-- Check that policies are created without recursion
SELECT schemaname, tablename, policyname, cmd, qual 
FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename, policyname;
