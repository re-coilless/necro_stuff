dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local hooman = ComponentGetValue2( EntityGetFirstComponentIncludingDisabled( projectile_id, "ProjectileComponent" ), "mWhoShot" )
local x, y = EntityGetTransform( projectile_id )
local angle = math.rad( 36 )
for i = 1,10 do
	shoot_projectile_ultimate( hooman, "mods/necro_stuff/files/spells/wrath/wrath_ray.xml", x, y, math.cos( angle*i )*4000, math.sin( angle*i )*4000, true )
end