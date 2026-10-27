-- Jalankan juga pada project Supabase yang sudah memakai versi sebelumnya.
-- setup.sql harus dijalankan lebih dahulu karena menggunakan fungsi is_site_admin().
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('site-assets', 'site-assets', true, 5242880, array['image/png','image/jpeg','image/webp'])
on conflict (id) do nothing;
drop policy if exists creative_island_logo_upload on storage.objects;
create policy creative_island_logo_upload on storage.objects for insert to authenticated
with check (bucket_id = 'site-assets' and (storage.foldername(name))[1] = 'logo' and (select public.is_site_admin()));
-- Bucket ini publik untuk menampilkan logo; hanya admin yang boleh mengunggah.
