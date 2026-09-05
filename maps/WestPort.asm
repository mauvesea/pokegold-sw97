	object_const_def
	const WESTPORT_SAILOR

WestPort_MapScripts:
	def_scene_scripts

	def_callbacks

WestPortSailorScript:
	faceplayer
	opentext
	writetext WestPortText1
	waitbutton
	closetext
	readvar VAR_FACING
	ifequal DOWN, .FacingDownMovement
	applymovement PLAYER, WestPortMov1
	sjump .AfterPlayerMovement
.FacingDownMovement
	applymovement PLAYER, WestPortMov3
.AfterPlayerMovement
	disappear PLAYER
	playsound SFX_EXIT_BUILDING
	pause 10
	applymovement WESTPORT_SAILOR, WestPortMov2
	disappear WESTPORT_SAILOR
	playsound SFX_EXIT_BUILDING
	pause 10
	refreshscreen
	playsound SFX_BOAT
	pause 30
	callasm WestportScroll
	special FadeOutPalettes
	pause 15
	warp WEST_PORT, 14, 5
	end

WestPortSignScript:
	jumptext WestPortText2

WestPortMov2:
	step RIGHT
WestPortMov1:
	step DOWN
	step_end

WestPortMov3:
	step RIGHT
	step DOWN
	step DOWN
	step_end

WestPortText1:
	text "We're departing"
	line "soon. Please get"
	cont "on board."
	done

WestPortText2:
	text "FLINT CITY PORT"
	line "FLINT CITY - "
	cont "PRIMROSE ISLAND"
	done

WestportScroll:
	ld a, 1
	ldh [hBGMapMode], a

	push hl
	push bc
	push af
	ld a, $46 ; water tile
	hlcoord 16, 10 ; X, Y
	ld bc, 4 ; Y, X
	call ByteFill
	hlcoord 16, 11 ; X, Y
	ld bc, 4 ; Y, X
	call ByteFill
	hlcoord 16, 12 ; X, Y
	ld bc, 4 ; Y, X
	call ByteFill
	hlcoord 16, 13 ; X, Y
	ld bc, 4 ; Y, X
	call ByteFill
	hlcoord 16, 14 ; X, Y
	ld bc, 4 ; Y, X
	call ByteFill
	hlcoord 16, 15 ; X, Y
	ld bc, 4 ; Y, X
	call ByteFill
	hlcoord 16, 16 ; X, Y
	ld bc, 4 ; Y, X
	call ByteFill
	pop hl
	pop bc
	pop af

	ld de, WaterScrollTile
	ld hl, vTiles2 tile $60
	lb bc, BANK(WaterScrollTile), 1
	call Get2bpp

.loop1
	push bc
	ld h, b
	ld l, 80
	call .subfunction
	ld h, 0
	ld l, 128
	call .subfunction
	ld h, b
	ld l, 80
	call .subfunction
	ld h, 0
	ld l, 128
	call .subfunction
	pop bc
	inc b
	dec c
	ld a, b
	cp 64
	jr nz, .loop1

	push hl
	push bc
	push af
	ld a, $46 ; water tile
	hlcoord 0, 10 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 0, 11 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 0, 12 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 0, 13 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 0, 14 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 0, 15 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 0, 16 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	pop hl
	pop bc
	pop af

.loop4
	push bc
	ld h, b
	ld l, 80
	call .subfunction
	ld h, 0
	ld l, 128
	call .subfunction
	ld h, b
	ld l, 80
	call .subfunction
	ld h, 0
	ld l, 128
	call .subfunction
	pop bc
	inc b
	dec c
	ld a, b
	cp 140
	jr nz, .loop4

	push hl
	push bc
	push af
	ld a, $14 ; water tile
	hlcoord 8, 10 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 8, 11 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 8, 12 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 8, 13 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 8, 14 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 8, 15 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	hlcoord 8, 16 ; X, Y
	ld bc, 8 ; Y, X
	call ByteFill
	pop hl
	pop bc
	pop af

.loop5
	push bc
	ld h, b
	ld l, 80
	call .subfunction
	ld h, 0
	ld l, 128
	call .subfunction
	ld h, b
	ld l, 80
	call .subfunction
	ld h, 0
	ld l, 128
	call .subfunction
	pop bc
	inc b
	dec c
	ld a, b
	cp 148
	jr nz, .loop5

	ret

.subfunction
.loop2
	ldh a, [rLY]
	cp l
	jr nz, .loop2
	ld a, h
	ldh [rSCX], a

.loop3
	ldh a, [rLY]
	cp h
	jr z, .loop3
	ret

WaterScrollTile:
INCBIN "gfx/font/water_scroll.2bpp"


WestPort_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 29, 4, WEST_PORT, 1
	warp_event 29, 5, WEST_PORT, 1

	def_coord_events

	def_bg_events
	bg_event 17,  5, BGEVENT_READ, WestPortSignScript

	def_object_events
	object_event 13,  5, SPRITE_SAILOR, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, WestPortSailorScript, -1
