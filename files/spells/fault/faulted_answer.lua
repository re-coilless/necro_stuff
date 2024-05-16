dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local projectile_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( projectile_id )

local frame_num = GameGetFrameNum()
local abyss_comp = EntityGetFirstComponentIncludingDisabled( projectile_id, "BlackHoleComponent", "abyss" )
ComponentSetValue2( abyss_comp, "radius", 15 + frame_num%10 )
ComponentSetValue2( abyss_comp, "particle_attractor_force", 666 - 100*frame_num%10 )