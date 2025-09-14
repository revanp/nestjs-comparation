#!/bin/bash

# 🚀 Quick NestJS Speed Test
# Simple one-liner comparisons

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Quick NestJS Speed Comparison${NC}"
echo ""

# Test installation speed
echo -e "${YELLOW}📦 Installation Speed Test:${NC}"
echo "NPM:"
time (cd npm && npm install --no-cache --prefer-offline > /dev/null 2>&1)
echo ""

echo "PNPM:"
time (cd pnpm && pnpm install --no-cache --prefer-offline > /dev/null 2>&1)
echo ""

echo "PNPM-SWC:"
time (cd pnpm-swc && pnpm install --no-cache --prefer-offline > /dev/null 2>&1)
echo ""

echo "BUN:"
time (cd bun && bun install --no-cache > /dev/null 2>&1)
echo ""

# Test build speed
echo -e "${YELLOW}🔨 Build Speed Test:${NC}"
echo "NPM:"
time (cd npm && rm -rf dist && rm -f tsconfig.tsbuildinfo && npm run build > /dev/null 2>&1)
echo ""

echo "PNPM:"
time (cd pnpm && rm -rf dist && rm -f tsconfig.tsbuildinfo && npm run build > /dev/null 2>&1)
echo ""

echo "PNPM-SWC:"
time (cd pnpm-swc && rm -rf dist && rm -f tsconfig.tsbuildinfo && rm -rf .swc && npm run build > /dev/null 2>&1)
echo ""

echo "BUN:"
time (cd bun && rm -rf dist && rm -f tsconfig.tsbuildinfo && npm run build > /dev/null 2>&1)
echo ""

echo -e "${GREEN}✅ Quick test completed!${NC}"
