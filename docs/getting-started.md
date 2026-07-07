# Getting Started Guide

Panduan untuk memulai dan menjalankan sistem Nara dari awal.

---

## Prerequisites

Sebelum memulai, pastikan Anda memiliki:

- [ ] Akun Supabase (free tier cukup)
- [ ] Akun Google Cloud dengan Gemini API enabled
- [ ] Akun Buffer dengan akses ke Threads
- [ ] Akun GitHub
- [ ] n8n terinstal (self-hosted atau cloud)
- [ ] Pengetahuan dasar PostgreSQL
- [ ] Pengetahuan dasar workflow automation

---

## Step 1: Setup Database

### 1.1 Buat Project Supabase

1. Login ke [Supabase](https://supabase.com)
2. Buat project baru dengan nama `nara-strategist`
3. Pilih region terdekat (Singapore untuk Indonesia)
4. Tunggu hingga project selesai dibuat

### 1.2 Jalankan Schema

1. Buka SQL Editor di Supabase dashboard
2. Copy isi dari `database/schema.sql`
3. Paste dan jalankan
4. Pastikan semua tabel berhasil dibuat

### 1.3 Dapatkan Credentials

1. Buka Settings > API
2. Salin `Project URL` dan `service_role key`
3. Simpan sebagai environment variables:
   ```bash
   SUPABASE_URL=https://xxxxx.supabase.co
   SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

## Step 2: Setup Gemini API

### 2.1 Enable Gemini API

1. Buka [Google Cloud Console](https://console.cloud.google.com)
2. Buat project baru atau gunakan yang ada
3. Buka APIs & Services > Library
4. Cari "Gemini API" dan enable

### 2.2 Buat API Key

1. Buka APIs & Services > Credentials
2. Klik "Create Credentials" > "API Key"
3. Salin API key
4. Simpan sebagai environment variable:
   ```bash
   GEMINI_API_KEY=AIza...
   ```

---

## Step 3: Setup Buffer

### 3.1 Dapatkan Access Token

1. Login ke [Buffer](https://buffer.com)
2. Buka Settings > Apps
3. Buat aplikasi baru jika belum ada
4. Dapatkan access token
5. Simpan sebagai environment variable:
   ```bash
   BUFFER_ACCESS_TOKEN=1/xxxxx...
   ```

### 3.2 Dapatkan Profile ID

1. Hubungkan akun Threads ke Buffer
2. Gunakan API untuk mendapatkan profile ID:
   ```bash
   curl -X GET "https://api.bufferapp.com/1/profiles.json" \
     -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
   ```
3. Simpan sebagai environment variable:
   ```bash
   BUFFER_PROFILE_ID=5fxxxxx...
   ```

---

## Step 4: Setup GitHub

### 4.1 Buat Repository

1. Buat repository baru di GitHub
2. Tambahkan README.md
3. Clone repository ke lokal

### 4.2 Buat Personal Access Token

1. Buka GitHub Settings > Developer settings > Personal access tokens
2. Buat token dengan scope `repo`
3. Simpan sebagai environment variable:
   ```bash
   GITHUB_TOKEN=ghp_xxxxx...
   GITHUB_REPO=username/repo-name
   ```

---

## Step 5: Setup n8n

### 5.1 Install n8n

**Option A: Docker**
```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

**Option B: npm**
```bash
npm install n8n -g
n8n start
```

### 5.2 Tambahkan Environment Variables

Buat file `.env` di folder n8n:
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

### 5.3 Tambahkan Credentials

Di n8n dashboard:
1. Buka Settings > Credentials
2. Tambahkan credential untuk:
   - PostgreSQL (Supabase)
   - Google Gemini API
   - HTTP Query Auth (Buffer)
   - GitHub API

---

## Step 6: Import Workflows

### 6.1 Workflow Generate & Publish

1. Buat workflow baru di n8n
2. Import dari `docs/example-workflows.md`
3. Sesuaikan node sesuai credentials
4. Test dengan manual trigger

### 6.2 Workflow Tracking

1. Buat workflow baru
2. Import konfigurasi tracking
3. Sesuaikan credentials
4. Test dengan manual trigger

### 6.3 Workflow Backup

1. Buat workflow baru
2. Import konfigurasi backup
3. Sesuaikan credentials
4. Test dengan manual trigger

---

## Step 7: Isi Knowledge Base

### 7.1 Tambah Data Knowledge

```sql
INSERT INTO knowledge (category, title, content, tags) VALUES
('copywriting', 'Hook Formula', 'Gunakan pola: [Pernyataan mengejutkan] + [Kenapa penting] + [Apa yang harus dilakukan]', ARRAY['hook', 'opening', 'engagement']),
('psikologi', 'Social Proof', 'Orang cenderung mengikuti tindakan orang lain ketika tidak yakin harus melakukan apa', ARRAY['social-proof', 'trust', 'influence']);
```

### 7.2 Tambah Data Ideas

```sql
INSERT INTO ideas (topic, angle, priority, status) VALUES
('Produktivitas remote work', 'Tips praktis berdasarkan pengalaman nyata', 8, 'pending'),
('Mindset entrepreneur pemula', 'Kesalahan umum dan cara menghindarinya', 7, 'pending');
```

---

## Step 8: Test dan Monitoring

### 8.1 Test Manual

Jalankan setiap workflow secara manual:
1. Generate & Publish - Cek apakah konten berhasil di-publish
2. Tracking - Cek apakah metrics berhasil disimpan
3. Backup - Cek apakah file berhasil di-commit ke GitHub

### 8.2 Monitor Logs

Periksa execution logs di n8n:
- Success rate
- Execution time
- Error messages

### 8.3 Cek Output

- Buka Threads untuk melihat konten yang di-publish
- Buka Supabase untuk melihat data history dan metrics
- Buka GitHub untuk melihat backup knowledge

---

## Troubleshooting

### Database Connection Failed
- Cek SUPABASE_URL dan SUPABASE_SERVICE_KEY
- Pastikan IP address di-allowlist jika perlu
- Cek apakah Supabase project aktif

### Gemini API Error
- Cek GEMINI_API_KEY validity
- Pastikan quota belum exceeded
- Cek model name (gemini-1.5-pro atau gemini-1.5-flash)

### Buffer Publish Failed
- Cek BUFFER_ACCESS_TOKEN validity
- Pastikan BUFFER_PROFILE_ID benar
- Cek apakah akun Threads terhubung dengan Buffer

### GitHub Push Failed
- Cek GITHUB_TOKEN validity
- Pastikan repo exists
- Cek apakah token memiliki scope `repo`

---

## Next Steps

Setelah sistem berjalan:
1. Monitor performa konten secara berkala
2. Tambah knowledge base sesuai kebutuhan
3. Adjust prompt untuk hasil yang lebih baik
4. Tambah ideas backlog untuk variasi konten

---

*Panduan ini akan diupdate seiring perkembangan project.*
