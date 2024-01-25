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
require 'cairo'

--declare an object with properties of the dial.

RGBDial = {radius = 100,
    -- lenght of tick
    tickLength = 10,
    tickWidth = 3,
    -- Font face for text stops
    fontFace = "Liberation Serif",
    -- Font size for text stops
    fontSize = 18,
    -- Width of the arc
    lineWidth = 14,
    -- alpha parameter
    alpha = 0.4,
    -- largest number for the dial (integer)
    maxNum = 50,
	-- smallest number on the dial (integer)
	minNum = 0,
    -- colour of background with alpha transparancy
    backgroundrgba = {0,0,0,0.3},
    -- 11 stops supported for 10 text stops, red, green, blue values for each stop
    redStops =  {0,0, 0, 0, 76/255, 230/255, 187/255, 1, 1, 204/255, 128/255},
    greenStops = {51/255, 134/255, 179/255, 179/255, 230/255, 230/255, 153/255, 153/255, 102/255, 0, 0},
    blueStops = {153/55, 179/255, 179/255, 0, 0, 0, 0, 51/255, 0, 0, 0 },
    -- hard stops or gradient
    useGradientStops = true    
}

--[[
	Creates a new RGBDial object.  
	o = table of overrides (optional).  If not provided the defaults are used.
	Any missing attribute from o will be replaced with defaults.

	returns: the RGBDial object.
]]
function RGBDial:new (o)
	-- Set any missed attributes to defaults.
	if (o ~= nil) then
		if (o.tickLength == nil) then o.tickLength=RGBDial.tickLength end
		if (o.tickWidth == nil) then o.tickWidth=RGBDial.tickWidth end
		if (o.radius == nil) then o.radius=RGBDial.radius end
		if (o.fontFace == nil) then o.fontFace=RGBDial.fontFace end
		if (o.fontSize == nil) then o.fontSize=RGBDial.fontSize end
		if (o.lineWidth == nil) then o.lineWidth=RGBDial.lineWidth end
		if (o.alpha == nil) then o.alpha=RGBDial.alpha end
		if (o.maxNum == nil) then o.maxNum=RGBDial.maxNum end
		if (o.minNum == nil) then o.minNum=RGBDial.minNum end
		if (o.bacgroundrdba == nil) then o.backgroundrgba=RGBDial.backgroundrgba end
		if (o.redStops == nil) then o.redStops=RGBDial.redStops end
		if (o.greenStops == nil) then o.greenStops=RGBDial.greenStops end
		if (o.blueStops==nil) then o.blueStops=RGBDial.blueStops end
		if (o.useGradientStops==nil) then o.useGradientStops=RGBDial.useGradientStops end
	end
	-- create object if user does not provide one
    o = o or RGBDial
    setmetatable(o, self)
    self.__index = self
    --Cairo uses radians
    self.radianConversion = math.pi/180
    return o
end

