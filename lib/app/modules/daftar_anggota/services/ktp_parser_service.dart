import 'dart:core';

class KtpParserService {
  // Kata-kata yang PASTI BUKAN nama orang
  static const Set<String> _BUKAN_NAMA = {
    'NIK', 'NAMA', 'TEMPAT', 'TGL', 'LAHIR', 'TANGGAL',
    'JENIS', 'KELAMIN', 'GOL', 'DARAH', 'ALAMAT', 'RT', 'RW',
    'KEL', 'DESA', 'KECAMATAN', 'KEC', 'AGAMA', 'STATUS',
    'PERKAWINAN', 'PEKERJAAN', 'KEWARGANEGARAAN', 'BERLAKU',
    'HINGGA', 'SEUMUR', 'HIDUP', 'PROVINSI', 'KABUPATEN',
    'KOTA', 'REPUBLIK', 'INDONESIA', 'KARTU', 'TANDA',
    'PENDUDUK', 'WNI', 'WNA', 'LAKI', 'PEREMPUAN',
    'ISLAM', 'KRISTEN', 'KATOLIK', 'HINDU', 'BUDDHA', 'KONGHUCU',
    'PELAJAR', 'MAHASISWA', 'WIRASWASTA', 'KARYAWAN', 'SWASTA',
    'NEGERI', 'PNS', 'TNI', 'POLRI', 'BELUM', 'KAWIN',
    'MENIKAH', 'CERAI', 'GOL.', 'DARAH:',
  };

