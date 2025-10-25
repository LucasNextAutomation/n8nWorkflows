# 🏗️ LinkedIn Content Radar - Complete SaaS Architecture

## 📊 System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    USER INTERFACE (Next.js)                  │
│  /dashboard  /radar  /knowledge  /calendar  /logs           │
└───────────────────────┬─────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              API LAYER (Next.js App Router)                  │
│  /api/creators  /api/posts  /api/runs  /api/webhook         │
└───────────────────────┬─────────────────────────────────────┘
                        │
            ┌───────────┴───────────┐
            ▼                       ▼
┌─────────────────────┐  ┌─────────────────────┐
│   SUPABASE (DB)     │  │   n8n AUTOMATION    │
│  - Postgres DB      │  │  - Weekly scraping  │
│  - Auth             │  │  - AI analysis      │
│  - Storage          │  │  - Post generation  │
│  - Real-time subs   │  │  - Webhook output   │
└─────────────────────┘  └─────────────────────┘
            │                       │
            └───────────┬───────────┘
                        ▼
┌─────────────────────────────────────────────────────────────┐
│              EXTERNAL SERVICES                               │
│  Apify → OpenAI → Google Sheets → Google Drive             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🎯 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Next.js 14 (App Router) | React framework with SSR |
| **Styling** | Tailwind CSS + shadcn/ui | Scripe-inspired dark theme |
| **Database** | Supabase (Postgres) | Data persistence |
| **Auth** | Supabase Auth | User authentication |
| **Storage** | Supabase Storage | PDF/media storage |
| **Real-time** | Supabase Realtime | Live updates |
| **Automation** | n8n (Docker) | Backend workflow engine |
| **AI** | OpenAI GPT-4 | Analysis & generation |
| **Scraping** | Apify | LinkedIn data collection |
| **Deployment** | Vercel | Frontend hosting |
| **Analytics** | Vercel Analytics | Usage tracking |

---

## 🗄️ Database Schema (Supabase)

### Tables

#### 1. **creators**
```sql
CREATE TABLE creators (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  linkedin_url TEXT UNIQUE NOT NULL,
  full_name TEXT,
  username TEXT,
  follower_count INTEGER,
  industry TEXT,
  niche_tags TEXT[], -- ['AI', 'Automation', 'SaaS']
  status TEXT DEFAULT 'active', -- 'active', 'paused', 'archived'
  avg_engagement_rate DECIMAL(5,2),
  last_scraped_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_creators_status ON creators(status);
CREATE INDEX idx_creators_last_scraped ON creators(last_scraped_at);
```

#### 2. **posts**
```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  creator_id UUID REFERENCES creators(id) ON DELETE CASCADE,
  post_url TEXT UNIQUE NOT NULL,
  post_text TEXT NOT NULL,
  posted_date TIMESTAMP WITH TIME ZONE NOT NULL,
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  reshares_count INTEGER DEFAULT 0,
  content_type TEXT, -- 'text', 'image', 'carousel', 'video'
  media_urls TEXT[],

  -- AI Scoring
  relevance_score INTEGER, -- 1-5
  value_depth_score INTEGER, -- 1-5
  tone_suitable BOOLEAN,
  final_score DECIMAL(5,2), -- (relevance × 2) + (value_depth × 3)

  -- Classification
  topic_category TEXT, -- 'Automation', 'AI Trends', 'Productivity', etc.
  content_pillar TEXT, -- 'Educational', 'Personal', 'Technical', 'Story'

  -- Lead Magnet
  lead_magnet_opportunity BOOLEAN DEFAULT FALSE,
  lead_magnet_suggestion TEXT,

  ai_reasoning TEXT,

  -- Metadata
  is_analyzed BOOLEAN DEFAULT FALSE,
  is_selected_for_generation BOOLEAN DEFAULT FALSE,
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
```

