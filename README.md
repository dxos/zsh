# DXOS ZSH Plugin

ZSH plugin for DXOS project development.

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
