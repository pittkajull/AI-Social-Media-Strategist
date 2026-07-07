# Dokumentasi Lengkap Nara — AI Social Media Strategist

Dokumen ini menjelaskan detail alur kerja, keputusan desain, dan implementasi teknis dari sistem Nara.

---

## Daftar Isi

1. [Latar Belakang](#latar-belakang)
2. [Arsitektur Sistem](#arsitektur-sistem)
3. [Alur Kerja Detail](#alur-kerja-detail)
4. [Keputusan Desain](#keputusan-desain)
5. [Implementasi AI Roles](#implementasi-ai-roles)
6. [Database Design](#database-design)
7. [API dan Integrasi](#api-dan-integrasi)
8. [Monitoring dan Logging](#monitoring-dan-logging)
9. [Troubleshooting](#troubleshooting)
10. [Roadmap](#roadmap)

---

## Latar Belakang

### Problem Statement

Kebanyakan bot AI untuk media sosial bekerja dengan pola sederhana: *prompt → generate → publish*. Pendekatan ini memiliki beberapa masalah:

1. **Kurang matang** — konten dihasilkan tanpa proses review bertahap
2. **Tidak konsisten** — gaya bicara bisa berubah-ubah antar post
3. **Tidak strategis** — topic dipilih secara random, tidak ada pertimbangan strategis
4. **Sulit diaudit** — tidak ada jejak keputusan kenapa suatu konten ditulis demikian

### Solusi: Multi-Role AI Execution

Nara mengambil pendekatan berbeda: **satu AI yang menjalankan tiga peran berbeda secara berurutan**. Setiap peran memiliki tanggung jawab dan konteks yang jelas, sehingga proses kreatif menjadi terstruktur dan bisa diaudit.

---

## Arsitektur Sistem

### Komponen Utama

```
┌─────────────────────────────────────────────────────────────┐
│                        n8n Workflow Engine                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Scheduler   │  │   Router     │  │   Logger     │      │
│  │  (Cron)      │  │  (Switch)    │  │  (Error)     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Supabase Database                       │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ knowledge  │  │   ideas    │  │  history   │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│  ┌────────────┐                                             │
│  │  metrics   │                                             │
│  └────────────┘                                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Gemini API                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  Strategist  │  │   Writer     │  │   Editor     │      │
│  │  (Phase 1)   │→ │  (Phase 2)   │→ │  (Phase 3)   │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Buffer API                                │
│           (Publishing ke Threads)                            │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **Input Phase**
   - Scheduler trigger pada waktu yang ditentukan
   - Query knowledge base dan ideas backlog dari Supabase
   - Siapkan konteks untuk Strategist

2. **Processing Phase**
   - Strategist memilih topic dan menentukan angle
   - Writer menulis draft berdasarkan strategi
   - Editor merevisi dan mempertajam

3. **Output Phase**
   - Kirim konten final ke Buffer
   - Simpan ke history dengan buffer_post_id
   - Log hasil eksekusi

---

## Alur Kerja Detail

### Workflow 1: Generate & Publish Konten

**Schedule:** Setiap hari pada pukul 08:00 WIB

**Steps:**

```
1. Trigger (Schedule)
   └─ Cron: "0 1 * * *" (UTC)

2. Fetch Knowledge Base
   └─ Query: SELECT * FROM knowledge ORDER BY created_at DESC
   └─ Store di context untuk digunakan 3 phase

3. Fetch Ideas Backlog
   └─ Query: SELECT * FROM ideas WHERE status = 'pending' ORDER BY priority DESC

4. Phase 1: Strategist
   └─ Input: knowledge[], ideas[]
   └─ Prompt: "Kamu adalah Strategist..."
   └─ Output: { topic, angle, objective, reasoning }

5. Phase 2: Writer
   └─ Input: strategist_output, knowledge[]
   └─ Prompt: "Kamu adalah Writer..."
   └─ Output: { draft_content }

6. Phase 3: Editor
   └─ Input: writer_output, persona_guidelines
   └─ Prompt: "Kamu adalah Editor..."
   └─ Output: { final_content }

7. Publish to Buffer
   └─ POST /updates/create
   └─ Body: { text: final_content, channel_ids: [...] }

8. Save to History
   └─ INSERT INTO history (topic, angle, content, status, buffer_post_id)

9. Mark Idea as Used
   └─ UPDATE ideas SET status = 'used' WHERE id = selected_idea_id
```

### Workflow 2: Tracking Performa

**Schedule:** Setiap hari pada pukul 20:00 WIB

**Steps:**

```
1. Trigger (Schedule)
   └─ Cron: "0 13 * * *" (UTC)

2. Fetch Published Content
   └─ Query: SELECT * FROM history WHERE status = 'published' AND buffer_post_id IS NOT NULL

3. For Each Post:
   └─ GET /updates/:id/analytics
   └─ Parse: impressions, likes, replies, reposts
   
4. Save Metrics
   └─ INSERT INTO metrics (history_id, impressions, likes, replies, reposts, buffer_post_id)

5. Update History Status (if needed)
   └─ Mark posts that failed to publish
```

### Workflow 3: Backup Knowledge Base

**Schedule:** Setiap minggu pada hari Minggu pukul 00:00 WIB

**Steps:**

```
1. Trigger (Schedule)
   └─ Cron: "0 17 * * 0" (UTC)

2. Fetch All Knowledge
   └─ Query: SELECT * FROM knowledge ORDER BY created_at

3. Format as Markdown
   └─ Convert rows to structured markdown

4. Commit to GitHub
   └─ git add knowledge_backup.md
   └─ git commit -m "Weekly knowledge backup: $(date)"
   └─ git push origin main
```

---

## Keputusan Desain

### Kenapa Multi-Role, Bukan Multi-Model?

**Pertimbangan:**
- Lebih mudah mengelola satu prompt yang sama
- Konsistensi gaya bicara lebih terjaga
- Biaya API lebih terkontrol

**Trade-off:**
- Tidak ada keberagaman "suara" antar phase
- Memory antar phase harus di-pass secara eksplisit

### Kenapa Buffer, Bukan Threads API Langsung?

**Pertimbangan:**
- Threads API belum sepenuhnya publik
- Buffer menyediakan analytics yang mudah diakses
- Dapat schedule post untuk waktu tertentu

**Trade-off:**
- Ada delay antara publish dan muncul di Threads
- Tergantung pada uptime Buffer

### Kenapa Supabase, Bukan Database Lain?

**Pertimbangan:**
- PostgreSQL yang fully managed
- Built-in authentication dan API
- Dashboard yang memudahkan monitoring

**Trade-off:**
- Vendor lock-in
- Biaya bisa naik seiring pertumbuhan data

---

## Implementasi AI Roles

### Strategist Prompt Structure

```
## Role
Kamu adalah Content Strategist bernama Nara.

## Task
Pilih satu topic dari ideas backlog dan tentukan angle yang paling relevan untuk dibahas hari ini.

## Context
- Knowledge Base: {knowledge}
- Ideas Backlog: {ideas}
- Recent History: {recent_posts}

## Constraints
- Jangan pilih topic yang sudah dibahas dalam 7 hari terakhir
- Pertimbangkan relevansi dan nilai untuk audiens
- Jelaskan reasoning di balik pilihan

## Output Format
{
  "selected_idea_id": number,
  "topic": "string",
  "angle": "string",
  "objective": "string",
  "reasoning": "string"
}
```

### Writer Prompt Structure

```
## Role
Kamu adalah Content Writer bernama Nara.

## Task
Tulis draft konten Threads berdasarkan strategi yang sudah ditetapkan.

## Context
- Strategy: {strategist_output}
- Knowledge Base: {knowledge}
- Persona: {persona_guidelines}

## Constraints
- Maksimal 500 karakter
- Hook kuat di baris pertama
- Tidak ada hard selling
- Gunakan gaya bicara yang sudah ditentukan

## Output Format
{
  "draft_content": "string"
}
```

### Editor Prompt Structure

```
## Role
Kamu adalah Content Editor bernama Nara.

## Task
Review dan revisi draft konten sebelum dipublikasikan.

## Context
- Draft: {writer_output}
- Persona: {persona_guidelines}
- Prohibited Words: {larangan}

## Constraints
- Pastikan tidak ada kata terlarang
- Pertajam hook jika perlu
- Cek konsistensi tone
- Maksimal 500 karakter

## Output Format
{
  "final_content": "string",
  "changes_made": ["string"],
  "approved": boolean
}
```

---

## Database Design

### Entity Relationship Diagram

```
┌─────────────┐       ┌─────────────┐
│  knowledge  │       │    ideas    │
├─────────────┤       ├─────────────┤
│ id          │       │ id          │
│ category    │       │ topic       │
│ title       │       │ angle       │
│ content     │       │ priority    │
│ tags        │       │ status      │
│ created_at  │       │ created_at  │
└─────────────┘       └─────────────┘

┌─────────────┐       ┌─────────────┐
│   history   │───┐   │   metrics   │
├─────────────┤   │   ├─────────────┤
│ id          │   └──▶│ id          │
│ topic       │       │ history_id  │
│ angle       │       │ impressions │
│ content     │       │ likes       │
│ status      │       │ replies     │
│ buffer_id   │       │ reposts     │
│ created_at  │       │ created_at  │
└─────────────┘       └─────────────┘
```

### Indexing Strategy

- `knowledge(category)` — filter berdasarkan kategori
- `knowledge(tags)` — GIN index untuk array tags
- `ideas(status)` — filter ide yang pending
- `ideas(priority)` — sorting berdasarkan prioritas
- `history(buffer_post_id)` — lookup untuk tracking
- `history(created_at)` — sorting kronologis
- `metrics(history_id)` — join dengan history

---

## API dan Integrasi

### Buffer API Endpoints

**Create Update:**
```http
POST https://api.bufferapp.com/1/updates/create.json
Authorization: Bearer {access_token}

{
  "text": "Content here",
  "profile_ids": ["profile_id"],
  "now": true
}
```

**Get Analytics:**
```http
GET https://api.bufferapp.com/1/updates/{update_id}/analytics.json
Authorization: Bearer {access_token}
```

### Supabase Connection

```javascript
const { createClient } = require('@supabase/supabase-js')

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
)
```

---

## Monitoring dan Logging

### Error Handling

Setiap workflow memiliki error handler yang:
1. Log error ke n8n execution log
2. Kirim notifikasi ke Telegram (opsional)
3. Retry maksimal 3 kali untuk transient errors

### Success Metrics

- Content published per day: 1 (target)
- Tracking accuracy: >95%
- Backup success rate: 100%

---

## Troubleshooting

### Masalah Umum

**1. Konten tidak ter-publish**
- Cek Buffer API status
- Verifikasi buffer_post_id tersimpan
- Check error log di n8n

**2. Performa tidak ter-track**
- Pastikan buffer_post_id valid
- Cek apakah analytics sudah available
- Verifikasi endpoint Buffer API

**3. Knowledge base tidak ter-backup**
- Cek GitHub token validity
- Verifikasi repository permissions
- Check cron schedule

---

## Roadmap

### Phase 1 (Current) ✅
- Generate konten harian
- Auto-publish ke Threads
- Performance tracking
- Weekly backup

### Phase 2 (Next)
- Dashboard publik
- Backup prompt AI
- Multi-platform support (Twitter, LinkedIn)

### Phase 3 (Future)
- A/B testing konten
- Sentiment analysis
- Audience insights
- Custom training model

---

*Dokumen ini akan diupdate seiring perkembangan project.*
