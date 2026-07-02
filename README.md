# Nara — AI Social Media Strategist for Threads

Nara adalah AI Content Strategist yang dibangun untuk agency Social Media Management, khusus platform **Threads**. Nara membangun *awareness* lewat **soft-selling melalui insight**, bukan hard-selling — dengan pendekatan strategist, edukator, observer, dan teman bagi audiensnya.

## 🎯 Tujuan

Membangun kehadiran brand di Threads yang terasa manusiawi dan bernilai, dengan target audiens: **Business Owner, UMKM, Startup, Freelancer, dan Content Creator**.

### Persona Nara
- **Belief:** Human before algorithm · Strategy before content · Trust before sales · Curiosity before conclusion
- **Tone:** 40% Strategist, 30% Educator, 20% Observer, 10% Friend
- **Larangan:** clickbait, hard selling, klaim "auto viral", kata "rahasia"/"wajib", nada menggurui

## 🏗️ Arsitektur & Stack

| Komponen | Fungsi |
|---|---|
| **n8n** (self-hosted) | Orkestrasi seluruh workflow |
| **Supabase** | Database (knowledge, ideas, history, metrics) |
| **Gemini API** (`gemini-2.5-flash`) | LLM untuk Strategist → Writer → Editor |
| **Buffer API** | Publish otomatis ke Threads (mendukung thread bersambung) |
| **GitHub** | Version control untuk knowledge base & prompt |

## 🔄 Alur Kerja

### 1. Generate & Publish Konten (harian, otomatis via Cron)
```
Schedule Trigger
  → Ambil Knowledge (20 referensi) + Ideas (backlog topik)
  → Strategist (Gemini): pilih ide, tentukan angle & key insight
  → Writer (Gemini): tulis draft thread 4–7 post
  → Editor (Gemini): polish, pertajam closing, soft-selling halus
  → Publish ke Threads via Buffer (thread bersambung)
  → Simpan hasil ke tabel `history` (dengan buffer_post_id)
```

### 2. Fetch Metrics (harian, otomatis via Cron)
```
Schedule Trigger
  → Ambil post yang sudah published dari `history`
  → Query metrics per-post ke Buffer API (likes, replies, reposts, impressions)
  → Simpan ke tabel `metrics`
```

### 3. Sync Knowledge Base ke GitHub (mingguan, otomatis via Cron)
```
Schedule Trigger
  → Export tabel `knowledge` dari Supabase
  → Commit ke GitHub (create atau update, otomatis deteksi lewat SHA)
```

## 🗄️ Struktur Database (Supabase)

- **`knowledge`** — referensi strategi (Psychology, Branding, Copywriting, Storytelling, Threads, Business, Content Strategy)
- **`ideas`** — backlog topik dengan prioritas
- **`history`** — log setiap konten yang digenerate & dipublish, termasuk `buffer_post_id`
- **`metrics`** — performa tiap post (likes, replies, reposts, impressions), ter-link ke `history`

> RLS dinonaktifkan di semua tabel karena akses hanya dilakukan secara internal via n8n menggunakan `service_role` key.

## 📁 Struktur Repo

```
├── prompts/              # System prompt untuk Strategist, Writer, Editor
│   ├── strategist_prompt.md
│   ├── writer_prompt.md
│   └── editor_prompt.md
├── knowledge/            # Snapshot knowledge base (auto-synced dari Supabase)
│   └── knowledge_export.json
└── README.md
```

## 📌 Status

- ✅ Generate konten otomatis harian
- ✅ Auto-publish ke Threads (via Buffer, mendukung thread bersambung)
- ✅ Tracking metrics performa harian
- ✅ Auto-sync knowledge base ke GitHub

### Belum dikerjakan
- Auto-sync prompt ke GitHub (saat ini baru knowledge base)
- Dashboard/reporting dari data `metrics`

---

*Dibangun dengan pendekatan "Trust before sales" — karena kepercayaan bukan hasil dari penjualan, melainkan investasi yang dipupuk lewat konsistensi dan nilai.*
