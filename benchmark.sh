#!/bin/bash

# 🚀 NestJS Package Manager Speed Comparison Script
# Author: Revan's Speed Test Suite
# Usage: ./benchmark.sh [test_type]
# Test types: install, build, start, test, all

set -e

# Ensure we're using bash with associative array support
if [ -z "$BASH_VERSION" ]; then
    echo "This script requires bash with associative array support"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Projects to test
PROJECTS=("npm" "pnpm" "pnpm-swc" "bun")

# Results storage
declare -A RESULTS

# Function to print header
print_header() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    🚀 NESTJS SPEED COMPARISON 🚀              ║${NC}"
    echo -e "${CYAN}║                                                              ║${NC}"
    echo -e "${CYAN}║  Testing: ${1:-ALL TESTS}                                    ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to measure time
measure_time() {
    local command="$1"
    local project="$2"
    local test_name="$3"
    
    echo -e "${YELLOW}⏱️  Testing ${test_name} for ${project}...${NC}"
    
    # Measure execution time
    local start_time=$(date +%s.%N)
    eval "$command" > /dev/null 2>&1
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    RESULTS["${project}_${test_name}"]=$duration
    echo -e "${GREEN}✅ ${project} ${test_name}: ${duration}s${NC}"
    echo ""
}


# Function to clean project
clean_project() {
    local project="$1"
    echo -e "${BLUE}🧹 Cleaning ${project}...${NC}"
    
    cd "$project"
    
    # Remove node_modules and lock files
    rm -rf node_modules
    rm -f package-lock.json pnpm-lock.yaml bun.lockb
    rm -rf dist
    
    # Clear TypeScript cache
    rm -f tsconfig.tsbuildinfo
    
    # Clear SWC cache
    rm -rf .swc
    
    # Clear other caches
    rm -rf .cache
    rm -rf .parcel-cache
    rm -rf .turbo
    
    # Clear package manager caches
    case $project in
        "npm")
            npm cache clean --force 2>/dev/null || true
            ;;
        "pnpm"|"pnpm-swc")
            pnpm store prune 2>/dev/null || true
            ;;
        "bun")
            bun pm cache rm 2>/dev/null || true
            ;;
    esac
    
    cd ..
    echo -e "${GREEN}✅ ${project} cleaned${NC}"
}

# Function to test installation
test_installation() {
    print_header "INSTALLATION SPEED"
    
    for project in "${PROJECTS[@]}"; do
        echo -e "${PURPLE}📦 Testing ${project} installation...${NC}"
        
        cd "$project"
        
        case $project in
            "npm")
                measure_time "npm install --no-cache --prefer-offline" "$project" "install"
                ;;
            "pnpm"|"pnpm-swc")
                measure_time "pnpm install --no-cache --prefer-offline" "$project" "install"
                ;;
            "bun")
                measure_time "bun install --no-cache" "$project" "install"
                ;;
        esac
        
        cd ..
        echo ""
    done
}

# Function to test build
test_build() {
    print_header "BUILD SPEED"
    
    for project in "${PROJECTS[@]}"; do
        echo -e "${PURPLE}🔨 Testing ${project} build...${NC}"
        
        cd "$project"
        
        # Clean dist first
        rm -rf dist
        
        # Clear TypeScript cache
        rm -f tsconfig.tsbuildinfo
        
        measure_time "npm run build" "$project" "build"
        
        cd ..
        echo ""
    done
}

# Function to test startup
test_startup() {
    print_header "STARTUP SPEED"
    
    for project in "${PROJECTS[@]}"; do
        echo -e "${PURPLE}🚀 Testing ${project} startup...${NC}"
        
        cd "$project"
        
        # Test cold start with proper timeout handling
        echo -e "${YELLOW}⏱️  Testing startup for ${project}...${NC}"
        
        local start_time=$(date +%s.%N)
        
        # Start the server in background
        npm run start > /dev/null 2>&1 &
        local pid=$!
        
        # Wait for server to be ready (check if port 3000 is listening)
        local timeout=15
        local elapsed=0
        while [ $elapsed -lt $timeout ]; do
            if lsof -i :3000 > /dev/null 2>&1; then
                break
            fi
            sleep 0.5
            elapsed=$((elapsed + 1))
        done
        
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)
        
        # Kill the server
        kill $pid 2>/dev/null || true
        sleep 1
        
        RESULTS["${project}_startup"]=$duration
        echo -e "${GREEN}✅ ${project} startup: ${duration}s${NC}"
        echo ""
        
        cd ..
    done
}

