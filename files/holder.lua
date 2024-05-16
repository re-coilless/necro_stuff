dofile_once( "mods/necro_stuff/files/generic_lib.lua" )

local entity = GetUpdatedEntityID()
local parent = EntityGetParent( entity )

local this_x = get_storage_old( entity, "this_x" )
local this_y = get_storage_old( entity, "this_y" )
local last_x = get_storage_old( entity, "last_x" )
local last_y = get_storage_old( entity, "last_y" )

local x, y = EntityGetTransform( parent )
local this_x_num = ComponentGetValue2( this_x, "value_float" )
local this_y_num = ComponentGetValue2( this_y, "value_float" )

ComponentSetValue2( last_x, "value_float", this_x_num )
ComponentSetValue2( last_y, "value_float", this_y_num )
ComponentSetValue2( this_x, "value_float", x )
ComponentSetValue2( this_y, "value_float", y )

local c_x, c_y = EntityGetTransform( entity )
EntitySetTransform( entity, c_x + x - this_x_num, c_y + y - this_y_num )
EntityApplyTransform( entity, c_x + x - this_x_num, c_y + y - this_y_num )