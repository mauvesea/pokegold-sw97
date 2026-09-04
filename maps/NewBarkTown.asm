	object_const_def
	const TEALBURG_RIVAL
	const TEALBURG_BLUE
	const TEALBURG_TEACHER
	const TEALBURG_SUPER_NERD
	const TEALBURG_PICROSS
	
NewBarkTown_MapScripts:
	def_scene_scripts
	scene_script TealBurgMeetRivalScene, SCENE_TEALBURG_RIVAL
	scene_script TealBurgNoop1Scene, SCENE_TEALBURG_BLUE
	scene_script TealBurgNoop2Scene, SCENE_TEALBURG_NOOP

	def_callbacks
	callback MAPCALLBACK_NEWMAP, NewBarkTownFlypointCallback

TealBurgMeetRivalScene:
	sdefer Tealburg_RivalScript
	end

TealBurgNoop1Scene:
TealBurgNoop2Scene:
	end

NewBarkTownFlypointCallback:
	setflag ENGINE_FLYPOINT_NEW_BARK
	clearevent EVENT_FIRST_TIME_BANKING_WITH_MOM
	endcallback

NewBarkTown_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event 14, 15, ELMS_LAB, 1
	warp_event 15, 15, ELMS_LAB, 2
	warp_event  3,  8, PLAYERS_HOUSE_1F, 1
	warp_event  0,  0, PLAYERS_NEIGHBORS_HOUSE, 1
	warp_event  0,  0, ELMS_HOUSE, 1

	def_coord_events
	coord_event  0, 11, SCENE_TEALBURG_BLUE, Tealburg_BlueCoordScript1
	coord_event  0, 14, SCENE_TEALBURG_BLUE, Tealburg_BlueCoordScript2

	def_bg_events	
	bg_event 16,  9, BGEVENT_READ, TealburgSign
	bg_event  6,  8, BGEVENT_READ, TealburgPlayerHouseSign
	bg_event  6, 16, BGEVENT_READ, TealburgRivalHouseSign
	bg_event 14,  8, BGEVENT_READ, TealburgPokecenterSign
	bg_event 10, 15, BGEVENT_READ, TealburgLabSign

	def_object_events
	object_event  4, 14, SPRITE_RIVAL, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_RIVAL_NEW_BARK_TOWN
	object_event  6, 13, SPRITE_BLUE, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_TEALBURG_BLUE
	object_event  8, 10, SPRITE_TEACHER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Tealburg_TeacherScript, -1
	object_event 10, 17, SPRITE_SUPER_NERD, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, Tealburg_SuperNerdScript, -1

	object_event 10, 8, SPRITE_YOUNGSTER, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, Tealburg_PicrossScript, -1

Tealburg_RivalScript:
	applymovement PLAYER, Tealburg_RivalScript_Mov1
	showemote EMOTE_SHOCK, PLAYER, 15
	playmusic MUSIC_RIVAL_ENCOUNTER
	applymovement TEALBURG_RIVAL, Tealburg_RivalScript_Mov2
	turnobject PLAYER, RIGHT
	opentext
	writetext Tealburg_RivalScript_Text1	
	loadmenu .MenuHeader
	verticalmenu
	closewindow
	ifequal 1, .NewName
	ifequal 2, .Mother
	ifequal 3, .Mom
	ifequal 4, .Mommy
.Next
	writetext Tealburg_RivalScript_Text2
	waitbutton
	closetext
	applymovement TEALBURG_RIVAL, Tealburg_RivalScript_Mov3
	disappear TEALBURG_RIVAL
	special RestartMapMusic
	setscene SCENE_TEALBURG_BLUE
	end
	
.MenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, 11
	dw .MenuData
	db 1 ; default option

.MenuData:
	db STATICMENU_CURSOR | STATICMENU_PLACE_TITLE | STATICMENU_DISABLE_B ; flags
	db 4 ; items
	db "NEW NAME@"
	db "MOTHER@"
	db "MOM@"
	db "MOMMY@"	
	db 2 ; title indent
	db "NAME@" ; title

.NewName
	special NameMom
	sjump .Next

