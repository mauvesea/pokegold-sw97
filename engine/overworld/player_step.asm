_HandlePlayerStep::
	ld a, [wPlayerStepFlags]
	and a
	ret z
	bit PLAYERSTEP_START_F, a
	jr nz, .update_overworld_map
	bit PLAYERSTEP_STOP_F, a
	jr nz, .update_player_coords
	bit PLAYERSTEP_CONTINUE_F, a
	jr nz, .finish
	ret

.update_overworld_map
	ld a, 4
	ld [wHandlePlayerStep], a
	ldh a, [hOverworldFlashlightEffect]
	and a
	jr nz, .update_overworld_map_flashlight
	call UpdateOverworldMap
	jr .finish

.update_overworld_map_flashlight
	call UpdateOverworldMap_Flashlight
	jr .finish

.update_player_coords
	call UpdatePlayerCoords
	jr .finish

.finish
	call HandlePlayerStep
	ld a, [wPlayerStepVectorX]
	ld d, a
	ld a, [wPlayerStepVectorY]
	ld e, a
	ld a, [wPlayerBGMapOffsetX]
	sub d
	ld [wPlayerBGMapOffsetX], a
	ld a, [wPlayerBGMapOffsetY]
	sub e
	ld [wPlayerBGMapOffsetY], a
	ret

ScrollScreen::
	ld a, [wPlayerStepVectorX]
	ld d, a
	ld a, [wPlayerStepVectorY]
	ld e, a
	ldh a, [hSCX]
	add d
	ldh [hSCX], a
	ldh a, [hSCY]
	add e
	ldh [hSCY], a
	ret

HandlePlayerStep:
	ld hl, wHandlePlayerStep
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ld a, [hl]
	ld hl, .Jumptable
	rst JumpTable
	ret

.Jumptable:
	dw GetMovementPermissions
	dw BufferScreen
	dw .fail1
	dw .fail2
; The rest are never used.  Ever.
	dw .fail1
	dw .fail1
	dw .fail1
	dw .fail1
	dw .fail1
	dw .fail1
	dw .fail1

.fail1
	ret

.fail2
	ret

UpdatePlayerCoords:
	ld a, [wPlayerStepDirection]
	and a
	jr nz, .check_step_down
	ld hl, wYCoord
	inc [hl]
	ret

.check_step_down
	cp UP
	jr nz, .check_step_left
	ld hl, wYCoord
	dec [hl]
	ret

.check_step_left
	cp LEFT
	jr nz, .check_step_right
	ld hl, wXCoord
	dec [hl]
	ret

.check_step_right
	cp RIGHT
	ret nz
	ld hl, wXCoord
	inc [hl]
	ret

UpdateOverworldMap:
	ld a, [wPlayerStepDirection]
	and a
	jr z, .step_down
	cp UP
	jr z, .step_up
	cp LEFT
	jr z, .step_left
	cp RIGHT
	jr z, .step_right
	ret

.step_down
	call .ScrollOverworldMapDown
	call LoadMapPart
	call ScrollMapDown
	ret

.step_up
	call .ScrollOverworldMapUp
	call LoadMapPart
	call ScrollMapUp
	ret

.step_left
	call .ScrollOverworldMapLeft
	call LoadMapPart
	call ScrollMapLeft
	ret

.step_right
	call .ScrollOverworldMapRight
	call LoadMapPart
	call ScrollMapRight
	ret

.ScrollOverworldMapDown:
	ld a, [wBGMapAnchor]
	add 2 * BG_MAP_WIDTH
	ld [wBGMapAnchor], a
	jr nc, .not_overflowed
	ld a, [wBGMapAnchor + 1]
	inc a
	and %11
	or HIGH(vBGMap0)
	ld [wBGMapAnchor + 1], a
.not_overflowed
	ld hl, wPlayerMetatileY
	inc [hl]
	ld a, [hl]
	cp 2 ; was 1
	jr nz, .done_down
	ld [hl], 0
	call .ScrollMapDataDown
.done_down
	ret

.ScrollMapDataDown:
	ld hl, wOverworldMapAnchor
	ld a, [wMapWidth]
	add 3 * 2 ; surrounding tiles
	add [hl]
	ld [hli], a
	ret nc
	inc [hl]
	ret

.ScrollOverworldMapUp:
	ld a, [wBGMapAnchor]
	sub 2 * BG_MAP_WIDTH
	ld [wBGMapAnchor], a
	jr nc, .not_underflowed
	ld a, [wBGMapAnchor + 1]
	dec a
	and %11
	or HIGH(vBGMap0)
	ld [wBGMapAnchor + 1], a
.not_underflowed
	ld hl, wPlayerMetatileY
	dec [hl]
	ld a, [hl]
	cp -1 ; was 0
	jr nz, .done_up
	ld [hl], $1
	call .ScrollMapDataUp
