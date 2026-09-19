# Changes

Bringing `sharp-mz80k/FD_rom.s` into line with `OPERATING.md`.

`OPERATING.md` was treated as the specification throughout. Where the ROM and the
document disagreed, the ROM was changed; the document was only edited where it
contradicted itself or left behaviour undefined.

## Summary

Before this pass the ROM implemented roughly a quarter of what the operator guide
described. There was no monitor command-line parser at all — `*FD` went straight to
the file menu — and the menu supported six keys out of the thirteen documented. Four
of the Pico-side handlers that the documented menu operations depend on were
addressing the wrong directory and could never have succeeded.

Every monitor command and menu key documented in `OPERATING.md` is now implemented. The
ROM grew from 1342 to 3240 bytes, leaving 849 bytes of the 4089-byte budget free.

One documented behaviour is still missing: the guide says that pressing ENTER after
`LOAD` without naming a file should bring up the File Menu. `MLHED` still reports
`NO FILENAME` instead. Entering the menu from inside BASIC means never returning to it,
so this needs a decision about what should happen afterwards rather than a quick patch.

---

## Decision that needed a call

`OPERATING.md` assigned `A` and `D` to two different things each: page-back and
page-forward under "Navigation", and "copy to 0000.mzf" (`A`) and "delete" (`D`) in
the per-key list below it. Both could not be true.

Resolved in favour of the per-key list, because it is the more detailed and more
recently written of the two. Paging moved to `,` and `.`, and the Navigation section
of `OPERATING.md` was updated to match.

---

## `sharp-mz80k/FD_rom.s`

### Monitor command line — all of this was missing

The ROM had no parser. It jumped straight to the file menu from `0xF001`, so none of
the documented commands worked and `*FD` did the wrong thing.

Added `FDSTART`, which reads the command line out of `LBUF` (tolerating a missing
`*` prompt character) and dispatches:

| Command | Behaviour |
| --- | --- |
| `*FD` | Loads and runs `0000.mzf` (SD command `0x81`) |
| `*FDF` | Opens the file menu |
| `*FDS saddr eaddr xaddr name` | Saves a memory block (SD command `0x80`) |
| `*FDM saddr` | Displays memory, 128 bytes per screen — no Pico traffic |
| `*FDW saddr hexbytes` | Writes hex byte pairs into memory, then re-prompts |

`*FDS` validates that the end address is above the start address and that a filename
is present, reporting `ADDRESS FAILED!` / `FILENAME FAILED!` as the guide describes.

`*FDM` honours the documented "cancel at any time with SHIFT+BREAK, even while a
single screen is being displayed" by testing the key between every byte printed, not
just at the page prompt.

`*FDW` re-prints `*FDW nnnn ` after each line so the monitor's line editor picks the
whole line back up, stops on an empty line, and writes the valid data up to the first
non-hex character — all as documented.

### File menu keys

Previously only `W`, `S`, `A`, `D`, `R`, `/` and BREAK did anything. Now:

| Key | Action | Status |
| --- | --- | --- |
| `W` / `S` | Up / down one line | was present |
| `,` / `.` | Page back / forward | replaces `A`/`D` |
| `X` or ENTER | Load and run | `X` added |
| `L` | Load without running | added |
| `H` | Help page | added |
| `F` | Filter by next letter typed | replaces the old `/` line-input search |
| `T` | Cycle ALL → BASIC → M-CODE | added |
| `A` | Copy to `0000.mzf` (SD `0x82`) | added |
| `C` | Copy file (SD `0x87`) | added |
| `R` | Rename file (SD `0x85`) | added, was "run" |
| `D` | Delete file (SD `0x84`) | added, was "next page" |
| `P` | Print/dump file (SD `0x86`) | added |
| SHIFT+BREAK | Exit to monitor | was present |

`L` reports the load address and returns to the monitor rather than to the menu,
since a loaded program may sit on top of the menu's own work area at `0xC800`.

A status line now shows the active type filter and letter filter.

