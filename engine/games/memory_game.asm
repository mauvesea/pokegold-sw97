_MemoryGame:

	call .LoadGFXAndPals
	call DelayFrame
.loop
	call .JumptableLoop
	jr nc, .loop
	ret

.LoadGFXAndPals:
	ld hl, wOptions
	set NO_TEXT_SCROLL, [hl]
	call ClearBGPalettes
	call ClearTilemap
	call ClearSprites
	ld de, MUSIC_NONE
	call PlayMusic
	call DelayFrame
	call DisableLCD
	call LoadStandardFont
	call LoadFontsExtra
	ld b, SCGB_DIPLOMA
	call GetSGBLayout
	callfar ClearSpriteAnims
	ld hl, MemoryGameLZ
	ld de, vTiles2 tile $00
	call Decompress
	ld hl, MemoryGameGFX
	ld de, vTiles0 tile $00
	ld bc, 4 tiles
	ld a, BANK(MemoryGameGFX)
	call FarCopyBytes

	ld a, SPRITE_ANIM_DICT_ARROW_CURSOR
	ld hl, wSpriteAnimDict
	ld [hli], a
	ld [hl], 0

	hlcoord 0, 0
	ld bc, SCREEN_HEIGHT * SCREEN_WIDTH
	xor a
	call ByteFill

	xor a
	ldh [hSCY], a
	ldh [hSCX], a
	ldh [rWY], a
	ld [wJumptableIndex], a
	ld a, 1
	ldh [hBGMapMode], a
	ld a, %11100011
	ldh [rLCDC], a
	ld a, %11100100
	ldh [rBGP], a
	ld a, %11100000
	ldh [rOBP0], a
	ld de, MUSIC_GAME_CORNER
	call PlayMusic
	ret

.JumptableLoop:
	ld a, [wJumptableIndex]
	bit 7, a
	jr nz, .quit
	call .ExecuteJumptable
	callfar PlaySpriteAnimations
	call DelayFrame
	and a
	ret

.quit
	ld de, SFX_QUIT_SLOTS
	call WaitSFX
	call PlaySFX
	call WaitSFX
	scf
	ret

.ExecuteJumptable:
	jumptable .Jumptable, wJumptableIndex

.Jumptable:
	dw .RestartGame
	dw .ResetBoard
	dw .InitBoardTilemapAndCursorObject
	dw .CheckTriesRemaining
	dw .PickCard1
	dw .PickCard2
	dw .DelayPickAgain
	dw .RevealAll
	dw .AskPlayAgain

.RestartGame:
	call MemoryGame_InitStrings
	ld hl, wJumptableIndex
	inc [hl]
	ret

.ResetBoard:
	call MemoryGameBetAmount
	jr nc, .proceed
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

.proceed
	call MemoryGame_InitBoard
	ld hl, wJumptableIndex
	inc [hl]
	xor a
	ld [wMemoryGameCounter], a
	ld hl, wMemoryGameLastMatches
rept 4
	ld [hli], a
endr
	ld [hl], a
	ld [wMemoryGameNumCardsMatched], a

.InitBoardTilemapAndCursorObject:
	ld hl, wMemoryGameCounter
	ld a, [hl]
	cp 45
	jr nc, .spawn_object
	inc [hl]
	call MemoryGame_Card2Coord
	xor a
	ld [wMemoryGameLastCardPicked], a
	call MemoryGame_PlaceCard
	ret

.spawn_object
	depixel 6, 3, 4, 4
	ld a, SPRITE_ANIM_OBJ_MEMORY_GAME_CURSOR
	call InitSpriteAnimStruct
	ld hl, wJumptableIndex
	inc [hl]
	ret

.CheckTriesRemaining:
	ld a, [wMemoryGameNumberTriesRemaining]
	cp 10
	jr nc, .two_digits

	; 1–9
	hlcoord 18, 1
	add "0"
	ld [hl], a

	hlcoord 17, 1
	xor a
	ld [hl], a
	jr .check_remaining

