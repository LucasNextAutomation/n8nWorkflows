# Production Deployment Guide

This guide walks you through deploying the **LinkedIn Content Radar Production v1** workflow to your n8n instance.

## Prerequisites Checklist

Before starting, ensure you have:

- [ ] n8n instance running (Docker or cloud)
- [ ] Bright Data account with API token
- [ ] OpenAI API key with GPT-4 access
- [ ] Google account with Sheets and Drive access
- [ ] Dashboard webhook endpoint (optional, can disable)
- [ ] All environment variables configured

## Part 1: Environment Variables

### Step 1.1: Configure n8n Environment Variables

Add these to your n8n `.env` file or environment configuration:

```bash
# Bright Data Configuration
BRIGHTDATA_TOKEN=your-bright-data-api-token-here
BRIGHTDATA_ZONE=datacenter  # or 'residential' for higher quality

# OpenAI Configuration
OPENAI_API_KEY=sk-your-openai-api-key-here

# Dashboard Webhook (Optional)
DASHBOARD_WEBHOOK_URL=https://your-dashboard.com
WEBHOOK_SECRET=your-random-secret-here

# Google Sheets & Drive
GOOGLE_SHEET_ID=your-google-sheet-id
GOOGLE_DRIVE_FOLDER_ID=your-google-drive-folder-id
```

### Step 1.2: Restart n8n

After adding environment variables:

```bash
# Docker
docker-compose restart n8n

# Or if using docker run
docker restart n8n
```

Verify variables are loaded:
- Go to n8n Settings → Variables
- Check that your variables appear

## Part 2: Import Workflow

### Step 2.1: Download Workflow File

The workflow file is: `LinkedIn_Radar_Production_v1.json`

### Step 2.2: Import into n8n

1. Open n8n interface
2. Click **"+ Add workflow"** or **"Import from File"**
3. Select `LinkedIn_Radar_Production_v1.json`
4. Click **"Import"**

The workflow should import successfully with **28 nodes**.

### Step 2.3: Verify Import

Check that all nodes are present:
- ✅ Schedule Trigger
- ✅ Generate Run ID
- ✅ 5 Webhook nodes
- ✅ Bright Data scraping node
- ✅ OpenAI scoring node
- ✅ OpenAI generation node
- ✅ Google Sheets node
- ✅ Google Drive node

## Part 3: Configure Credentials

### Step 3.1: Google Sheets OAuth2

1. Click on **"Append to Google Sheets"** node
2. Click **"Create New Credential"**
3. Select **"Google Sheets OAuth2 API"**
4. Follow Google OAuth flow:
   - Go to Google Cloud Console
   - Enable Google Sheets API
   - Create OAuth 2.0 credentials
   - Copy Client ID and Secret to n8n
5. Authorize access
6. Test connection

### Step 3.2: Google Drive OAuth2

1. Click on **"Upload PDF to Google Drive"** node
2. Click **"Create New Credential"**
3. Select **"Google Drive OAuth2 API"**
4. Follow same OAuth flow as Sheets
5. Enable Google Drive API in console
6. Authorize access
7. Test connection

### Step 3.3: Verify Environment Variables

The workflow automatically reads these from environment:
- `$env.BRIGHTDATA_TOKEN`
- `$env.OPENAI_API_KEY`
- `$env.DASHBOARD_WEBHOOK_URL`
- `$env.WEBHOOK_SECRET`

No credential nodes needed for these - they're accessed directly via `$env`.

## Part 4: Configure Google Sheet

### Step 4.1: Create Google Sheet

1. Create a new Google Sheet
2. Name it: **"LinkedIn Content Radar Results"**
3. Create a sheet tab named: **"Generated Posts"**

### Step 4.2: Add Headers

In the first row, add these column headers:

```
Rank | Creator | Original URL | Posted Date | Likes | Comments | Relevance Score | Value Depth Score | Final Score | Generated Post | Lead Magnet | Week Of | OpenAI Cost | Bright Data Cost | Total Cost
```

### Step 4.3: Get Sheet ID

From the URL:
```
https://docs.google.com/spreadsheets/d/1abc123def456/edit
                                        ^^^^^^^^^^^
                                        This is your SHEET_ID
```

Update your `.env`:
```bash
GOOGLE_SHEET_ID=1abc123def456
```

## Part 5: Configure Google Drive

### Step 5.1: Create Folder

