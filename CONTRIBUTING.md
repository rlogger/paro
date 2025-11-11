# Contributing to Eater

Thank you for your interest in contributing to Eater! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

### Our Standards

- Be respectful and considerate
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards other community members

---

## Getting Started

### Prerequisites

Before you begin, ensure you have:
- Xcode 15.0 or later
- iOS 17.0+ SDK
- Git
- A GitHub account

### Setting Up Your Development Environment

1. **Fork the repository**
   ```bash
   # Click 'Fork' on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/eaterr.git
   cd eaterr
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/rlogger/eaterr.git
   ```

3. **Install dependencies**
   - Follow setup instructions in [README.md](README.md)
   - Set up Firebase (see [docs/FIREBASE_SETUP.md](docs/FIREBASE_SETUP.md))

4. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

---

## Development Workflow

### 1. Check for Existing Issues

Before starting work, check if an issue exists for your proposed change:
- Browse [existing issues](https://github.com/rlogger/eaterr/issues)
- Comment on the issue to let others know you're working on it
- If no issue exists, create one to discuss your proposed changes

### 2. Sync with Upstream

Keep your fork up to date:
```bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### 3. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

Branch naming conventions:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or modifications

### 4. Make Your Changes

- Write clean, readable code
- Follow the [Coding Standards](#coding-standards)
- Add comments for complex logic
- Update documentation as needed

### 5. Test Your Changes

- Build and run the app
- Test on multiple device sizes (if UI changes)
- Ensure no existing functionality is broken
- Add unit tests for new features (when applicable)

---

## Coding Standards

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

**Naming Conventions:**
```swift
// Use descriptive names
let orderConfirmationCode = "123456"  // Good
let code = "123456"                   // Avoid

// PascalCase for types
class OrderService { }
struct User { }
enum OrderStatus { }

// camelCase for functions and variables
func placeOrder() { }
var selectedCuisines: [String]

// UPPERCASE for constants
let API_KEY = "your-key"
```

**Code Organization:**
```swift
// Use MARK comments to organize code
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Helper Methods
```

**Documentation:**
```swift
/**
 Brief description of what this does.

 Detailed description if needed, explaining the purpose,
 behavior, and any important details.

 - Parameters:
   - param1: Description of parameter
   - param2: Description of parameter

 - Returns: Description of return value

 - Throws: Description of errors that can be thrown

 ## Example
 ```swift
 let result = myFunction(param1: "value")
 ```
 */
func myFunction(param1: String, param2: Int) -> String {
    // Implementation
}
```

**SwiftUI Best Practices:**
- Extract complex views into separate components
- Use `@State` for local state, `@StateObject` for observable objects
- Prefer computed properties for simple view logic
- Keep view bodies clean and readable

**Error Handling:**
```swift
// Use Result type for async operations
func fetchData(completion: @escaping (Result<Data, Error>) -> Void) {
    // Implementation
}

// Use do-catch for throwing functions
do {
    let data = try fetchData()
} catch {
    print("Error: \(error)")
}
```

### File Organization

- One type per file (class, struct, enum)
- Group related files together
- Use meaningful file names that match the type name

---

## Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code style changes (formatting, no logic change)
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

**Examples:**
```
feat(auth): add Apple Sign-In support

Implement Apple Sign-In authentication flow using Firebase Auth.
Add necessary UI components and error handling.

Closes #42
```

```
fix(orders): resolve order confirmation display issue

Fix crash that occurred when order had no customization field.
Add nil check and default value handling.

Fixes #38
```

```
docs(readme): update installation instructions

Add section about Firebase setup and clarify prerequisites.
```

### Commit Best Practices

- Write clear, descriptive commit messages
- Keep commits focused and atomic
- Reference issue numbers when applicable
- Use present tense ("add feature" not "added feature")
- Capitalize the first letter of the subject line
- Don't end the subject line with a period

---

## Pull Request Process

### Before Submitting

1. **Ensure your code builds**
   ```bash
   # Build in Xcode or use command line
   xcodebuild -scheme eater -destination 'platform=iOS Simulator,name=iPhone 15' build
   ```

2. **Update documentation**
   - Update README.md if adding new features
   - Update relevant docs in `docs/` folder
   - Add inline code documentation

3. **Test thoroughly**
   - Test on iOS simulator
   - Test on physical device (if possible)
   - Verify all existing features still work

4. **Clean up your branch**
   ```bash
   # Rebase if needed
   git fetch upstream
   git rebase upstream/main

   # Squash commits if necessary
   git rebase -i HEAD~3  # Squash last 3 commits
   ```

### Submitting a Pull Request

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create the PR**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Fill out the PR template

3. **PR Template**
   ```markdown
   ## Description
   Brief description of what this PR does

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   How has this been tested?

   ## Screenshots (if applicable)
   Add screenshots for UI changes

   ## Checklist
   - [ ] Code builds without errors
   - [ ] Documentation updated
   - [ ] Tests added/updated
   - [ ] No breaking changes
   ```

### PR Review Process

- Maintainers will review your PR
- Address any feedback or requested changes
- Be patient and respectful during the review process
- Once approved, a maintainer will merge your PR

---

## Testing

### Manual Testing

Test the following scenarios:
- App launch and initial load
- Authentication flow (if applicable)
- Order placement
- Navigation between views
- Error handling
- Different device sizes and orientations

### Unit Testing (Future)

When the project adds unit tests, follow these guidelines:
- Write tests for new features
- Ensure tests are isolated and repeatable
- Use meaningful test names
- Test edge cases and error conditions

---

## Questions?

If you have questions:
- Check existing [documentation](docs/)
- Search [existing issues](https://github.com/rlogger/eaterr/issues)
- Create a new issue with the `question` label

---

## Recognition

Contributors will be recognized in:
- GitHub contributors page
- Future CONTRIBUTORS.md file

Thank you for contributing to Eater! 🥕