### Key code handling — corrected

The monitor's `GETKY` at `001BH` returns *device* codes, not plain ASCII: CR is `66H`
and SHIFT+BREAK is `64H` (confirmed against the SP-1002 subprogram documentation).
Both alias onto lower-case letters once bit 5 is cleared — `64H & 5FH` is `'D'` and
`66H & 5FH` is `'F'`.

The older `artefacts/FD_rom_v0.1.s` masks with `AND 5FH` *before* testing for BREAK,
which means BREAK reads as `D` and CR reads as `F`. That idiom was deliberately **not**
carried over. The new dispatcher tests `64H` and `66H` first and never masks, which is
what makes it safe to bind `D` (delete) and `F` (filter) at all.

### Paging with a filter active — fixed

`GET_PAGE` used to start at raw index `page × 16` and scan exactly 16 entries, keeping
whichever matched. With a filter on, that produced short pages and silently skipped
files. It now counts *matching* entries: it skips `page × 16` matches, then collects up
to 16 more.

### Repeated directory rescans — fixed

`LOAD_SELECTED` called `GET_FILE_COUNT` on every iteration of its file-scanning loop,
and each of those triggers a full directory scan on the Pico. The scan is gone
entirely: `GET_PAGE` now records each row's Pico file index in a new `INDEX_BUFFER`,
so the selected file is looked up directly.

### Other fixes in the ROM

- `CLEAR_SCREEN` used to reset `CURSOR_POS`, so every redraw jerked the highlight back
  to the top of the page. It now only clears the screen.
- `DRAW_SCREEN` clamps `CURSOR_POS` to the last populated row, so changing a filter
  cannot leave the marker pointing past the end of a now-shorter page.
- `MOVE_DOWN` returned the cursor unchanged on an empty page and could step past the
  end if `CURSOR_POS` was already out of range; both are now guarded.
- Filenames are sent with the new `SNDNAME`, which emits the name, its CR, then NUL
  padding to exactly 33 bytes. The Pico needs the CR for `addmzf()` and the NUL for
  `addrootdir()`; the old code sent whatever happened to follow the name in memory.
- `*FDW`'s re-prompt loop now detects a BREAK out of `GETL` (reported as `1BH` in the
  first column) instead of re-parsing a line that is not there and looping forever.
- Dropped the unused `STCMD` wrapper and the write-only `FILE_COUNT` variable.
- `ENT1`–`ENT5` remain at `0xF004`, `0xF007`, `0xF00A`, `0xF00D` and `0xF010` —
  verified against the addresses `sharp-mz80k/tools/filehandle_patch.py` patches in.

---

## `sharp-mz80k/sharp_mz.cpp`

### Wrong directory on four handlers — fixed

`f_del()`, `f_ren()`, `f_dump()` and `f_copy()` called `addmzf()` but never
`addrootdir()`, unlike `f_save()`, `astart()` and `mon_whead()` which call both.

`ffconf.h` sets `FF_FS_RPATH 2` and nothing in the project ever calls `f_chdir()`, so a
bare `TEST.mzf` resolves to `/TEST.mzf` — not `/MZ_FD/TEST.mzf`. Every delete, rename,
dump and copy would therefore have reported "file not found". Since `OPERATING.md`
documents all four as working menu operations, they had to be fixed for the new ROM
keys to do anything.

Added a `recv_path()` helper that receives the name and builds the full path. It also
guarantees the CR and NUL terminators that `addmzf()` and `addrootdir()` each rely on,
which the raw 33-byte read did not.

### `FILEINFO` (`0xA1`) now reports the file type

The `T` key needs to know whether each file is BASIC or machine code, and the listing
protocol carried only the name. `sendFileName()` now sends the MZF header type byte
(header offset 0) immediately after the status byte and before the name.

`getFileAttribute()` reads that byte by opening the file at the given index. It is read
per listed entry rather than cached during `establishFileList()`, which would have
added an open for all 255 possible files to every directory scan.

