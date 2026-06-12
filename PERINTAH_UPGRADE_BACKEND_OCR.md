# PERINTAH UPGRADE BACKEND OCR KTP

## Masalah
OCR backend saat ini gagal membaca KTP yang sebenarnya jelas. 
Sudah diuji di Google Colab menggunakan kode yang sama dan BERHASIL.

## Penyebab Utama
1. EasyOCR hanya pakai bahasa `['id']`. Colab pakai `['en', 'id']` dan berhasil.
2. OCR membaca dari numpy array langsung. Colab membaca dari file JPEG yang disimpan dulu.

## Yang Harus Diubah

Ganti SELURUH isi fungsi `preprocess_ktp`, `parse_ktp_to_flask_format`, `get_ocr_reader`, 
dan endpoint `process_ocr` di file `routes/api_routes.py` dengan kode di bawah ini.

---

### KODE LENGKAP (Copy-Paste ke `routes/api_routes.py`)

Ganti fungsi-fungsi OCR lama dengan ini:

```python
import cv2
import re
import os
from datetime import date

# --- OCR Reader (WAJIB pakai 'en' DAN 'id') ---
reader = None
def get_ocr_reader():
    global reader
    if reader is None:
        import easyocr
        reader = easyocr.Reader(['en', 'id'], gpu=False)
    return reader


# --- Preprocessing Gambar KTP ---
def preprocess_ktp(img_path):
    img = cv2.imread(img_path)
    if img is None:
        raise ValueError("Gambar tidak terbaca.")
    img_resized = cv2.resize(img, None, fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
    gray = cv2.cvtColor(img_resized, cv2.COLOR_BGR2GRAY)
    denoised = cv2.fastNlMeansDenoising(gray, h=10)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    enhanced = clahe.apply(denoised)
    _, thresh = cv2.threshold(enhanced, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return thresh, img_resized


# --- Parser KTP Super Akurat ---
def parse_ktp_to_flask_format(results):
    text_conf = [(text, prob) for (_, text, prob) in results]
    raw_text  = ' '.join([t for t, _ in text_conf])
    raw_upper = raw_text.upper()

    ktp_data = {}

    # 1. PERBAIKAN NIK (Sering salah baca angka mirip, misal 2 jadi 3)
    # Ambil 16 digit angka yang berdekatan
    nik_candidate = ""
    # Cari semua blok angka
    for text, _ in text_conf:
        # Bersihkan dari spasi/karakter aneh
        clean_digits = re.sub(r'\D', '', text)
        if len(clean_digits) == 16:
            nik_candidate = clean_digits
            break
            
    if not nik_candidate:
        # Fallback: cari di raw text gabungan
        nik_match = re.search(r'\b(\d{16})\b', re.sub(r'[\s\.\:\-]', '', raw_upper))
        if nik_match:
            nik_candidate = nik_match.group(1)

    # AUTO-KOREKSI NIK BERDASARKAN PROVINSI
    # Jawa Tengah selalu mulai dengan 33. Jika terbaca 23, koreksi!
    if "JAWA TENGAH" in raw_upper and nik_candidate.startswith("23"):
        nik_candidate = "33" + nik_candidate[2:]
    # Tambahkan koreksi lain jika perlu (Jawa Barat=32, Jatim=35, DKI=31)
    
    ktp_data['nik'] = nik_candidate

    # 2. PERBAIKAN NAMA (Sering terlewat jika formatnya 'Narna', 'Nema', dsb)
    nama = ""
    # Coba cari baris yang letaknya persis di bawah/setelah NIK
    nik_index = -1
    for i, (text, _) in enumerate(text_conf):
        if nik_candidate and nik_candidate in re.sub(r'\D', '', text):
            nik_index = i
            break
            
    if nik_index != -1 and nik_index + 1 < len(text_conf):
        # Biasanya nama ada di baris tepat setelah NIK
        # Ambil maksimal 3 baris setelah NIK untuk mencari string huruf kapital
        for j in range(nik_index + 1, min(nik_index + 4, len(text_conf))):
            kandidat_nama = text_conf[j][0].strip()
            # Nama biasanya huruf kapital semua, tidak ada angka, minimal 3 huruf
            if re.match(r'^[A-Z][A-Z\s\.\']{2,}$', kandidat_nama) and "GOL" not in kandidat_nama and "DARAH" not in kandidat_nama:
                nama = kandidat_nama
                break

    # Jika masih kosong, pakai regex standard
    if not nama:
        m1 = re.search(r'(?:NAMA|Narna|Nema)\s*[:\-]?\s*([A-Z][A-Z\s\.\']{2,})', raw_text, re.IGNORECASE)
        if m1:
            nama = m1.group(1).strip()

    ktp_data['nama'] = nama.replace(':', '').replace('-', '').strip()

    # --- TEMPAT & TANGGAL LAHIR ---
    tempat = re.search(r'(?:Tempat|Temp[a-z]+)\s*[/\s]*(?:Tgl\.?|Tanggal)?\s*(?:Lahir)?\s*[:\-]?\s*([A-Z][A-Z\s,]+?)(?:\d{2}-|\s{2,}|$)', raw_text, re.IGNORECASE)
    tempat_str = tempat.group(1).strip().rstrip(',') if tempat else ""

    tgl = re.search(r'(\d{2}-\d{2}-\d{4})', raw_text)
    tgl_str = tgl.group(1) if tgl else ""

    if tempat_str and tgl_str:
        ktp_data['ttl'] = f"{tempat_str}, {tgl_str}"
    elif tempat_str:
        ktp_data['ttl'] = tempat_str
    elif tgl_str:
        ktp_data['ttl'] = tgl_str
    else:
        ktp_data['ttl'] = ""

    # --- JENIS KELAMIN ---
    if 'PEREMPUAN' in raw_upper:
        ktp_data['jenis_kelamin'] = 'Perempuan'
    elif 'LAKI' in raw_upper:
        ktp_data['jenis_kelamin'] = 'Laki-laki'
    else:
        ktp_data['jenis_kelamin'] = ''

    # --- AGAMA ---
    agama_list = ['ISLAM', 'KRISTEN', 'KATOLIK', 'HINDU', 'BUDDHA', 'KONGHUCU']
    found_agama = next((a for a in agama_list if a in raw_upper), None)
    ktp_data['agama'] = found_agama.title() if found_agama else ""

    # --- ALAMAT LENGKAP ---
    alamat = re.search(r'(?:Alamat|Alama|A1amat)\s*[:\-]?\s*([A-Za-z0-9][^\n]+?)(?:RT|RW|Kel|Desa|Kec|$)', raw_text, re.IGNORECASE)
    alamat_str = alamat.group(1).strip() if alamat else ""

    rtrw = re.search(r'(\d{3})[/ \\](\d{3})', raw_text)
    rtrw_str = f"{rtrw.group(1)}/{rtrw.group(2)}" if rtrw else ""

    keldesa = re.search(r'(?:Kel|Desa)\s*[/ \\]?\s*(?:Desa|Kel)?\s*[:\-]?\s*([A-Z][A-Z\s]+?)(?:\s{2,}|Kec|$)', raw_text, re.IGNORECASE)
    kel_str = keldesa.group(1).strip() if keldesa else ""

    kec = re.search(r'Kecamatan\s*[:\-]?\s*([A-Z][A-Z\s]+?)(?:\s{2,}|Agama|$)', raw_text, re.IGNORECASE)
    kec_str = kec.group(1).strip() if kec else ""

    bagian_alamat = []
    if alamat_str: bagian_alamat.append(alamat_str)
    if rtrw_str: bagian_alamat.append('RT/RW ' + rtrw_str)
    if kel_str: bagian_alamat.append('Kel. ' + kel_str)
    if kec_str: bagian_alamat.append('Kec. ' + kec_str)
    ktp_data['alamat'] = ', '.join(bagian_alamat)

    return ktp_data


# ============================================================
# ENDPOINT /api/ocr - Ganti seluruh endpoint lama
# ============================================================
@api_bp.route('/ocr', methods=['POST'])
def process_ocr():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400

    file_path = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(file_path)

    try:
        # STEP 1: Preprocessing
        img_thresh, img_resized = preprocess_ktp(file_path)

        # STEP 2: Simpan hasil preprocessing ke file JPEG dulu
        # >>> INI KUNCI KEBERHASILAN - SAMA SEPERTI COLAB <<<
        preprocessed_path = os.path.join(UPLOAD_FOLDER, 'ktp_preprocessed.jpg')
        cv2.imwrite(preprocessed_path, img_thresh)

        # STEP 3: OCR membaca dari FILE (bukan numpy array langsung)
        ocr_reader = get_ocr_reader()
        results = ocr_reader.readtext(preprocessed_path)

        # STEP 4: Parse hasil OCR
        parsed_data = parse_ktp_to_flask_format(results)

        # STEP 5: Hitung confidence
        confidences = [prob for (_, _, prob) in results if prob > 0.0]
        mean_confidence = sum(confidences) / len(confidences) if confidences else 0.0

        # STEP 6: Cek Duplikasi di database
        nik = parsed_data.get('nik', '').strip()
        nama = parsed_data.get('nama', '').strip()
        is_duplicate = False
        duplicate_reason = ""

        if nik:
            existing_member = Member.query.filter_by(nik=nik).first()
            if existing_member:
                is_duplicate = True
                duplicate_reason = f"NIK ({nik}) sudah terdaftar sebagai anggota aktif dengan ID {existing_member.member_no}."

            if not is_duplicate:
                existing_reg = MemberRegistration.query.filter_by(ocr_nik=nik).filter(
                    MemberRegistration.status.in_(['pending', 'approved'])
                ).first()
                if existing_reg:
                    is_duplicate = True
                    duplicate_reason = f"NIK ({nik}) sudah digunakan dalam pendaftaran pending/aktif."

        elif nama:
            existing_member = Member.query.filter_by(full_name=nama).first()
            if existing_member:
                is_duplicate = True
                duplicate_reason = f"Nama ({nama}) terdeteksi duplikat dengan anggota terdaftar."

        # STEP 7: Response JSON
        parsed_data['is_duplicate'] = is_duplicate
        parsed_data['duplicate_reason'] = duplicate_reason
        parsed_data['ocr_confidence'] = mean_confidence

        # STEP 8: Log di console backend (tidak ditampilkan di mobile)
        print("\n" + "="*55)
        print("     LAPORAN SCAN OCR KTP")
        print("="*55)
        print(f"File       : {file.filename}")
        print(f"NIK        : {nik if nik else 'TIDAK TERDETEKSI'}")
        print(f"Nama       : {nama if nama else 'TIDAK TERDETEKSI'}")
        print(f"TTL        : {parsed_data.get('ttl')}")
        print(f"JK         : {parsed_data.get('jenis_kelamin')}")
        print(f"Agama      : {parsed_data.get('agama')}")
        print(f"Alamat     : {parsed_data.get('alamat')}")
        print(f"Confidence : {mean_confidence * 100:.2f}%")
        print(f"Duplikat   : {'YA' if is_duplicate else 'TIDAK (AMAN)'}")
        if is_duplicate:
            print(f"Alasan     : {duplicate_reason}")
        print("="*55 + "\n")

        return jsonify(parsed_data), 200
    except Exception as e:
        print(f"OCR Error: {str(e)}")
        return jsonify({'error': str(e)}), 500
```

---

## Checklist Sebelum Jalankan
- [ ] Library terinstall: `pip install easyocr opencv-python-headless`
- [ ] Folder `uploads/` ada di root project backend
- [ ] Restart Flask server setelah update kode
- [ ] Tes dengan foto KTP yang sama yang berhasil di Colab