.done_up
	ret

.ScrollMapDataUp:
	ld hl, wOverworldMapAnchor
	ld a, [wMapWidth]
	add 3 * 2 ; surrounding tiles
	ld b, a
	ld a, [hl]
	sub b
	ld [hli], a
	ret nc
	dec [hl]
	ret

.ScrollOverworldMapLeft:
	ld a, [wBGMapAnchor]
	ld e, a
	and $e0
	ld d, a
	ld a, e
	sub $2
	and $1f
	or d
	ld [wBGMapAnchor], a
	ld hl, wPlayerMetatileX
	dec [hl]
	ld a, [hl]
	cp -1
	jr nz, .done_left
	ld [hl], 1
	call .ScrollMapDataLeft
.done_left
	ret

.ScrollMapDataLeft:
	ld hl, wOverworldMapAnchor
	ld a, [hl]
	sub 1
	ld [hli], a
	ret nc
	dec [hl]
	ret

.ScrollOverworldMapRight:
	ld a, [wBGMapAnchor]
	ld e, a
	and $e0
	ld d, a
	ld a, e
	add $2
	and $1f
	or d
	ld [wBGMapAnchor], a
	ld hl, wPlayerMetatileX
	inc [hl]
	ld a, [hl]
	cp 2
	jr nz, .done_right
	ld [hl], 0
	call .ScrollMapDataRight
.done_right
	ret

.ScrollMapDataRight:
	ld hl, wOverworldMapAnchor
	ld a, [hl]
	add 1
	ld [hli], a
	ret nc
	inc [hl]
	ret

UpdateOverworldMap_Flashlight:
	ld a, [wPlayerStepDirection]
	and a
	jr z, .step_down
	cp UP
	jr z, .step_up
	cp LEFT
	jr z, .step_left
	cp RIGHT
	jr z, .step_right
	ret

.step_down
	call UpdateOverworldMap.ScrollOverworldMapDown
	call .LoadMapPart
	ld a, 2
	jr .scroll

.step_up
	call UpdateOverworldMap.ScrollOverworldMapUp
	call .LoadMapPart
	ld a, 1
	jr .scroll

.step_left
	call UpdateOverworldMap.ScrollOverworldMapLeft
	call .LoadMapPart
	ld a, 3
	jr .scroll

.step_right
	call UpdateOverworldMap.ScrollOverworldMapRight
	call .LoadMapPart
	ld a, 4

.scroll
	call ScrollOverworldFlashlight
	ret

.LoadMapPart
	call LoadMapPart
	ldh a, [hCGB]
	and a
	ret z
	call SwapTextboxPalettes
	ret

ScrollOverworldFlashlight:
	push af
	call .GetFlashlightVariables
	call .GetFlashlightSize
	pop af
	add 2
	ldh [hFlashlightRedrawMode], a
	ret

.GetFlashlightVariables:
	dec a
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ldh a, [hOverworldFlashlightEffect]
	dec a
	swap a ; * 16
	sla a  ; *  2
	ld e, a
	ld d, 0
	add hl, de
	ld de, .FlashlightColumns
	add hl, de
	call .ReadFlashlightDst
	ld a, e
	ld [wRedrawFlashlightDst0], a
	ld a, d
	ld [wRedrawFlashlightDst0 + 1], a
	call .GetFlashlightSrc
	ld a, e
	ld [wRedrawFlashlightSrc0], a
	ld a, d
	ld [wRedrawFlashlightSrc0 + 1], a
	call .ReadFlashlightDst
	ld a, e
	ld [wRedrawFlashlightBlackDst0], a
	ld a, d
	ld [wRedrawFlashlightBlackDst0 + 1], a
	call .ReadFlashlightDst
	ld a, e
	ld [wRedrawFlashlightDst1], a
	ld a, d
	ld [wRedrawFlashlightDst1 + 1], a
	call .GetFlashlightSrc
	ld a, e
	ld [wRedrawFlashlightSrc1], a
	ld a, d
	ld [wRedrawFlashlightSrc1 + 1], a
	call .ReadFlashlightDst
	ld a, e
	ld [wRedrawFlashlightBlackDst1], a
	ld a, d
	ld [wRedrawFlashlightBlackDst1 + 1], a
	ret

.FlashlightColumns:
for x, 8, 0, -2 ; effect sizes 1, 2, 3, 4
	; up
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x + 1
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 + x - 1
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 + x - 2
	; down
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 + x - 4
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x - 2
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 + x - 3
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x - 1
	; left
	db SCREEN_WIDTH / 2 - x + 1
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 + x - 1
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 + x - 2
	db SCREEN_WIDTH / 2 - x
	; right
	db SCREEN_WIDTH / 2 + x - 4
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x - 2
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 + x - 3
	db SCREEN_WIDTH / 2 - x
	db SCREEN_WIDTH / 2 - x - 1
	db SCREEN_WIDTH / 2 - x
