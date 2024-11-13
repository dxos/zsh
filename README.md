# DXOS ZSH Plugin

ZSH plugin for DXOS project development, providing convenient shortcuts for NX monorepo and CI workflows.

## Installation

To install via zplug, add the following to your `.zplug/init.sh`:

```zsh
zplug "dxos/zsh", from:github
```

Then run:

```zsh
zplug install
```

## Commands

### Git

- `gs` - Interactively select and checkout git branches (`git-branch-select -l`).
- `gb` - List all branches with their tracking info (`git branch -vv`).

### Package Development

- `p <target>` - Run NX target for current package (e.g., `p build`).
- `pb` - Build current package.
- `pt` - Test current package.
- `pc <target>` - Force rebuild by breaking NX cache for target.
- `pa <target>` - Run target across all packages in monorepo.
- `pre [-c]` - Complete rebuild sequence:
  - Cleans artifacts if `-c` flag provided
  - Resets NX
  - Runs fresh install
  - Builds, tests, and lints all packages

### PNPM Shortcuts

- `pi` - Install dependencies (`pnpm install`).
- `pw` - Run watch mode (`pnpm watch`).
- `px` - Run NX command with workspace flag (`pnpm -w nx`).
- `nx` - short for `px` (`pnpm -w nx`).

### CI

- `ci` - Watch current branch's CircleCI pipeline:
  - Shows pipeline status
  - Auto-refreshes every 10s
  - Provides failed job URL on failure
  - Requires `CIRCLECI_TOKEN`

## Configuration

- `CIRCLECI_TOKEN` - Your CircleCI API token.
- `CIRCLECI_ORG` - CircleCI organization (default: "dxos").
- `CIRCLECI_REPO` - CircleCI repository (default: "dxos").
