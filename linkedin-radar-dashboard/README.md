# 🧠 LinkedIn Content Radar - SaaS Dashboard

**AI-Powered Weekly LinkedIn Competitive Content Intelligence Platform**

A full-stack Next.js 14 application that combines n8n automation with a Scripe-inspired dashboard to analyze LinkedIn content, score posts with AI, and generate data-driven content for your brand.

---

## 🎯 Features

### 📊 Dashboard Overview
- **Performance Snapshot** - Real-time metrics on creators, posts, and engagement
- **Content Strategy Tracker** - Visual pillar tracking with target vs actual frequency
- **Knowledge Base Status** - System learning completeness with progress rings
- **Weekly Suggestions** - AI-generated post ideas based on top performers
- **Last Run Status** - Automation execution history and health

### 🔍 Radar View
- Filter and explore all analyzed posts
- View AI scores, engagement metrics, and topic categories
- Drill into individual post details
- Export top posts as CSV/PDF

### 📚 Knowledge Base
- Manage 25+ tracked LinkedIn creators
- View creator performance analytics
- Add/edit/pause creators
- Upload brand voice training materials

### 📅 Calendar
- Visual weekly/monthly post scheduling
- Drag-and-drop post assignment
- Color-coded by content pillar
- Export to LinkedIn Scheduler

### 📈 Logs & Analytics
- Automation run history with detailed stats
- API usage and cost tracking
- Error monitoring and retry options
- Daily/weekly/monthly analytics charts

---

## 🏗️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Next.js 14 (App Router) |
| **Language** | TypeScript |
| **Styling** | Tailwind CSS + shadcn/ui |
| **Database** | Supabase (Postgres) |
| **Auth** | Supabase Auth |
| **Storage** | Supabase Storage |
| **State** | TanStack Query (React Query) |
| **Automation** | n8n (external) |
| **AI** | OpenAI GPT-4 |
| **Deployment** | Vercel |

---

## 🚀 Quick Start

### Prerequisites

