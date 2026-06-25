# Panduan Integrasi & Perubahan Backend Koperasi (OCR & E-KYC)

Dokumen ini memuat seluruh daftar perubahan di sisi Backend (Python Flask) dari awal hingga fitur OCR KTP, pemrosesan citra (Computer Vision), dan deteksi duplikasi selesai diimplementasikan. Anda dapat membagikan panduan ini kepada tim backend Anda.

---

## 1. Konfigurasi Endpoint Server (`config.py` & `main.py`)
Pastikan server Flask terikat pada host `0.0.0.0` agar dapat diakses dari jaringan lokal oleh perangkat mobile.
*   **IP Server Baru:** `http://192.168.56.46:5000` (atau sesuaikan dengan IP LAN saat ini).
*   **Binding Port:** `5000` pada host `0.0.0.0`.

---

## 2. Struktur Database Model (`models/user_model.py`)
Pastikan kolom-kolom berikut tersedia di database SQL:

### Tabel `members` (Anggota Aktif)
Memiliki kolom identitas unik untuk pencocokan duplikasi:
*   `nik` (Varchar 20, Unique): Menyimpan NIK terverifikasi untuk perlindungan KYC.
*   `full_name` (Varchar 100): Nama lengkap anggota.

### Tabel `member_registration` (Pendaftaran Baru)
Menyimpan data hasil ekstraksi OCR dan status validasi:
```python
class MemberRegistration(SoftDeleteMixin, db.Model):
    __tablename__ = "member_registration"
    id = db.Column(db.Integer, primary_key=True)
    mobile_user_id = db.Column(db.Integer, db.ForeignKey('mobile_users.id'))
    status = db.Column(db.String(20), default="pending") # pending, approved, rejected
    
    # OCR Data Hasil Pemindaian KTP
    ocr_name = db.Column(db.String(100))
    ocr_nik = db.Column(db.String(20))
    ocr_address = db.Column(db.Text)
    ocr_gender = db.Column(db.String(20))
    ocr_birth_date = db.Column(db.String(50))
    ocr_confidence = db.Column(db.Float)
```

---

## 3. Pemrosesan Citra & OCR KTP (`routes/api_routes.py`)
Backend membutuhkan pustaka **OpenCV (cv2)** dan **EasyOCR** untuk membaca teks pada KTP dengan akurasi tinggi.

### A. Fungsi Preprocessing Citra KTP
Fungsi ini digunakan untuk membersihkan derau (noise), meningkatkan kontras, dan memperbesar gambar sebelum dibaca oleh OCR:
```python
import cv2
import easyocr
import re
import os

# Inisialisasi OCR Reader (Bilingual/Indonesian)
reader = None
def get_ocr_reader():
    global reader
    if reader is None:
        reader = easyocr.Reader(['id'], gpu=False)
    return reader

def preprocess_ktp(img_path):
    img = cv2.imread(img_path)
    # Perbesar gambar 2x lipat agar resolusi karakter lebih tinggi
    img_resized = cv2.resize(img, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
    # Ubah ke Grayscale
    gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    # Denoiser untuk menghilangkan bintik hitam
    denoised = cv2.fastNlMeansDenoising(gray, h=10)
    # CLAHE untuk meratakan kontras cahaya yang silau/gelap
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(denoised)
    # Thresholding binerisasi Otsu
    _, thresh = cv2.threshold(enhanced, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return thresh, img_resized
```

### B. Parser Teks Hasil OCR (Ekstraksi NIK, Nama, dll)
Fungsi ini memfilter hasil pembacaan mentah menggunakan ekspresi reguler (Regex) untuk mendapatkan data terstruktur KTP:
```python
def parse_ktp_to_flask_format(results):
    text_conf = [(text, prob) for (_, text, prob) in results]
    raw_text  = ' '.join([t for t, _ in text_conf])
    raw_upper = raw_text.upper()

    ktp_data  = {}

    # Koreksi kesalahan karakter OCR yang umum pada NIK angka
    cleaned_for_nik = raw_text.replace(" ", "").replace("O", "0").replace("l", "1").replace("S", "5").replace("I", "1").replace("B", "8")
    nik = re.search(r'(\d{16})', cleaned_for_nik)
    ktp_data['nik'] = nik.group(1) if nik else ""

    # Ekstraksi Nama
    nama = ""
    m1 = re.search(r'(?:^|\s)Nama\s*[:\-]?\s*([A-Za-z][A-Za-z\s\.\']{2,})', raw_text, re.IGNORECASE)
    if m1:
        nama = m1.group(1).strip()
    else:
        for i, (text, prob) in enumerate(text_conf):
            if re.match(r'^Nama$', text.strip(), re.IGNORECASE):
                for j in range(i+1, min(i+4, len(text_conf))):
                    candidate = text_conf[j][0].strip()
                    if re.match(r'^[A-Za-z][A-Za-z\s\.\']{2,}$', candidate):
                        nama = candidate
                        break
                break
    ktp_data['nama'] = nama

    # Tempat Tanggal Lahir (TTL)
    tempat = re.search(r'(?:Tempat|Temp[a-z]+)\s*[/ \s]*(?:Tgl\.?|Tanggal)?\s*(?:Lahir)?\s*[:\-]?\s*([A-Z][A-Z\s,]+?)(?:\d{2}-|\s{2,}|$)', raw_text, re.IGNORECASE)
    tempat_str = tempat.group(1).strip().rstrip(',') if tempat else ""
    tgl = re.search(r'(\d{2}-\d{2}-\d{4})', raw_text)
    tgl_str = tgl.group(1) if tgl else ""
    ktp_data['ttl'] = f"{tempat_str}, {tgl_str}" if tempat_str and tgl_str else (tempat_str or tgl_str)

    # Jenis Kelamin
    if 'PEREMPUAN' in raw_upper:
        ktp_data['jenis_kelamin'] = 'Perempuan'
    else:
        ktp_data['jenis_kelamin'] = 'Laki-laki'

    # Agama
    agama_list = ['ISLAM', 'KRISTEN', 'KATOLIK', 'HINDU', 'BUDDHA', 'KONGHUCU']
    found_agama = next((a for a in agama_list if a in raw_upper), None)
    ktp_data['agama'] = found_agama.title() if found_agama else ""

    # Alamat Lengkap (menggabungkan RT/RW, Kelurahan, Kecamatan)
    alamat = re.search(r'(?:Alamat|Alama|A1amat)\s*[:\-]?\s*([A-Za-z0-9][^\n]+?)(?:RT|RW|Kel|Desa|Kec|$)', raw_text, re.IGNORECASE)
    alamat_str = alamat.group(1).strip() if alamat else ""
    rtrw = re.search(r'(\d{3})[/ \\](\d{3})', raw_text)
    rtrw_str = f"RT/RW {rtrw.group(1)}/{rtrw.group(2)}" if rtrw else ""
    
    bagian_alamat = [alamat_str] if alamat_str else []
    if rtrw_str: bagian_alamat.append(rtrw_str)
    ktp_data['alamat'] = ', '.join(bagian_alamat)

    return ktp_data
```

