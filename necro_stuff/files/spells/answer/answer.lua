dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( projectile_id )

local frame_num = GameGetFrameNum()
local abyss_comp = EntityGetFirstComponentIncludingDisabled( projectile_id, "BlackHoleComponent", "abyss" )
ComponentSetValue2( abyss_comp, "radius", 15 + frame_num%10 )
ComponentSetValue2( abyss_comp, "particle_attractor_force", 6666 - 100*frame_num%10 )

local meat = EntityGetInRadius( x, y, 10 )
if( #meat > 0 ) then
	for i,entity_id in ipairs( meat ) do
		if( EntityGetRootEntity( entity_id ) == entity_id and entity_id ~= projectile_id ) then
			EntityKill( entity_id )
		end
	end
end