	object_const_def
;	const ROUTE_2_TEACHER

Route30_MapScripts:
	def_scene_scripts

	def_callbacks

Route30_MapEvents:
	db 0, 0 ; filler

	def_warp_events
;	warp_event  8, 25, SILENT_HILL, 3
;	warp_event  9, 25, SILENT_HILL, 3
;	warp_event  8,  5, SILENT_OLD_GATE, 1
;	warp_event  9,  5, SILENT_OLD_GATE, 2

	def_coord_events

	def_bg_events
	bg_event 10, 20, BGEVENT_READ, Route2Sign_Script

	def_object_events
;´	object_event  7, 15, SPRITE_TEACHER, SPRITEMOVEDATA_STANDING_RIGHT, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_TRAINER, 3, ObjectEvent, -1

Route2Sign_Script:
	jumptext Route2Sign_ScriptText

Route2Sign_ScriptText:
	text "ROUTE 2"
	line "SILENT TOWN -"
	cont "OLD CITY"
	done
