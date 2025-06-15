dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity_id = GetUpdatedEntityID()
local hooman = GameGetWorldStateEntity()
if( hooman ~= nil ) then
	local children = EntityGetAllChildren( hooman ) or {}
	if( #children > 0 ) then
		local tormented = {}
		for i,child in ipairs( children ) do
			if( EntityHasTag( child, "torment_storage" )) then
				table.insert( tormented, child )
			end
		end
		
		SetRandomSeed( GameGetFrameNum(), hooman + entity_id + #tormented )
		local penitent_one = tormented[Random( 1, #tormented )]
		local x, y = EntityGetTransform( entity_id )
		EntityRemoveFromParent( penitent_one )
		unpackage_entity( penitent_one, true )
		EntitySetTransform( penitent_one, x, y )
		
		edit_component_ultimate( penitent_one, "GenomeDataComponent", function(comp,vars) 
			ComponentSetValue2( comp, "herd_id", StringToHerdId( "player" ))
		end)
		
		--the longer they spend in torment, the higher buffs are gonna be
		--maybe custom projectiles with a random chance of applying
		
		if( Random( 1, 5 ) == 1 ) then
			EntityAddChild( penitent_one, EntityLoad( "mods/necro_stuff/files/spells/penance/penitent_".."1"..".xml", x, y ))
			
			if( Random( 1, 10 ) == 1 ) then
				--add custom shot modifier
			end
		end
	end
end