#### 3. **generated_posts**
```sql
CREATE TABLE generated_posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  run_id UUID REFERENCES automation_runs(id) ON DELETE CASCADE,
  original_post_id UUID REFERENCES posts(id),

  rank INTEGER, -- 1-7
  generated_text TEXT NOT NULL,

  -- Metadata from original
  inspiration_creator TEXT,
  inspiration_url TEXT,
  original_relevance INTEGER,
  original_value_depth INTEGER,
  original_final_score DECIMAL(5,2),

  topic_category TEXT,
  content_pillar TEXT,
  lead_magnet_suggestion TEXT,

  -- Publishing
  status TEXT DEFAULT 'draft', -- 'draft', 'scheduled', 'published', 'archived'
  scheduled_for TIMESTAMP WITH TIME ZONE,
  published_at TIMESTAMP WITH TIME ZONE,

  -- User edits
  edited_text TEXT,
  notes TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_generated_posts_run ON generated_posts(run_id);
CREATE INDEX idx_generated_posts_rank ON generated_posts(rank);
CREATE INDEX idx_generated_posts_status ON generated_posts(status);
CREATE INDEX idx_generated_posts_scheduled ON generated_posts(scheduled_for);
```

#### 4. **automation_runs**
```sql
CREATE TABLE automation_runs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  -- Execution metadata
  status TEXT DEFAULT 'running', -- 'running', 'completed', 'failed', 'partial'
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  duration_seconds INTEGER,

  -- Statistics
  creators_total INTEGER,
  creators_scraped INTEGER,
  creators_failed INTEGER,
  posts_scraped INTEGER,
  posts_filtered INTEGER,
  posts_analyzed INTEGER,
  posts_generated INTEGER,

  -- API usage
  openai_calls INTEGER DEFAULT 0,
  openai_tokens_used INTEGER DEFAULT 0,
  openai_cost_usd DECIMAL(10,4) DEFAULT 0,
  apify_credits_used INTEGER DEFAULT 0,

  -- Outputs
  google_sheet_url TEXT,
  google_drive_pdf_url TEXT,

  -- Error tracking
  errors JSONB, -- [{creator: 'x', error: 'y', timestamp: 'z'}]

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_runs_status ON automation_runs(status);
CREATE INDEX idx_runs_started ON automation_runs(started_at DESC);
```

#### 5. **analytics_daily**
```sql
CREATE TABLE analytics_daily (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  date DATE UNIQUE NOT NULL,

  -- Content metrics
  posts_scraped INTEGER DEFAULT 0,
  posts_analyzed INTEGER DEFAULT 0,
  posts_generated INTEGER DEFAULT 0,
  avg_engagement_rate DECIMAL(5,2),
  avg_final_score DECIMAL(5,2),

  -- Automation metrics
  runs_completed INTEGER DEFAULT 0,
  runs_failed INTEGER DEFAULT 0,
  avg_duration_seconds INTEGER,

  -- Cost tracking
  total_openai_cost_usd DECIMAL(10,4) DEFAULT 0,
  total_apify_credits INTEGER DEFAULT 0,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_analytics_date ON analytics_daily(date DESC);
```

#### 6. **content_strategy**
```sql
CREATE TABLE content_strategy (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),

  pillar_name TEXT NOT NULL, -- 'Educational', 'Personal', 'Technical', 'Story'
  target_frequency INTEGER, -- Posts per week
  current_count INTEGER DEFAULT 0,
  color_code TEXT, -- For UI display
  description TEXT,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### 7. **user_preferences**
```sql
CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),

  -- Brand voice
  brand_voice_description TEXT,
  tone_preferences TEXT[], -- ['professional', 'conversational', 'technical']
  avoid_words TEXT[],
  preferred_hashtags TEXT[],

  -- Content settings
  min_engagement_threshold INTEGER DEFAULT 100,
  days_to_scan INTEGER DEFAULT 7,
  posts_to_generate INTEGER DEFAULT 7,

  -- Scheduling
  timezone TEXT DEFAULT 'Europe/Paris',
  preferred_posting_days TEXT[], -- ['Monday', 'Wednesday', 'Friday']
  preferred_posting_times TIME[],

  -- Notifications
  slack_webhook_url TEXT,
  discord_webhook_url TEXT,
  email_notifications BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 🔌 API Endpoints

### Next.js App Router API Routes

