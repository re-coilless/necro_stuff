local effect_id = GetUpdatedEntityID()
local hooman = EntityGetRootEntity( effect_id )

local lua_comp = EntityGetFirstComponentIncludingDisabled( hooman, "LuaComponent", "corrupt_infusion" )
if( lua_comp == nil ) then
	EntityAddComponent( hooman, "LuaComponent", 
	{
		_tags = "corrupt_infusion",
		script_death = "mods/necro_stuff/files/spells/corrupt_infusion/corrupt_infusion_death.lua",
		execute_every_n_frame = "-1",
	})
end

EntityKill( effect_id )