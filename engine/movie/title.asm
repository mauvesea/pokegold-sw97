TitleScreen:
	call ClearPalettes
	xor a
	ld [wTimeOfDayPal], a
	ldh [hMapAnims], a
	ldh [hSCY], a
	ldh [hSCX], a

	ld de, MUSIC_NONE
	call PlayMusic

	call ClearTilemap
	call DisableLCD
	call ClearSprites
	farcall ClearSpriteAnims

	ld hl, vTiles0
	ld bc, vBGMap0 - vTiles0
	xor a
	call ByteFill

	ld hl, TitleScreenGFX
	ld de, vTiles2 tile $41
	ld bc, 13 tiles
	ld a, BANK(TitleScreenGFX)
	call FarCopyBytes

	ld hl, TitleScreenVersionGFX
	ld de, vTiles2 tile $60
	ld bc, 24 tiles
	ld a, BANK(TitleScreenVersionGFX)
	call FarCopyBytes

	ld hl, TitleScreenHoOhGFX
	ld de, vTiles2
	ld bc, 49 tiles
	ld a, BANK(TitleScreenHoOhGFX)
	call FarCopyBytes

	ld hl, TitleScreenLogoGFX
	ld de, vTiles1
	ld bc, 58 tiles
	ld a, BANK(TitleScreenLogoGFX)
	call FarCopyBytes

	ld hl, TitleScreenVersionLogoGFX
	ld de, vTiles1 tile $3a
	ld bc, 20 tiles
	ld a, BANK(TitleScreenVersionLogoGFX)
	call FarCopyBytes

; The Space World title alternated these tiles with the notes used by the
; Pikachu minigame. This port always uses the flame tiles.
	ld hl, TitleScreenFireGFX
	ld de, vTiles0
	ld bc, 8 tiles
	ld a, BANK(TitleScreenFireGFX)
	call FarCopyBytes

	ld hl, wSpriteAnimDict
	xor a ; SPRITE_ANIM_DICT_DEFAULT and tile offset $00
	ld [hli], a
	ld [hl], a

	ld hl, vBGMap0
	ld bc, 128 tiles
	ld a, " "
	call ByteFill

	ld b, SCGB_BETA_TITLE_SCREEN
	call GetSGBLayout

; The title flames are composed of four 8x8 sprites.
	ld hl, rLCDC
	res rLCDC_SPRITE_SIZE, [hl]
	call EnableLCD
	call WaitBGMap
	xor a
	ldh [hBGMapMode], a

; Reset the title sequence state, selected option, and timer.
	ld hl, wJumptableIndex
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a

	call .LoadFirePositions

	ld a, %00011010
	call DmgToCgbBGPals
	ld a, %11100100
	call DmgToCgbObjPal0

	call SetTitleBGDecorationBorder
	ret

.LoadFirePositions:
	ld hl, .FirePositionTable
	ld c, 6
.loop
	push bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
	ld a, SPRITE_ANIM_OBJ_GS_TITLE_FLAME
	call InitSpriteAnimStruct
	pop hl
	pop bc
	dec c
	jr nz, .loop
	ret

.FirePositionTable:
	dbpixel 28,  9, 0, 4
	dbpixel 20, 11, 0, 0
	dbpixel 18, 12, 0, 4
	dbpixel 26, 14, 0, 0
	dbpixel 22, 15, 0, 4
	dbpixel  0, 17, 0, 0

SetTitleBGDecorationBorder:
	ld de, TitleScreenDecorationGFX
	ld hl, vTiles2 tile $50
	lb bc, BANK(TitleScreenDecorationGFX), 9
	call Request2bpp

	hlcoord 0, 8
	ld b, $50
	call .PlaceRow

	hlcoord 0, 16
	ld b, $54

.PlaceRow:
	xor a
	ld c, SCREEN_WIDTH
.loop
	and $03
	or b
	ld [hli], a
	inc a
	dec c
	jr nz, .loop
	ret

