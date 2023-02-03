MusicUtil = require "musicutil"
scale_names = {}
notes = {}
note_count = 24
position = math.floor(note_count/2)
engine.name = 'PolyPerc'

function init()
  message = "mikhail"
  screen_dirty = true
  redraw_clock_id = clock.run(redraw_clock)
  
  for i = 1, #MusicUtil.SCALES do
    table.insert(scale_names, string.lower(MusicUtil.SCALES[i].name))
  end

  params:add{type = "number", id = "note_delta", name = "note_delta",
    min = 1, max = 5, default = 1}
  
  params:add{type = "number", id = "root_note", name = "root note",
    min = 0, max = 127, default = 60, formatter = function(param) return MusicUtil.note_num_to_name(param:get(), true) end,
    action = function() build_scale() end}
  
  params:add{type = "option", id = "scale_mode", name = "scale mode",
    options = scale_names, default = 5,
    action = function() build_scale() end}
  
  build_scale()
end

function build_scale()
  notes = MusicUtil.generate_scale_of_length(params:get("root_note"), params:get("scale_mode"), note_count)
  local num_to_add = note_count - #notes
  for i = 1, num_to_add do
    table.insert(notes, notes[16 - num_to_add])
  end
end

function enc(e, d)
  if e == 1 then 
    params:delta("note_delta", d) 
    turn(e, params:get("note_delta")) 
  end 
  if e == 2 then turn(e, d) end 
  if e == 3 then turn(e, d) end 
  screen_dirty = true
end

function turn(e, d)
  message = "encoder " .. e .. ", delta " .. d
end

function key(k, z)
  local note_delta = params:get("note_delta")
  if z == 0 then return end
  if k == 2 then 
    press_down(-note_delta) 
  end
  if k == 3 then 
    press_down(note_delta) 
  end
  screen_dirty = true
end

function press_down(i)
  
  position = position + i
  if position < 1 then
    position = #notes
  end
  if position > #notes then
    position = 1
  end

  local active_note = notes[position]
  local freq = MusicUtil.note_num_to_freq(active_note)
  engine.hz(freq)
  local note_name = MusicUtil.note_num_to_name(active_note)
  message = note_name
end

function redraw_clock()
  while true do
    clock.sleep(1/15)
    if screen_dirty then
      redraw()
      screen_dirty = false
    end
  end
end

function redraw()
  screen.clear()
  screen.aa(1)
  screen.font_face(1)
  screen.font_size(8)
  screen.level(15)
  screen.move(64, 32)
  screen.text_center(message)
  screen.pixel(0, 0)
  screen.pixel(127, 0)
  screen.pixel(127, 63)
  screen.pixel(0, 63)
  screen.fill()
  screen.update()
end

function r()
  norns.script.load(norns.state.script)
end

function cleanup()
  clock.cancel(redraw_clock_id)
end