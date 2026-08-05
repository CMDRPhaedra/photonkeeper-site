#!/bin/bash
# Photonkeeper — DWARF Mini compatibility check.
#
# Read-only. It looks at what is mounted and asks macOS what the device says
# about itself. It does not open, copy, move, rename or delete a single file
# on the telescope.
#
# Run it with the telescope connected over USB, then send back everything it
# prints.

echo "Photonkeeper compatibility check — $(date)"
echo "macOS $(sw_vers -productVersion)"
echo

echo "=== 1. What is mounted ==============================================="
ls -1 /Volumes
echo

echo "=== 2. Volumes with an Astronomy folder =============================="
found=0
for vol in /Volumes/*; do
  if [ -d "$vol/Astronomy" ]; then
    found=1
    echo "FOUND: $vol"
    echo
    echo "--- what macOS says about the device ---"
    diskutil info "$vol" 2>/dev/null | grep -E \
      "Device Node|Device / Media Name|Volume Name|File System Personality|Removable Media|Disk Size|Allocation Block Size|Volume Free Space"
    echo
    echo "--- top level of the volume ---"
    ls -1 "$vol" 2>/dev/null | head -20
    echo
    echo "--- inside Astronomy (this is the important bit) ---"
    ls -1 "$vol/Astronomy" 2>/dev/null | head -30
    echo
    echo "--- one session's contents, first 12 files ---"
    session=$(find "$vol/Astronomy" -mindepth 1 -maxdepth 1 -type d ! -name "CALI_FRAME" 2>/dev/null | head -1)
    if [ -n "$session" ]; then
      echo "session folder: $(basename "$session")"
      ls -1 "$session" 2>/dev/null | head -12
    else
      echo "(no session folders found at that level)"
    fi
    echo

    # The part that actually answers the question. Nothing the telescope says
    # over USB distinguishes one DWARF from another - the strings in sections 3
    # and 4 are the vendor's and the Linux storage gadget's, shared across the
    # range - but the firmware writes its own model name into every frame.
    #
    # A FITS header is 80-column ASCII cards in 2880-byte blocks ending at END,
    # so this reads 5,760 bytes and decodes no image data whatsoever.
    echo "--- what one frame's header says (the important bit) ---"
    fits=$(find "$vol/Astronomy" -type f \( -iname '*.fits' -o -iname '*.fit' \) 2>/dev/null | head -1)
    if [ -n "$fits" ]; then
      echo "file: ${fits#"$vol"/}"
      head -c 5760 "$fits" 2>/dev/null \
        | LC_ALL=C fold -w 80 | sed 's/ *$//' | grep -v '^$' | head -40
    else
      echo "(no FITS files found on the volume)"
    fi
    echo

    # One line per session folder, because a single sample is not
    # representative: a DWARF 3 measured across its own firmware history writes
    # DWARFIII, DWARF III and DWARF 3 at different dates, all on one telescope.
    # If the Mini has done the same we need to see the whole spread, not
    # whichever frame happened to sort first.
    echo "--- model name per session, to catch firmware changing its spelling ---"
    find "$vol/Astronomy" -mindepth 1 -maxdepth 2 -type d 2>/dev/null | head -25 | while read -r dir; do
      f=$(find "$dir" -maxdepth 1 -type f \( -iname '*.fits' -o -iname '*.fit' \) 2>/dev/null | head -1)
      [ -z "$f" ] && continue
      ident=$(head -c 5760 "$f" 2>/dev/null | LC_ALL=C fold -w 80 \
              | grep -E '^(TELESCOP|INSTRUME|FIRMWARE)' | sed 's/ *$//' | tr '\n' ' ')
      [ -n "$ident" ] && echo "  ${dir#"$vol/Astronomy/"}: $ident"
    done
    echo
  fi
done
[ "$found" -eq 0 ] && echo "No mounted volume has an Astronomy folder."
echo

echo "=== 3. What the device calls itself over USB ========================="
# ioreg rather than system_profiler: SPUSBDataType returns nothing at all on
# some Macs, and this is the same registry the app itself reads.
ioreg -p IOUSB -l -w0 2>/dev/null \
  | grep -E '"USB Product Name"|"USB Vendor Name"|"USB Serial Number"' \
  | sed 's/^[ |]*//' | sort -u
echo

echo "=== 4. What it calls itself as a disk ================================"
ioreg -c IOBlockStorageDevice -l -w0 2>/dev/null \
  | grep -o '"Device Characteristics" = {[^}]*}' \
  | sed 's/^/  /' | sort -u
echo

echo "=== end — please send everything above ==============================="