endr

.ReadFlashlightDst:
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	push hl
	push bc
	ld a, [wBGMapAnchor]
	ld e, a
	ld a, [wBGMapAnchor + 1]
	ld d, a
.row_loop
	ld a, BG_MAP_WIDTH
	add e
	ld e, a
	jr nc, .no_overflow
	inc d
.no_overflow
	ld a, d
	and %11
	or HIGH(vBGMap0)
	ld d, a
	dec b
	jr nz, .row_loop
.tile_loop
	ld a, e
	inc a
	maskbits BG_MAP_WIDTH
	ld b, a
	ld a, e
	and ~(BG_MAP_WIDTH - 1)
	or b
	ld e, a
	dec c
	jr nz, .tile_loop
	pop bc
	pop hl
	ret

.GetFlashlightSrc:
	push hl
	ld hl, wTilemap
	ld de, SCREEN_WIDTH
.loop
	ld a, b
	and a
	jr z, .last_row
	add hl, de
	dec b
	jr .loop
.last_row
	add hl, bc
	ld e, l
	ld d, h
	pop hl
	ret

.GetFlashlightSize:
	ldh a, [hOverworldFlashlightEffect]
	dec a
	ld l, a
	ld h, 0
	ld de, .Sizes
	add hl, de
	ld a, [hl]
	ld [wRedrawFlashlightWidthHeight], a
	ret

.Sizes:
	db 7, 5, 3, 1

RedrawFlashlight::
	ldh a, [hFlashlightRedrawMode]
	and a
	ret z
	sub 3
	ld c, a
	ld b, 0
	ld hl, .Jumptable
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

.Jumptable:
	dw RedrawFlashlightRow0
	dw RedrawFlashlightRow0
	dw RedrawFlashlightColumn0
	dw RedrawFlashlightColumn0
	dw RedrawFlashlightRow1
	dw RedrawFlashlightRow1
	dw RedrawFlashlightColumn1
	dw RedrawFlashlightColumn1
	dw RedrawFlashlightRow2
	dw RedrawFlashlightRow2
	dw RedrawFlashlightColumn2
	dw RedrawFlashlightColumn2
	dw RedrawFlashlightRow3
	dw RedrawFlashlightRow3
	dw RedrawFlashlightColumn3
	dw RedrawFlashlightColumn3

RedrawFlashlightColumn0:
	ldh a, [hSCX]
	and $07
	ret nz ; wait until one complete tile has scrolled
	ld hl, wRedrawFlashlightDst0
	call LoadFlashlightDestination
	push de
	ld hl, wRedrawFlashlightSrc0
	call LoadFlashlightSource
	call RedrawFlashlightColumnTiles
	pop de
	call RedrawFlashlightColumnAttrs0
	scf
	ret

RedrawFlashlightColumn1:
	ld hl, wRedrawFlashlightBlackDst0
	call LoadFlashlightDestination
	call RedrawFlashlightColumnBlack
	scf
	ret

RedrawFlashlightColumn2:
	ldh a, [hSCX]
	and $0f
	ret nz ; wait until two complete tiles have scrolled
	ld hl, wRedrawFlashlightDst1
	call LoadFlashlightDestination
	push de
	ld hl, wRedrawFlashlightSrc1
	call LoadFlashlightSource
	call RedrawFlashlightColumnTiles
	pop de
	call RedrawFlashlightColumnAttrs1
	scf
	ret

RedrawFlashlightColumn3:
	ld hl, wRedrawFlashlightBlackDst1
	call LoadFlashlightDestination
	call RedrawFlashlightColumnBlack
	xor a
	ldh [hFlashlightRedrawMode], a
	scf
	ret

RedrawFlashlightRow0:
	ldh a, [hSCY]
	and $07
	ret nz ; wait until one complete tile has scrolled
	ld hl, wRedrawFlashlightDst0
	call LoadFlashlightDestination
	push de
	ld hl, wRedrawFlashlightSrc0
	call LoadFlashlightSource
	call RedrawFlashlightRowTiles
	pop de
	call RedrawFlashlightRowAttrs0
	scf
	ret

RedrawFlashlightRow1:
	ld hl, wRedrawFlashlightBlackDst0
	call LoadFlashlightDestination
	call RedrawFlashlightRowBlack
	scf
	ret

RedrawFlashlightRow2:
	ldh a, [hSCY]
	and $0f
	ret nz ; wait until two complete tiles have scrolled
	ld hl, wRedrawFlashlightDst1
	call LoadFlashlightDestination
	push de
	ld hl, wRedrawFlashlightSrc1
	call LoadFlashlightSource
	call RedrawFlashlightRowTiles
	pop de
	call RedrawFlashlightRowAttrs1
	scf
	ret

