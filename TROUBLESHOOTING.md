# Troubleshooting Guide: 404 and Security Errors

## Problem: Website showing "404 Not Found" and "Site Not Secure" errors

This guide will help you diagnose and fix common issues with thericotoken.xyz hosted on GitHub Pages.

## Quick Diagnostic Checklist

### 1. Check DNS Configuration (Most Common Issue)

**Problem:** Domain doesn't point to GitHub Pages servers
**Solution:** Configure DNS records at your domain registrar (GoDaddy)

#### Required DNS Records at GoDaddy:

**A Records** (for root domain `thericotoken.xyz`):
```
Type: A    Name: @    Value: 185.199.108.153    TTL: 600
Type: A    Name: @    Value: 185.199.109.153    TTL: 600
Type: A    Name: @    Value: 185.199.110.153    TTL: 600
Type: A    Name: @    Value: 185.199.111.153    TTL: 600
```

**CNAME Record** (for www subdomain):
```
Type: CNAME    Name: www    Value: rocket941.github.io    TTL: 3600
```

#### How to Verify DNS:
1. Visit https://dnschecker.org
2. Enter `thericotoken.xyz`
3. Select "A" record type
4. Should show the 4 GitHub IPs above (may take 24-48 hours to propagate)

### 2. Verify GitHub Pages Settings

**Check these settings at:** https://github.com/ROCKET941/Thericotoken.xyz/settings/pages

Required configuration:
- **Source:** Deploy from a branch
- **Branch:** main (or master)
- **Folder:** / (root)
- **Custom domain:** thericotoken.xyz
- **Enforce HTTPS:** Enabled (only after DNS check passes)

### 3. Common 404 Causes

#### A. Wrong Branch Being Served
**Symptom:** Repository has files but GitHub Pages shows 404

**Check:**
```bash
# Ensure index.html is in the correct branch
git checkout main
ls -la index.html  # Should exist
```

**Fix:**
- Go to repository Settings → Pages
- Ensure "main" branch is selected as source
- Click "Save"

#### B. CNAME File Issues
**Symptom:** Custom domain not working

**Check CNAME file content:**
```bash
cat CNAME
# Should contain: thericotoken.xyz (no www, no https://)
```

**Fix if needed:**
```bash
echo "thericotoken.xyz" > CNAME
git add CNAME
git commit -m "Fix CNAME file"
git push origin main
```

#### C. Files Not in Root Directory
**Symptom:** 404 when accessing main page

**Check:**
- `index.html` must be in repository root (not in a subfolder)
- Run: `git ls-files | grep index.html`
- Should show: `index.html` (not `docs/index.html` or similar)

### 4. Security/HTTPS Issues

#### A. "Site Not Secure" Warning
**Symptoms:**
- Browser shows "Not Secure" warning
- HTTPS doesn't work
- Certificate errors

**Causes & Solutions:**

**Cause 1: DNS Check Not Passed**
- GitHub Pages needs DNS to verify domain ownership before issuing SSL certificate
- **Solution:** Wait for DNS to propagate (up to 48 hours), then check GitHub Pages settings for "DNS check successful"

**Cause 2: HTTPS Not Enforced Yet**
- **Solution:** Wait for DNS check to pass, then enable "Enforce HTTPS" in GitHub Pages settings

**Cause 3: Mixed DNS Records**
- **Solution:** Remove old DNS records that conflict with GitHub Pages IPs

#### B. Certificate Provisioning Delay
**Timeline:**
1. Configure DNS → wait 1-24 hours for propagation
2. GitHub detects DNS → "DNS check successful" appears
3. GitHub provisions SSL cert → wait 1-24 hours
4. Enable "Enforce HTTPS" → site is secure

### 5. Step-by-Step Recovery Process

If your site is completely broken, follow these steps in order:

#### Step 1: Fix Repository (2 minutes)
```bash
# Ensure you're on main branch
git checkout main

# Verify files exist
ls -la index.html CNAME

# Verify CNAME content
cat CNAME  # Should be: thericotoken.xyz

# If missing, recreate:
echo "thericotoken.xyz" > CNAME
git add CNAME .nojekyll
git commit -m "Fix CNAME and add .nojekyll"
git push origin main
```

