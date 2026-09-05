	object_const_def
	const PLAYERSHOUSE_KEN
	const PLAYERSHOUSE_KANTO_DOLL
	const PLAYERSHOUSE_CARD_MINIGAME
	const PLAYERSHOUSE_CARD_MINIGAME2

PlayersHouse2F_MapScripts:
	def_scene_scripts
	scene_script PlayersHouse2FNoop1Scene, SCENE_PLAYERSHOUSE2F_KEN
	scene_script PlayersHouse2FNoop2Scene, SCENE_PLAYERSHOUSE2F_NOOP	

	def_callbacks
	callback MAPCALLBACK_NEWMAP, PlayersHouse2FInitializeRoomCallback
	
PlayersHouse2FNoop1Scene:
PlayersHouse2FNoop2Scene:
	end

PlayersHouse2FInitializeRoomCallback:
	setevent EVENT_TEMPORARY_UNTIL_MAP_RELOAD_8
	checkevent EVENT_INITIALIZED_EVENTS
	iftrue .SkipInitialization
	setflag ENGINE_POKEGEAR
	jumpstd InitializeEventsScript
	endcallback

.SkipInitialization:
	endcallback

PlayersHouseBookshelfScript:
	jumpstd PictureBookshelfScript
	
PlayersHouseConsoleScript:
	jumptext PlayersHouseConsoleScript_Text
	
PlayersHouseDollScript:	
	jumptext PlayersHouseDollScript_Text

PlayersHouse2F_KenScript:
	faceplayer
	opentext
	checkevent EVENT_READ_OAKS_EMAIL
	iftrue .AlreadyReadEmail
	checkevent EVENT_TALKED_TO_KEN_ONCE
	iftrue .TalkedToKenOnce
	setevent EVENT_TALKED_TO_KEN_ONCE
	writetext PlayersHouse2F_KenScript_Text1
	sjump .FinishScript
.AlreadyReadEmail
	writetext PlayersHouse2F_KenScript_Text3
	sjump .FinishScript
.TalkedToKenOnce
	writetext PlayersHouse2F_KenScript_Text2
.FinishScript
	waitbutton
	closetext
	end

PlayersHouse2F_KenCoordScript:
	turnobject PLAYER, LEFT
	turnobject PLAYERSHOUSE_KEN, RIGHT
	opentext
	checkevent EVENT_READ_OAKS_EMAIL
	iftrue .AlreadyReadEmail
	checkevent EVENT_TALKED_TO_KEN_ONCE
	iftrue .TalkedToKenOnce
	setevent EVENT_TALKED_TO_KEN_ONCE
	writetext PlayersHouse2F_KenScript_Text1
	sjump .FinishScript
.AlreadyReadEmail
	writetext PlayersHouse2F_KenScript_Text3
	sjump .FinishScript
.TalkedToKenOnce
	writetext PlayersHouse2F_KenScript_Text2
.FinishScript
	waitbutton
	closetext
	applymovement PLAYER, PlayersHouse2F_KenCoordScript_Mov1
	end

PlayersHousePCScript:
	opentext
	waitsfx
	writetext PlayersHousePCScriptText1
	playsound SFX_BOOT_PC
	waitsfx
	checkevent EVENT_READ_OAKS_EMAIL
	iftrue .RandomSite
	writetext PlayersHousePCScriptText2
	yesorno
	iffalse .NotReading
	playmusic MUSIC_PROF_OAK
	setevent EVENT_READ_OAKS_EMAIL
	writetext PlayersHousePCScriptText3
	musicfadeout MUSIC_NEW_BARK_TOWN, 16
	setscene SCENE_PLAYERSHOUSE2F_NOOP
	sjump .Finished
.RandomSite
	random 2
	ifequal 0, .SilphCoSite
	writetext PlayersHousePCScriptText6
	sjump .Finished
.SilphCoSite
	writetext PlayersHousePCScriptText5
	sjump .Finished
.NotReading
	writetext PlayersHousePCScriptText4
.Finished
	waitbutton
	closetext
	end
	
PlayersHouseRadioScript:
	setflag ENGINE_RADIO_CARD
	setflag ENGINE_MAP_CARD
	setflag ENGINE_PHONE_CARD
	setflag ENGINE_POKEDEX
	opentext
	givepoke CHIKORITA, 5
	givepoke PIKACHU, 5
	closetext
	end
	checkevent EVENT_LISTENED_TO_INITIAL_RADIO
	iftrue .NormalRadio
	opentext
	writetext PlayersRadioText1
	pause 45
	writetext PlayersRadioText2
	pause 45
	writetext PlayersRadioText3
	pause 45
	closetext
	playmusic MUSIC_POKE_FLUTE_CHANNEL
	setevent EVENT_LISTENED_TO_INITIAL_RADIO
	end

.NormalRadio:
	jumpstd Radio1Script
	
PlayersHouse2F_KenCoordScript_Mov1:
	step DOWN
	step_end
	
PlayersRadioText1:
	text "<PLAYER> turned on"
	line "the radio."
	
	para "Now listening to "
	line "JOPM, the #MON "
	cont "broadcast station!"
	cont "We'll now present"
	cont "#MON News."
	done

PlayersRadioText2:
	text "<……>World-renowned"
	line "#MON researcher"
	cont "reported missing"
	cont "from Kanto!"
	cont "Some suspect that"
	cont "PROF.OAK may have"
	cont "simply left for a"
	cont "new place to"
	cont "study, but we can't"
	cont "yet disprove that"
	cont "foul play may have"
	cont "been involved."
	cont "Concerned parties"
	cont "are very worried."
	done
	