.two_digits
	; 10–20
	ld a, [wMemoryGameNumberTriesRemaining]
	cp 20
	jr z, .twenty

	; 10–19
	hlcoord 17, 1
	ld a, "1"
	ld [hli], a

	ld a, [wMemoryGameNumberTriesRemaining]
	sub 10
	add "0"
	ld [hl], a
	jr .check_remaining

.twenty
	hlcoord 17, 1
	ld a, "2"
	ld [hli], a
	ld a, "0"
	ld [hl], a

.check_remaining
	ld hl, wMemoryGameNumberTriesRemaining
	ld a, [hl]
	and a
	jr nz, .next_try
	ld a, $7
	ld [wJumptableIndex], a
	ret


.next_try
	dec [hl]
	xor a
	ld [wMemoryGameCardChoice], a
	ld hl, wJumptableIndex
	inc [hl]

.PickCard1:
	ld a, [wMemoryGameCardChoice]
	and a
	ret z
	dec a
	ld e, a
	ld d, 0
	ld hl, wMemoryGameCards
	add hl, de
	ld a, [hl]
	cp -1
	ret z
	ld [wMemoryGameLastCardPicked], a
	ld [wMemoryGameCard1], a
	ld a, e
	ld [wMemoryGameCard1Location], a
	call MemoryGame_Card2Coord
	call MemoryGame_PlaceCard
	xor a
	ld [wMemoryGameCardChoice], a
	ld hl, wJumptableIndex
	inc [hl]
	ret

.PickCard2:
	ld a, [wMemoryGameCardChoice]
	and a
	ret z
	dec a
	ld hl, wMemoryGameCard1Location
	cp [hl]
	ret z
	ld e, a
	ld d, 0
	ld hl, wMemoryGameCards
	add hl, de
	ld a, [hl]
	cp -1
	ret z
	ld [wMemoryGameLastCardPicked], a
	ld [wMemoryGameCard2], a
	ld a, e
	ld [wMemoryGameCard2Location], a
	call MemoryGame_Card2Coord
	call MemoryGame_PlaceCard
	ld a, 64
	ld [wMemoryGameCounter], a
	ld hl, wJumptableIndex
	inc [hl]

.DelayPickAgain:
	ld hl, wMemoryGameCounter
	ld a, [hl]
	and a
	jr z, .PickAgain
	dec [hl]
	ret

.PickAgain:
	call MemoryGame_CheckMatch

	ld a, [wMemoryGameNumCardsMatched]
    cp 10
    jr nc, .game_won

	ld a, $3
	ld [wJumptableIndex], a
	ret

.game_won
	call MemoryGamePayout
	ld a, $7
    ld [wJumptableIndex], a
    ret

.RevealAll:
	ldh a, [hJoypadPressed]
	and A_BUTTON
	ret z
	xor a
	ld [wMemoryGameCounter], a

.RevelationLoop:
	ld hl, wMemoryGameCounter
	ld a, [hl]
	cp 45
	jr nc, .finish_round
	inc [hl]
	push af
	call MemoryGame_Card2Coord
	pop af
	push hl
	ld e, a
	ld d, 0
	ld hl, wMemoryGameCards
	add hl, de
	ld a, [hl]
	pop hl
	cp -1
	jr z, .RevelationLoop
	ld [wMemoryGameLastCardPicked], a
	call MemoryGame_PlaceCard
	jr .RevelationLoop

.finish_round
	call WaitPressAorB_BlinkCursor
	ld hl, wJumptableIndex
	inc [hl]

.AskPlayAgain:
	call MemoryGameYesOrNo
	jr nc, .restart
	ld hl, wJumptableIndex
	set 7, [hl]
	ret

.restart
	xor a
	ld [wJumptableIndex], a
	ret

