function print_help() {
    cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}")

List mounted Garmin data cards, their mount points, and devices.
EOF
}

while IFS= read -r mount_dev && IFS= read -r mount_point && IFS= read -r mount_options; do
    gadm_meta="$mount_point/.gadm.meta"
    if [ -f "$gadm_meta" ]; then
        while IFS= read -r card_id \
                && IFS= read -r card_tail \
                && IFS= read -r card_product \
                && IFS= read -r card_description \
                && IFS= read -r card_updated; do
            archive_name=$(echo "$card_tail-${card_product// /-}-$card_id-$timestamp" | tr "[:upper:]" "[:lower:]")
            label="$card_tail $card_product"
            if [ -n "$card_description" ]; then
                label="$label $card_description"
            fi
            echo "$label"
            echo "  Path:    $mount_point"
            echo "  Device:  $mount_dev"
            if [[ "$mount_options" == *":ro:"* ]]; then
                echo "  Mode:    Read-only"
            else
                echo "  Mode:    Read/write"
            fi
            echo "  Updated: $card_updated"
            echo "  ID:      $card_id"
        done < <(jq --raw-output ".id,.gadmTailNumber,.gadmAvionicsName,.gadmCardDescription // \"\",.gadmLastInstalled" "$gadm_meta")
    fi
done < <(mounts)
