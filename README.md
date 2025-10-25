# 🧠 Weekly LinkedIn Competitive Content Radar

**An intelligent n8n automation that analyzes top LinkedIn creators and generates data-driven content for your brand.**

![Status](https://img.shields.io/badge/status-production--ready-green)
![n8n](https://img.shields.io/badge/n8n-v1.0+-blue)
![License](https://img.shields.io/badge/license-MIT-blue)

---

## 🎯 What This Does

This automation saves you **5-10 hours per week** by:

1. 🕵️ **Scraping** posts from 10 hand-picked LinkedIn creators in your niche
2. 🔍 **Filtering** to find high-engagement original content from the last 7 days
3. 🤖 **Analyzing** each post with AI for relevance, value, and tone
4. 📊 **Ranking** posts using smart scoring algorithms
5. ✍️ **Generating** 7 brand-new LinkedIn posts for your agency
6. 📑 **Exporting** everything to Google Sheets and PDF

**Runs automatically every Sunday at 2PM** (Europe/Paris timezone)

---

## ✨ Key Features

- ✅ **Zero manual research** - fully automated weekly execution
- ✅ **AI-powered insights** - GPT-4 analyzes content quality and relevance
- ✅ **Smart filtering** - only keeps posts with 100+ likes from last 7 days
- ✅ **Lead magnet detection** - suggests downloadable resources based on top posts
- ✅ **Professional output** - beautifully formatted PDF reports
- ✅ **Organized data** - all results saved to Google Sheets for easy editing
- ✅ **Error handling** - continues working even if some creators fail to scrape

---

## 🚀 Quick Start

### 1. Import the Workflow

```bash
1. Open n8n
2. Go to Workflows → Import from File
3. Select: LinkedIn_Content_Radar_Workflow.json
4. Click Import
```

### 2. Configure Credentials (5 minutes)

You need to set up 4 services:

| Service | Purpose | Cost |
|---------|---------|------|
| **Apify** | LinkedIn scraping | $0-2/week |
| **OpenAI** | GPT-4 analysis & generation | $0.50-2/week |
| **Google Sheets** | Data storage | Free |
| **Google Drive** | PDF reports | Free |

**Total estimated cost: $0.50-4/week**

### 3. Add Your Creators

Replace the placeholder URLs with 10 LinkedIn profiles in your niche:

```javascript
[
  "https://www.linkedin.com/in/creator1/",
  "https://www.linkedin.com/in/creator2/",
  // ... add 8 more
]
```

### 4. Test & Activate

1. Click **Execute Workflow** to test
2. Verify posts appear in Google Sheets
3. Check PDF is created in Google Drive
4. Activate the schedule trigger

**Done!** Your automation will run every Sunday at 2PM.

---

## 📂 Repository Contents

```
/n8nWorkflows/
├── LinkedIn_Content_Radar_Workflow.json   ← Import this into n8n
├── SETUP_GUIDE.md                        ← Detailed setup instructions
├── QUICK_REFERENCE.md                    ← One-page cheat sheet
└── README.md                             ← You are here
```

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│  Schedule Trigger (Every Sunday 2PM)                │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  Load 10 Target LinkedIn Creator URLs               │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  Apify LinkedIn Scraper (20 posts per creator)      │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  Filter Posts:                                       │
│  • Posted within last 7 days                        │
│  • 100+ likes                                        │
│  • Original content (not reshared)                  │
│  • Has meaningful text content                      │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  OpenAI GPT-4 Analysis:                             │
│  • Topic relevance (1-5)                            │
│  • Value depth (1-5)                                │
│  • Tone check (professional/conversational)         │
│  • Lead magnet opportunity detection                │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  Calculate Final Score & Rank:                      │
│  Score = (Relevance × 2) + (Value Depth × 3)       │
│  Keep top 15 posts                                  │
└─────────────────┬───────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────┐
│  GPT-4 Post Generation:                             │
│  Generate 7 new posts for your brand                │
│  (Inspired by top performers, not copies)           │
└─────────────────┬───────────────────────────────────┘
                  │
          ┌───────┴───────┐
          ▼               ▼
┌──────────────────┐  ┌────────────────────┐
│  Google Sheets   │  │  PDF Report        │
│  (Editable data) │  │  → Google Drive    │
└──────────────────┘  └────────────────────┘
```

---

## 📊 Sample Output

### Google Sheets Columns

| Column | Description |
|--------|-------------|
| Rank | Position (1-7) |
| Week Of | Date of analysis |
| Creator | Original post author |
| Original Post | Full text of original post |
| Original URL | Link to LinkedIn post |
| Posted Date | When it was published |
| Likes | Engagement count |
| Comments | Comment count |
| Relevance Score | AI rating 1-5 |
| Value Depth | AI rating 1-5 |
| Final Score | Calculated score (max 25) |
| **Generated Post** | Your new post draft |
| Lead Magnet | Suggested downloadable resource |

### PDF Report

A beautifully formatted document with:
- Header with week date
- 7 post cards with rankings
- Engagement metrics
- AI scores and reasoning
- Lead magnet suggestions
- Links to original posts

---

## 🎯 Use Cases

### For Agencies
- Research competitive content strategies
- Generate client content ideas
- Track industry trends
- Build content calendars

### For Creators
- Stay on top of trending topics
- Analyze what's working in your niche
- Generate content variations
- Save hours of manual research

### For Marketing Teams
- Monitor competitor activity
- Discover viral content patterns
- Test different content angles
- Build data-driven strategies

---

## 🛠️ Customization Options

### Adjust Post Count
Change from 7 to any number:
```javascript
// In "Select Top 7 Final Posts" node
const top7Posts = items.slice(0, 10) // Now generates 10 posts
```

### Change Engagement Threshold
```javascript
// In "Filter Posts" node
(post.likes || 0) >= 50 // Lowered from 100 to 50
```

### Modify Scoring Formula
```javascript
// In "Calculate & Rank" node
const finalScore = (relevance * 3) + (valueDepth * 2) // Prioritize relevance
```

### Change Schedule
```javascript
// In "Schedule Trigger" node
// Every Monday at 9AM: 0 9 * * 1
// Daily at 6AM: 0 6 * * *
```

---

## 🔧 Technical Requirements

### Minimum Requirements
- n8n instance (self-hosted or cloud)
- Apify account (free tier works)
- OpenAI account with GPT-4 access
- Google account

### Recommended Setup
- n8n Cloud (for reliability)
- Apify paid plan (for better scraping)
- OpenAI with usage monitoring
- Dedicated Google Sheet

### API Rate Limits
- Apify: ~100 requests/hour (free tier)
- OpenAI: 90,000 tokens/minute (tier 1)
- Google Sheets: 300 requests/minute
- Google Drive: 1,000 requests/user/100 seconds

---

## 📈 Performance Metrics

**Expected Results Per Week:**

| Metric | Value |
|--------|-------|
| Total posts scraped | 50-150 |
| Posts after filtering | 15-40 |
| Posts sent to AI | 15-40 |
| Top ranked posts | 15 |
| Final generated posts | 7 |
| Execution time | 30-45 min |
| OpenAI API calls | ~30-50 |
| Cost per run | $0.50-2 |

---

## 🐛 Troubleshooting

### Common Issues

**"No posts found"**
- Lower engagement threshold (50+ likes)
- Extend time window (14 days instead of 7)
- Verify creator URLs are correct

**"Apify scraper failed"**
- Refresh LinkedIn session cookie
- Check Apify credit balance
- Verify API token is valid

**"OpenAI error"**
- Check API key and credits
- Verify GPT-4 access is enabled
- Monitor rate limits

**"Google Sheets not updating"**
- Verify spreadsheet ID
- Check sheet name matches exactly
- Re-authenticate Google credential

📚 **See SETUP_GUIDE.md for detailed troubleshooting**

---

## 🔐 Security & Privacy

### Best Practices

1. **Use a dedicated LinkedIn account** for scraping (not your main)
2. **Rotate session cookies** every 30 days
3. **Monitor API costs** to avoid surprise bills
4. **Secure your credentials** in n8n
5. **Review LinkedIn TOS** - scraping may violate terms

### Data Privacy

- All data stays in **your** Google Drive/Sheets
- No third-party data sharing
- OpenAI processes content per their privacy policy
- Apify handles scraping with proxies

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **README.md** | Overview & quick start (you are here) |
| **SETUP_GUIDE.md** | Complete setup instructions with troubleshooting |
| **QUICK_REFERENCE.md** | One-page cheat sheet for daily use |

---

## 🤝 Contributing

Found a bug? Have an improvement idea?

1. Fork this repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Or open an issue to discuss!

---

## 📝 Version History

**v1.0** (October 2025)
- Initial release
- Core scraping, filtering, AI analysis
- Google Sheets & Drive integration
- PDF report generation
- Error handling & fallback logic

---

## 💡 Future Enhancements

Potential features for future versions:

- [ ] Multi-platform support (Twitter/X, Reddit)
- [ ] Sentiment analysis
- [ ] Hashtag optimization
- [ ] Image generation with DALL-E
- [ ] Automatic posting to LinkedIn
- [ ] A/B testing tracking
- [ ] Notion integration
- [ ] Weekly email digest
- [ ] Slack notifications
- [ ] Performance analytics dashboard

---

## 📞 Support

Need help?

1. Check **SETUP_GUIDE.md** for detailed instructions
2. Review **QUICK_REFERENCE.md** for common solutions
3. Search [n8n Community Forum](https://community.n8n.io/)
4. Join [n8n Discord](https://discord.gg/n8n)

---

## 📄 License

This workflow is provided as-is under the MIT License.

**Disclaimer**: Web scraping may violate LinkedIn's Terms of Service. Use at your own risk. This tool is for educational and research purposes.

---

## 🙏 Credits

Built with:
- [n8n](https://n8n.io) - Workflow automation
- [Apify](https://apify.com) - Web scraping
- [OpenAI](https://openai.com) - GPT-4 analysis
- [Google Workspace](https://workspace.google.com) - Data storage

---

## 🚀 Ready to Get Started?

1. Import `LinkedIn_Content_Radar_Workflow.json` into n8n
2. Follow **SETUP_GUIDE.md** for detailed configuration
3. Use **QUICK_REFERENCE.md** for daily operations

**Estimated setup time: 10-15 minutes**

Happy automating! 🎉

---

**Questions?** Open an issue or check the documentation files.

**Want to share your results?** Tag us and show what you built!