  // Cek apakah baris adalah label KTP (bukan data)
  static bool _adalahLabel(String line) {
    String bersih = line.trim().toUpperCase()
        .replaceAll(RegExp(r'[\:\-\.\/]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (bersih.isEmpty) return true;
    List<String> kata = bersih.split(' ').where((w) => w.length > 1).toList();
    if (kata.isEmpty) return true;
    int jumlahLabel = kata.where((k) => _BUKAN_NAMA.contains(k)).length;
    // Jika lebih dari 70% kata adalah label → ini baris label
    if (jumlahLabel / kata.length > 0.7) return true;
    // Jika baris hanya angka/simbol
    if (RegExp(r'^[\d\s\/\-\:\.]+$').hasMatch(bersih)) return true;
    return false;
  }

  static Map<String, dynamic> parse(String rawText) {
    Map<String, dynamic> result = {
      'nik': '', 'nama': '', 'ttl': '',
      'jenis_kelamin': '', 'agama': '', 'alamat': '',
    };

    List<String> lines = rawText.split('\n')
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toList();

    String flatText = lines.join(' ');

    // ================================================================
    // 1. NIK — Cari baris dengan 16 digit angka
    // ================================================================
    int nikIdx = -1;
    for (int i = 0; i < lines.length; i++) {
      String cl = lines[i]
          .replaceAll(' ', '')
          .replaceAll(RegExp(r'[IiLl]'), '1')
          .replaceAll(RegExp(r'[Oo]'), '0')
          .replaceAll(RegExp(r'[Ss]'), '5')
          .replaceAll(RegExp(r'[Bb]'), '8')
          .replaceAll(RegExp(r'[Zz]'), '2');
      var m = RegExp(r'\d{16}').firstMatch(cl);
      if (m != null) {
        // Verifikasi: NIK indonesia dimulai dari kode provinsi 11-99
        String cand = m.group(0)!;
        int prov = int.tryParse(cand.substring(0, 2)) ?? 0;
        if (prov >= 11 && prov <= 99) {
          result['nik'] = cand;
          nikIdx = i;
          break;
        }
      }
    }
    // Fallback: cari 16 digit di semua teks gabung
    if (result['nik'].isEmpty) {
      String allClean = flatText
          .replaceAll(' ', '')
          .replaceAll(RegExp(r'[IiLl]'), '1')
          .replaceAll(RegExp(r'[Oo]'), '0')
          .replaceAll(RegExp(r'[Ss]'), '5')
          .replaceAll(RegExp(r'[Bb]'), '8');
      for (var m in RegExp(r'\d{16}').allMatches(allClean)) {
        String cand = m.group(0)!;
        int prov = int.tryParse(cand.substring(0, 2)) ?? 0;
        if (prov >= 11 && prov <= 99) {
          result['nik'] = cand;
          break;
        }
      }
    }

    // ================================================================
    // 2. NAMA — Cari label "NAMA" lalu ambil isinya
    // ================================================================
    for (String line in lines) {
      // Cocokkan baris yang mengandung label "NAMA" diikuti isi
      var m = RegExp(r"^(?:NAMA|NAM)\s*[:\-\.]?\s*([A-Z][A-Z\s\.]{2,})$").firstMatch(line);
      if (m != null) {
        String kandidat = m.group(1)!.trim();
        if (!_adalahLabel(kandidat)) {
          result['nama'] = _formatNama(kandidat);
          break;
        }
      }
    }
    // Fallback: baris antara NIK dan baris pertama tanggal
    if (result['nama'].isEmpty && nikIdx != -1) {
      for (int i = nikIdx + 1; i < lines.length && i <= nikIdx + 3; i++) {
        String line = lines[i];
        if (RegExp(r'\d{2}[\-\/\.]\d{2}[\-\/\.]\d{4}').hasMatch(line)) break;
        if (_adalahLabel(line)) continue;
        String bersih = line.replaceAll(RegExp(r'^(?:NAMA|NAM)\s*[\:\-\.]?\s*'), '').trim();
        if (bersih.length >= 3 && RegExp(r'^[A-Z]').hasMatch(bersih)) {
          result['nama'] = _formatNama(bersih);
          break;
        }
      }
    }

    // ================================================================
    // 3. TANGGAL LAHIR — Ambil SEMUA tanggal, pilih yang paling tepat
    // sebagai tanggal lahir (bukan tanggal berlaku/cetak)
    // ================================================================
    List<Map<String, String>> semuaTanggal = [];
    for (var m in RegExp(r'(\d{2})[\-\/\.\s](\d{2})[\-\/\.\s](\d{4})').allMatches(flatText)) {
      int tgl   = int.tryParse(m.group(1)!) ?? 0;
      int bln   = int.tryParse(m.group(2)!) ?? 0;
      int tahun = int.tryParse(m.group(3)!) ?? 0;
      // Tanggal lahir: tahun 1920–2010, bulan 1-12, tanggal 1-31
      if (tahun >= 1920 && tahun <= 2010 && bln >= 1 && bln <= 12 && tgl >= 1 && tgl <= 31) {
        semuaTanggal.add({
          'tgl': m.group(1)!, 'bln': m.group(2)!, 'thn': m.group(3)!,
          'formatted': '${m.group(1)}-${m.group(2)}-${m.group(3)}'
        });
      }
    }
    
    // Cari konteks: tanggal lahir biasanya ada di baris yang juga berisi nama kota
    String tanggalLahir = '';
    String tempatLahir  = '';
    for (String line in lines) {
      if (RegExp(r'\d{2}[\-\/\.]\d{2}[\-\/\.]\d{4}').hasMatch(line)) {
        // Cek apakah baris ini berisi kata "LAHIR" atau "TEMPAT"
        bool adaLabelLahir = line.contains('LAHIR') || line.contains('TEMPAT') || line.contains('TGL');
        if (adaLabelLahir || semuaTanggal.isNotEmpty) {
          // Ambil tanggal dari baris ini
          var m = RegExp(r'(\d{2})[\-\/\.\s](\d{2})[\-\/\.\s](\d{4})').firstMatch(line);
          if (m != null) {
            int tahun = int.tryParse(m.group(3)!) ?? 0;
            // Ini tahun lahir (bukan tahun penerbitan dokumen)
            if (tahun >= 1920 && tahun <= 2010) {
              tanggalLahir = '${m.group(1)}-${m.group(2)}-${m.group(3)}';
              // Cari nama tempat/kota di baris yang sama
              String sisaBaris = line
                  .replaceAll(RegExp(r'^(?:TEMPAT|TEMP)[A-Z\s\/\.]*LAHIR[\s\:\-\.]*', caseSensitive: false), '')
                  .replaceAll(m.group(0)!, '')
                  .replaceAll(RegExp(r'[\:\-\.,]'), ' ')
                  .trim();
              // Ambil kata-kata yang murni huruf (nama kota)
              var kotaMatch = RegExp(r'^([A-Z]{3,}(?:\s+[A-Z]{2,})*)').firstMatch(sisaBaris.trim());
              if (kotaMatch != null && !_BUKAN_NAMA.contains(kotaMatch.group(1)!.trim())) {
                tempatLahir = kotaMatch.group(1)!.trim();
              }
              break;
            }
          }
        }
      }
    }
    // Jika masih tidak ketemu dari baris bertanda, ambil dari daftar tanggal valid
    if (tanggalLahir.isEmpty && semuaTanggal.isNotEmpty) {
      tanggalLahir = semuaTanggal.first['formatted']!;
    }
    
    if (tempatLahir.isNotEmpty && tanggalLahir.isNotEmpty) {
      result['ttl'] = '$tempatLahir, $tanggalLahir';
    } else if (tanggalLahir.isNotEmpty) {
      result['ttl'] = tanggalLahir;
    }

    // ================================================================
    // 4. JENIS KELAMIN
    // ================================================================
    if (flatText.contains('PEREMPUAN') || flatText.contains('PREMPUAN')) {
      result['jenis_kelamin'] = 'Perempuan';
    } else if (flatText.contains('LAKI-LAKI') || RegExp(r'\bLAKI\b').hasMatch(flatText)) {
      result['jenis_kelamin'] = 'Laki-laki';
    }

    // ================================================================
    // 5. AGAMA
    // ================================================================
    const agamaList = ['ISLAM', 'KRISTEN', 'KATOLIK', 'HINDU', 'BUDDHA', 'KONGHUCU'];
    const agamaLabel = ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'];
    for (int i = 0; i < agamaList.length; i++) {
      if (flatText.contains(agamaList[i])) {
        result['agama'] = agamaLabel[i];
        break;
      }
    }

    // ================================================================
    // 6. ALAMAT — Ekstrak baris setelah label ALAMAT sampai RT/RW
    // ================================================================
    StringBuffer alamatBuf = StringBuffer();
    bool tangkapAlamat = false;
    String rt = '', rw = '', kel = '', kec = '';
    
    for (String line in lines) {
      // Mulai menangkap setelah baris ALAMAT
      if (!tangkapAlamat && RegExp(r'^ALAMAT\b').hasMatch(line)) {
        String isi = line.replaceAll(RegExp(r'^ALAMAT\s*[\:\-\.]?\s*'), '').trim();
        if (isi.isNotEmpty) alamatBuf.write(isi);
        tangkapAlamat = true;
        continue;
      }
      if (tangkapAlamat) {
        if (RegExp(r'^(?:RT|RW|KEL|DESA|KEC|AGAMA|STATUS|PEKERJAAN)\b').hasMatch(line)) {
          tangkapAlamat = false;
        } else {
          if (alamatBuf.isNotEmpty) alamatBuf.write(' ');
          alamatBuf.write(line);
        }
      }
      // RT/RW
      var rtRwM = RegExp(r'^RT\s*[\/]?\s*RW\s*[\:\-\.]?\s*(\d{1,3})\s*[\/\\]\s*(\d{1,3})').firstMatch(line);
      if (rtRwM != null) {
        rt = rtRwM.group(1)!.padLeft(3, '0');
        rw = rtRwM.group(2)!.padLeft(3, '0');
      }
      // Kelurahan/Desa
      var kelM = RegExp(r'^(?:KEL|DESA)\b[A-Z\/\s]*[\:\-\.]?\s*([A-Z][A-Z\s]+)$').firstMatch(line);
      if (kelM != null) kel = kelM.group(1)!.trim();
      // Kecamatan
      var kecM = RegExp(r'^KECAMATAN\s*[\:\-\.]?\s*([A-Z][A-Z\s]+)$').firstMatch(line);
      if (kecM != null) kec = kecM.group(1)!.trim();
    }
    
    List<String> bagian = [];
    String alamatStr = alamatBuf.toString().trim();
    if (alamatStr.isNotEmpty) bagian.add(alamatStr);
    if (rt.isNotEmpty && rw.isNotEmpty) bagian.add('RT/RW $rt/$rw');
    if (kel.isNotEmpty) bagian.add('Kel. $kel');
    if (kec.isNotEmpty) bagian.add('Kec. $kec');
    result['alamat'] = bagian.join(', ');

    return result;
  }

  static String _formatNama(String raw) {
    // Hanya ubah karakter yang sangat aman untuk nama
    String clean = raw.toUpperCase()
        .replaceAll('0', 'O')
        .replaceAll('8', 'B')
        .replaceAll(RegExp(r"[^A-Z\s\.\']"), '')
        .trim();
    // Kapitalisasi per kata
    return clean.split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0] + w.substring(1).toLowerCase())
        .join(' ');
  }
}
