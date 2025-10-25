# LinkedIn Content Radar - Bright Data Unlocker Setup Guide

> **Production-ready workflow using Bright Data's Unlocker API with your credentials**

## 🎯 What This Workflow Does

Uses **Bright Data Unlocker API** to:
1. Scrape 25 LinkedIn creator activity feeds
2. Extract recent posts (text, likes, comments, date)
3. Filter posts (7 days, 100+ likes, no reshares)
4. Score with OpenAI GPT-4
5. Generate 7 new LinkedIn posts
6. Export to Google Sheets

**Key advantage:** Bright Data handles all anti-bot measures, CAPTCHAs, and unlocking automatically.

---

## ⚡ Quick Start (40 minutes)

### Prerequisites

✅ **You already have:**
- Bright Data account with `linkedin_unlocker` zone
- API Token: `8d6d87d5...` (already in workflow)
- $4.84 balance (enough for testing)

❓ **You need to add:**
- OpenAI API key (GPT-4 access)
- Google Sheets credential in n8n
- Google Sheet ID

---

## 🧪 Step 1: Test Bright Data First (IMPORTANT!)

Before importing the workflow, let's verify Bright Data works with LinkedIn:

### Test Command

Run this in your terminal:

```bash
curl --http1.1 -X POST https://api.brightdata.com/request \
  -H "Authorization: Bearer 8d6d87d5de48ae3e4e78cc8a7df1d1945bfb26d4af7775a8215e2b0ac2dee1c6" \
  -H "Content-Type: application/json" \
  -d '{
    "zone": "linkedin_unlocker",
    "url": "https://www.linkedin.com/in/zeyneb-madi-6821b521b/recent-activity/all/",
    "format": "raw",
    "country": "us"
  }'
```

### What to Expect

**Success Response (200 OK):**
```html
<!DOCTYPE html>
<html lang="en">
  <head>...</head>
  <body>
    <!-- LinkedIn HTML with posts -->
    <div data-urn="urn:li:activity:1234567890">
      <span class="commentary">Post text here...</span>
      <span>123 likes</span>
    </div>
  </body>
</html>
```

**Error Response (401/403):**
```json
{
  "error": "Unauthorized",
  "message": "Invalid API token"
}
```

**Rate Limit Response (429):**
```json
{
  "error": "Too Many Requests",
  "message": "Rate limit: 1000 requests/minute"
}
```

### Troubleshooting Test

| Issue | Solution |
|-------|----------|
| `401 Unauthorized` | Check API token in Bright Data dashboard |
| `403 Forbidden` | Verify `linkedin_unlocker` zone is active |
| `429 Rate Limit` | Wait 60 seconds, you hit 1000 req/min limit |
| `Empty response` | LinkedIn blocked request - Bright Data may need config |
| `HTML but no posts` | URL might need authentication (see Alternative URLs below) |

---

## 📥 Step 2: Import Workflow

### Import File

```
LinkedIn_Radar_Unlocker_Production.json
```

### Import Steps

1. Open n8n interface
2. Click **"Import from File"**
3. Select `LinkedIn_Radar_Unlocker_Production.json`
4. Click **"Import"**

**Expected result:** 15 nodes imported successfully

### Verify Nodes

✅ Manual Trigger
✅ Generate Run ID
✅ Load 25 Creator URLs
✅ Convert to Activity URLs
✅ Split Creators
✅ Rate Limit Delay
✅ **Bright Data Unlocker** (HTTP Request node)
✅ Parse LinkedIn HTML (Code node)
✅ Filter Posts
✅ Deduplication
✅ OpenAI Score Posts
✅ Rank Top 15
✅ Select Top 7
✅ OpenAI Generate Posts
✅ Google Sheets

---

## 🔧 Step 3: Configure Environment Variables

Add these to your n8n environment:

```bash
# Required
OPENAI_API_KEY=sk-your-openai-api-key
GOOGLE_SHEET_ID=your-google-sheet-id
```

**Bright Data API token is already in the workflow!**

### How to Add Variables

**Docker:**
```bash
# Edit .env file
nano .env

# Add variables
OPENAI_API_KEY=sk-proj-abc123...
GOOGLE_SHEET_ID=1abc123def456...

# Restart n8n
docker-compose restart n8n
```

