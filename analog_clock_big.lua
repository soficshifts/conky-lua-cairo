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
require'cairo'
socket = require'socket'

--vectors contain number of points, then x or y co-ordinates
vec24hrx = {4, -10, 0, 70, 0}
vec24hry = {4, 0, 5, 0, -5}

vechrx = {4, 110, 120, 180, 120}
vechry = {4, 0, 5, 0, -5} 

vecminx = {4, 120, 130, 220, 130}
vecminy = {4, 0, 5, 0, -5} 

vecsecx = {4, 190, 200, 230, 200}
vecsecy = {4, 0, 5, 0, -5} 

function conky_init(ctrx1, ctry1)
	if conky_window == nil then return end
end

function conky_clock(ctrx, ctry)
	if conky_window == nil then return end
	--RGB values for colour
	r_green=26/255
	g_green=1
	b_green=102/255

	r_blue=0
	g_blue=102/255
	b_blue=1

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	cr = cairo_create(cs)
	-- diamter, we have a 500x500 window.
	p_len=240
	-- base transparancy
	alpha=0.4
	--outer clock
	clock_dial(cr, p_len, alpha, ctrx, ctry, false)

	--inner clock
	clock_dial(cr, (p_len/3), alpha, ctrx, ctry, true)

	--time
	seconds = os.date("%S")
	minutes = os.date("%M")
	mins = tonumber(minutes)
	hours = os.date("%H")
	h = tonumber(hours)

	--hands
	hr12 = h % 12
	if (hr12==0) then hr12 = 12 end

	rad=math.pi/180
	-- hack to get just the millis.  use -6 for 0-9 seconds plus millis
	tme = (socket.gettime()*1000)
	x = string.sub(""..tme,-5)
	inMillis = tonumber(seconds)*1000 + tonumber(x) 
	thetaseconds = ((inMillis*0.006))*rad-math.pi/2

	thetamins = ((mins*6))*rad-math.pi/2.04 + thetaseconds/60
	
	thetahrs = ((hr12*30))*rad-math.pi/2.16 + thetamins/12

	--theta24hrs = ((h*15 + (m*6)/24)-90)*rad 
	theta24hrs = ((h*15)*rad)-math.pi/2.08 + thetamins/24
	
	cairo_set_line_width (cr,1)
	
	cairo_set_source_rgba (cr,r_green,g_green,b_green,alpha)
	placeHandOnClock(cr, vechrx, vechry, thetahrs, ctrx, ctry)
	placeHandOnClock(cr, vecminx, vecminy, thetamins, ctrx, ctry)
	placeHandOnClock(cr, vecsecx, vecsecy, thetaseconds, ctrx, ctry)
	--lines
	basex = ctrx+p_len/3+6 --add 3 for the 24hr clock frame.
	basey = ctry
	cairo_set_line_width (cr,3)
	placeLineOnClock(cr, basex, basey, ctrx+vechrx[2], thetahrs, ctrx, ctry)
	placeLineOnClock(cr, basex, basey, ctrx+vecminx[2], thetamins, ctrx, ctry)
	placeLineOnClock(cr, basex, basey, ctrx+vecsecx[2], thetaseconds, ctrx, ctry)
	
	--24 hr clock
	cairo_set_line_width (cr,1)
	cairo_set_source_rgba (cr,r_blue,g_blue,b_blue,alpha)
	placeHandOnClock(cr, vec24hrx, vec24hry, theta24hrs, ctrx, ctry)

	--end of output
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil
	return " "
	
end

function placeLineOnClock(cr, x, y, xoffset, angle, ctrx, ctry)
	cairo_set_line_width (cr,3)
	sin = math.sin(angle)
	cos = math.cos(angle)
	xy=rotateTrig(x, y, ctrx, ctry, sin, cos)
	cairo_move_to (cr,xy[0], xy[1])
	xy=rotateTrig(xoffset, y, ctrx, ctry, sin, cos)
	cairo_line_to (cr, xy[0], xy[1])
	cairo_stroke(cr)
	
end

function conky_clock_test(ctrx, ctry, h, m, s)
	if conky_window == nil then return end
	--RGB values for colour
	r_green=26/255
	g_greem=1
	b_green=102/255

	r_blue=0
	g_blue=102/255
	b_blue=1

	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	cr = cairo_create(cs)
	-- diamter, we have a 500x500 window.
	p_len=240
	-- base transparancy
	alpha=0.4
	--outer clock
	clock_dial(cr, p_len, alpha, ctrx, ctry, false)

	--inner clock
	clock_dial(cr, (p_len/3), alpha, ctrx, ctry, true)
	--hands
	hr12 = h % 12
	if (hr12==0) then hr12 = 12 end

	rad=math.pi/180
	thetaseconds = ((s*6))*rad-math.pi/2

	thetamins = ((m*6))*rad-math.pi/2.04 + thetaseconds/60
	
	thetahrs = ((hr12*30))*rad-math.pi/2.16 + thetamins/12

	--theta24hrs = ((h*15 + (m*6)/24)-90)*rad 
	theta24hrs = ((h*15)*rad)-math.pi/2.08 + thetamins/24

	cairo_set_line_width (cr,1)
	cairo_set_source_rgba (cr,0,102/255,1,alpha)
	placeHandOnClock(cr, vec24hrx, vec24hry, theta24hrs, ctrx, ctry)
	placeHandOnClock(cr, vechrx, vechry, thetahrs, ctrx, ctry)
	placeHandOnClock(cr, vecminx, vecminy, thetamins, ctrx, ctry)
	placeHandOnClock(cr, vecsecx, vecsecy, thetaseconds, ctrx, ctry)


	--end of output
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil
	return " "
	
