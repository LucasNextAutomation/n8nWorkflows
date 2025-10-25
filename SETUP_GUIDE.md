# 📊 LinkedIn Content Radar - Complete Setup Guide

## 🎯 What This Automation Does

Every Sunday at 2PM (Europe/Paris timezone), this automation will:

1. ✅ Scrape posts from 10 LinkedIn creators in the AI/automation niche
2. ✅ Filter posts from the last 7 days with 100+ likes (original content only)
3. ✅ Use OpenAI GPT-4 to analyze and score each post
4. ✅ Rank posts and select the top 15
5. ✅ Generate 7 brand-new LinkedIn posts for your agency
6. ✅ Save everything to Google Sheets
7. ✅ Export a beautiful PDF report to Google Drive

---

## 🚀 Quick Start (5 Steps)

### Step 1: Import the Workflow

1. Open your n8n instance
2. Click **Workflows** → **Import from File**
3. Select `LinkedIn_Content_Radar_Workflow.json`
4. Click **Import**

The workflow is now in your n8n instance!

---

### Step 2: Set Up Required Credentials

You need to configure 4 services:

#### A) Bright Data API Token
- Go to [Bright Data.com](https://brightdata.com) and create a free account
- Navigate to **Settings** → **Integrations** → **API Token**
- Copy your API token
- In n8n: Click on the **"Bright Data LinkedIn Scraper"** node
- Click **Credentials** → **Create New**
- Add your Bright Data API token

#### B) OpenAI API Key
- Go to [platform.openai.com](https://platform.openai.com)
- Navigate to **API Keys** and create a new key
- In n8n: Click on **"OpenAI Post Analysis & Scoring"** node
- Click **Credentials** → **Create New**
- Add your OpenAI API key
- **Note**: This workflow uses GPT-4 Turbo. Costs are approximately $0.50-$2 per week depending on post volume.

#### C) Google Sheets
- In n8n: Click on **"Save to Google Sheets"** node
- Click **Credentials** → **Create New**
- Authenticate with your Google account
- **Create a Google Sheet** named "LinkedIn Content Radar"
- Copy the spreadsheet ID from the URL (the long string after `/d/`)
- Paste it in the node's **Document ID** field

#### D) Google Drive
- In n8n: Click on **"Upload to Google Drive"** node
- Click **Credentials** → **Create New**
- Authenticate with your Google account
- **Create a folder** called "LinkedIn Weekly Radar"
- Copy the folder ID from the URL
- Paste it in the node's **Folder ID** field

---

### Step 3: Add Your 10 Target LinkedIn Creators

1. Click on the **"10 Target LinkedIn Creators"** node
2. Replace the placeholder URLs with your actual target creators
3. Format: `https://www.linkedin.com/in/username/`

Example:
```javascript
[
  "https://www.linkedin.com/in/samaltman/",
  "https://www.linkedin.com/in/andrewng/",
  "https://www.linkedin.com/in/cassiekozyrkov/",
  // ... add 7 more
]
```

**How to find good creators:**
- Search LinkedIn for "AI automation" or "n8n" or "make.com"
- Look for profiles with 10k+ followers and regular engagement
- Choose creators in your specific niche (AI, automation, SaaS, etc.)

---

### Step 4: Configure Bright Data Scraper

The workflow uses **Bright Data's LinkedIn Profile Scraper**. You need to:

1. Go to [Bright Data.com](https://brightdata.com)
2. Find the **"LinkedIn Profile Scraper"** actor
3. Make sure you have credits (free tier gives you $5/month)
4. The workflow is configured to use `run-sync-get-dataset-items` for real-time results

**Important**: LinkedIn scraping requires:
- A valid LinkedIn account session cookie, OR
- Bright Data's proxies (included in paid plans)

To add your LinkedIn session:
1. Log into LinkedIn in your browser
2. Open Developer Tools (F12) → Application → Cookies
3. Find the `li_at` cookie value
4. In Bright Data scraper settings, add this as your session cookie

---

### Step 5: Test the Workflow

Before scheduling, test it manually:

1. Click **Execute Workflow** (the play button)
2. Watch each node execute
3. Check for errors (red nodes)
4. Verify:
   - Posts are being scraped ✅
   - Filtering is working ✅
   - OpenAI is analyzing posts ✅
   - Google Sheets is populated ✅
   - PDF is created in Google Drive ✅

**First test tip**: Start with just 2-3 creators to test faster and cheaper.

---

## 🔧 Configuration Options

### Adjust the Schedule

The workflow runs every Sunday at 2PM Paris time. To change this:

1. Click the **"Schedule Trigger - Every Sunday 2PM"** node
2. Modify the cron expression:
   - Current: `0 14 * * 0` (Sunday 2PM)
   - Daily at 9AM: `0 9 * * *`
   - Weekdays at 6AM: `0 6 * * 1-5`
   - Every 3 days: `0 14 */3 * *`

### Adjust Filtering Criteria

Edit the **"Filter Posts (7 days, 100+ likes)"** node:

```javascript
// Change these values:
const sevenDaysAgo = new Date();
sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7); // Change -7 to -14 for 2 weeks

// Minimum likes threshold
(post.likes || post.numLikes || 0) >= 100 // Change 100 to your preference
```

### Adjust AI Scoring Weights

Edit the **"Calculate & Rank (Top 15)"** node:

```javascript
// Current formula: (Relevance × 2) + (Value Depth × 3)
const finalScore = (analysis.relevance * 2) + (analysis.valueDepth * 3);

// Example: Weight relevance more heavily
const finalScore = (analysis.relevance * 3) + (analysis.valueDepth * 2);
```

### Change Number of Final Posts

Currently generates 7 posts. To change:

1. Edit **"Select Top 7 Final Posts"** node
2. Change: `const top7Posts = items.slice(0, 7)` → `items.slice(0, 10)` for 10 posts

---

## 💰 Cost Breakdown

Estimated weekly costs:

| Service | Cost | Notes |
|---------|------|-------|
| Bright Data | $0-2 | Free tier: $5/month credit |
| OpenAI GPT-4 | $0.50-2 | ~30-50 API calls per week |
| Google Sheets | Free | Unlimited |
| Google Drive | Free | 15GB free storage |
| **Total** | **~$0.50-4/week** | Depends on post volume |

**Cost optimization tips:**
- Use GPT-4 Turbo (not GPT-4) - it's 3x cheaper
- Reduce creator count from 10 to 5
- Increase filtering threshold (200+ likes instead of 100+)

---

## 🐛 Troubleshooting

### "Bright Data scraper failed"

**Causes:**
1. Invalid LinkedIn session cookie
2. Bright Data credits exhausted
3. LinkedIn rate limiting

**Solutions:**
- Refresh your `li_at` cookie (expires every ~30 days)
- Check Bright Data dashboard for credit balance
- Add delays between scraping requests
- Use Bright Data's residential proxies (paid)

### "OpenAI request failed"

**Causes:**
1. Invalid API key
2. Insufficient credits
3. Rate limiting

**Solutions:**
- Verify API key at platform.openai.com
- Add credits to your OpenAI account
- Add a delay node between OpenAI calls
- Reduce batch size (process fewer posts)

### "No posts found"

**Causes:**
1. Creators haven't posted in 7 days
2. Posts don't meet engagement threshold
3. Scraper isn't capturing posts

**Solutions:**
- Extend time window to 14 days
- Lower engagement threshold (50+ likes instead of 100+)
- Check Bright Data logs for scraping errors
- Verify creator URLs are correct

### "Google Sheets not updating"

**Causes:**
1. Invalid spreadsheet ID
2. Sheet name doesn't match
3. Permission issues

**Solutions:**
- Verify spreadsheet ID in URL
- Ensure sheet is named exactly "LinkedIn Content Radar"
- Re-authenticate Google Sheets credential
- Check sheet isn't locked/protected

### "PDF not generating"

**Causes:**
1. HTML conversion node error
2. Google Drive folder doesn't exist
3. Permission issues

**Solutions:**
- Check HTML node for syntax errors
- Create folder manually in Google Drive
- Verify folder ID in node settings
- Re-authenticate Google Drive credential

---

## 🎨 Customization Ideas

### Add More Data Points

Track additional metrics in Google Sheets:
- Hashtags used
- Post length (character count)
- Time of day posted
- Media type (text, image, video, carousel)

### Enhance AI Analysis

Add more OpenAI prompts:
- Hook/opening line analysis
- CTA effectiveness rating
- Emotional tone detection
- Viral potential score

### Multi-Platform Export

Export to:
- Notion database
- Airtable
- Slack notification
- Email digest

### Weekly Summary Email

Add a final node that:
- Compiles all 7 posts
- Sends via email
- Includes PDF attachment

---

## 📈 Best Practices

### Weekly Workflow

**Sunday 2PM**: Automation runs
**Sunday 3PM**: Review Google Sheet
**Monday**: Edit/refine the 7 generated posts
**Mon-Sun**: Schedule and post throughout the week

### Content Strategy

Don't just copy-paste! Use the generated posts as:
- **Inspiration** for your own voice
- **Structure** templates
- **Topic** ideas
- **Angle** references

Always:
- Add your own personality
- Include real examples from your business
- Adjust tone to match your brand
- Test different hooks and CTAs

### Monitoring

Check weekly:
- Total posts scraped
- Average engagement scores
- Top performing topics
- Lead magnet suggestions

Track monthly:
- Your own LinkedIn engagement
- Which generated posts performed best
- ROI of the automation

---

## 🔐 Security & Privacy

### Important Notes

1. **LinkedIn TOS**: Web scraping may violate LinkedIn's Terms of Service. Use at your own risk.
2. **API Keys**: Never share your Bright Data, OpenAI, or Google credentials
3. **Session Cookies**: Rotate your LinkedIn session cookie regularly
4. **Data Storage**: Posts are stored in your Google Sheets - ensure proper access controls

### Recommendations

- Use a dedicated LinkedIn account for scraping (not your main account)
- Don't scrape too frequently (once per week is safe)
- Use Bright Data's residential proxies for better reliability
- Enable 2FA on all connected accounts

---

## 🆘 Support & Resources

### Official Documentation

- [n8n Documentation](https://docs.n8n.io/)
- [Bright Data LinkedIn Scraper](https://brightdata.com/apify/linkedin-profile-scraper)
- [OpenAI API Reference](https://platform.openai.com/docs/api-reference)
- [Google Sheets API](https://developers.google.com/sheets/api)

### Community

- [n8n Community Forum](https://community.n8n.io/)
- [n8n Discord](https://discord.gg/n8n)

### Need Help?

If you encounter issues:
1. Check the **error logs** in each node
2. Test each node individually
3. Verify all credentials are valid
4. Check the troubleshooting section above

---

## 🚀 Next Steps

After your first successful run:

1. ✅ Review the 7 generated posts in Google Sheets
2. ✅ Download the PDF from Google Drive
3. ✅ Refine and personalize the posts
4. ✅ Schedule them throughout the week
5. ✅ Track which posts perform best
6. ✅ Adjust scoring criteria based on results

### Weekly Optimization

Each week, improve your workflow by:
- Adjusting creator list (remove low performers, add new ones)
- Refining engagement thresholds
- Tweaking AI prompts for better generation
- Testing different posting times

---

## 📝 Workflow Summary

```
Schedule Trigger (Sunday 2PM)
    ↓
Load 10 Creator URLs
    ↓
Split into Individual Items
    ↓
Scrape Each Creator's Posts (Bright Data)
    ↓
Filter: 7 days, 100+ likes, original only
    ↓
AI Analysis: Relevance, Value, Tone (OpenAI)
    ↓
Calculate Final Score & Rank Top 15
    ↓
Generate 7 New Posts for Your Brand (GPT-4)
    ↓
    ├─→ Save to Google Sheets
    └─→ Generate PDF → Upload to Google Drive
```

---

## 🎉 You're All Set!

You now have a fully automated LinkedIn content research system that:
- Saves you 5-10 hours per week
- Provides data-driven content ideas
- Generates high-quality post drafts
- Keeps you competitive in your niche

**Pro tip**: Set a recurring calendar reminder for Sunday 3PM to review your weekly results!

Happy automating! 🚀
