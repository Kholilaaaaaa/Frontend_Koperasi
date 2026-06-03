# Template Operation Testing – Capstone Project

**Nama Projek:** Mobile Koperasi (Frontend_Koperasi)  
**Modul:** Autentikasi, KYC Pendaftaran Anggota, Layanan Keuangan (Simpanan & Penarikan), Ubah Kata Sandi  
**Tester:** [Nama Tester / Mahasiswa]  

---

## Tabel Pengujian Operasional (Functionality)

| ID Test | Skenario (Scenario Name) | Jenis (+/- / Edge) | Precondition (Prasyarat) | Langkah Eksekusi (Test Steps) | Data Uji (Test Data) | Hasil yang Diharapkan (Test Expected) | Status (OK/NG) |
| :--- | :--- | :---: | :--- | :--- | :--- | :--- | :---: |
| **OP-01** | Verify Login Success | Positif (+) | User berada di halaman login | 1. Input email terdaftar<br>2. Input password valid<br>3. Klik tombol "Login" | Email: `budi.santoso@gmail.com`<br>Pass: `password` | Sistem berhasil login, menyimpan token JWT, dan mengarahkan ke dashboard yang sesuai (Member/Visitor/Status). | OK |
| **OP-02** | Verify Login Failed (Wrong Credentials) | Negatif (-) | User berada di halaman login | 1. Input email terdaftar<br>2. Input password salah<br>3. Klik tombol "Login" | Email: `budi.santoso@gmail.com`<br>Pass: `wrongpassword` | Tampil snackbar Error/Gagal dengan pesan: "Email atau password salah." | OK |
| **OP-03** | Verify Login Empty Inputs | Negatif (-) | User berada di halaman login | 1. Kosongkan email dan password<br>2. Klik tombol "Login" | Email: ``<br>Pass: `` | Tampil snackbar Error dengan pesan: "Email/Telepon dan Password harus diisi" | OK |
| **OP-04** | Verify Signup Success | Positif (+) | User berada di halaman signup | 1. Input nama lengkap<br>2. Input email aktif<br>3. Input password & konfirmasi password<br>4. Klik tombol "Daftar" | Nama: `Budi Santoso`<br>Email: `budi.santoso@gmail.com`<br>Pass: `budi123456`<br>Confirm: `budi123456` | Pendaftaran terkirim, OTP dikirim ke email, dan mengarahkan user ke halaman verifikasi. | OK |
| **OP-05** | Verify Signup Passwords Do Not Match | Negatif (-) | User berada di halaman signup | 1. Input data lengkap<br>2. Input password & konfirmasi password yang berbeda<br>3. Klik tombol "Daftar" | Nama: `Budi Santoso`<br>Email: `budi.santoso@gmail.com`<br>Pass: `budi123456`<br>Confirm: `budi654321` | Tampil snackbar Error dengan pesan: "Password dan konfirmasi password tidak cocok" | OK |
| **OP-06** | Verify Signup Empty Fields | Negatif (-) | User berada di halaman signup | 1. Kosongkan satu atau seluruh field<br>2. Klik tombol "Daftar" | Nama: `Budi Santoso`<br>Email: `budi.santoso@gmail.com`<br>Pass: ``<br>Confirm: `` | Tampil snackbar Error dengan pesan: "Semua kolom harus diisi" | OK |
| **OP-07** | Verify OTP Verification Success | Positif (+) | User berada di halaman verifikasi OTP setelah signup | 1. Input kode OTP valid<br>2. Klik tombol "Verifikasi" | Email: `budi.santoso@gmail.com`<br>OTP: `654321` | Verifikasi berhasil, dan sistem mengarahkan user untuk login. | OK |
| **OP-08** | Verify OTP Incorrect/Expired | Negatif (-) | User berada di halaman verifikasi OTP | 1. Input kode OTP salah / kedaluwarsa<br>2. Klik tombol "Verifikasi" | Email: `budi.santoso@gmail.com`<br>OTP: `999999` | Tampil snackbar Gagal dengan pesan: "Kode OTP salah atau sudah kadaluarsa." | OK |
| **OP-09** | Verify KYC Step 1 Success | Positif (+) | User di halaman Daftar Anggota (Step 1) | 1. Input nomor telepon valid<br>2. Klik tombol "Lanjut" | No. Telepon: `08123456789` | Sistem menyimpan data kontak dan melangkah ke Step 2 (Upload Dokumen). | OK |
| **OP-10** | Verify KYC Step 1 Empty Contact | Negatif (-) | User di halaman Daftar Anggota (Step 1) | 1. Kosongkan nomor telepon / email<br>2. Klik tombol "Lanjut" | No. Telepon: `` | Tampil snackbar Error dengan pesan: "Nomor telepon harus diisi" | OK |
| **OP-11** | Verify KYC Step 2 Success (Upload & OCR) | Positif (+) | User di halaman Daftar Anggota (Step 2) | 1. Upload foto KTP<br>2. Upload Kartu Anggota<br>3. Upload Pas Foto<br>4. Upload Tanda Tangan<br>5. Klik tombol "Lanjut" | File KTP, Kartu Anggota, Pas Foto, Tanda Tangan (Format JPEG/PNG) | Loading dialog muncul untuk OCR, data berhasil diekstraksi ke Step 3 secara otomatis. | OK |
| **OP-12** | Verify KYC Step 2 Missing Documents | Negatif (-) | User di halaman Daftar Anggota (Step 2) | 1. Upload KTP tapi kosongkan dokumen lain<br>2. Klik tombol "Lanjut" | Dokumen: Hanya KTP ter-upload | Tampil snackbar Peringatan: "Harap upload Kartu Anggota terlebih dahulu" (sesuai dokumen yang kosong). | OK |
| **OP-13** | Verify KYC Step 3 Edit OCR Data | Positif (+) | User di halaman Daftar Anggota (Step 3) setelah proses OCR | 1. Periksa/edit data hasil OCR<br>2. Klik tombol "Lanjut" | Nama: `BUDI SANTOSO`<br>NIK: `3275012345678901`<br>TTL: `Jakarta, 01-01-1990` | Data divalidasi dan sistem melanjutkan ke Step 4 (Pilih Simpanan). | OK |
| **OP-14** | Verify KYC Step 3 Data Empty | Negatif (-) | User di halaman Daftar Anggota (Step 3) | 1. Hapus isi nama / NIK<br>2. Klik tombol "Lanjut" | Nama: ``, NIK: `` | Tampil snackbar Error dengan pesan: "Data OCR tidak boleh kosong" | OK |
| **OP-15** | Verify KYC Step 4 Setup Savings | Positif (+) | User di halaman Daftar Anggota (Step 4) | 1. Pilih jenis simpanan awal<br>2. Input nominal simpanan<br>3. Klik tombol "Lanjut" | Tipe: `Simpanan Sukarela`<br>Nominal: `100000` | Data simpanan disimpan dan sistem lanjut ke Step 5 (Persetujuan). | OK |
| **OP-16** | Verify KYC Step 4 Nominal Empty | Negatif (-) | User di halaman Daftar Anggota (Step 4) | 1. Kosongkan nominal simpanan<br>2. Klik tombol "Lanjut" | Nominal: `` | Tampil snackbar Error dengan pesan: "Nominal simpanan harus diisi" | OK |
| **OP-17** | Verify KYC Step 5 Agreement & Submit | Positif (+) | User di halaman Daftar Anggota (Step 5) | 1. Centang checkbox persetujuan syarat & ketentuan<br>2. Klik tombol "Ajukan Pendaftaran" | Persetujuan: `Checked` | Loading dialog tampil, pendaftaran dikirim ke backend, muncul dialog sukses "Pendaftaran Berhasil!" dan diarahkan ke Dashboard Status. | OK |
| **OP-18** | Verify KYC Step 5 Agreement Unchecked | Negatif (-) | User di halaman Daftar Anggota (Step 5) | 1. Biarkan checkbox persetujuan tidak tercentang<br>2. Klik tombol "Ajukan Pendaftaran" | Persetujuan: `Unchecked` | Tampil snackbar Error dengan pesan: "Anda harus menyetujui syarat dan ketentuan sebelum mengajukan pendaftaran." | OK |
| **OP-19** | Verify Buka Simpanan Success | Positif (+) | User berada di form buka simpanan | 1. Pilih Jenis Simpanan<br>2. Input nominal simpanan<br>3. Pilih bank sumber dana<br>4. Klik tombol "Buka Simpanan" | Jenis: `Simpanan Berjangka`<br>Nominal: `500000`<br>Bank: `Bank Mandiri` | Tampil snackbar Sukses "Permohonan buka simpanan sedang diproses" dan halaman kembali ke dashboard. | OK |
| **OP-20** | Verify Buka Simpanan Missing Fields | Negatif (-) | User berada di form buka simpanan | 1. Biarkan nominal kosong atau Bank pada nilai default<br>2. Klik tombol "Buka Simpanan" | Nominal: ``<br>Bank: `Pilih Bank Sumber` | Tampil snackbar Error dengan pesan: "Mohon lengkapi semua data" | OK |
| **OP-21** | Verify Penarikan Dana Success | Positif (+) | User berada di form penarikan dana | 1. Pilih jenis simpanan asal<br>2. Input nominal penarikan<br>3. Input alasan penarikan (opsional)<br>4. Klik tombol "Ajukan Penarikan" | Asal: `Simpanan Sukarela`<br>Nominal: `250000`<br>Alasan: `Keperluan mendesak` | Tampil snackbar Sukses "Pengajuan penarikan sedang diproses" dan halaman kembali ke dashboard. | OK |
| **OP-22** | Verify Penarikan Dana Nominal Empty | Negatif (-) | User berada di form penarikan dana | 1. Kosongkan nominal penarikan<br>2. Klik tombol "Ajukan Penarikan" | Nominal: `` | Tampil snackbar Error dengan pesan: "Mohon masukkan nominal penarikan" | OK |
| **OP-23** | Verify Change Password Success | Positif (+) | User berada di halaman Ubah Kata Sandi | 1. Input kata sandi lama<br>2. Input kata sandi baru<br>3. Input konfirmasi kata sandi baru<br>4. Klik tombol "Simpan" | Sandi Lama: `password`<br>Sandi Baru: `newpassword123`<br>Konfirmasi: `newpassword123` | Dialog loading muncul, sandi berhasil diubah, halaman kembali, dan muncul snackbar sukses "Kata sandi berhasil diubah". | OK |
| **OP-24** | Verify Change Password Empty Fields | Negatif (-) | User berada di halaman Ubah Kata Sandi | 1. Kosongkan salah satu atau seluruh kolom sandi<br>2. Klik tombol "Simpan" | Sandi Baru: `newpassword123`<br>Konfirmasi: `` | Tampil snackbar Error dengan pesan: "Semua kolom harus diisi" | OK |
| **OP-25** | Verify Change Password Confirm Mismatch | Negatif (-) | User berada di halaman Ubah Kata Sandi | 1. Input kata sandi lama<br>2. Input kata sandi baru dan konfirmasi yang berbeda<br>3. Klik tombol "Simpan" | Sandi Lama: `password`<br>Sandi Baru: `newpassword123`<br>Konfirmasi: `differentpass` | Tampil snackbar Error dengan pesan: "Kata sandi baru tidak cocok dengan konfirmasi" | OK |

