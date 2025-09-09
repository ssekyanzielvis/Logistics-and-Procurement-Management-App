# Logistics Management App - Supabase Setup Guide

## Prerequisites
1. A Supabase account (https://supabase.com)
2. A new Supabase project created
3. Flutter development environment set up

## Step-by-Step Setup Instructions

### 1. Create Supabase Project
1. Go to https://supabase.com and sign in
2. Click "New Project"
3. Choose your organization and give your project a name
4. Set a strong database password (save this!)
5. Select a region close to your users
6. Click "Create new project"

### 2. Environment Configuration

#### Create .env file in your project root:
```env
SUPABASE_URL=your_project_url_here
SUPABASE_ANON_KEY=your_anon_key_here
```

#### Get your credentials:
1. Go to your Supabase project dashboard
2. Click on "Settings" in the sidebar
3. Click on "API"
4. Copy the "Project URL" and "anon public" key
5. Replace the values in your .env file

### 3. Database Setup

#### Execute the database schema:
1. Go to your Supabase dashboard
2. Click on "SQL Editor" in the sidebar
3. Click "New Query"
4. Copy and paste the contents of `supabase_database_schema.sql`
5. Click "Run" to execute the script

#### Execute the storage setup:
1. In the SQL Editor, create another new query
2. Copy and paste the contents of `supabase_storage_setup.sql`
3. Click "Run" to execute the script

### 4. Authentication Configuration

#### Configure Auth Settings:
1. Go to "Authentication" > "Settings" in your Supabase dashboard
2. Under "Site URL", add your app's URL (for web) or use `http://localhost:3000` for development
3. Under "Redirect URLs", add any additional URLs your app uses

#### Enable Auth Providers (if needed):
1. Go to "Authentication" > "Providers"
2. Configure any OAuth providers you want to use (Google, GitHub, etc.)

### 5. Row Level Security (RLS) Verification

The SQL scripts automatically enable RLS and create policies. Verify they're working:

1. Go to "Authentication" > "Policies"
2. You should see policies for all tables
3. Test by creating a user and verifying they can only access their own data

### 6. Storage Configuration

#### Verify Storage Buckets:
1. Go to "Storage" in your Supabase dashboard
2. You should see the following buckets:
   - `delivery-notes`
   - `profile-images`
   - `chat-attachments`
   - `fuel-receipts`
   - `consignment-docs`

#### Configure CORS (if needed for web):
1. Go to "Storage" > "Settings"
2. Add your domain to allowed origins

### 7. Create Your First Admin User

#### Method 1: Through the App
1. Run your Flutter app
2. Go to the admin registration page
3. Sign up with your admin credentials
4. The user will be created automatically in the users table

#### Method 2: Manual Setup
1. Sign up a user through your app's normal registration
2. Get the user's UUID from "Authentication" > "Users" in Supabase
3. In SQL Editor, run:
```sql
UPDATE public.users 
SET role = 'admin' 
WHERE id = 'your-user-uuid-here';

INSERT INTO public.admins (id, admin_type) 
VALUES ('your-user-uuid-here', 'admin');
```

### 8. Test the Setup

#### Verify Database Connection:
1. Run your Flutter app
2. Try to sign up a new user
3. Check if the user appears in "Authentication" > "Users"
4. Verify the user profile is created in the `users` table

#### Test Functionality:
1. Create a consignment as a client
2. Upload a delivery note as a driver
3. Send a message in chat
4. Verify all data appears correctly in your Supabase dashboard

### 9. Production Considerations

#### Security:
1. Ensure RLS policies are properly configured
2. Review and test all policies thoroughly
3. Use environment variables for sensitive data
4. Enable database backups

#### Performance:
1. Monitor your database usage in Supabase dashboard
2. Add indexes for frequently queried columns
3. Consider upgrading your Supabase plan if needed

#### Backup:
1. Enable automatic backups in Supabase settings
2. Consider implementing additional backup strategies for critical data

## Troubleshooting

### Common Issues:

#### "Authentication Error":
- Check your .env file has correct SUPABASE_URL and SUPABASE_ANON_KEY
- Verify the project URL doesn't have trailing slashes
- Ensure the anon key is the public one, not the service role key

#### "Permission Denied" Errors:
- Check RLS policies are correctly configured
- Verify the user has the correct role assigned
- Test policies in the SQL Editor

#### "Bucket Not Found" Errors:
- Run the storage setup SQL script
- Verify buckets exist in Storage dashboard
- Check bucket names match exactly in your code

#### Users Not Created Automatically:
- Verify the trigger function `handle_new_user()` exists
- Check if the trigger `on_auth_user_created` is active
- Look for errors in the Supabase logs

### Getting Help:
1. Check Supabase documentation: https://supabase.com/docs
2. Visit Supabase Discord: https://discord.supabase.com
3. Review the SQL logs in your Supabase dashboard for error details

## Database Schema Overview

### Core Tables:
- **users**: User profiles with roles (admin, client, driver)
- **consignments**: Shipment/delivery requests
- **delivery_notes**: Proof of delivery with images
- **fuel_cards**: Fleet fuel card management
- **fuel_transactions**: Fuel usage tracking
- **chat_rooms & chat_messages**: In-app messaging

### Storage Buckets:
- **delivery-notes**: Delivery proof images
- **profile-images**: User profile pictures
- **chat-attachments**: File sharing in messages
- **fuel-receipts**: Fuel transaction receipts
- **consignment-docs**: Shipment documentation

All tables include:
- Automatic UUID primary keys
- Created/updated timestamps
- Row Level Security policies
- Proper foreign key relationships
