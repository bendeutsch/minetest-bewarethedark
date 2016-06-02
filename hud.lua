--[[

HUD definitions for Beware the Dark

Optionally from one of the supported mods

Any hud needs to define the following functions:

- bewarethedark.hud_init(player)
  Initialize the HUD for a new player.

- bewarethedark.hud_update(player, value)
  Display the new value "value" for the given player. "value" is
  a floating point number, not necessarily bounded. You can use the
  "bewarethedark.hud_clamp(value)" function to get an integer between 0
  and 20.

]]

local M   = bewarethedark
local C   = M.config
local PPA = M.persistent_player_attributes

function M.hud_clamp(value)
    if value < 0 then
        return 0
    elseif value > 20 then
        return 20
    else
        return math.ceil(value)
    end
end

if minetest.get_modpath("hudbars") then
    hb.register_hudbar('sanity', 0x000000, "Sanity", {
        bar = 'bewarethedark_hudbars_bar.png',
        icon = 'bewarethedark_eye.png'
    }, 20, 20, false)
    function M.hud_init(player)
        hb.init_hudbar(player, 'sanity',
            M.hud_clamp(PPA.get_value(player, 'bewarethedark_sanity')),
        20, false)
    end
    function M.hud_update(player, value)
        hb.change_hudbar(player, 'sanity', M.hud_clamp(value), 20)
    end
elseif minetest.get_modpath("hud") then
    -- default positions follow [hud] defaults
    local position = HUD_SANITY_POS or { x=0.5, y=1 }
    local offset   = HUD_SANITY_OFFSET or { x=15, y=-133} -- above AIR
    hud.register('sanity', {
        hud_elem_type = "statbar",
        position = position,
        text = "bewarethedark_eye.png",
        background = "bewarethedark_eye_closed.png",
        number = 20,
        max = 20,
        size = HUD_SB_SIZE, -- by default { x=24, y=24 },
        offset = offset,
    })
    function M.hud_init(player)
        -- automatic by [hud]
    end
    function M.hud_update(player, value)
        hud.change_item(player, 'sanity', {
            number = M.hud_clamp(value)
        })
    end
else
    -- 'builtin' hud
    function M.hud_init(player)
        -- above breath bar, for now
        local name = player:get_player_name()
        M.players[name].hud_id = player:hud_add({
            hud_elem_type = "statbar",
            position = { x=0.5, y=1 },
            text = "bewarethedark_eye.png",
            number = M.hud_clamp(PPA.get_value(player, 'bewarethedark_sanity')),
            direction = 0,
            size = { x=24, y=24 },
            offset = { x=25, y=-(48+24+16+32)},
        })
    end
    function M.hud_update(player, value)
        local name = player:get_player_name()
        local hud_id = M.players[name].hud_id
        player:hud_change(hud_id, 'number', M.hud_clamp(value))
    end
end
