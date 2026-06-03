# Dokumen Pengujian BDD (Behavior-Driven Development)

**Nama Projek:** Mobile Koperasi (Frontend_Koperasi)  
**Metodologi:** Behavior-Driven Development (BDD) dengan Sintaks Gherkin  
**Modul:** Autentikasi, KYC Anggota Baru, Layanan Simpanan & Penarikan, Keamanan Akun  

---

## 📦 Feature 1: Autentikasi Pengguna (Login)

### Scenario: Login dengan kredensial yang valid (Positif)
* **Given** Pengguna berada di halaman Login aplikasi Koperasi
* **When** Pengguna memasukkan Email `"budi.santoso@gmail.com"` dan Password `"password"`
* **And** Pengguna menekan tombol `"Login"`
* **Then** Sistem berhasil melakukan autentikasi dan menyimpan token JWT ke penyimpanan lokal
* **And** Sistem mengalihkan Pengguna ke halaman Dashboard Anggota

### Scenario: Login dengan kata sandi yang salah (Negatif)
* **Given** Pengguna berada di halaman Login aplikasi Koperasi
* **When** Pengguna memasukkan Email `"budi.santoso@gmail.com"` dan Password `"wrongpassword"`
* **And** Pengguna menekan tombol `"Login"`
* **Then** Sistem menolak autentikasi dan memunculkan snackbar error `"Email atau password salah."`
* **And** Pengguna tetap berada di halaman Login

### Scenario: Login dengan mengosongkan semua inputan (Negatif)
* **Given** Pengguna berada di halaman Login aplikasi Koperasi
* **When** Pengguna mengosongkan kolom email/telepon dan password
* **And** Pengguna menekan tombol `"Login"`
* **Then** Sistem menampilkan snackbar error `"Email/Telepon dan Password harus diisi"`
* **And** Form login tidak mengirimkan permintaan ke server

---

## 📦 Feature 2: Registrasi Akun Baru (Sign Up)

### Scenario: Registrasi menggunakan email baru yang valid (Positif)
* **Given** Pengguna berada di halaman Pendaftaran Akun (Signup)
* **When** Pengguna memasukkan Nama Lengkap `"Budi Santoso"`, Email `"budi.santoso@gmail.com"`, Password `"budi123456"`, dan Konfirmasi Password `"budi123456"`
* **And** Pengguna menekan tombol `"Daftar"`
* **Then** Server berhasil membuat akun baru dengan status belum terverifikasi
* **And** Sistem mengirimkan kode verifikasi OTP ke email terdaftar
* **And** Sistem mengalihkan Pengguna ke halaman Verifikasi Akun

### Scenario: Registrasi dengan kata sandi konfirmasi tidak cocok (Negatif)
* **Given** Pengguna berada di halaman Pendaftaran Akun (Signup)
* **When** Pengguna memasukkan Nama Lengkap `"Budi Santoso"`, Email `"budi.santoso@gmail.com"`, Password `"budi123456"`, dan Konfirmasi Password `"budi654321"`
* **And** Pengguna menekan tombol `"Daftar"`
* **Then** Sistem membatalkan proses registrasi secara lokal
* **And** Sistem memunculkan snackbar error `"Password dan konfirmasi password tidak cocok"`

### Scenario: Registrasi dengan kolom formulir yang kosong (Negatif)
* **Given** Pengguna berada di halaman Pendaftaran Akun (Signup)
* **When** Pengguna mengosongkan satu atau seluruh kolom pada form registrasi
* **And** Pengguna menekan tombol `"Daftar"`
* **Then** Sistem menampilkan snackbar error `"Semua kolom harus diisi"`

---

## 📦 Feature 3: Verifikasi Akun dengan OTP (OTP Verification)

### Scenario: Memasukkan kode OTP yang valid (Positif)
* **Given** Pengguna berada di halaman Verifikasi OTP
* **When** Pengguna memasukkan kode OTP `"654321"` yang diterima di email terdaftar
* **And** Pengguna menekan tombol `"Verifikasi"`
* **Then** Sistem memverifikasi kode OTP ke server dan akun dinyatakan aktif/terverifikasi
* **And** Sistem menampilkan dialog sukses dan mengalihkan Pengguna ke halaman Login

### Scenario: Memasukkan kode OTP yang salah atau kedaluwarsa (Negatif)
* **Given** Pengguna berada di halaman Verifikasi OTP
* **When** Pengguna memasukkan kode OTP `"999999"` (tidak valid)
* **And** Pengguna menekan tombol `"Verifikasi"`
* **Then** Server menolak verifikasi tersebut
* **And** Sistem memunculkan snackbar error `"Kode OTP salah atau sudah kadaluarsa."`

---

## 📦 Feature 4: Pendaftaran Anggota Koperasi (KYC)