# Function to test development mode
test_dev_mode() {
    print_header "DEVELOPMENT MODE"
    
    for project in "${PROJECTS[@]}"; do
        echo -e "${PURPLE}🔄 Testing ${project} dev mode...${NC}"
        
        cd "$project"
        
        # Test dev startup and memory
        echo -e "${YELLOW}🧠 Testing memory usage for ${project} dev...${NC}"
        
        # Start dev server in background
        npm run start:dev > /dev/null 2>&1 &
        local pid=$!
        
        # Wait for server to be ready
        local timeout=15
        local elapsed=0
        while [ $elapsed -lt $timeout ]; do
            if lsof -i :3000 > /dev/null 2>&1; then
                break
            fi
            sleep 0.5
            elapsed=$((elapsed + 1))
        done
        
        # Wait a bit more for dev server to stabilize
        sleep 2
        
        # Get memory usage
        local memory=$(ps -o rss= -p $pid 2>/dev/null | awk '{print $1/1024}' || echo "0")
        
        # Kill the server
        kill $pid 2>/dev/null || true
        sleep 1
        
        RESULTS["${project}_dev_memory"]=$memory
        echo -e "${GREEN}✅ ${project} dev memory: ${memory}MB${NC}"
        echo ""
        
        cd ..
    done
}

# Function to test testing
test_testing() {
    print_header "TEST EXECUTION SPEED"
    
    for project in "${PROJECTS[@]}"; do
        echo -e "${PURPLE}🧪 Testing ${project} test execution...${NC}"
        
        cd "$project"
        
        measure_time "npm test" "$project" "test"
        
        cd ..
        echo ""
    done
}

# Function to print results
print_results() {
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                        📊 RESULTS SUMMARY 📊                 ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Installation results
    echo -e "${YELLOW}📦 INSTALLATION SPEED:${NC}"
    for project in "${PROJECTS[@]}"; do
        local time=${RESULTS["${project}_install"]}
        printf "  %-12s: %8.3fs\n" "$project" "$time"
    done
    echo ""
    
    # Build results
    echo -e "${YELLOW}🔨 BUILD SPEED:${NC}"
    for project in "${PROJECTS[@]}"; do
        local time=${RESULTS["${project}_build"]}
        printf "  %-12s: %8.3fs\n" "$project" "$time"
    done
    echo ""
    
    # Startup results
    echo -e "${YELLOW}🚀 STARTUP SPEED:${NC}"
    for project in "${PROJECTS[@]}"; do
        local time=${RESULTS["${project}_startup"]}
        printf "  %-12s: %8.3fs\n" "$project" "$time"
    done
    echo ""
    
    # Test results
    echo -e "${YELLOW}🧪 TEST SPEED:${NC}"
    for project in "${PROJECTS[@]}"; do
        local time=${RESULTS["${project}_test"]}
        printf "  %-12s: %8.3fs\n" "$project" "$time"
    done
    echo ""
    
    # Memory results
    echo -e "${YELLOW}🧠 MEMORY USAGE:${NC}"
    for project in "${PROJECTS[@]}"; do
        local memory=${RESULTS["${project}_dev_memory"]}
        printf "  %-12s: %8.1fMB\n" "$project" "$memory"
    done
    echo ""
}

# Function to find fastest
find_fastest() {
    echo -e "${GREEN}🏆 WINNERS:${NC}"
    echo ""
    
    # Find fastest installation
    local fastest_install=""
    local fastest_install_time=999999
    for project in "${PROJECTS[@]}"; do
        local time=${RESULTS["${project}_install"]}
        if (( $(echo "$time < $fastest_install_time" | bc -l) )); then
            fastest_install_time=$time
            fastest_install=$project
        fi
    done
    echo -e "  📦 Fastest Installation: ${GREEN}${fastest_install}${NC} (${fastest_install_time}s)"
    
    # Find fastest build
    local fastest_build=""
    local fastest_build_time=999999
    for project in "${PROJECTS[@]}"; do
        local time=${RESULTS["${project}_build"]}
        if (( $(echo "$time < $fastest_build_time" | bc -l) )); then
            fastest_build_time=$time
            fastest_build=$project
        fi
    done
    echo -e "  🔨 Fastest Build: ${GREEN}${fastest_build}${NC} (${fastest_build_time}s)"
    
    echo ""
}

# Main execution
main() {
    local test_type="${1:-all}"
    
    # Check if bc is installed
    if ! command -v bc &> /dev/null; then
        echo -e "${RED}❌ Error: 'bc' command not found. Please install it first.${NC}"
        echo -e "${YELLOW}   macOS: brew install bc${NC}"
        echo -e "${YELLOW}   Ubuntu: sudo apt-get install bc${NC}"
        exit 1
    fi
    
    # Clean all projects first
    echo -e "${BLUE}🧹 Cleaning all projects...${NC}"
    for project in "${PROJECTS[@]}"; do
        clean_project "$project"
    done
    echo ""
    
    case $test_type in
        "install")
            test_installation
            ;;
        "build")
            test_build
            ;;
        "start")
            test_startup
            ;;
        "dev")
            test_dev_mode
            ;;
        "test")
            test_testing
            ;;
        "all")
            test_installation
            test_build
            test_startup
            test_dev_mode
            test_testing
            ;;
        *)
            echo -e "${RED}❌ Invalid test type: $test_type${NC}"
            echo -e "${YELLOW}Available options: install, build, start, dev, test, all${NC}"
            exit 1
            ;;
    esac
    
    print_results
    find_fastest
    
    echo -e "${CYAN}🎉 Benchmark completed! Check results above.${NC}"
}

# Run main function
main "$@"
