-- Supabase Storage Buckets Configuration
-- Execute these SQL commands in your Supabase SQL Editor after setting up the database schema

-- =============================================
-- STORAGE BUCKETS
-- =============================================

-- Create bucket for delivery note images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'delivery-notes',
    'delivery-notes',
    true,
    52428800, -- 50MB limit
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
);

-- Create bucket for profile images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profile-images',
    'profile-images',
    true,
    10485760, -- 10MB limit
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
);

-- Create bucket for chat attachments
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'chat-attachments',
    'chat-attachments',
    true,
    104857600, -- 100MB limit
    ARRAY[
        'image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif',
        'application/pdf', 'text/plain', 
        'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.ms-excel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ]
);

-- Create bucket for fuel transaction receipts
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'fuel-receipts',
    'fuel-receipts',
    true,
    20971520, -- 20MB limit
    ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'application/pdf']
);

-- Create bucket for consignment documents
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'consignment-docs',
    'consignment-docs',
    true,
    52428800, -- 50MB limit
    ARRAY[
        'image/jpeg', 'image/jpg', 'image/png', 'image/webp',
        'application/pdf', 'text/plain',
        'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
    ]
);

-- =============================================
-- STORAGE POLICIES
-- =============================================

-- Delivery notes bucket policies
CREATE POLICY "Users can view delivery note images" ON storage.objects
    FOR SELECT USING (bucket_id = 'delivery-notes');

CREATE POLICY "Drivers can upload delivery note images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'delivery-notes' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'driver'
        )
    );

CREATE POLICY "Drivers can update their delivery note images" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'delivery-notes' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('driver', 'admin', 'other_admin')
        )
    );

CREATE POLICY "Admins can delete delivery note images" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'delivery-notes' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
        )
    );

-- Profile images bucket policies
CREATE POLICY "Users can view profile images" ON storage.objects
    FOR SELECT USING (bucket_id = 'profile-images');

CREATE POLICY "Users can upload their own profile image" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'profile-images' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can update their own profile image" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'profile-images' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete their own profile image" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'profile-images' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

-- Chat attachments bucket policies
CREATE POLICY "Users can view chat attachments" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'chat-attachments' AND
        auth.role() = 'authenticated'
    );

CREATE POLICY "Users can upload chat attachments" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'chat-attachments' AND
        auth.role() = 'authenticated'
    );

CREATE POLICY "Users can update their chat attachments" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'chat-attachments' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete their chat attachments" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'chat-attachments' AND
        auth.role() = 'authenticated' AND
        (storage.foldername(name))[1] = auth.uid()::text
    );

-- Fuel receipts bucket policies
CREATE POLICY "Users can view fuel receipts" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'fuel-receipts' AND
        auth.role() = 'authenticated'
    );

CREATE POLICY "Drivers can upload fuel receipts" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'fuel-receipts' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'driver'
        )
    );

CREATE POLICY "Drivers and admins can manage fuel receipts" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'fuel-receipts' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role IN ('driver', 'admin', 'other_admin')
        )
    );

-- Consignment documents bucket policies
CREATE POLICY "Users can view consignment documents" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'consignment-docs' AND
        auth.role() = 'authenticated'
    );

CREATE POLICY "Clients can upload consignment documents" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'consignment-docs' AND
        auth.role() = 'authenticated' AND
        EXISTS (
            SELECT 1 FROM public.users 
            WHERE id = auth.uid() AND role = 'client'
        )
    );

CREATE POLICY "Users can update their consignment documents" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'consignment-docs' AND
        auth.role() = 'authenticated' AND
        (
            (storage.foldername(name))[1] = auth.uid()::text OR
            EXISTS (
                SELECT 1 FROM public.users 
                WHERE id = auth.uid() AND role IN ('admin', 'other_admin')
            )
        )
    );

-- =============================================
-- HELPER FUNCTIONS FOR STORAGE
-- =============================================

-- Function to generate secure file paths
CREATE OR REPLACE FUNCTION public.generate_file_path(
    bucket_name TEXT,
    user_id UUID,
    file_extension TEXT
)
RETURNS TEXT AS $$
BEGIN
    RETURN user_id::text || '/' || 
           extract(year from now()) || '/' ||
           extract(month from now()) || '/' ||
           extract(epoch from now())::bigint || '_' ||
           substr(md5(random()::text), 1, 8) || '.' || 
           file_extension;
END;
$$ LANGUAGE plpgsql;

-- Function to clean up orphaned files (run periodically)
CREATE OR REPLACE FUNCTION public.cleanup_orphaned_files()
RETURNS void AS $$
BEGIN
    -- Clean up delivery note images not referenced in delivery_notes table
    DELETE FROM storage.objects 
    WHERE bucket_id = 'delivery-notes' 
    AND created_at < NOW() - INTERVAL '7 days'
    AND name NOT IN (
        SELECT DISTINCT substring(image_url from '[^/]+$') 
        FROM public.delivery_notes 
        WHERE image_url LIKE '%delivery-notes%'
    );
    
    -- Clean up profile images not referenced in users table
    DELETE FROM storage.objects 
    WHERE bucket_id = 'profile-images' 
    AND created_at < NOW() - INTERVAL '30 days'
    AND name NOT IN (
        SELECT DISTINCT substring(profile_image from '[^/]+$') 
        FROM public.users 
        WHERE profile_image LIKE '%profile-images%'
    );
END;
$$ LANGUAGE plpgsql;

COMMIT;
