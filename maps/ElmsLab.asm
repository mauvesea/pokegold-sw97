	object_const_def
	const SILENTOAKSLAB_OAK_1
	const SILENTOAKSLAB_OAK_2
	const SILENTOAKSLAB_RIVAL_1
	const SILENTOAKSLAB_RIVAL_2
	const SILENTOAKSLAB_BLUE_1
	const SILENTOAKSLAB_BLUE_2
    const SILENTOAKSLAB_DAISY
    const SILENTOAKSLAB_SCIENTIST_1
    const SILENTOAKSLAB_SCIENTIST_2
    const SILENTOAKSLAB_POKEDEX_1
    const SILENTOAKSLAB_POKEDEX_2

ElmsLab_MapScripts:
	def_scene_scripts
	scene_script ElmsLabNoop1Scene,   SCENE_SILENT_LAB_INITIAL
	scene_script ElmsLabMeetElmScene, SCENE_SILENT_LAB_FRONT_EVENT
	scene_script ElmsLabNoop2Scene,   SCENE_ELMSLAB_NOOP
	scene_script ElmsLabNoop3Scene,   SCENE_ELMSLAB_MEET_OFFICER
	scene_script ElmsLabNoop4Scene,   SCENE_ELMSLAB_UNUSED
	scene_script ElmsLabNoop5Scene,   SCENE_ELMSLAB_AIDE_GIVES_POTION
	scene_const SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS

	def_callbacks

ElmsLabMeetElmScene:
	sdefer SilentOaksLabFrontScene
	end

ElmsLabNoop1Scene:
	end

ElmsLabNoop2Scene:
	end

ElmsLabNoop3Scene:
	end

ElmsLabNoop4Scene:
	end

ElmsLabNoop5Scene:
	end

SilentOaksLabFrontScene:
	follow SILENTOAKSLAB_BLUE_1, PLAYER
	applymovement SILENTOAKSLAB_BLUE_1, SilentOaksLabFrontScene_Mov1
    stopfollow
    turnobject SILENTOAKSLAB_BLUE_1, UP
    turnobject SILENTOAKSLAB_RIVAL_1, UP
    opentext 
    writetext SilentOaksLabFrontSceneText1
    waitbutton
    closetext
    opentext
    writetext SilentOaksLabFrontSceneText2
    waitbutton
    closetext
    turnobject SILENTOAKSLAB_RIVAL_1, RIGHT
    turnobject PLAYER, LEFT
    opentext
    writetext SilentOaksLabFrontSceneText3
    waitbutton
    closetext
    turnobject SILENTOAKSLAB_RIVAL_1, UP
    turnobject PLAYER, UP
    opentext
    writetext SilentOaksLabFrontSceneText4
.CantSelectNo
    yesorno
    iftrue .ContinueScene
    writetext SilentOaksLabFrontSceneText5
    sjump .CantSelectNo
.ContinueScene
    writetext SilentOaksLabFrontSceneText6
    waitbutton
    closetext
    turnobject SILENTOAKSLAB_RIVAL_1, RIGHT
    turnobject PLAYER, LEFT
    opentext
    writetext SilentOaksLabFrontSceneText7
    waitbutton
    closetext
    turnobject SILENTOAKSLAB_RIVAL_1, UP
    turnobject PLAYER, UP
    opentext
    writetext SilentOaksLabFrontSceneText8
    waitbutton
    closetext
    applymovement SILENTOAKSLAB_OAK_1, SilentOaksLabFrontScene_Mov2
    playsound SFX_ENTER_DOOR
    disappear SILENTOAKSLAB_OAK_1
    pause 10
    applymovement SILENTOAKSLAB_RIVAL_1, SilentOaksLabFrontScene_Mov3
    playsound SFX_ENTER_DOOR
    playsound SFX_ENTER_DOOR
    disappear SILENTOAKSLAB_RIVAL_1
    pause 10
    applymovement PLAYER, SilentOaksLabFrontScene_Mov4
    playsound SFX_ENTER_DOOR

    end


SilentOaksLabFrontScene_Mov1:
    step UP
    step UP
    step UP
    step UP
    step UP
    step UP
    step UP
    step UP
    step UP
    slow_step UP
    slow_step RIGHT
    step_end