.Mother
	callasm .MotherName1
	sjump .Next
.Mom
	callasm .MotherName2
	sjump .Next
.Mommy
	callasm .MotherName3
	sjump .Next
.MotherName1:
	ld hl, .DefaultName1
	jr .SetName
.MotherName2:
	ld hl, .DefaultName2
	jr .SetName
.MotherName3:
	ld hl, .DefaultName3
.SetName
	ld de, wMomsName
	ld bc, NAME_LENGTH
	call CopyBytes
	ret
	
.DefaultName1:
	db "MOTHER@"
	
.DefaultName2:
	db "MOM@"

.DefaultName3:
	db "MOMMY@"	
	
Tealburg_BlueCoordScript1:
    clearevent EVENT_POPULATE_LAB
    clearevent EVENT_BLUE_LAB_WALK_UP
    clearevent EVENT_OAK_IN_SILENT_LAB_FRONT
    setmapscene ELMS_LAB, SCENE_SILENT_LAB_FRONT_EVENT
	opentext
	writetext Tealburg_BlueCoordScript_Text1
	waitbutton
	closetext
	showemote EMOTE_SHOCK, PLAYER, 15
	turnobject PLAYER, RIGHT
	playmusic MUSIC_SHOW_ME_AROUND
	appear TEALBURG_BLUE
	applymovement TEALBURG_BLUE, Tealburg_BlueCoordScript_Mov1
	opentext
	writetext Tealburg_BlueCoordScript_Text2
	waitbutton
	closetext
	follow TEALBURG_BLUE, PLAYER
	applymovement TEALBURG_BLUE, Tealburg_BlueCoordScript_Mov2
	stopfollow
	disappear TEALBURG_BLUE
	applymovement PLAYER, Tealburg_BlueCoordScript_Mov3
	special FadeOutPalettes
	pause 15
	warp ELMS_LAB, 4, 15
	end
	
Tealburg_BlueCoordScript2:
    clearevent EVENT_POPULATE_LAB
    clearevent EVENT_BLUE_LAB_WALK_UP
    clearevent EVENT_OAK_IN_SILENT_LAB_FRONT
    setmapscene ELMS_LAB, SCENE_SILENT_LAB_FRONT_EVENT
	opentext
	writetext Tealburg_BlueCoordScript_Text1
	waitbutton
	closetext
	showemote EMOTE_SHOCK, PLAYER, 15
	turnobject PLAYER, RIGHT
	playmusic MUSIC_SHOW_ME_AROUND
	appear TEALBURG_BLUE
	applymovement TEALBURG_BLUE, Tealburg_BlueCoordScript_Mov4
	opentext
	writetext Tealburg_BlueCoordScript_Text2
	waitbutton
	closetext
	follow TEALBURG_BLUE, PLAYER
	applymovement TEALBURG_BLUE, Tealburg_BlueCoordScript_Mov5
	stopfollow
	disappear TEALBURG_BLUE
	applymovement PLAYER, Tealburg_BlueCoordScript_Mov3
	special FadeOutPalettes
	pause 15
	warp ELMS_LAB, 4, 15
	end
	
TealburgSign:
	jumptext TealburgSign_Text
	
TealburgPlayerHouseSign:
	jumptext TealburgPlayerHouseSign_Text

TealburgRivalHouseSign:
	jumptext TealburgRivalHouseSign_Text

TealburgPokecenterSign:
	jumpstd PokecenterSignScript

TealburgLabSign:
	opentext
;	checkevent EVENT_OAK_LEFT_TEALBURG
;	ifalse .OaksLab
;	writetext TealburgLabSign_Text2
;	jr .Finish
.OaksLab
	writetext TealburgLabSign_Text1
.Finish
	waitbutton
	closetext
	end

Tealburg_TeacherScript:
	faceplayer
	opentext
	writetext Tealburg_TeacherScript_Text1
	waitbutton
	closetext
;	checkevent EVENT_GOT_HOLDERS
;	iffalse .Finish
;	showemote EMOTE_SHOCK, TEALBURG_TEACHER, 15
;	opentext
;	writetext Tealburg_TeacherScript_Text2
;	waitbutton
;	closetext
;	.Finish
	end

