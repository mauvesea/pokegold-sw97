	object_const_def
	const PLAYERSHOUSE1F_MOM1
	const PLAYERSHOUSE1F_MOM2
	const PLAYERSHOUSE1F_MOM3

PlayersHouse1F_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_NEWMAP, PlayersHouse1FResetMusic
	
PlayersHouse1FResetMusic:
	checkevent EVENT_MUSIC_FADEOUT
	iftrue .SkipCallback
	checkevent EVENT_LISTENED_TO_INITIAL_RADIO
	iftrue .fademusic
	sjump .SkipCallback
.fademusic
	setevent EVENT_MUSIC_FADEOUT
	musicfadeout MUSIC_NEW_BARK_TOWN, 16
.SkipCallback	
	endcallback

PlayersHouse1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  6,  7, NEW_BARK_TOWN, 3
	warp_event  7,  7, NEW_BARK_TOWN, 3
	warp_event  9,  0, PLAYERS_HOUSE_2F, 1

	def_coord_events

	def_bg_events
	bg_event  0,  1, BGEVENT_READ, PlayersHouse1FStoveScript
	bg_event  1,  1, BGEVENT_READ, PlayersHouse1FSinkScript
	bg_event  2,  1, BGEVENT_READ, PlayersHouse1FFridgeScript
	bg_event  4,  1, BGEVENT_READ, PlayersHouse1FTVScript

	def_object_events
	object_event  2,  2, SPRITE_MOM, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, MORN, 0, OBJECTTYPE_SCRIPT, 0, MomScript,-1
	object_event  7,  3, SPRITE_MOM, SPRITEMOVEDATA_STANDING_LEFT, 0, 0, -1, DAY, 0, OBJECTTYPE_SCRIPT, 0, MomScript,-1
	object_event  0,  2, SPRITE_MOM, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, NITE, 0, OBJECTTYPE_SCRIPT, 0, MomScript,-1


MomScript:
	jumptextfaceplayer MomScript_Text1

PlayersHouse1FStoveScript:
	jumptext PlayersHouse1FStoveScriptText

PlayersHouse1FSinkScript:
	jumptext PlayersHouse1FSinkScriptText

PlayersHouse1FFridgeScript:
	jumptext PlayersHouse1FFridgeScriptText

PlayersHouse1FTVScript:
	jumptext PlayersHouse1FTVScriptText

MomScript_Text1:
	text "<MOM>: Oh, you"
	line "were asked by"
	cont "PROF.OAK to help"
	cont "make a new #-"
	cont "DEX?"
	
	para "That's wonderful!"
	line "I may not know too"
	cont "much about #-"
	cont "MON, but I'll be"
	cont "rooting for you!"
	done
	
PlayersHouse1FStoveScriptText:
	text "The fire in the"
	line "stove is out,"
	cont "safety first!"
	done
	
PlayersHouse1FSinkScriptText:
	text "A spotless sink!"
	line "What's on the menu"
	cont "this evening?"
	done
	
PlayersHouse1FFridgeScriptText:
	text "The inside<……>"
	line "Is almost empty."
	done
	
PlayersHouse1FTVScriptText:
	text "Primeape is on a"
	line "rampage and Ash is"
	cont "running away!"
	
	para "The #MON anime"
	line "is on TV!"
	done
	
