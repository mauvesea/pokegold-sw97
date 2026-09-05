	object_const_def

CherrygroveCity_MapScripts:
	def_scene_scripts
	scene_script CherrygroveCityNoop1Scene, SCENE_CHERRYGROVECITY_NOOP
	scene_script CherrygroveCityNoop2Scene, SCENE_CHERRYGROVECITY_MEET_RIVAL

	def_callbacks
	callback MAPCALLBACK_NEWMAP, CherrygroveCityFlypointCallback

CherrygroveCityNoop1Scene:
	end

CherrygroveCityNoop2Scene:
	end

CherrygroveCityFlypointCallback:
	setflag ENGINE_FLYPOINT_CHERRYGROVE
	endcallback

CherrygroveCity_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  0,  0, CHERRYGROVE_MART, 2
	warp_event  0,  0, CHERRYGROVE_POKECENTER_1F, 1
	warp_event  0,  0, CHERRYGROVE_GYM_SPEECH_HOUSE, 1
	warp_event  0,  0, GUIDE_GENTS_HOUSE, 1
	warp_event  0,  0, CHERRYGROVE_EVOLUTION_SPEECH_HOUSE, 1

	def_coord_events
;	coord_event 33,  6, SCENE_CHERRYGROVECITY_MEET_RIVAL, CherrygroveRivalSceneNorth
;	coord_event 33,  7, SCENE_CHERRYGROVECITY_MEET_RIVAL, CherrygroveRivalSceneSouth

	def_bg_events
;	bg_event 30,  8, BGEVENT_READ, CherrygroveCitySign

	def_object_events
	object_event  8, 30, SPRITE_TWIN, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MochaCity_TwinScript, -1
	object_event  2, 20, SPRITE_SUPER_NERD, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, -1
	object_event 14, 26, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 2, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MochaCity_Bugcatcher1Script, -1
	object_event 10, 21, SPRITE_BUG_CATCHER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, MochaCity_Bugcatcher2Script, -1
	object_event 16, 12, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ObjectEvent, -1


MochaCity_TwinScript:
	jumptextfaceplayer MochaCity_TwinScript_Text
	
MochaCity_Bugcatcher1Script:
	jumptextfaceplayer MochaCity_Bugcatcher1Script_Text
	
MochaCity_Bugcatcher2Script:
	jumptextfaceplayer MochaCity_Bugcatcher1Script_Text
	
MochaCity_SuperNerdScript:
	faceplayer
	opentext
	writetext MochaCity_SuperNerdScript_Text1
	waitbutton
	writetext MochaCity_SuperNerdScript_Text2
	checkevent EVENT_BEAT_FALKNER
	waitbutton
	closetext
	end
	
MochaCity_SuperNerdScript_Text1:
	text "I just dropped a"
	line "very important"
	cont "thing around here."
	
	para "If you walk over"
	line "here now, you may"
	cont "step on it!"
	
	para "So just wait until"
	line "I find it, okay?"
	done
	
MochaCity_SuperNerdScript_Text2:
	text "In the mean time,"
	line "you could "
	cont "challenge the local"
	cont "GYM LEADER."
	done
	
MochaCity_TwinScript_Text:
	text "My grandpa makes"
	line "handmade BALLs!"
	
	para "Though he says"
	line "he only makes"
	cont "them for worthy"
	cont "trainers."
	done

MochaCity_Bugcatcher1Script_Text:
	text "MOCHA CITY is the"
	line "best place to live"
	cont "in HONSHU!"
	
	para "We even got a"
	line "#MON SCHOOL"
	cont "here!"
	done
	
MochaCity_Bugcatcher2Script_Text:
	text "The tower ahead is"
	line "named BRASS TOWER."
	
	para "Tradition says a"
	line "legendary #MON"
	cont "once made it it's"
	cont "nest."
	done
