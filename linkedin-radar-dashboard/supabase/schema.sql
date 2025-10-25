-- ============================================================================
-- LinkedIn Content Radar - Supabase Database Schema
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: creators
-- Stores LinkedIn creator profiles we're tracking
-- ============================================================================
CREATE TABLE creators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  linkedin_url TEXT UNIQUE NOT NULL,
  full_name TEXT,
  username TEXT,
  follower_count INTEGER,
  industry TEXT,
  niche_tags TEXT[], -- ['AI', 'Automation', 'SaaS']
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'archived')),
  avg_engagement_rate DECIMAL(5,2),
  total_posts_scraped INTEGER DEFAULT 0,
  last_scraped_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_creators_status ON creators(status);
CREATE INDEX idx_creators_last_scraped ON creators(last_scraped_at DESC);
CREATE INDEX idx_creators_avg_engagement ON creators(avg_engagement_rate DESC NULLS LAST);

COMMENT ON TABLE creators IS 'LinkedIn creator profiles being tracked for content analysis';

-- ============================================================================
-- TABLE: posts
-- Individual LinkedIn posts scraped from creators
-- ============================================================================
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES creators(id) ON DELETE CASCADE,
  post_url TEXT UNIQUE NOT NULL,
  post_text TEXT NOT NULL,
  posted_date TIMESTAMP WITH TIME ZONE NOT NULL,

  -- Engagement metrics
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  reshares_count INTEGER DEFAULT 0,

  -- Content metadata
  content_type TEXT CHECK (content_type IN ('text', 'image', 'carousel', 'video', 'document')),
  media_urls TEXT[],
  hashtags TEXT[],
  word_count INTEGER,

  -- AI Scoring
  relevance_score INTEGER CHECK (relevance_score BETWEEN 1 AND 5),
  value_depth_score INTEGER CHECK (value_depth_score BETWEEN 1 AND 5),
  tone_suitable BOOLEAN,
  final_score DECIMAL(5,2), -- (relevance × 2) + (value_depth × 3), max = 25

  -- Classification
  topic_category TEXT, -- 'Automation', 'AI Trends', 'Productivity', 'Entrepreneurship'
  content_pillar TEXT CHECK (content_pillar IN ('Educational', 'Personal', 'Technical', 'Story', 'Promotional')),

  -- Lead Magnet Detection
  lead_magnet_opportunity BOOLEAN DEFAULT FALSE,
  lead_magnet_suggestion TEXT,

  -- AI analysis metadata
  ai_reasoning TEXT,
  ai_analysis_duration_ms INTEGER,

  -- Processing flags
  is_analyzed BOOLEAN DEFAULT FALSE,
  is_selected_for_generation BOOLEAN DEFAULT FALSE,

  -- Timestamps
  scraped_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  analyzed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_posts_creator ON posts(creator_id);
CREATE INDEX idx_posts_posted_date ON posts(posted_date DESC);
CREATE INDEX idx_posts_final_score ON posts(final_score DESC NULLS LAST);
CREATE INDEX idx_posts_analyzed ON posts(is_analyzed);
CREATE INDEX idx_posts_selected ON posts(is_selected_for_generation);
CREATE INDEX idx_posts_topic_category ON posts(topic_category);
CREATE INDEX idx_posts_content_pillar ON posts(content_pillar);
CREATE INDEX idx_posts_engagement ON posts((likes_count + comments_count * 2) DESC);

COMMENT ON TABLE posts IS 'LinkedIn posts scraped and analyzed by the automation';

