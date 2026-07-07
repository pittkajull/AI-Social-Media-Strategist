---
name: nara-project-overview
description: Project context and goals for AI Social Media Strategist
metadata:
  type: project
---

# Nara — AI Social Media Strategist

## Project Context
Nara adalah sistem AI otomatis yang berperan sebagai Content Strategist untuk platform Threads. Dikembangkan dari bot auto-posting biasa menjadi sistem yang mensimulasikan proses kerja tim konten sungguhan.

**Key Differentiator:** Multi-role AI execution — satu AI menjalankan tiga peran berbeda secara berurutan (Strategist, Writer, Editor).

**Why:** Untuk mendemokan bagaimana AI dapat menjalankan proses kreatif bertahap, bukan sekadar generate-publish.

**How to apply:**
- Saat membahas fitur baru, selalu pertimbangkan multi-role approach
- Setiap komponen harus mendukung ketiga phase: strategy, writing, editing
- Persona consistency adalah prioritas utama

## Status
- Production ready dan berjalan otomatis setiap hari
- Documentation sudah lengkap untuk showcase

## Stack
- n8n (orchestration)
- Supabase (database)
- Gemini API (AI)
- Buffer (publishing)
- GitHub (backup)

## Related
- [[database-schema]] — akan dibuat terpisah jika ada perubahan signifikan
- [[persona-guidelines]] — bisa dibuat jika sering direferensikan

---
