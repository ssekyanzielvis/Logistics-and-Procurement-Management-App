-- 🔧 QUICK FIX FOR INFINITE RECURSION ERROR
-- Copy this into Supabase SQL Editor to fix the admin registration issue

-- Drop problematic policies
DROP POLICY IF EXISTS "Admins can manage all users" ON public.users;
DROP POLICY IF EXISTS "Only admins can view admin data" ON public.admins;

-- Create fixed policies using JWT instead of table lookup
CREATE POLICY "Admins can manage all users" ON public.users
    FOR ALL USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

CREATE POLICY "Admins can view admin data" ON public.admins
    FOR ALL USING (
        (auth.jwt() ->> 'role')::text IN ('admin', 'other_admin') OR
        auth.uid() = id
    );

-- Also ensure users can insert their own profile
CREATE POLICY IF NOT EXISTS "Users can insert their own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);
