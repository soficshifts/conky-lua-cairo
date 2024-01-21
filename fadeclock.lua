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

days={"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}

function fadeNumber(cr, x, y, current, nxt, r, g, b, alpha)
	cairo_move_to (cr,x,y)
	fade = 1 - alpha
	appear = 0 + alpha
	cairo_set_source_rgba (cr,r,g,b,fade)
	cairo_show_text (cr, current)
	cairo_set_source_rgba (cr,r,g,b,appear)
	cairo_move_to (cr,x,y)
	cairo_show_text (cr, nxt)
	--reset alpha
	cairo_set_source_rgba (cr, r,g,b,1)
end

function clock(cr, correctOffset, city, r, g, b)
	
	--x co-ordinate to start - depends on font/size - 
	xoffset = 330
	fontheight =40
	colonoffset = 7
	charoffset = 15
	
	-- text
	--cairo_select_font_face (cr, "Liberation Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_select_font_face (cr, "Liberation Serif", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, 30)
	cairo_set_source_rgba (cr,r,g,b,1)
	
	seconds = os.date("%S")
	minutes = os.date("%M")
	mins = tonumber(minutes)
	hours = os.date("%H")
	hour = tonumber(hours)
	--0-6; 0=Sun
	day = tonumber(os.date("%w"))

	isdst = os.date("*t")["isdst"]
	
	-- hack to get just the millis.  use -6 for 0-9 seconds plus millis
	tme = (socket.gettime()*1000)
	x = string.sub(""..tme,-6) 
    --the base y=40, height is 40 to 80, 1 sec = 40  pixels, we have millis
	basey=correctOffset+40
	
	--seconds
	secones = seconds % 10
	seconesnext = (secones+1) % 10
	--alpha fades over 5000millis from 5000-10000 millis: 55,56...59,0
	alpha = (tonumber(x)/5000)-1
	-- for testing
	--fadeNumber(cr, xoffset, basey, secones, seconesnext, alpha)
	--10secs 
	--xoffset = xoffset - charoffset	
	ymin=basey
	sectens = seconds //10
    --minutes
	minones = mins % 10
	mintens = mins // 10
	ymin = basey
	ymin10 = basey
	if (sectens == 5 and secones > 4 ) then
		minonesnext = (minones + 1) % 10
		fadeNumber(cr, xoffset, ymin, minones, minonesnext, r, g, b, alpha)
	else
		cairo_move_to (cr,xoffset,ymin)
		cairo_show_text (cr, minones)
	end
	
	--minute 10s
	xoffset = xoffset - charoffset
	if (minones == 9 and sectens == 5 and secones > 4) then
		mintensnext = (mintens + 1) % 6
		ymin10=y
		fadeNumber(cr,xoffset,ymin, mintens, mintensnext, r, g, b, alpha)
	else
		cairo_move_to (cr,xoffset,ymin10)
		cairo_show_text (cr, mintens)
	end
	
	--minute colon 
	xoffset = xoffset - colonoffset
	cairo_move_to (cr,xoffset,ymin-2)
	if (tonumber(seconds) % 2 ==0) then
		cairo_show_text (cr, ":")
	else 
		cairo_show_text (cr, "")
	end
	--hours (org x=40) now 40, colon moves it 11.
	xoffset = xoffset - charoffset
	yhr = basey
	hr1 = hour % 10
	hr10 = hour // 10
 	newDay = false
	if (minones == 9 and sectens == 5 and secones > 4 and mintens == 5) then
	--if (secones == 9) then
		hrnext = (hour + 1) % 24
		hr1next = hrnext % 10
		newDay = (hrnext==0)
		fadeNumber(cr, xoffset, yhr, hr1, hr1next, r, g, b, alpha)
	else
		cairo_move_to (cr,xoffset,yhr)
		cairo_show_text (cr, hr1)	
	end
	
	-- hr 10  )was x=10)
	xoffset = xoffset - charoffset
	if (minones == 9 and sectens == 5 and secones > 4 and mintens == 5 and ((hr1==9) or newDay)) then
	--if (secones == 9) then
		hrnext = (hour + 1) % 24
		hr10next = hrnext // 10
		fadeNumber(cr, xoffset, yhr, hr10, hr10next, r, g, b, alpha)
	else
		cairo_move_to (cr,xoffset,yhr)
		cairo_show_text (cr, hr10)
	end
	
	
	--day of week	
	dayString = days[(day+1)]
	d=basey
	xoffset=xoffset - (charoffset*4)
	if (minones == 9 and sectens == 5 and secones > 4 and mintens == 5 and newDay) then
	--test onlyif (secones == 9) then
		nx = (day+2)
		if (nx==8) then nx=1 end
		tommorrow = days[nx]
		fadeNumber(cr, xoffset, d, dayString, tommorrow, r, g, b, alpha)
	else
		cairo_move_to (cr,xoffset,d)
		cairo_show_text (cr, dayString)	
	end

	--city
	xoffset=0
	cairo_move_to (cr,xoffset,d)
	if (isdst) then
		city = city.." ☼"
	end	
	cairo_show_text (cr, city)
	
	
	--test draw rectangle
	--x,y,w,h
	--cairo_rectangle(cr, 0, 45, 310, 45);
	--cairo_set_source_rgba (cr,0,0,0,1)
  	--cairo_stroke_preserve(cr);
  	--cairo_fill(cr);
	-- End of output
	--[[cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil]]
    return " "
end 

--r,g,b in 0-255
function conky_tz(tz, city, ymin, r, g, b)
	if conky_window == nil then return end
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	cr = cairo_create(cs)
	--call back to conky to set the timezone for the time call later.
	x = conky_parse('${tztime '..tz..' %H:%M:%S}')
	clock(cr, ymin, city, r/255, g/255, b/255)
  	
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil
    return " "
	
end