**This is a protocol change.** The ROM and the Pico firmware must be updated together —
an old ROM against this firmware will read the type byte as the first character of the
filename.

### Off-by-one in ROM upload

`SharpMZ_initialise()` copied the ROM with `i <= fd_rom_start + fd_rom_size`, reading
one byte past the end of `fd_rom_data[]`. Changed to `<`.

---

## `OPERATING.md`

Only the parts that were self-contradictory or undefined:

- Navigation split into `W`/`S` for line movement and `,`/`.` for paging, resolving the
  clash with `A` (autoboot copy) and `D` (delete).
- `R` and `C` now state that the new name is written to the IBF filename as well as
  the SDCard filename. The guide said this for SAVE but not for rename or copy, which
  left it ambiguous whether a rename touches the header.
- `L` now states that it reports the load address and returns to the monitor.
- `F` now states that ENTER or SHIFT+BREAK at the prompt clears the filter. The guide
  described how to set a filter but not how to remove one.
- `T` now states that it cycles through three settings rather than two. A two-way
  toggle gives no way back to showing every file, which contradicts `*FDF` listing all
  files on entry. Also records that type byte `01H` means machine code.

The `H` (help) entry was already present and is unchanged.

---

## IBF filenames used for listing and matching

`OPERATING.md` is explicit that the name a user sees and types is the **IBF name** —
the one stored inside the file header — not the name on the SD card:

> "when listing filenames and referencing files from programs like BASIC, the IBF
> filename is used from within the file header"
>
> "All filenames are their IBF filename not the filename on the SDCard."

The code used the SD card filename throughout. That is now fixed.

### Reading the name out of the header

`FileEntry` gained `displayname` (the IBF name) and `attr`, both filled by a new
`readHeaderInfo()` that reads the first 18 bytes of each file: byte 0 is the type and
bytes `01H`–`11H` are the name, CR-terminated. Space padding is trimmed from both ends
— a leading space would otherwise defeat the menu's first-letter filter.

A file with no readable header falls back to its SD filename minus `.mzf`, so a damaged
file is still listed and still reachable rather than showing as a blank row.

This also replaced the per-entry `getFileAttribute()` open added earlier: the type byte
now comes from the same read as the name, so listing costs one file open per entry
instead of two.

### Matching a name back to a file

New `resolve_name()` maps a name from the Z80 to a real SD path, trying in order:

