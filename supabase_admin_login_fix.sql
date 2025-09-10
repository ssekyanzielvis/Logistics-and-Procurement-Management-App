-- Emergency Fix for Admin Login - Supabase Database
-- This fixes the infinite recursion in RLS policies that's preventing admin login

-- 1. Drop ALL problematic RLS policies on users table
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
DROP POLICY IF EXISTS "Users can update own profile" ON public.users;
DROP POLICY IF EXISTS "Admins can view all users" ON public.users;
DROP POLICY IF EXISTS "Admins can update users" ON public.users;
DROP POLICY IF EXISTS "Enable read access for users based on user_id" ON public.users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;
DROP POLICY IF EXISTS "Enable update for users based on email" ON public.users;

-- 2. Temporarily disable RLS on users table
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;

-- 3. Create simple, non-recursive policies based on auth.uid() only
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can view their own profile (simple auth.uid() check)
CREATE POLICY "users_select_own" ON public.users
    FOR SELECT
    USING (auth.uid() = id);

-- Policy 2: Users can update their own profile (simple auth.uid() check)
CREATE POLICY "users_update_own" ON public.users
    FOR UPDATE
    USING (auth.uid() = id);

-- Policy 3: Allow authenticated users to insert (for registration)
CREATE POLICY "users_insert_authenticated" ON public.users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Policy 4: Simple admin access (using JWT claims, not database lookup)
CREATE POLICY "admin_full_access" ON public.users
    FOR ALL
    USING (
        auth.jwt() ->> 'role' = 'admin' OR
        auth.jwt() ->> 'email' = 'abdulssekyanzi@gmail.com'
    );

-- 4. Ensure proper user metadata is set for admin user
-- Update the admin user's metadata in auth.users
UPDATE auth.users 
SET 
    raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'), 
        '{role}', 
        '"admin"'
    )
WHERE email = 'abdulssekyanzi@gmail.com';

-- 5. Create or update the admin user in the users table
INSERT INTO public.users (id, email, full_name, role, created_at, updated_at)
SELECT 
    id,
    email,
    COALESCE(raw_user_meta_data->>'full_name', 'System Administrator'),
    'admin',
    created_at,
    updated_at
FROM auth.users 
WHERE email = 'abdulssekyanzi@gmail.com'
ON CONFLICT (id) DO UPDATE SET
    role = 'admin',
    updated_at = NOW();

-- 6. Grant necessary permissions
GRANT ALL ON public.users TO authenticated;
GRANT ALL ON public.users TO service_role;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Admin login fix applied successfully!';
    RAISE NOTICE 'Admin user updated with proper role and metadata.';
    RAISE NOTICE 'RLS policies simplified to avoid recursion.';
END $$;
