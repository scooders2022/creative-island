# Panduan Creative Island: GitHub Pages + Supabase

## Yang disiapkan
- Akun GitHub dan Supabase, serta email dan kata sandi admin yang Anda buat sendiri.
- Koneksi internet. GitHub Pages menyediakan frontend statis, sedangkan Supabase menyediakan database, login admin, dan penyimpanan pesan. Tidak ada server Node atau PHP yang perlu diunggah.
- Folder ini berisi `index.html`, `admin.html`, `config.js`, `assets`, `supabase/setup.sql`, dan panduan. Upload isi folder, bukan file ZIP yang belum diekstrak.

## 1. Buat project Supabase
1. Buka https://supabase.com/dashboard, buat project baru dan tunggu sampai siap.
2. Buka **SQL Editor**, buat query baru, salin seluruh isi `supabase/setup.sql`, lalu pilih **Run**. Pastikan muncul pesan berhasil.
3. Buka **Authentication > Users** dan tambahkan user menggunakan email dan kata sandi admin yang Anda tentukan sendiri. Pastikan pengguna sudah dikonfirmasi agar dapat login. Jangan gunakan akun contoh.
4. Kembali ke **SQL Editor**, jalankan query berikut setelah mengganti alamat email dengan email admin yang tepat:

```sql
insert into public.site_admins (user_id)
select id from auth.users where email = 'EMAIL_ADMIN_ANDA'
on conflict (user_id) do nothing;
```

5. Hasil `INSERT 0 1` berarti akun ditambahkan; `INSERT 0 0` berarti email tidak cocok atau akun sudah ada. Periksa dengan query berikut (ganti email):

```sql
select u.email, a.user_id from public.site_admins a
join auth.users u on u.id = a.user_id
where u.email = 'EMAIL_ADMIN_ANDA';
```

Jika tidak ada hasil, periksa bahwa email user sudah dibuat dengan benar, lalu ulangi langkah 4. Untuk admin kedua, buat user dan ulangi untuk emailnya. Pendaftaran user baru sendiri tidak otomatis menjadikannya admin.

## 2. Hubungkan konfigurasi
1. Di pengaturan project Supabase, buka bagian **API** atau **Connect** untuk menemukan Project URL dan publishable key (atau legacy anon key).
2. Buka file `config.js` dengan Notepad atau VS Code, lalu ganti dua nilai contoh:

```js
window.SUPABASE_CONFIG = {
  url: 'https://PROJECT-ANDA.supabase.co',
  key: 'PUBLISHABLE_KEY_ANDA'
};
```

3. Simpan file. Publishable key atau anon key memang dipakai di frontend dengan RLS. **Jangan pernah memasukkan service_role key, secret key, password database, atau kata sandi admin ke GitHub.**
4. URL dan key harus berasal dari project Supabase yang sama dengan SQL dan user admin di atas.

## 3. Upload ke GitHub
1. Buat repository baru di GitHub. Agar GitHub Pages dapat diakses publik, pilih **Public** jika akun GitHub Anda memerlukan repository publik untuk Pages.
2. Buka repository > **Add file > Upload files**. Upload seluruh isi folder proyek: `index.html`, `admin.html`, `config.js`, folder `assets`, folder `supabase`, dan file panduan. Pastikan `index.html` berada di akar repository, bukan di dalam folder tambahan.
3. Pilih **Commit changes**.
4. Buka **Settings > Pages**. Pada **Build and deployment**, pilih **Deploy from a branch**, branch `main`, folder `/ (root)`, lalu **Save**.
5. Tunggu GitHub menampilkan alamat website pada halaman Pages. Buka alamat yang ditampilkan. Tidak perlu menjalankan npm atau mengunggah node_modules.

## 4. Gunakan halaman admin
1. Buka alamat website dan klik **Admin** pada bagian bawah halaman, atau tambahkan `admin.html` setelah alamat website (misalnya `https://nama.github.io/nama-repository/admin.html`).
2. Login menggunakan email dan kata sandi user yang sudah ditambahkan ke tabel `site_admins`.
3. **Pengaturan & Konten:** ubah nama usaha, judul halaman, tagline, deskripsi, email, lokasi, dan nomor WhatsApp (contoh `628123456789`, tanpa tanda +). Untuk logo, pilih PNG, JPG, atau WebP maksimal 5 MB, klik **Unggah logo**, lalu klik **SIMPAN KONTEN** untuk menerapkan semua perubahan.
4. **Layanan:** tambah, ubah, hapus, atau susun urutan layanan lalu simpan.
5. **Portofolio:** tambah proyek, deskripsi, kategori, URL proyek, dan URL gambar yang dapat diakses publik. Foto memakai URL publik HTTPS; unggah gambar ke penyedia pilihan terlebih dahulu. Simpan perubahan.
6. **Proses Kerja:** tambah, ubah, hapus, dan atur urutan tahapan lalu simpan.
7. **Pesan Masuk:** lihat dan hapus permintaan yang dikirim melalui formulir. Penghapusan pesan bersifat permanen.
8. Setelah selesai, klik **Keluar**.

