# 🚀 LinkedIn Content Radar - Complete Setup from Scratch

## Overview

Since you have an empty n8n instance, we'll:
1. ✅ Import the original working workflow (no webhooks)
2. ✅ Configure credentials (Apify, OpenAI, Google)
3. ✅ Add webhook nodes manually (6 nodes)
4. ✅ Test the complete system

**Total time: ~20 minutes**

---

## Part 1: Import Base Workflow (5 minutes)

### Step 1: Import the Workflow

1. **Open n8n** in your browser
2. Click **"Workflows"** in the left sidebar
3. Click **"Import from File"** button (top right)
4. Select: `LinkedIn_Content_Radar_Workflow.json`
5. Click **"Import"**

You should now see a workflow with these nodes:
- Schedule Trigger
- 10 Target LinkedIn Creators
- Split Into Items
- Apify LinkedIn Scraper
- Filter Posts
- OpenAI Post Analysis & Scoring
- Calculate & Rank (Top 15)
- GPT Generate Brand Posts
- Select Top 7 Final Posts
- Save to Google Sheets
- Generate PDF HTML
- Convert HTML to PDF
- Upload to Google Drive

✅ **Workflow imported successfully!**

---

## Part 2: Configure Credentials (10 minutes)

### Step 2A: Apify Credentials