**n8n Cloud:**
- Settings → Environment Variables
- Add each variable

---

## 🔑 Step 4: Set Up Google Sheets

### Create Sheet

1. Create new Google Sheet: **"LinkedIn Content Radar Results"**
2. Create tab: **"Generated Posts"**
3. Add headers (row 1):

```
Rank | Creator | Original URL | Original Text | Likes | Comments | Posted Date | Relevance Score | Value Score | Final Score | Generated Post | Lead Magnet | Week Of
```

### Get Sheet ID

From URL:
```
https://docs.google.com/spreadsheets/d/1abc123def456/edit
                                        ↑↑↑↑↑↑↑↑↑↑↑
                                        This is your ID
```

Update environment variable:
```bash
GOOGLE_SHEET_ID=1abc123def456
```

### Configure Credential in n8n

1. Click **"Google Sheets"** node (last node)
2. Click **"Create New Credential"**
3. Select **"Google Sheets OAuth2 API"**
4. Follow OAuth flow (see [Google Cloud Console](https://console.cloud.google.com))
5. Authorize n8n

---

## 🧪 Step 5: Test with 1 Creator

Before running all 25, test with just 1:

### Edit Creator List

1. Click **"Load 25 Creator URLs"** node
2. Change the array to only 1 URL:

```javascript
=["https://www.linkedin.com/in/zeyneb-madi-6821b521b/"]
```

3. Click **"Execute Workflow"**

### Monitor Execution

Watch each node:
- ✅ **Bright Data Unlocker** should return HTML
- ✅ **Parse LinkedIn HTML** should extract posts
- ⚠️ **Filter Posts** might return 0 if no posts meet criteria
- ✅ **Google Sheets** should add data

### Check Results

1. Open Google Sheet
2. You should see rows added (if posts found)
3. Check **"Parse LinkedIn HTML"** node output to see what was extracted

---

## 🐛 Step 6: Troubleshooting HTML Parsing

**This is the trickiest part!** LinkedIn's HTML structure changes frequently.

### Issue: No Posts Extracted

**Symptom:** "Parse LinkedIn HTML" node returns `error: 'No posts extracted'`

**Solutions:**

**Option 1: Check Raw HTML**

1. Click **"Bright Data Unlocker"** node
2. View **"Output"** tab
3. Copy the HTML response
4. Search for patterns like:
   - `data-urn="urn:li:activity:`
   - `"commentary"`
   - Post text snippets

**Option 2: Update Parsing Logic**

Edit the **"Parse LinkedIn HTML"** node code:

```javascript
// Current pattern
const postPattern = /data-urn=\"urn:li:activity:(\\d+)\"/g;

// Try alternative patterns
const postPattern = /urn:li:activity:(\\d+)/g;
// or
const postPattern = /\"activityUrn\":\"urn:li:activity:(\\d+)\"/g;
```

**Option 3: Use LinkedIn API Alternative**

If HTML parsing is too unreliable, consider:
- Bright Data's LinkedIn Datasets API (structured data)
- RapidAPI's LinkedIn alternatives
- Manual data entry for initial testing

### Issue: Wrong Data Extracted

**Symptom:** Posts have wrong text, likes, or dates

**Solution:** Adjust regex patterns in parsing code

```javascript
// Current like pattern
const likesMatch = postChunk.match(/(\\d+)\\s*(likes?|reactions?)/i);

// Try alternatives
const likesMatch = postChunk.match(/\"numLikes\":(\\d+)/);
// or
const likesMatch = postChunk.match(/reactionCount[\":]+(\\d+)/);
```

### Issue: Rate Limiting

**Symptom:** HTTP 429 errors

**Solution:** Increase delay in "Rate Limit Delay" node:

```javascript
// Current: 2-5 seconds
const delay = Math.floor(Math.random() * 3000) + 2000;

// Change to: 5-10 seconds
const delay = Math.floor(Math.random() * 5000) + 5000;
```

---

## 🚀 Step 7: Scale to Production

Once 1 creator works:

### Restore Full Creator List

1. Click **"Load 25 Creator URLs"** node
2. Restore all 25 URLs (already in workflow)
3. Save workflow

### Add Schedule Trigger (Optional)

To run automatically every Sunday at 2 PM:

1. Delete **"Manual Trigger"** node
2. Add **"Schedule Trigger"** node:
   - Mode: Every week
   - Day: Sunday
   - Hour: 14 (2 PM)
   - Minute: 0
   - Timezone: Europe/Paris
3. Connect to **"Generate Run ID"** node
4. Activate workflow

### Monitor First Full Run

1. Click **"Execute Workflow"**
2. Execution takes ~10-15 minutes (25 creators × 2-5s delay)
3. Watch for:
   - Bright Data costs (~$0.20 for 25 requests)
   - OpenAI costs (~$1.25 for scoring + generation)
   - Total cost: ~$1.45 per run

---

## 💰 Cost Breakdown

### Per Run (25 Creators)

| Service | Usage | Cost |
|---------|-------|------|
| **Bright Data** | 25 requests × ~$0.008 | **$0.20** |
| **OpenAI GPT-4** | Scoring 75 posts | **$0.80** |
| **OpenAI GPT-4** | Generating 7 posts | **$0.45** |
| **Total** | | **$1.45** |

### Monthly (4 Weekly Runs)

**Total: ~$5.80/month**

### Current Balance Check

You have **$4.84** in Bright Data balance.
- This covers ~3 full runs
- Add funds: https://brightdata.com/cp/billing

### Cost Optimization

**Option 1: Use GPT-4o-mini**
- Change model in OpenAI nodes: `model: 'gpt-4o-mini'`
- **Saves 95%:** $0.30/run → $1.20/month

**Option 2: Reduce creators**
- Use 10 instead of 25
- **Saves 60%:** $0.58/run → $2.32/month

**Option 3: Run bi-weekly**
- Change schedule to every 2 weeks
- **Saves 50%:** ~$2.90/month

---

## 🔄 Alternative LinkedIn URL Patterns

If `/recent-activity/all/` doesn't work, try these:

### Option 1: Recent Activity Shares Only

```javascript
// In "Convert to Activity URLs" node
return `${cleanUrl}/recent-activity/shares/`;
```

### Option 2: Detail Page

```javascript
return `${cleanUrl}/detail/recent-activity/`;
```

### Option 3: Direct Profile (More Limited)

```javascript
return cleanUrl; // Just the profile URL
```

### Option 4: Use Bright Data's LinkedIn Dataset

Instead of Unlocker API, use Datasets API:

```bash
POST https://api.brightdata.com/datasets/v3/trigger
?dataset_id=gd_l7q7dkj5xxkronpd1q  # LinkedIn Posts dataset
&endpoint=your-webhook
```

This returns **structured JSON** instead of HTML (easier parsing).

---

## 📊 Expected Output Format

### After Successful Run

**Google Sheet should contain:**

| Rank | Creator | Original URL | Original Text | Likes | Comments | Generated Post | Lead Magnet |
|------|---------|--------------|---------------|-------|----------|----------------|-------------|
| 1 | agrim-goyal | linkedin.com/... | "AI is changing..." | 342 | 28 | "Just discovered..." | "10 AI Tools Checklist" |
| 2 | jessievanbreugel | linkedin.com/... | "Automation secret..." | 298 | 19 | "Here's why..." | null |

---

## 🛠️ Advanced Configuration

### Custom Parsing for Your Use Case

If the default HTML parsing doesn't work, you can:

1. **Test HTML Structure**
   - Run Bright Data test command
   - Save HTML response to file
   - Analyze structure in browser DevTools

2. **Update Parsing Patterns**
   - Identify post container selectors
   - Find like/comment patterns
   - Adjust regex in "Parse LinkedIn HTML" node

3. **Use External Parser**
   - Add HTTP Request to parsing service
   - Use tools like Apify, ParseHub
   - More reliable but costs extra

### Add Webhooks for Dashboard

To send updates to a dashboard:

1. Add HTTP Request node after key stages
2. Configure:
```javascript
{
  "method": "POST",
  "url": "https://your-dashboard.com/api/webhook",
  "headers": {
    "X-Webhook-Secret": "your-secret"
  },
  "body": {
    "event": "posts_scraped",
    "count": "={{ $input.all().length }}"
  }
}
```

### Batch Processing for Faster Execution

To process multiple creators simultaneously:

1. Remove "Split Creators" node
2. Update "Bright Data Unlocker" to handle arrays
3. Add parallel processing logic

---

## 🆘 Common Issues & Solutions

### Issue: "Invalid API Token"

**Error:** `401 Unauthorized`

**Solutions:**
1. Check token in Bright Data dashboard: https://brightdata.com/cp/zones
2. Verify token in workflow: Click "Bright Data Unlocker" node
3. Regenerate token if expired

### Issue: "Zone not found"

**Error:** `403 Forbidden - Zone 'linkedin_unlocker' not found`

**Solutions:**
1. Check zone name: https://brightdata.com/cp/zones
2. Verify zone is active and not paused
3. Ensure you have permissions for the zone

### Issue: "No posts extracted"

**Causes:**
- LinkedIn's HTML structure changed
- URL requires authentication
- Profile has no public posts
- Parsing logic needs adjustment

**Solutions:**
1. Check raw HTML output
2. Test with different creator profiles
3. Try alternative URL patterns
4. Update parsing regex (see Troubleshooting section)

### Issue: OpenAI Rate Limit

**Error:** `429 Too Many Requests`

**Solutions:**
1. Check OpenAI tier limits: https://platform.openai.com/account/limits
2. Add delay between OpenAI calls
3. Reduce batch size
4. Upgrade OpenAI tier

### Issue: Google Sheets Error

**Error:** `Missing credentials`

**Solutions:**
1. Re-authenticate Google OAuth
2. Check credential is selected in node
3. Verify Sheet ID is correct
4. Check sheet tab name: "Generated Posts"

---

## 📚 Additional Resources

### Bright Data Documentation

- **Unlocker API:** https://brightdata.com/products/unblocker
- **API Reference:** https://docs.brightdata.com/api-reference/unlocker
- **Zone Management:** https://brightdata.com/cp/zones
- **Billing:** https://brightdata.com/cp/billing

### LinkedIn Scraping Best Practices

- **Rate limiting:** Max 1000 req/min
- **URL formats:** Test different activity URL patterns
- **Anti-bot:** Bright Data handles this automatically
- **Data quality:** Not all profiles have public posts

### OpenAI GPT-4 Optimization

- **Token limits:** GPT-4: 8K context, GPT-4-32k: 32K context
- **Cost reduction:** Use GPT-4o-mini for 95% savings
- **Rate limits:** Tier 1: 500 RPM, upgrade for more

---

## ✅ Production Checklist

Before going live:

- [ ] Tested Bright Data API with curl command
- [ ] Imported workflow successfully (15 nodes)
- [ ] Added OpenAI API key to environment
- [ ] Set up Google Sheets credential
- [ ] Created Google Sheet with proper headers
- [ ] Tested with 1 creator successfully
- [ ] Verified HTML parsing extracts posts
- [ ] Checked OpenAI scoring works
- [ ] Confirmed Google Sheets receives data
- [ ] Reviewed costs and added Bright Data balance
- [ ] Scaled to all 25 creators
- [ ] Set up Schedule Trigger (optional)
- [ ] Activated workflow

---

## 🎯 Success Criteria

After first production run, you should have:

✅ 7 AI-generated LinkedIn posts in Google Sheet
✅ Post scores and rankings
✅ Lead magnet suggestions
✅ Total cost under $2
✅ Execution time 10-15 minutes
✅ No errors in workflow

---

## 🚨 Important Notes

### Bright Data Limits

- **Rate limit:** 1000 requests/minute (plenty for 25 creators)
- **Balance:** $4.84 current (add funds before going live)
- **Zone:** `linkedin_unlocker` must stay active

### LinkedIn Considerations

- **Public posts only:** Private/connections-only posts won't be scraped
- **Structure changes:** LinkedIn updates HTML frequently, parsing may break
- **Authentication:** Some profiles require login (Bright Data handles this)

### OpenAI Considerations

- **GPT-4 access:** Ensure your API key has GPT-4 enabled
- **Billing:** Set up payment method and limits
- **Rate limits:** Tier 1 allows 500 requests/min

---

**Version:** Unlocker Production v1
**Last Updated:** 2025-10-25
**Status:** ✅ Ready for Testing
**Estimated Setup Time:** 40 minutes
**Cost per Run:** ~$1.45
**Monthly Cost:** ~$5.80 (4 weekly runs)
