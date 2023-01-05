-- The core library must be loaded prior to anything else
local libPath = reaper.GetExtState("Scythe v3", "libPath")
if not libPath or libPath == "" then
    reaper.MB("Couldn't load the Scythe library. Please install 'Scythe library v3' from ReaPack, then run 'Script: Scythe_Set v3 library path.lua' in your Action List.", "Whoops!", 0)
    return
end

-- This line needs to use loadfile; anything afterward can be required
loadfile(libPath .. "scythe.lua")()
local GUI = require("gui.core")
local Tabs = require("gui.elements.Tabs")

------------------------------------
-------- Functions -----------------
------------------------------------

------------------------------------
-------- Window settings -----------
------------------------------------
local window = GUI.createWindow({
  name = "NSM Reascript Club",
  w = 600,
  h = 400,
})

layers = table.pack( GUI.createLayers(
  {name = "Layer1", z = 1},
  {name = "Layer2", z = 2},
  {name = "Layer3", z = 3},
  {name = "Layer4", z = 4},
  {name = "Layer5", z = 5}
))

window:addLayers(table.unpack(layers))

------------------------------------
-------- Global elements -----------
------------------------------------

layers[1]:addElements( GUI.createElements(
  {
    name = "tabs",
    type = "Tabs",
    x = 0,
    y = 0,
    w = 64,
    h = 20,
    tabs = {
      {
        label = "VOL",
        layers = {layers[3]}
      },
      {
        label = "SFX",
        layers = {layers[4]}
      }
    },
    pad = 16
  }
))

------------------------------------
-------- Tab 1 Elements ------------
------------------------------------

layers[2]:addElements( GUI.createElements(
  {
    name = "Up",
    type = "Button",
    x = 96,
    y = 32,
    w = 64,
    h = 20,
    caption = "Up",
    --func = toggleLabelFade,
  },
  {
    name = "Down",
    type = "Button",
    x = 96,
    y = 96,
    w = 64,
    h = 25,
    caption = "Down",
    --func = toggleLabelFade,
  },
  {
    name = "Up",
    type = "Button",
    x = 96,
    y = 32,
    w = 64,
    h = 25,
    caption = "Up",
    --func = toggleLabelFade,
  },
  {
    name = "MoveWithUp",
    type = "Button",
    x = 16,
    y = 64,
    w = 96,
    h = 25,
    caption = "MoveWithUp",
    --func = toggleLabelFade,
  },
  {
    name = "Move",
    type = "Button",
    x = 144,
    y = 64,
    w = 96,
    h = 25,
    caption = "Move",
    --func = toggleLabelFade,
  },
  {
    name = "GoToTrack",
    type = "Textbox",
    caption = "Go To Track:",
    x = 80,
    y = 144,
    w = 144,
  },
  {
    name = "Go",
    type = "Button",
    x = 240,
    y = 144,
    w = 96,
    h = 23,
    caption = "Go",
    --func = toggleLabelFade,
  },
  {
    name = "ShowAllTracks",
    type = "Button",
    x = 360,
    y = 48,
    w = 96,
    h = 64,
    caption = "Show All Tracks",
    --func = toggleLabelFade,
  },
  {
    name = "SetMetaData",
    type = "Textbox",
    caption = "Set MetaData:",
    x = 80,
    y = 180,
    w = 144,
  },
  {
    name = "Go",
    type = "Button",
    x = 240,
    y = 144,
    w = 96,
    h = 23,
    caption = "Go",
    --func = toggleLabelFade,
  }
))

--button.func = function() reaper.ShowMessageBox("You clicked the button!", "Yay!", 0) end
--volLayer:addElements(GoToTrackbutton)

window:open()
GUI.Main()

