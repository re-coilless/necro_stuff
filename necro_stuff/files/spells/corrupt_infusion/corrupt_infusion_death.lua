function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
	local x, y = EntityGetTransform( GetUpdatedEntityID())
	EntityLoad( "mods/necro_stuff/files/spells/corrupt_infusion/power_upper.xml", x, y )
end