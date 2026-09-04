; VBlank half of the bottom-of-screen Toolgear clock.

TransferToolgearClock::
; Copy a newly rendered clock to window map 1 during VBlank. The render
; routine uses wBGMapBuffer only when no map update is pending, so it is safe
; to reuse that short-lived buffer here. Like the Space World version, this
; leaves the window's existing palette attributes intact.
	ld hl, wToolgearClockFlags
	bit TOOLGEAR_CLOCK_DIRTY_F, [hl]
	ret z
	res TOOLGEAR_CLOCK_DIRTY_F, [hl]

	ld hl, wBGMapBuffer
	ld de, vBGMap1
	ld c, SCREEN_WIDTH
.copy_top_row
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy_top_row

	ld de, vBGMap1 + BG_MAP_WIDTH
	ld c, SCREEN_WIDTH
.copy_bottom_row
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copy_bottom_row

	ld hl, wToolgearClockFlags
	bit TOOLGEAR_CLOCK_PENDING_SHOW_F, [hl]
	ret z
	res TOOLGEAR_CLOCK_PENDING_SHOW_F, [hl]
	set TOOLGEAR_CLOCK_VISIBLE_F, [hl]
	ld a, TOOLGEAR_CLOCK_WINDOW_Y
	ldh [hWY], a
	ldh [rWY], a
	ret

EnableToolgearClockSprites::
; The LCD interrupt disables sprites below the clock. Restore them during
; VBlank before the next frame starts.
	ld a, [wToolgearClockFlags]
	bit TOOLGEAR_CLOCK_VISIBLE_F, a
	ret z
	ldh a, [rLCDC]
	set rLCDC_SPRITES_ENABLE, a
	ldh [rLCDC], a
	ret
