# release-summary

> Generate structured Git release changelogs from commit history, with optional AI-powered summarization.

## Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/DavidMachile/release-summary/main/install.sh | bash
```

Or download the script directly:

```bash
curl -sSL https://raw.githubusercontent.com/DavidMachile/release-summary/main/release-summary.sh -o /usr/local/bin/release-summary
chmod +x /usr/local/bin/release-summary
```

Requirements: **git** (required), **Claude CLI** (optional, for AI summaries).

## Usage

```bash
# Between two commits
release-summary abc1234 def5678

# From a commit to HEAD
release-summary abc1234

# With a project name and custom output path
release-summary -n "MyApp" -o changelog/v2.0.0.md abc1234 def5678

# Show version
release-summary --version
```

## What It Does

1. Collects all non-merge commits between the two refs
2. If Claude CLI is available, generates an AI summary grouped by feature area
3. Outputs a clean Markdown file with summary + full commit list

### Example Output

````markdown
# MyApp Release Summary

> **Generated**: 2026-05-26
> **Range**: `abc1234 .. def5678`
> **Commits**: 12

## Highlights

**Auth Module**
- Added OAuth2 login support with Google and GitHub providers
- Fixed token refresh race condition on session expiry

**Payment**
- Integrated Stripe checkout for subscription billing
- Added invoice download in user settings

**Performance**
- Reduced bundle size by 40% via tree-shaking optimization

## Commits

```
def5678 feat: add OAuth2 login with Google provider (Jane)
abc1234 fix: token refresh race condition (Mike)
...
```
````

## How It Works

- **Without Claude CLI**: outputs commit list only, clean and ready to paste into release notes
- **With Claude CLI**: adds an AI-generated "Highlights" section, auto-grouped by feature area

## Uninstall

```bash
rm "$(which release-summary)"
```
