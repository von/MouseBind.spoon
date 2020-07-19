--- === MouseBinding ===

local MouseBinding = {}

-- Failed table lookups on the instances should fallback to the class table, to get methods
MouseBinding.__index = MouseBinding

-- Calls to MouseBinding() return MouseBinding.new()
setmetatable(MouseBinding, {
  __call = function (cls, ...)
    return cls.new(...)
  end,
})

-- Set up logger
MouseBinding.log = hs.logger.new("MouseBinding")

--- MouseBinding.new()
--- Function
--- Create a new binding between a mouse event and an action. Returns a
--- MouseBinding object. Note that the enable() method must be called before
--- it is effective.
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
---    It can optionally return two values. Firstly, a boolean, true if the event
---    should be deleted, false if it should propagate to any other applications
---    watching for that event. Secondly, a table of events to post.
---
--- Returns: MouseBinding instance, or nil on error.
function MouseBinding.new(mods, typeName, message, fn)
  MouseBinding.log.d("new() called")
  local self = setmetatable({}, MouseBinding)
  self.log = MouseBinding.log
  self.mods = mods
  self.type = hs.eventtap.event.types[typeName]
  if not self.type then
    self.log.ef("Unrecognized type \"%s\"", typeName)
    return nil
  end
  self.message = message
  if not fn then
    self.log.e("Callback function is nil")
    return nil
  end
  self.fn = fn
  self.callback = function(event)
    local flags = event:getFlags()
    local type = event:getType()
    local retval = true  -- delete event, false == propagate it
    self.log.df("Got event %s", hs.eventtap.event.types[type])
    if not flags:containExactly(self.mods) then
      return false  -- No match. Propagate event
    end
    -- Match
    if self.message then
      hs.alert(self.message)
    end
    result, errormsg = pcall(function() retval = self.fn(event) end)
    if not result then
      self.log.ef("Error executing mouse binding: " .. errormsg)
      hs.alert.show("Error executing mouse binding. Disabling.")
      -- Disable ourselves so we're not disabling UI
      self:disable()
      return true  -- Delete event
    end
    self.log.df("retval: %s", tostring(retval))
    return retval, {event}
  end
  self.tap = hs.eventtap.new({self.type}, self.callback)
  return self
end

--- MouseBinding:disable()
--- Method
--- Disable the binding.
---
--- Parameters:
--- * None
---
--- Returns:
--- * The Mousebinding instance.
function MouseBinding:disable()
  self.log.d("disable() called")
  self.tap:stop()
  return self
end

--- MouseBinding:enable()
--- Method
--- Enable the binding.
---
--- Parameters:
--- * None
---
--- Returns:
--- * The Mousebinding instance.
function MouseBinding:enable()
  self.log.d("enable() called")
  self.tap:start()
  return self
end

return MouseBinding