TitleScreenSequence:
	ld e, a
	ld d, 0
	ld hl, .SequenceTable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.SequenceTable:
	dw TitleSequence_Start
	dw TitleSequence_LoadPokemonLogo
	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_MoveTitle
	dw TitleSequence_FinishMovingTitle
	dw TitleSequence_InitFlash
	dw TitleSequence_Flash

	dw TitleSequence_PrintPMJapaneseChar
	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_Wait
	dw TitleSequence_PrintPMSubtitle
	dw TitleSequence_Advance
	dw TitleSequence_Advance

	dw TitleSequence_Advance
	dw TitleSequence_Wait
	dw TitleSequence_PrintVersion
	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_Wait
	dw TitleSequence_PrintCopyright

	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_Wait
	dw TitleSequence_PrintHoOh
	dw TitleSequence_Advance
	dw TitleSequence_Advance
	dw TitleSequence_Advance

	dw TitleSequence_Wait
	dw TitleSequence_InitInput
	dw TitleSequence_InputAndTimeout
	dw TitleSequence_FadeMusicOut

TitleSequence_Advance:
	ld hl, wJumptableIndex
	inc [hl]
	ret

TitleSequence_Wait:
	xor a
	ldh [hBGMapMode], a
	ld hl, wTitleScreenTimer
	ld a, [hl]
	and a
	jr z, .done
	dec [hl]
	ret
.done
	jp TitleSequence_Advance

TitleSequence_Start:
	call TitleSequence_Advance
	push de
	ld de, SFX_TITLE_SCREEN_ENTRANCE
	call PlaySFX
	pop de
	ld a, $80
	ld [wTitleScreenTimer], a
	call TitleScreen_SetLYOverrides
	ld a, LOW(rSCX)
	ldh [hLCDCPointer], a
	ret

TitleSequence_LoadPokemonLogo:
	call TitleScreen_PrintPokemonLogo
	call TitleSequence_Advance
	ld a, 1
	ldh [hBGMapMode], a
	ret

TitleSequence_MoveTitle:
	xor a
	ldh [hBGMapMode], a
	ld hl, wTitleScreenTimer
	ld a, [hl]
	and a
	jr z, .done
	add 4
	ld [hl], a
	ld e, a
.waitForLY
	ldh a, [rLY]
	cp $40
	jr c, .waitForLY
	ld a, e
	jp TitleScreen_SetLYOverrides
.done
	jp TitleSequence_Advance

TitleSequence_FinishMovingTitle:
	xor a
	ldh [hLCDCPointer], a
	call TitleSequence_Advance
	ld de, MUSIC_TITLE
	jp PlayMusic

TitleSequence_InitFlash:
	call TitleSequence_Advance
	ld a, %00011010
	ld [wTitleScreenTimer], a
	ld a, 6
	ld [wTitleScreenTimer + 1], a
	ret

TitleSequence_Flash:
	ld hl, wTitleScreenTimer + 1
	ld a, [hl]
	and a
	jr z, .done
	dec [hl]
	ld a, [wTitleScreenTimer]
	xor %00011010
	ld [wTitleScreenTimer], a
	call DmgToCgbBGPals
	call DelayFrame
	jp DelayFrame
.done
	call TitleSequence_Advance
	ld a, %11100100
	jp DmgToCgbBGPals

TitleSequence_PrintPMJapaneseChar:
	call TitleScreen_PrintPMJapaneseChar
	jr TitleSequence_StartRevealWait

TitleSequence_PrintPMSubtitle:
	call TitleScreen_PrintPMSubtitle
	jr TitleSequence_StartRevealWait

TitleSequence_PrintVersion:
	call TitleScreen_PrintVersion
	jr TitleSequence_StartRevealWait

TitleSequence_PrintCopyright:
	call TitleScreen_PrintCopyright
	jr TitleSequence_StartRevealWait

