# Nara Showcase Guide

Panduan untuk mempresentasikan dan mendemokan sistem Nara sebagai showcase project.

---

## Quick Start untuk Demo

### Persiapan Sebelum Demo

1. **Pastikan sistem berjalan**
   - n8n aktif dan terkoneksi
   - Supabase database accessible
   - Buffer API terautentikasi
   - Gemini API key valid

2. **Siapkan data demo**
   - Knowledge base minimal 10 entries
   - Ideas backlog minimal 5 pending ideas
   - History dengan beberapa konten yang sudah publish

3. **Screenshot yang perlu disiapkan**
   - Workflow n8n (ketiga workflow)
   - Dashboard Supabase
   - Contoh konten di Threads
   - Performance metrics

---

## Demo Script

### Bagian 1: Introduction (5 menit)

**Slide/Halaman: README_SHOWCASE.md**

**Key Points:**
- Nara adalah AI yang menjalankan 3 peran: Strategist, Writer, Editor
- Berbeda dari bot biasa yang langsung generate-publish
- Proses bertahap seperti tim konten sungguhan

**Script:**
> "Nara bukan sekadar bot auto-posting. Bayangkan Anda punya tim konten dengan 3 orang: Strategist yang menentukan topik, Writer yang menulis, dan Editor yang merevisi. Nara menjalankan ketiganya secara otomatis dengan satu AI yang sama."

### Bagian 2: Architecture Overview (5 menit)

**Slide/Halaman: docs/arsitektur-sistem.md**

**Key Points:**
- n8n sebagai orkestrator
- Supabase untuk database
- Gemini API untuk AI
- Buffer untuk publishing

**Demo:**
- Tampilkan diagram arsitektur
- Jelaskan alur data dari trigger hingga publish

**Script:**
> "Semua diorkestrasikan oleh n8n. Setiap pagi jam 8, sistem otomatis bangun, ambil data dari Supabase, proses dengan Gemini, lalu publish ke Threads via Buffer."

### Bagian 3: Live Demo (10 menit)

**Demo Workflow 1: Generate & Publish**

1. Buka n8n workflow
2. Tampilkan node-node utama:
   - Cron trigger
   - Database query
   - AI nodes (Strategist, Writer, Editor)
   - Buffer publish
3. Jalankan manual trigger untuk demo

**Script:**
> "Mari kita lihat prosesnya secara langsung. Pertama, sistem mengambil knowledge base dan ideas backlog..."

**Demo Workflow 2: Track Performance**

1. Buka workflow tracking
2. Tampilkan data metrics yang sudah terkumpul

**Script:**
> "Setiap malam, sistem otomatis mengambil data performa dari konten yang sudah tayang."

### Bagian 4: Database Structure (5 menit)

**Slide/Halaman: database/schema.sql**

**Key Points:**
- Knowledge table untuk basis pengetahuan
- Ideas untuk backlog topik
- History untuk arsip konten
- Metrics untuk performa

**Demo:**
- Buka Supabase dashboard
- Tampilkan sample data di setiap table

**Script:**
> "Knowledge base ini adalah 'otak' dari Nara. Di sini tersimpan referensi tentang copywriting, psikologi, storytelling yang menjadi acuan saat AI memilih topik dan menulis."

### Bagian 5: AI Roles Deep Dive (5 menit)

**Slide/Halaman: prompts/ directory**

**Key Points:**
- Setiap peran memiliki prompt yang berbeda
- Persona consistency dijaga oleh Editor
- Context passing antar phase

**Demo:**
- Buka strategist_prompt.md
- Jelaskan struktur prompt
- Tampilkan contoh output per phase

**Script:**
> "Strategist memilih topik berdasarkan knowledge base. Writer menulis draft. Editor memastikan gaya bicara konsisten. Setiap phase punya tanggung jawab yang jelas."

### Bagian 6: Results & Metrics (5 menit)

**Demo:**
- Tampilkan konten yang sudah publish di Threads
- Tampilkan dashboard metrics (jika ada)
- Tampilkan engagement data

**Script:**
> "Ini adalah hasil kerja Nara selama [X] bulan. Konten dihasilkan secara otomatis setiap hari dengan gaya bicara yang konsisten."

### Bagian 7: Q&A (5-10 menit)

**Pertanyaan yang sering ditanyakan:**

1. **Q: Kenapa tidak langsung pakai Threads API?**
   A: Threads API belum sepenuhnya publik. Buffer memberikan interface yang stabil dan analytics.

2. **Q: Berapa biaya operasional?**
   A: Dengan free tier, hampir $0. Gemini free tier cukup untuk 1-2 konten per hari.

3. **Q: Bagaimana jika konten tidak sesuai?**
   A: Editor phase bertugas mengecek. Jika masih tidak sesuai, bisa ditambahkan approval step via Telegram.

4. **Q: Apakah bisa dikembangkan untuk platform lain?**
   A: Ya, tinggal ganti channel di Buffer. Arsitektur sama.

5. **Q: Bagaimana dengan multi-language?**
   A: Tinggal ubah prompt ke bahasa yang diinginkan.

---

## Key Selling Points

### 1. Multi-Role AI Execution
- Satu AI, tiga peran berbeda
- Proses bertahap seperti tim sungguhan
- Hasil lebih matang dan konsisten

### 2. Knowledge-Driven Strategy
- Keputusan berdasarkan data, bukan random
- Basis pengetahuan terstruktur
- Bisa dikembangkan untuk domain lain

### 3. Full Automation Pipeline
- Dari ide hingga publish tanpa intervensi
- Performance tracking otomatis
- Backup terjadwal

### 4. Scalable Architecture
- Bisa digunakan untuk multiple brands
- Ganti knowledge base = ganti "kepribadian"
- Tidak terikat platform tertentu

---

## Demo Checklist

Sebelum presentasi, pastikan:

- [ ] n8n running dan accessible
- [ ] Database memiliki sample data
- [ ] Screenshot sudah di-capture
- [ ] Live demo sudah di-test
- [ ] Backup plan jika live demo gagal
- [ ] Pertanyaan umum sudah diantisipasi
- [ ] Timing sudah di-rehearse

---

## File yang Perlu Dibawa

1. `README_SHOWCASE.md` — Overview
2. `docs/dokumentasi-lengkap.md` — Detail teknis
3. `docs/arsitektur-sistem.md` — Arsitektur
4. `database/schema.sql` — Database structure
5. `prompts/*.md` — AI prompts
6. Screenshots folder — Visual aids

---

## Follow-up Actions Setelah Demo

- Kirimkan link repo GitHub
- Share dokumentasi lengkap
- Tawarkan demo hands-on jika diminta
- Diskusi use case spesifik jika ada interest

---

*Dokumen ini adalah panduan internal untuk persiapan showcase.*