### Scenario: Mengisi data kontak pada KYC Step 1 (Positif)
* **Given** Pengguna berada di halaman Formulir KYC (Step 1 - Kontak)
* **When** Pengguna memasukkan Nomor Telepon `"08123456789"`
* **And** Pengguna menekan tombol `"Lanjut"`
* **Then** Sistem memvalidasi kontak dan mengalihkan Pengguna ke Step 2 (Upload Dokumen)

### Scenario: Mengunggah berkas identitas pada KYC Step 2 (Positif)
* **Given** Pengguna berada di halaman Upload Dokumen KYC (Step 2 - Dokumen)
* **When** Pengguna mengunggah foto KTP, Kartu Anggota, Pas Foto, dan Foto Tanda Tangan
* **And** Pengguna menekan tombol `"Lanjut"`
* **Then** Sistem melakukan pembacaan dokumen via modul OCR AI
* **And** Pengguna dialihkan ke Step 3 (Verifikasi Data OCR) dengan formulir terisi otomatis

### Scenario: Melewati unggahan berkas identitas wajib pada KYC Step 2 (Negatif)
* **Given** Pengguna berada di halaman Upload Dokumen KYC (Step 2 - Dokumen)
* **When** Pengguna hanya mengunggah foto KTP dan membiarkan dokumen lain kosong
* **And** Pengguna menekan tombol `"Lanjut"`
* **Then** Sistem menolak untuk melanjutkan langkah pengisian
* **And** Sistem memunculkan snackbar peringatan `"Harap upload Kartu Anggota terlebih dahulu"`

### Scenario: Memeriksa dan mengonfirmasi hasil OCR pada KYC Step 3 (Positif)
* **Given** Pengguna berada di halaman Verifikasi Data OCR (Step 3) dengan data terisi
* **When** Pengguna memeriksa kesesuaian Nama `"BUDI SANTOSO"`, NIK `"3275012345678901"`, dan Alamat
* **And** Pengguna menekan tombol `"Lanjut"`
* **Then** Sistem menyimpan data identitas diri dan mengalihkan Pengguna ke Step 4 (Pemilihan Simpanan)

### Scenario: Memilih simpanan awal pada KYC Step 4 (Positif)
* **Given** Pengguna berada di halaman Setup Simpanan Awal (Step 4)
* **When** Pengguna memilih jenis `"Simpanan Sukarela"` dan menginput nominal `"100000"`
* **And** Pengguna menekan tombol `"Lanjut"`
* **Then** Data simpanan disimpan di memori state dan Pengguna diarahkan ke Step 5 (Konfirmasi & Persetujuan)

### Scenario: Mengirimkan pengajuan keanggotaan setelah menyetujui syarat (Step 5) (Positif)
* **Given** Pengguna berada di halaman Persetujuan KYC (Step 5)
* **When** Pengguna mencentang kotak persetujuan Syarat & Ketentuan Koperasi
* **And** Pengguna menekan tombol `"Ajukan Pendaftaran"`
* **Then** Sistem mengirimkan semua data formulir dan berkas gambar biner ke API `/api/member/register`
* **And** Sistem menampilkan dialog sukses pendaftaran dan mengarahkan ke halaman Dashboard Status

---

## 📦 Feature 5: Layanan Keuangan (Buka Simpanan & Penarikan Dana)

### Scenario: Membuka rekening simpanan baru dari dashboard (Positif)
* **Given** Pengguna telah berstatus Anggota Resmi dan berada di halaman Buka Simpanan
* **When** Pengguna memilih jenis simpanan `"Simpanan Berjangka"`, nominal `"500000"`, dan bank asal `"Bank Mandiri"`
* **And** Pengguna menekan tombol `"Buka Simpanan"`
* **Then** Sistem memproses data ke server dan memunculkan snackbar sukses `"Permohonan buka simpanan sedang diproses"`
* **And** Halaman menutup dan kembali ke dashboard keuangan utama

### Scenario: Mengajukan penarikan dana sukarela (Positif)
* **Given** Pengguna berada di form Penarikan Dana
* **When** Pengguna memilih simpanan asal `"Simpanan Sukarela"`, menginput nominal `"250000"`, dan alasan penarikan
* **And** Pengguna menekan tombol `"Ajukan Penarikan"`
* **Then** Server mencatat permohonan penarikan dana tersebut
* **And** Sistem memunculkan snackbar sukses `"Pengajuan penarikan sedang diproses"` dan kembali ke halaman utama

---

## 📦 Feature 6: Keamanan Akun (Ubah Kata Sandi)

### Scenario: Mengubah kata sandi lama dengan kata sandi baru (Positif)
* **Given** Pengguna telah login dan berada di halaman Ubah Kata Sandi
* **When** Pengguna menginput Kata Sandi Lama `"password"`, Kata Sandi Baru `"newpassword123"`, dan Konfirmasi Baru `"newpassword123"`
* **And** Pengguna menekan tombol `"Simpan"`
* **Then** Server memperbarui kata sandi di database dan mengembalikan respon sukses
* **And** Sistem menampilkan snackbar sukses `"Kata sandi berhasil diubah"`
* **And** Pengguna dikembalikan ke menu Pengaturan Akun