-- ============================================================================
-- TABLE: generated_posts
-- AI-generated posts for our brand, based on top performers
-- ============================================================================
CREATE TABLE generated_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  run_id UUID REFERENCES automation_runs(id) ON DELETE CASCADE,
  original_post_id UUID REFERENCES posts(id) ON DELETE SET NULL,

  rank INTEGER CHECK (rank >= 1 AND rank <= 10), -- Top 1-10
  generated_text TEXT NOT NULL,

  -- Metadata from original inspiration
  inspiration_creator TEXT,
  inspiration_url TEXT,
  original_relevance INTEGER,
  original_value_depth INTEGER,
  original_final_score DECIMAL(5,2),

  -- Classification
  topic_category TEXT,
  content_pillar TEXT,
  lead_magnet_suggestion TEXT,

  -- Publishing workflow
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'reviewed', 'scheduled', 'published', 'archived')),
  scheduled_for TIMESTAMP WITH TIME ZONE,
  published_at TIMESTAMP WITH TIME ZONE,
  published_url TEXT,

  -- User customization
  edited_text TEXT, -- User's edited version
  internal_notes TEXT,
  custom_hashtags TEXT[],

  -- Performance tracking (after publishing)
  published_likes INTEGER,
  published_comments INTEGER,
  published_reshares INTEGER,

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_generated_posts_run ON generated_posts(run_id);
CREATE INDEX idx_generated_posts_rank ON generated_posts(rank);
CREATE INDEX idx_generated_posts_status ON generated_posts(status);
CREATE INDEX idx_generated_posts_scheduled ON generated_posts(scheduled_for) WHERE scheduled_for IS NOT NULL;
CREATE INDEX idx_generated_posts_created ON generated_posts(created_at DESC);

COMMENT ON TABLE generated_posts IS 'AI-generated LinkedIn posts ready for publishing';

-- ============================================================================
-- TABLE: automation_runs
-- Tracks each weekly automation execution
-- ============================================================================
CREATE TABLE automation_runs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Execution metadata
  status TEXT DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed', 'partial')),
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  duration_seconds INTEGER,

  -- Statistics
  creators_total INTEGER,
  creators_scraped INTEGER,
  creators_failed INTEGER,

  posts_scraped INTEGER DEFAULT 0,
  posts_filtered INTEGER DEFAULT 0,
  posts_analyzed INTEGER DEFAULT 0,
  posts_generated INTEGER DEFAULT 0,

  -- AI/API usage
  openai_calls INTEGER DEFAULT 0,
  openai_tokens_used INTEGER DEFAULT 0,
  openai_cost_usd DECIMAL(10,4) DEFAULT 0,

  apify_calls INTEGER DEFAULT 0,
  apify_credits_used INTEGER DEFAULT 0,
  apify_cost_usd DECIMAL(10,4) DEFAULT 0,

  -- Output URLs
  google_sheet_url TEXT,
  google_drive_pdf_url TEXT,
  supabase_pdf_url TEXT, -- If stored in Supabase Storage

  -- Error tracking
  errors JSONB DEFAULT '[]'::jsonb, -- [{creator: 'x', error: 'y', timestamp: 'z'}]

  -- Trigger info
  triggered_by TEXT DEFAULT 'schedule', -- 'schedule', 'manual', 'webhook'
  triggered_by_user UUID REFERENCES auth.users(id) ON DELETE SET NULL,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_runs_status ON automation_runs(status);
CREATE INDEX idx_runs_started ON automation_runs(started_at DESC);
CREATE INDEX idx_runs_completed ON automation_runs(completed_at DESC NULLS LAST);

COMMENT ON TABLE automation_runs IS 'History of automation executions with stats and errors';