PlayersRadioText3:	
	text "<……>That concludes"
	line "today's news."
	cont "<……> <……> <……> <……>"
	
	para "Coming up, music."
	done

PlayersHousePCScriptText6:
	text "#MON JOURNAL"
	line "HOME PAGE<……>"
	cont "A new #MON has"
	cont "been discovered!"
	cont "Its strong wings "
	cont "are hard as steel."
	cont "It is not only a "
	cont "flying type, but"
	cont "also part of the"
	cont "new steel type!"
	cont "Further research "
	cont "is in the works<……>"
	done

PlayersHouse2F_KenScript_Text1:
	text "KEN: Oh! That"
	line "shiny thing on"
	cont "your wrist<……>"
	cont "You finally bought"
	cont "a TRAINER GEAR!"
	
	para "Sweet! But since"
	line "it's new and"
	cont "all, you can't do"
	cont "much more than"
	cont "check the time,"
	cont "can you?"
	cont "I'll enable the"
	cont "map for ya later!"
	cont "You're going out"
	cont "anyway, right?"
	
	para "Mom's out"
	line "shopping, so if"
	cont "you were hoping to"
	cont "ask for some"
	cont "spending money,"
	cont "that's too bad!"
	
	para "Oh, right, I saw"
	line "your PC got a new"
	cont "e-mail. At least"
	cont "check that before"
	cont "you leave, huh?"
	done

PlayersHouse2F_KenScript_Text2:
	text "KEN: Oh, right, I"
	line "saw your PC got a"
	cont "new e-mail. At"
	cont "least check that"
	cont "before you leave,"
	cont "huh?"
	done

PlayersHouse2F_KenScript_Text3:
	text "KEN: Mom's out"
	line "shopping, so if"
	cont "you were hoping to"
	cont "ask for some"
	cont "spending money,"
	cont "that's too bad!"	
	done
	
PlayersHousePCScriptText1:
	text "<PLAYER> turned on"
	line "the PC."
	done

PlayersHousePCScriptText2:
	text "Oh? There seems to"
	line "be a new e-mail "
	cont "addressed to"
	cont "<PLAYER>! Read it?"
	done
	
PlayersHousePCScriptText3:
	text "I hope you'll"
	line "excuse the sudden"
	cont "e-mail, but there"
	cont "is something that "
	cont "I would like to"
	cont "entrust you with."
	cont "Won't you come by"
	cont "and collect it?"
	
	para "#MON researcher"
	line "OAK"
	done
	
PlayersHousePCScriptText4:
	text "I'll read this"
	line "later<……>"
	done
	
PlayersHousePCScriptText5:
	text "Introducing the"
	line "TRAINER GEAR!"
	cont "A cutting edge"
	cont "watch just for"
	cont "#MON trainers."
	
	para "It tells the time,"
	line "of course, but "
	cont "add a CARTRIDGE"
	cont "and it can show"
	cont "you where you are!"
	cont "It can even make "
	cont "phone calls!"
	
	para "And to top it"
	line "all off, you can"
	cont "use it to listen "
	cont "to the radio!"
	
	para "Order yours at…"
	line "<……> <……> <……> <……>"
	cont "It's SILPH's"
	cont "home page."
	done
	
PlayersHouseConsoleScript_Text:
	text "<PLAYER> played"
	line "the Nintendo 64!"
	cont "<……>Alright!"
	cont "It's time to go!"
	done

PlayersHouseDollScript_Text:
	text "It's a doll you"
	line "got as a Christmas"
	cont "present from a"
	cont "relative in KANTO."
	done	

PlayersHouse2F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  9,  0, PLAYERS_HOUSE_1F, 3

	def_coord_events
	coord_event  9, 1, SCENE_PLAYERSHOUSE2F_KEN, PlayersHouse2F_KenCoordScript

	def_bg_events
	bg_event  1,  1, BGEVENT_READ, PlayersHouseBookshelfScript
	bg_event  5,  1, BGEVENT_READ, PlayersHouseBookshelfScript
	bg_event  3,  1, BGEVENT_UP, PlayersHousePCScript
	bg_event  2,  1, BGEVENT_UP, PlayersHouseRadioScript
	bg_event  7,  2, BGEVENT_READ, PlayersHouseConsoleScript
	
	def_object_events
	object_event  8,  1, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouse2F_KenScript, EVENT_GOT_A_POKEMON_FROM_ELM	
	object_event  6,  1, SPRITE_FAIRY, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouseDollScript, -1
	object_event  5,  3, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouse2F_CardMinigame, -1
	object_event  3,  3, SPRITE_ROCKER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, PlayersHouse2F_CardMinigame2, -1


PlayersHouse2F_CardMinigame:
	giveitem COIN_CASE
	givecoins 20
	giveitem KEY_HOLDER
	giveitem BALL_HOLDER
	giveitem TMHM_HOLDER
	refreshscreen
	setval FALSE
	special UnusedMemoryGame
	closetext
	end

PlayersHouse2F_CardMinigame2:
	giveitem COIN_CASE
	givecoins 20
	giveitem KEY_HOLDER
	giveitem BALL_HOLDER
	giveitem TMHM_HOLDER
	refreshscreen
	setval FALSE
	special CardFlip
	closetext
	special PlayMapMusic
	end
