dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local kill_count = tonumber( StatsGetValue( "enemies_killed" ))
local kpf = kill_count - ( kill_memo or tonumber( StatsGetValue( "enemies_killed" )))
kill_memo = kill_count

if( kpf > 0 ) then
	local entity_id = GetUpdatedEntityID()
	local wand_id = EntityGetParent( entity_id )
	local hooman = get_wand_owner_old( wand_id )
	if(( EntityHasTag( wand_id, "wand" ) or EntityHasTag( wand, "custom_wand" )) and hooman ~= wand_id ) then
		local items = EntityGetAllChildren( get_hooman_child_old( hooman, "inventory_quick" )) or {}
		if( #items > 0 ) then
			for i,item_id in ipairs( items ) do
				local comp = EntityGetFirstComponentIncludingDisabled( item_id, "MaterialInventoryComponent" )
				if( comp ~= nil ) then
					local mtr = get_matter_old( ComponentGetValue2( comp, "count_per_material_type" ) or {})
					if( CellFactory_GetName( mtr[1] ) == "necro_inferno" or mtr[2] == 0 ) then
						AddMaterialInventoryMaterial( item_id, "necro_inferno", mtr[2] + kpf )
						break
					end
				end
			end
		end
	end
end