--- === MouseBind ===
local MouseBind = {}


-- Metadata
MouseBind.name="MouseBind"
MouseBind.version="0.1"
MouseBind.author="Von Welch"
-- https://opensource.org/licenses/Apache-2.0
MouseBind.license="Apache-2.0"
MouseBind.homepage="https://github.com/von/MounseBind.spoon"


--- MouseBind:debug(enable)
--- Method
--- Enable or disable debugging
---
--- Parameters:
---  * enable - Boolean indicating whether debugging should be on
---
--- Returns:
---  * Nothing
function MouseBind:debug(enable)
  if enable then
    self.log.setLogLevel('debug')
    self.log.d("Debugging enabled")
  else
    self.log.d("Disabling debugging")
    self.log.setLogLevel('info')
  end
end

-- Methods
-- Spoon methods/variables/constants/etc. should use camelCase

--- MouseBind:init()
--- Method
--- Initializes a MouseBind
--- When a user calls hs.loadSpoon(), Hammerspoon will load and execute init.lua
--- from the relevant s.
--- Do generally not perform any work, map any hotkeys, start any timers/watchers/etc.
--- in the main scope of your init.lua. Instead, it should simply prepare an object
--- with methods to be used later, then return the object.
---
--- Parameters:
---  * None
---
--- Returns:
---  * MouseBind object

function MouseBind:init()
  -- Set up logger for spoon
  self.log = hs.logger.new("MouseBind")

  -- Path to this file itself
  -- See also http://www.hammerspoon.org/docs/hs.spoons.html#resourcePath
  self.path = hs.spoons.scriptPath()

  -- List of bindings
  self.bindings = {}

  -- MouseBinding class
  self.MouseBinding = dofile(self.path.."/MouseBinding.lua")

  return self
end

--start() and stop()
--If your Spoon provides some kind of background activity, e.g. timers, watchers,
--spotlight searches, etc. you should generally activate them in a :start()
--method, and de-activate them in a :stop() method

--- MouseBind:start()
--- Method
--- Start background activity.
---
--- Parameters:
---  * param - Some parameter
---
--- Returns:
---  * MouseBind object
function MouseBind:start()
  -- No-op
  return self
end

--- MouseBind:stop()
--- Method
--- Stop background activity.
---
--- Parameters:
---  * param - Some parameter
---
--- Returns:
---  * MouseBind object
function MouseBind:stop()
  hs.fnutils.map(self.bindings, function(b) b:disable() end)
  return self
end

--- MouseBind:createBinding()
--- Method
--- Create a new binding between a mouse event and an action. Returns a
--- MouseBinding object.
--- This is a wrapper around MouseBinding.new():enable()
---
--- Parameters:
---  * mods - A table or a string containing (as elements, or as substrings with any
---    separator) the keyboard modifiers required, which should be zero or more of the
---    following:
---      "cmd", "command" or "⌘"
---      "ctrl", "control" or "⌃"
---      "alt", "option" or "⌥"
---      "shift" or "⇧"
---  * typeName - A string containing the name of an event type, as described in
---    hs.eventtap.event.types
---  * message - A string containing a message to be displayed via hs.alert()
---    when the mouse event has been triggered; if nil, no alert will be shown
---    Note that unlike hs.hotkey, this parameter must be present.
---  * fn - A function that will be called when mouse event is detected.
---
--- Returns:
---  *  MouseBinding istance.
function MouseBind:createBinding(mods, typeName, message, fn)
  local b = self.MouseBinding.new(mods, typeName, message, fn)
  if b then
    table.insert(self.bindings, b)
    b:enable()
  end
  return b
end

return MouseBind