SilentOaksLabFrontScene_Mov2:
    step UP
    slow_step UP
    step_end

SilentOaksLabFrontScene_Mov3:
    big_step UP
    big_step UP
    big_step RIGHT
    big_step UP
    big_step UP
    step_end

SilentOaksLabFrontScene_Mov4:
    step UP
    step UP
    step UP
    slow_step UP
    step_end

SilentOaksLabFrontSceneText1:
text "BLUE: Gramps!"
line "Look who I found!"
done

SilentOaksLabFrontSceneText2:
text "OAK: Good work!"
done

SilentOaksLabFrontSceneText3:
text "<RIVAL>: I can't"
line "believe this old"
cont "geezer is"
cont "PROF.OAK…"

para "Oh, sorry, I mean…"
line "Old man?! It's"
cont "the first time I"
cont "see him in person!"
done

SilentOaksLabFrontSceneText4:
text "OAK: Indeed! I am"
line "PROF.OAK. You've"
cont "got quite the"
cont "mouth on you!"

para "It is indeed I who"
line "called you here!"

para "Won't you listen"
line "for a while?"
done

SilentOaksLabFrontSceneText5:
text "OAK: Oh. I might"
line "not be as good a"
cont "judge of character" 
cont "as I thought…"

para "No! It can't be!"
line "I have an eye for"
cont "this sorta thing!"

para "You'll surely"
line "listen, no?"
done

SilentOaksLabFrontSceneText6:
	text "OAK: One year ago,"
	line "in KANTO, I"
	cont "entrusted two boys"
	cont "much like you"
	cont "with a POKéMON and"
	cont "a POKéDEX each,"
	cont "to assist in"
	cont "my research."
	
	para "In the end, their" 
	line "work was truly"
	cont "astounding!"
	
	para "They succeeded in"
	line "discovering 151"
	cont "POKéMON species!"
	cont "However..."
	
	para "It's a vast world"
	line "we live in. With"
	cont "that, new #MON"
	cont "started being"
	cont "found all over"
	cont "the country!"
	
	para "Therefore, I moved"
	line "from KANTO to"
	cont "here, TEAL BURG,"
	cont "to establish a new"
	cont "laboratory!"
	
	para "Because, you see,"
	line "in a new place,"
	cont "new POKéMON may"
	cont "well be found."
	cont "..."
	
	para "Research will keep"
	line "me busy,but as you"
	cont "see, I'm growing"
	cont "old. My grandson"
	cont "and AIDEs help,"
	cont "but they can only"
	cont "do so much..."
	
	para "<PLAYER>! <RIVAL>!"
	line "Please! Help me"
	cont "research POKéMON!"
	done

SilentOaksLabFrontSceneText7:
text "<RIVAL>: Hey!"
line "<PLAYER>!"
cont "This just got"
cont "interesting!"
done

SilentOaksLabFrontSceneText8:
text "OAK: Follow me,"
line "you two!"
done

ElmsLab_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3, 15, NEW_BARK_TOWN, 1
	warp_event  4, 15, NEW_BARK_TOWN, 1

	def_coord_events
;	coord_event  4,  6, SCENE_ELMSLAB_CANT_LEAVE, LabTryToLeaveScript
;	coord_event  5,  6, SCENE_ELMSLAB_CANT_LEAVE, LabTryToLeaveScript
;	coord_event  4,  5, SCENE_ELMSLAB_MEET_OFFICER, MeetCopScript
;	coord_event  5,  5, SCENE_ELMSLAB_MEET_OFFICER, MeetCopScript2
;	coord_event  4,  8, SCENE_ELMSLAB_AIDE_GIVES_POTION, AideScript_WalkPotion1
;	coord_event  5,  8, SCENE_ELMSLAB_AIDE_GIVES_POTION, AideScript_WalkPotion2
;	coord_event  4,  8, SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS, AideScript_WalkBalls1
;	coord_event  5,  8, SCENE_ELMSLAB_AIDE_GIVES_POKE_BALLS, AideScript_WalkBalls2

	def_bg_events
    bg_event  2,  0, BGEVENT_READ, SilentOaksLabPosterScript
    bg_event  6,  1, BGEVENT_UP, SilentOaksLabPCScript
    bg_event  4,  0, BGEVENT_READ, SilentOaksLabDoorScript


	def_object_events