Tealburg_SuperNerdScript:
	jumptextfaceplayer Tealburg_SuperNerdScript_Text1	
	
Tealburg_TeacherScript_Text1:
	text "Your backpack is"
	line "so cool!"
	para "Where did you get"
	line "it?"
	done

Tealburg_TeacherScript_Text2:
	text "Wow! You even got"
	line "HOLDERs to organ-"
	cont "ize your items!"
	done

Tealburg_SuperNerdScript_Text1:
	text "I wonder if there's"
	line "anyone in this"
	cont "world who dislikes"
	cont "#MON."
	done
	
Tealburg_RivalScript_Text1:
	text "<RIVAL>: <PLAYER>!"
	line "You see, there's"
	cont "something I wanna"
	cont "brag to you about."
	
	para "I received an"
	line "email from that"
	cont "famous PROF.OAK!"
	cont "Huh? You got one"
	cont "too? Ugh! Boring!"
	
	para "…Hmph!"
	line "Then, then…"
	cont "Got it!"
	cont "What do you call"
	cont "your mom?"
	done
	
Tealburg_RivalScript_Text2:
	text "<MOM>…"
	line "Lame! You really"
	cont "call her something"
	cont "so childish? Don't"
	cont "make me laugh! "
	cont "Oh, I feel re-"
	cont "freshed already."
	
	para "Then… I'll be one"
	line "step ahead and go"
	cont "to PROF.OAK's place"
	cont "at once!"
	done
	
Tealburg_BlueCoordScript_Text1:
	text "Hold on a sec!"
	line "Wait! Wait up!"
	done

Tealburg_BlueCoordScript_Text2:
	text "You really don't"
	line "know anything, do"
	cont "you?"
	cont "If you go into the"
	cont "tall grass, wild"
	cont "#MON will jump"
	cont "at you!"
	
	para "If you had your"
	line "own #MON, you"
	cont "could protect"
	cont "yourself…"
	
	para "Oh! Could you be…"
	line "Come with me for a"
	cont "moment!"
	done
	
TealburgSign_Text:
	text "Ever peaceful"
	line "TEAL BURG"
	done
	
TealburgPlayerHouseSign_Text:
	text "<PLAYER>'s house"
	done
	
TealburgRivalHouseSign_Text:
	text "<RIVAL>'s house"
	done
	
TealburgLabSign_Text1:
	text "PROF.OAK #MON"
	line "RESEARCH LAB"
	done
	
TealburgLabSign_Text2:
	text "HOUSE FOR RENT"
	done
	
Tealburg_RivalScript_Mov1:
	step DOWN
	step_end
	
Tealburg_RivalScript_Mov2:
	big_step UP
	big_step UP
	big_step UP
	big_step UP
	slow_step UP
	turn_head LEFT
	step_end
	
Tealburg_RivalScript_Mov3:
	slow_step DOWN
	big_step DOWN
	big_step DOWN
	big_step DOWN
	big_step DOWN
	big_step DOWN
	step_end
	
Tealburg_BlueCoordScript_Mov1:
	step LEFT
	step LEFT
	step LEFT
	step UP
	step LEFT
	step LEFT	
	step_end
	
Tealburg_BlueCoordScript_Mov2:
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step UP
	step_end
	
Tealburg_BlueCoordScript_Mov3:
	slow_step UP
	step_end

Tealburg_BlueCoordScript_Mov4:
	step LEFT
	step LEFT
	step LEFT
	step LEFT
	step LEFT	
	step_end
	
Tealburg_BlueCoordScript_Mov5:
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step DOWN
	step DOWN
	step DOWN
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step RIGHT
	step UP
	step_end		

Tealburg_PicrossScript:
	faceplayer
	opentext
	writetext Tealburg_PicrossText
	callasm PicrossStageMenu
	ifequal -1, .Cancel
	closetext
	callasm PlayPicrossFromOverworld
	end
.Cancel:
	closetext
	end

Tealburg_PicrossText:
	text "Pick a puzzle!"
	para "A: fill  B: mark"
	line "START when solved."
	done
