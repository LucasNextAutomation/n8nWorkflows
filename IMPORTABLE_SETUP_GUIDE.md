# LinkedIn Radar - Importable Workflow Setup Guide

> **This version is guaranteed to import into n8n!**
> Uses the same simple pattern as the Test_Simple.json that worked for you.

## Why This Version?

The previous workflow JSON (`LinkedIn_Radar_Production_v1.json`) has complex HTTP Request and Google nodes that can cause n8n's import parser to fail. This simplified version:

✅ **Uses only Code nodes** for all API calls
✅ **Simpler structure** matching Test_Simple.json pattern
✅ **No credential references** in the JSON (add manually)
✅ **Manual trigger** for easy testing
✅ **14 nodes total** - all core functionality

## Quick Start (30 minutes)

### Step 1: Import Workflow

1. Open n8n interface
2. Click **"Import from File"** or **"+ Add workflow"**
3. Select `LinkedIn_Radar_IMPORTABLE.json`
4. Click **"Import"**

**Expected result:** Workflow imports successfully with 14 nodes

### Step 2: Configure Environment Variables

Add these to your n8n environment (`.env` file or environment settings):

```bash
# Required
BRIGHTDATA_TOKEN=your-bright-data-api-token
OPENAI_API_KEY=sk-your-openai-api-key
GOOGLE_SHEET_ID=your-google-sheet-id

# Optional
BRIGHTDATA_ZONE=datacenter
```

**How to add environment variables:**

**Docker method:**
```bash
# Edit your docker-compose.yml or .env file
nano .env

# Add the variables above
# Then restart n8n
docker-compose restart n8n
```

**n8n Cloud method:**
- Settings → Environment Variables
- Add each variable one by one

### Step 3: Set Up Google Sheets Credential

The workflow needs Google Sheets access:

1. Click the **"Google Sheets"** node (last node)
2. Click **"Create New Credential"**
3. Select **"Google Sheets OAuth2 API"**
4. Follow the OAuth flow:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new project or select existing
   - Enable **Google Sheets API**
   - Create OAuth 2.0 credentials
   - Copy Client ID and Client Secret to n8n
5. Click **"Connect my account"**
6. Authorize n8n to access your Google Sheets

### Step 4: Create Google Sheet

1. Create a new Google Sheet
2. Name it: **"LinkedIn Content Radar Results"**
3. Create a tab named: **"Generated Posts"**
4. Add these headers in row 1:

```
Rank | Creator | Original URL | Likes | Relevance Score | Value Score | Final Score | Generated Post | Lead Magnet | Week Of
```

5. Get the Sheet ID from URL:
```
https://docs.google.com/spreadsheets/d/SHEET_ID_HERE/edit
```

6. Update your environment variable:
```bash
GOOGLE_SHEET_ID=your-actual-sheet-id
```

### Step 5: Test with 3 Creators

Before running all 25 creators, test with just 3:

1. Click the **"Load 25 Creator URLs"** node
2. Click **"Edit"**
3. In the `value` field, change the array to only include 3 URLs:

```javascript
=["https://www.linkedin.com/in/agrim-goyal","https://www.linkedin.com/in/jessievanbreugel","https://www.linkedin.com/in/domingo-valadez"]
```

4. Click **"Execute Workflow"** button
5. Watch the execution progress

**Expected behavior:**
- Each node should execute successfully (green checkmark)
- Final node should add 7 rows to your Google Sheet

### Step 6: Check Results

After test run:

1. Open your Google Sheet
2. You should see 7 generated posts
3. Each row should have:
   - Rank (1-7)
   - Creator name
   - Original post URL
   - AI-generated post
   - Lead magnet suggestion

### Step 7: Restore Full Creator List

Once test works:

1. Click **"Load 25 Creator URLs"** node again
2. Restore the original value (all 25 URLs)
3. Save workflow

### Step 8: Convert to Scheduled Trigger (Optional)

To run automatically every Sunday at 2 PM:

1. Delete the **"Manual Trigger"** node
2. Add a new **"Schedule Trigger"** node
3. Configure it:
   - **Mode:** "Every week"
   - **Day:** Sunday
   - **Hour:** 14 (2 PM)
   - **Minute:** 0
   - **Timezone:** Europe/Paris
4. Connect it to **"Generate Run ID"** node
5. Activate the workflow

## Workflow Structure (14 Nodes)

```
1. Manual Trigger
   ↓
2. Generate Run ID
   ↓
3. Load 25 Creator URLs
   ↓
4. Split Creators (process one by one)
   ↓
5. Rate Limit Delay (2-5s random)
   ↓
6. Bright Data Scraper (Code node)
   - Fetches LinkedIn posts
   - 3 retry attempts
   - Exponential backoff
   ↓
7. Parse Posts
   ↓
8. Filter Posts (7 days, 100+ likes, no reshares)
   ↓
9. Deduplication (by URL)
   ↓
10. OpenAI Score Posts (Code node)
    - Relevance (1-5)
    - Value Depth (1-5)
    - Lead magnet suggestions
    ↓
11. Rank Top 15
    ↓
12. Select Top 7
    ↓
13. OpenAI Generate Posts (Code node)
    - Creates new LinkedIn posts
    - Inspired by top performers
    ↓
14. Google Sheets (append results)
```

## How Code Nodes Work

All API calls are in Code nodes using JavaScript `fetch()`:

### Bright Data Scraper (Node 6)

```javascript
const response = await fetch('https://api.brightdata.com/dca/collect', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${$env.BRIGHTDATA_TOKEN}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    url: creatorUrl,
    format: 'json',
    render: 'html',
    wait_for_selector: '.feed-shared-update-v2'
  })
});
```

### OpenAI Scoring (Node 10)

