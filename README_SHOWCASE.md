# Nara — AI Social Media Strategist

Automation showcase untuk strategi konten Threads: satu AI menjalankan tiga peran (Strategist, Writer, Editor) secara berurutan untuk menghasilkan konten yang matang dan konsisten.

![Status](https://img.shields.io/badge/status-production%20ready-1f7a8c?style=for-the-badge)
![Workflow](https://img.shields.io/badge/workflows-3%20core%20flows-2c7a7b?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Threads%20%2B%20Buffer-3b82f6?style=for-the-badge)

Repo ini merangkum satu sistem content strategist otomatis yang menjalankan proses berpikir bertahap sebelum konten dipublikasikan — persis seperti alur kerja tim konten sungguhan, tapi dikerjakan sepenuhnya oleh AI dan berjalan otomatis setiap hari.

Project ini dibuat untuk mendemokan bagaimana AI tidak sekadar generate-dan-publish, melainkan mensimulasikan proses kerja tim konten profesional:

1. **Strategist** memilih topic dan menentukan angle yang relevan
2. **Writer** menulis draft berdasarkan strategi yang sudah ditetapkan
3. **Editor** merevisi dan mempertajam sebelum dipublikasikan

Dengan kata lain, repo ini adalah gabungan dari multi-role AI automation, knowledge management, dan performance tracking yang bisa dipamerkan sebagai satu paket demo.

## Highlights

- **Multi-role AI execution** — satu AI, tiga peran berbeda, dijalankan secara berurutan
- **Knowledge-driven strategy** — keputusan konten didasarkan pada basis pengetahuan terstruktur
- **Full automation pipeline** — dari pemilihan topic hingga publikasi tanpa intervensi manual
- **Performance tracking** — data performa konten dikumpulkan dan disimpan otomatis
- **Weekly backup** — basis pengetahuan di-backup ke GitHub secara terjadwal
- **Persona consistency** — gaya bicara brand terjaga dengan prompt yang terstruktur

## How It Works

Secara sederhana, alurnya seperti ini:

```
Trigger Harian
    ↓
Strategist Phase
    ├─ Ambil knowledge base dari database
    ├─ Pilih topic dari ideas backlog
    └─ Tentukan angle dan objective
    ↓
Writer Phase
    ├─ Baca strategi dari Strategist
    └─ Tulis draft konten
    ↓
Editor Phase
    ├─ Review draft sesuai persona
    └─ Revisi dan pertajam konten
    ↓
Publish ke Threads (via Buffer)
    ↓
Simpan ke history + ambil post ID
    ↓
Tracking performa (terjadwal harian)
    ↓
Backup knowledge (terjadwal mingguan)
```

Bagian yang paling penting adalah AI menjalankan tiga peran berbeda secara berurutan. Setiap fase memiliki konteks dan tanggung jawab yang jelas, sehingga hasil akhir lebih matang dibanding generate sekali jadi.

## The Three Roles

Nara menggunakan pendekatan **role-based AI execution** — satu model AI yang sama menjalankan tiga posisi berbeda secara berurutan:

### 1. Strategist
**Tanggung jawab:** Memilih topic dan menentukan angle

**Input:**
- Knowledge base (referensi strategi, psikologi, copywriting)
- Ideas backlog (daftar topic kandidat)

**Output:**
- Topic terpilih
- Angle yang akan digunakan
- Objective konten

**Prinsip kerja:** Tidak random, tapi berdasarkan relevansi dan konteks. Strategist mempertimbangkan apa yang sudah pernah dibahas, apa yang sedang relevan, dan bagaimana memaksimalkan nilai untuk audiens.

### 2. Writer
**Tanggung jawab:** Menulis draft konten

**Input:**
- Strategi dari Strategist
- Persona guidelines
- Knowledge base

**Output:**
- Draft konten mentah

**Prinsip kerja:** Mengikuti arahan strategi, bukan sekadar menulis bebas. Writer memastikan konten sesuai dengan angle dan objective yang sudah ditetapkan.

### 3. Editor
**Tanggung jawab:** Merevisi dan mempertajam draft

**Input:**
- Draft dari Writer
- Persona guidelines
- Style guide

**Output:**
- Konten final siap publish

**Prinsip kerja:** Mengecek konsistensi tone, memastikan tidak ada larangan yang dilanggar, dan mempertajam hook serta struktur. Editor adalah quality gate sebelum konten tayang.

## Persona: "Nara"

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

**Larangan:**
- Clickbait
- Hard selling
- Auto viral framing
- Kata "rahasia" / "wajib"
- Nada menggurui

**Target audience:** Business Owner, UMKM, Startup, Freelancer, Content Creator

**Pendekatan:** Soft-selling melalui insight — membangun awareness dan kepercayaan, bukan jualan langsung

## Repo Structure

```text
nara-ai-strategist/
├── README.md                    # Dokumentasi utama (original)
├── README_SHOWCASE.md           # Dokumentasi showcase (file ini)
├── prompts/
│   ├── strategist_prompt.md     # Prompt untuk fase Strategist
│   ├── writer_prompt.md         # Prompt untuk fase Writer
│   └── editor_prompt.md         # Prompt untuk fase Editor
├── docs/
│   ├── dokumentasi-lengkap.md   # Detail alur, keputusan desain
│   ├── arsitektur-sistem.md     # Penjelasan arsitektur teknis
│   └── screenshots/             # Screenshot workflow dan dashboard
└── database/
    └── schema.sql               # Struktur database
```

## What's Inside

- `prompts/` berisi tiga prompt inti yang mendefinisikan perilaku AI di setiap fase. Setiap prompt sudah dioptimasi untuk peran spesifiknya.
- `docs/` berisi dokumentasi lengkap, arsitektur sistem, dan screenshot pendukung untuk presentasi atau showcase.
- `database/schema.sql` berisi struktur data yang dipakai: knowledge base, ideas backlog, history konten, dan metrics performa.

## Tech Stack

| Komponen | Fungsi |
|----------|--------|
| **n8n** | Orkestrasi workflow dan scheduling |
| **Supabase** | Database untuk knowledge, ideas, history, metrics |
| **Gemini API** | Model AI yang menjalankan ketiga peran |
| **Buffer** | Publishing ke Threads |
| **GitHub** | Backup basis pengetahuan mingguan |

## Database Schema

### Table `knowledge`
Basis pengetahuan referensi yang menjadi acuan AI saat menyusun strategi dan menulis.

| Column | Type | Description |
|--------|------|-------------|
| `id` | `int8` | Primary key |
| `category` | `text` | Kategori (psikologi, copywriting, storytelling, dll) |
| `title` | `text` | Judul item pengetahuan |
| `content` | `text` | Isi pengetahuan |
| `tags` | `_text` | Tag untuk filtering |
| `created_at` | `timestamptz` | Timestamp |

### Table `ideas`
Daftar topic mentah yang menjadi kandidat untuk dibahas.

| Column | Type | Description |
|--------|------|-------------|
| `id` | `int8` | Primary key |
| `topic` | `text` | Topik |
| `angle` | `text` | Sudut pandang |
| `priority` | `int4` | Prioritas |
| `status` | `text` | Status (pending, used, archived) |
| `created_at` | `timestamptz` | Timestamp |

### Table `history`
Arsip seluruh konten yang sudah digenerate dan dipublikasikan.

| Column | Type | Description |
|--------|------|-------------|
| `id` | `int8` | Primary key |
| `topic` | `text` | Topik yang dibahas |
| `angle` | `text` | Angle yang digunakan |
| `content` | `text` | Isi konten final |
| `status` | `text` | Status publikasi |
| `created_at` | `timestamptz` | Timestamp |
| `buffer_post_id` | `text` | ID post di Buffer |

### Table `metrics`
Data performa tiap konten yang sudah tayang.

| Column | Type | Description |
|--------|------|-------------|
| `id` | `int8` | Primary key |
| `history_id` | `int8` | Foreign key ke history |
| `impressions` | `int4` | Jumlah impressions |
| `likes` | `int4` | Jumlah likes |
| `replies` | `int4` | Jumlah replies |
| `reposts` | `int4` | Jumlah reposts |
| `created_at` | `timestamptz` | Timestamp |
| `buffer_post_id` | `text` | ID post di Buffer |

## Reading Order

Kalau baru pertama kali buka repo ini, urutan baca yang paling masuk akal adalah:

1. README ini untuk memahami gambaran besar
2. `docs/dokumentasi-lengkap.md` untuk detail alur dan keputusan desain
3. `prompts/strategist_prompt.md`, `writer_prompt.md`, `editor_prompt.md` untuk melihat implementasi peran AI
4. `database/schema.sql` untuk memahami struktur data

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

## Nilai Bisnis

- **Efisiensi** — proses yang biasanya membutuhkan tim dan waktu berjam-jam kini berjalan otomatis dalam hitungan menit
- **Konsistensi** — kualitas dan gaya bicara brand terjaga setiap hari, tidak bergantung pada ketersediaan orang
- **Skalabilitas** — pendekatan yang sama dapat diterapkan untuk brand atau klien lain dengan mengganti basis pengetahuannya

---

*Dokumentasi ini dibuat untuk showcase. Untuk dokumentasi teknis lengkap, lihat folder `docs/`.*
