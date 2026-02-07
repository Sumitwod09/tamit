-- Storage buckets and policies for Tamit
-- Run this in Supabase SQL editor

-- Create storage buckets (you may need to do this via Supabase Dashboard instead)
-- This is for reference. Create these buckets in the Supabase Dashboard:
-- 1. Name: "avatars" (Public: true)
-- 2. Name: "posts" (Public: true)

-- Storage policies for avatars bucket
-- After creating the bucket, run these policies:

-- Anyone authenticated can upload avatars
CREATE POLICY "Authenticated users can upload avatars"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'avatars');

-- Anyone can view avatars (public bucket)
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

-- Users can update their own avatar
CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1])
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users can delete their own avatar
CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Storage policies for posts bucket

-- Anyone authenticated can upload post images
CREATE POLICY "Authenticated users can upload post images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'posts');

-- Anyone can view post images (public bucket)
CREATE POLICY "Post images are publicly accessible"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'posts');

-- Users can delete their own post images
CREATE POLICY "Users can delete own post images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'posts' AND auth.uid()::text = (storage.foldername(name))[1]);
