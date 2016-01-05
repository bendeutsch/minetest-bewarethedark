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

    -- configuration in bewarethedark.default.conf

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

dofile(minetest.get_modpath('bewarethedark')..'/configuration.lua')
local C = M.config

dofile(minetest.get_modpath('bewarethedark')..'/persistent_player_attributes.lua')
local PPA = M.persistent_player_attributes

dofile(minetest.get_modpath('bewarethedark')..'/hud.lua')

PPA.register({
    name = 'bewarethedark_sanity',
    min  = 0,
    max  = 20,
    default = 20,
})

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local pl = M.players[name]
    if not pl then
        M.players[name] = { pending_dmg = 0.0 }
        pl = M.players[name]
        M.hud_init(player)
    end
end)

minetest.register_on_respawnplayer(function(player)
    local name = player:get_player_name()
    local pl = M.players[name]
    pl.pending_dmg = 0.0
    local sanity = 20
    PPA.set_value(player, "bewarethedark_sanity", sanity)
    M.hud_update(player, sanity)
end)

minetest.register_globalstep(function(dtime)

    M.time_next_tick = M.time_next_tick - dtime
    while M.time_next_tick < 0.0 do
        M.time_next_tick = M.time_next_tick + C.tick_time
        for _,player in ipairs(minetest.get_connected_players()) do

            if player:get_hp() <= 0 then
                -- dead players don't fear the dark
                break
            end

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

            local sanity = PPA.get_value(player, "bewarethedark_sanity")
            local overflow_factor = 1.0

            local dps = C.damage_for_light[light_now] * C.tick_time
            --print("Standing in " .. node.name .. " at light " .. light_now .. " taking " .. dps);

            if dps ~= 0 then

                sanity = sanity - dps
                --print("New sanity "..sanity)
                if sanity < 0.0 and minetest.setting_getbool("enable_damage") then
                    -- how much of this tick is hp damage?
                    overflow_factor = (0.0 - sanity) / dps
                    sanity = 0.0
                end

                PPA.set_value(player, "bewarethedark_sanity", sanity)

                M.hud_update(player, sanity)
            end

            -- if insane, hp damage applies
            if sanity <= 0.0 then
                -- dps for HP potentially other than for sanity
                dps = (C.insane_damage_for_light[light_now] or C.damage_for_light[light_now]) * C.tick_time * overflow_factor
                if dps < 0.0 then dps = 0.0 end

                pl.pending_dmg = pl.pending_dmg + dps

                if pl.pending_dmg > 0.0 then
                    local dmg = math.floor(pl.pending_dmg)
                    --print("Deals "..dmg.." damage!")
                    pl.pending_dmg = pl.pending_dmg - dmg
                    player:set_hp( player:get_hp() - dmg )
                end
            end
        end
    end
end)
