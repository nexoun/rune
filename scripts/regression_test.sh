#!/bin/sh
# Regression test generated fonts against last tagged release
set -e

mkdir -p prev_release

OLD_FONT=prev_release/hinted/Roboto\[ital\,wdth\,wght\].ttf
GENNED_FONT=fonts/hinted/Roboto\[ital\,wdth\,wght\].ttf

API_URL="https://api.github.com/repositories/86081751/releases/latest"
# Use the token to avoid the rate limit on anonymous requests.
RESP=$(curl -sS -H "Authorization: Bearer $GITHUB_TOKEN" "$API_URL")
DL_URL=$(printf '%s\n' "$RESP" | jq -r '.assets[0].browser_download_url // empty')
if [ -z "$DL_URL" ]; then
    echo "Could not get the download URL of the latest release. API response:"
    printf '%s\n' "$RESP"
    exit 1
fi
wget "$DL_URL"
unzip Roboto_*.zip -d prev_release


# Diff old hinted variable font against current
diff ()
{
    diffenator $OLD_FONT $GENNED_FONT -i "$2" \
        -html > $1/index.html \
        -rd -r ./img/ \
        --ft-hinting normal
    mv img/ $1
}


mkdir -p diffs \
	 diffs/Regular \
	 diffs/Condensed \
	 diffs/Italic \
	 diffs/CondensedItalic


diff diffs/Regular "wght=400, wdth=100"
diff diffs/Condensed "wght=400, wdth=75"
diff diffs/Italic "ital=1, wght=400, wdth=100"
diff diffs/CondensedItalic "ital=1, wght=400, wdth=75"

