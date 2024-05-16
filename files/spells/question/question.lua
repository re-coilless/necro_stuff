dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local x, y = EntityGetTransform( GetUpdatedEntityID())
local meat = EntityGetWithTag( "enemy" ) or {}
if( #meat > 0 ) then
	local stuff = EntityGetClosestWithTag( x, y, "necro_stuff" )
	if( stuff ~= nil ) then
		local storage_necro = get_storage_old( stuff, "necro_current" )
		for i,deadman in ipairs( meat ) do
			ComponentSetValue2( storage_necro, "value_float", ComponentGetValue2( storage_necro, "value_float" ) + get_necro_current( deadman )*0.1 )
			
			EntityRemoveTag( deadman, "enemy" )
			
			for i,ai_comp in ipairs( ai_comps ) do
				local comp_ids = EntityGetComponentIncludingDisabled( deadman, ai_comp ) or {}
				if( #comp_ids > 0 ) then
					for i,comp in ipairs( comp_ids ) do
						EntityRemoveComponent( deadman, comp )
					end
				end
			end
			
			local luas = EntityGetComponentIncludingDisabled( deadman, "LuaComponent" ) or {}
			if( #luas > 0 ) then
				for i,comp in ipairs( luas ) do
					EntityRemoveComponent( deadman, comp )
				end
			end
		end
	end
end