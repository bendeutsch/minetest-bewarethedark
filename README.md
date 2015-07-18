Beware the dark [bewarethedark]
=================

A Minetest mod where darkness simply kills you directly

Version: 0.1.0

License:
  Code: LGPL 2.1 (see included LICENSE file)

Report bugs or request help on the forum topic.

Description
-----------

This is a mod for MineTest. It's only function is to make
darkness and light a valid mechanic for the default minetest_game.
In other voxel games, darkness is dangerous because it spawns
monsters. In MineTest, darkness just makes it more likely for you
to walk into a tree.

This mod changes that in a very direct fashion: you are damaged
by darkness, the darker the damager. So craft those torches!

Current behavior
----------------

If you stand in a node with light level 7 or less, you slowly
get damaged. The darker it is, the more damage you get per second.

Future plans
------------

**Darkness meter**: similar to the standard air bar and drowning, add
a meter for light, or sanity, or something loreful. You only start
taking damage when the meter is depleted.

**Sunburn**: Suddenly, too much light can kill you too! Will need
a separate meter.

Dependencies
------------
None at the moment.

Installation
------------

Unzip the archive, rename the folder to to `bewarethedark` and
place it in minetest/mods/

(  Linux: If you have a linux system-wide installation place
    it in ~/.minetest/mods/.  )

(  If you only want this to be used in a single world, place
    the folder in worldmods/ in your worlddirectory.  )

For further information or help see:
http://wiki.minetest.com/wiki/Installing_Mods