;	object_event  5,  2, SPRITE_ELM, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ProfElmScript, -1
;	object_event  2,  9, SPRITE_SCIENTIST, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ElmsAideScript, EVENT_ELMS_AIDE_IN_LAB
;	object_event  6,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CyndaquilPokeBallScript, EVENT_CYNDAQUIL_POKEBALL_IN_ELMS_LAB
;	object_event  7,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, TotodilePokeBallScript, EVENT_TOTODILE_POKEBALL_IN_ELMS_LAB
;	object_event  8,  3, SPRITE_POKE_BALL, SPRITEMOVEDATA_STILL, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, ChikoritaPokeBallScript, EVENT_CHIKORITA_POKEBALL_IN_ELMS_LAB
;	object_event  5,  3, SPRITE_OFFICER, SPRITEMOVEDATA_STANDING_UP, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, CopScript, EVENT_COP_IN_ELMS_LAB

	object_event  4,  2, SPRITE_OAK, SPRITEMOVEDATA_STANDING_DOWN, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_OAK_IN_SILENT_LAB_FRONT
	object_event  4,  0, SPRITE_OAK, SPRITEMOVEDATA_STANDING_DOWN, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_OAK_IN_SILENT_LAB_BACK
	object_event  3,  4, SPRITE_RIVAL, SPRITEMOVEDATA_SPINRANDOM_SLOW, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, SilentOaksLabRivalScript, EVENT_RIVAL_IN_SILENT_LAB_FRONT
	object_event  4,  0, SPRITE_RIVAL, SPRITEMOVEDATA_STANDING_DOWN, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_RIVAL_IN_SILENT_LAB_BACK
	object_event  4, 14, SPRITE_BLUE, SPRITEMOVEDATA_STANDING_DOWN, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BLUE_LAB_WALK_UP
	object_event  1,  3, SPRITE_BLUE, SPRITEMOVEDATA_STANDING_DOWN, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_BLUE_LAB_FRONT
	object_event  1, 13, SPRITE_DAISY, SPRITEMOVEDATA_STANDING_DOWN, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, EVENT_POPULATE_LAB
	object_event  1,  8, SPRITE_SCIENTIST, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, SilentOaksLabAideScript, EVENT_POPULATE_LAB
	object_event  6, 12, SPRITE_SCIENTIST, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, SilentOaksLabAideScript, EVENT_POPULATE_LAB
	object_event  0,  1, SPRITE_POKEDEX, SPRITEMOVEDATA_STILL, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, -1
	object_event  1,  1, SPRITE_POKEDEX, SPRITEMOVEDATA_STILL, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, ObjectEvent, -1

SilentOaksLabRivalScript:
    jumptextfaceplayer SilentOaksLabRivalScriptText

SilentOaksLabRivalScriptText:
    text "<RIVAL>: Well, if"
    line "it isn't <PLAYER>!"
    cont "Now, you're in the"
    cont "right spot, but"
    cont "it looks like this"
    cont "place is empty?"
    done

SilentOaksLabAideScript:
    jumptextfaceplayer SilentOaksLabAideScriptText

SilentOaksLabPosterScript:
    jumptext SilentOaksLabPosterScriptText

SilentOaksLabDoorScript:
    jumptext SilentOaksLabDoorScriptText

SilentOaksLabPCScript:
    jumptext SilentOaksLabPCScriptText

SilentOaksLabAideScriptText:
    text "I'm one of PROF."
    line "OAK's AIDEs."

    para "I have a feeling"
    line "that we'll see"
    cont "each other again."
    done

SilentOaksLabPosterScriptText:
    text "Push START to"
    line "open the MENU!"
    done

SilentOaksLabDoorScriptText:
    text "It's locked."
    done

SilentOaksLabPCScriptText:
    text "There's an e-mail"
    line "out in the open!"

    para "…PROF.OAK! The"
    line "whole world's in a" 
    cont "terrible stir over"
    cont "your whereabouts!"

    para "As for the #MON"
    line "you asked I search"
    cont "for, I have yet to"
    cont "find even a single"
    cont "lead-- let alone"
    cont "its hiding spot."

    para "I suppose that's"
    line "to be expected…"
    cont "It's high up in"
    cont "the sky after all."
    cont "Regards,"
    cont "Your AIDE"
    done




