	object_const_def
	const ROUTE_1_SUPERNERD
	const ROUTE_1_YOUNGSTER

Route29_MapScripts:
	def_scene_scripts
;	scene_script Route29Noop1Scene, SCENE_ROUTE29_NOOP
;	scene_script Route29Noop2Scene, SCENE_ROUTE29_CATCH_TUTORIAL

	def_callbacks
;	callback MAPCALLBACK_OBJECTS, Route29TuscanyCallback

Route29Noop1Scene:
	end

Route29Noop2Scene:
	end

Route29_MapEvents:
	db 0, 0 ; filler

	def_warp_events
;	warp_event 8,  8, SILENT_HILL, 1
;	warp_event 8,  9, SILENT_HILL, 2

	def_coord_events

	def_bg_events
	bg_event 20,  8, BGEVENT_READ, Route1Sign1_Script
	bg_event 12,  7, BGEVENT_READ, Route1Sign2_Script

	def_object_events
	object_event 20,  5, SPRITE_SUPER_NERD, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Route1SuperNerd_Script, -1
	object_event 18, 12, SPRITE_YOUNGSTER, SPRITEMOVEDATA_WANDER, 1, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, Route1Youngster_Script, -1

Route1Sign1_Script:
	jumptext Route1Sign1_ScriptText

Route1Sign1_ScriptText:
	text "ROUTE 1"
	line "SILENT TOWN -"
	cont "OLD CITY"
	done

Route1Sign2_Script:
	jumptext Route1Sign2_ScriptText

Route1Sign2_ScriptText:
	text "Beyond here lies"
	line "the SILENT HILLS."
	para "Beware of wild"
	line "#MON."
	done

Route1SuperNerd_Script:
	jumptextfaceplayer Route1SuperNerd_ScriptText

Route1SuperNerd_ScriptText:
	text "Listen up, lad!"
	para "# BALLs should"
	line "be used only after"
	cont "weakening the wild"
	cont "#MON!"
	done

Route1Youngster_Script:
	jumptextfaceplayer Route1Youngster_ScriptText

Route1Youngster_ScriptText:
	text "One evening, on my"
	line "way home from cram"
	para "school, I saw an"
	line "unknown #MON!"
	done
