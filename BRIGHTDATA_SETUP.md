# 🌐 Bright Data Integration Guide

## Overview

This project uses **Bright Data Web Scraper API** with **Web Unlocker** for LinkedIn scraping, providing:
- ✅ Anti-bot protection
- ✅ Automatic proxy rotation
- ✅ Residential/datacenter proxies
- ✅ CAPTCHA handling
- ✅ JavaScript rendering

---

## 🚀 Quick Setup

### 1. Create Bright Data Account

1. Go to [brightdata.com](https://brightdata.com)
2. Sign up for an account
3. Choose a plan (Starter plan recommended)

### 2. Get API Token

1. Navigate to **My Account** → **API Token**
2. Click **Generate Token**
3. Copy your token (starts with `bd_`)
4. Save it securely

### 3. Configure in n8n

**Add to n8n Environment Variables:**
```
BRIGHTDATA_TOKEN=bd_your_token_here
BRIGHTDATA_ZONE=datacenter (or residential)
```

---

## 📡 API Configuration

### Endpoint

```
POST https://api.brightdata.com/dca/collect
```

### Authentication

```
Authorization: Bearer {{ $env.BRIGHTDATA_TOKEN }}
```

### Headers

```json
{
  "Content-Type": "application/json",
  "X-BrightData-Zone": "datacenter"
}
```

### Request Body (LinkedIn Profile)

```json
{
  "url": "https://www.linkedin.com/in/username/",
  "format": "json",
  "country": "us",
  "render": "html",
  "wait_for_selector": ".feed-shared-update-v2",
  "extract": {
    "posts": {
      "selector": ".feed-shared-update-v2",
      "fields": {
        "text": ".feed-shared-text__text-view",
        "likes": "[data-test-icon='like-icon-small-filled'] + span",
        "comments": "[data-test-icon='comment-icon-small'] + span",
        "date": "time",
        "url": "a.app-aware-link"
      }
    }
  }
}
```

---

## ⚙️ Retry Logic (Best Practices)

### Configuration

```javascript
// In n8n HTTP Request node
{
  "maxRetries": 3,
  "retryDelay": "random", // 2-5 seconds
  "retryOnHttpCodes": [408, 429, 500, 502, 503, 504],
  "backoffStrategy": "exponential"
}
```

### Implementation Example (Code Node)

```javascript
async function scrapePosts(url, token) {
  const maxRetries = 3;
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      const response = await fetch('https://api.brightdata.com/dca/collect', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json',
          'X-BrightData-Zone': 'datacenter'
        },
        body: JSON.stringify({
          url: url,
          format: 'json',
          country: 'us',
          render: 'html',
          wait_for_selector: '.feed-shared-update-v2'
        })
      });

      if (response.ok) {
        return await response.json();
      }

      // Retry on specific status codes
      if ([408, 429, 500, 502, 503, 504].includes(response.status)) {
        attempt++;
        const delay = Math.random() * 3000 + 2000; // 2-5 seconds
        await new Promise(resolve => setTimeout(resolve, delay));
        continue;
      }

      throw new Error(`HTTP ${response.status}`);

    } catch (error) {
      attempt++;
      if (attempt >= maxRetries) throw error;

      const delay = Math.random() * 3000 + 2000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

---

## 🔄 Proxy Rotation

Bright Data automatically rotates proxies on each request. No manual configuration needed!

### Proxy Types

| Type | Speed | Cost | Use Case |
|------|-------|------|----------|
| **Datacenter** | Fast | Low | Development, testing |
| **Residential** | Medium | Medium | Production scraping |
| **Mobile** | Slow | High | Maximum stealth |

**Recommendation:** Use **datacenter** for testing, **residential** for production.

### Setting Proxy Zone

```javascript
// In request headers
{
  "X-BrightData-Zone": "datacenter" // or "residential" or "mobile"
}
```

---

## ⏱️ Rate Limiting Best Practices

### Recommended Limits

| Metric | Limit | Reason |
|--------|-------|--------|
| **Requests/minute** | 50 | LinkedIn rate limits |
| **Concurrent requests** | 5 | Avoid triggering anti-bot |
| **Delay between requests** | 2-5s random | Mimic human behavior |
| **Session timeout** | 30 minutes | Cookie refresh |

### Implementation in n8n

**Add delay between requests:**

```javascript
// After each scraping request
const delay = Math.random() * 3000 + 2000; // 2-5 seconds
await new Promise(resolve => setTimeout(resolve, delay));
```

**Rate limiter code node:**

```javascript
const requests = $input.all();
const rateLimit = 50; // requests per minute
const delayMs = (60 * 1000) / rateLimit; // ~1200ms

const results = [];
for (let i = 0; i < requests.length; i++) {
  // Process request
  results.push(requests[i]);

  // Wait before next request
  if (i < requests.length - 1) {
    await new Promise(resolve => setTimeout(resolve, delayMs));
  }
}

return results;
```

---

## 🛡️ Anti-Bot Protection

Bright Data's Web Unlocker automatically handles:

✅ **CAPTCHA Solving** - Automatic bypass
✅ **JavaScript Challenges** - Cloudflare, etc.
✅ **Browser Fingerprinting** - Randomized headers
✅ **Cookie Management** - Session persistence
✅ **User-Agent Rotation** - Real browser UAs

### Best Practices

1. **Use render: "html"** - Waits for JavaScript execution
2. **Set wait_for_selector** - Ensures content loads
3. **Randomize delays** - Avoid patterns
4. **Rotate sessions** - Don't reuse too long
5. **Monitor success rate** - Adjust if < 90%

---

## 💰 Cost Optimization

### Pricing (Estimated)

| Plan | Cost/GB | Requests/GB | Cost per 1000 Requests |
|------|---------|-------------|------------------------|
| **Pay as You Go** | $15 | ~10,000 | $1.50 |
| **Growth** | $10 | ~10,000 | $1.00 |
| **Business** | $5 | ~10,000 | $0.50 |

**Weekly automation cost:**
- 25 creators × 20 posts × 4 weeks = ~2,000 requests/month
- Estimated cost: **$2-3/month**

### Optimization Tips

1. **Use datacenter proxies** - 50% cheaper than residential
2. **Cache results** - Don't re-scrape same posts
3. **Filter early** - Only scrape what you need
4. **Batch requests** - Use async processing
5. **Monitor usage** - Set up billing alerts

---

## 📊 Monitoring & Debugging

### Check Request Status

```bash
curl -X GET https://api.brightdata.com/dca/jobs/YOUR_JOB_ID \
  -H "Authorization: Bearer $BRIGHTDATA_TOKEN"
```

### Response Codes

| Code | Meaning | Action |
|------|---------|--------|
| **200** | Success | Process data |
| **400** | Bad request | Check parameters |
| **401** | Unauthorized | Verify token |
| **429** | Rate limited | Wait and retry |
| **500** | Server error | Retry with backoff |

### Logging in n8n

```javascript
// Add logging to track issues
console.log(`[BrightData] Scraping: ${url}`);
console.log(`[BrightData] Response status: ${response.status}`);
console.log(`[BrightData] Posts found: ${posts.length}`);
```

---

## 🔧 Troubleshooting

### Issue: 401 Unauthorized

**Cause:** Invalid or expired token

**Fix:**
1. Go to Bright Data dashboard
2. Regenerate API token
3. Update `BRIGHTDATA_TOKEN` in n8n
4. Restart workflow

### Issue: 429 Too Many Requests

**Cause:** Exceeded rate limit

**Fix:**
1. Add delays between requests (2-5s)
2. Reduce concurrent requests
3. Implement retry with exponential backoff
4. Upgrade to higher tier plan

### Issue: No posts returned

**Cause:** LinkedIn blocked request or selector changed

**Fix:**
1. Check LinkedIn hasn't changed UI
2. Update CSS selectors in extract config
3. Use `wait_for_selector` to ensure content loads
4. Try residential proxies instead of datacenter

### Issue: High cost

**Cause:** Too many requests or inefficient scraping

**Fix:**
1. Cache scraped posts (avoid re-scraping)
2. Use datacenter proxies for testing
3. Filter at scraping level (not after)
4. Batch requests more efficiently

---

## 📝 Complete n8n HTTP Request Configuration

### Node Settings

**Method:** POST

**URL:**
```
https://api.brightdata.com/dca/collect
```

**Authentication:** None (use headers)

**Headers:**
```json
{
  "Authorization": "Bearer {{ $env.BRIGHTDATA_TOKEN }}",
  "Content-Type": "application/json",
  "X-BrightData-Zone": "datacenter"
}
```

**Body:**
```json
{
  "url": "{{ $json.creatorUrl }}",
  "format": "json",
  "country": "us",
  "render": "html",
  "wait_for_selector": ".feed-shared-update-v2",
  "extract": {
    "posts": {
      "selector": ".feed-shared-update-v2",
      "fields": {
        "text": ".feed-shared-text__text-view",
        "likes": "[data-test-icon='like-icon-small-filled'] + span",
        "comments": "[data-test-icon='comment-icon-small'] + span",
        "date": "time",
        "url": "a.app-aware-link"
      }
    }
  }
}
```

**Retry Settings:**
- Max Retries: 3
- Retry on Codes: 408, 429, 500, 502, 503, 504
- Delay: 2000-5000ms (random)

---

## 🎯 Production Checklist

- [ ] Bright Data account created
- [ ] API token generated and saved
- [ ] `BRIGHTDATA_TOKEN` set in n8n
- [ ] HTTP Request node configured
- [ ] Retry logic implemented (3 retries, 2-5s delay)
- [ ] Rate limiting added (max 50 req/min)
- [ ] Proxy zone selected (datacenter/residential)
- [ ] CSS selectors tested and working
- [ ] Error handling implemented
- [ ] Logging added for debugging
- [ ] Cost monitoring set up
- [ ] Workflow tested with real creators

---

## 📚 Additional Resources

- [Bright Data Documentation](https://docs.brightdata.com/)
- [Web Unlocker Guide](https://docs.brightdata.com/scraping-automation/web-unlocker)
- [API Reference](https://docs.brightdata.com/api-reference)
- [LinkedIn Scraping Best Practices](https://docs.brightdata.com/scraping-automation/web-scraper/use-cases/linkedin)

---

## 🆘 Support

**Bright Data Support:**
- Email: support@brightdata.com
- Chat: Available in dashboard
- Response time: Usually < 24 hours

**n8n Community:**
- Forum: [community.n8n.io](https://community.n8n.io/)
- Discord: [discord.gg/n8n](https://discord.gg/n8n)

---

**Ready to scrape!** 🚀
