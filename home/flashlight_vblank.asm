RunFlashlightVBlank:
	ldh a, [hFlashlightRedrawMode]
	and a
	ret z
	ld a, BANK(RedrawFlashlight)
	rst Bankswitch
	call RedrawFlashlight
	ld a, [wROMBankBackup]
	rst Bankswitch
	ret
