-- =============================================
-- SUPABASE EMAIL CONFIRMATION BYPASS SETUP
-- =============================================

-- This script shows how to bypass email confirmation for development
-- You need to execute these settings in your Supabase Dashboard

-- =============================================
-- METHOD 1: DASHBOARD SETTINGS (RECOMMENDED)
-- =============================================

/*
To disable email confirmation in Supabase Dashboard:

1. Go to your Supabase project dashboard
2. Navigate to Authentication > Settings 
3. Under "User Signups" section:
   - Set "Enable email confirmations" to OFF
   - OR set "Enable email confirmations" to ON but add auto-confirm rules

4. Under "Email Templates" section:
   - You can customize the confirmation email template if needed

5. Save the changes
*/

-- =============================================
-- METHOD 2: AUTO-CONFIRM USERS VIA SQL TRIGGER
-- =============================================

-- Create a trigger to auto-confirm users upon signup
CREATE OR REPLACE FUNCTION public.auto_confirm_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Auto-confirm the user's email (confirmed_at is auto-generated)
    NEW.email_confirmed_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to auto-confirm users on signup
DROP TRIGGER IF EXISTS auto_confirm_user_trigger ON auth.users;
CREATE TRIGGER auto_confirm_user_trigger
    BEFORE INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user();

-- =============================================
-- METHOD 3: BULK CONFIRM EXISTING USERS
-- =============================================

-- If you have existing unconfirmed users, run this to confirm them all
UPDATE auth.users 
SET 
    email_confirmed_at = NOW()
WHERE 
    email_confirmed_at IS NULL;

-- =============================================
-- METHOD 4: ENVIRONMENT VARIABLE APPROACH
-- =============================================

/*
You can also set environment variables in your Supabase project:

1. Go to Project Settings > API
2. Add these environment variables:
   - GOTRUE_MAILER_AUTOCONFIRM: true
   - GOTRUE_DISABLE_SIGNUP: false
   
This will auto-confirm all new signups without sending emails.
*/

-- =============================================
-- IMPORTANT NOTES
-- =============================================

/*
ABOUT confirmed_at COLUMN:
- The "confirmed_at" column is a GENERATED COLUMN in Supabase
- It automatically gets set when "email_confirmed_at" is set
- You CANNOT directly update "confirmed_at" - it will cause an error
- Only update "email_confirmed_at" and "confirmed_at" will auto-populate

ERROR YOU MIGHT SEE:
"column "confirmed_at" can only be updated to DEFAULT"
SOLUTION: Remove "confirmed_at" from your UPDATE statements
*/

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Check if users are confirmed
SELECT 
    id,
    email,
    email_confirmed_at,
    confirmed_at,
    created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;

-- Note: auth.config table doesn't exist in most Supabase setups
-- Auth settings are managed through the Supabase Dashboard instead

-- =============================================
-- QUICK FIX: COPY AND PASTE THIS EXACT SQL
-- =============================================

-- Step 1: Create the auto-confirm function (CORRECTED VERSION)
CREATE OR REPLACE FUNCTION public.auto_confirm_user()
RETURNS TRIGGER AS $$
BEGIN
    NEW.email_confirmed_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 2: Create the trigger
DROP TRIGGER IF EXISTS auto_confirm_user_trigger ON auth.users;
CREATE TRIGGER auto_confirm_user_trigger
    BEFORE INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user();

-- Step 3: Confirm existing users (CORRECTED VERSION)
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;
