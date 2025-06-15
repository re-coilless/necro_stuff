dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local effect_id = GetUpdatedEntityID()
local entity_id = EntityGetRootEntity( effect_id )
local hooman = GameGetWorldStateEntity()
if( hooman ~= nil and is_sentient( entity_id ) and not( EntityHasTag( entity_id, "player_unit" ))) then
	local dmg_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "DamageModelComponent" )
	local hp = ComponentGetValue2( dmg_comp, "hp" )/ComponentGetValue2( dmg_comp, "max_hp" )
	if( hp < 0.5 ) then
		local k = 10^6
		local chance = math.abs( math.min(( 101.56 - 0.0131 )/( 1 + ( math.abs( get_necro_current( entity_id ))/2.9758 )^3.8133 ), 100 ))*k
		SetRandomSeed( GameGetFrameNum(), hooman + entity_id + hp*250 )
		if( Random( 1, 100*k ) <= chance ) then
			package_entity( entity_id, true )
			EntityAddTag( entity_id, "torment_storage" )
			if( EntityGetFirstComponentIncludingDisabled( entity_id, "InheritTransformComponent" ) == nil ) then
				EntitySetComponentIsEnabled( entity_id, EntityAddComponent( entity_id, "InheritTransformComponent",
				{
					_tags="enabled_in_inventory,enabled_in_world,enabled_in_hand",
				}), true )
			end
			EntityAddChild( hooman, entity_id )
		end
	end
end
EntityKill( effect_id )