1. Go to [apify.com](https://apify.com) → Sign up/Login
2. Navigate to **Settings** → **Integrations** → **API Token**
3. Copy your API token

**In n8n:**
1. Click on **"Apify LinkedIn Scraper"** node
2. Click **"Credentials for Apify API"** dropdown
3. Select **"Create New Credential"**
4. Name: `Apify API`
5. Paste your API token
6. Click **"Save"**

### Step 2B: OpenAI Credentials

1. Go to [platform.openai.com](https://platform.openai.com)
2. Navigate to **API Keys** → **Create new secret key**
3. Copy the key (starts with `sk-`)

**In n8n:**
1. Click on **"OpenAI Post Analysis & Scoring"** node
2. Click **"Credentials for OpenAI"** dropdown
3. Select **"Create New Credential"**
4. Name: `OpenAI API`
5. Paste your API key
6. Click **"Save"**

**Repeat for "GPT Generate Brand Posts" node** (use same credential)

### Step 2C: Google Sheets Credentials

**In n8n:**
1. Click on **"Save to Google Sheets"** node
2. Click **"Credentials for Google Sheets API"** dropdown
3. Select **"Create New Credential"**
4. Choose **"OAuth2"** (recommended)
5. Click **"Connect my account"**
6. Authorize with Google
7. Click **"Save"**

**Configure Sheet:**
1. Create a new Google Sheet named: `LinkedIn Content Radar`
2. Copy the Sheet ID from URL: `https://docs.google.com/spreadsheets/d/{SHEET_ID}/edit`
3. In the node, paste the Sheet ID in **"Document"** field
4. Set **"Sheet Name"** to: `LinkedIn Content Radar`

### Step 2D: Google Drive Credentials

**In n8n:**
1. Click on **"Upload to Google Drive"** node
2. Click **"Credentials for Google Drive API"** dropdown
3. Select **"Create New Credential"**
4. Choose **"OAuth2"**
5. Click **"Connect my account"**
6. Authorize with Google
7. Click **"Save"**

**Configure Folder:**
1. Create a folder in Google Drive: `LinkedIn Weekly Radar`
2. Copy the Folder ID from URL: `https://drive.google.com/drive/folders/{FOLDER_ID}`
3. In the node, paste the Folder ID in **"Folder"** field

✅ **All credentials configured!**

---

## Part 3: Add Webhook Integration (5 minutes)

Now we'll add 6 webhook nodes to connect with your dashboard.

### Step 3A: Set n8n Environment Variables

**In n8n Settings:**
1. Go to **Settings** → **Environments** (or **Variables**)
2. Add these variables:

```
Name: DASHBOARD_WEBHOOK_URL
Value: http://localhost:3000
(Change to https://your-app.vercel.app when deployed)

Name: WEBHOOK_SECRET
Value: [Generate a random secret - see below]
```

**Generate webhook secret:**
```bash
openssl rand -base64 32
# Or use: https://generate-secret.vercel.app/32
```

**⚠️ Important:** Use the **exact same** secret in your dashboard's `.env.local` file!

---

### Step 3B: Add "Generate Run ID" Node

This must be the FIRST node after the trigger.

**Add Node:**
1. Click the **"+"** between "Schedule Trigger" and "10 Target LinkedIn Creators"
2. Search for: **"Code"**
3. Select **"Code"** node
4. Name it: `Generate Run ID`

**Configure:**
- Mode: **Run Once for All Items**
- Language: **JavaScript**

**Paste this code:**
```javascript
// Generate unique run ID for tracking
const runId = `run_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;

// Return with all existing data
return [{
  json: {
    runId: runId
  }
}];
```

**Connect:**
- Input: **Schedule Trigger**
- Output: **Webhook: Run Started** (we'll create this next)

---

### Step 3C: Add Webhook Node #1 - Run Started

**Add Node:**
1. Click **"+"** after "Generate Run ID"
2. Search for: **"HTTP Request"**
3. Name it: `Webhook: Run Started`

**Configure:**

**Request Method:** POST

**URL:**
```
={{ $env.DASHBOARD_WEBHOOK_URL }}/api/webhook/n8n
```

**Authentication:** None

**Send Headers:** Yes (toggle on)

**Headers:**
- Name: `X-Webhook-Secret` | Value: `={{ $env.WEBHOOK_SECRET }}`
- Name: `Content-Type` | Value: `application/json`

**Send Body:** Yes (toggle on)

**Body Content Type:** JSON

**Specify Body:** Using Fields Below

**JSON/RAW Parameters:**
Click **"Add Field"** and add these:

| Name | Value |
|------|-------|
| event | `run_started` |
| run_id | `={{ $('Generate Run ID').first().json.runId }}` |
| timestamp | `={{ new Date().toISOString() }}` |
| creators_count | `25` |

**Connect:**
- Input: **Generate Run ID**
- Output: **10 Target LinkedIn Creators**

---

### Step 3D: Add Webhook Node #2 - Posts Scraped

**Add Node:**
1. Click **"+"** after "Filter Posts (7 days, 100+ likes)"
2. This will run in PARALLEL with "OpenAI Post Analysis"
3. Search for: **"HTTP Request"**
4. Name it: `Webhook: Posts Scraped`

**Configure:**

**Request Method:** POST

**URL:**
```
={{ $env.DASHBOARD_WEBHOOK_URL }}/api/webhook/n8n
```

**Send Headers:** Yes

**Headers:**
- Name: `X-Webhook-Secret` | Value: `={{ $env.WEBHOOK_SECRET }}`
- Name: `Content-Type` | Value: `application/json`

**Send Body:** Yes

**Body Content Type:** JSON

**Specify Body:** Using Fields Below

**JSON/RAW Parameters:**
| Name | Value |
|------|-------|
| event | `posts_scraped` |
| run_id | `={{ $('Generate Run ID').first().json.runId }}` |
| posts | `={{ $input.all() }}` |

**Connect:**
- Input: **Filter Posts (7 days, 100+ likes)**
- Output: None (runs in parallel, doesn't block workflow)

---

### Step 3E: Add Webhook Node #3 - Analysis Complete

**Add Node:**
1. Click **"+"** after "Calculate & Rank (Top 15)"
2. Runs in PARALLEL with "GPT Generate Brand Posts"
3. Search for: **"HTTP Request"**
4. Name it: `Webhook: Analysis Complete`

**Configure:**

**Request Method:** POST

**URL:**
```
={{ $env.DASHBOARD_WEBHOOK_URL }}/api/webhook/n8n
```

**Send Headers:** Yes

**Headers:**
- Name: `X-Webhook-Secret` | Value: `={{ $env.WEBHOOK_SECRET }}`
- Name: `Content-Type` | Value: `application/json`

**Send Body:** Yes

**Body Content Type:** JSON

**Specify Body:** Using Fields Below

**JSON/RAW Parameters:**
| Name | Value |
|------|-------|
| event | `analysis_complete` |
| run_id | `={{ $('Generate Run ID').first().json.runId }}` |
| analyzed_posts | `={{ $input.all() }}` |

**Connect:**
- Input: **Calculate & Rank (Top 15)**
- Output: None (parallel)

---

### Step 3F: Add Webhook Node #4 - Generation Complete

**Add Node:**
1. Click **"+"** after "Select Top 7 Final Posts"
2. Runs in PARALLEL with "Save to Google Sheets"
3. Search for: **"HTTP Request"**
4. Name it: `Webhook: Generation Complete`

**Configure:**

**Request Method:** POST

**URL:**
```
={{ $env.DASHBOARD_WEBHOOK_URL }}/api/webhook/n8n
```

**Send Headers:** Yes

**Headers:**
- Name: `X-Webhook-Secret` | Value: `={{ $env.WEBHOOK_SECRET }}`
- Name: `Content-Type` | Value: `application/json`

**Send Body:** Yes

**Body Content Type:** JSON

**Specify Body:** Using Fields Below

**JSON/RAW Parameters:**
| Name | Value |
|------|-------|
| event | `generation_complete` |
| run_id | `={{ $('Generate Run ID').first().json.runId }}` |
| generated_posts | `={{ $input.all() }}` |

**Connect:**
- Input: **Select Top 7 Final Posts**
- Output: None (parallel)

---

### Step 3G: Add Webhook Node #5 - Run Complete

**Add Node:**
1. Click **"+"** at the very END (after "Upload to Google Drive")
2. Search for: **"HTTP Request"**
3. Name it: `Webhook: Run Complete`

**Configure:**

**Request Method:** POST

**URL:**
```
={{ $env.DASHBOARD_WEBHOOK_URL }}/api/webhook/n8n
```

**Send Headers:** Yes

**Headers:**
- Name: `X-Webhook-Secret` | Value: `={{ $env.WEBHOOK_SECRET }}`
- Name: `Content-Type` | Value: `application/json`

**Send Body:** Yes

**Body Content Type:** JSON

**Specify Body:** Using Fields Below

**JSON/RAW Parameters:**

Create a JSON structure like this (use "Add Field" for each):

```json
{
  "event": "run_complete",
  "run_id": "={{ $('Generate Run ID').first().json.runId }}",
  "status": "completed",
  "stats": {
    "creators_scraped": 25,
    "posts_scraped": "={{ $('Filter Posts (7 days, 100+ likes)').all().length }}",
    "posts_analyzed": "={{ $('Calculate & Rank (Top 15)').all().length }}",
    "posts_generated": 7,
    "openai_calls": 30,
    "openai_cost_usd": 2.50
  },
  "outputs": {
    "google_sheet_url": "YOUR_SHEET_URL",
    "google_drive_pdf_url": "={{ $('Upload to Google Drive').first().json.webViewLink }}"
  }
}
```

**Connect:**
- Input: **Upload to Google Drive**
- Output: None (final node)

✅ **All webhook nodes added!**

---

## Part 4: Visual Check - Final Workflow Structure

Your workflow should now look like this:

```
1. Schedule Trigger (Every Sunday 2PM)
       ↓
2. Generate Run ID [NEW]
       ↓
3. Webhook: Run Started [NEW] ────────→ Dashboard ✉️
       ↓
4. 10 Target LinkedIn Creators
       ↓
5. Split Into Items
       ↓
6. Apify LinkedIn Scraper
       ↓
7. Filter Posts (7 days, 100+ likes)
       ├─→ Webhook: Posts Scraped [NEW] ─→ Dashboard ✉️
       ↓
8. OpenAI Post Analysis & Scoring
       ↓
9. Calculate & Rank (Top 15)
       ├─→ Webhook: Analysis Complete [NEW] → Dashboard ✉️
       ↓
10. GPT Generate Brand Posts
       ↓
11. Select Top 7 Final Posts
       ├─→ Webhook: Generation Complete [NEW] → Dashboard ✉️
       ↓
12. Save to Google Sheets
       ↓
13. Generate PDF HTML
       ↓
14. Convert HTML to PDF
       ↓
15. Upload to Google Drive
       ↓
16. Webhook: Run Complete [NEW] ──────→ Dashboard ✉️
```

**Node Count:**
- Original workflow: 13 nodes
- Added: 2 nodes (Generate Run ID + 5 webhooks)
- **Total: 18 nodes**

---

## Part 5: Test the Complete System

### Step 5A: Start Your Dashboard

```bash
cd linkedin-radar-dashboard
npm run dev
```

Dashboard should be running at: `http://localhost:3000`

### Step 5B: Verify n8n Environment Variables

Check that these are set:
- ✅ `DASHBOARD_WEBHOOK_URL = http://localhost:3000`
- ✅ `WEBHOOK_SECRET = your-secret-here`

### Step 5C: Test Workflow Execution

**In n8n:**
1. Click **"Execute Workflow"** button (top right)
2. Watch each node execute
3. Green checkmarks = success
4. Red X = error (click to see details)

**Monitor Dashboard Terminal:**
You should see webhook logs:
```
[Webhook] Received event: run_started
[Webhook] Run run_1730123456789_abc123 started
[Webhook] Received event: posts_scraped
[Webhook] Inserted 50 posts for run run_1730123456789_abc123
[Webhook] Received event: analysis_complete
[Webhook] Updated 50 posts with AI scores
[Webhook] Received event: generation_complete
[Webhook] Inserted 7 generated posts
[Webhook] Received event: run_complete
[Webhook] Run run_1730123456789_abc123 completed with status: completed
```

### Step 5D: Verify Data in Supabase

**Go to Supabase Dashboard → Table Editor:**

1. **automation_runs table:**
   - Should have 1 new row
   - Status: `completed`
   - Duration populated

2. **posts table:**
   - Should have 50-150 new rows
   - `is_analyzed = true`
   - Scores populated

3. **generated_posts table:**
   - Should have 7 new rows
   - Rank 1-7
   - Status: `draft`

### Step 5E: Check Dashboard UI

**Open:** `http://localhost:3000`

**You should see:**
- ✅ Dashboard with updated metrics
- ✅ Posts analyzed count increased
- ✅ 7 new generated posts in suggestions
- ✅ Latest run in automation history

---

## Part 6: Troubleshooting

### Issue: Webhook nodes show errors

**Check:**
1. Dashboard is running (`npm run dev`)
2. URL is correct: `http://localhost:3000/api/webhook/n8n`
3. Webhook secret matches in both places
4. Headers include `X-Webhook-Secret`

**Test manually:**
```bash
curl -X POST http://localhost:3000/api/webhook/n8n \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Secret: your-secret" \
  -d '{"event":"run_started","run_id":"test_123","timestamp":"2025-10-25T14:00:00Z","creators_count":25}'
```

Expected: `{"success":true,"message":"Webhook received","event":"run_started"}`

### Issue: Apify scraper fails

**Check:**
1. Valid Apify API token
2. Sufficient credits in Apify account
3. LinkedIn session cookie configured (if required)

### Issue: OpenAI requests fail

**Check:**
1. Valid OpenAI API key (starts with `sk-`)
2. GPT-4 access enabled on your account
3. Sufficient credits/billing set up

### Issue: Data not in Supabase

**Check:**
1. Ran `supabase/schema.sql` in Supabase SQL Editor
2. Tables exist: `automation_runs`, `posts`, `generated_posts`
3. `SUPABASE_SERVICE_ROLE_KEY` set in dashboard `.env.local`
4. Check dashboard terminal for database errors

---

## Part 7: Update Creator List

**Edit the workflow:**
1. Click on **"10 Target LinkedIn Creators"** node
2. Update the `creators` array with your 25 confirmed creators
3. Click **"Save"**

The list is already populated with your 25 creators:
- agrim-goyal
- jessievanbreugel
- domingo-valadez
- ... (and 22 more)

---

## Part 8: Schedule Activation

Once testing is successful:

1. Click **"Active"** toggle (top right)
2. Workflow will now run automatically every Sunday at 2PM (Paris time)
3. Dashboard will update in real-time

---

## Part 9: Deploy to Production

### Deploy Dashboard:
```bash
# Push to GitHub
git push origin main

# Deploy to Vercel
# Connect GitHub repo at vercel.com
# Add environment variables
# Deploy!
```

### Update n8n:
```
DASHBOARD_WEBHOOK_URL = https://your-app.vercel.app
```

---

## ✅ Setup Complete Checklist

- [ ] Imported `LinkedIn_Content_Radar_Workflow.json` ✅
- [ ] Configured Apify credentials ✅
- [ ] Configured OpenAI credentials ✅
- [ ] Configured Google Sheets credentials ✅
- [ ] Configured Google Drive credentials ✅
- [ ] Set n8n environment variables ✅
- [ ] Added "Generate Run ID" node ✅
- [ ] Added 5 webhook HTTP Request nodes ✅
- [ ] Each webhook has correct headers ✅
- [ ] Each webhook has correct JSON body ✅
- [ ] Tested workflow execution ✅
- [ ] Verified dashboard receives webhooks ✅
- [ ] Confirmed data in Supabase tables ✅
- [ ] Dashboard UI shows real-time updates ✅
- [ ] Workflow activated for Sunday schedule ✅

---

## 🎉 You're Live!

Your complete LinkedIn Content Radar system is now:

✅ **Scraping** - 25 creators every Sunday
✅ **Analyzing** - AI scores with OpenAI GPT-4
✅ **Generating** - 7 brand-ready posts
✅ **Storing** - All data in Supabase
✅ **Displaying** - Beautiful Scripe-inspired dashboard
✅ **Real-time** - Webhooks update instantly

**Weekly output:**
- 📊 150+ posts analyzed
- 🎯 Top 15 scored and ranked
- ✍️ 7 LinkedIn posts ready to publish
- 📈 Complete analytics in dashboard
- 📄 PDF report in Google Drive

**Next steps:**
1. Review and edit generated posts weekly
2. Publish throughout the week
3. Track performance
4. Adjust creator list as needed
5. Scale as your content grows!

---

**Need help?** Check the other guides:
- `README.md` - Dashboard setup
- `PROJECT_ARCHITECTURE.md` - Technical details
- `COMPONENTS_GUIDE.md` - UI components
- `WEBHOOK_INTEGRATION_GUIDE.md` - Webhook reference

Happy automating! 🚀
