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
	jr z, .render
	ldh a, [hWY]
	cp TOOLGEAR_CLOCK_WINDOW_Y
	jr nz, .render
	ldh a, [hSeconds]
	ld b, a
	ld a, [wToolgearClockLastSecond]
	cp b
	ret z

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
	ld a, $6d
	ld [de], a
.no_colon
	inc de
	ldh a, [hMinutes]
	call .PrintTwoDigits
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
	add CHARVAL("0")
	ld [de], a
	inc de
	pop af
	add CHARVAL("0")
	ld [de], a
	inc de
	ret
