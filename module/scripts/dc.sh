#!/usr/bin/env bash
includes=("_mount.sh")
for include in "${includes[@]}"; do
    include_path=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$include
    if [ ! -f "$include_path" ]; then
        echo "Error: Missing include file '$include'." >&2
        exit 1
    fi
    . "$include_path"
done

# Scan mount points for data cards.
timestamp=$(date -u +%Y%m%d%H%M%S)
while IFS= read -r mount_dev && IFS= read -r mount_point && IFS= read -r mount_options; do
    gadm_meta="$mount_point/.gadm.meta"
    if [ -f "$gadm_meta" ]; then
        echo $mount_dev
        while IFS= read -r card_id \
                && IFS= read -r card_tail \
                && IFS= read -r card_product; do
            archive_name=$(echo "$card_tail-${card_product// /-}-$card_id-$timestamp" | tr "[:upper:]" "[:lower:]")
            echo "  ID:          $card_id"
            echo "  Tail Number: $card_tail"
            echo "  Name:        $card_product"
            echo "  Archive:     $archive_name"
            echo "  dev:         $mount_dev"
            echo
        done < <(jq --raw-output ".id,.gadmTailNumber,.gadmAvionicsName // \"\"" "$gadm_meta")
    fi
done < <(mounts)
