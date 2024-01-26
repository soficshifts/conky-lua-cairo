--[[
MIT License

Copyright (c) 2024 JaySam

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--[[
	You'll need to set your package path to the full path if you plan
	to launch the conky automatically in a startup script which may
	not run in the current directory to ensure the dials.lua script is found.
]]
package.path = "./?.lua"
require'cairo'
require'dials'

-- Remember Ciaro Trigonometry is in Radians.
toRadians=math.pi/180

--[[ 
	Needles, these work for guages of radius 100, but can adjust them for larger.
	These were copied from Common.Needles in dials.lua as a convenience for you to experiment.
	(as Lua does not autoload libraries on change)
	The needle is centred on the x-axis, pointing right, this is 0 radians for cairo.

	For further description, you can check the comments in Common.Needles dials.lua script
]]
Needles = {
	--vectors contain number of points at first index, then the x or y co-ordinates
	Large = {
		x = {4, -10, 0, 102, 0},
		y = {4, 0, 6, 0, -6}
	},

	Medium = { 
		x = {4, -8, 0, 98, 0},
		y = {4, 0, 5, 0, -5}
	},

	Small = {
		x = {4, -6, 0, 94, 0},
		y = {4, 0, 4, 0, -4}
	},

	Tiny = {
		x = {4, -4, 0, 90, 0},
		y = {4, 0, 3, 0, -3}
	}
}

function conky_init(ctrx1, ctry1)
	if conky_window == nil then return end
end

-- Called from conky configuration.  Parameters are x,y co-ordinates for centre of dial.
function conky_cpu(ctrx1, ctry1)
	if conky_window == nil then return end
	alpha=0.4
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	cr = cairo_create(cs)
	--[[
		We will instatiate the dial with an override object.
		No need to set all the values, as new will check nils and set defaults
		Just remember no validation is done on your overrides, so you can break stuff

		See documentation on method in dials.lua on usage.
	]]
	local overrides = {maxNum = 100}
	local dial = RGBDial:new(overrides)

	-- We can now draw the dial. This adds the gradient, ticks and numbers.
	-- See the documentation on its usuage in dials.lua
	dial:draw(cr, ctrx1, ctry1)
	--get cpu values
	local cpu0 = conky_parse('${cpu cpu0}')
	local cpu1 = conky_parse('${cpu cpu1}')
	--[[ 
		place the hands on the dials. 
		You need to pass it needle vector co-ordinates.  
		It will calculate the angle of the needle.
		If the value is above/below limits, it will set them to the limit.
		You then pass the r, g, b color of the needle.
		The next parameter is how much to add to the colour values to create the shading (set to zero for no shading)
		last is the center of the circle.

		See the comments/doco in dials.lua for further info on usage.
	]]
	dial:placeHandOnDialShade(cr, Needles.Large.x, Needles.Large.y, tonumber(cpu0), 26/255,1,102/255, -50/255, ctrx1, ctry1)
	dial:placeHandOnDialShade(cr, Needles.Medium.x, Needles.Medium.y, tonumber(cpu1), 251/255,153/255,1, -60/255, ctrx1, ctry1)
	
	-- text is not supported in the dial library.  You'll have to add it manually.
	local extents = cairo_text_extents_t:create()
	cairo_select_font_face (cr, "Liberation Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	
	cairo_set_font_size (cr, 18)
	--cpu0
	local text =  "0:"..cpu0.."%"
	cairo_text_extents(cr, text, extents)
	xoffset = extents.width/2
	cairo_move_to (cr,ctrx1-xoffset,ctry1+68)
	cairo_set_source_rgba (cr,26/255,1,102/255,1)	
	cairo_show_text (cr, text)

	--cpu1
	local text =  "1:"..cpu1.."%"
	cairo_text_extents(cr, text, extents)
	xoffset = extents.width/2
	cairo_move_to (cr,ctrx1-xoffset,ctry1+85)
	cairo_set_source_rgba (cr,251/255,153/255,1,1)
	
	cairo_show_text (cr, text)

	-- End of output.  Exterminate!!! (a la Dalek)
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cairo_text_extents_t:destroy(extents)
	cr=nil
	return " "
end 

-- Parameters are x,y co-ordinates for centre of dial.
function conky_memory( ctrx1, ctry1)
	if conky_window == nil then return end
	alpha=0.4
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	cr = cairo_create(cs)
	-- Set the overrides, like RGBDial, the constructor will set missing values to defaults.
	local overrides = {
		baseColorHue = 0,
		baseColorSaturation = 74
		startVolume = 100
	}
	local dial = HSVDial:new(overrides)
	--Draw
	dial:draw(cr, ctrx1, ctry1)
	-- Get the memory value
	local mem = conky_parse("${memperc}")
	-- place the needle
	dial:placeHandOnDialShade(cr, Needles.Large.x, Needles.Large.y, tonumber(mem), 26/255,1,102/255, -50/255, ctrx1, ctry1)

	-- Add any further text yourself.
	local extents = cairo_text_extents_t:create()
	cairo_select_font_face (cr, "Liberation Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	
	cairo_set_font_size (cr, 18)
	local text = ""..mem.."%"
	cairo_text_extents(cr, text, extents)
	xoffset = extents.width/2
	cairo_move_to (cr,ctrx1-xoffset,ctry1+68)
	cairo_set_source_rgba (cr,26/255,1,102/255,1)
	cairo_show_text (cr, text)

	-- End of output.  Free up resources (otherwise serious memory leak)
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cairo_text_extents_t:destroy(extents)
	cr=nil
	return " "
end 

