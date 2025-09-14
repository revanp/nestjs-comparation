#!/bin/bash

# 🛠️ Setup script for NestJS comparison projects
# Cleans and prepares all projects for benchmarking

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECTS=("npm" "pnpm" "pnpm-swc" "bun")

echo -e "${BLUE}🛠️  Setting up NestJS comparison projects...${NC}"
echo ""

# Function to clean project
clean_project() {
    local project="$1"
    echo -e "${YELLOW}🧹 Cleaning ${project}...${NC}"
    
    cd "$project"
    
    # Remove generated files
    rm -rf node_modules
    rm -rf dist
    rm -f package-lock.json
    rm -f pnpm-lock.yaml
    rm -f bun.lockb
    
    cd ..
    echo -e "${GREEN}✅ ${project} cleaned${NC}"
}

# Function to check if package manager is installed
check_package_manager() {
    local manager="$1"
    case $manager in
        "npm")
            if ! command -v npm &> /dev/null; then
                echo -e "${RED}❌ npm not found! Please install Node.js${NC}"
                return 1
            fi
            ;;
        "pnpm")
            if ! command -v pnpm &> /dev/null; then
                echo -e "${RED}❌ pnpm not found! Install with: npm install -g pnpm${NC}"
                return 1
            fi
            ;;
        "bun")
            if ! command -v bun &> /dev/null; then
                echo -e "${RED}❌ bun not found! Install from: https://bun.sh${NC}"
                return 1
            fi
            ;;
    esac
    return 0
}

# Check all package managers
echo -e "${YELLOW}🔍 Checking package managers...${NC}"
check_package_manager "npm"
check_package_manager "pnpm" 
check_package_manager "bun"
echo ""

# Clean all projects
echo -e "${YELLOW}🧹 Cleaning all projects...${NC}"
for project in "${PROJECTS[@]}"; do
    clean_project "$project"
done
echo ""

# Install dependencies for each project
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
for project in "${PROJECTS[@]}"; do
    echo -e "${BLUE}Installing for ${project}...${NC}"
    cd "$project"
    
    case $project in
        "npm")
            npm install
            ;;
        "pnpm"|"pnpm-swc")
            pnpm install
            ;;
        "bun")
            bun install
            ;;
    esac
    
    cd ..
    echo -e "${GREEN}✅ ${project} dependencies installed${NC}"
done
echo ""

# Make scripts executable
chmod +x benchmark.sh
chmod +x quick-test.sh
chmod +x setup.sh

echo -e "${GREEN}🎉 Setup completed!${NC}"
echo ""
echo -e "${BLUE}Available commands:${NC}"
echo -e "  ${YELLOW}./benchmark.sh${NC}     - Full comprehensive benchmark"
echo -e "  ${YELLOW}./benchmark.sh install${NC} - Test installation speed only"
echo -e "  ${YELLOW}./benchmark.sh build${NC}   - Test build speed only"
echo -e "  ${YELLOW}./quick-test.sh${NC}   - Quick installation & build test"
echo -e "  ${YELLOW}./setup.sh${NC}        - Clean and reinstall everything"
echo ""
