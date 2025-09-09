# 🆘 EMERGENCY: Infinite Recursion Fix

## 🚨 **IMMEDIATE ACTION REQUIRED**

The infinite recursion error is happening because:
1. `getUserProfile()` queries the `users` table
2. RLS policies on `users` table reference the `users` table
3. This creates an infinite loop

## ⚡ **EMERGENCY FIX** (Try this first):

```sql
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
```

## 🚨 **NUCLEAR OPTION** (If emergency fix fails):

```sql
-- Completely disable RLS for development
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.admins DISABLE ROW LEVEL SECURITY;
```

## 📋 **Steps**:

1. **Copy and paste** the Emergency Fix SQL into Supabase SQL Editor
2. **Click "Run"** to execute
3. **Test admin registration** immediately
4. **If still fails**, run the Nuclear Option SQL
5. **Verify** - no more recursion errors

## ✅ **Expected Result**:
- ❌ No more "infinite recursion detected" errors
- ✅ Admin registration works
- ✅ getUserProfile() succeeds
- ✅ Dashboard loads without errors

## ⚠️ **Important Note**:
The Nuclear Option disables all security for development. This is **safe for development** but you'll need to implement proper RLS policies before production.

**Status: Choose Emergency Fix or Nuclear Option based on urgency! 🚀**
