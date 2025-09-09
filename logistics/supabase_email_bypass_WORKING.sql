-- ✅ WORKING EMAIL CONFIRMATION BYPASS SQL
-- Copy and paste this EXACT code into your Supabase SQL Editor

-- Step 1: Create auto-confirm function (only updates email_confirmed_at)
CREATE OR REPLACE FUNCTION public.auto_confirm_user()
RETURNS TRIGGER AS $$
BEGIN
    NEW.email_confirmed_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Create trigger to auto-confirm new users
DROP TRIGGER IF EXISTS auto_confirm_user_trigger ON auth.users;
CREATE TRIGGER auto_confirm_user_trigger
    BEFORE INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user();

-- Step 3: Confirm all existing unconfirmed users
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- Step 4: Verify it worked - check recent users
SELECT 
    id,
    email,
    email_confirmed_at,
    confirmed_at,
    created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 5;

-- ✅ SUCCESS: All users should now have email_confirmed_at AND confirmed_at set!
