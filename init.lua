local players = {}
local model_types = {
	{ "bench", "bench.obj", "Bench", 0.5, 0.05 },
	{ "chair", "chair.obj", "Chair", 0.0, 0.05 },
	{ "table", "table.obj", "Table", 0.0, 0.00 },
	{ "side_table", "side_table.obj", "Side Table", 0.0, 0.00 },
}
local frame_types = {
	{ "standard", "bench_side.png", "default:steel_ingot" },
	{ "patina", "bench_side_patina.png", "default:copper_ingot" },
}
local wood_types = {
	{ "wood", "Apple Wood", "default_wood.png", "default:wood" },
	{ "junglewood", "Jungle Wood", "default_junglewood.png", "default:junglewood" },
	{ "pine", "Pine Wood", "default_pine_wood.png", "default:pine_wood" },
	{ "aspen", "Aspen Wood", "default_aspen_wood.png", "default:aspen_wood" },
}
for _, model in ipairs(model_types) do
	local m_folder = model[1]
	local m_file = model[2]
	local m_name = model[3]
	local x_offset = model[4]
	local y_height = model[5]
	for _, frame in ipairs(frame_types) do
		local f_suffix = frame[1]
		local f_tex = frame[2]
		local side_metal = frame[3]
		for _, wood in ipairs(wood_types) do
			local w_suffix = wood[1]
			local w_desc = wood[2]
			local w_tex = wood[3]
			local slat_wood = wood[4]
			local suffix = f_suffix .. "_" .. w_suffix
			local node_id = "bench_n_stuff:" .. m_folder .. "_" .. suffix
			local title = w_desc .. " " .. m_name .. " (" .. f_suffix:sub(1,1):upper() .. f_suffix:sub(2) .. ")"
			local boxes = {}
						if m_folder == "bench" then
				boxes = {
					{ -3/2, -3/4, -3/16, -11/8, 3/8, 1/2 }, -- Left Side Frame
					{ 3/8, -3/4, -3/16, 1/2, 3/8, 1/2 },    -- Right Side Frame
					{ -11/8, -1/16, -1/16, 3/8, 0, 13/32 }, -- Seat Slats
					{ -11/8, 1/16, 7/16, 3/8, 9/16, 1/2 },  -- Backrest Slats
				}
			elseif m_folder == "chair" then
				boxes = {
					{ -9/16, -3/4, -3/16, -7/16, 3/8, 1/2 }, -- Left Side Frame
					{ 7/16, -3/4, -3/16, 9/16, 3/8, 1/2 },   -- Right Side Frame
					{ -7/16, -1/16, -1/16, 7/16, 0, 13/32 }, -- Seat Slats
					{ -7/16, 1/16, 7/16, 7/16, 9/16, 1/2 },  -- Backrest Slats
				}
			elseif m_folder == "table" then
				boxes = {
					{ -1/2, -1/2, -1/2, 1/2, 1/4, 1/2 }
				}
			elseif m_folder == "side_table" then
				boxes = {
					{ -5/16, -1/2, -5/16, 5/16, 1/4, 5/16 }
				}
			end
			local click_func = nil
			if m_folder ~= "table" and m_folder ~= "side_table" then
				click_func = function(pos, node, clicker, itemstack, pointed_thing)
					if not clicker or not clicker:is_player() then return end
					local name = clicker:get_player_name()
					local meta = minetest.get_meta(pos)
					local occupant = meta:get_string("occupant")
					if occupant == name then
						pos.y = pos.y + 0.5
						clicker:set_pos(pos)
						clicker:set_eye_offset({x=0, y=0, z=0}, {x=0, y=0, z=0})
						if minetest.get_modpath("player_api") then
							player_api.set_animation(clicker, "stand")
							player_api.player_attached[name] = false
						end
						if players[name] then
							clicker:set_physics_override({speed=players[name].speed, jump=players[name].jump})
							players[name] = nil
						end
						meta:set_string("occupant", "")
					elseif occupant == "" then
						clicker:set_eye_offset({x=0, y=-3, z=2}, {x=0, y=0, z=0})
						local dir = node.param2 % 4
						local p_pos = { x = pos.x, y = pos.y + y_height, z = pos.z }
						if m_folder == "bench" then
							if dir == 0 then
								p_pos.z = p_pos.z + 0.30
								p_pos.x = p_pos.x - x_offset
								clicker:set_look_horizontal(3.15)
							elseif dir == 1 then
								p_pos.x = p_pos.x + 0.30
								p_pos.z = p_pos.z + 0.5
								clicker:set_look_horizontal(7.9)
							elseif dir == 2 then
								p_pos.z = p_pos.z - 0.30
								p_pos.x = p_pos.x + 0.5
								clicker:set_look_horizontal(6.28)
							elseif dir == 3 then
								p_pos.x = p_pos.x - 0.30
								p_pos.z = p_pos.z - 0.5
								clicker:set_look_horizontal(4.75)
							end
						else
							if dir == 0 then
								p_pos.z = p_pos.z + 0.30
								clicker:set_look_horizontal(3.15)
							elseif dir == 1 then
								p_pos.x = p_pos.x + 0.30
								clicker:set_look_horizontal(7.9)
							elseif dir == 2 then
								p_pos.z = p_pos.z - 0.30
								clicker:set_look_horizontal(6.28)
							elseif dir == 3 then
								p_pos.x = p_pos.x - 0.30
								clicker:set_look_horizontal(4.75)
							end
						end
						clicker:set_pos(p_pos)
						meta:set_string("occupant", name)
						players[name] = clicker:get_physics_override()
						clicker:set_physics_override({speed=0, jump=0})
						if minetest.get_modpath("player_api") then
							player_api.player_attached[name] = true
							minetest.after(0.2, function()
								local p = minetest.get_player_by_name(name)
								if p and minetest.get_meta(pos):get_string("occupant") == name then
									player_api.set_animation(p, "sit")
								end
							end)
						end
					end
				end
			end
			minetest.register_node(node_id, {
				description = title,
				drawtype = "mesh",
				mesh = m_file,
				tiles = { f_tex, w_tex },
				use_texture_alpha = "blend",
				paramtype = "light",
				paramtype2 = "facedir",
				is_ground_content = false,
				groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
				sounds = default.node_sound_wood_defaults(),
				selection_box = { type = "fixed", fixed = boxes },
				collision_box = { type = "fixed", fixed = boxes },
				on_rightclick = click_func,
				on_rotate = minetest.get_modpath("screwdriver") and screwdriver.rotate_simple or nil,
			})
			local recipe_layout = {}
			if m_folder == "bench" then
				recipe_layout = {
					{slat_wood, slat_wood, slat_wood},
					{side_metal, "", side_metal},
					{side_metal, "", side_metal},
				}
			elseif m_folder == "chair" then
				recipe_layout = {
					{slat_wood, ""},
					{side_metal, side_metal},
				}
			elseif m_folder == "table" then
				recipe_layout = {
					{slat_wood, slat_wood, slat_wood},
					{side_metal, side_metal, side_metal},
					{side_metal, "", side_metal},
				}
			elseif m_folder == "side_table" then
				recipe_layout = {
					{slat_wood, slat_wood, ""},
					{side_metal, side_metal, ""},
				}
			end

			minetest.register_craft({
				output = node_id,
				recipe = recipe_layout
			})
		end
	end
end
