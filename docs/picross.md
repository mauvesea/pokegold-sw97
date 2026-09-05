# Picross port

Source: [pret/pokegold-spaceworld at 5b555967e18171d06c6c7f630c0fcc9eeba52519](https://github.com/pret/pokegold-spaceworld/blob/5b555967e18171d06c6c7f630c0fcc9eeba52519/engine/games/picross_minigame.asm).

The youngster at **New Bark Town (10, 8)** opens a scrolling menu with four
visible rows and all **six** source stages. This map is displayed as TEAL BURG
in this project. An existing save made outdoors can retain the old map-object
list; enter a building and leave it to reload the new NPC.

| Stage | Pattern source in this project |
| --- | --- |
| 1 | `DiglettIcon` |
| 2 | `GhostIcon` (identical to the prototype's `GengarIcon`) |
| 3 | `UnownIcon` |
| 4 | `SnorlaxIcon` |
| 5 | Pokécenter tiles `$20`, `$21`, `$30`, `$31` |
| 6 | First four tiles of `PoliwrathSpriteGFX` |

All six puzzle images and the five supplied Picross graphics were compared
against the pinned upstream PNGs. The puzzle images match exactly. The
Pokécenter pairs are included uncompressed and contiguously, avoiding a tileset
decompression that would destroy Picross's working memory.

The source randomly selects only stages 1–4; the menu deliberately exposes its
two otherwise unreachable definitions as well. There are no seventh/eighth
source stages. The player animation uses this project's Chris graphics instead
of prototype Gold, with a `TO BE CHECKED` comment. The source minigame and its
animation functions contain no sound calls, so no sound substitution was needed.

## Controls and preserved behavior

D-pad moves the cursor by six pixels within the 16×16 board, with the original
eight-update movement delay. A toggles a filled square, B toggles a cross, and
holding A/B while moving paints with the selected cell type. Filling and marking
use `SFX_STRENGTH` and `SFX_BUMP`; clearing either uses `SFX_GRASS_RUSTLE`.
Completing every filled cell plays `SFX_ITEM`, waits three seconds, and returns
to the map automatically. Select gives up before completion, plays
`SFX_SHUT_DOWN_PC`, waits three seconds, and returns. B cancels stage selection.

Picross plays `MUSIC_GAME_CORNER` while active and restores the map music on
return. On SGB, it uses the same palette packet and all-palette-zero block map
as the Trainer Card. CGB retains the grayscale board palette.

The board, clues, packed-tile drawing routines, player movement, cursor blink,
and dust frames follow the source. The port uses interrupt-sampled button edges
and an eight-tile transfer helper to retain the original input semantics and
two-VBlank grid reads/writes; the general helpers in this project differ.

## Dependency audit

Every file in the pinned source containing a Picross reference was reviewed:

- `engine/games/picross_minigame.asm`: game loop, board/clues, layouts, graphics.
- `engine/sprite_anims/functions.asm`: cursor movement and player animation.
- `data/sprite_anims/objects.asm`, `framesets.asm`, `oam.asm`: three objects,
  four framesets, and three OAM entries, appended without renumbering existing IDs.
- `data/sprite_anims/gfx.asm`: Picross loads its graphics and dictionary directly;
  its unused generic graphics lookup is not needed by this entry point.
- `constants/minigame_constants.asm`, `constants/sprite_anim_constants.asm`.
- `ram/wram.asm`, `ram/vram.asm`.
- `main.asm`: the game has its own relocatable ROM section here.
- `engine/debug/subgame_debug_menu.asm`: upstream's only external caller;
  replaced by the NPC/menu and overworld lifecycle wrapper here.

Additional transitive dependencies checked include sprite/icon and tileset
storage, coordinate/OAM macros, joypad synchronization, VBlank transfers,
banking/copy helpers, palette setup, scrolling menus and menu teardown. The
upstream animation callback's literal `$18` actually means the second Gold
frameset, despite its dust comment; the port uses the correct symbolic ID.

## Memory and restoration

Picross intentionally shares the existing **Overworld Map** scratch union only
while overworld processing is suspended. It adds no persistent WRAM allocation
and does not move existing WRAM, party or save fields. Current linked addresses
are the same in all four builds:

| Storage | Inclusive range | Purpose |
| --- | --- | --- |
| Picross WRAM | `$c700–$cae9` (1002 bytes) | All game state and scratch buffers |
| Marked cells | `$c708–$c807` | 256 cell states |
| Layout storage | `$c808–$c847` | Four 2bpp tiles, including reserved leading byte |
| Solution bitmap | `$c848–$c947` | 256 binary cells |
| Clue buffer | `$c958–$ca57` | 256 bytes |
| Tile update buffer | `$ca58–$cae7` | Nine 2bpp tiles |
| Overworld map blocks | `$c700–$cc13` | Backed up in full before play |
| Temporary SRAM backup | Bank 0, `$a000–$a513` | 1300 original map-block bytes |
| Persistent SRAM begins | Bank 0, `$a600` | Mail/save area, outside backup |
| SRAM menu stack | Bank 0, `$b800–$bfff` | Outside backup |

Sprite animation state ends at `$c5c9`, below Picross. Video-transfer buffers,
menu/script state, audio, player data, party and stack are outside its WRAM span.
Picross's animation flag, which upstream placed separately in another union,
is part of its own bounded allocation here. The source's `$514`-byte clear from
`wPicrossMarkedCells` is replaced with `wPicrossRAMEnd - wPicrossRAM`, including
all control fields and excluding unrelated storage. The layout's `buffer - 1`
access is backed by an explicitly reserved byte, not an underrun.

Linker assertions enforce the allocation and backup bounds. SRAM is closed after
each copy. No minigame routine decompresses or uses SRAM scratch while the backup
is live. The original map blocks, including dynamic edits, are restored before
normal menu teardown reloads the overworld graphics and palettes.

VRAM uses `$8000` for sprites, `$8800–$8eff` for background/clues, and
`$8f00–$97ff` for the board. These are explicit aliases within the existing VRAM
allocation. The cursor copy is bounded to its six actual tiles, fixing the
source's nine-tile overread. Window map 1 (`$9c00`) displays the game at WY=0.

The local Toolgear clock also writes window map 1 and masks sprites below LY=128.
Its rendering, queued transfer and sprite mask are suspended during Picross.
Its glyphs and both window rows are regenerated after returning. Map animations
are suspended, and menu/window state is restored around the game.

## Verification

Build all variants with `make -j4`. Run the reusable headless checks with PyBoy:

```sh
python tools/test_picross.py pokegold.sgb pokesilver.sgb pokegold_debug.sgb pokesilver_debug.sgb
```

The checks use temporary ROM copies, no player save, and a test-only entry
trampoline in emulator memory. They verify linked bounds, independent expected
bitmaps, clue generation, A/B sounds, toggling and drag painting, cursor limits,
every puzzle's filled cells, solved-state sound and automatic timed exit, Select
give-up sound and timed exit, and untouched WRAM sentinels. All 48
stage/variant/hardware-mode combinations and eight give-up paths passed (DMG and
forced CGB mode).
SGB palette setup uses the existing Trainer Card layout; SGB hardware was not
tested.

Additional emulator integration checks used a disposable copy of the existing
save: approach and talk to the NPC, scroll/select all six stages, cancel with B,
complete/return from each stage, give up with Select, and start a second game
without reloading. Game Corner music was active during Picross; map music,
map-block bytes, party bytes, and the Toolgear clock were restored on return.
Menu, puzzle and restored town/clock screens were visually inspected.
Integration completion used an injected solved bitmap; the standalone checks
fill each required cell through actual A-button processing.
