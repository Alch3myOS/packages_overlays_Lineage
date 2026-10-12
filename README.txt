Alch3myOS 17 - packages/overlays/Lineage tree fix
==================================================

One script, run it on the build server:

  bash overlays-tree-fix/RUN.sh

Run it from anywhere inside your source tree (or anywhere at all if your
tree is ~/17/alos). It:
  1. refreshes the manifest and checks it points packages/overlays/Lineage
     at Alch3myOS/packages_overlays_Lineage
  2. deletes the old LineageOS checkout and the leftover copies from the
     earlier scripts (only that one folder and its git data)
  3. syncs packages/overlays/Lineage and vendor/extras fresh
  4. checks everything and prints ALL GOOD, then you start the build

Safe to run more than once. Tested with the real repo tool on a tree set
up the same way as yours.
