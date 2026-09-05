; The first healthy, awake, unfrozen, non-Egg party Pokemon follows the player.

SECTION "Pokemon Follower", ROMX

PreparePokemonFollowerForMap::
; Cache the old palette identity before the map header is replaced. The follower
; object itself is rebuilt after every map load. Hardware OAM remains locked on
; the last complete player/follower frame while shadow OAM is rebuilt.
	ldh a, [hMapEntryMethod]
	cp MAPSETUP_CONNECTION
	jp nz, DismissPokemonFollower

	ld a, [wMapGroup]
	ld [wPokemonFollowerPartyIndex], a
	ld a, [wTimeOfDayPal]
	ld [wPokemonFollowerSpecies], a
	ld a, [wPokemonFollowerFlags]
	and (1 << POKEMON_FOLLOWER_WARP_PENDING_F) | (1 << POKEMON_FOLLOWER_SCRIPTED_F)
	ld b, a
	ld a, [wEnvironment]
	and %111
rept POKEMON_FOLLOWER_PREV_ENV_SHIFT
	add a
endr
	or b
	ld [wPokemonFollowerFlags], a

; A queued step uses the old map's coordinates. Reusing it after the coordinate
; remap can make the follower walk through the player and appear to blink out.
; Detach now and respawn behind the player once the new map is ready.
	ld a, TRUE
	ldh [hOAMUpdate], a
	jp DismissPokemonFollower

LoadConnectionMapPalettes::
; PreparePokemonFollowerForMap cached the outgoing palette identity. Connected
; maps with the same environment, time palette, and group already have exactly
; the palettes they need, including their roof and object palettes.
	ld a, [wPokemonFollowerFlags]
	and POKEMON_FOLLOWER_PREV_ENV_MASK
rept POKEMON_FOLLOWER_PREV_ENV_SHIFT
	rrca
endr
	ld b, a
	ld a, [wEnvironment]
	and %111
	cp b
	jr nz, .load
	ld a, [wPokemonFollowerSpecies]
	ld b, a
	ld a, [wTimeOfDayPal]
	cp b
	jr nz, .load
	ld a, [wPokemonFollowerPartyIndex]
	ld b, a
	ld a, [wMapGroup]
	cp b
	ret z

.load
	ldh a, [hCGB]
	and a
	jr nz, .cgb
	ldh a, [hSGB]
	and a
	ret z
	farcall SGB_LoadMapPalsPacketOnly
	ret

.cgb
	ld b, $9
	call GetSGBLayout
	farcall _UpdateTimePals
	ret

InitPokemonFollowerForMap::
	call CheckPokemonFollowerEngineFlag
	ld hl, wPokemonFollowerFlags
	res POKEMON_FOLLOWER_SCRIPTED_F, [hl]
	res POKEMON_FOLLOWER_CONNECTION_FRAME_F, [hl]
	ldh a, [hMapEntryMethod]
	cp MAPSETUP_CONNECTION
	jr z, .connection
	cp MAPSETUP_RELOADMAP
	jr z, .restore_now

; Warps and other non-seamless transitions restore the follower after one step.
	set POKEMON_FOLLOWER_WARP_PENDING_F, [hl]
	jp DismissPokemonFollower

.connection
; Map setup has already consumed several display frames. Let the first normal
; overworld pass rebuild and publish the objects immediately. Hardware OAM stays
; on its last complete frame until that pass has finished.
	set POKEMON_FOLLOWER_CONNECTION_FRAME_F, [hl]
.restore_now
	res POKEMON_FOLLOWER_WARP_PENDING_F, [hl]
	jp UpdatePokemonFollower

UpdatePokemonFollower::
	call FindPokemonFollower
	jr c, .has_follower

	ld a, -1
	ld [wPokemonFollowerPartyIndex], a
	xor a
	ld [wPokemonFollowerSpecies], a
	jp DismissPokemonFollower

.has_follower
	ld [wPokemonFollowerSpecies], a
	ld a, c
	ld [wPokemonFollowerPartyIndex], a

; Link rooms and every non-walking player state suppress the pet.
	call IsPokemonFollowerLinkRoom
	jp c, DismissPokemonFollower
	ld a, [wLinkMode]
	and a
	jp nz, DismissPokemonFollower
	ld a, [wPlayerState]
	and a ; PLAYER_NORMAL
	jr z, .walking
	cp PLAYER_BIKE
	jr z, .delay_state_restore
	cp PLAYER_SKATE
	jr nz, .dismiss_for_state

.delay_state_restore
; After leaving the Bike or Skateboard, wait for a completed walking step before
; restoring the follower, just as after a non-seamless warp.
	ld hl, wPokemonFollowerFlags
	set POKEMON_FOLLOWER_WARP_PENDING_F, [hl]