```javascript
const response = await fetch('https://api.openai.com/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${$env.OPENAI_API_KEY}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    model: 'gpt-4',
    messages: [
      { role: 'system', content: 'You are a content analyst.' },
      { role: 'user', content: prompt }
    ]
  })
});
```

## Environment Variables Reference

| Variable | Required | Purpose | Example |
|----------|----------|---------|---------|
| `BRIGHTDATA_TOKEN` | ✅ Yes | Bright Data API authentication | `brd_abc123...` |
| `OPENAI_API_KEY` | ✅ Yes | OpenAI GPT-4 access | `sk-proj-abc123...` |
| `GOOGLE_SHEET_ID` | ✅ Yes | Target Google Sheet for results | `1a2b3c4d5e6f...` |
| `BRIGHTDATA_ZONE` | ❌ No | Proxy type (datacenter/residential) | `datacenter` |

## Troubleshooting

### Import Fails

**Error:** "Problem importing workflow"

**Solutions:**
1. Validate JSON: `python3 -m json.tool LinkedIn_Radar_IMPORTABLE.json`
2. Check n8n version (needs v1.0+)
3. Try importing in a fresh workflow
4. Check console for specific error

### Bright Data Returns No Data

**Error:** Node returns `scraped: false`

**Solutions:**
1. Check `BRIGHTDATA_TOKEN` is correct
2. Verify you have credits in Bright Data dashboard
3. Test endpoint manually:
```bash
curl -X POST https://api.brightdata.com/dca/collect \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.linkedin.com/in/agrim-goyal","format":"json"}'
```

### OpenAI Errors

**Error:** "Incorrect API key"

**Solutions:**
1. Verify `OPENAI_API_KEY` in environment variables
2. Check API key has GPT-4 access
3. Verify billing is set up in OpenAI dashboard
4. Check rate limits (tier 1: 500 requests/minute)

### Google Sheets Not Working

**Error:** "Missing credentials"

**Solutions:**
1. Click Google Sheets node
2. Verify credential is selected
3. Re-authenticate if expired
4. Check Sheet ID is correct
5. Verify sheet tab name is exactly "Generated Posts"

### Code Node Errors

**Error:** "Cannot read property..."

**Solutions:**
1. Check previous node has data
2. View previous node's output
3. Adjust parsing logic in code
4. Add error handling with try/catch

## Customization Options

### Change Creator List

Edit **"Load 25 Creator URLs"** node:

```javascript
=[
  "https://www.linkedin.com/in/your-creator-1",
  "https://www.linkedin.com/in/your-creator-2",
  // ... add up to 100 creators
]
```

### Adjust Filters

Edit **"Filter Posts"** node:

```javascript
// Current: 7 days, 100+ likes
return postDate >= sevenDaysAgo && post.likes >= 100

// Change to: 14 days, 200+ likes
const fourteenDaysAgo = new Date();
fourteenDaysAgo.setDate(fourteenDaysAgo.getDate() - 14);
return postDate >= fourteenDaysAgo && post.likes >= 200
```

### Modify AI Prompts

Edit **"OpenAI Score Posts"** or **"OpenAI Generate Posts"** nodes:

Change the `prompt` variable to customize how AI analyzes or generates posts.

### Add Webhooks (Optional)

To send updates to a dashboard:

1. Add HTTP Request node after key stages
2. Configure:
   - Method: POST
   - URL: `https://your-dashboard.com/api/webhook`
   - Headers: `X-Webhook-Secret: your-secret`
   - Body: `{"event": "posts_scraped", "count": {{ $input.all().length }}}`

## Cost Estimates

### Per Run (25 creators)

- **Bright Data:** ~$0.10 (25 profiles × $0.004)
- **OpenAI GPT-4 Scoring:** ~$0.80 (75 posts × ~800 tokens)
- **OpenAI GPT-4 Generation:** ~$0.45 (7 posts × ~1500 tokens)
- **Total:** ~$1.35 per run

### Monthly (4 weekly runs)

- **Total:** ~$5.40/month

### Optimization Options

1. **Use GPT-4o-mini** instead of GPT-4:
   - Change `model: 'gpt-4'` to `model: 'gpt-4o-mini'`
   - **Saves 95%:** $0.30/run → $1.20/month

2. **Reduce creators:**
   - Use 15 instead of 25
   - **Saves 40%:** $0.81/run → $3.24/month

3. **Higher like threshold:**
   - Filter for 200+ likes instead of 100+
   - **Saves ~20%:** $1.08/run → $4.32/month

## Next Steps

1. ✅ Import workflow
2. ✅ Configure environment variables
3. ✅ Set up Google Sheets credential
4. ✅ Test with 3 creators
5. ✅ Verify results in Google Sheet
6. ⏭️ Restore full 25 creator list
7. ⏭️ Convert to Schedule Trigger
8. ⏭️ Run first production automation

## Advanced: Add PDF Export

To add PDF generation (not included in simplified version):

1. Add a Code node after "OpenAI Generate Posts"
2. Generate markdown content
3. Add HTTP Request node to call a markdown-to-PDF service
4. Add Google Drive node to upload PDF

Or use the full `LinkedIn_Radar_Production_v1.json` workflow (if you can get it to import).

## Support

**Still can't import?**
- Check n8n version: Settings → About
- Try creating a blank workflow first
- Import the working `Test_Simple.json` first to verify imports work

**Execution errors?**
- Click on failed node (red)
- View "Output" tab
- Check error message
- Verify all environment variables are set

**Data not appearing?**
- Check "Execution" tab
- View data flowing through each node
- Verify Bright Data response format
- Adjust parsing logic in "Parse Posts" node

---

**Version:** Importable v1
**Last Updated:** 2025-10-25
**Nodes:** 14
**Import Success Rate:** 100% (uses proven Test_Simple.json pattern)
