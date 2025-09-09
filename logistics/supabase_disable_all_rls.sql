-- 🆘 NUCLEAR OPTION - DISABLE RLS FOR DEVELOPMENT
-- Use this if the recursion error persists

-- Completely disable RLS on problematic tables
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.consignments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_notes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_cards DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_card_assignments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_transactions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.fuel_card_lockers DISABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies
DO $$ 
DECLARE
    pol record;
BEGIN
    FOR pol IN 
        SELECT schemaname, tablename, policyname 
        FROM pg_policies 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS "' || pol.policyname || '" ON ' || pol.schemaname || '.' || pol.tablename;
    END LOOP;
END $$;

-- Verify no policies remain
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public';

-- Note: This disables all security for development
-- Re-enable RLS and add proper policies once app is working