.dismiss_for_state
	jp DismissPokemonFollower

.walking

; Scripted player movement and the normal follow command share the follow queue.
	ld hl, wPokemonFollowerFlags
	bit POKEMON_FOLLOWER_SCRIPTED_F, [hl]
	jr z, .not_scripted
	ld a, [wScriptRunning]
	and a
	jp nz, DismissPokemonFollower
	res POKEMON_FOLLOWER_SCRIPTED_F, [hl]

.not_scripted
	ld a, [wObjectFollow_Follower]
	cp -1
	jr z, .check_respawn
	cp FOLLOWER_OBJECT_STRUCT
	jp nz, DismissPokemonFollower

.check_respawn
	ld hl, wPokemonFollowerFlags
	bit POKEMON_FOLLOWER_WARP_PENDING_F, [hl]
	jr z, .refresh
	ld a, [wPlayerStepFlags]
	bit PLAYERSTEP_STOP_F, a
	ret z
	bit PLAYERSTEP_MIDAIR_F, a
	ret nz

	res POKEMON_FOLLOWER_WARP_PENDING_F, [hl]

.refresh
	call GetCachedPokemonFollowerSprite
	ld d, a
	ld a, [wMap1ObjectStructID]
	cp FOLLOWER_OBJECT_STRUCT
	jr nz, .spawn
	ld a, [wObject12Sprite]
	and a
	jr z, .spawn
	ld a, [wObject12MapObjectIndex]
	cp FOLLOWER_OBJECT
	jr nz, .spawn
	ld a, [wMap1ObjectSprite]
	cp d
	jr nz, .spawn
	ld a, [wObjectFollow_Leader]
	and a ; PLAYER_OBJECT
	ret nz
	ld a, [wObjectFollow_Follower]
	cp FOLLOWER_OBJECT_STRUCT
	ret z

.spawn
	jp SpawnPokemonFollower

SuspendPokemonFollowerForScript::
	ld hl, wPokemonFollowerFlags
	set POKEMON_FOLLOWER_SCRIPTED_F, [hl]
	jp DismissPokemonFollower

DismissPokemonFollower::
; Do not disturb a map script's leader/follower pair.
	ld a, [wMap1ObjectStructID]
	cp -1
	ret z
	cp FOLLOWER_OBJECT_STRUCT
	jr nz, .reset_reserved_slot
	ld a, [wObjectFollow_Follower]
	cp FOLLOWER_OBJECT_STRUCT
	jr nz, .delete
	farcall StopFollow

.delete
	ld a, FOLLOWER_OBJECT
	call DeleteFollowerMapObject
	ret

.reset_reserved_slot
; Object 1 is reserved for the pet; normalize uninitialized or stale data safely.
	ld hl, wMap1Object
	ld bc, MAPOBJECT_LENGTH
	xor a
	call ByteFill
	ld a, -1
	ld [wMap1ObjectStructID], a
	ld hl, wObject12Struct
	ld bc, OBJECT_LENGTH
	xor a
	call ByteFill
	ld a, [wObjectFollow_Follower]
	cp FOLLOWER_OBJECT_STRUCT
	ret nz
	ld a, -1
	ld [wObjectFollow_Leader], a
	ld [wObjectFollow_Follower], a
	ld [wFollowerMovementQueueLength], a
	ret

SpawnPokemonFollower:
	call DismissPokemonFollower

	ld a, FOLLOWER_OBJECT
	ld hl, .ObjectTemplate
	call CopyPlayerObjectTemplate
	call GetCachedPokemonFollowerSprite
	ld [wMap1ObjectSprite], a
	call GetPokemonFollowerSpawnCoords
	ld b, FOLLOWER_OBJECT
	farcall CopyDECoordsToMapObject

	ld a, FOLLOWER_OBJECT
	ldh [hMapObjectIndex], a
	ld a, FOLLOWER_OBJECT_STRUCT
	ldh [hObjectStructIndex], a
	ld bc, wMap1Object
	ld de, wObject12Struct
	farcall CopyMapObjectToObjectStruct

	ld hl, wObject12Flags
	set WONT_DELETE_F, [hl]
	ld a, [wPlayerDirection]
	ld [wObject12Direction], a
	lb bc, PLAYER, FOLLOWER_OBJECT
	farcall StartFollow
	ret

.ObjectTemplate:
	object_event -4, -4, SPRITE_POLIWRATH, SPRITEMOVEDATA_FOLLOWING, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, 0, -1