```
/app/api/
├── creators/
│   ├── route.ts              # GET (list), POST (create)
│   └── [id]/
│       └── route.ts          # GET, PATCH, DELETE
│
├── posts/
│   ├── route.ts              # GET (list with filters)
│   ├── [id]/route.ts         # GET, PATCH, DELETE
│   └── top/route.ts          # GET top scored posts
│
├── generated/
│   ├── route.ts              # GET, POST
│   └── [id]/
│       ├── route.ts          # GET, PATCH, DELETE
│       └── publish/route.ts  # POST (mark as published)
│
├── runs/
│   ├── route.ts              # GET (list runs)
│   └── [id]/
│       └── route.ts          # GET run details
│
├── analytics/
│   ├── overview/route.ts     # GET dashboard stats
│   ├── trends/route.ts       # GET time-series data
│   └── costs/route.ts        # GET cost breakdown
│
├── webhook/
│   ├── n8n/route.ts          # POST (receive n8n data)
│   └── trigger/route.ts      # POST (manually trigger automation)
│
└── export/
    ├── pdf/route.ts          # GET (generate PDF report)
    └── csv/route.ts          # GET (export data)
```

---

## 📱 Frontend Pages

### App Router Structure

```
/app/
├── (auth)/
│   ├── login/page.tsx
│   └── signup/page.tsx
│
├── (dashboard)/
│   ├── layout.tsx              # Main dashboard layout with sidebar
│   │
│   ├── page.tsx                # /dashboard - Home view
│   │
│   ├── radar/
│   │   └── page.tsx            # /radar - Post analysis results
│   │
│   ├── knowledge/
│   │   └── page.tsx            # /knowledge - Creators management
│   │
│   ├── calendar/
│   │   └── page.tsx            # /calendar - Content scheduling
│   │
│   ├── logs/
│   │   └── page.tsx            # /logs - Automation monitoring
│   │
│   └── settings/
│       └── page.tsx            # /settings - User preferences
│
└── api/                        # API routes (see above)
```

---

## 🎨 UI Component Library

### Core Components (Scripe-inspired)

```
/components/
├── ui/                         # shadcn/ui base components
│   ├── button.tsx
│   ├── card.tsx
│   ├── dialog.tsx
│   ├── dropdown-menu.tsx
│   ├── input.tsx
│   ├── select.tsx
│   ├── table.tsx
│   └── ...
│
├── dashboard/
│   ├── PerformanceSnapshot.tsx      # Metrics widgets
│   ├── ContentStrategyTracker.tsx   # Pillar chart
│   ├── WeeklySuggestions.tsx        # Post preview cards
│   ├── WeeklyCalendar.tsx           # Calendar grid
│   └── KnowledgeBaseStatus.tsx      # Upload status meter
│
├── radar/
│   ├── PostCard.tsx                 # Individual post display
│   ├── PostFilters.tsx              # Filter controls
│   ├── ScoreVisualization.tsx       # Score charts
│   └── TopicDistribution.tsx        # Category breakdown
│
├── knowledge/
│   ├── CreatorList.tsx              # Creator table
│   ├── CreatorCard.tsx              # Creator detail card
│   ├── AddCreatorDialog.tsx         # Add new creator
│   └── CreatorStats.tsx             # Per-creator analytics
│
├── calendar/
│   ├── CalendarGrid.tsx             # Weekly/monthly view
│   ├── PostSlot.tsx                 # Individual calendar slot
│   └── SchedulingPanel.tsx          # Drag-drop scheduling
│
├── logs/
│   ├── RunsTable.tsx                # Automation run history
│   ├── RunDetails.tsx               # Detailed run view
│   ├── ErrorLog.tsx                 # Error display
│   └── ApiUsageChart.tsx            # Cost tracking
│
└── shared/
    ├── Sidebar.tsx                  # Main navigation
    ├── Header.tsx                   # Top bar with search
    ├── AssistantChat.tsx            # "Ask the Radar" AI chat
    ├── LoadingStates.tsx            # Skeleton loaders
    └── EmptyStates.tsx              # Empty state illustrations
```

---

## 🔄 n8n → Supabase Integration Flow

### Workflow Enhancement

Add webhook nodes to existing n8n workflow:

