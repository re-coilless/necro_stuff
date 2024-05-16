dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local hooman = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( projectile_id, "ProjectileComponent" ), "mWhoShot" )
if( hooman ~= nil ) then
	package_entity( projectile_id, true )
	EntityAddTag( projectile_id, "dream_storage" )
	if( EntityGetFirstComponentIncludingDisabled( projectile_id, "InheritTransformComponent" ) == nil ) then
		EntitySetComponentIsEnabled( projectile_id, EntityAddComponent( projectile_id, "InheritTransformComponent",
		{
			_tags="enabled_in_inventory,enabled_in_world,enabled_in_hand",
		}), true )
	end
	EntityAddChild( hooman, projectile_id )
end