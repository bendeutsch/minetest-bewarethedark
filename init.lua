--[[

Beware the Dark [bewarethedark]
==========================

A mod where darkness simply kills you outright.

Copyright (C) 2015 Ben Deutsch <ben@bendeutsch.de>

License
-------

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
USA

]]


bewarethedark = {

    -- configuration
    config = {
        tick_time = 0.5,
        damage_for_light = {
            [15] = -1.0,
            [14] = -0.5,
            [13] = -0.2,
            [12] = 0,
            [11] = 0,
            [10] = 0,
            [ 9] = 0,
            [ 8] = 0,
            [ 7] = 0.1,
            [ 6] = 0.2,
            [ 5] = 0.3,
            [ 4] = 0.4,
            [ 3] = 0.5,
            [ 2] = 0.6,
            [ 1] = 0.8,
            [ 0] = 1.0,
        },
    },

    -- per-player-stash (not persistent)
    players = {
        --[[
        name = {
            pending_dmg = 0.0,
        }
        ]]
    },

    -- global things
    time_next_tick = 0.0,
}
local M = bewarethedark
local C = bewarethedark.config

dofile(minetest.get_modpath('bewarethedark')..'/persistent_player_attributes.lua')
local PPA = persistent_player_attributes

PPA.register({
    name = 'bewarethedark_sanity',
    min  = 0,
    max  = 20,
    default = 20,
})

function bewarethedark.hud_clamp(value)
    if value < 0 then
        return 0
    elseif value > 20 then
        return 20
    else
        return math.ceil(value)
    end
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local pl = M.players[name]
    local inv = player:get_inventory()
    if not pl then
        M.players[name] = { pending_dmg = 0.0 }
        pl = M.players[name]
        pl.hud_id = player:hud_add({
            hud_elem_type = "statbar",
            position = { x=0.5, y=1 },
            text = "bewarethedark_eye.png",
            number = 20,
            direction = 0,
            size = { x=24, y=24 },
            offset = { x=25, y=-(48+24+16+32)},
        })
    end
end)

minetest.register_globalstep(function(dtime)

    M.time_next_tick = M.time_next_tick - dtime
    while M.time_next_tick < 0.0 do
        M.time_next_tick = M.time_next_tick + C.tick_time
        for _,player in ipairs(minetest.get_connected_players()) do
            local name = player:get_player_name()
            local pl = M.players[name]
            local pos  = player:getpos()
            local pos_y = pos.y
            -- the middle of the block with the player's head
            pos.y = math.floor(pos_y) + 1.5
            local node = minetest.get_node(pos)

            local light_now   = minetest.get_node_light(pos) or 0
            if node.name == 'ignore' then
                -- can happen while world loads, set to something innocent
                light_now = 9
            end

            local dps = C.damage_for_light[light_now]
            --print("Standing in " .. node.name .. " at light " .. light_now .. " taking " .. dps);

            if dps ~= 0 then
                local sanity = PPA.get_value(player, "bewarethedark_sanity")

                sanity = sanity - dps
                --print("New sanity "..sanity)
                if sanity < 0.0 and minetest.setting_getbool("enable_damage") then
                    pl.pending_dmg = pl.pending_dmg - sanity
                    sanity = 0.0

                    if pl.pending_dmg > 0.0 then
                        local dmg = math.floor(pl.pending_dmg)
                        --print("Deals "..dmg.." damage!")
                        pl.pending_dmg = pl.pending_dmg - dmg
                        player:set_hp( player:get_hp() - dmg )
                    end
                end

                PPA.set_value(player, "bewarethedark_sanity", sanity)

                player:hud_change(pl.hud_id, 'number', bewarethedark.hud_clamp(sanity))
            end
        end
    end
end)
