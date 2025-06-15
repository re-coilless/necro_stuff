dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local player_id = EntityGetRootEntity( entity_id )

if( player_id ~= entity_id ) then
	local lua_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "LuaComponent", "eater" )
	if( lua_comp ~= nil ) then
		local timing = ComponentGetValue2( lua_comp, "execute_every_n_frame" )
		if( timing == 1 ) then
			local x, y = EntityGetTransform( entity_id )
			local projectiles = EntityGetInRadiusWithTag( x, y, 100, "projectile" ) or {}
			if( #projectiles > 0 ) then
				local projectile_id = 0
				for i,v in ipairs( projectiles ) do
					if( v == EntityGetRootEntity( v )) then
						local comp = EntityGetFirstComponent( v, "ProjectileComponent" )
						if( comp ~= nil ) then
							local who = EntityGetRootEntity( ComponentGetValue2( comp, "mWhoShot" ))
							if( who ~= player_id and not( EntityHasTag( who, "necro_brain" )) and not( EntityHasTag( who, "abomination" ))) then
								projectile_id = v
								break
							end
						end
					end
				end
				
				if( projectile_id ~= 0 ) then
					local proj_comp = EntityGetComponent( projectile_id, "ProjectileComponent" ) or {}
					local p_x, p_y = EntityGetTransform( projectile_id )
					if( #proj_comp > 0 ) then
						for j,comp_id in ipairs( proj_comp ) do
							ComponentSetValue2( comp_id, "on_death_explode", false )
							ComponentSetValue2( comp_id, "on_lifetime_out_explode", false )
						end
					end
					
					local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
					if( stuff ~= nil ) then
						local storage_mana = get_storage_old( stuff, "mana_current" )
						local mana_current = ComponentGetValue2( storage_mana, "value_float" )
						ComponentSetValue2( storage_mana, "value_float", mana_current + math.min( get_proj_threat( player_id, projectile_id ), 4^( string.len( tostring( math.floor( mana_current - 1 ))))))
						
						EntityLoad( "mods/necro_stuff/files/spells/meatchunk/poof.xml", p_x, p_y )
						new_connector( entity_id, p_x, p_y, "magic_liquid_mana_regeneration" )
						EntityAddChild( entity_id, new_connector( player_id, x, y, "magic_liquid_mana_regeneration" ))
					end
					EntityKill( projectile_id )
					
					ComponentSetValue2( lua_comp, "execute_every_n_frame", 66 )
				end
			end
		else
			ComponentSetValue2( lua_comp, "execute_every_n_frame", 1 )
		end
	end
end