dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent( projectile_id, "ProjectileComponent" )
if( proj_comp ~= nil ) then
	ComponentSetValue2( proj_comp, "never_hit_player", true )
	
	local hooman = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( projectile_id, "ProjectileComponent" ), "mWhoShot" ) or 0
	if( hooman ~= 0 ) then
		local link = ComponentGetValue2( get_storage_old( EntityGetRootEntity( hooman ), "link" ), "value_int" )
		local anchor_id = 0
		local anchors = EntityGetWithTag( "behest_anchor" ) or {}
		if( #anchors > 0 ) then
			for i,anchor in ipairs( anchors ) do
				if( ComponentGetValue2( get_storage_old( anchor, "link" ), "value_int" ) == link ) then
					anchor_id = anchor
					break
				end
			end
		end
		if( anchor_id ~= 0 ) then
			local spell_id = EntityGetParent( anchor_id )
			local values = ComponentGetValue2( get_storage_old( spell_id, "extra_stuff" ), "value_string" ) or ""
			if( values ~= "" ) then
				for stuff in string.gmatch( values, "([^,]+)" ) do
					EntityLoadToEntity( stuff, projectile_id )
				end
			end
		end
	end
end