---

## 4. Endpoint Deteksi & Validasi Duplikasi KTP (`POST /api/ocr`)
Ini adalah endpoint utama yang dipanggil oleh Flutter saat pengguna memproses foto KTP. Endpoint ini bertugas:
1. Memproses gambar KTP menggunakan fungsi preprocessing & EasyOCR.
2. Mengekstrak NIK & Nama.
3. Mencocokkan data NIK dan Nama di database untuk mendeteksi duplikasi.
4. Menghitung rata-rata score akurasi OCR.
5. Mencetak laporan verifikasi terperinci di konsol backend.

```python
@api_bp.route('/ocr', methods=['POST'])
def process_ocr():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    # Simpan file sementara di folder uploads
    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    try:
        # Pemrosesan gambar & EasyOCR
        thresh, _ = preprocess_ktp(file_path)
        ocr_reader = get_ocr_reader()
        results = ocr_reader.readtext(thresh)
        parsed_data = parse_ktp_to_flask_format(results)
        
        # Hitung rata-rata confidence score OCR
        confidences = [prob for (_, _, prob) in results if prob > 0.0]
        mean_confidence = sum(confidences) / len(confidences) if confidences else 0.0

        # PEMERIKSAAN DUPLIKASI KTP / DATA ANGGOTA
        nik = parsed_data.get('nik', '').strip()
        nama = parsed_data.get('nama', '').strip()
        is_duplicate = False
        duplicate_reason = ""

        if nik:
            # 1. Cek di tabel members (Anggota aktif)
            existing_member = Member.query.filter_by(nik=nik).first()
            if existing_member:
                is_duplicate = True
                duplicate_reason = f"NIK ({nik}) sudah terdaftar sebagai anggota aktif dengan ID {existing_member.member_no}."
            
            # 2. Cek di tabel member_registration (Pendaftaran pending yang belum diapprove)
            if not is_duplicate:
                existing_reg = MemberRegistration.query.filter_by(ocr_nik=nik).filter(
                    MemberRegistration.status.in_(['pending', 'approved'])
                ).first()
                if existing_reg:
                    is_duplicate = True
                    duplicate_reason = f"NIK ({nik}) sudah digunakan dalam pendaftaran pending/aktif."

        elif nama:
            # Fallback check nama apabila NIK tidak terdeteksi
            existing_member = Member.query.filter_by(full_name=nama).first()
            if existing_member:
                is_duplicate = True
                duplicate_reason = f"Nama ({nama}) terdeteksi duplikat dengan anggota terdaftar."

        # Sisipkan metadata keamanan ke respon JSON untuk Flutter
        parsed_data['is_duplicate'] = is_duplicate
        parsed_data['duplicate_reason'] = duplicate_reason
        parsed_data['ocr_confidence'] = mean_confidence

        # TAMPILKAN DI CONSOLE BACKEND (LOGS)
        print("\n" + "="*50)
        print("                 LAPORAN SCAN OCR KTP                 ")
        print("="*50)
        print(f"File Name      : {file.filename}")
        print(f"Hasil NIK      : {nik if nik else 'TIDAK TERDETEKSI'}")
        print(f"Hasil Nama     : {nama if nama else 'TIDAK TERDETEKSI'}")
        print(f"Score OCR (Conf): {mean_confidence * 100:.2f}%")
        print(f"Status Duplikat: {'YA (DUPLIKAT)' if is_duplicate else 'TIDAK (AMAN)'}")
        if is_duplicate:
            print(f"Alasan Duplikat: {duplicate_reason}")
        print("="*50 + "\n")

        return jsonify(parsed_data), 200
    except Exception as e:
        print(f"OCR Error: {str(e)}")
        return jsonify({'error': str(e)}), 500
```
