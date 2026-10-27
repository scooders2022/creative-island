-- CREATIVE ISLAND: jalankan satu kali di SQL Editor Supabase project baru.
-- Tidak menghapus data yang sudah ada.
create extension if not exists pgcrypto;
create table if not exists public.site_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.site_content (
  id integer primary key check (id = 1),
  content jsonb not null default '{}'::jsonb check (jsonb_typeof(content) = 'object'),
  updated_at timestamptz not null default now()
);
create table if not exists public.inquiries (
 id uuid primary key default gen_random_uuid(),
 name text not null check (char_length(trim(name)) between 1 and 100),
 company text not null default '' check (char_length(company) <= 150),
 email text not null check (char_length(email) between 3 and 200 and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
 project_type text not null default '' check (char_length(project_type) <= 100),
 budget text not null default '' check (char_length(budget) <= 100),
 details text not null check (char_length(trim(details)) between 1 and 4000),
 created_at timestamptz not null default now()
);
insert into public.site_content(id,content) values (1, '{"tagline":"WHERE IDEAS COME ALIVE.","hero_description":"Kami membantu usaha membangun merek, produk digital, dan pengalaman yang berkesan.","manifesto":"Kami percaya pengalaman digital yang baik lahir dari strategi, desain, teknologi, dan kreativitas.","about":"Creative Island membantu usaha menghadirkan ide menjadi pengalaman digital yang bermakna.","about_detail":"Kami mengerjakan periklanan digital, website, aplikasi web dan mobile, serta desain UI/UX sesuai kebutuhan proyek.","email":"","location":"Indonesia","whatsapp":"","services":[{"title":"DIGITAL MARKETING","description":"Manajemen konten dan kampanye digital sesuai kebutuhan usaha."},{"title":"WEBSITE","description":"Website profil, katalog, dan landing page yang responsif."},{"title":"APLIKASI WEB","description":"Sistem berbasis web untuk mendukung alur kerja usaha."},{"title":"APLIKASI MOBILE","description":"Aplikasi mobile yang dirancang untuk kebutuhan pengguna."},{"title":"DESAIN UI/UX","description":"Alur dan antarmuka yang jelas untuk produk digital."}],"projects":[]}'::jsonb) on conflict (id) do nothing;
alter table public.site_admins enable row level security;
alter table public.site_content enable row level security;
alter table public.inquiries enable row level security;
revoke all on public.site_admins, public.site_content, public.inquiries from anon, authenticated;
grant select on public.site_content to anon, authenticated;
grant update on public.site_content to authenticated;
grant insert (name,company,email,project_type,budget,details) on public.inquiries to anon, authenticated;
grant select, delete on public.inquiries to authenticated;
grant select on public.site_admins to authenticated;
create or replace function public.is_site_admin() returns boolean language sql stable security definer set search_path = '' as $$
 select exists(select 1 from public.site_admins where user_id = (select auth.uid()));
$$;
revoke all on function public.is_site_admin() from public;
grant execute on function public.is_site_admin() to authenticated;
drop policy if exists admins_read_self on public.site_admins;
create policy admins_read_self on public.site_admins for select to authenticated using (user_id = (select auth.uid()));
drop policy if exists content_public_read on public.site_content;
create policy content_public_read on public.site_content for select to anon, authenticated using (true);
drop policy if exists content_admin_update on public.site_content;
create policy content_admin_update on public.site_content for update to authenticated using ((select public.is_site_admin())) with check ((select public.is_site_admin()));
drop policy if exists inquiries_public_insert on public.inquiries;
create policy inquiries_public_insert on public.inquiries for insert to anon, authenticated with check (true);
drop policy if exists inquiries_admin_read on public.inquiries;
create policy inquiries_admin_read on public.inquiries for select to authenticated using ((select public.is_site_admin()));
drop policy if exists inquiries_admin_delete on public.inquiries;
create policy inquiries_admin_delete on public.inquiries for delete to authenticated using ((select public.is_site_admin()));
-- Admin ditambahkan setelah membuat user di Authentication, lihat panduan.
-- Jalankan juga pada project Supabase yang sudah memakai versi sebelumnya.
-- setup.sql harus dijalankan lebih dahulu karena menggunakan fungsi is_site_admin().
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('site-assets', 'site-assets', true, 5242880, array['image/png','image/jpeg','image/webp'])
on conflict (id) do nothing;
drop policy if exists creative_island_logo_upload on storage.objects;
create policy creative_island_logo_upload on storage.objects for insert to authenticated
with check (bucket_id = 'site-assets' and (storage.foldername(name))[1] = 'logo' and (select public.is_site_admin()));
-- Bucket ini publik untuk menampilkan logo; hanya admin yang boleh mengunggah.
