dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()

local anim = "fly_idle"
if( ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( entity_id, "SpriteComponent" ), "rect_animation" ) ~= anim ) then
	GamePlayAnimation( entity_id, anim, 0.5 )
end

local vel_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "VelocityComponent" )
local v_x, v_y = ComponentGetValue2( vel_comp, "mVelocity" )
if( v_x ~= 0 or v_y ~= 0 ) then
	ComponentSetValueVector2( vel_comp, "mVelocity", 0, 0 )
end