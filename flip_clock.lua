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


function conky_clock(correctOffset)
	if conky_window == nil then return end
	local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, 45)
	cr = cairo_create(cs)
	--x co-ordinate to start - depends on font/size - 
	xoffset = 280
	fontheight =40
	colonoffset = 11
	
  	
	-- text
	cairo_select_font_face (cr, "Liberation Sans", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, 55)
	cairo_set_source_rgba (cr,26/255,1,26/255,1)
	
	seconds = os.date("%S")
	minutes = os.date("%M")
	mins = tonumber(minutes)
	hours = os.date("%H")
	hour = tonumber(hours)
	--0-6; 0=Sun
	day = tonumber(os.date("%w"))
	
	-- hack to get just the millis.
	tme = (socket.gettime()*1000)
	x = string.sub(""..tme,-5) 
    --the base y=40, height is 40 to 80, 1 sec = 40  pixels, we have millis
	basey=40
	y = basey - (tonumber(x)*0.04)
	
	--seconds
	secones = seconds % 10
	seconesnext = (secones+1) % 10
	cairo_move_to (cr,xoffset,y)
	cairo_show_text (cr, secones)
	cairo_move_to (cr,xoffset,y+fontheight)
	cairo_show_text (cr, seconesnext)
	--10secs 
	xoffset = xoffset - 30
	ymin=basey
	sectens = seconds //10
	if (secones==9) then
		sectensnext = (sectens + 1) % 6
		ymin=y
		cairo_move_to (cr,xoffset,ymin+fontheight)
		cairo_show_text (cr, sectensnext)
	end
	cairo_move_to (cr,xoffset,ymin)
	cairo_show_text (cr, sectens)
	--seconds colon
	xoffset = xoffset - colonoffset
	cairo_move_to (cr,xoffset,36)
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
    xoffset = xoffset - 29
	if (sectens == 5 and secones == 9 ) then
		minonesnext = (minones + 1) % 10
		ymin=y
		cairo_move_to (cr,xoffset,ymin+fontheight)
		cairo_show_text (cr, minonesnext)
	end
	cairo_move_to (cr,xoffset,ymin)
	cairo_show_text (cr, minones)
	
	--minute 10s
	xoffset = xoffset - 30
	if (minones == 9 and sectens == 5 and secones == 9) then
		mintensnext = (mintens + 1) % 6
		ymin10=y
		cairo_move_to (cr,xoffset,ymin+fontheight)
		cairo_show_text (cr, mintensnext)
	end
	
	cairo_move_to (cr,xoffset,ymin10)
	cairo_show_text (cr, mintens)
	--minute colon 
	xoffset = xoffset - colonoffset
	cairo_move_to (cr,xoffset,36)
	if (tonumber(seconds) % 2 ==0) then
		cairo_show_text (cr, ":")
	else 
		cairo_show_text (cr, "")
	end
	--hours (org x=40) now 40, colon moves it 11.
	xoffset = xoffset - 29
	yhr = basey
	hr1 = hour % 10
	hr10 = hour // 10
 	newDay = false
	if (minones == 9 and sectens == 5 and secones == 9 and mintens == 5) then
	--if (secones == 9) then
		hrnext = (hour + 1) % 24
		hr1next = hrnext % 10
		newDay = (hrnext==0)
		yhr=y
		cairo_move_to (cr,xoffset,yhr+fontheight)
		cairo_show_text (cr, hr1next)
	end
	cairo_move_to (cr,xoffset,yhr)
	cairo_show_text (cr, hr1)
	-- hr 10  )was x=10)
	xoffset = xoffset - 30
	if (minones == 9 and sectens == 5 and secones == 9 and mintens == 5 and ((hr1==9) or newDay)) then
	--if (secones == 9) then
		hrnext = (hour + 1) % 24
		hr10next = hrnext // 10
		yhr=y
		cairo_move_to (cr,xoffset,yhr+fontheight)
		cairo_show_text (cr, hr10next)
	end
	cairo_move_to (cr,xoffset,yhr)
	cairo_show_text (cr, hr10)
	
	--day of week	
	dayString = days[(day+1)]
	d=basey
	xoffset=0
	if (minones == 9 and sectens == 5 and secones == 9 and mintens == 5 and newDay) then
	--test onlyif (secones == 9) then
		nx = (day+2)
		if (nx==8) then nx=1 end
		tommorrow = days[nx]
		d=y		
		cairo_move_to (cr,xoffset,d+fontheight)
		cairo_show_text (cr, tommorrow)
	end
	
	cairo_move_to (cr,xoffset,d)
	--test on sunday.  tommorrow = days[((day+2)%7)]
	cairo_show_text (cr, dayString)
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
	cr=nil
    return " "
end 