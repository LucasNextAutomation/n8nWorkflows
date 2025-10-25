# ⚡ LinkedIn Content Radar - Quick Reference

## 🎯 One-Page Cheat Sheet

### Import & Setup (10 Minutes)

```
1. Import workflow JSON into n8n
2. Add 4 credentials:
   - Bright Data API token
   - OpenAI API key
   - Google Sheets (create sheet: "LinkedIn Content Radar")
   - Google Drive (create folder: "LinkedIn Weekly Radar")
3. Add 10 LinkedIn creator URLs
4. Test workflow manually
5. Activate the schedule
```

### Required Credentials

| Service | Where to Get | What You Need |
|---------|-------------|---------------|
| **Bright Data** | brightdata.com/settings | API Token |
| **OpenAI** | platform.openai.com/api-keys | API Key (GPT-4 access) |
| **Google Sheets** | OAuth in n8n | Spreadsheet ID |
| **Google Drive** | OAuth in n8n | Folder ID |

### Nodes Overview

| Node Name | What It Does | Customize |
|-----------|--------------|-----------|
| Schedule Trigger | Runs every Sunday 2PM | Cron expression |
| 10 Target Creators | Your creator list | Replace URLs |
| Bright Data Scraper | Gets LinkedIn posts | Add session cookie |
| Filter Posts | Keeps high-engagement posts | Change thresholds |
| OpenAI Analysis | Scores posts 1-5 | Adjust prompts |
| Calculate & Rank | Selects top 15 | Change scoring formula |
| Generate Posts | Creates 7 new posts | Edit brand voice |
| Google Sheets | Saves all data | Change sheet name |
| Generate PDF | Creates report | Customize HTML |
| Google Drive | Uploads PDF | Change folder path |

### Quick Fixes

| Problem | Solution |
|---------|----------|
| "No posts found" | Lower engagement threshold (50+ likes) |
| "Bright Data failed" | Refresh LinkedIn session cookie |
| "OpenAI error" | Check API credits & rate limits |
| "Sheets not updating" | Verify spreadsheet ID & sheet name |
| "PDF not created" | Check HTML syntax & Drive permissions |

### Cost Per Week

- **Free tier**: $0 (using free credits)
- **Light usage**: $0.50 - $2
- **Heavy usage**: $2 - $4

### Workflow Schedule

```
Sunday 2:00 PM  → Automation runs (30-45 min)
Sunday 3:00 PM  → Review Google Sheets
Monday          → Edit & refine posts
Mon-Sun         → Post throughout the week
```

### Key Configuration Values

```javascript
// Time window for posts
sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7) // Change -7 to -14 for 2 weeks

// Minimum engagement
(post.likes || 0) >= 100 // Change 100 to 50 or 200

// Scoring formula
finalScore = (relevance * 2) + (valueDepth * 3)

// Number of final posts
items.slice(0, 7) // Change 7 to 5 or 10
```

### Testing Checklist

- [ ] All 4 credentials configured
- [ ] 10 creator URLs added
- [ ] Manual execution successful
- [ ] Posts appear in Google Sheets
- [ ] PDF created in Google Drive
- [ ] Schedule trigger activated

### Monthly Maintenance

**Every 30 days:**
1. Refresh LinkedIn session cookie
2. Review creator list (remove/add creators)
3. Check Bright Data & OpenAI credit balance
4. Analyze which posts performed best
5. Adjust filtering/scoring if needed

### Advanced Customizations

**Add more metrics:**
- Edit "Filter Posts" node → add new fields
- Update Google Sheets columns

**Change AI voice:**
- Edit "GPT Generate Brand Posts" node
- Modify system prompt

**Export to other tools:**
- Add HTTP Request node
- Send to Slack, Notion, Airtable, etc.

### Common Cron Expressions

```
0 14 * * 0      Every Sunday 2PM
0 9 * * 1       Every Monday 9AM
0 6 * * 1-5     Weekdays 6AM
0 14 */3 * *    Every 3 days at 2PM
0 0 1 * *       First of month midnight
```

### Support Links

- n8n Docs: https://docs.n8n.io/
- Bright Data LinkedIn Scraper: https://brightdata.com/apify/linkedin-profile-scraper
- OpenAI API: https://platform.openai.com/docs
- Community: https://community.n8n.io/

### Emergency Stops

**Disable automation:**
1. Open workflow
2. Click "Active" toggle (top right)
3. Set to "Inactive"

**Stop running execution:**
1. Go to "Executions" tab
2. Find running execution
3. Click "Stop Execution"

---

## 📋 Pre-Launch Checklist

Before activating the schedule:

- [ ] Imported workflow successfully
- [ ] Added Bright Data API token
- [ ] Added OpenAI API key
- [ ] Connected Google Sheets
- [ ] Connected Google Drive
- [ ] Created "LinkedIn Content Radar" sheet
- [ ] Created "LinkedIn Weekly Radar" folder
- [ ] Added 10 LinkedIn creator URLs
- [ ] Tested workflow manually
- [ ] Verified posts in Google Sheets
- [ ] Verified PDF in Google Drive
- [ ] Checked costs are acceptable
- [ ] Set calendar reminder for Sunday 3PM

**Status:** Ready to activate! 🚀

---

## 🎯 Expected Results (Per Week)

| Metric | Expected Value |
|--------|----------------|
| Posts scraped | 50-150 |
| Posts after filtering | 15-40 |
| Top ranked posts | 15 |
| Final generated posts | 7 |
| Execution time | 30-45 minutes |
| Google Sheets rows | 7 new rows/week |
| PDF reports | 1 per week |

---

## 💡 Pro Tips

1. **Start small**: Test with 3 creators first
2. **Monitor costs**: Check OpenAI usage weekly
3. **Rotate cookies**: Update LinkedIn session monthly
4. **Track performance**: Note which generated posts work best
5. **Personalize**: Always edit AI-generated content before posting
6. **A/B test**: Try different creator combinations
7. **Build library**: Save all PDFs for future reference
8. **Iterate**: Adjust prompts based on output quality

---

## 🔗 File Structure

```
/n8nWorkflows/
├── LinkedIn_Content_Radar_Workflow.json   (Import this)
├── SETUP_GUIDE.md                         (Full documentation)
├── QUICK_REFERENCE.md                     (This file)
└── README.md                              (Overview)
```

---

**Last Updated**: October 2025
**Version**: 1.0
**Compatibility**: n8n v1.0+

Need help? Check SETUP_GUIDE.md for detailed troubleshooting! 📚
