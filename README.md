# 📱 Aplikasi Arisan Digital v2

Aplikasi Arisan Digital v2 adalah platform manajemen arisan modern berbasis *mobile* (Android/iOS) yang memudahkan pengelola maupun peserta arisan untuk memantau iuran bulanan, undian pemenang (*Gacha*), dan riwayat arisan secara transparan dan terpusat.

## ✨ Fitur Utama

Aplikasi ini dibagi menjadi 2 buah peran (*Role*) utama dengan fitur masing-masing:

### 👑 Pengelola (Admin)
- **Manajemen Grup Arisan:** Membuat, mengubah nama, dan menghapus grup arisan.
- **Manajemen Peserta:** Menambahkan peserta arisan lengkap dengan *username* dan *password* unik.
- **Pencatatan Iuran:** Mengubah status pembayaran (Belum/Sudah bayar) peserta setiap bulannya.
- **Sistem Undian Otomatis (Gacha):** Mengundi secara acak pemenang arisan pada bulan berjalan dengan animasi rolet yang menarik.
- **Riwayat Kemenangan:** Melihat daftar peserta yang telah memenangkan arisan pada bulan-bulan sebelumnya.
- **Advance Month:** Melanjutkan periode arisan ke bulan berikutnya (otomatis mereset status pembayaran).

### 👥 Peserta (Member)
- **Login Khusus Peserta:** Masuk menggunakan nama pengguna dan kata sandi yang telah didaftarkan oleh Pengelola.
- **Pemantauan Pembayaran:** Melihat status pembayaran pribadi (Sudah/Belum bayar) untuk bulan berjalan.
- **Riwayat Pemenang:** Melihat transparansi daftar riwayat pemenang arisan per bulan.

---

## 🛠️ Teknologi yang Digunakan

Aplikasi ini dibangun menggunakan arsitektur *Client-Server* dengan *tech-stack* berikut:

- **Frontend (Mobile App):** Flutter (Dart)
- **State Management:** Provider (`provider: ^6.1.2`)
- **Backend (REST API):** Native PHP 8.x
- **Database:** MySQL
- **Local Server Environment:** Laragon / XAMPP

---

## 📂 Struktur Direktori Proyek

Proyek ini telah direstrukturisasi agar mematuhi standar pengembangan perangkat lunak modular:

### Struktur Frontend (Flutter)
```text
lib/
 ┣ core/              # File konfigurasi inti (URL API)
 ┣ providers/         # State management untuk reaktivitas UI
 ┣ services/          # Logika panggilan HTTP ke API Backend
 ┣ ui/
 ┃ ┣ screens/       # Halaman antarmuka aplikasi
 ┃ ┃ ┣ auth/        # Layar Login & Register
 ┃ ┃ ┣ pengelola/   # Fitur khusus Pengelola
 ┃ ┃ ┗ peserta/     # Fitur khusus Peserta
 ┃ ┗ widgets/       # Komponen daur ulang
 ┗ main.dart          # Entry point aplikasi
```

### Struktur Backend (PHP API)
```text
api_arisan/
 ┣ config/
 ┃ ┣ config.php       # Detail koneksi database
 ┃ ┗ db_connect.php   # Instansiasi objek database
 ┣ endpoints/
 ┃ ┣ pengelola/     # API Khusus Hak Akses Pengelola
 ┃ ┗ peserta/       # API Khusus Hak Akses Peserta
 ┗ database_schema.sql  # Skema tabel database (dbarisan)
```

---

## 🚀 Panduan Instalasi (Menjalankan secara Lokal)

Ikuti langkah-langkah berikut untuk menjalankan aplikasi ini di komputer Anda:

### 1. Persiapan Database & Backend
1. Pastikan Anda telah menginstal web server lokal seperti **Laragon** atau **XAMPP**.
2. Nyalakan layanan **Apache** dan **MySQL**.
3. Buat database baru bernama `dbarisan` di MySQL (bisa melalui phpMyAdmin atau HeidiSQL).
4. Impor (Import) *file* skema database yang tersedia di `api_arisan/database_schema.sql` (jika ada, atau salin syntax dari Skema Anda).
5. Pastikan folder proyek (terutama folder `api_arisan`) berada di dalam direktori publik *server* Anda:
   - Laragon: `C:/laragon/www/arisan_digitalv2/`
   - XAMPP: `C:/xampp/htdocs/arisan_digitalv2/`
6. Buka `api_arisan/config/config.php` dan pastikan *username* (biasanya `root`) serta *password* (biasanya kosong) sesuai dengan konfigurasi lokal Anda.

### 2. Persiapan Aplikasi Flutter
1. Pastikan Anda telah menginstal **Flutter SDK** versi terbaru.
2. Buka *terminal* pada *folder* *root* proyek ini.
3. Unduh semua dependensi dengan perintah:
   ```bash
   flutter pub get
   ```
4. Sesuaikan **IP Address Backend** pada file `lib/core/api_config.dart`. Jika Anda menggunakan emulator dan web lokal, gunakan IP statis komputer Anda atau `localhost`:
   ```dart
   static const String baseUrl = 'http://localhost/arisan_digitalv2/api_arisan'; 
   // Gunakan IP WiFi misal: http://192.168.1.5/arisan_digitalv2/api_arisan jika dijalankan di HP fisik
   ```

### 3. Menjalankan Aplikasi
Ketikkan perintah berikut pada *terminal*:
```bash
flutter run
```
Aplikasi akan menampilkan *Landing Page* beranimasi, disusul oleh pemilihan *Role* pengguna.

---

## 🔒 Keamanan
- API Backend menggunakan `Prepared Statements` (MySQLi) untuk mencegah serangan *SQL Injection*.
- Sistem validasi ganda dilakukan di sisi *Frontend* (Dart) maupun *Backend* (PHP) untuk mencegah *error input*.

---
*Dibuat untuk mempermudah rutinitas arisan bersama!* 🎈
