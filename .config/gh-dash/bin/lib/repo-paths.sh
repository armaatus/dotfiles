# Local clones from repoPaths in common.yml. Source it after setting CONFIG_DIR.

# "OWNER/REPO <clone>" per line, ~ expanded.
repo_paths() {
  awk -v home="$HOME" '
    /^repoPaths:/ { in_paths = 1; next }
    in_paths && /^[^ ]/ { in_paths = 0 }
    in_paths && NF == 2 { sub(/:$/, "", $1); sub(/^~/, home, $2); print $1, $2 }' "$CONFIG_DIR/common.yml"
}

# The clone of OWNER/REPO, or nothing.
clone_for() {
  repo_paths | awk -v r="$1" '$1 == r { print $2 }'
}
