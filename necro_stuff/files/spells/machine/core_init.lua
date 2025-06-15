dofile_once( "data/scripts/lib/utilities.lua" )
dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()

local cores = EntityGetWithTag( "machine_core" )
if( #cores < 40 ) then
	local x, y = EntityGetTransform( entity_id )
	
	local found, n_x, n_y, dist = GetSurfaceNormal( x, y, 20, 8 )
	if( found ) then
		EntitySetTransform( entity_id, x + n_x*dist, y + n_y*dist )
		
		edit_component_ultimate( entity_id, "VelocityComponent", function(comp,vars)
			ComponentSetValueVector2( comp, "mVelocity", -n_x, -n_y)
		end)
	end
	
	-- GamePlaySound( "data/audio/Desktop/misc.bank", "misc/root_grow", pos_x, pos_y )

	EntitySetComponentsWithTagEnabled( entity_id, "grow", true )
else
	EntityKill( entity_id )
end