MemoryGame_CheckMatch:
	ld hl, wMemoryGameCard1
	ld a, [hli]
	cp [hl]
	jr nz, .no_match

	ld a, [wMemoryGameCard1Location]
	call MemoryGame_Card2Coord
	call MemoryGame_DeleteCard

	ld a, [wMemoryGameCard2Location]
	call MemoryGame_Card2Coord
	call MemoryGame_DeleteCard

	ld a, [wMemoryGameCard1Location]
	ld e, a
	ld d, 0
	ld hl, wMemoryGameCards
	add hl, de
	ld [hl], -1

	ld a, [wMemoryGameCard2Location]
	ld e, a
	ld d, 0
	ld hl, wMemoryGameCards
	add hl, de
	ld [hl], -1

	ld hl, wMemoryGameLastMatches
.find_empty_slot
	ld a, [hli]
	and a
	jr nz, .find_empty_slot
	dec hl
	ld a, [wMemoryGameCard1]
	ld [hl], a
	ld [wMemoryGameLastCardPicked], a
	ld hl, wMemoryGameNumCardsMatched
	ld e, [hl]
	inc [hl]
	inc [hl]
	ld d, 0
	hlcoord 5, 0
	add hl, de
	call MemoryGame_PlaceCard
	ld hl, .VictoryText
	call PrintText
	push de
	ld de, SFX_LEVEL_UP
	call PlaySFX
	call WaitSFX
	pop de
	ret

.no_match
	xor a
	ld [wMemoryGameLastCardPicked], a

	ld a, [wMemoryGameCard1Location]
	call MemoryGame_Card2Coord
	call MemoryGame_PlaceCard

	ld a, [wMemoryGameCard2Location]
	call MemoryGame_Card2Coord
	call MemoryGame_PlaceCard

	ld hl, MemoryGameDarnText
	call PrintText
	push de
	ld de, SFX_WRONG
	call PlaySFX
	call WaitSFX
	pop de
	ret

.VictoryText:
	text_asm
	push bc
	hlcoord 2, 13
	call MemoryGame_PlaceCard
	ld hl, MemoryGameYeahText
	pop bc
	inc bc
	inc bc
	inc bc
	ret

MemoryGameYeahText:
	text_far _MemoryGameYeahText
	text_end

MemoryGameDarnText:
	text_far _MemoryGameDarnText
	text_end

MemoryGameYouWon:
	text_far _MemoryGameYouWon
	text_end

MemoryGame_InitBoard:
	ld hl, wMemoryGameCards
	ld bc, wMemoryGameCardsEnd - wMemoryGameCards
	xor a
	call ByteFill
	call MemoryGame_GetDistributionOfTiles

	ld c, 2
	ld b, [hl]
	call MemoryGame_SampleTilePlacement

	ld c, 8
	ld b, [hl]
	call MemoryGame_SampleTilePlacement

	ld c, 4
	ld b, [hl]
	call MemoryGame_SampleTilePlacement

	ld c, 7
	ld b, [hl]
	call MemoryGame_SampleTilePlacement

	ld c, 3
	ld b, [hl]
	call MemoryGame_SampleTilePlacement

	ld c, 6
	ld b, [hl]
	call MemoryGame_SampleTilePlacement

	ld c, 1
	ld b, [hl]
	call MemoryGame_SampleTilePlacement

	ld c, 5
	ld hl, wMemoryGameCards
	ld b, wMemoryGameCardsEnd - wMemoryGameCards
.loop
	ld a, [hl]
	and a
	jr nz, .no_load
	ld [hl], c
.no_load
	inc hl
	dec b
	jr nz, .loop
	ret

MemoryGame_SampleTilePlacement:
	push hl
	ld de, wMemoryGameCards
.loop
	call Random
	and %00111111
	cp 45
	jr nc, .loop
	ld l, a
	ld h, 0
	add hl, de
	ld a, [hl]
	and a
	jr nz, .loop
	ld [hl], c
	dec b
	jr nz, .loop
	pop hl
	inc hl
	ret

MemoryGame_GetDistributionOfTiles:
	ld hl, MemoryGameDummyText
	call PrintText
	ld a, [wMenuCursorY]
	dec a
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, .distributions
	add hl, de
	ret

.distributions
	db $02, $03, $06, $06, $06, $08, $08, $06
	db $02, $02, $04, $06, $06, $08, $08, $09
	db $02, $02, $02, $04, $07, $08, $08, $0c

