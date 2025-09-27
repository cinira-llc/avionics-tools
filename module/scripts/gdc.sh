#!/usr/bin/env bash
includes=("_platform.sh" "_mount.sh")
for include in "${includes[@]}"; do
    include_path=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$include
    if [ ! -f "$include_path" ]; then
        echo "Error: Missing include file '$include'." >&2
        exit 1
    fi
    . "$include_path"
done

function print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [output_directory]

Back up Garmin data cards to the specified output directory. If no output
directory is specified, a timestamped directory is created in the current
working directory.
EOF
}

# Parse command line options.
lock_options=0
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

# Find data cards.
timestamp=$(date -u +%Y%m%d%H%M%S)
cards_found=()
while IFS= read -r mount_dev && IFS= read -r mount_point && IFS= read -r mount_options; do
    gadm_meta="$mount_point/.gadm.meta"
    if [ -f "$gadm_meta" ]; then
        while IFS= read -r card_id \
                && IFS= read -r card_tail \
                && IFS= read -r card_product \
                && IFS= read -r card_description; do
            archive_name=$(echo "$card_tail-${card_product// /-}-$card_id-$timestamp" | tr "[:upper:]" "[:lower:]")
            label="$card_tail $card_product"
            if [ -n "$card_description" ]; then
                label="$label $card_description"
            fi
            label="$label ($(basename "$mount_dev"))"
            cards_found+=("$mount_point,$archive_name,$mount_dev,$mount_options" "$label" off)
        done < <(jq --raw-output ".id,.gadmTailNumber,.gadmAvionicsName,.gadmCardDescription // \"\"" "$gadm_meta")
    fi
done < <(mounts)

# Select data cards for backup.
if [ ${#cards_found[@]} -eq 0 ]; then
	echo "No mounted data cards were found." >&2
	exit 1
fi
cards_selected=$(\
    dialog \
        --no-tags \
        --separate-output \
        --stdout \
        --checklist \
        "Select data card(s) for backup" \
        $((7 + ${#cards_found[@]} / 3)) \
        100 \
        ${#cards_found[@]} \
        "${cards_found[@]}" \
    )

# Archive the selected data cards.
if [ -z "$cards_selected" ]; then
    echo "No data cards were selected." >&2
    exit 0
fi

# Determine the number of XZ compression threads to use per process, (#cpu - 1) / #cards.
card_count=$(wc -l <<< "$cards_selected" | xargs)
xz_threads=$((($(cpu_count) - 1) / $card_count))
while IFS= read -r line; do
    IFS=',' read -r mount_point archive_name mount_dev mount_options <<< "$line"
    target="$(pwd)/$archive_name.tar.xz"
    (cd "$mount_point" \
        && find . -type f -print 2>/dev/null \
        | sed '/\/\./d' \
        | { echo "./.gadm.meta" ; cat ; } \
        | $tar -c --files-from=- --no-xattrs --owner=0 --group=0 2>/dev/null \
        | xz --extreme --threads=$xz_threads --stdout - > "$target" \
    ) &
done <<< "$cards_selected"

# Wait for all background processes to complete.
clear
echo -n "Backing up $card_count data card(s) using $xz_threads compression thread(s) per card..."
wait
echo " Done."
