# Instructions for Agents

Do's:
- Comment code where helpful, explaining what it does and why it's needed.
- Ensure all setup and utility scripts can be executed idempotently.
- Support both macOS and Linux (Ubuntu); use `lib/os.sh` helpers for OS-specific logic, and keep shared `lib/` scripts compatible with both `bash` and `zsh`.
- Remember `home/` is symlinked to `$HOME` via GNU Stow (`bootstrap.sh`); exclude templates/non-home files in `home/.stow-local-ignore`.
- Verify shell edits with `bash -n` / `zsh -n` (and `stow --simulate` when changing `home/` layout).

Don'ts:
- Overcomplicate solutions; keep things simple.
- Commit secrets or personal data (`.secrets`, `.ssh/*` except `config`, work gitconfigs/repo lists); update `*.example` templates instead.