TitleSequence_PrintHoOh:
	call TitleScreen_PrintHoOh

TitleSequence_StartRevealWait:
	ld a, $10
	ld [wTitleScreenTimer], a
	call TitleSequence_Advance
	ld a, 1
	ldh [hBGMapMode], a
	ret

TitleSequence_InitInput:
	call TitleSequence_Advance
	ld hl, wTitleScreenTimer
	ld de, 51 * 60 + 12
	ld [hl], e
	inc hl
	ld [hl], d
	ret

TitleSequence_InputAndTimeout:
	ld hl, wTitleScreenTimer
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld a, e
	or d
	jr z, .timeout
	dec de
	ld [hl], d
	dec hl
	ld [hl], e

	call GetJoypad
	ld hl, hJoyDown

; Up + B + Select opens the save-data deletion screen.
	ld a, [hl]
	and D_UP | B_BUTTON | SELECT
	cp D_UP | B_BUTTON | SELECT
	jr z, .deleteSave

; Retain the retail engine's Down + B + Select clock-reset shortcut.
	ld a, [hl]
	and D_DOWN | B_BUTTON | SELECT
	cp D_DOWN | B_BUTTON | SELECT
	jr z, .resetClock

	ld a, [hl]
	and START | A_BUTTON
	ret z
	ld a, TITLESCREENOPTION_MAIN_MENU
	jr .exit

.deleteSave
	ld a, TITLESCREENOPTION_DELETE_SAVE_DATA
	jr .exit

.resetClock
	ld a, TITLESCREENOPTION_RESET_CLOCK

.exit
	ld [wTitleScreenSelectedOption], a
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

.timeout
	call TitleSequence_Advance
	xor a ; MUSIC_NONE
	ld [wMusicFadeID], a
	ld [wMusicFadeID + 1], a
	ld hl, wMusicFade
	ld [hl], 8
	ret

TitleSequence_FadeMusicOut:
	ld a, [wMusicFade]
	and a
	ret nz
	ld a, TITLESCREENOPTION_RESTART
	ld [wTitleScreenSelectedOption], a
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

TitleScreen_SetLYOverrides:
	ld hl, wLYOverrides
	ld c, $30
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	ret

TitleScreen_PrintPMSubtitle:
	hlcoord 2, 6
	ld b, 15
	ld a, $69
	jr TitleScreen_LoadPrintArea

TitleScreen_PrintVersion:
	hlcoord 4, 1
	ld b, 9
	ld a, $60

TitleScreen_LoadPrintArea:
	ld [hli], a
	inc a
	dec b
	jr nz, TitleScreen_LoadPrintArea
	ret

TitleScreen_PrintPMJapaneseChar:
	hlcoord 15, 2
	ld a, "こ"
	lb bc, 4, 4
	jr TitleScreen_PrintBoxArea

TitleScreen_PrintPokemonLogo:
	hlcoord 15, 3
	ld [hl], $b8
	hlcoord 15, 4
	ld [hl], $b9
	hlcoord 1, 2
	ld a, $80
	lb bc, 14, 4

TitleScreen_PrintBoxArea:
	ld de, SCREEN_WIDTH
	push bc
	push hl
.xloop
	ld [hli], a
	inc a
	dec b
	jr nz, .xloop
	pop hl
	add hl, de
	pop bc
	dec c
	jr nz, TitleScreen_PrintBoxArea
	ret

TitleScreen_PrintCopyright:
	hlcoord 3, 17
	ld a, $41
	ld b, 13
.loop
	ld [hli], a
	inc a
	dec b
	jr nz, .loop
	ret

TitleScreen_PrintHoOh:
	hlcoord 7, 9
	ld de, SCREEN_WIDTH - 7
	xor a
	ld b, 7
.row
	ld c, 7
.column
	ld [hli], a
	inc a
	dec c
	jr nz, .column
	add hl, de
	dec b
	jr nz, .row
	ret
