---
description: A description of your rule
---

# New Rule

Your rule content 1. Code Quality & Style
Always enforce language-idiomatic style and formatting (e.g., PEP8 for Python, standard style for JS, .editorconfig for C#/C++).

Flag code that mixes styles, uses unclear variable names, or lacks comments on complex logic.

Discourage “magic numbers”; require constants with meaningful names.

Recommend splitting large functions or classes into smaller, focused units.

Check for unused variables, dead code, and unreachable branches.

Enforce strict linting; no warnings should be ignored without clear justification.

Enforce code formatting (spaces, tabs, indentation, line length limits).

Suggest descriptive function and variable names, and require docstrings or XML comments for public APIs.

2. Security
Always check for common security issues:

SQL injection (raw SQL, unsafe user input).

Command injection (passing user input to system calls).

Insecure deserialization or use of eval.

Use of weak hashing (MD5, SHA1).

Hardcoded secrets, passwords, API keys, or tokens.

Lack of input validation or output encoding.

Open ports, excessive permissions, or missing authentication.

Flag dependencies with known CVEs (vulnerabilities) and recommend upgrades.

Enforce principle of least privilege in code and configuration.

Advise on secure handling of user data and logging (no sensitive data in logs).

3. Maintainability
Require all functions and classes to be documented.

Encourage modularization: keep related code in modules or classes.

Flag files or classes that grow too large (“God objects”) or are responsible for too much.

Enforce DRY (Don't Repeat Yourself): highlight duplicate logic or code blocks.

Recommend refactoring when code is difficult to understand or test.

Require all public APIs to have tests, with a minimum threshold of code coverage (e.g., 80%).

Discourage global variables; prefer local scope or dependency injection.

4. Testing
Require unit tests for every new function/class.

Recommend integration or end-to-end tests for critical workflows.

Check for presence of test assertions—flag “empty” or incomplete tests.

Flag skipped or commented-out tests for review.

Enforce clear naming for test files and test functions.

Encourage use of test coverage tools and reporting (aim for 80%+ coverage).

5. Documentation & Usability
Check that README or equivalent project documentation exists and is up to date.

Ensure all new scripts, configs, and tools have inline comments explaining their purpose and usage.

Enforce the use of standardized code examples in docs.

Flag missing, outdated, or incomplete documentation.

6. Modern Practices & Dependency Management
Require use of up-to-date frameworks and languages (no EOL versions).

Enforce semantic versioning for packages and dependencies.

Advise on containerization or virtualization if relevant (e.g., Dockerfiles should follow best practices).

Warn against the use of deprecated APIs, libraries, or language features.

7. CI/CD & Workflow Integration
Recommend automating lint, format, and test runs in CI/CD.

Check for presence of configuration files for build, deploy, and test pipelines (e.g., .github/workflows/, .gitlab-ci.yml, etc).

Advise on code review policies (e.g., no direct pushes to main/master, use pull requests).

Flag missing or insecure secrets handling in pipelines.

8. Accessibility and Internationalization
For UI code, flag missing accessibility features (e.g., alt text, ARIA attributes).

Suggest internationalization/localization best practices for user-facing messages.

9. Error Handling & Logging
Require explicit error handling for all external calls (APIs, DB, filesystems).

Discourage empty catch blocks or blanket exception swallowing.

Advise on structured logging, and flag excessive or missing log statements.

Ensure sensitive data is never logged.

10. Learning & Feedback
Whenever possible, provide an explanation and a code example for any flagged issue or recommendation.

Suggest resources, documentation, or patterns for any complex recommendation.

Encourage continual learning—link to official docs for best practices and deeper understanding.