- Node.js 18+ and npm 9+
- Supabase account ([app.supabase.com](https://app.supabase.com))
- n8n instance (self-hosted or cloud)
- OpenAI API key (for AI chat assistant)

### 1. Clone and Install

```bash
# Clone the repository
cd linkedin-radar-dashboard

# Install dependencies
npm install
```

### 2. Set Up Supabase

#### Create a New Project

1. Go to [app.supabase.com](https://app.supabase.com)
2. Create a new project
3. Wait for database provisioning (~2 minutes)

#### Run Database Migration

1. Copy the SQL from `supabase/schema.sql`
2. Go to Supabase Dashboard → SQL Editor
3. Paste and run the entire SQL script
4. Verify tables are created in Table Editor

### 3. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env.local

# Edit .env.local with your credentials
```

Required variables:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Authentication
NEXTAUTH_SECRET=your-random-secret-min-32-chars
NEXTAUTH_URL=http://localhost:3000

# n8n
N8N_WEBHOOK_URL=https://your-n8n-instance.com/webhook
WEBHOOK_SECRET=your-webhook-secret

# OpenAI (optional, for AI chat)
OPENAI_API_KEY=sk-your-openai-api-key
```

**Get Supabase Keys:**
- URL & Keys: Project Settings → API → Project URL and API Keys

**Generate NEXTAUTH_SECRET:**
```bash
openssl rand -base64 32
```

### 4. Install shadcn/ui Components

This project uses shadcn/ui for UI components. Install the required components:

```bash
# Initialize shadcn/ui (if not already done)
npx shadcn-ui@latest init

# Install all required components
npx shadcn-ui@latest add button card badge input label select separator avatar dropdown-menu dialog progress tabs toast tooltip
```

### 5. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### 6. Set Up Authentication

#### Enable Email Auth in Supabase

1. Go to Supabase Dashboard → Authentication → Providers
2. Enable **Email** provider
3. Configure email templates if desired

#### Create Your First User

```sql
-- Run in Supabase SQL Editor
INSERT INTO auth.users (email, email_confirmed_at, encrypted_password, created_at, updated_at)
VALUES (
  'your-email@example.com',
  NOW(),
  crypt('your-password', gen_salt('bf')),
  NOW(),
  NOW()
);
```

Or use Supabase Dashboard → Authentication → Add User.

---

## 🔌 n8n Integration

### Overview

The dashboard receives real-time updates from your n8n automation via webhooks. When the weekly automation runs, it sends data to the dashboard's webhook endpoint.

### Step 1: Update n8n Workflow

Add webhook nodes to your existing n8n workflow:

```
Existing n8n Workflow
    ↓
Add these nodes:
    ├── Webhook: Run Started
    ├── Webhook: Posts Scraped
    ├── Webhook: Analysis Complete
    ├── Webhook: Generation Complete
    └── Webhook: Run Complete
```

### Step 2: Configure Webhook Nodes

**Node: "Webhook - Run Started"**

```json
{
  "httpMethod": "POST",
  "path": "webhook/n8n",
  "responseMode": "onReceived",
  "authentication": "headerAuth",
  "headerAuth": {
    "name": "X-Webhook-Secret",
    "value": "={{ $env.WEBHOOK_SECRET }}"
  },
  "body": {
    "event": "run_started",
    "run_id": "={{ $workflow.id }}_{{ $now }}",
    "timestamp": "={{ $now }}",
    "creators_count": 25
  }
}
```

**Node: "Webhook - Posts Scraped"**

```json
{
  "event": "posts_scraped",
  "run_id": "={{ $node['Webhook - Run Started'].json.run_id }}",
  "posts": "={{ $json }}"
}
```

**Node: "Webhook - Analysis Complete"**

```json
{
  "event": "analysis_complete",
  "run_id": "={{ $node['Webhook - Run Started'].json.run_id }}",
  "analyzed_posts": "={{ $json }}"
}
```

**Node: "Webhook - Run Complete"**

```json
{
  "event": "run_complete",
  "run_id": "={{ $node['Webhook - Run Started'].json.run_id }}",
  "status": "completed",
  "stats": {
    "posts_scraped": "={{ $json.posts_scraped }}",
    "posts_analyzed": "={{ $json.posts_analyzed }}",
    "posts_generated": 7
  }
}
```

### Step 3: Test Webhooks

```bash
# Test from command line
curl -X POST http://localhost:3000/api/webhook/n8n \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your-webhook-secret" \
  -d '{
    "event": "run_started",
    "run_id": "test_123",
    "timestamp": "2025-10-25T14:00:00Z",
    "creators_count": 25
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "Webhook received",
  "event": "run_started"
}
```

---

## 📂 Project Structure

```
linkedin-radar-dashboard/
├── app/
│   ├── (auth)/                 # Authentication pages
│   │   ├── login/
│   │   └── signup/
│   ├── (dashboard)/            # Main dashboard pages
│   │   ├── layout.tsx          # Dashboard layout with sidebar
│   │   ├── page.tsx            # Dashboard home
│   │   ├── radar/              # Post analysis view
│   │   ├── knowledge/          # Creator management
│   │   ├── calendar/           # Content scheduling
│   │   ├── logs/               # Automation monitoring
│   │   └── settings/           # User preferences
│   ├── api/                    # API routes
│   │   ├── creators/
│   │   ├── posts/
│   │   ├── generated/
│   │   ├── runs/
│   │   ├── analytics/
│   │   └── webhook/            # n8n webhook receiver
│   ├── globals.css             # Global styles (Scripe theme)
│   ├── layout.tsx              # Root layout
│   └── providers.tsx           # React Query provider
├── components/
│   ├── ui/                     # shadcn/ui base components
│   ├── dashboard/              # Dashboard-specific components
│   ├── radar/                  # Radar page components
│   ├── knowledge/              # Knowledge Base components
│   ├── calendar/               # Calendar components
│   └── shared/                 # Shared components
├── lib/
│   ├── supabase.ts             # Supabase clients
│   ├── utils.ts                # Utility functions
│   └── database.types.ts       # Generated types
├── supabase/
│   └── schema.sql              # Database schema
├── public/                     # Static assets
├── .env.example                # Environment variables template
├── next.config.js              # Next.js configuration
├── tailwind.config.ts          # Tailwind CSS configuration
├── tsconfig.json               # TypeScript configuration
├── package.json                # Dependencies
└── README.md                   # This file
```

---

## 🗄️ Database Schema

### Key Tables

| Table | Description |
|-------|-------------|
| **creators** | LinkedIn creators being tracked |
| **posts** | Scraped and analyzed LinkedIn posts |
| **generated_posts** | AI-generated posts for your brand |
| **automation_runs** | Execution history of n8n automation |
| **analytics_daily** | Daily aggregated metrics |
| **content_strategy** | Content pillar targets and tracking |
| **user_preferences** | User/team settings |
| **webhook_logs** | Audit log of incoming webhooks |

Full schema: See `supabase/schema.sql`

---

## 🎨 UI Components

This project uses **shadcn/ui** components with a **Scripe-inspired dark theme**.

### Color Palette

```css
--background: 0 0% 4%           /* Very dark gray */
--foreground: 0 0% 98%          /* Near white */
--primary: 262 83% 58%          /* Purple (Scripe accent) */
--muted: 0 0% 15%               /* Dark gray */
--accent: 262 83% 58%           /* Purple */
--destructive: 0 84% 60%        /* Red */
--border: 0 0% 20%              /* Gray border */
--card: 0 0% 7%                 /* Slightly lighter than bg */
```

### Key Design Features

- Dark theme by default
- Gradient purple accent (Scripe-inspired)
- Glassmorphism effects
- Smooth transitions (200ms)
- Progress ring animations
- Hover effects on cards

---

## 🔑 API Routes

### Public Endpoints

- `GET /api/analytics/overview` - Dashboard statistics
- `GET /api/analytics/trends` - Time-series data
- `GET /api/creators` - List all creators
- `GET /api/posts/top` - Top-scoring posts

### Protected Endpoints

- `POST /api/creators` - Add new creator
- `PATCH /api/creators/[id]` - Update creator
- `DELETE /api/creators/[id]` - Remove creator
- `PATCH /api/generated/[id]` - Edit generated post
- `POST /api/generated/[id]/publish` - Mark post as published

### Webhook Endpoints

- `POST /api/webhook/n8n` - Receive n8n automation data
- `POST /api/webhook/trigger` - Manually trigger n8n workflow

**Authentication:** All protected endpoints require Supabase session.

---

## 📊 Analytics & Monitoring

### Built-in Analytics

The dashboard tracks:
- Daily posts scraped/analyzed/generated
- Average engagement rates
- AI scoring trends
- Automation success rate
- API costs (OpenAI + Bright Data)

### Exporting Data

```typescript
// Export to CSV
const response = await fetch('/api/export/csv?type=posts&start=2025-10-01&end=2025-10-31')
const blob = await response.blob()

// Export to PDF
const response = await fetch('/api/export/pdf?run_id=abc123')
```

---

## 🚢 Deployment

### Deploy to Vercel

1. **Push to GitHub**

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/linkedin-radar-dashboard.git
git push -u origin main
```

2. **Connect to Vercel**

- Go to [vercel.com](https://vercel.com)
- Click "Import Project"
- Select your GitHub repository
- Add environment variables from `.env.local`
- Deploy!

3. **Update Environment Variables**

In Vercel dashboard, add all variables from `.env.example`:
- Supabase credentials
- OpenAI API key
- n8n webhook URL
- Webhook secret

4. **Update n8n Webhook URL**

In your n8n workflow, update webhook URLs to:
```
https://your-app.vercel.app/api/webhook/n8n
```

### Custom Domain

1. Go to Vercel Project Settings → Domains
2. Add your custom domain
3. Update DNS records as instructed
4. Update `NEXTAUTH_URL` in environment variables

---

## 🔧 Development

### Generate Database Types

```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref your-project-id

# Generate types
npm run db:types
```

### Linting & Formatting

```bash
# Lint
npm run lint

# Format
npm run format

# Type check
npm run type-check
```

### Database Migrations

```bash
# Create migration
supabase migration new migration_name

# Apply migrations
supabase db push
```

---

## 🐛 Troubleshooting

### "Supabase client error"

**Cause:** Missing or incorrect Supabase credentials

**Solution:**
1. Verify `.env.local` has correct `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`
2. Check Supabase Dashboard → Settings → API
3. Restart dev server after changing env variables

### "Webhook not receiving data"

**Cause:** Incorrect webhook URL or secret

**Solution:**
1. Verify `N8N_WEBHOOK_URL` in n8n points to dashboard
2. Check `X-Webhook-Secret` header matches `WEBHOOK_SECRET` in `.env.local`
3. Test webhook with curl (see n8n Integration section)

### "Database connection failed"

**Cause:** Database not initialized or RLS policies blocking access

**Solution:**
1. Run `supabase/schema.sql` in Supabase SQL Editor
2. Verify RLS policies are created
3. Check user has proper authentication

### "shadcn/ui components not found"

**Cause:** Components not installed

**Solution:**
```bash
npx shadcn-ui@latest add button card badge input
# Install all required components
```

---

## 📚 Resources

### Documentation

- [Next.js Docs](https://nextjs.org/docs)
- [Supabase Docs](https://supabase.com/docs)
- [shadcn/ui](https://ui.shadcn.com/)
- [TanStack Query](https://tanstack.com/query/latest)
- [n8n Documentation](https://docs.n8n.io/)

### Scripe Inspiration

This dashboard's UX is inspired by [Scripe](https://scripe.io) - a LinkedIn content creation platform. Key design elements:
- Dark theme with purple accents
- Progress rings for metrics
- Card-based layout
- Smooth animations
- Content pillar tracking

---

## 🎯 Roadmap

- [ ] Multi-user support with team workspaces
- [ ] Real-time collaboration on posts
- [ ] In-app post editor with WYSIWYG
- [ ] Auto-scheduling to LinkedIn (via API)
- [ ] Sentiment analysis on comments
- [ ] Competitor benchmarking
- [ ] Mobile app (React Native)
- [ ] Slack/Discord bot integration
- [ ] Advanced analytics dashboard
- [ ] A/B testing for post variations

---

## 📝 License

MIT License - feel free to use this project for your own purposes.

---

## 🙏 Acknowledgments

- **Scripe** - Design inspiration
- **shadcn/ui** - Beautiful UI components
- **Vercel** - Seamless deployment
- **Supabase** - Powerful backend
- **n8n** - Workflow automation

---

## 💬 Support

Need help? Check:

1. This README
2. `PROJECT_ARCHITECTURE.md` for technical details
3. Supabase Dashboard → Logs for database errors
4. Vercel Dashboard → Functions for API errors
5. n8n Executions for automation errors

---

**Built with ❤️ for AI/Automation content creators**

🚀 Ready to dominate LinkedIn content!
