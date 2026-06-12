# Laporan Progres Integrasi KTP OCR

Berikut adalah rekapitulasi lengkap mengenai penambahan fitur OCR KTP pada aplikasi, baik di sisi Backend maupun Frontend.

---

### ⚙️ 1. Perubahan di Sisi Backend (Python / Flask)
Untuk fitur OCR, telah dilakukan penambahan dan modifikasi pada dua file utama:

**A. Membuat File Baru: `utils/ocr_helper.py`**
File ini bertugas murni sebagai "Mesin AI", berisi logika pemrosesan gambar KTP:
1. **`get_ocr_reader()`**: Menerapkan sistem *caching* (Singleton). Model bahasa dari `easyocr` (yang berat) hanya akan dimuat satu kali ke memori RAM server, sehingga *request* berikutnya akan jauh lebih cepat dan tidak membuat server *crash*.
2. **`preprocess_ktp()`**: Menggunakan library OpenCV (`cv2`) untuk menjernihkan foto KTP (mengubah ke *Grayscale*, menghilangkan *noise/blur*, memperbaiki kontras dengan CLAHE, dan teknik *Thresholding*).
3. **`parse_ktp()`**: Mengandung puluhan logika **Regex** (Pola teks) untuk memilah teks mentah hasil AI menjadi struktur data spesifik, seperti mencari format 16 digit untuk NIK, mencari teks setelah kata "Nama", hingga membaca format "RT/RW".
4. **`process_ktp_image()`**: Fungsi utama yang menggabungkan seluruh alur di atas dan dipanggil oleh *routes*.

**B. Modifikasi Endpoint: `routes/api_routes.py`**
1. **Import `process_ktp_image`**: Menghubungkan file *routes* dengan *ocr_helper*.
2. **Ubah Endpoint `POST /api/ocr`**: 
   - Menghapus data *dummy/mock* (sebelumnya selalu me-*return* "BUDI SANTOSO").
   - Menambahkan perintah untuk menerima gambar dari Flutter, memprosesnya melalui fungsi AI, dan mengubahnya menjadi format JSON murni (`nama`, `nik`, `ttl`, `alamat`, dll).
   - **Fitur Auto-Clean**: Menambahkan kode penghapus file otomatis (`os.remove`) setelah gambar selesai diproses agar *storage* server Anda tidak penuh.

---

### 📱 2. Yang Telah Diselesaikan di Sisi Frontend (Flutter / GetX)
Di *project* Flutter (`pattern_getx_cli`), tugas-tugas berikut telah diselesaikan:

**A. Instalasi Package**
Library untuk mengakses kamera dan API telah dipasang di `pubspec.yaml`:
- `image_picker`
- `http`

**B. Pengaturan Izin (Permissions) Kamera**
- Di `android/app/src/main/AndroidManifest.xml`, tag permission untuk `CAMERA` dan `READ_EXTERNAL_STORAGE` telah ditambahkan.
- Di `ios/Runner/Info.plist`, deskripsi penggunaan `NSCameraUsageDescription` telah dikonfigurasi.

**C. Logika di `daftar_anggota_controller.dart`**
Fungsi asinkron `processOCR()` telah diimplementasikan dengan fitur:
1. Menjalankan `ImagePicker().pickImage` untuk membuka kamera atau galeri.
2. Mengubah *state* untuk memunculkan *loading indicator* ketika AI sedang bekerja.
3. Mengemas foto tersebut menggunakan `http.MultipartRequest` dan menembaknya ke URL API Flask (`$baseUrl/api/ocr`).
4. Menerima data kembalian API berupa JSON.
5. **Autofill (Inti Fitur)**: Memasukkan *value* dari JSON secara otomatis ke dalam masing-masing *Text Form Controller* (seperti `nameController.text = data['nama'];`).

**D. Pemasangan UI di `daftar_anggota_view.dart`**
1. Membuat UI yang interaktif untuk mengambil foto KTP.
2. Menambahkan *Conditional Rendering* yang menampilkan `CircularProgressIndicator()` dengan deskripsi ramah pengguna saat *loading* AI sedang memproses gambar.
3. Form *review* (Step 3) yang menunjukkan hasil tangkapan AI secara instan dan dapat diverifikasi langsung oleh pengguna.
