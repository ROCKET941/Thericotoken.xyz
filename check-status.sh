#!/bin/bash
#
# Website Status Checker for thericotoken.xyz
# This script checks DNS, GitHub Pages, and website status
#

# Configuration
DOMAIN="thericotoken.xyz"
GITHUB_USER="ROCKET941"
GITHUB_REPO="Thericotoken.xyz"
GITHUB_PAGES_URL="https://${GITHUB_USER}.github.io/${GITHUB_REPO}/"

echo "========================================="
echo "Website Status Checker"
echo "${DOMAIN}"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: Repository Files
echo "📁 Checking Repository Files..."
echo "---"

if [ -f "index.html" ]; then
    echo -e "${GREEN}✓${NC} index.html exists"
else
    echo -e "${RED}✗${NC} index.html is MISSING!"
    exit 1
fi

if [ -f "CNAME" ]; then
    CNAME_CONTENT=$(cat CNAME)
    if [ "$CNAME_CONTENT" = "${DOMAIN}" ]; then
        echo -e "${GREEN}✓${NC} CNAME file correct: $CNAME_CONTENT"
    else
        echo -e "${YELLOW}⚠${NC} CNAME file contains: $CNAME_CONTENT (expected: ${DOMAIN})"
    fi
else
    echo -e "${RED}✗${NC} CNAME file is MISSING!"
fi

if [ -f ".nojekyll" ]; then
    echo -e "${GREEN}✓${NC} .nojekyll file exists"
else
    echo -e "${YELLOW}⚠${NC} .nojekyll file is missing (recommended for static sites)"
fi

echo ""

# Check 2: DNS Configuration
echo "🌐 Checking DNS Configuration..."
echo "---"

# Check if dig or nslookup is available
if command -v dig &> /dev/null; then
    DNS_TOOL="dig"
    DNS_RESULT=$(dig +short ${DOMAIN} A)
elif command -v nslookup &> /dev/null; then
    DNS_TOOL="nslookup"
    DNS_RESULT=$(nslookup ${DOMAIN} 2>/dev/null | grep -A 10 "Name:" | grep "Address:" | awk '{print $2}' | grep -v '#')
else
    echo -e "${YELLOW}⚠${NC} DNS tools (dig/nslookup) not available"
    DNS_RESULT=""
fi

if [ ! -z "$DNS_RESULT" ]; then
    echo "DNS A Records found:"
    echo "$DNS_RESULT"
    
    # Check for GitHub Pages IPs
    GITHUB_IPS=("185.199.108.153" "185.199.109.153" "185.199.110.153" "185.199.111.153")
    FOUND_COUNT=0
    
    for IP in "${GITHUB_IPS[@]}"; do
        if echo "$DNS_RESULT" | grep -q "$IP"; then
            ((FOUND_COUNT++))
        fi
    done
    
    if [ $FOUND_COUNT -eq 4 ]; then
        echo -e "${GREEN}✓${NC} All GitHub Pages A records configured correctly"
    elif [ $FOUND_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} Some GitHub Pages A records found ($FOUND_COUNT/4)"
        echo "Expected IPs:"
        printf '%s\n' "${GITHUB_IPS[@]}"
    else
        echo -e "${RED}✗${NC} GitHub Pages A records NOT found"
        echo "DNS points to: $DNS_RESULT"
        echo "Expected IPs:"
        printf '%s\n' "${GITHUB_IPS[@]}"
    fi
else
    echo -e "${RED}✗${NC} Domain ${DOMAIN} does NOT resolve"
    echo "ACTION REQUIRED: Configure DNS A records at your domain registrar"
fi

echo ""

# Check 3: HTTP/HTTPS Access
echo "🔒 Checking Website Access..."
echo "---"