## 5. Pengujian setelah pemasangan
- Buka website pada desktop dan ponsel; periksa menu, tombol, dan tampilan.
- Login admin, ubah satu teks, simpan, lalu muat ulang halaman utama untuk memastikan perubahan muncul.
- Kirim satu pesan uji melalui formulir dan periksa pada **Pesan Masuk**. Hapus pesan uji setelah selesai.
- Uji akun non-admin: akun yang tidak terdaftar di `site_admins` tidak boleh mengelola konten atau membaca pesan.
- Uji logout dan login ulang. Konfirmasi URL proyek dan gambar dapat dibuka.

## 6. Penjelasan dan pemecahan masalah
- **Admin belum terdaftar:** jalankan langkah 1.4 dengan email yang tepat. Pastikan SQL, konfigurasi URL, dan akun berada pada project yang sama.
- **Login gagal:** periksa email, kata sandi, status konfirmasi user, dan project. Jangan membagikan kata sandi di chat atau menyimpannya dalam repository.
- **Tidak bisa simpan / pesan gagal:** pastikan `setup.sql` berhasil, RLS aktif, URL dan key benar, serta koneksi internet tersedia. Periksa log dan kebijakan di Supabase.
- **Konten awal yang tampil sebelum tersambung:** situs menggunakan teks bawaan. Formulir tidak akan mengirim pesan jika konfigurasi belum benar.
- **Gambar portofolio tidak tampil:** gunakan URL gambar langsung yang publik, bukan tautan halaman berbagi yang memerlukan login.
- **Perubahan belum muncul:** muat ulang browser. Jika ada beberapa admin mengubah data bersamaan, penyimpanan terakhir dapat menimpa perubahan sebelumnya.
- Formulir bersifat publik sehingga berpotensi menerima spam. Untuk penggunaan publik skala besar, tambahkan CAPTCHA, pembatasan permintaan, dan pemantauan; implementasi ini belum menyediakannya.
- Formulir menyimpan pesan di Supabase, tidak mengirim notifikasi email otomatis. Pencadangan dan kebijakan privasi harus disiapkan sesuai kebutuhan usaha.
- Logo dapat diunggah lewat admin ke bucket Supabase publik `site-assets`. Logo yang sudah diganti tetap tersimpan di bucket sampai dihapus manual oleh pemilik project. Gambar portofolio masih menggunakan URL publik, belum memiliki upload file dari panel.
- Tampilan referensi seperti case study lengkap, carousel testimoni, belum termasuk dalam panel ini. Halaman layanan, proyek, kontak, dan teks utama bisa dikelola.

## Struktur
```
index.html            Halaman utama
admin.html            Login dan dashboard admin
config.js             Konfigurasi URL dan publishable/anon key
assets/style.css      Tampilan
assets/app.js         Interaksi website
assets/admin.js       Interaksi dashboard admin
assets/logo.png       Logo Creative Island
supabase/setup.sql    Struktur database dan kebijakan RLS
```

## Jika memperbarui versi sebelumnya

1. Upload dan ganti file `index.html`, `admin.html`, dan folder `assets` di repository GitHub. Pertahankan `config.js` lama agar URL dan key tidak tertimpa.
2. Di Supabase SQL Editor, jalankan `supabase/tambah_storage_logo.sql` satu kali setelah setup lama. Skrip menyiapkan bucket publik dan izin unggah khusus admin tanpa menghapus konten atau pesan.
3. Tunggu GitHub Pages selesai, lalu muat ulang browser. Masuk ke admin dan gunakan Pengaturan & Konten untuk logo dan nama usaha.
4. Jika gagal unggah, pastikan Anda terdaftar sebagai admin, storage script berhasil, ukuran gambar tidak lebih dari 5 MB, dan project tidak memiliki bucket `site-assets` lama dengan pengaturan berbeda.
