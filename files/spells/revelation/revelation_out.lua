dofile_once( "mods/necro_stuff/files/generic_lib.lua" )
dofile_once( "data/scripts/status_effects/status_list.lua" )

local effect_id = GetUpdatedEntityID()
local deadman = EntityGetRootEntity( effect_id )

unpackage_entity( deadman, true )
SetRandomSeed( GameGetFrameNum(), effect_id + deadman )
local status = status_effects[Random( 1, #status_effects )]
while( string.find( status.id, "INGESTION" ) ~= nil ) do
	status = status_effects[Random( 1, #status_effects )]
end
local status_id = LoadGameEffectEntityTo( deadman, status.effect_entity )
local status_comp = EntityGetFirstComponentIncludingDisabled( status_id, "GameEffectComponent" )
if( status_comp ~= nil ) then
	ComponentSetValue2( status_comp, "frames", -1 )
	
	EntityAddComponent( status_id, "UIIconComponent", 
	{
		icon_sprite_file = status.ui_icon,
		name = status.ui_name,
		description = status.ui_description,
		display_above_head = "1",
		display_in_hud = "1",
		is_perk = "0",
	})
end

EntityKill( effect_id )