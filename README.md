# 🚀 NestJS Package Manager Speed Comparison

A comprehensive benchmarking suite to compare performance between different package managers in NestJS development environments.

## 📁 Project Structure

```
nestjs-comparation/
├── npm/          # NestJS with NPM
├── pnpm/         # NestJS with PNPM  
├── pnpm-swc/     # NestJS with PNPM + SWC compiler
├── bun/          # NestJS with Bun
├── benchmark.sh  # Comprehensive benchmark script
├── quick-test.sh # Quick speed test
└── setup.sh      # Setup & cleanup script
```

## 🛠️ Prerequisites

Ensure you have all package managers installed:

```bash
# NPM (usually comes with Node.js)
node --version
npm --version

# PNPM
npm install -g pnpm

# Bun
curl -fsSL https://bun.sh/install | bash
```

## 🚀 Quick Start

### 1. Setup all projects
```bash
./setup.sh
```

### 2. Run comprehensive benchmark
```bash
./benchmark.sh
```

### 3. Quick test only
```bash
./quick-test.sh
```

## 📊 Benchmark Options

### Full Benchmark
```bash
./benchmark.sh all
```

### Specific Tests
```bash
./benchmark.sh install    # Installation speed only
./benchmark.sh build      # Build speed only  
./benchmark.sh start      # Startup speed only
./benchmark.sh dev        # Development mode only
./benchmark.sh test       # Test execution only
```

## 🎯 What Gets Measured

### 📦 Installation Speed
- Time to install all dependencies
- Lock file generation speed
- Cache efficiency

### 🔨 Build Performance  
- Cold build time (first build)
- TypeScript compilation speed
- Bundle size comparison

### 🚀 Runtime Performance
- Application startup time
- Memory usage during development
- Hot reload speed

### 🧪 Testing Speed
- Test execution time
- Test compilation speed

### 🧠 Memory Usage
- Development server memory footprint
- Build process memory consumption

## 📈 Expected Results

Based on general performance characteristics:

- **Bun**: Usually fastest for installation & build operations
- **PNPM**: Efficient disk usage with good overall speed
- **NPM**: Most compatible with standard performance
- **SWC**: Fastest compilation (Rust-based compiler)

## 🔧 Customization

You can modify the scripts to add additional test cases:

1. Edit `benchmark.sh` to add new test functions
2. Modify the `PROJECTS` array to include new projects
3. Adjust timeout values according to your needs

## 🐛 Troubleshooting

### Permission Denied
```bash
chmod +x *.sh
```

### Package Manager Not Found
- Install missing package managers
- Check PATH environment variable

### Build Failures
```bash
./setup.sh  # Clean and reinstall everything
```

## 📝 Notes

- Scripts will clean all `node_modules` before testing
- Results are stored in memory during script execution
- 10-second timeout for startup tests (adjustable)
- Memory measurement uses `ps` command

## 🎉 Happy Benchmarking!

This benchmarking suite will help you determine which package manager works best for your development workflow! 🔥