MemoryGame_PlaceCard:
	ld a, [wMemoryGameLastCardPicked]
	sla a
	sla a
	add 4
	ld [hli], a
	inc a
	ld [hld], a
	inc a
	ld bc, SCREEN_WIDTH
	add hl, bc
	ld [hli], a
	inc a
	ld [hl], a
	ld c, 3
	call DelayFrames
	ret

MemoryGame_DeleteCard:
	ld a, $1
	ld [hli], a
	ld [hld], a
	ld bc, SCREEN_WIDTH
	add hl, bc
	ld [hli], a
	ld [hl], a
	ld c, 3
	call DelayFrames
	ret

MemoryGame_InitStrings:
	hlcoord 0, 0
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	ld a, $1
	call ByteFill
	hlcoord 0, 0
	ld de, MemoryGameTopLeftString
	call PlaceString
	hlcoord 15, 0
	ld de, MemoryGameTopRightString
	call PlaceString
	ld hl, MemoryGameDummyText
	call PrintText
	ret

MemoryGameDummyText:
	db "@"
MemoryGameTopLeftString:
	db "PAIRS@";"とったもの@"
MemoryGameTopRightString:
	db "TRIES@";"あと　かい@"

MemoryGame_Card2Coord:
	ld d, 0
.find_row
	sub 9
	jr c, .found_row
	inc d
	jr .find_row

.found_row
	add 9
	ld e, a
	hlcoord 1, 2
	ld bc, 2 * SCREEN_WIDTH
.loop2
	ld a, d
	and a
	jr z, .done
	add hl, bc
	dec d
	jr .loop2

.done
	sla e
	add hl, de
	ret

MemoryGame_InterpretJoypad_AnimateCursor:
	ld a, [wJumptableIndex]
	cp $7
	jr nc, .quit
	call JoyTextDelay
	ld hl, hJoypadPressed
	ld a, [hl]
	and A_BUTTON
	jr nz, .pressed_a
	ld a, [hl]
	and D_LEFT
	jr nz, .pressed_left
	ld a, [hl]
	and D_RIGHT
	jr nz, .pressed_right
	ld a, [hl]
	and D_UP
	jr nz, .pressed_up
	ld a, [hl]
	and D_DOWN
	jr nz, .pressed_down
	ret

.quit
	ld hl, SPRITEANIMSTRUCT_INDEX
	add hl, bc
	ld [hl], $0
	ret

.pressed_a
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, [hl]
	inc a
	ld [wMemoryGameCardChoice], a
	ret

.pressed_left
	ld hl, SPRITEANIMSTRUCT_XOFFSET
	add hl, bc
	ld a, [hl]
	and a
	ret z
	sub 1 tiles
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	dec [hl]
	ret

.pressed_right
	ld hl, SPRITEANIMSTRUCT_XOFFSET
	add hl, bc
	ld a, [hl]
	cp (9 - 1) tiles
	ret z
	add 1 tiles
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	inc [hl]
	ret

.pressed_up
	ld hl, SPRITEANIMSTRUCT_YOFFSET
	add hl, bc
	ld a, [hl]
	and a
	ret z
	sub 1 tiles
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, [hl]
	sub 9
	ld [hl], a
	ret

.pressed_down
	ld hl, SPRITEANIMSTRUCT_YOFFSET
	add hl, bc
	ld a, [hl]
	cp (5 - 1) tiles
	ret z
	add 1 tiles
	ld [hl], a
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, [hl]
	add 9
	ld [hl], a
	ret

MemoryGameYesOrNo:
	ld hl, wCoins
	ld a, [hli]
	or [hl]
	jr nz, .menu

	ld hl, MemoryGameNoCoinsText
	call PrintText
	ld c, 60
	call DelayFrames
	jr .yes

.menu:
	ld hl, MemoryGameReplayText
	call PrintText

	call YesNoBox
	jr c, .yes
	and a
	ret

.yes:
	scf
	ret

MemoryGameAskBetText:
	text "1 COIN per try."
	line "Play？"
	done

