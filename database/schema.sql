-- Nara AI Social Media Strategist Database Schema
-- PostgreSQL / Supabase

-- ============================================
-- Table: knowledge
-- Basis pengetahuan referensi untuk AI
-- ============================================

CREATE TABLE IF NOT EXISTS knowledge (
    id BIGSERIAL PRIMARY KEY,
    category TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tags TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk pencarian berdasarkan kategori
CREATE INDEX idx_knowledge_category ON knowledge(category);

-- Index untuk pencarian berdasarkan tags
CREATE INDEX idx_knowledge_tags ON knowledge USING GIN(tags);

-- ============================================
-- Table: ideas
-- Backlog ide konten
-- ============================================

CREATE TABLE IF NOT EXISTS ideas (
    id BIGSERIAL PRIMARY KEY,
    topic TEXT,
    angle TEXT,
    priority INTEGER DEFAULT 0,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk filter berdasarkan status
CREATE INDEX idx_ideas_status ON ideas(status);

-- Index untuk sorting berdasarkan prioritas
CREATE INDEX idx_ideas_priority ON ideas(priority DESC);

-- ============================================
-- Table: history
-- Arsip konten yang sudah dipublikasikan
-- ============================================

CREATE TABLE IF NOT EXISTS history (
    id BIGSERIAL PRIMARY KEY,
    topic TEXT,
    angle TEXT,
    content TEXT,
    status TEXT DEFAULT 'draft',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    buffer_post_id TEXT
);

-- Index untuk pencarian berdasarkan buffer_post_id
CREATE INDEX idx_history_buffer_post_id ON history(buffer_post_id);

-- Index untuk sorting berdasarkan tanggal
CREATE INDEX idx_history_created_at ON history(created_at DESC);

-- ============================================
-- Table: metrics
-- Data performa konten
-- ============================================

CREATE TABLE IF NOT EXISTS metrics (
    id BIGSERIAL PRIMARY KEY,
    history_id BIGINT REFERENCES history(id) ON DELETE CASCADE,
    impressions INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    replies INTEGER DEFAULT 0,
    reposts INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    buffer_post_id TEXT
);

-- Index untuk join dengan history
CREATE INDEX idx_metrics_history_id ON metrics(history_id);

-- Index untuk pencarian berdasarkan buffer_post_id
CREATE INDEX idx_metrics_buffer_post_id ON metrics(buffer_post_id);

-- ============================================
-- Views untuk mempermudah query
-- ============================================

-- View: Konten dengan performa
CREATE OR REPLACE VIEW content_with_metrics AS
SELECT
    h.id,
    h.topic,
    h.angle,
    h.content,
    h.status,
    h.created_at,
    h.buffer_post_id,
    m.impressions,
    m.likes,
    m.replies,
    m.reposts,
    (m.likes + m.replies + m.reposts) as total_engagement
FROM history h
LEFT JOIN metrics m ON h.id = m.history_id
ORDER BY h.created_at DESC;

-- View: Ide yang belum digunakan
CREATE OR REPLACE VIEW pending_ideas AS
SELECT * FROM ideas
WHERE status = 'pending'
ORDER BY priority DESC, created_at ASC;

-- ============================================
-- Sample Data untuk Testing
-- ============================================

-- Sample knowledge base
INSERT INTO knowledge (category, title, content, tags) VALUES
('copywriting', 'Hook Formula', 'Gunakan pola: [Pernyataan mengejutkan] + [Kenapa penting] + [Apa yang harus dilakukan]', ARRAY['hook', 'opening', 'engagement']),
('psikologi', 'Social Proof', 'Orang cenderung mengikuti tindakan orang lain ketika tidak yakin harus melakukan apa', ARRAY['social-proof', 'trust', 'influence']),
('storytelling', 'Hero Journey Mini', 'Problem → Struggle → Discovery → Transformation → Lesson', ARRAY['story', 'narrative', 'structure']),
('strategi', 'Content Pillar', 'Fokus pada 3-5 topik utama yang saling terkait untuk membangun authority', ARRAY['pillar', 'authority', 'focus']);

-- Sample ideas
INSERT INTO ideas (topic, angle, priority, status) VALUES
('Produktivitas remote work', 'Tips praktis berdasarkan pengalaman nyata', 8, 'pending'),
('Mindset entrepreneur pemula', 'Kesalahan umum dan cara menghindarinya', 7, 'pending'),
('Personal branding tanpa spam', 'Membangun kepercayaan melalui value-first approach', 9, 'pending');

-- ============================================
-- Functions untuk automation
-- ============================================

-- Function: Get random pending idea
CREATE OR REPLACE FUNCTION get_next_idea()
RETURNS ideas AS $$
DECLARE
    selected_idea ideas%ROWTYPE;
BEGIN
    SELECT * INTO selected_idea
    FROM ideas
    WHERE status = 'pending'
    ORDER BY priority DESC, RANDOM()
    LIMIT 1;

    RETURN selected_idea;
END;
$$ LANGUAGE plpgsql;

-- Function: Mark idea as used
CREATE OR REPLACE FUNCTION mark_idea_used(idea_id BIGINT)
RETURNS VOID AS $$
BEGIN
    UPDATE ideas SET status = 'used' WHERE id = idea_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Get engagement rate
CREATE OR REPLACE FUNCTION get_engagement_rate(post_id BIGINT)
RETURNS NUMERIC AS $$
DECLARE
    total_impressions INTEGER;
    total_engagement INTEGER;
BEGIN
    SELECT impressions INTO total_impressions
    FROM metrics
    WHERE history_id = post_id;

    SELECT (likes + replies + reposts) INTO total_engagement
    FROM metrics
    WHERE history_id = post_id;

    IF total_impressions > 0 THEN
        RETURN (total_engagement::NUMERIC / total_impressions) * 100;
    ELSE
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- Comments untuk dokumentasi
-- ============================================

COMMENT ON TABLE knowledge IS 'Basis pengetahuan referensi yang menjadi acuan AI saat menyusun strategi dan menulis konten';
COMMENT ON TABLE ideas IS 'Daftar topic mentah yang menjadi kandidat untuk dibahas';
COMMENT ON TABLE history IS 'Arsip seluruh konten yang sudah digenerate dan dipublikasikan';
COMMENT ON TABLE metrics IS 'Data performa tiap konten yang sudah tayang';

COMMENT ON COLUMN knowledge.category IS 'Kategori pengetahuan: psikologi, copywriting, storytelling, strategi, dll';
COMMENT ON COLUMN knowledge.tags IS 'Array tag untuk filtering dan pencarian';
COMMENT ON COLUMN ideas.priority IS 'Prioritas ide: 1-10, semakin tinggi semakin diprioritaskan';
COMMENT ON COLUMN ideas.status IS 'Status ide: pending, used, archived';
COMMENT ON COLUMN history.status IS 'Status konten: draft, published, failed';
COMMENT ON COLUMN metrics.buffer_post_id IS 'ID post di Buffer untuk tracking';