```
n8n Workflow:
├── [Existing nodes...]
├──
└── New Webhook Nodes:
    ├── "Webhook: Run Started"      → POST /api/webhook/n8n (status: started)
    ├── "Webhook: Posts Scraped"    → POST /api/webhook/n8n (posts data)
    ├── "Webhook: Analysis Complete"→ POST /api/webhook/n8n (scores)
    ├── "Webhook: Generation Done"  → POST /api/webhook/n8n (generated posts)
    └── "Webhook: Run Complete"     → POST /api/webhook/n8n (status: completed)
```

### Webhook Payload Examples

**Run Started:**
```json
{
  "event": "run_started",
  "run_id": "uuid",
  "timestamp": "2025-10-25T14:00:00Z",
  "creators_count": 25
}
```

**Posts Scraped:**
```json
{
  "event": "posts_scraped",
  "run_id": "uuid",
  "posts": [{
    "creator_id": "uuid",
    "post_url": "...",
    "post_text": "...",
    "likes_count": 150,
    "comments_count": 12,
    "posted_date": "2025-10-20T10:30:00Z"
  }]
}
```

**Analysis Complete:**
```json
{
  "event": "analysis_complete",
  "run_id": "uuid",
  "analyzed_posts": [{
    "post_id": "uuid",
    "relevance_score": 4,
    "value_depth_score": 5,
    "final_score": 23,
    "topic_category": "AI Trends",
    "lead_magnet_opportunity": true
  }]
}
```

---

## 🎯 Key Features by Page

### 1. Dashboard (`/dashboard`)

**Performance Snapshot**
- Active creators count
- Total posts analyzed (this week)
- Average engagement rate
- Posts generated count
- Trend charts (7-day, 30-day)

**Content Strategy Tracker**
- Ring/pie chart by content pillar
- Target vs actual frequency
- Auto-calculated from generated posts

**Knowledge Base Status**
- % completeness meter
- Total creators, posts analyzed
- Last update timestamp

**Weekly Suggestions**
- Top 7 generated posts as preview cards
- "Copy to clipboard" button
- "Open in editor" link
- Filter by pillar/category

**Mini Calendar**
- Current week view with scheduled posts
- Color-coded by pillar
- Quick jump to full calendar

---

### 2. Radar (`/radar`)

**Filters**
- Date range picker
- Score threshold slider
- Creator multi-select
- Topic category filter
- Content type (text/carousel/video)

**Post Grid/List**
- Card view with:
  - Original post preview
  - Creator name + avatar
  - Engagement metrics
  - AI scores (badges)
  - "View details" → modal with full analysis

**Top Posts Section**
- Top 15 posts (selected for generation)
- Compare scores side-by-side
- Export as CSV/PDF

**Analytics Panel**
- Topic distribution chart
- Average scores by creator
- Engagement vs score correlation

---

### 3. Knowledge Base (`/knowledge`)

**Creator Management**
- Table view with columns:
  - Name, URL, Industry, Status
  - Avg Engagement, Last Scraped
  - Actions (Edit, Pause, Archive)
- "Add Creator" button → dialog
- Bulk import from CSV

**Creator Details Modal**
- Profile info
- Historical posts (mini-list)
- Engagement trends (chart)
- Top performing posts from this creator

**Upload Section**
- Upload additional training data (brand voice docs)
- Link to Google Drive folder for reference materials

---

### 4. Calendar (`/calendar`)

**Weekly/Monthly Toggle**

**Calendar Grid**
- Drag-and-drop post slots
- Color-coded by pillar
- Time slots (based on user preferences)

**Scheduling Panel**
- List of unscheduled generated posts
- Drag to calendar slot to schedule
- Auto-suggests best times

**Settings**
- Timezone selector
- Preferred posting days
- Preferred times
- Auto-schedule toggle

**Export Options**
- Export to LinkedIn Scheduler CSV
- Export to Buffer/Hootsuite format

---

### 5. Logs (`/logs`)

**Run History Table**
- Date/time, Duration, Status
- Posts scraped/analyzed/generated
- API costs (OpenAI + Apify)
- Actions (View details, Re-run)

**Run Details View**
- Full execution timeline
- Success/error breakdown by creator
- API call logs
- Output links (Google Sheet, Drive PDF)