--[[
	Draws the dial with the line, stops (ticks) and places the numbers for each tick.

	It is hard-coded to 10 stops based on the max and min values provided.

	cr = cairo drawing object.
	ctrx1 = window x co-ordinate for the centre of the dial.
	ctry1 = window y co-ordinate for the centre of the dial.

	Returns: nil

	Call this once the dial has been created.
]]
function RGBDial:draw(cr, ctrx1, ctry1) 
    -- Start of output
    -- Set fonts, lines etc.
    cairo_select_font_face (cr, self.fontFace, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size (cr, self.fontSize)
    cairo_set_line_width (cr,self.lineWidth)
	--background
	cairo_set_source_rgba (cr,self.backgroundrgba[1],self.backgroundrgba[2],self.backgroundrgba[3], self.backgroundrgba[4])
    -- make background slighly bigger
    local backgroundRadiusIncrement = 7
	cairo_arc (cr,ctrx1,ctry1,self.radius + backgroundRadiusIncrement,0,(2*math.pi))
	cairo_fill (cr)
	-- line gradient.  Initial colour
	--now the loop from -225 to 75 degrees (270deg) each gradient is 27 degrees 10 times
	
	local arcStart = -225 *self.radianConversion
	--tick(cr, p_len, arcStart, ctrx1, ctry1, reds[11],greens[11],blues[11],1)
	local tickIncrement = math.floor(self.maxNum / 10)
	for i=0,9 do
		
		--the arc
		cairo_set_line_width (cr,self.lineWidth)
		local arcEnd = (27*(i+1)-225)*radianConversion
        if (self.useGradientStops) then
		    self:drawArc(arcStart, arcEnd,ctrx1, ctry1, self.redStops[i+1], self.redStops[i+2], self.greenStops[i+1], self.greenStops[i+2], self.blueStops[i+1], self.blueStops[i+2], self.alpha*2)
        else
            --no gradient, keep colour same
            self:drawArc(arcStart, arcEnd,ctrx1, ctry1, self.redStops[i+1], self.redStops[i+1], self.greenStops[i+1], self.greenStops[i+1], self.blueStops[i+1], self.blueStops[i+1], self.alpha*2)
        end 
		arcStart = arcEnd
	end
   
	--Ticks done separately due to cr issues
	arcStart = -225 * self.radianConversion
	cairo_set_line_width (cr,1)
	for i=0,9 do
        Common.tick(cr, self.radius, self.tickLength, self.tickWidth, arcStart, ctrx1, ctry1, self.redStops[i+1],self.greenStops[i+1],self.blueStops[i+1],1.0, i*tickIncrement)
		local arcEnd = (27*(i+1)-225)*self.radianConversion	
		arcStart = arcEnd
        --print("tick")
	end
	--end tick
	Common.tick(cr,self.radius,self.tickLength,self.tickWidth,arcStart,ctrx1,ctry1,self.redStops[11],self.greenStops[11],self.blueStops[11],1.0,self.maxNum)
end


--[[
	Utility function to draw the arc with gradient.
]]
function RGBDial:drawArc(arcStart, arcEnd, ctrx, ctry, r1, r2, g1, g2, b1, b2, alpha) 
	--Slope
	sloper = (r2-r1)/10
	slopeg = (g2-g1)/10
	slopeb = (b2-b1)/10
	tarcStart = arcStart
	arcIncrement = (arcEnd - arcStart)/10
	--radianConversion = math.pi/180
	for i=0,9 do
		red = r1 + (sloper*i)
		green = g1 + (slopeg*i)
		blue = b1 + (slopeb*i)
		tarcEnd = (((i+1)*arcIncrement)+arcStart)
		cairo_set_source_rgba (cr,red, green, blue ,alpha)
		cairo_arc (cr,ctrx,ctry,self.radius,tarcStart,tarcEnd)
		cairo_stroke (cr)
		tarcStart = tarcEnd
	end
		
end

--[[
	This function will place the needle or hand on the dial to point at the number provided.
	
	cr = Cairo drawing object.
	vecx = Needle x-coordinates. You can use for example Common.Needle.Large.x
	vecy = Needle y-coordinates. You can use for example Common.Needle.Large.y
	r = red value [0..1] for needle colour
	g = green value [0..1] for needle colour
	b = blue value [0..1] for needle colour
	offset = amount to add to the r, g, b colour to create shading.  Use zero for no shading.  Negative for darker
		No checking if you go <0 or >1 so be careful
	ctrx = x-coordinate for centre of dial
	ctry = y-coordinate for centre of dial

	Returns: nil

]]
function RGBDial:placeHandOnDialShade(cr, vecx, vecy, value, r, g, b, offset, ctrx, ctry)
    return Common.placeHandOnDialShade(cr, vecx, vecy, value, r, g, b, offset, ctrx, ctry, self.maxNum, self.minNum)
end

-- END CLASS RGBDIal.

-- Class HSVDial.
-- Default values.
HSVDial = {radius = 100,
    -- lenght of tick
    tickLength = 10,
    tickWidth = 3,
    -- Font face for text stops
    fontFace = "Liberation Serif",
    -- Font size for text stops
    fontSize = 18,
    -- Width of the arc
    lineWidth = 14,
    -- alpha parameter
    alpha = 0.4,
    -- largest number for the dial
    maxNum = 100,
    --smallest number for the dial
    minNum = 0,
    -- colour of background with alpha transparancy
    backgroundrgba = {0,0,0,0.3},
    --base colour to use for the darkest colour at end of dial, hue and saturation.  Volume is calculated.
    baseColorHue = 220,
    baseColorSaturation = 100,
    startVolume = 82
    
}

--[[
	Creates a new HSVDial object.  
	o = table of overrides (optional).  If not provided the defaults are used.
	Any missing attribute from o will be replaced with defaults.

	returns: the HSVDial object.
]]
function HSVDial:new(o)
	-- Set any missed attributes to defaults.
	if (o ~= nil) then
		if (o.tickLength == nil) then o.tickLength=HSVDial.tickLength end
		if (o.tickWidth == nil) then o.tickWidth=HSVDial.tickWidth end
		if (o.radius == nil) then o.radius=HSVDial.radius end
		if (o.fontFace == nil) then o.fontFace=HSVDial.fontFace end
		if (o.fontSize == nil) then o.fontSize=HSVDial.fontSize end
		if (o.lineWidth == nil) then o.lineWidth=HSVDial.lineWidth end
		if (o.alpha == nil) then o.alpha=HSVDial.alpha end
		if (o.maxNum == nil) then o.maxNum=HSVDial.maxNum end
		if (o.bacgroundrdba == nil) then o.backgroundrgba=HSVDial.backgroundrgba end
		if (o.baseColorHue == nil) then o.baseColorHue=HSVDial.baseColorHue end
		if (o.baseColorSaturation == nil) then o.baseColorSaturation=HSVDial.baseColorSaturation end
		if (o.startVolume==nil) then o.startVolume=HSVDial.startVolume end
	end
	-- create object if user does not provide one
    o = o or HSVDial    
    setmetatable(o, self)
    self.__index = self
    --Cairo uses radians
    self.radianConversion = math.pi/180
    return o
end

--[[
	Draws the dial with the line, stops (ticks) and places the numbers for each tick.

	It is hard-coded to 10 stops based on the max and min values provided.

	cr = cairo drawing object.
	ctrx1 = window x co-ordinate for the centre of the dial.
	ctry1 = window y co-ordinate for the centre of the dial.

	Returns: nil

	Call this once the dial has been created.
]]
function HSVDial:draw(cr, ctrx1, ctry1)
	-- setup the dial numbers.
	-- background
	cairo_select_font_face (cr, self.fontFace, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
	cairo_set_font_size (cr, self.fontSize)
	cairo_set_line_width (cr,self.lineWidth)
	cairo_set_source_rgba (cr,self.backgroundrgba[1], self.backgroundrgba[2], self.backgroundrgba[3], self.backgroundrgba[4])
    local offset = 7
	cairo_arc (cr,ctrx1,ctry1,self.radius + offset,0,(2*math.pi))
	cairo_fill (cr)
	--gradient arch 270 degrees at 10degrees each starting at -225 degrees.
	local arcStart = -225 * radianConversion
	local volume = 0
	local arcEnd = 0
	for i=0,26 do
		volume = self.startVolume-(2*i)
		Common.setRGBFromHSV(cr, self.baseColorHue, self.baseColorSaturation, volume, alpha*2)		
		arcEnd = (10*(i+1)-225)*radianConversion
		cairo_arc (cr,ctrx1,ctry1,self.radius,arcStart,arcEnd)
		cairo_stroke (cr)
		arcStart = arcEnd
	end

	--Ticks done separately due to 27 divisions vs 10
	arcStart = -225 * self.radianConversion
	local tickIncrement = math.floor((self.maxNum-self.minNum) / 10)
	for i=0,9 do
		volume = self.startVolume-(i/9*50)
		Common.setRGBFromHSV(cr, self.baseColorHue, self.baseColorSaturation, volume, alpha*2)
		Common.tick(cr, self.radius, self.tickLength, self.tickWidth, arcStart, ctrx1, ctry1, nil,nil,nil,nil,self.minNum + i*tickIncrement)
		arcEnd = (27*(i+1)-225)*self.radianConversion	
		arcStart = arcEnd
	end
	volume = self.startVolume-(10/9*50)
	Common.setRGBFromHSV(cr, self.baseColorHue, self.baseColorSaturation, volume, alpha*2)
	Common.tick(cr, self.radius, self.tickLength, self.tickWidth, arcEnd, ctrx1, ctry1, nil, nil, nil, nil, self.maxNum)
end

--[[
	This function will place the needle or hand on the dial to point at the number provided.
	
	cr = Cairo drawing object.
	vecx = Needle x-coordinates. You can use for example Common.Needle.Large.x
	vecy = Needle y-coordinates. You can use for example Common.Needle.Large.y
	r = red value [0..1] for needle colour
	g = green value [0..1] for needle colour
	b = blue value [0..1] for needle colour
	offset = amount to add to the r, g, b colour to create shading.  Use zero for no shading.  Negative for darker
		No checking if you go <0 or >1 so be careful
	ctrx = x-coordinate for centre of dial
	ctry = y-coordinate for centre of dial

	Returns: nil

]]
function HSVDial:placeHandOnDialShade(cr, vecx, vecy, value, r, g, b, offset, ctrx, ctry)
    return  Common.placeHandOnDialShade(cr, vecx, vecy, value, r, g, b, offset, ctrx, ctry, self.maxNum, self.minNum)
end

----- END HSVDial Object.

-- Shared Functions
Common = {
    --[[ 
		Needles, these work for guages of radius 100, but can adjust them for larger.
		The needle is centred on the x-axis, pointing right, this is 0 radians for cairo.

		You can experiment with other shapes.  
	]]
    Needles = {
        --[[
			vectors contain number of points, then x or y co-ordinates.
			The Large needle is defined at (x,y) co-ordinates {(-10,0) , (0,6), (102, 0), (0, -6)}

			We draw the needles starting at the first point drawing a between each successive point.
			We then close the loop by drawing a line from the last point to the first point.
			
			The needle can then be filled.
		]]
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
    },
	radianConversion =  math.pi/180
}

-- Uses an explicit angle to place the hand
function Common.placeHandOnDialShadeAngle(cr, vecx, vecy, angle, r, g, b, offset, ctrx, ctry)
	sin = math.sin(angle)
	cos = math.cos(angle)
	
	cairo_set_source_rgba (cr,r,g,b,1)
	--not the safest, assumes vecx, vecy are equal
	for i=2,(vecx[1]) do
		xy=Common.rotate(ctrx+vecx[i], ctry+vecy[i], ctrx, ctry, sin, cos)
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
	--10less
	cairo_set_source_rgba (cr,r+offset,g+offset,b+offset,1)
	for i=2,(vecx[1]+1) do
		xy=Common.rotate(ctrx+vecx[i], ctry+vecy[i], ctrx, ctry, sin, cos)
		if (i==2) then
			cairo_move_to (cr,xy[0], xy[1])
			--cairo_move_to (cr,vecx[i], vecy[i])
		elseif (i~=3) then
			cairo_line_to (cr, xy[0], xy[1])
			--cairo_line_to (cr,vecx[i], vecy[i])
		end
	end
	--cairo_stroke(cr)
	cairo_close_path (cr)
	cairo_stroke_preserve (cr) 
	cairo_fill(cr)
end
--[[
	Given a value, and the min/max values, this will calculate the angle to put the hand on the dial.
]]
function Common.placeHandOnDialShade(cr, vecx, vecy, value, r, g, b, shadeOffset, ctrx, ctry, max, min)
	--bounds check
	if (value > max) then value = max end
	if (value < min) then value = min end
	--caculate angle, the min value is at -225 degrees and the dial arc is 270 degrees
	local angle = (-225+(value*270/(max-min)))*Common.radianConversion
	local sin = math.sin(angle)
	local cos = math.cos(angle)
	
	cairo_set_source_rgba (cr,r,g,b,1)
	--not the safest, assumes vecx, vecy are equal
	for i=2,(vecx[1]) do
		xy=Common.rotate(ctrx+vecx[i], ctry+vecy[i], ctrx, ctry, sin, cos)
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
	--offset the shade to create a shadow effect on the dial.
	cairo_set_source_rgba (cr,r+shadeOffset,g+shadeOffset,b+shadeOffset,1)
	for i=2,(vecx[1]+1) do
		xy=Common.rotate(ctrx+vecx[i], ctry+vecy[i], ctrx, ctry, sin, cos)
		if (i==2) then
			cairo_move_to (cr,xy[0], xy[1])
			--cairo_move_to (cr,vecx[i], vecy[i])
		elseif (i~=3) then
			cairo_line_to (cr, xy[0], xy[1])
			--cairo_line_to (cr,vecx[i], vecy[i])
		end
	end
	--cairo_stroke(cr)
	cairo_close_path (cr)
	cairo_stroke_preserve (cr) 
	cairo_fill(cr)
end

function Common.placeHandOnDialAlpha(cr, vecx, vecy, angle, ctrx, ctry, r, g, b, alpha)
	sin = math.sin(angle)
	cos = math.cos(angle)
	
	
	--not the safest, assumes vecx, vecy are equal
	for i=2,(vecx[1]+1) do
		xy=Common.rotate(ctrx+vecx[i], ctry+vecy[i], ctrx, ctry, sin, cos)
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
	cairo_set_source_rgba(cr,r,g,b,alpha)
	cairo_fill(cr)
end

function Common.rotate(x, y, ctrx, ctry, sin, cos)
	xy = {}
	xy[0] = (cos * (x - ctrx)) - (sin * (y-ctry)) + ctrx
	xy[1] = (sin * (x - ctrx)) + (cos * (y-ctry)) + ctry
	return xy
end

--[[
	Cairo does not understand HSV - this utility function converts to RGB. 
	
	It then sets the colour for the cr object.
]]
function Common.setRGBFromHSV(cr, hue, saturation, volume, alpha) 
	c =  (1 - math.abs(2*(volume/100)-1)) * (saturation/100)
	
	x = c * (1 - math.abs((hue/60)%2.0 - 1))
	m = volume/100 - c/2
	redprime=0
	greenprime=0
	blueprime=0
	if (hue >= 0 and hue < 60) then 
		redprime = c
		greenprime = x
	elseif (hue >= 60 and hue < 120) then
		redprime = x
		greenprime = c
	elseif (hue >= 120 and hue < 180) then
		greenprime = c
		blueprime = x
	elseif (hue >= 180 and hue < 240) then
		greenprime = x
		blueprime = c
	elseif (hue >= 240 and hue < 300) then
		redprime = x
		blueprime = c
	elseif (hue >= 300 and hue < 360) then
		redprime = c
		blueprime = x
	end
	cairo_set_source_rgba(cr, redprime+m, greenprime+m, blueprime+m, alpha)	
end

function Common.tick(cr, p_len,l_len,l_width, arcStart, ctrx1, ctry1, r, g, b, alpha, digit)
	local linestart = p_len-l_len
	local offset = 7
	if (r ~= nil) then
		cairo_set_source_rgba (cr,r,g,b,alpha)
	end
	--the tick 
	cairo_set_line_width(cr,l_width)
	local cos = math.cos(arcStart)
	local sin= math.sin(arcStart)
	local xval0=ctrx1 + (linestart * cos)
	local yval0=ctry1 + (linestart * sin)
	local xval1=ctrx1 + ((p_len+offset) * cos)
	local yval1=ctry1 + ((p_len+offset) * sin)
	cairo_move_to (cr, xval0,yval0)
	cairo_line_to (cr, xval1, yval1)
	cairo_stroke (cr)
	--cairo_move_to (cr,0,0)
	cairo_set_line_width(cr,0)
	local extents = cairo_text_extents_t:create()
	cairo_text_extents(cr, ""..digit, extents)
	--place number; 
	local t_len = linestart-15 --extents.width*0.75 
	local xoffset = ctrx1 + t_len*cos
	--y=ctry
	local yoffset = ctry1 + t_len*sin
	cairo_move_to(cr, xoffset - extents.width/2, yoffset + extents.height/2)
	cairo_show_text(cr, ""..digit)
	cairo_text_extents_t:destroy(extents)

end
    