end

function placeHandOnClock(cr, vecx, vecy, angle, ctrx, ctry)
	sin = math.sin(angle)
	cos = math.cos(angle)
	
	
	--not the safest, assumes vecx, vecy are equal
	for i=2,(vecx[1]+1) do
		xy=rotateTrig(ctrx+vecx[i], ctry+vecy[i], ctrx, ctry, sin, cos)
		if (i==2) then
			cairo_move_to (cr,xy[0], xy[1])
			--cairo_move_to (cr,vecx[i], vecy[i])
		else
			cairo_line_to (cr, xy[0], xy[1])
			--cairo_line_to (cr,vecx[i], vecy[i])
		end
	end
	--cairo_stroke(cr)
	cairo_close_path (cr)
	cairo_stroke_preserve (cr) 
	cairo_fill(cr)
end

function rotateTrig(x, y, ctrx, ctry, sin, cos)
	xy = {}
	xy[0] = (cos * (x - ctrx)) - (sin * (y-ctry)) + ctrx
	xy[1] = (sin * (x - ctrx)) + (cos * (y-ctry)) + ctry
	return xy
end



function clock_dial(cr, p_len, alpha, ctrx1, ctry1, is24hr) 
	--font
	cairo_select_font_face (cr, "Liberation Serif", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	--colour of fill circle
	cairo_set_source_rgba (cr,0,102/255,1,0.2)
	-- circle is 7 pixels wider
	offset=7
	cairo_arc (cr,ctrx1,ctry1,(p_len+offset),0,(2*math.pi))
	cairo_fill (cr)
	--three pixel line
	cairo_set_line_width (cr,3)
	--setup the clock hours circles will start at "3 oclock"
	local currentHr=3
	local modulus=12
	local hradvance=1
	local width = 2
	local longline=15
	--Need a color arc, increase alpha
	if (is24hr) then
		cairo_set_source_rgba (cr,r_green,g_green,b_green,1.5*alpha)
		cairo_set_font_size (cr, 12)
		currentHr = 6
		modulus = 24
		hradvance = 2
		width = 1
		longline=7
	else
		cairo_set_source_rgba (cr,r_blue,g_blue,b_blue,2*alpha)
		cairo_set_font_size (cr, 36)	
	end
	-- three pixel circle
	cairo_arc (cr,ctrx1,ctry1,p_len+7,0.0, 2*math.pi)
	cairo_stroke(cr)
	--Start line strokes, 60 minutes
	cairo_set_line_width (cr,1)
	cairo_set_line_cap (cr,CAIRO_LINE_CAP_ROUND)
	xy={}
	for i=0,60 do
		
		--radians
		angle=i*2*math.pi/60
		-- edge of line is diamter of clock, inner clock smaller line.
		linestart = p_len
		linewidth = width
		
		if ((i % 5) == 0)then
			--tick an hour or two.
			linestart=linestart-longline
			linewidth=2*width
			currentHr = currentHr % modulus
			if (currentHr==0 and not is24hr) then 
				currentHr = 12 
			end
			xy=toPolar(linestart,angle, ctrx1, ctry1)
			place_number(cr, ""..currentHr, xy[0], xy[1], angle) 
			currentHr = currentHr+hradvance
		else
			xy=toPolar(linestart,angle, ctrx1, ctry1)
		end
		--draw tick
		cairo_set_line_width (cr,linewidth) 
		xval0=xy[0]
		yval0=xy[1]
		xy=toPolar((p_len+offset), angle, ctrx1, ctry1)
		xval1=xy[0]--ctrx1 + ((p_len+offset) * (math.cos (angle)))
		yval1=xy[1]--ctry1 + ((p_len+offset) * (math.sin (angle)))
		cairo_move_to (cr, xval0,yval0)
		cairo_line_to (cr, xval1, yval1)
		cairo_stroke (cr) 
	end
end

function place_number(cr, number, x, y, angle)
	--
	--placement (0,0) of text box is bottom right
	local extents = cairo_text_extents_t:create()
	--move to the place at 3 o'clock to set the start point.
	cairo_move_to (cr,0,0)
	cairo_text_extents(cr, number, extents)
	--place number

	xm = math.cos(angle)
	ym= math.sin(angle)


	cairo_set_line_width(cr,0)
	--place number; 
	--Hacky
	xoffset = x-(extents.width+5)*(1+xm)/2 +3*(1-ym)/2
	yoffset = y-((extents.height)*(ym-1)/2) - 13*(ym)/2

	cairo_move_to(cr, xoffset, yoffset)
	cairo_show_text(cr, ""..number)
	cairo_text_extents_t:destroy(extents)
end


function rotate(x, y, ctrx, ctry, angle)
	cosradian = math.cos(angle)
	sinradian = math.sin(angle)
	xy = {}
	xy[0] = (cosradian * (x - ctrx)) - (sinradian * (y-ctry)) + ctrx
	xy[1] = (sinradian * (x - ctrx)) + (cosradian * (y-ctry)) + ctry
	return xy
end

function toPolar(start, angle, ctrx, ctry)
	cos=math.cos (angle)
	sin=math.sin (angle)
	local xy={}
	xy[0]=ctrx + (start * cos)
	xy[1]=ctry + (start * sin)
	return xy
end