1. exact IBF name
2. exact SD filename
3. IBF name prefix (only for BASIC's `LOAD`, which allows abbreviation)

Step 2 is what keeps `*FD` booting `0000.mzf` by its SD name — that file's IBF name is
whatever program it holds, so an IBF-only lookup would break the documented autoboot.

Now resolving through IBF names: `f_del`, `f_ren`, `f_dump`, `f_copy`, `astart`,
`f_load` and `mon_lhead`. `sendFileData` still uses the SD path directly because the
menu loads by index, not by name.

`dirlist` (`0x83`) was rewritten to walk the cached list and send IBF names, which also
fixed its "previous page" branch — it reopened the directory and reset to page 1, so
paging back always jumped to the start.

### Rename and copy update the header

Since the listing shows IBF names, renaming or copying a file now writes the new name
into the header as well (`write_ibf_name()`). Without that, a rename would appear to do
nothing in the menu.

Both check the destination against existing **IBF** names, as the guide describes.
Rename excludes the file being renamed from that check, so giving a file an IBF name
that already matches its own SD filename is not reported as a collision with itself.

### Duplicate IBF names are tagged in the listing

IBF names are not unique, and duplicates are common in practice — a patched `_FD` build
keeps the same header name as the original it came from. Three of the seven distinct
IBF names in `sharp-mz80k/mzFiles/` are duplicated for exactly this reason.

Left alone that is dangerous: the second file of a pair is unreachable by name, so a
menu delete or rename aimed at it would silently act on the first instead.

`disambiguateNames()` now tags each member of a duplicate group `<1`, `<2`, `<3` … in
directory-scan order, so every file can be named on its own. The tag is appended, or
overwrites the tail when the name is already too long to grow:

| SD filename | listed as |
| --- | --- |
| `BASIC_SP_5025.mzf` | `BASIC SP-5025<1` |
| `BASIC_SP_5025_FD.mzf` | `BASIC SP-5025<2` |
| `EXTENDED-SP5025-BASIC-80K-FD.mzf` | `*EXTENDED BASIC<1` |
| `EXTENDED-SP5025-BASIC-80K.mzf` | `*EXTENDED BASIC<2` |

**Only the scanned listing is tagged — no file on the card is modified.** `FileEntry`
keeps both forms: `rawname` is exactly what the header says, `displayname` carries the
tag. They are used differently:

- `resolve_name()` matches the tagged name first (the only way to single out one file
  of a group), then the raw header name, then the SD filename, then a raw-name prefix.
  So `LOAD "BASIC SP-5025"` from BASIC still works untagged and finds the first match.
- `ibf_name_taken()` compares against `rawname`, because a tag is a label this scan
  invented and must not make a name look free or taken when rename and copy check it.

Because a tag depends on what else is on the card, it can move when files are added or
removed. `OPERATING.md` says so and points at `R` for giving a file a permanent name of
its own.

### ROM name field widened

The cached name field grew from 16 bytes (15 characters) to `NAME_FIELD` = 18 bytes
(17 characters plus CR), so a full-length IBF name and its tag both stay visible —
`*EXTENDED BASIC<1` is 17 characters and would otherwise have been cut back to
`*EXTENDED BASI`, hiding the very tag that distinguishes it.

`PAGE_BUFFER` therefore grew from 256 to 288 bytes and the buffers after it moved:
`ATTR_BUFFER` to `0C950H`, `INDEX_BUFFER` to `0C960H`, `NAMEBUF` to `0C970H`. The slot
address calculation in `STORE_ENTRY` is now `slot * 18` rather than a shift by four.

## Pre-existing bug found: `f_save` wrote a malformed header

`f_save()` wrote the type byte, the 17-byte name, and then **an extra null** before the
size, load and exec addresses. That pushed all three fields one byte past where the MZF
format puts them (`12H`, `14H`, `16H`) and one byte past where `f_send()` reads them
back, so anything saved with `*FDS` would have reloaded with the wrong size and
addresses.

The stray null is gone and the trailing pad grew from 103 to 104 bytes to keep the
header at 128. `mon_whead()` was never affected — it writes the 128-byte header
verbatim from the Z80.

## Verification

- `sjasmplus` assembles clean: 0 errors, 0 warnings.
- Full Pico firmware links clean via `ninja`.
- ROM is 3240 bytes against the 4089-byte limit asserted in `SharpMZ_initialise()`.
- Entry point addresses checked byte-for-byte in the generated `FD_rom.h` against
  `filehandle_patch.py`.
- Every ROM/Pico exchange was traced by hand against the handler in `sharp_mz.cpp` —
  byte counts and status-byte ordering for save, load, astart, delete, rename, copy,
  dump, file count and file info.
- The header-parsing logic was run against the real `.mzf` files in
  `sharp-mz80k/mzFiles/`, and returns sensible IBF names and type bytes for all ten.
- The duplicate-tagging pass was run over the same ten files: all ten listed names come
  out unique, and the longest is 17 characters — exactly what the widened field holds.

**Not tested on hardware.** No MZ-80K was available, so nothing here has been run on a
real machine. The command-line commands (`*FDS`, `*FDM`, `*FDW`) and the new menu file
operations are the least proven: they depend on monitor routines (`HLHEX`, `TWOHEX`,
`PRTWRD`, `ADCN`, `DISPCH`) whose register-preservation behaviour was inferred from the
working code in `artefacts/FD_rom_v0.1.s` rather than from a datasheet. The call
patterns used here mirror that file's.
