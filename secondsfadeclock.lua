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

function fadeNumber(cr, x, y, current, nxt, alpha)
	cairo_move_to (cr,x,y)
	fade = 1 - alpha
	appear = 0 + alpha
	cairo_set_source_rgba (cr,26/255,1,26/255,fade)
	cairo_show_text (cr, current)
	cairo_set_source_rgba (cr,26/255,1,26/255,appear)
	cairo_move_to (cr,x,y)
	cairo_show_text (cr, nxt)
	--reset alpha
	cairo_set_source_rgba (cr,26/255,1,26/255,1)
end

function clock(cr, correctOffset, city)
	
	--x co-ordinate to start - depends on font/size - 
	xoffset = 340
	fontheight =40
	colonoffset = 7
	charoffset = 15
	
  	
	-- text
	cairo_select_font_face (cr, "Liberation Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, 30)
	cairo_set_source_rgba (cr,26/255,1,26/255,1)
	
	seconds = os.date("%S")
	minutes = os.date("%M")
	mins = tonumber(minutes)
	hours = os.date("%H")
	hour = tonumber(hours)
	--0-6; 0=Sun
	day = tonumber(os.date("%w"))

	isdst = os.date("*t")["isdst"]
	
	-- hack to get just the millis.
	tme = (socket.gettime()*1000)
	x = string.sub(""..tme,-5) 
	--the base y=40, height is 40 to 80, 1 sec = 40  pixels, we have millis
	basey=correctOffset+40
	--y = basey - (tonumber(x)*0.04)
	
	--seconds
	secones = seconds % 10
	seconesnext = (secones+1) % 10
	alpha = (tonumber(x)/1000)
	fadeNumber(cr, xoffset, basey, secones, seconesnext, alpha)
	--10secs 
	
	xoffset = xoffset - charoffset
	ymin=basey
	sectens = seconds //10
	if (secones==9) then
		sectensnext = (sectens + 1) % 6
		fadeNumber(cr, xoffset, ymin, sectens, sectensnext, alpha)
	else
		cairo_move_to (cr,xoffset,ymin)
		cairo_show_text (cr, sectens)
	end
	
	--seconds colon
	xoffset = xoffset - colonoffset
	--yoffset-4 was 36
	cairo_move_to (cr,xoffset,ymin)
	if (tonumber(seconds) % 2 ==0) then
		cairo_show_text (cr, ":")
	else 
		cairo_show_text (cr, "")
	end
	--minutes
	minones = mins % 10
	mintens = mins // 10
	ymin = basey
	ymin10 = basey
	-- x moves 40, but the colon has moved 11 (11+29)
	xoffset = xoffset - charoffset
	if (sectens == 5 and secones == 9 ) then
		minonesnext = (minones + 1) % 10
		fadeNumber(cr, xoffset, ymin, minones, minonesnext, alpha)
	else
		cairo_move_to (cr,xoffset,ymin)
		cairo_show_text (cr, minones)
	end
	
	--minute 10s
	xoffset = xoffset - charoffset
	if (minones == 9 and sectens == 5 and secones == 9) then
		mintensnext = (mintens + 1) % 6
		ymin10=y
		fadeNumber(cr,xoffset,ymin, mintens, mintensnext, alpha)
	else
		cairo_move_to (cr,xoffset,ymin10)
		cairo_show_text (cr, mintens)
	end
	
	
	--minute colon 
	xoffset = xoffset - colonoffset
	cairo_move_to (cr,xoffset,ymin)
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
	if (minones == 9 and sectens == 5 and secones == 9 and mintens == 5) then
	--if (secones == 9) then
		hrnext = (hour + 1) % 24
		hr1next = hrnext % 10
		newDay = (hrnext==0)
		fadeNumber(cr, xoffset, yhr, hr1, hr1next, alpha)
	else
		cairo_move_to (cr,xoffset,yhr)
		cairo_show_text (cr, hr1)	
	end
	
	-- hr 10  )was x=10)
	xoffset = xoffset - charoffset
	if (minones == 9 and sectens == 5 and secones == 9 and mintens == 5 and ((hr1==9) or newDay)) then
	--if (secones == 9) then
		hrnext = (hour + 1) % 24
		hr10next = hrnext // 10
		fadeNumber(cr, xoffset, yhr, hr10, hr10next, alpha)
	else
		cairo_move_to (cr,xoffset,yhr)
		cairo_show_text (cr, hr10)
	end
	
	
	--day of week	
	dayString = days[(day+1)]
	d=basey
	xoffset=xoffset - (charoffset*4)
	if (minones == 9 and sectens == 5 and secones == 9 and mintens == 5 and newDay) then
	--test onlyif (secones == 9) then
		nx = (day+2)
		if (nx==8) then nx=1 end
		tommorrow = days[nx]
		fadeNumber(cr, xoffset, d, dayString, tommorrow, alpha)
	else
		cairo_move_to (cr,xoffset,d)
		cairo_show_text (cr, dayString)	
	end

	--city
	xoffset=0
	cairo_move_to (cr,xoffset,d)
	if (isdst) then
		city = "☼"..city
	end	
	cairo_show_text (cr, city)

	return " "
end 

function conky_tz(tz, city, ymin)
	if conky_window == nil then return end
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
	cr = cairo_create(cs)
	--x co-ordinate to start - depends on font/size - 
	xoffset = 280
	fontheight =40
	colonoffset = 11
	--ymin=100
	-- This just sets the time to the correct timzone for the instance, we don't use the value.
	x = conky_parse('${tztime '..tz..' %H:%M:%S}')
	clock(cr, ymin, city)
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil
	return " "
	
end