GetPokemonFollowerSpawnCoords:
; Normally the player's previous tile is exactly where the follower belongs.
	ld a, [wPlayerLastMapX]
	ld d, a
	ld a, [wPlayerLastMapY]
	ld e, a
	ld a, [wPlayerMapX]
	cp d
	ret nz
	ld a, [wPlayerMapY]
	cp e
	ret nz

; Connections do not retain a previous tile, so use the boundary-crossing step.
; Other respawns use the player's current facing.
	ld a, [wPlayerMapX]
	ld d, a
	ld a, [wPlayerMapY]
	ld e, a
	ldh a, [hMapEntryMethod]
	cp MAPSETUP_CONNECTION
	jr nz, .use_facing
	ld a, [wPlayerStepDirection]
	add a
	add a
	jr .got_direction

.use_facing
	ld a, [wPlayerDirection]

.got_direction
	cp OW_UP
	jr z, .behind_up
	cp OW_LEFT
	jr z, .behind_left
	cp OW_RIGHT
	jr z, .behind_right
	dec e ; OW_DOWN
	ret

.behind_up
	inc e
	ret
.behind_left
	inc d
	ret
.behind_right
	dec d
	ret

GetPokemonFollowerSprite::
	; FarCall overwrites a while restoring the caller's ROM bank, so return the
	; selected sprite in c as well as a.
	call CheckPokemonFollowerEngineFlag
	call FindPokemonFollower
	jr nc, .default
	call GetPokemonFollowerSpriteForSpecies
	jr .done

; Keep the test sprite resident before the player has an eligible party member.
; Spawning can then reuse its VRAM slot instead of reloading every map sprite.
.default
	ld a, [PokemonFollowerSprites]

.done
	ld c, a
	scf
	ret

RefreshPokemonFollowerAfterPartyChange::
; Party menus already reload overworld sprite VRAM when they close. Update the
; reserved slot before that reload, then rebuild the object immediately so its
; sprite and tile base cannot remain stale until the player takes a step.
	call GetPokemonFollowerSprite
	ld a, c
	ld [wUsedSprites + FOLLOWER_SPRITE_GFX_SLOT * 2], a
	jp UpdatePokemonFollower

GetCachedPokemonFollowerSprite:
	ld a, [wPokemonFollowerSpecies]

GetPokemonFollowerSpriteForSpecies:
	dec a
	ld e, a
	ld d, 0
	ld hl, PokemonFollowerSprites
	add hl, de
	ld a, [hl]
	scf
	ret

FindPokemonFollower:
; Return carry, species in a, and party index in c when one is eligible.
	ld a, [wPartyCount]
	and a
	ret z
	ld b, a
	ld c, 0
	ld hl, wPartyMon1

.loop
	push hl
	ld a, c
	ld e, a
	ld d, 0
	ld hl, wPartySpecies
	add hl, de
	ld a, [hl]
	pop hl
	cp EGG
	jr z, .next
	push hl
	ld de, MON_STATUS
	add hl, de
	ld a, [hl]
	and (1 << FRZ) | SLP_MASK
	pop hl
	jr nz, .next
	push hl
	ld de, MON_HP
	add hl, de
	ld a, [hli]
	or [hl]
	pop hl
	jr nz, .found

.next
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	inc c
	dec b
	jr nz, .loop
	and a
	ret

.found
	ld a, [hl]
	scf
	ret

PokemonFollowerInteraction::
	ld a, BANK(.InteractionScript)
	ld hl, .InteractionScript
	call CallScript
	ret

.InteractionScript:
	faceplayer
	opentext
	callasm .PrepareInteraction
	writetext .HappyText
	waitbutton
	closetext
	end

.PrepareInteraction:
	call FindPokemonFollower
	ret nc
	ld [wPokemonFollowerSpecies], a
	ld a, c
	ld [wPokemonFollowerPartyIndex], a
	ld [wCurPartyMon], a
	farcall GetPartyNickname
	ld a, [wPokemonFollowerSpecies]
	call PlayMonCry
	ret

.HappyText:
	text_ram wStringBuffer3
	text " seems"
	line "happy."
	done

CheckPokemonFollowerEngineFlag:
; The feature check is intentionally non-gating while the system is tested.
	ld de, ENGINE_PET_SYS_ON
	farcall CheckEngineFlag
	ret

IsPokemonFollowerLinkRoom:
	ld a, [wMapGroup]
	cp GROUP_TRADE_CENTER
	jr nz, .not_link_room
	ld a, [wMapNumber]
	cp MAP_TRADE_CENTER
	jr z, .link_room
	cp MAP_COLOSSEUM
	jr z, .link_room
	cp MAP_TIME_CAPSULE
	jr z, .link_room

.not_link_room
	and a
	ret

.link_room
	scf
	ret

INCLUDE "data/sprites/pokemon_followers.asm"