# Check HTTP
if command -v curl &> /dev/null; then
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 http://${DOMAIN} 2>/dev/null || echo "000")
    
    if [ "$HTTP_STATUS" = "000" ]; then
        echo -e "${RED}✗${NC} HTTP: Cannot connect (DNS issue or site down)"
    elif [ "$HTTP_STATUS" = "200" ]; then
        echo -e "${GREEN}✓${NC} HTTP: Site accessible (Status: 200 OK)"
    elif [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
        echo -e "${GREEN}✓${NC} HTTP: Redirecting (Status: $HTTP_STATUS) - likely to HTTPS"
    elif [ "$HTTP_STATUS" = "404" ]; then
        echo -e "${RED}✗${NC} HTTP: 404 Not Found - Check GitHub Pages configuration"
    else
        echo -e "${YELLOW}⚠${NC} HTTP: Unexpected status $HTTP_STATUS"
    fi
    
    # Check HTTPS
    HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 https://${DOMAIN} 2>/dev/null || echo "000")
    
    if [ "$HTTPS_STATUS" = "000" ]; then
        echo -e "${RED}✗${NC} HTTPS: Cannot connect (DNS issue, SSL problem, or site down)"
    elif [ "$HTTPS_STATUS" = "200" ]; then
        echo -e "${GREEN}✓${NC} HTTPS: Site accessible and secure (Status: 200 OK)"
    elif [ "$HTTPS_STATUS" = "404" ]; then
        echo -e "${RED}✗${NC} HTTPS: 404 Not Found - Check GitHub Pages configuration"
    else
        echo -e "${YELLOW}⚠${NC} HTTPS: Unexpected status $HTTPS_STATUS"
    fi
    
    # Check SSL Certificate
    if command -v openssl &> /dev/null; then
        SSL_INFO=$(echo | openssl s_client -servername ${DOMAIN} -connect ${DOMAIN}:443 2>/dev/null | openssl x509 -noout -subject -dates 2>/dev/null)
        if [ ! -z "$SSL_INFO" ]; then
            echo -e "${GREEN}✓${NC} SSL Certificate is present"
            EXPIRY=$(echo "$SSL_INFO" | grep "notAfter")
            echo "  $EXPIRY"
        else
            echo -e "${YELLOW}⚠${NC} SSL Certificate check failed (may not be provisioned yet)"
        fi
    fi
else
    echo -e "${YELLOW}⚠${NC} curl not available - cannot check HTTP/HTTPS status"
fi

echo ""

# Check 4: GitHub Pages Direct Access
echo "📦 Checking GitHub Pages Direct URL..."
echo "---"

if command -v curl &> /dev/null; then
    GH_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 ${GITHUB_PAGES_URL} 2>/dev/null || echo "000")
    
    if [ "$GH_STATUS" = "200" ]; then
        echo -e "${GREEN}✓${NC} GitHub Pages URL accessible (Status: 200 OK)"
    elif [ "$GH_STATUS" = "404" ]; then
        echo -e "${RED}✗${NC} GitHub Pages: 404 Not Found"
        echo "  Check: Repository settings → Pages → Source branch"
    else
        echo -e "${YELLOW}⚠${NC} GitHub Pages: Status $GH_STATUS"
    fi
fi

echo ""

# Summary
echo "========================================="
echo "📋 Summary & Next Steps"
echo "========================================="
echo ""

if [ ! -z "$DNS_RESULT" ] && [ "$HTTPS_STATUS" = "200" ]; then
    echo -e "${GREEN}✓ Website appears to be working correctly!${NC}"
    echo ""
    echo "Your site should be accessible at:"
    echo "  https://${DOMAIN}"
elif [ -z "$DNS_RESULT" ]; then
    echo -e "${RED}⚠ DNS NOT CONFIGURED${NC}"
    echo ""
    echo "ACTION REQUIRED:"
    echo "1. Log in to your domain registrar (GoDaddy)"
    echo "2. Configure DNS A records to point to GitHub Pages:"
    echo "   - 185.199.108.153"
    echo "   - 185.199.109.153"
    echo "   - 185.199.110.153"
    echo "   - 185.199.111.153"
    echo ""
    echo "See: DNS-SETUP.md for detailed instructions"
elif [ "$HTTPS_STATUS" = "404" ] || [ "$HTTP_STATUS" = "404" ]; then
    echo -e "${RED}⚠ WEBSITE RETURNING 404${NC}"
    echo ""
    echo "ACTION REQUIRED:"
    echo "1. Check GitHub Pages settings:"
    echo "   https://github.com/${GITHUB_USER}/${GITHUB_REPO}/settings/pages"
    echo "2. Ensure 'main' branch is selected"
    echo "3. Ensure custom domain is set to: ${DOMAIN}"
    echo "4. Wait for DNS check to pass"
    echo ""
    echo "See: TROUBLESHOOTING.md for detailed instructions"
elif [ "$HTTPS_STATUS" = "000" ]; then
    echo -e "${YELLOW}⚠ SSL/HTTPS NOT READY${NC}"
    echo ""
    echo "WAIT FOR:"
    echo "1. DNS propagation (up to 48 hours)"
    echo "2. GitHub DNS check to pass"
    echo "3. SSL certificate provisioning (up to 24 hours after DNS check)"
    echo ""
    echo "Meanwhile, check DNS propagation at:"
    echo "  https://dnschecker.org"
else
    echo -e "${YELLOW}⚠ ISSUES DETECTED${NC}"
    echo ""
    echo "See full diagnostic output above and refer to:"
    echo "  TROUBLESHOOTING.md - for step-by-step fixes"
fi

echo ""
echo "========================================="
echo "For detailed help, see:"
echo "  - QUICK-START.md      (Simple setup)"
echo "  - DNS-SETUP.md        (DNS configuration)"
echo "  - TROUBLESHOOTING.md  (Problem solving)"
echo "========================================="
