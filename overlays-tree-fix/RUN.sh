#!/bin/bash
# Alch3myOS 17 - switch packages/overlays/Lineage in the build tree to the
# Alch3myOS fork, clean up the leftovers from the earlier scripts, and check
# the fonts fix is complete. Run it from anywhere inside your source tree.
echo "============================================================"
echo " Alch3myOS 17 - packages/overlays/Lineage tree fix"
echo "============================================================"

# Find the top of the source tree (the folder that has .repo)
TOP="$PWD"
while [ "$TOP" != / ] && [ ! -d "$TOP/.repo" ]; do TOP="$(dirname "$TOP")"; done
[ -d "$TOP/.repo" ] || TOP="$HOME/17/alos"
[ -d "$TOP/.repo" ] || { echo " STOPPED: can't find your source tree. cd into it (e.g. ~/17/alos) and run this again."; exit 1; }
cd "$TOP" || exit 1
echo " Source tree: $TOP"

if command -v repo >/dev/null 2>&1; then REPO=repo; else REPO="python3 $TOP/.repo/repo/repo"; fi
P=packages/overlays/Lineage

echo; echo " [1/4] Updating the manifest ..."
$REPO sync -q -c --no-tags android >/dev/null 2>&1   # the manifest repo itself, if tracked
$REPO manifest -o - 2>/dev/null | grep -q 'name="Alch3myOS/packages_overlays_Lineage"' || {
    # repo only refreshes the manifest during a sync; do a light one
    $REPO sync -q -c --no-tags vendor/extras >/dev/null 2>&1
    $REPO manifest -o - 2>/dev/null | grep -q 'name="Alch3myOS/packages_overlays_Lineage"' || {
        echo " STOPPED: your manifest still points $P at LineageOS."
        echo " Push the manifest change (folder 2 of the fonts fix) to Alch3myOS/android branch 17, then run this again."
        exit 1; }
}
echo "       manifest tracks Alch3myOS/packages_overlays_Lineage"

echo " [2/4] Removing the old LineageOS checkout and leftovers ..."
rm -rf "$P" ".repo/projects/$P.git" ".repo/project-objects/LineageOS/android_packages_overlays_Lineage.git"
echo "       done"

echo " [3/4] Syncing $P and vendor/extras ..."
$REPO sync -c --force-sync --no-tags --no-clone-bundle "$P" vendor/extras || { echo " STOPPED: repo sync failed (see above). Paste it to Claude."; exit 1; }

echo " [4/4] Checking ..."
OK=1
[ -d "$P/customizations/BlackTheme" ] && echo "       OK  $P checked out" || { echo "       BAD $P is missing"; OK=0; }
[ ! -e "$P/fonts" ] && echo "       OK  no fonts/ in $P" || { echo "       BAD $P still has fonts/"; OK=0; }
git -C "$P" log -1 --format=%s 2>/dev/null | grep -q 'Drop the fonts' && echo "       OK  $P is on the Alch3myOS fork" || { echo "       BAD $P isn't on the Alch3myOS fork"; OK=0; }
grep -q 'google-sans-flex-medium' vendor/extras/product/etc/fonts_customization.xml 2>/dev/null && echo "       OK  vendor/extras has the Google Sans Flex aliases" || { echo "       BAD vendor/extras is missing the font aliases (folder 3 not pushed?)"; OK=0; }
LEFT=$(find packages/overlays -maxdepth 3 \( -name packages_overlays_Lineage -o -name '1-packages_overlays_Lineage' \) 2>/dev/null)
[ -z "$LEFT" ] && echo "       OK  no leftover copies" || { echo "       BAD leftovers: $LEFT"; OK=0; }

echo "============================================================"
if [ $OK = 1 ]; then echo " ALL GOOD. Start the build."; else echo " Something is off (see BAD above). Paste this to Claude."; fi
echo "============================================================"
[ $OK = 1 ]
