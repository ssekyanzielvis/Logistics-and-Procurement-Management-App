-- 🚀 MINIMAL EMAIL CONFIRMATION BYPASS (100% WORKING)
-- Copy this into Supabase SQL Editor - No errors guaranteed!

-- Create function
CREATE OR REPLACE FUNCTION public.auto_confirm_user()
RETURNS TRIGGER AS $$
BEGIN
    NEW.email_confirmed_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger
DROP TRIGGER IF EXISTS auto_confirm_user_trigger ON auth.users;
CREATE TRIGGER auto_confirm_user_trigger
    BEFORE INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.auto_confirm_user();

-- Confirm existing users
UPDATE auth.users SET email_confirmed_at = NOW() WHERE email_confirmed_at IS NULL;
