# LinkedIn Content Radar - Production Ready System

> **Automated LinkedIn content analysis and generation system using n8n, Bright Data, OpenAI GPT-4, and Google Workspace**

## 🎯 What This System Does

Every Sunday at 2 PM (Europe/Paris time), this automation:

1. **Scrapes** 25 LinkedIn creator profiles using Bright Data Web Scraper
2. **Filters** posts from the last 7 days with 100+ likes (no reshares)
3. **Analyzes** each post with OpenAI GPT-4 for:
   - Relevance to AI/automation (1-5)
   - Value depth and actionability (1-5)
   - Professional tone check
   - Lead magnet opportunity detection
4. **Ranks** posts by final score: `(Relevance × 2) + (Value Depth × 3)`
5. **Generates** 7 brand-new LinkedIn posts inspired by top performers
6. **Outputs** to Google Sheets + PDF in Google Drive
7. **Sends** real-time updates to optional dashboard via webhooks

## 📦 Repository Structure

```
n8nWorkflows/
├── LinkedIn_Radar_Production_v1.json    # ⭐ MAIN PRODUCTION WORKFLOW
├── PRODUCTION_DEPLOYMENT.md             # 📘 Step-by-step deployment guide
├── PRODUCTION_WORKFLOW_ANALYSIS.md      # 🔍 Detailed improvement analysis
├── BRIGHTDATA_SETUP.md                  # 🌐 Bright Data integration guide
├── COMPLETE_SETUP_GUIDE.md              # 📖 Original comprehensive guide
├── .env.example                         # 🔑 Environment variables template
│
├── linkedin-radar-dashboard/            # 🎨 Next.js SaaS Dashboard (optional)
│   ├── app/                            # Next.js 14 App Router
│   ├── components/                     # React components
│   ├── supabase/                       # Database schema
│   └── .env.example                    # Dashboard environment vars
│
└── Legacy Workflows/                    # 📁 Previous iterations
    ├── LinkedIn_Radar_Simple_With_Webhooks.json
    ├── LinkedIn_Radar_WORKING.json
    ├── LinkedIn_Radar_BrightData.json
    └── Test_Simple.json
```

## 🚀 Quick Start (15 minutes)

### Prerequisites

