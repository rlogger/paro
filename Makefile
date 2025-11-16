# Makefile for Eater iOS App

.PHONY: help build test clean format lint install

help:
	@echo "Eater iOS App - Build Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make build    - Build the app"
	@echo "  make test     - Run all tests"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make format   - Format code with SwiftFormat"
	@echo "  make lint     - Lint code with SwiftLint"
	@echo "  make install  - Install dependencies"
	@echo "  make all      - Build and test"
	@echo ""

build:
	@echo "🔨 Building Eater app..."
	swift build

test:
	@echo "🧪 Running tests..."
	swift test

clean:
	@echo "🧹 Cleaning build artifacts..."
	swift package clean
	rm -rf .build

format:
	@echo "✨ Formatting code..."
	@which swiftformat > /dev/null || (echo "❌ SwiftFormat not installed. Run: brew install swiftformat" && exit 1)
	swiftformat .

lint:
	@echo "🔍 Linting code..."
	@which swiftlint > /dev/null || (echo "❌ SwiftLint not installed. Run: brew install swiftlint" && exit 1)
	swiftlint

install:
	@echo "📦 Installing dependencies..."
	@echo "Using Swift Package Manager - dependencies will be resolved on build"

all: clean build test
	@echo "✅ Build and tests complete!"

.DEFAULT_GOAL := help