MemoryGameNotEnoughCoinsText:
	text "Not enough"
	line "coins."
	prompt

MemoryGameBetWindow:
	db	%01000000
	db	5, 14, 11, 19
	dw	.text
	db	1
.text:
	db STATICMENU_CURSOR | STATICMENU_NO_TOP_SPACING | STATICMENU_WRAP ; flags
	db	3
	db	"×20@"
	db	"×10@"
	db	"×5@"

MemoryGameBetAmount:
	ld hl, MemoryGameAskBetText
	call PrintText

	call MemoryGamePrintCoinBalance

	ld hl, MemoryGameBetWindow
	call LoadMenuHeader
	call VerticalMenu
	call CloseWindow
	ret c

	ld a, [w2DMenuDataEnd]

	ld hl, .table
	dec a
	ld e, a
	ld d, $00
	add hl, de
	ld c, [hl]

	ld hl, wCoins
	ld a, [hli]
	and a
	jr nz, .CheckBet
	ld a, [hl]
	cp c
	jr nc, .CheckBet
	ld hl, MemoryGameNotEnoughCoinsText
	call PrintText
	jr MemoryGameBetAmount

.CheckBet:
	ld hl, wCoins + 1
	ld a, [hl]
	sub c
	ld [hld], a
	jr nc, .SetBet
	dec [hl]
.SetBet:
	push bc
	hlcoord 15, 16
	ld de, wCoins
	lb bc, PRINTNUM_LEADINGZEROS | 2, 4
	call PrintNum
	ld de, SFX_PAY_DAY
	call WaitSFX
	call PlaySFX
	call WaitSFX
	pop bc
	ld a, c
	ld [wMemoryGameNumberTriesRemaining], a
	and a
	ret

.table:
	db 20, 10, 5

MemoryGameNoCoinsText:
	text_far _SlotsRanOutOfCoinsText
	text_end

MemoryGameReplayText:
	text_far _SlotsPlayAgainText
	text_end

MemoryGameCoinString:
	db "COIN@"

MemoryGameLZ:
INCBIN "gfx/memory_game/memory_game.2bpp.lz"

MemoryGameGFX:
INCBIN "gfx/battle_anims/pointer.2bpp"


MemoryGamePayout:
	ld c, 30
	ld de, SFX_2ND_PLACE
	push bc
	push de
	ld hl, MemoryGameYouWon
	call MemoryGameUpdateCoinBalanceDisplay
	pop de
	call PlaySFX
	call WaitSFX
	pop bc
.loop
	push bc
	call .IsCoinCaseFull
	jr c, .full
	call .AddCoinPlaySFX

.full
	call MemoryGamePrintCoinBalance
	ld c, 2
	call DelayFrames
	pop bc
	dec c
	jr nz, .loop
	ret

.AddCoinPlaySFX:
	ld a, [wCoins]
	ld h, a
	ld a, [wCoins + 1]
	ld l, a
	inc hl
	ld a, h
	ld [wCoins], a
	ld a, l
	ld [wCoins + 1], a
	ld de, SFX_PAY_DAY
	call PlaySFX
	ret

.IsCoinCaseFull:
	ld a, [wCoins]
	cp HIGH(MAX_COINS)
	jr c, .less
	jr z, .check_low
	jr .more

.check_low
	ld a, [wCoins + 1]
	cp LOW(MAX_COINS)
	jr c, .less

.more
	scf
	ret

.less
	and a
	ret


MemoryGameUpdateCoinBalanceDisplay:
	push hl
	hlcoord 0, 12
	ld b, 4
	ld c, SCREEN_WIDTH - 2
	call Textbox
	pop hl
	call PrintTextboxText
	call MemoryGamePrintCoinBalance
	ret

MemoryGamePrintCoinBalance:
	hlcoord 9, 15
	lb bc, 1, 9
	call Textbox
	hlcoord 10, 16
	ld de, MemoryGameCoinString
	call PlaceString
	hlcoord 15, 16
	ld de, wCoins
	lb bc, PRINTNUM_LEADINGZEROS | 2, 4
	call PrintNum
	ret
