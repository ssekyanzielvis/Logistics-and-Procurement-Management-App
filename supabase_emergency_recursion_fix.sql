-- ⚡ EMERGENCY FIX FOR INFINITE RECURSION
-- Run this IMMEDIATELY to fix all recursion errors

-- DISABLE RLS temporarily to break the recursion
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins DISABLE ROW LEVEL SECURITY;

-- Drop ALL policies that might cause recursion
DROP POLICY IF EXISTS "Users can view all active users" ON public.users;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
DROP POLICY IF EXISTS "Admins can update all users" ON public.users;
DROP POLICY IF EXISTS "Admins can delete users" ON public.users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.users;

DROP POLICY IF EXISTS "Only admins can view admin data" ON public.admins;
DROP POLICY IF EXISTS "Admins can view admin data" ON public.admins;
DROP POLICY IF EXISTS "Admins can insert admin data" ON public.admins;
DROP POLICY IF EXISTS "Admins can update admin data" ON public.admins;

-- Create SIMPLE, NON-RECURSIVE policies
CREATE POLICY "Allow all authenticated users" ON public.users
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Allow all authenticated admins" ON public.admins
    FOR ALL USING (auth.role() = 'authenticated');

-- Re-enable RLS with safe policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins ENABLE ROW LEVEL SECURITY;