1. Go to Google Drive
2. Create a folder: **"LinkedIn Content Radar PDFs"**
3. Right-click folder → **"Get link"** → **"Share"**

### Step 5.2: Get Folder ID

From the URL:
```
https://drive.google.com/drive/folders/1xyz789abc123
                                         ^^^^^^^^^^^
                                         This is your FOLDER_ID
```

Update your `.env`:
```bash
GOOGLE_DRIVE_FOLDER_ID=1xyz789abc123
```

## Part 6: Configure Webhook Integration (Optional)

If you have the dashboard running:

### Step 6.1: Verify Webhook Endpoint

Test the webhook endpoint is accessible:

```bash
curl -X POST https://your-dashboard.com/api/webhook/n8n \
  -H "X-Webhook-Secret: your-secret" \
  -H "Content-Type: application/json" \
  -d '{"event":"test","data":"hello"}'
```

You should get: `{"success": true}`

### Step 6.2: Disable Webhooks (If No Dashboard)

If you don't have the dashboard yet, you can disable webhook nodes:

1. Click on each webhook node
2. Click **"Disable"** toggle
3. Workflow will still run, just won't send updates

Webhook nodes to disable:
- Webhook: Run Started
- Webhook: Posts Scraped
- Webhook: Analysis Complete
- Webhook: Generation Complete
- Webhook: Run Complete

## Part 7: Test Workflow

### Step 7.1: Small Test Run (3 Creators)

Before running full 25 creators, test with 3:

1. Click **"25 LinkedIn Creators"** node
2. Edit the `creators` array
3. Keep only first 3 URLs:

```javascript
=[
  "https://www.linkedin.com/in/agrim-goyal",
  "https://www.linkedin.com/in/jessievanbreugel",
  "https://www.linkedin.com/in/domingo-valadez"
]
```

4. Click **"Execute Workflow"**
5. Monitor execution in n8n UI

### Step 7.2: Verify Test Results

Check:
- ✅ Bright Data scraped 3 profiles successfully
- ✅ Posts were parsed and filtered
- ✅ OpenAI scored posts
- ✅ Top posts were generated
- ✅ Data appeared in Google Sheets
- ✅ PDF was created in Google Drive

### Step 7.3: Check Costs

After test run, check the execution log:
- Look for **"Calculate Total Costs"** node output
- Verify costs are reasonable (~$0.30-0.50 for 3 creators)

Example output:
```json
{
  "openaiCostUsd": 0.45,
  "brightdataCostUsd": 0.012,
  "totalCostUsd": 0.462
}
```

## Part 8: Production Deployment

### Step 8.1: Restore Full Creator List

1. Click **"25 LinkedIn Creators"** node
2. Restore all 25 URLs (or add your own list)
3. Save workflow

### Step 8.2: Verify Schedule

1. Click **"Schedule Trigger"** node
2. Verify schedule: `0 14 * * 0` (Sundays at 2 PM Paris time)
3. Adjust timezone if needed

### Step 8.3: Activate Workflow

1. Click **"Activate"** toggle at top right
2. Workflow status should change to **"Active"**
3. Next run will be shown in the UI

### Step 8.4: Manual Test Run

Before waiting for Sunday, run manually:

1. Click **"Execute Workflow"** button
2. Monitor execution (takes 7-11 minutes)
3. Watch for any errors

## Part 9: Monitor & Optimize

### Step 9.1: Check First Production Run

After first automated run:

1. Check Google Sheets for 7 generated posts
2. Check Google Drive for PDF
3. Review costs in final webhook or sheet
4. Check execution history in n8n

### Step 9.2: Cost Monitoring

Expected costs per run:
- **OpenAI GPT-4:** ~$1.25
- **Bright Data:** ~$0.10
- **Total:** ~$1.35/run
- **Monthly (4 runs):** ~$5.40

If costs are higher:
- Check token usage in execution logs
- Consider using GPT-4o-mini for scoring (cheaper)
- Reduce number of creators

### Step 9.3: Adjust Prompts

To improve generated posts:

1. Edit **"OpenAI: Generate Posts"** node
2. Modify the prompt in the `jsCode`
3. Test with manual execution
4. Save when satisfied

### Step 9.4: Error Handling

If workflow fails:

1. Check **Execution History** in n8n
2. Look for red nodes (errors)
3. Common issues:
   - **Bright Data timeout:** Increase retry attempts
   - **OpenAI rate limit:** Add delay between calls
   - **Google Sheets error:** Check credential expiration

