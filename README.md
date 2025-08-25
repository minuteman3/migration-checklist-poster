# Migration Checklist Poster

A GitHub Action that automatically posts a migration checklist as a comment on pull requests that contain database migration files.

## Description

This action monitors pull requests for changes to database migration files (specifically files in `db/migrate` directories). When migrations are detected, it posts a comprehensive checklist comment to guide developers through the migration deployment process.

## How It Works

1. The action examines all files changed in a pull request
2. If any files in `db/migrate` directories are detected, it triggers the checklist posting
3. The action checks if a migration checklist comment has already been posted to avoid duplicates
4. If no previous comment exists, it posts the appropriate checklist as a comment on the pull request

## Components

- **action.yml**: GitHub Action configuration defining the action name, inputs, and Docker runtime
- **Dockerfile**: Container setup with necessary tools (curl, jq) for API interactions
- **entrypoint.sh**: Main script that handles PR file detection, comment checking, and checklist posting
- **checklists/**: Directory containing checklist templates
  - **default.md**: Default migration checklist with comprehensive steps for database migrations

## Features

- Automatic detection of database migration files in pull requests
- Prevention of duplicate checklist comments
- Support for repository-specific checklists (falls back to default if not found)
- Uses GitHub API for PR interaction with proper authentication

## Required Inputs

- **token**: GitHub token for API authentication (required)