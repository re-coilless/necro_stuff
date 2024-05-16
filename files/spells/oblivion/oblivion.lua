dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local hooman = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( entity_id, "ProjectileComponent" ), "mWhoShot" )
if( hooman ~= nil ) then
	local children = EntityGetAllChildren( hooman ) or {}
	if( #children > 0 ) then
		local frame_num = GameGetFrameNum()
		local x, y = EntityGetTransform( entity_id )
		for i,child in ipairs( children ) do
			if( EntityHasTag( child, "dream_storage" )) then
				EntityRemoveFromParent( child )
				unpackage_entity( child, true )
				EntitySetTransform( child, x, y )
				
				edit_component_ultimate( child, "VelocityComponent", function(comp,vars) 
					local v_x, v_y = ComponentGetValue2( comp, "mVelocity" )
					local vel = math.sqrt( v_x^2 + v_y^2 )
					SetRandomSeed( frame_num, child + v_x + v_y )
					local v_angle = math.rad( Random( 0, 360 ))
					ComponentSetValueVector2( comp, "mVelocity", math.cos( v_angle )*vel, math.sin( v_angle )*vel )
				end)
				
				edit_component_ultimate( child, "ProjectileComponent", function(comp1,vars)
					edit_component_ultimate( child, "LifetimeComponent", function(comp2,vars) 
						ComponentSetValue2( comp2, "kill_frame", frame_num + ComponentGetValue2( comp1, "lifetime" ))
					end)
				end)
			end
		end
	end
end