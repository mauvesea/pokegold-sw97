PicrossStageMenu::
; Called with the NPC's text window open. B cancels without starting a game.
	ld hl, .MenuHeader
	call LoadMenuHeader
	call InitScrollingMenu
	call ClearSprites
	xor a
	ld [wMenuScrollPosition], a
	call ScrollingMenu
	ld a, [wMenuJoypad]
	and B_BUTTON
	jr nz, .cancel
	ld a, [wMenuSelection]
	cp NUM_PICROSS_STAGES
	jr nc, .cancel
	ld [wScriptVar], a
	call CloseWindow
	ret
.cancel
	call CloseWindow
	ld a, -1
	ld [wScriptVar], a
	ret

.MenuHeader:
	db MENU_BACKUP_TILES
	menu_coords 1, 1, 18, 10
	dw .MenuData
	db 1
.MenuData:
	db SCROLLINGMENU_DISPLAY_ARROWS
	db 4, 0 ; four visible rows, six stages
	db SCROLLINGMENU_ITEMS_NORMAL
	dba .Stages
	dba .PrintStage
	dba NULL
	dba NULL
.Stages:
	db NUM_PICROSS_STAGES
	for n, NUM_PICROSS_STAGES
		db n
	endr
	db -1
.PrintStage:
	push de
	ld a, [wMenuSelection]
	ld hl, .Names
	ld bc, 15
	call AddNTimes
	ld d, h
	ld e, l
	pop hl
	jp PlaceString
.Names:
	db "1 DIGLETT     @"
	db "2 GENGAR      @"
	db "3 UNOWN       @"
	db "4 SNORLAX     @"
	db "5 POKECENTER  @"
	db "6 POLIWRATH   @"
	assert @ - .Names == NUM_PICROSS_STAGES * 15

PlayPicrossFromOverworld::
; The Toolgear clock also owns window map 1 and masks sprites below LY=128.
; Suspend both its queued transfer and its LCD mask for the whole minigame.
	farcall ToolgearClockTextboxOpened
	ld hl, wToolgearClockFlags
	res TOOLGEAR_CLOCK_DIRTY_F, [hl]
	call FadeToMenu
; The game uses the Overworld Map union. Preserve even dynamically changed
; blocks rather than rebuilding the map from ROM. The SRAM window stack and
; persistent save/mail data are outside sScratch ($a000-$a5ff, bank 0).
	ld a, BANK(sPicrossMapBackup)
	call OpenSRAM
	ld hl, wOverworldMapBlocks
	ld de, sPicrossMapBackup
	ld bc, wOverworldMapBlocksEnd - wOverworldMapBlocks
	call CopyBytes
	call CloseSRAM

	ldh a, [hInMenu]
	push af
	ldh a, [hMapAnims]
	push af
	ldh a, [hWY]
	push af
	ldh a, [hBGMapAddress + 1]
	push af
	ld a, HIGH(vBGMap1) ; prototype displays the window map at WY=0
	ldh [hBGMapAddress + 1], a
	xor a
	ldh [hMapAnims], a
	ld a, 1
	ldh [hInMenu], a
	call PicrossSetupPalettes
	call PicrossMinigame
	call ClearBGPalettes
	farcall ClearSpriteAnims
	call ClearSprites
	pop af
	ldh [hBGMapAddress + 1], a
	pop af
	ldh [hWY], a
	ldh [rWY], a
	pop af
	ldh [hMapAnims], a
	pop af
	ldh [hInMenu], a

	ld a, BANK(sPicrossMapBackup)
	call OpenSRAM
	ld hl, sPicrossMapBackup
	ld de, wOverworldMapBlocks
	ld bc, wOverworldMapBlocksEnd - wOverworldMapBlocks
	call CopyBytes
	call CloseSRAM
	call ExitAllMenus
; Reload clock glyphs and both window rows after Picross overwrote their VRAM.
	farcall ToolgearClockTextboxClosed
	ret

PicrossSetupPalettes:
; Match the prototype's monochrome shades on DMG, SGB and CGB.
	ld b, SCGB_BATTLE_GRAYSCALE
	call GetSGBLayout
	ldh a, [hCGB]
	and a
	ret z
	ld hl, wAttrmap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	xor a
	call ByteFill
	farcall ApplyAttrmap
	ld hl, .Grayscale
	ld de, wBGPals1
	ld bc, 1 palettes
	call CopyBytes
	ld hl, .Grayscale
	ld de, wOBPals1
	ld bc, 1 palettes
	jp CopyBytes
.Grayscale:
	RGB 31, 31, 31
	RGB 21, 21, 21
	RGB 10, 10, 10
	RGB  0,  0,  0

	assert sPicrossMapBackup + 1300 <= $a600
	assert wPicrossRAM == wOverworldMapBlocks
	assert wPicrossRAMEnd <= wOverworldMapBlocksEnd
	assert wPicrossRAM >= wSpriteAnimDataEnd
