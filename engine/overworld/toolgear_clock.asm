; Bottom-of-screen Toolgear clock.
;
; The Space World Toolgear uses window-map row 0 as a horizontal border and
; row 1 for its status information. The window begins at pixel 128, so these
; two rows occupy the bottom sixteen pixels of the screen.

ToolgearClockTextboxOpened::
; Hide the clock before the text window is drawn. Rendering is invalidated
; because the text window uses the same window tilemap.
	ld hl, wToolgearClockFlags
	set TOOLGEAR_CLOCK_TEXTBOX_F, [hl]
	res TOOLGEAR_CLOCK_PENDING_SHOW_F, [hl]
	res TOOLGEAR_CLOCK_RENDERED_F, [hl]
	res TOOLGEAR_CLOCK_VISIBLE_F, [hl]
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	ldh [rWY], a
	ret

ToolgearClockTextboxClosed::
; The original Toolgear restores its window as soon as text closes. The
; transfer is deferred to VBlank so the tilemap is never written during LCD
; drawing.
	ld hl, wToolgearClockFlags
	res TOOLGEAR_CLOCK_TEXTBOX_F, [hl]
	res TOOLGEAR_CLOCK_RENDERED_F, [hl]
	jp UpdateToolgearClock

UpdateToolgearClock::
; Refresh the clock when it is not covered by text and either its window has
; been hidden or the RTC second has changed. hSeconds makes the colon blink
; once per second, matching the Space World implementation.
	ld hl, wToolgearClockFlags
	bit TOOLGEAR_CLOCK_TEXTBOX_F, [hl]
	ret nz
	ldh a, [hBGMapUpdate]
	and a
	ret nz
	bit TOOLGEAR_CLOCK_RENDERED_F, [hl]
	jr z, .load_graphics
	ldh a, [hWY]
	cp TOOLGEAR_CLOCK_WINDOW_Y
	jr nz, .load_graphics
	ldh a, [hSeconds]
	ld b, a
	ld a, [wToolgearClockLastSecond]
	cp b
	ret z
	ldh a, [hSeconds]
	and a
	jr nz, .render
	ldh a, [hMinutes]
	and a
	jr nz, .render
	ldh a, [hHours]
	and a
	jr nz, .render
	call LoadToolgearClockWeekdayGFX
	jr .render

.load_graphics
	call LoadToolgearClockGFX

.render
	call RenderToolgearClock
	ld hl, wToolgearClockFlags
	set TOOLGEAR_CLOCK_DIRTY_F, [hl]
	set TOOLGEAR_CLOCK_PENDING_SHOW_F, [hl]
	set TOOLGEAR_CLOCK_RENDERED_F, [hl]
	ret

RenderToolgearClock::
; Build the two window-map rows in the unused map-update buffer. The top
; border and unboxed bottom row intentionally match the original layout.
	ld hl, wBGMapBuffer
	ld a, CHARVAL("─")
	ld bc, SCREEN_WIDTH
	call ByteFill

	ld a, $7f
	ld bc, SCREEN_WIDTH
	call ByteFill

	ld de, wBGMapBuffer + SCREEN_WIDTH
	ldh a, [hHours]
	call .PrintTwoDigits
	ld a, $7f
	ld [de], a
	ldh a, [hSeconds]
	and 1
	jr z, .no_colon
	ld a, $6c
	ld [de], a
.no_colon
	inc de
	ldh a, [hMinutes]
	call .PrintTwoDigits
	ld a, $7f
	ld [de], a ; one-tile gap between the time and weekday
	inc de
	push de
	call GetToolgearClockWeekdayGFX
	ld b, [hl] ; number of letters loaded into $63-$6b
	pop de
	ld a, $63
.weekday
	ld [de], a
	inc de
	inc a
	dec b
	jr nz, .weekday
	ldh a, [hSeconds]
	ld [wToolgearClockLastSecond], a
	ret

.PrintTwoDigits:
; Print the value in a as two decimal digits at de.
	ld b, 0
.tens
	inc b
	sub 10
	jr nc, .tens
	dec b
	add 10
	push af
	ld a, b
	call .DigitTile
	ld [de], a
	inc de
	pop af
	call .DigitTile
	ld [de], a
	inc de
	ret

.DigitTile:
; Map a decimal digit to its Toolgear vTiles2 slot. Tiles $70 and $71 are
; intentionally skipped because they hold the Poké glyphs.
	cp 3
	jr nc, .upper_digits
	add $6d
	ret
.upper_digits
	add $6f ; 3 -> $72, ..., 9 -> $78
	ret

LoadToolgearClockGFX::
; Load the digit tiles into their Toolgear slots, then load the letters for
; the active weekday into $63-$6b.
	ld de, Font + (CHARVAL("0") - $80) * LEN_1BPP_TILE
	ld hl, vTiles2 tile $6d
	lb bc, BANK(Font), 3
	call Request1bpp
	ld de, Font + (CHARVAL("3") - $80) * LEN_1BPP_TILE
	ld hl, vTiles2 tile $72
	lb bc, BANK(Font), 7
	call Request1bpp
	jp LoadToolgearClockWeekdayGFX

LoadToolgearClockWeekdayGFX::
; Each letter has a direct 1bpp Font source pointer. Load the letters in
; order into $63-$6b, preserving the loop state across each VBlank request.
	call GetToolgearClockWeekdayGFX
	ld a, [hli]
	ld bc, vTiles2 tile $63
.letter
	push af
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
	push bc
	ld h, b
	ld l, c
	lb bc, BANK(Font), 1
	call Request1bpp
	pop hl
	ld bc, LEN_2BPP_TILE ; destination tiles expand to 16 bytes in VRAM
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	pop af
	dec a
	jr nz, .letter
	ret

GetToolgearClockWeekdayGFX::
; wCurDay is an elapsed-day counter. Pokegear code uses GetWeekday to reduce
; it modulo seven before indexing weekday-specific data. Return hl pointing
; to the letter count followed by one 1bpp Font source address per letter.
	call GetWeekday
	add a
	ld c, a
	ld b, 0
	ld hl, .Weekdays
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

.Weekdays:
	dw .Sunday, .Monday, .Tuesday, .Wednesday, .Thursday, .Friday, .Saturday

MACRO toolgear_weekday_gfx
	assert _NARG > 0 && _NARG <= $6c - $63, "Weekday must fit in tiles $63-$6b"
	db _NARG
	rept _NARG
		dw Font + (CHARVAL(\1) - $80) * LEN_1BPP_TILE
		shift
	endr
ENDM

.Sunday:
	toolgear_weekday_gfx "S", "U", "N", "D", "A", "Y"
.Monday:
	toolgear_weekday_gfx "M", "O", "N", "D", "A", "Y"
.Tuesday:
	toolgear_weekday_gfx "T", "U", "E", "S", "D", "A", "Y"
.Wednesday:
	toolgear_weekday_gfx "W", "E", "D", "N", "E", "S", "D", "A", "Y"
.Thursday:
	toolgear_weekday_gfx "T", "H", "U", "R", "S", "D", "A", "Y"
.Friday:
	toolgear_weekday_gfx "F", "R", "I", "D", "A", "Y"
.Saturday:
	toolgear_weekday_gfx "S", "A", "T", "U", "R", "D", "A", "Y"

PURGE toolgear_weekday_gfx
