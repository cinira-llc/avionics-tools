#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
NAME="${BASH_SOURCE[0]}"
BIN="$(cd -- "$(dirname -- "${NAME}")" &>/dev/null && pwd)"
readonly BIN

. "${BIN}/_mount.sh"

function print_help() {
    cat <<EOF
Usage: $(basename "${NAME}") [output_directory]

Back up Garmin G1000 data cards to the specified output directory.
If no output directory is specified, a timestamped directory is created
in the current working directory.
EOF
}

# Parse command line options.
lock_options=0
if [[ $# -eq 0 ]]; then
    print_help
    exit 0
fi
for arg in "$@"; do
    if [[ $lock_options -eq 1 ]]; then
        echo $arg
        continue
    else
        case $arg in
            --)
                lock_options=1
                ;;
            -h|--help)
                print_help
                exit 0
                ;;
            -i|--image)
                echo "Error: The -i/--image option is not supported." >&2
                exit 1
                ;;
            *)
                echo $arg
                ;;
        esac
    fi
done

_mounts
exit 0

# GNU vs. BSD tar produce wildly different archives, insist on GNU tar.
if command -v gtar >/dev/null 2>&1; then
  tar="gtar"
else
  tar="tar"
fi
if [[ "$OSTYPE" == "darwin"* && "$tar" != "gtar" ]]; then
  echo "GNU tar (gtar) is required on mac OS. Try 'brew install gnu-tar'." >&2
  exit 1
fi

# Determine output directory.
if [[ "$1" -ne "" ]]; then
  output="$(realpath "$1")"
else
  output="$(pwd -P)/$(date -u +%Y%m%d%H%M)"
fi

# Find all mounted data cards.
cards=()
while IFS= read -r line; do
  IFS=' ' read -r mount_dev mount_root <<< "$line"
  if [ -f "$mount_root/airframe_info.xml" ]; then
    name=$(basename "$mount_root")
    if [ -f "$mount_root/apt_dir.gca.sff" ]; then
      cards+=("mfd-bottom:$mount_dev:$mount_root" "$name (G1000 MFD Bottom)" off)
    elif [ -f "$mount_root/avtn_db.bin.sff" ]; then
      cards+=("mfd-top:$mount_dev:$mount_root" "$name (G1000 MFD Top)" off)
    elif [ -f "$mount_root/terrain.adb.dwt" ]; then
      cards+=("pfd-bottom:$mount_dev:$mount_root" "$name (G1000 PFD Bottom)" off)
    fi
  fi
done < <(mount | grep -e '^/[^/]' | cut -d'(' -f -1 | sed 's/ type .*//' | cut -d' ' -f 1,3- | sed 's/[[:space:]]*$//')

# Select data cards for backup.
if [ ${#cards[@]} -eq 0 ]; then
	echo "No mounted data cards found." >&2
	exit 1
fi
selected=$(\
  dialog \
    --no-tags \
    --separate-output \
    --stdout \
    --checklist \
    "Select data card(s) for backup" \
    $((7 + ${#cards[@]} / 3)) \
    50 \
    ${#cards[@]} \
    "${cards[@]}" \
  )
clear

# Back up selected data cards.
if [ -z "$selected" ]; then
  echo "No data cards selected." >&2
  exit 1
fi
mkdir -p "$output"
while IFS= read -r line; do
  IFS=':' read -r slot mount_dev mount_root <<< "$line"
  target="$output/${slot}.tar"
  echo -n "Backing up $mount_root to $target..."
  (cd "$mount_root" \
    && find . -path '*/.*' -prune -o -print \
    | tail -n +2 \
    | $tar -cf "$target" --files-from=- --no-xattrs 2>/dev/null
  )
  echo " Done."
done <<< "$selected"
