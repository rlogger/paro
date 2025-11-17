# Makefile for Paro iOS App

.PHONY: help build test clean format lint

help:
	@echo "Paro iOS App"
	@echo ""
	@echo "Commands:"
	@echo "  make build    - Build the app"
	@echo "  make test     - Run tests"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make format   - Format code"
	@echo "  make lint     - Lint code"
	@echo ""

build:
	@echo "Building..."
	@swift build

test:
	@echo "Testing..."
	@swift test

clean:
	@echo "Cleaning..."
	@swift package clean
	@rm -rf .build

format:
	@echo "Formatting..."
	@which swiftformat > /dev/null && swiftformat . || echo "Install: brew install swiftformat"

lint:
	@echo "Linting..."
	@which swiftlint > /dev/null && swiftlint || echo "Install: brew install swiftlint"

.DEFAULT_GOAL := help