## Part 10: Advanced Configuration

### Step 10.1: Deduplication with Database

For true deduplication (avoid re-analyzing same posts):

1. Set up Supabase or PostgreSQL
2. Modify **"Deduplication Check"** node
3. Query database for existing `post_url`
4. Skip posts analyzed in last 30 days

Example code:
```javascript
const posts = $input.all();
const supabase = /* your supabase client */;

const unique = [];
for (const item of posts) {
  const { data } = await supabase
    .from('posts')
    .select('id')
    .eq('post_url', item.json.postUrl)
    .gte('created_at', new Date(Date.now() - 30*24*60*60*1000).toISOString());

  if (data.length === 0) {
    unique.push(item);
  }
}
return unique;
```

### Step 10.2: Batch Processing (Faster)

To speed up OpenAI calls, batch posts:

1. Add **"Batch Items"** node before OpenAI scoring
2. Process 5 posts at once in single API call
3. Modify OpenAI prompt to handle array

### Step 10.3: Custom Creator Lists

To rotate creator lists:

1. Store creator URLs in Google Sheets
2. Add **"Google Sheets: Read"** node at start
3. Replace static creator list
4. Update sheet weekly with new creators

## Part 11: Dashboard Integration

If you have the Next.js dashboard:

### Step 11.1: Deploy Dashboard

Follow dashboard setup from `linkedin-radar-dashboard/README.md`

### Step 11.2: Configure Webhook Secret

Match secrets in both systems:

**n8n .env:**
```bash
WEBHOOK_SECRET=abc123xyz789
```

**Dashboard .env:**
```bash
WEBHOOK_SECRET=abc123xyz789
```

### Step 11.3: Test Webhook

Run workflow and check dashboard:
- Navigate to Dashboard page
- Should see real-time updates
- Check Logs page for webhook events

## Troubleshooting

### Issue: Workflow won't import

**Solution:**
- Verify JSON is valid: `python3 -m json.tool LinkedIn_Radar_Production_v1.json`
- Check n8n version (requires v1.0+)
- Try importing in fresh n8n instance

### Issue: Bright Data returns no data

**Solutions:**
- Verify `BRIGHTDATA_TOKEN` is correct
- Check Bright Data dashboard for credits
- Test endpoint manually:
```bash
curl -X POST https://api.brightdata.com/dca/collect \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://www.linkedin.com/in/agrim-goyal","format":"json"}'
```

### Issue: OpenAI errors

**Solutions:**
- Check API key has GPT-4 access
- Verify billing is set up
- Check rate limits (tier 1: 500 RPM)
- Consider adding delays between calls

### Issue: Google Sheets authentication expired

**Solution:**
- Re-authorize Google OAuth
- Go to Credentials → Edit → Re-authorize
- May need to refresh token every 7 days

### Issue: Costs too high

**Solutions:**
- Use GPT-4o-mini instead of GPT-4 ($0.15/1M vs $10/1M tokens)
- Reduce number of creators
- Increase like threshold (filter more aggressively)
- Cache results to avoid re-processing

## Production Checklist

Before going live, verify:

- [ ] All environment variables set
- [ ] Google Sheets credential working
- [ ] Google Drive credential working
- [ ] Test run completed successfully (3 creators)
- [ ] Costs reviewed and acceptable
- [ ] Schedule configured correctly
- [ ] Workflow activated
- [ ] Webhook integration tested (if applicable)
- [ ] Error monitoring set up
- [ ] Backup workflow JSON saved
- [ ] Documentation reviewed

## Next Steps

1. **Week 1:** Monitor first automated run closely
2. **Week 2:** Review generated posts quality
3. **Week 3:** Optimize prompts based on results
4. **Week 4:** Consider scaling to more creators

## Support

For issues:
- Check n8n community forum
- Review execution logs in n8n UI
- Test each node individually
- Check API documentation for Bright Data/OpenAI

## Cost Optimization Tips

1. **Use GPT-4o-mini for scoring** (95% cheaper)
2. **Batch OpenAI calls** (5 posts per call)
3. **Filter aggressively** (higher like threshold)
4. **Cache Bright Data results** (avoid re-scraping)
5. **Run bi-weekly** instead of weekly (halve costs)

---

**Estimated Setup Time:** 45-60 minutes
**Estimated Cost per Run:** $1.35
**Estimated Run Duration:** 7-11 minutes