RedrawFlashlightRow3:
	ld hl, wRedrawFlashlightBlackDst1
	call LoadFlashlightDestination
	call RedrawFlashlightRowBlack
	xor a
	ldh [hFlashlightRedrawMode], a
	scf
	ret

LoadFlashlightDestination:
	ld a, [hli]
	ld e, a
	ld d, [hl]
	ret

LoadFlashlightSource:
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

RedrawFlashlightColumnAttrs0:
	ld hl, wRedrawFlashlightSrc0
	jr RedrawFlashlightColumnAttrs

RedrawFlashlightColumnAttrs1:
	ld hl, wRedrawFlashlightSrc1

RedrawFlashlightColumnAttrs:
	ldh a, [hCGB]
	and a
	ret z
	call LoadFlashlightSource
	ld bc, wAttrmap - wTilemap
	add hl, bc
	ld a, 1
	ldh [rVBK], a
	ld a, [wRedrawFlashlightWidthHeight]
	add a
	ld c, a
.loop
	ld a, [hli]
	ld [de], a
	ld a, SCREEN_WIDTH - 1
	add l
	ld l, a
	jr nc, .no_source_carry
	inc h
.no_source_carry
	call StepFlashlightBGMapRow
	dec c
	jr nz, .loop
	xor a
	ldh [rVBK], a
	ret

RedrawFlashlightRowAttrs0:
	ld hl, wRedrawFlashlightSrc0
	jr RedrawFlashlightRowAttrs

RedrawFlashlightRowAttrs1:
	ld hl, wRedrawFlashlightSrc1

RedrawFlashlightRowAttrs:
	ldh a, [hCGB]
	and a
	ret z
	call LoadFlashlightSource
	ld bc, wAttrmap - wTilemap
	add hl, bc
	ld a, 1
	ldh [rVBK], a
	ld a, [wRedrawFlashlightWidthHeight]
	ld c, a
.loop
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	call StepFlashlightBGMapColumn
	dec c
	jr nz, .loop
	xor a
	ldh [rVBK], a
	ret

RedrawFlashlightColumnTiles:
	ld a, [wRedrawFlashlightWidthHeight]
	add a
	ld c, a
.loop
	ld a, [hli]
	ld [de], a
	ld a, SCREEN_WIDTH - 1
	add l
	ld l, a
	jr nc, .no_source_carry
	inc h
.no_source_carry
	call StepFlashlightBGMapRow
	dec c
	jr nz, .loop
	ldh a, [hFlashlightRedrawMode]
	add 4
	ldh [hFlashlightRedrawMode], a
	ret

RedrawFlashlightRowTiles:
	ld a, [wRedrawFlashlightWidthHeight]
	ld c, a
.loop
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	call StepFlashlightBGMapColumn
	dec c
	jr nz, .loop
	ldh a, [hFlashlightRedrawMode]
	add 4
	ldh [hFlashlightRedrawMode], a
	ret

RedrawFlashlightColumnBlack:
	ld l, e
	ld h, d
	ld b, '■'
	ld de, BG_MAP_WIDTH
	ld a, [wRedrawFlashlightWidthHeight]
	add a
	ld c, a
.loop
	ld [hl], b
	add hl, de
	ld a, h
	and HIGH(vBGMap1 - vBGMap0 - 1)
	or HIGH(vBGMap0)
	ld h, a
	dec c
	jr nz, .loop
	ldh a, [hFlashlightRedrawMode]
	add 4
	ldh [hFlashlightRedrawMode], a
	ret

RedrawFlashlightRowBlack:
	ld l, e
	ld h, d
	ld b, '■'
	ld a, [wRedrawFlashlightWidthHeight]
	ld c, a
.loop
	ld [hl], b
	inc hl
	ld [hl], b
	ld a, l
	inc a
	maskbits BG_MAP_WIDTH
	ld d, a
	ld a, l
	and ~(BG_MAP_WIDTH - 1)
	or d
	ld l, a
	dec c
	jr nz, .loop
	ldh a, [hFlashlightRedrawMode]
	add 4
	ldh [hFlashlightRedrawMode], a
	ret

StepFlashlightBGMapRow:
	ld a, BG_MAP_WIDTH
	add e
	ld e, a
	jr nc, .no_carry
	inc d
.no_carry
	ld a, d
	and HIGH(vBGMap1 - vBGMap0 - 1)
	or HIGH(vBGMap0)
	ld d, a
	ret

StepFlashlightBGMapColumn:
	ld a, e
	inc a
	maskbits BG_MAP_WIDTH
	ld b, a
	ld a, e
	and ~(BG_MAP_WIDTH - 1)
	or b
	ld e, a
	ret
