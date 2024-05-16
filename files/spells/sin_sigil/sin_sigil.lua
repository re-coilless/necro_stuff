local effect_id = GetUpdatedEntityID()
EntityAddTag( EntityGetRootEntity( effect_id ), "sigil_of_sin" )
EntityKill( effect_id )