#### Step 2: Configure DNS at GoDaddy (5 minutes)
1. Log in to GoDaddy.com
2. Go to "My Products" → "Domains"
3. Click "DNS" next to thericotoken.xyz
4. Delete any existing A records for @ (root domain)
5. Add the 4 GitHub Pages A records (listed above)
6. Add/update CNAME record for www
7. **Remove** any conflicting records:
   - Old A records with different IPs
   - AAAA (IPv6) records
   - Forwarding/redirect rules
8. Save changes

#### Step 3: Configure GitHub Pages (2 minutes)
1. Go to: https://github.com/ROCKET941/Thericotoken.xyz/settings/pages
2. Under "Source":
   - Branch: **main**
   - Folder: **/ (root)**
3. Under "Custom domain":
   - Enter: `thericotoken.xyz`
   - Click "Save"
4. Wait for "DNS check" to complete (green checkmark)
5. Once passed, enable "Enforce HTTPS"

#### Step 4: Wait and Monitor (1-48 hours)
- **First 10 minutes:** DNS starts propagating
- **After 1 hour:** Check https://dnschecker.org for propagation status
- **After DNS propagates:** GitHub Pages shows "DNS check successful"
- **After DNS check:** SSL certificate provisioning begins (automatic)
- **After SSL provisioned:** Can enable "Enforce HTTPS"
- **Final:** Website loads at https://thericotoken.xyz with green padlock

### 6. Testing Your Website

#### Test DNS Resolution:
```bash
# Should return GitHub Pages IPs
nslookup thericotoken.xyz
# or
dig thericotoken.xyz
```

#### Test HTTP Access:
```bash
# Should return 200 OK or 301 redirect
curl -I http://thericotoken.xyz
```

#### Test HTTPS Access:
```bash
# Should return 200 OK with valid SSL
curl -I https://thericotoken.xyz
```

#### Test in Browser:
1. Clear browser cache (Ctrl+Shift+Delete)
2. Try incognito/private browsing mode
3. Visit https://thericotoken.xyz
4. Check for green padlock in address bar

### 7. Still Not Working?

#### Check GitHub Status:
- Visit: https://www.githubstatus.com/
- Look for GitHub Pages outages

#### Review Workflow Logs:
- Go to: https://github.com/ROCKET941/Thericotoken.xyz/actions
- Check "pages build and deployment" workflow
- Look for errors in recent runs

#### Force Rebuild:
```bash
# Make a small change to trigger rebuild
git commit --allow-empty -m "Trigger Pages rebuild"
git push origin main
```

#### Contact Support:
If nothing works after 48 hours:
1. Verify DNS at https://dnschecker.org
2. Screenshot GitHub Pages settings
3. Screenshot GitHub Actions workflow status
4. Check browser console for errors (F12 → Console tab)
5. Contact GitHub Support with above information

## Common Error Messages Explained

| Error | Cause | Solution |
|-------|-------|----------|
| "404 - File not found" | index.html missing or wrong branch | Check file exists on main branch |
| "DNS check unsuccessful" | DNS records not configured | Configure A records at GoDaddy |
| "Not Secure" warning | SSL not provisioned yet | Wait for DNS check to pass first |
| "ERR_NAME_NOT_RESOLVED" | DNS not configured/propagated | Configure DNS, wait up to 48 hours |
| "ERR_CERT_COMMON_NAME_INVALID" | SSL for wrong domain | Remove and re-add custom domain |

## Prevention Checklist

To avoid future issues:
- [ ] Keep CNAME file in repository root with just domain name
- [ ] Don't change DNS records without documenting
- [ ] Always use main branch for GitHub Pages
- [ ] Test changes in incognito mode to avoid cache issues
- [ ] Monitor https://github.com/ROCKET941/Thericotoken.xyz/settings/pages for warnings
- [ ] Keep "Enforce HTTPS" enabled once working

## Quick Reference

**Repository:** https://github.com/ROCKET941/Thericotoken.xyz
**GitHub Pages Settings:** https://github.com/ROCKET941/Thericotoken.xyz/settings/pages
**GitHub Actions:** https://github.com/ROCKET941/Thericotoken.xyz/actions
**Live Site:** https://thericotoken.xyz
**DNS Checker:** https://dnschecker.org

## Need More Help?

Refer to:
- [QUICK-START.md](QUICK-START.md) - Simple setup guide
- [DNS-SETUP.md](DNS-SETUP.md) - Detailed DNS configuration
- [README.md](README.md) - Project overview

---

**Last Updated:** December 2025
