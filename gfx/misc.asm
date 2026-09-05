SECTION "Egg Pic", ROMX

EggPic::
INCBIN "gfx/pokemon/egg/front.2bpp.lz"


SECTION "Title Screen", ROMX

TitleScreenGFX::
INCBIN "gfx/title/title.2bpp"

IF DEF(_GOLD)
TitleScreenVersionGFX::
INCBIN "gfx/title/title_gold_version.2bpp"

ELIF DEF(_SILVER)
TitleScreenVersionGFX::
INCBIN "gfx/title/title_silver_version.2bpp"
ENDC

TitleScreenHoOhGFX::
INCBIN "gfx/title/title_hooh.2bpp"

TitleScreenLogoGFX::
INCBIN "gfx/title/title_logo.2bpp"

IF DEF(_GOLD)
TitleScreenVersionLogoGFX::
INCBIN "gfx/title/title_goldlogo.2bpp"

ELIF DEF(_SILVER)
TitleScreenVersionLogoGFX::
INCBIN "gfx/title/title_silverlogo.2bpp"
ENDC

SECTION "The End", ROMX

TheEndGFX::
INCBIN "gfx/credits/theend.2bpp"


SECTION "Font Inversed", ROMX

FontInversed::
INCBIN "gfx/font/font_inversed.1bpp"


SECTION "Copyright", ROMX

CopyrightGFX::
INCBIN "gfx/splash/copyright.2bpp"


SECTION "Title Screen 2", ROMX

TitleScreenFireGFX::
INCBIN "gfx/title/fire.2bpp"

TitleScreenDecorationGFX::
INCBIN "gfx/title/titlebgdecoration.2bpp"


SECTION "Shrink Pics", ROMX

Shrink1Pic::
INCBIN "gfx/new_game/shrink1.2bpp.lz"
Shrink2Pic::
INCBIN "gfx/new_game/shrink2.2bpp.lz"


SECTION "Pokégear GFX", ROMX

PokegearGFX::
INCBIN "gfx/pokegear/pokegear.2bpp.lz"
