local effect_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( effect_id )
EntityLoad( "mods/necro_stuff/files/spells/heresy/heretic.xml", x, y )
EntityKill( effect_id )