**Error Monitoring**
- Failed creators list with reasons
- Retry options
- Alert configuration

**Cost Tracking**
- Daily/weekly/monthly totals
- Cost per post generated
- Budget alerts

---

## 🚀 Deployment Architecture

### Development
```
Local:
├── Next.js dev server (localhost:3000)
├── Supabase local (Docker)
└── n8n (Docker: localhost:5678)
```

### Production
```
Production:
├── Frontend: Vercel (auto-deploy from GitHub)
├── Database: Supabase Cloud
├── Automation: n8n (DigitalOcean Droplet or Railway)
└── Storage: Supabase Storage + Google Drive
```

---

## 🔐 Authentication Flow

1. User visits app → redirected to `/login`
2. Supabase Auth (email/password or OAuth)
3. JWT stored in cookie
4. Protected routes check auth in middleware
5. RLS policies on Supabase tables

---

## 📊 Real-time Features

**Live Automation Status**
- Subscribe to `automation_runs` table
- Show progress bar when run is active
- Update stats in real-time

**Collaboration (Future)**
- Multi-user editing of generated posts
- Comments on posts
- Team notifications

---

## 🎨 Design System (Scripe-inspired)

**Colors**
```css
--background: 0 0% 4%;           /* Very dark gray */
--foreground: 0 0% 98%;          /* Near white */
--primary: 262 83% 58%;          /* Purple (Scripe accent) */
--primary-foreground: 0 0% 100%;
--muted: 0 0% 15%;               /* Dark gray */
--accent: 262 83% 58%;           /* Purple */
--destructive: 0 84% 60%;        /* Red */
--border: 0 0% 20%;              /* Gray border */
--card: 0 0% 7%;                 /* Slightly lighter than bg */
```

**Typography**
- Font: Inter (Scripe uses Inter)
- Headings: Bold, gradient text on important titles
- Body: Regular, high contrast

**Components**
- Rounded corners (8px default)
- Subtle shadows on cards
- Gradient backgrounds on CTAs
- Animated progress rings
- Smooth transitions (200ms)

---

## 📦 Dependencies

```json
{
  "dependencies": {
    "next": "^14.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "@supabase/supabase-js": "^2.39.0",
    "@supabase/auth-helpers-nextjs": "^0.9.0",
    "tailwindcss": "^3.4.0",
    "@radix-ui/react-*": "latest",
    "lucide-react": "^0.320.0",
    "recharts": "^2.10.0",
    "date-fns": "^3.3.0",
    "react-hook-form": "^7.49.0",
    "zod": "^3.22.0",
    "@tanstack/react-query": "^5.17.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.0"
  },
  "devDependencies": {
    "typescript": "^5.3.3",
    "@types/node": "^20.11.0",
    "@types/react": "^18.2.48",
    "prettier": "^3.2.0",
    "eslint": "^8.56.0",
    "eslint-config-next": "^14.1.0"
  }
}
```

---

## 🔄 Data Flow Summary

```
User → Dashboard UI
         ↓
    API Routes (Next.js)
         ↓
    Supabase (Read/Write)
         ↑
    n8n Automation (Weekly)
         ↓
    Webhook → API → Supabase
         ↓
    Real-time subscription → UI update
```

---

## 📈 Performance Optimizations

1. **Server Components**: Use RSC for static content
2. **Edge Functions**: Deploy API routes to Edge
3. **Caching**: SWR for client-side caching
4. **Database Indexes**: See schema above
5. **Image Optimization**: Next.js Image component
6. **Lazy Loading**: Code splitting per page
7. **Supabase RLS**: Row-level security for data isolation

---

## 🎯 Success Metrics

**User Experience**
- Page load < 2s
- Time to interactive < 3s
- Zero layout shift

**Automation Reliability**
- 95%+ success rate
- < 5% API errors
- Execution time: 30-45 min

**Data Accuracy**
- 100% webhook delivery
- Real-time updates < 1s delay
- No data loss

---

This architecture provides a complete, production-ready foundation for your LinkedIn Content Radar SaaS dashboard. Next, I'll create the actual code structure with all components, pages, and configurations.
