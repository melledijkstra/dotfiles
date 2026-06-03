#!/usr/bin/env bash
# sync-repos.sh — Clone or update repositories listed in adidas-repos.txt and projects-repos.txt
#
# Each file contains one SSH clone URL per line.
# Lines starting with # and blank lines are ignored.
# Existing repos are updated with git pull --ff-only; new ones are cloned.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ADIDAS_DIR="${HOME}/adidas"
PROJECTS_DIR="${HOME}/projects"

ADIDAS_REPOS_FILE="${SCRIPT_DIR}/adidas-repos.txt"
PROJECTS_REPOS_FILE="${SCRIPT_DIR}/projects-repos.txt"

clone_or_pull() {
  local base_dir="$1"
  local url="$2"

  local repo_name
  repo_name="$(basename "${url%.git}")"

  local target_dir="${base_dir}/${repo_name}"

  if [[ -d "${target_dir}/.git" ]]; then
    echo "  [pull]  ${repo_name}"
    git -C "${target_dir}" pull --ff-only || echo "  [WARN]  ${repo_name}: pull failed (local changes or diverged branch?)"
  else
    echo "  [clone] ${url}"
    git clone "${url}" "${target_dir}" || echo "  [FAIL]  ${repo_name}: clone failed"
  fi
}

sync_repos() {
  local base_dir="$1"
  local repos_file="$2"

  if [[ ! -f "${repos_file}" ]]; then
    echo "Skipping: ${repos_file} not found"
    return
  fi

  mkdir -p "${base_dir}"
  echo "==> ${base_dir}"

  while IFS= read -r line || [[ -n "${line}" ]]; do
    # Skip blank lines and comments
    [[ -z "${line}" || "${line}" == \#* ]] && continue
    clone_or_pull "${base_dir}" "${line}"
  done < "${repos_file}"

  echo ""
}

sync_repos "${ADIDAS_DIR}"   "${ADIDAS_REPOS_FILE}"
sync_repos "${PROJECTS_DIR}" "${PROJECTS_REPOS_FILE}"

echo "Done."
