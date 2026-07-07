# Arsitektur Sistem Nara

Dokumen ini menjelaskan arsitektur teknis dan implementasi sistem Nara secara detail.

---

## Overview Arsitektur

Nara dibangun dengan pendekatan **microservices-style** yang diorkestrasikan oleh n8n. Setiap komponen memiliki tanggung jawab yang jelas dan dapat diganti tanpa mempengaruhi komponen lain.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           ORCHESTRATION LAYER                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         n8n Workflow Engine                      │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐  │   │
│  │  │ Scheduler  │  │   Router   │  │  Handler   │  │  Logger  │  │   │
│  │  │  (Cron)    │  │  (Switch)  │  │  (Logic)   │  │  (Error) │  │   │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           DATA LAYER                                    │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                       Supabase (PostgreSQL)                      │   │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐  ┌──────────┐  │   │
│  │  │ knowledge  │  │   ideas    │  │  history   │  │ metrics  │  │   │
│  │  │   table    │  │   table    │  │   table    │  │  table   │  │   │
│  │  └────────────┘  └────────────┘  └────────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                          AI PROCESSING LAYER                            │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         Gemini API                               │   │
│  │  ┌──────────────────────────────────────────────────────────┐   │   │
│  │  │              Multi-Role AI Execution                      │   │   │
│  │  │                                                            │   │   │
│  │  │   ┌───────────┐      ┌───────────┐      ┌───────────┐   │   │   │
│  │  │   │Strategist │ ──▶  │  Writer   │ ──▶  │  Editor   │   │   │   │
│  │  │   │ (Phase 1) │      │ (Phase 2) │      │ (Phase 3) │   │   │   │
│  │  │   └───────────┘      └───────────┘      └───────────┘   │   │   │
│  │  │        │                  │                  │          │   │   │
│  │  │        ▼                  ▼                  ▼          │   │   │
│  │  │   [Topic +         [Draft            [Final           │   │   │
│  │  │    Angle]           Content]           Content]        │   │   │
│  │  └──────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         INTEGRATION LAYER                               │
│  ┌─────────────────────┐              ┌─────────────────────┐          │
│  │     Buffer API      │              │     GitHub API      │          │
│  │  (Publishing to     │              │   (Backup &         │          │
│  │     Threads)        │              │    Versioning)      │          │
│  └─────────────────────┘              └─────────────────────┘          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Komponen Detail

### 1. n8n Workflow Engine

**Fungsi:** Orkestrasi seluruh workflow dan scheduling

**Konfigurasi:**
- Hosted on: Local server / Cloud
- Database: SQLite (default) atau PostgreSQL
- Authentication: Basic Auth

**Workflows:**
| Workflow | Schedule | Trigger |
|----------|----------|---------|
| Generate & Publish | Daily 08:00 WIB | Cron: `0 1 * * *` |
| Track Performance | Daily 20:00 WIB | Cron: `0 13 * * *` |
| Backup Knowledge | Weekly Sunday 00:00 WIB | Cron: `0 17 * * 0` |

**Nodes yang digunakan:**
- `Cron` — scheduling trigger
- `HTTP Request` — API calls
- `Postgres` — database operations
- `Code` — data transformation
- `Switch` — conditional routing
- `Error Trigger` — error handling

### 2. Supabase Database

**Fungsi:** Menyimpan seluruh data sistem

**Konfigurasi:**
- Region: Singapore (ap-southeast-1)
- Plan: Free tier (atau Pro untuk production)
- Connection: Connection pooling enabled

**Tables:**
```sql
-- Lihat database/schema.sql untuk detail lengkap
knowledge  →  Basis pengetahuan AI
ideas      →  Backlog ide konten
history    →  Arsip konten terpublish
metrics    →  Data performa
```

**Security:**
- RLS (Row Level Security) enabled
- Service role key untuk automation
- Anon key untuk read-only access

### 3. Gemini API

**Fungsi:** Menjalankan ketiga peran AI

**Model:** Gemini 1.5 Pro atau Gemini 1.5 Flash

**Konfigurasi:**
```javascript
{
  "model": "gemini-1.5-pro",
  "temperature": 0.7,
  "max_output_tokens": 1024,
  "top_p": 0.95,
  "top_k": 40
}
```

**Rate Limiting:**
- 60 requests per minute (free tier)
- 300 requests per minute (paid tier)

### 4. Buffer API

**Fungsi:** Publishing ke Threads

**Authentication:** OAuth 2.0

**Endpoints:**
```
POST /1/updates/create.json     → Create new post
GET  /1/updates/:id.json        → Get post details
GET  /1/updates/:id/analytics   → Get performance data
```

**Rate Limiting:**
- 100 requests per hour

### 5. GitHub API

**Fungsi:** Backup basis pengetahuan

**Authentication:** Personal Access Token (PAT)

**Operations:**
```bash
git add knowledge_backup.md
git commit -m "Weekly backup: $(date)"
git push origin main
```

---

## Data Flow Diagram

### Flow 1: Generate & Publish

