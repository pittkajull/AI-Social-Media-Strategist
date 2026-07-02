# Nara — AI Social Media Strategist

Nara adalah sistem AI otomatis yang berperan sebagai **Content Strategist** untuk platform **Threads**. Berbeda dari bot posting biasa yang langsung generate-dan-publish, Nara menjalankan proses berpikir bertahap sebelum konten dipublikasikan — persis seperti alur kerja tim konten sungguhan, tapi dikerjakan sepenuhnya oleh AI dan berjalan otomatis setiap hari.

---

## Latar Belakang

Awalnya project ini cuma ditujukan untuk membuat bot yang bisa auto-post ke Threads. Namun dikembangkan lebih jauh menjadi sistem yang **tidak sekadar generate lalu publish**, melainkan mensimulasikan proses kerja tim konten sungguhan — riset topic, penulisan, dan revisi — sebelum konten benar-benar tayang.

## Yang Membedakan Nara

Kebanyakan bot AI untuk media sosial bekerja dengan pola sederhana: *prompt → generate → publish*. Nara berbeda — ia menjalankan **1 AI yang sama, tapi berperan sebagai 3 posisi berbeda secara berurutan**:

1. **Strategist** — memilih topic dan menentukan sudut pandang (angle) yang paling relevan untuk dibahas hari ini, berdasarkan basis pengetahuan yang sudah ditentukan
2. **Writer** — menulis draft konten berdasarkan strategi yang sudah ditetapkan
3. **Editor** — membaca ulang dan merevisi draft tersebut agar sesuai gaya bicara brand, sebelum akhirnya dipublikasikan

Proses bertahap ini yang membuat hasil akhirnya lebih matang dan konsisten, dibanding pendekatan generate-sekali-jadi.

---

## Persona "Nara"

**Belief:**
- Human before algorithm
- Strategy before content
- Trust before sales
- Curiosity before conclusion

**Tone (komposisi gaya bicara):**
- 40% Strategist — tajam dan terstruktur
- 30% Educator — menjelaskan tanpa menggurui
- 20% Observer — mengamati fenomena sehari-hari
- 10% Friend — hangat dan personal

**Larangan:** clickbait, hard selling, auto viral framing, kata "rahasia"/"wajib", nada menggurui

**Target audience:** Business Owner, UMKM, Startup, Freelancer, Content Creator

**Pendekatan:** soft-selling melalui insight — membangun awareness dan kepercayaan, bukan jualan langsung

---

## Alur Kerja

### 1. Generate & Publish Konten (harian, otomatis)

```
Trigger (terjadwal harian)
  ↓
Ambil Knowledge Base + Ideas Backlog dari database
  ↓
Strategist  → AI memilih topic & menentukan angle/objective
  ↓
Writer      → AI menulis draft konten
  ↓
Editor      → AI merevisi & mempertajam draft
  ↓
Publish otomatis ke Threads (via Buffer)
  ↓
Simpan histori ke database
```

### 2. Tracking Performa (harian, otomatis)

```
Trigger (terjadwal harian)
  ↓
Ambil daftar konten yang sudah pernah dipublikasikan
  ↓
Cek performa tiap post (likes, replies, reposts, impressions)
  ↓
Simpan data performa ke database
```

### 3. Backup Basis Pengetahuan (mingguan, otomatis)

```
Trigger (terjadwal mingguan)
  ↓
Ambil seluruh basis pengetahuan dari database
  ↓
Commit & backup ke GitHub sebagai riwayat versi
```

---

## Arsitektur & Stack

| Komponen | Fungsi |
|---|---|
| **n8n** | Menjalankan dan menghubungkan seluruh alur kerja otomatis |
| **Supabase** | Database — menyimpan basis pengetahuan, backlog ide, histori konten, dan data performa |
| **Gemini API** | Model AI yang menjalankan peran Strategist, Writer, dan Editor |
| **Buffer** | Menerbitkan konten ke Threads |
| **GitHub** | Menyimpan riwayat versi basis pengetahuan |

---

## Struktur Database

**`knowledge`** — basis pengetahuan referensi (psikologi, copywriting, storytelling, strategi konten, dll) yang menjadi acuan AI saat menyusun strategi dan menulis

**`ideas`** — daftar topic mentah yang menjadi kandidat untuk dibahas

**`history`** — arsip seluruh konten yang sudah digenerate dan dipublikasikan, lengkap dengan topic, angle, isi konten, dan status publikasi

**`metrics`** — data performa tiap konten yang sudah tayang (likes, replies, reposts, impressions)

---

## Status Project

Sistem sudah berjalan **penuh secara otomatis** — bukan lagi tahap eksperimen. Seluruh proses, dari penentuan topic hingga publikasi dan pencatatan performa, berjalan sendiri setiap hari tanpa perlu intervensi manual.

### Sudah berjalan
- ✅ Generate konten otomatis harian (Strategist → Writer → Editor)
- ✅ Auto-publish ke Threads
- ✅ Tracking performa konten harian
- ✅ Backup basis pengetahuan mingguan ke GitHub
- ✅ Dashboard pemantauan performa

### Rencana pengembangan selanjutnya
- Backup otomatis untuk prompt AI (saat ini baru basis pengetahuan yang ter-backup otomatis)
- Dashboard versi publik yang bisa diakses dari perangkat manapun

---

## Nilai Bisnis

- **Efisiensi** — proses yang biasanya membutuhkan tim dan waktu berjam-jam kini berjalan otomatis dalam hitungan menit
- **Konsistensi** — kualitas dan gaya bicara brand terjaga setiap hari, tidak bergantung pada ketersediaan orang
- **Skalabilitas** — pendekatan yang sama dapat diterapkan untuk brand atau klien lain dengan mengganti basis pengetahuannya