---

## Glosarium Kolom

1. **Jenis Case (+/- / Edge):**
   * **Positif (+):** Menguji alur normal (jalur sukses).
   * **Negatif (-):** Sengaja memasukkan data salah/tidak lengkap untuk melihat penanganan error sistem.
   * **Edge:** Menguji nilai batas (misal: batas upload ukuran berkas, panjang teks input).
2. **Precondition (Prasyarat):** Kondisi yang harus dipenuhi sebelum langkah pengujian dapat dilakukan (misal: "User sudah login").
3. **Langkah Eksekusi:** Urutan tindakan yang dilakukan oleh tester.
4. **Data Uji (Test Data):** Nilai spesifik yang dimasukkan pada input form saat pengujian.
5. **Expected Result:** Respon sistem yang diharapkan sesuai dengan spesifikasi/kode aplikasi.
6. **Status (OK/NG):** Status kelayakan hasil uji (`OK` = Sesuai ekspektasi, `NG` = Terjadi bug/tidak sesuai ekspektasi).

---

## Tips Pengujian (Praktikum Kelas)

* **Proporsi Kasus Uji:** Pastikan memiliki skenario pengujian negatif (Negative Cases) minimal 30% dari keseluruhan skenario pengujian untuk melatih penanganan error aplikasi.
* **Penanganan Status NG (No Good):** Jika pengujian menghasilkan status `NG`, tester wajib mendokumentasikan bug tersebut dalam Bug Report lengkap dengan rekaman/screenshot layar.
* **Sinkronisasi Dokumen:** Sesuaikan skenario pengujian dengan Product Requirement Document (PRD) agar seluruh fitur inti aplikasi koperasi teruji secara merata.