```
┌──────────┐
│  Cron    │ 08:00 WIB
│ Trigger  │
└────┬─────┘
     │
     ▼
┌──────────────────┐
│ Fetch Knowledge  │ SELECT * FROM knowledge
│ & Ideas          │ SELECT * FROM ideas WHERE status='pending'
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Strategist AI    │ Input: knowledge[], ideas[]
│                  │ Output: {topic, angle, objective}
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Writer AI        │ Input: strategy, knowledge[]
│                  │ Output: {draft_content}
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Editor AI        │ Input: draft, persona
│                  │ Output: {final_content}
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Buffer API       │ POST /updates/create
│ Publish          │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Save to History  │ INSERT INTO history
│ & Update Ideas   │ UPDATE ideas SET status='used'
└──────────────────┘
```

### Flow 2: Track Performance

```
┌──────────┐
│  Cron    │ 20:00 WIB
│ Trigger  │
└────┬─────┘
     │
     ▼
┌──────────────────┐
│ Fetch Published  │ SELECT * FROM history
│ Posts            │ WHERE buffer_post_id IS NOT NULL
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ For Each Post:   │ Loop through posts
│                  │
│  ┌────────────┐  │
│  │ Buffer API │  │ GET /updates/:id/analytics
│  │ Analytics  │  │
│  └─────┬──────┘  │
│        │         │
│        ▼         │
│  ┌────────────┐  │
│  │ Save       │  │ INSERT INTO metrics
│  │ Metrics    │  │
│  └────────────┘  │
└──────────────────┘
```

### Flow 3: Backup Knowledge

```
┌──────────┐
│  Cron    │ Sunday 00:00 WIB
│ Trigger  │
└────┬─────┘
     │
     ▼
┌──────────────────┐
│ Fetch All        │ SELECT * FROM knowledge
│ Knowledge        │ ORDER BY created_at
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Format as        │ Convert to markdown
│ Markdown         │ with proper structure
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ GitHub Commit    │ git add, commit, push
│ & Push           │
└──────────────────┘
```

---

## Environment Variables

```bash
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Gemini API
GEMINI_API_KEY=AIza...

# Buffer API
BUFFER_ACCESS_TOKEN=1/xxxxx...
BUFFER_PROFILE_ID=5fxxxxx...

# GitHub
GITHUB_TOKEN=ghp_xxxxx...
GITHUB_REPO=username/repo-name
```

---

## Error Handling Strategy

### Retry Logic

```javascript
// n8n retry configuration
{
  "retry": {
    "maxRetries": 3,
    "retryInterval": 5000,  // 5 seconds
    "retryOn": ["TimeoutError", "ConnectionError"]
  }
}
```

### Error Logging

```javascript
// Error handler node
{
  "error": {
    "message": error.message,
    "stack": error.stack,
    "timestamp": new Date().toISOString(),
    "workflow": $workflow.name,
    "executionId": $execution.id
  }
}
```

### Fallback Behavior

| Component | Failure | Fallback |
|-----------|---------|----------|
| Database | Connection failed | Retry 3x, then skip |
| Gemini API | Rate limit | Wait 60s, retry |
| Buffer API | Publish failed | Save as draft, alert |
| GitHub API | Push failed | Save locally, retry next day |

---

## Performance Considerations

### Database Optimization

- Index pada kolom yang sering di-query
- Connection pooling untuk mengurangi overhead
- Periodic vacuum untuk cleanup

### API Rate Limiting

- Implementasi request queue
- Cache response untuk data yang jarang berubah
- Batch operations jika memungkinkan

### AI Processing

- Gunakan model yang lebih cepat (Flash) untuk fase draft
- Cache prompt yang sering digunakan
- Monitor token usage

---

## Security Considerations

### API Keys Management

- Simpan di environment variables
- Jangan hardcode di workflow
- Rotate secara berkala

### Database Access

- Gunakan service role key hanya untuk automation
- Enable RLS untuk proteksi tambahan
- Log semua query untuk audit

### Content Safety

- Filter konten sebelum publish
- Implementasi content moderation
- Log semua konten yang di-generate

---

## Monitoring & Observability

### Health Checks

```javascript
// Daily health check workflow
{
  "database": "SELECT 1",
  "gemini_api": "Simple prompt test",
  "buffer_api": "Get profile info",
  "github_api": "Get repo info"
}
```

### Metrics to Track

- Workflow execution success rate
- Average execution time per workflow
- API response times
- Error frequency by type
- Content generation quality (manual review)

### Alerting

- Workflow failure → Telegram notification
- API rate limit approaching → Email alert
- Database connection issues → Immediate alert

---

## Deployment Architecture

### Development Environment

```
Local Machine
├── n8n (Docker)
├── Supabase (Cloud - Dev project)
├── Gemini API (Dev key)
└── Buffer (Dev account)
```

### Production Environment

```
Cloud Server (e.g., Railway, Render)
├── n8n (Cloud hosted)
├── Supabase (Cloud - Prod project)
├── Gemini API (Prod key)
└── Buffer (Prod account)
```

---

## Future Architecture Improvements

### Short Term
- [ ] Add Redis for caching
- [ ] Implement proper queue system
- [ ] Add monitoring dashboard

### Long Term
- [ ] Multi-tenant support
- [ ] Custom AI model fine-tuning
- [ ] Real-time analytics dashboard
- [ ] Multi-platform publishing

---

*Dokumen ini akan diupdate seiring perkembangan arsitektur sistem.*