- n8n instance (Docker or cloud)
- Bright Data account ([sign up](https://brightdata.com))
- OpenAI API key with GPT-4 access
- Google account (Sheets + Drive)

### Installation

**1. Import workflow into n8n:**
```bash
# Download the workflow
curl -O https://raw.githubusercontent.com/YourRepo/n8nWorkflows/main/LinkedIn_Radar_Production_v1.json

# Import via n8n UI:
# n8n → Import from File → Select LinkedIn_Radar_Production_v1.json
```

**2. Configure environment variables:**
```bash
# Copy template
cp .env.example .env

# Edit with your credentials
nano .env
```

Required variables:
```bash
BRIGHTDATA_TOKEN=your-bright-data-token
OPENAI_API_KEY=sk-your-openai-key
GOOGLE_SHEET_ID=your-sheet-id
GOOGLE_DRIVE_FOLDER_ID=your-drive-folder-id
DASHBOARD_WEBHOOK_URL=https://your-dashboard.com  # Optional
WEBHOOK_SECRET=random-secret-string               # Optional
```

**3. Set up Google OAuth credentials:**
- Enable Google Sheets API in Google Cloud Console
- Enable Google Drive API
- Create OAuth 2.0 credentials
- Add to n8n credential store

**4. Test with 3 creators first:**
- Edit "25 LinkedIn Creators" node
- Keep only 3 URLs
- Click "Execute Workflow"
- Verify results in Google Sheets

**5. Activate for production:**
- Restore full 25 creator list
- Click "Activate" toggle
- Wait for Sunday 2 PM or run manually

📘 **Full deployment guide:** [PRODUCTION_DEPLOYMENT.md](./PRODUCTION_DEPLOYMENT.md)

## 💡 Key Features

### ✅ Production-Ready Components

- **Retry Logic:** 3 attempts with exponential backoff on Bright Data calls
- **Rate Limiting:** 2-5s random delays to avoid LinkedIn blocks
- **Error Handling:** Graceful degradation, continues with partial results
- **Cost Tracking:** Real-time OpenAI + Bright Data cost calculation
- **Deduplication:** Avoids re-processing same posts
- **Lead Magnet Detection:** AI identifies downloadable content opportunities
- **Webhook Integration:** 5 events for real-time dashboard updates
- **Comprehensive Logging:** Detailed execution history in n8n

### 🎯 Workflow Nodes (28 total)

1. **Schedule Trigger** - Sundays at 14:00 (Paris)
2. **Generate Run ID** - Unique identifier for tracking
3. **Webhook: Run Started** - Dashboard notification
4. **25 LinkedIn Creators** - Target profile URLs
5. **Split Creators** - Process individually
6. **Rate Limit Delay** - Random 2-5s pause
7. **Bright Data: Scrape Posts** - LinkedIn data extraction
8. **Parse Scrape Results** - Extract post data
9. **Filter Posts** - 7d, 100+ likes, no reshares
10. **Deduplication Check** - Skip seen posts
11. **Webhook: Posts Scraped** - Dashboard update
12. **OpenAI: Score Posts** - GPT-4 analysis
13. **Calculate Final Score** - Weighted scoring
14. **Track OpenAI Scoring Cost** - Token usage
15. **Webhook: Analysis Complete** - Dashboard update
16. **Rank Top 15** - Sort by score
17. **Select Top 7** - Best performers
18. **OpenAI: Generate Posts** - GPT-4 content creation
19. **Format Output** - Prepare for export
20. **Calculate Total Costs** - OpenAI + Bright Data
21. **Webhook: Generation Complete** - Dashboard update
22. **Format for Google Sheets** - Column mapping
23. **Append to Google Sheets** - Write data
24. **Generate PDF Content** - Create summary
25. **Upload PDF to Google Drive** - Store document
26. **Webhook: Run Complete** - Final dashboard update

## 💰 Cost Analysis

### Per Run Estimate

| Service | Usage | Cost |
|---------|-------|------|
| **OpenAI GPT-4** | Scoring: ~75 posts × 800 tokens | $0.80 |
| **OpenAI GPT-4** | Generation: ~7 posts × 1500 tokens | $0.45 |
| **Bright Data** | 25 profiles × $0.004 | $0.10 |
| **Total per Run** | | **$1.35** |

### Monthly Estimate

- **Weekly runs:** 4-5 per month
- **Monthly cost:** ~$5.40-6.75
- **Annual cost:** ~$65-81

### Cost Optimization Options

1. **Use GPT-4o-mini** instead of GPT-4 → **Save 95%** ($0.30/run)
2. **Run bi-weekly** instead of weekly → **Save 50%**
3. **Increase like filter** (150+ instead of 100+) → **Save 20%**
4. **Reduce to 15 creators** → **Save 40%**

**Optimized monthly cost:** As low as **$1.20/month**

## 📊 Output Examples

### Google Sheets Columns

```
| Rank | Creator | Original URL | Posted Date | Likes | Comments |
|------|---------|--------------|-------------|-------|----------|
| 1 | John Doe | linkedin.com/... | 2025-10-23 | 342 | 28 |
| 2 | Jane Smith | linkedin.com/... | 2025-10-22 | 298 | 19 |
...

| Relevance Score | Value Depth Score | Final Score | Generated Post | Lead Magnet |
|-----------------|-------------------|-------------|----------------|-------------|
| 5 | 5 | 25 | AI automation is changing... | "10 AI Tools Checklist" |
| 4 | 5 | 23 | Just discovered a game-changer... | "Prompt Template Guide" |
```

### PDF Format

```
# LinkedIn Content Radar - Week of 2025-10-20

Run ID: run_1729440000_abc123
Generated: 2025-10-20T14:15:32.000Z

## Top 7 LinkedIn Posts This Week

### 1. John Doe (Score: 25)

**Generated Post:**
AI automation is changing how we work...
[Full generated post content]

**Stats:** 342 likes, 28 comments
**Scores:** Relevance 5/5, Value 5/5
**Lead Magnet Idea:** "10 AI Tools Checklist"

---

[Continues for all 7 posts]

**Total Run Cost:** $1.35 USD
```

## 🔧 Technical Architecture

### Data Flow

```
Trigger (Sundays 14:00)
  ↓
Generate Run ID
  ↓
Webhook: Run Started → Dashboard
  ↓
Load 25 Creator URLs
  ↓
For Each Creator:
  ├─ Rate Limit (2-5s delay)
  ├─ Bright Data API (3 retries)
  └─ Parse Posts
  ↓
Filter (7d, 100+ likes)
  ↓
Deduplication
  ↓
Webhook: Posts Scraped → Dashboard
  ↓
For Each Post:
  ├─ OpenAI GPT-4 Scoring
  ├─ Calculate Final Score
  └─ Track Costs
  ↓
Webhook: Analysis Complete → Dashboard
  ↓
Rank Top 15 → Select Top 7
  ↓
For Each Top Post:
  ├─ OpenAI GPT-4 Generation
  └─ Format Output
  ↓
Calculate Total Costs
  ↓
Webhook: Generation Complete → Dashboard
  ↓
Google Sheets Append
  ↓
Generate PDF
  ↓
Google Drive Upload
  ↓
Webhook: Run Complete → Dashboard
```

### Tech Stack

- **Automation:** n8n (self-hosted or cloud)
- **LinkedIn Scraping:** Bright Data Web Scraper API
- **AI Analysis:** OpenAI GPT-4
- **Storage:** Google Sheets + Google Drive
- **Dashboard:** Next.js 14 + Supabase (optional)
- **Webhooks:** Custom HTTP endpoints

## 🎨 Optional Dashboard

Full-stack SaaS dashboard with:

- **Real-time updates** via webhooks
- **Analytics dashboard** with performance metrics
- **Radar view** of all analyzed posts
- **Knowledge base** for content strategy
- **Calendar** for scheduling runs
- **Logs** for debugging

Tech: Next.js 14, Supabase, TanStack Query, Tailwind CSS, shadcn/ui

📁 **Location:** `linkedin-radar-dashboard/`
📘 **Setup guide:** `linkedin-radar-dashboard/README.md`

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **PRODUCTION_DEPLOYMENT.md** | Step-by-step deployment instructions |
| **PRODUCTION_WORKFLOW_ANALYSIS.md** | Detailed improvement analysis |
| **BRIGHTDATA_SETUP.md** | Bright Data integration guide |
| **COMPLETE_SETUP_GUIDE.md** | Original comprehensive guide |
| **.env.example** | Environment variables template |

## 🐛 Troubleshooting

### Common Issues

**1. Bright Data returns no data**
- Check API token is valid
- Verify credits in Bright Data dashboard
- Test endpoint manually with curl

**2. OpenAI rate limit errors**
- Check tier limits (tier 1: 500 RPM)
- Add delays between calls
- Consider batching requests

**3. Google Sheets authentication expired**
- Re-authorize OAuth in n8n credentials
- Refresh token every 7 days

**4. Workflow import fails**
- Verify JSON syntax: `python3 -m json.tool workflow.json`
- Check n8n version (requires v1.0+)
- Try fresh n8n instance

**5. Costs too high**
- Switch to GPT-4o-mini for scoring
- Reduce number of creators
- Increase like threshold filter

📘 **Full troubleshooting guide:** [PRODUCTION_DEPLOYMENT.md#troubleshooting](./PRODUCTION_DEPLOYMENT.md#troubleshooting)

## 🔐 Security Notes

### Environment Variables

Never commit `.env` files with real credentials:
```bash
# Add to .gitignore
.env
.env.local
```

### Webhook Secret

Use strong random secret:
```bash
# Generate secure secret
openssl rand -hex 32
```

### Google OAuth

- Use service account for production
- Limit scope to specific sheets/folders
- Rotate credentials every 90 days

### API Keys

- Restrict OpenAI key to specific IP if possible
- Monitor usage daily
- Set spending limits in OpenAI dashboard

## 🚦 Production Readiness Checklist

Before going live:

- [ ] Tested with 3 creators successfully
- [ ] All credentials configured and working
- [ ] Environment variables set correctly
- [ ] Google Sheets properly formatted
- [ ] Google Drive folder created and accessible
- [ ] Costs reviewed and acceptable
- [ ] Schedule configured (Sundays 14:00)
- [ ] Error monitoring set up
- [ ] Backup workflow JSON saved
- [ ] Webhook integration tested (if using dashboard)
- [ ] First production run monitored

## 📈 Performance Metrics

### Execution Time

- **Scraping 25 creators:** 3-5 minutes
- **AI scoring ~75 posts:** 2-3 minutes
- **Generating 7 posts:** 1-2 minutes
- **Google Sheets/Drive:** 30 seconds

**Total:** 7-11 minutes per run

### Success Metrics

After 4 weeks, you should have:
- ✅ 28 AI-generated LinkedIn posts
- ✅ ~300 analyzed competitor posts
- ✅ Lead magnet ideas library
- ✅ Content strategy insights
- ✅ Engagement benchmarks

## 🔄 Workflow Versions

| Version | Date | Changes |
|---------|------|---------|
| **v1.0.0** | 2025-10-25 | Production release with all features |
| v0.3.0 | 2025-10-24 | Added Bright Data integration |
| v0.2.0 | 2025-10-23 | Added webhook integration |
| v0.1.0 | 2025-10-22 | Initial version with Apify |

**Current stable:** `LinkedIn_Radar_Production_v1.json`

## 🤝 Contributing

To customize for your use case:

1. **Change creator list** in "25 LinkedIn Creators" node
2. **Adjust filters** in "Filter Posts" node (days, likes threshold)
3. **Modify AI prompts** in OpenAI nodes
4. **Change schedule** in "Schedule Trigger" node
5. **Add custom fields** to Google Sheets output

## 📝 License

This workflow is provided as-is for automation purposes.

## 🆘 Support

For issues:
1. Check execution logs in n8n
2. Review troubleshooting guide
3. Test individual nodes
4. Check API status pages (OpenAI, Bright Data)

## 🎯 Roadmap

Potential future enhancements:

- [ ] A/B testing different generation prompts
- [ ] Automatic creator list optimization
- [ ] Multi-niche support (Real Estate, SaaS, etc.)
- [ ] Sentiment analysis
- [ ] Viral potential scoring
- [ ] Integration with posting scheduler
- [ ] Email digest of top posts
- [ ] Slack/Discord notifications

---

**Current Version:** 1.0.0 Production
**Last Updated:** 2025-10-25
**Status:** ✅ Production Ready
**Estimated Setup Time:** 45-60 minutes
**Monthly Cost:** ~$5-6 (optimizable to $1-2)