-- ============================================================================
-- TABLE: analytics_daily
-- Daily aggregated analytics for dashboard charts
-- ============================================================================
CREATE TABLE analytics_daily (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE UNIQUE NOT NULL,

  -- Content metrics
  posts_scraped INTEGER DEFAULT 0,
  posts_analyzed INTEGER DEFAULT 0,
  posts_generated INTEGER DEFAULT 0,
  avg_engagement_rate DECIMAL(5,2),
  avg_final_score DECIMAL(5,2),

  -- Top topics
  top_topics JSONB, -- [{topic: 'AI Trends', count: 15}, ...]

  -- Automation metrics
  runs_completed INTEGER DEFAULT 0,
  runs_failed INTEGER DEFAULT 0,
  avg_duration_seconds INTEGER,

  -- Cost tracking
  total_openai_cost_usd DECIMAL(10,4) DEFAULT 0,
  total_apify_cost_usd DECIMAL(10,4) DEFAULT 0,
  total_cost_usd DECIMAL(10,4) DEFAULT 0,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_analytics_date ON analytics_daily(date DESC);

COMMENT ON TABLE analytics_daily IS 'Daily aggregated metrics for trend analysis';

-- ============================================================================
-- TABLE: content_strategy
-- Content pillar targets and tracking
-- ============================================================================
CREATE TABLE content_strategy (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  pillar_name TEXT UNIQUE NOT NULL,
  target_frequency INTEGER CHECK (target_frequency >= 0), -- Posts per week
  current_count INTEGER DEFAULT 0,

  -- UI display
  color_code TEXT NOT NULL, -- Hex color for charts
  icon_name TEXT, -- Lucide icon name
  description TEXT,

  -- Tracking
  last_post_date DATE,

  is_active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_content_strategy_active ON content_strategy(is_active);

COMMENT ON TABLE content_strategy IS 'Content pillar strategy configuration and tracking';

-- Insert default pillars
INSERT INTO content_strategy (pillar_name, target_frequency, color_code, icon_name, description) VALUES
  ('Educational', 2, '#8B5CF6', 'GraduationCap', 'How-to guides, tutorials, and learning resources'),
  ('Personal', 1, '#EC4899', 'Heart', 'Personal stories, experiences, and insights'),
  ('Technical', 2, '#06B6D4', 'Code', 'Deep technical content, case studies, and implementations'),
  ('Story', 1, '#F59E0B', 'BookOpen', 'Narrative posts, customer stories, and journeys'),
  ('Promotional', 1, '#10B981', 'Megaphone', 'Product updates, offers, and announcements');

-- ============================================================================
-- TABLE: user_preferences
-- User/team settings and configurations
-- ============================================================================
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Brand voice
  brand_name TEXT,
  brand_voice_description TEXT,
  tone_preferences TEXT[] DEFAULT ARRAY['professional', 'conversational'],
  avoid_words TEXT[] DEFAULT ARRAY[]::TEXT[],
  preferred_hashtags TEXT[] DEFAULT ARRAY[]::TEXT[],

  -- Content settings
  min_engagement_threshold INTEGER DEFAULT 100,
  days_to_scan INTEGER DEFAULT 7 CHECK (days_to_scan >= 1 AND days_to_scan <= 30),
  posts_to_generate INTEGER DEFAULT 7 CHECK (posts_to_generate >= 1 AND posts_to_generate <= 20),

  -- Scheduling preferences
  timezone TEXT DEFAULT 'Europe/Paris',
  preferred_posting_days TEXT[] DEFAULT ARRAY['Monday', 'Wednesday', 'Friday'],
  preferred_posting_times TIME[] DEFAULT ARRAY['09:00:00', '14:00:00', '17:00:00'],

  -- Notifications
  slack_webhook_url TEXT,
  discord_webhook_url TEXT,
  email_notifications BOOLEAN DEFAULT TRUE,
  notification_frequency TEXT DEFAULT 'weekly' CHECK (notification_frequency IN ('realtime', 'daily', 'weekly')),

  -- Dashboard preferences
  default_dashboard_view TEXT DEFAULT 'overview',
  dark_mode BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(user_id)
);

CREATE INDEX idx_user_preferences_user ON user_preferences(user_id);

COMMENT ON TABLE user_preferences IS 'User/team preferences and configuration';

-- ============================================================================
-- TABLE: webhook_logs
-- Logs incoming webhooks from n8n
-- ============================================================================
CREATE TABLE webhook_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  event_type TEXT NOT NULL, -- 'run_started', 'posts_scraped', 'analysis_complete', etc.
  payload JSONB NOT NULL,

  run_id UUID REFERENCES automation_runs(id) ON DELETE SET NULL,

  status TEXT DEFAULT 'received' CHECK (status IN ('received', 'processed', 'failed')),
  error_message TEXT,

  received_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  processed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_webhook_logs_event ON webhook_logs(event_type);
CREATE INDEX idx_webhook_logs_run ON webhook_logs(run_id);
CREATE INDEX idx_webhook_logs_received ON webhook_logs(received_at DESC);

COMMENT ON TABLE webhook_logs IS 'Audit log of all incoming webhooks from n8n automation';

-- ============================================================================
-- FUNCTIONS: Auto-update timestamps
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to relevant tables
CREATE TRIGGER update_creators_updated_at BEFORE UPDATE ON creators
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_generated_posts_updated_at BEFORE UPDATE ON generated_posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_content_strategy_updated_at BEFORE UPDATE ON content_strategy
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_preferences_updated_at BEFORE UPDATE ON user_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_analytics_daily_updated_at BEFORE UPDATE ON analytics_daily
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- FUNCTIONS: Analytics aggregation
-- ============================================================================

-- Function to aggregate daily analytics
CREATE OR REPLACE FUNCTION aggregate_daily_analytics(target_date DATE)
RETURNS void AS $$
DECLARE
  v_posts_scraped INTEGER;
  v_posts_analyzed INTEGER;
  v_posts_generated INTEGER;
  v_avg_engagement DECIMAL(5,2);
  v_avg_score DECIMAL(5,2);
  v_runs_completed INTEGER;
  v_runs_failed INTEGER;
  v_avg_duration INTEGER;
  v_openai_cost DECIMAL(10,4);
  v_apify_cost DECIMAL(10,4);
BEGIN
  -- Count posts scraped on target date
  SELECT COUNT(*) INTO v_posts_scraped
  FROM posts
  WHERE DATE(scraped_at) = target_date;

  -- Count analyzed posts
  SELECT COUNT(*) INTO v_posts_analyzed
  FROM posts
  WHERE DATE(analyzed_at) = target_date AND is_analyzed = TRUE;

  -- Count generated posts
  SELECT COUNT(*) INTO v_posts_generated
  FROM generated_posts
  WHERE DATE(created_at) = target_date;

  -- Calculate average engagement rate
  SELECT AVG(likes_count + comments_count)::DECIMAL(5,2) INTO v_avg_engagement
  FROM posts
  WHERE DATE(scraped_at) = target_date;

  -- Calculate average final score
  SELECT AVG(final_score)::DECIMAL(5,2) INTO v_avg_score
  FROM posts
  WHERE DATE(analyzed_at) = target_date AND is_analyzed = TRUE;

  -- Count completed/failed runs
  SELECT
    COUNT(*) FILTER (WHERE status = 'completed'),
    COUNT(*) FILTER (WHERE status = 'failed')
  INTO v_runs_completed, v_runs_failed
  FROM automation_runs
  WHERE DATE(started_at) = target_date;

  -- Average duration
  SELECT AVG(duration_seconds)::INTEGER INTO v_avg_duration
  FROM automation_runs
  WHERE DATE(started_at) = target_date AND status = 'completed';

  -- Sum costs
  SELECT
    COALESCE(SUM(openai_cost_usd), 0),
    COALESCE(SUM(apify_cost_usd), 0)
  INTO v_openai_cost, v_apify_cost
  FROM automation_runs
  WHERE DATE(started_at) = target_date;

  -- Insert or update analytics record
  INSERT INTO analytics_daily (
    date,
    posts_scraped,
    posts_analyzed,
    posts_generated,
    avg_engagement_rate,
    avg_final_score,
    runs_completed,
    runs_failed,
    avg_duration_seconds,
    total_openai_cost_usd,
    total_apify_cost_usd,
    total_cost_usd
  ) VALUES (
    target_date,
    COALESCE(v_posts_scraped, 0),
    COALESCE(v_posts_analyzed, 0),
    COALESCE(v_posts_generated, 0),
    v_avg_engagement,
    v_avg_score,
    COALESCE(v_runs_completed, 0),
    COALESCE(v_runs_failed, 0),
    v_avg_duration,
    v_openai_cost,
    v_apify_cost,
    v_openai_cost + v_apify_cost
  )
  ON CONFLICT (date) DO UPDATE SET
    posts_scraped = EXCLUDED.posts_scraped,
    posts_analyzed = EXCLUDED.posts_analyzed,
    posts_generated = EXCLUDED.posts_generated,
    avg_engagement_rate = EXCLUDED.avg_engagement_rate,
    avg_final_score = EXCLUDED.avg_final_score,
    runs_completed = EXCLUDED.runs_completed,
    runs_failed = EXCLUDED.runs_failed,
    avg_duration_seconds = EXCLUDED.avg_duration_seconds,
    total_openai_cost_usd = EXCLUDED.total_openai_cost_usd,
    total_apify_cost_usd = EXCLUDED.total_apify_cost_usd,
    total_cost_usd = EXCLUDED.total_cost_usd,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE creators ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE generated_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE automation_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_daily ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_strategy ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE webhook_logs ENABLE ROW LEVEL SECURITY;

-- For now, allow authenticated users to read all data
-- (Adjust these policies based on multi-tenancy requirements)

CREATE POLICY "Allow authenticated users to read creators"
  ON creators FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to manage creators"
  ON creators FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to read posts"
  ON posts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to read generated posts"
  ON generated_posts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to manage generated posts"
  ON generated_posts FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow authenticated users to read runs"
  ON automation_runs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to read analytics"
  ON analytics_daily FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to read content strategy"
  ON content_strategy FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Allow authenticated users to manage content strategy"
  ON content_strategy FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow users to read their own preferences"
  ON user_preferences FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Allow users to manage their own preferences"
  ON user_preferences FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow authenticated users to read webhook logs"
  ON webhook_logs FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================================
-- VIEWS: Convenient data access
-- ============================================================================

-- View: Top performing posts across all time
CREATE OR REPLACE VIEW v_top_posts AS
SELECT
  p.*,
  c.full_name AS creator_name,
  c.username AS creator_username,
  c.follower_count AS creator_followers,
  (p.likes_count + p.comments_count * 2) AS engagement_score
FROM posts p
LEFT JOIN creators c ON p.creator_id = c.id
WHERE p.is_analyzed = TRUE
ORDER BY p.final_score DESC NULLS LAST, engagement_score DESC
LIMIT 100;

-- View: Weekly statistics
CREATE OR REPLACE VIEW v_weekly_stats AS
SELECT
  DATE_TRUNC('week', scraped_at) AS week_start,
  COUNT(*) AS total_posts,
  COUNT(*) FILTER (WHERE is_analyzed = TRUE) AS analyzed_posts,
  AVG(final_score) FILTER (WHERE is_analyzed = TRUE) AS avg_score,
  AVG(likes_count) AS avg_likes,
  AVG(comments_count) AS avg_comments
FROM posts
GROUP BY DATE_TRUNC('week', scraped_at)
ORDER BY week_start DESC;

-- View: Creator performance summary
CREATE OR REPLACE VIEW v_creator_performance AS
SELECT
  c.id,
  c.full_name,
  c.username,
  c.linkedin_url,
  c.status,
  COUNT(p.id) AS total_posts_scraped,
  COUNT(p.id) FILTER (WHERE p.is_analyzed = TRUE) AS posts_analyzed,
  COUNT(p.id) FILTER (WHERE p.is_selected_for_generation = TRUE) AS posts_selected,
  AVG(p.final_score) FILTER (WHERE p.is_analyzed = TRUE) AS avg_final_score,
  AVG(p.likes_count) AS avg_likes,
  AVG(p.comments_count) AS avg_comments,
  MAX(p.scraped_at) AS last_post_date
FROM creators c
LEFT JOIN posts p ON c.id = p.creator_id
GROUP BY c.id
ORDER BY avg_final_score DESC NULLS LAST;

-- View: Recent automation runs with stats
CREATE OR REPLACE VIEW v_recent_runs AS
SELECT
  r.id,
  r.status,
  r.started_at,
  r.completed_at,
  r.duration_seconds,
  r.creators_scraped,
  r.posts_analyzed,
  r.posts_generated,
  r.openai_cost_usd,
  r.apify_cost_usd,
  (r.openai_cost_usd + r.apify_cost_usd) AS total_cost,
  COUNT(gp.id) AS generated_posts_count
FROM automation_runs r
LEFT JOIN generated_posts gp ON r.id = gp.run_id
GROUP BY r.id
ORDER BY r.started_at DESC
LIMIT 50;

-- ============================================================================
-- SAMPLE DATA (for development/testing)
-- ============================================================================

-- Insert the 25 confirmed creators
INSERT INTO creators (linkedin_url, full_name, username, status) VALUES
  ('https://www.linkedin.com/in/agrim-goyal', 'Agrim Goyal', 'agrim-goyal', 'active'),
  ('https://www.linkedin.com/in/jessievanbreugel', 'Jessie van Breugel', 'jessievanbreugel', 'active'),
  ('https://www.linkedin.com/in/domingo-valadez', 'Domingo Valadez', 'domingo-valadez', 'active'),
  ('https://www.linkedin.com/in/arthur-morin-girard-824294357', 'Arthur Morin-Girard', 'arthur-morin-girard-824294357', 'active'),
  ('https://www.linkedin.com/in/leadgenwiz', 'Lead Gen Wiz', 'leadgenwiz', 'active'),
  ('https://www.linkedin.com/in/antonyslumbers', 'Antony Slumbers', 'antonyslumbers', 'active'),
  ('https://www.linkedin.com/in/ottotatton', 'Otto Tatton', 'ottotatton', 'active'),
  ('https://www.linkedin.com/in/nielsklement', 'Niels Klement', 'nielsklement', 'active'),
  ('https://www.linkedin.com/in/jonathan-peslar', 'Jonathan Peslar', 'jonathan-peslar', 'active'),
  ('https://www.linkedin.com/in/nicholas-puruczky-113818198', 'Nicholas Puruczky', 'nicholas-puruczky-113818198', 'active'),
  ('https://www.linkedin.com/in/brandonpassley', 'Brandon Passley', 'brandonpassley', 'active'),
  ('https://www.linkedin.com/in/mattlakajev', 'Matt Lakajev', 'mattlakajev', 'active'),
  ('https://www.linkedin.com/in/duncanrogoff', 'Duncan Rogoff', 'duncanrogoff', 'active'),
  ('https://www.linkedin.com/in/teddy-james', 'Teddy James', 'teddy-james', 'active'),
  ('https://www.linkedin.com/in/jason-ratcliff-8a416014b', 'Jason Ratcliff', 'jason-ratcliff-8a416014b', 'active'),
  ('https://www.linkedin.com/in/matt-yellin', 'Matt Yellin', 'matt-yellin', 'active'),
  ('https://www.linkedin.com/in/jakeheller1', 'Jake Heller', 'jakeheller1', 'active'),
  ('https://www.linkedin.com/in/jaindl', 'Josef Aindl', 'jaindl', 'active'),
  ('https://www.linkedin.com/in/tomos-ormsby-63592134b', 'Tomos Ormsby', 'tomos-ormsby-63592134b', 'active'),
  ('https://www.linkedin.com/in/toprealestateappraiser', 'Top Real Estate Appraiser', 'toprealestateappraiser', 'active'),
  ('https://www.linkedin.com/in/santosh-srinivas-n0c0de', 'Santosh Srinivas', 'santosh-srinivas-n0c0de', 'active'),
  ('https://www.linkedin.com/in/michel-lieben', 'Michel Lieben', 'michel-lieben', 'active'),
  ('https://www.linkedin.com/in/ivanfalco', 'Ivan Falco', 'ivanfalco', 'active'),
  ('https://www.linkedin.com/in/alex-vacca', 'Alex Vacca', 'alex-vacca', 'active'),
  ('https://www.linkedin.com/in/grycz-monika', 'Monika Grycz', 'grycz-monika', 'active')
ON CONFLICT (linkedin_url) DO NOTHING;

-- ============================================================================
-- GRANTS (for Supabase service role)
-- ============================================================================

GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
