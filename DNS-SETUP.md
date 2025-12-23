# DNS Setup Instructions for thericotoken.xyz

This guide will help you configure your GoDaddy domain to work with GitHub Pages.

## Current Setup
- **Domain**: thericotoken.xyz (purchased from GoDaddy)
- **Website**: Hosted on GitHub Pages
- **Repository**: ROCKET941/Thericotoken.xyz

## Step-by-Step DNS Configuration at GoDaddy

### 1. Log into GoDaddy
1. Go to [GoDaddy.com](https://www.godaddy.com)
2. Sign in to your account
3. Go to "My Products" → "Domains"
4. Click on "DNS" next to your domain `thericotoken.xyz`

### 2. Configure A Records (Root Domain)

Delete any existing A records and add these four A records pointing to GitHub Pages:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| A | @ | 185.199.108.153 | 600 seconds (or default) |
| A | @ | 185.199.109.153 | 600 seconds (or default) |
| A | @ | 185.199.110.153 | 600 seconds (or default) |
| A | @ | 185.199.111.153 | 600 seconds (or default) |

**Note**: The `@` symbol represents your root domain (thericotoken.xyz)

### 3. Configure CNAME Record (www subdomain)

Add or modify the CNAME record for www:

| Type | Name | Value | TTL |
|------|------|-------|-----|
| CNAME | www | rocket941.github.io | 1 hour (or default) |

**Important**: Do NOT add a dot at the end of `rocket941.github.io`

### 4. Remove Conflicting Records

Make sure to remove or disable:
- Any existing A records pointing to other IPs
- Any AAAA records (IPv6) that might conflict
- GoDaddy's default parking page records

### 5. Verify Your Configuration

After saving your DNS settings at GoDaddy, you can verify they're correct:

**Check A Records:**
```bash
dig thericotoken.xyz +short
```
Should return the four GitHub Pages IP addresses.

**Check CNAME Record:**
```bash
dig www.thericotoken.xyz +short
```
Should return `rocket941.github.io`

**Check via Online Tool:**
Visit https://dnschecker.org and enter your domain to see propagation status worldwide.

## DNS Propagation Time

⏰ **Important**: DNS changes can take anywhere from a few minutes to 48 hours to propagate worldwide. During this time:
- Your site may be intermittently accessible
- Some locations may see the old site while others see the new one
- This is normal and will resolve itself

## Verifying GitHub Pages Configuration

Once DNS is configured, verify in your GitHub repository:

1. Go to: https://github.com/ROCKET941/Thericotoken.xyz/settings/pages
2. Under "Custom domain", it should show: `thericotoken.xyz`
3. Wait for the DNS check to pass (green checkmark)
4. Once passed, enable "Enforce HTTPS" for security

## Common Issues and Solutions

### Issue: "DNS check unsuccessful"
**Solution**: 
- Verify all 4 A records are configured correctly at GoDaddy
- Wait up to 48 hours for DNS propagation
- Clear your browser cache and try again
- Use incognito/private browsing mode

### Issue: "HTTPS not working"
**Solution**: 
- Wait for DNS check to pass completely
- GitHub automatically provisions SSL certificate (can take up to 24 hours)
- Don't enable "Enforce HTTPS" until certificate is ready

### Issue: "Site shows 404 error"
**Solution**: 
- Verify the CNAME file exists in your repository with content: `thericotoken.xyz`
- Ensure index.html is in the root of the repository
- Check that GitHub Pages is enabled in repository settings

### Issue: "Still seeing GoDaddy parking page"
**Solution**: 
- Disable GoDaddy's domain forwarding
- Turn off GoDaddy's "Domain forwarding" feature
- Make sure you're not using GoDaddy's website builder

## Testing Your Website

Once everything is configured and propagated, your website should be accessible at:
- https://thericotoken.xyz
- https://www.thericotoken.xyz

Both URLs will work and www will automatically redirect to the root domain.

## Summary Checklist

- [ ] GoDaddy: Add 4 A records pointing to GitHub Pages IPs
- [ ] GoDaddy: Add CNAME record for www subdomain
- [ ] GoDaddy: Remove conflicting DNS records
- [ ] GoDaddy: Disable domain forwarding
- [ ] GitHub: Verify CNAME file contains `thericotoken.xyz`
- [ ] GitHub: Wait for DNS check to pass (green checkmark)
- [ ] GitHub: Enable "Enforce HTTPS" after DNS check passes
- [ ] Wait for DNS propagation (up to 48 hours)
- [ ] Test website at https://thericotoken.xyz

## Need Help?

If you're still having issues after following these steps:
1. Check GitHub Pages status: https://www.githubstatus.com/
2. Verify your DNS settings using: https://dnschecker.org
3. Wait the full 48 hours for DNS propagation
4. Check the GitHub repository settings/pages section for error messages

---

**Last Updated**: December 2025
