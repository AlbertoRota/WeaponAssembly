require "/scripts/util.lua"

function rgbToHsl(r, g, b)
   r, g, b = r/255, g/255, b/255
   local min = math.min(r, g, b)
   local max = math.max(r, g, b)
   local delta = max - min

   local h, s, l = 0, 0, ((min+max)/2)

   if l > 0 and l < 0.5 then s = delta/(max+min) end
   if l >= 0.5 and l < 1 then s = delta/(2-max-min) end

   if delta > 0 then
      if max == r and max ~= g then h = h + (g-b)/delta end
      if max == g and max ~= b then h = h + 2 + (b-r)/delta end
      if max == b and max ~= r then h = h + 4 + (r-g)/delta end
      h = h / 6;
   end

   if h < 0 then h = h + 1 end
   if h > 1 then h = h - 1 end

   return h * 360, s, l
end

function hslToRgb(h, s, L)
   h = h/360
   local m1, m2
   if L<=0.5 then
      m2 = L*(s+1)
   else
      m2 = L+s-L*s
   end
   m1 = L*2-m2

   local function _h2rgb(m1, m2, h)
      if h<0 then h = h+1 end
      if h>1 then h = h-1 end
      if h*6<1 then
         return m1+(m2-m1)*h*6
      elseif h*2<1 then
         return m2
      elseif h*3<2 then
         return m1+(m2-m1)*(2/3-h)*6
      else
         return m1
      end
   end

   return _h2rgb(m1, m2, h+1/3) * 255, _h2rgb(m1, m2, h) * 255, _h2rgb(m1, m2, h-1/3) * 255
end

local function decToHex(num)
	local hexstr = '0123456789abcdef'
	local s = ''
	while num > 0 do
		local mod = math.fmod(num, 16)
		s = string.sub(hexstr, mod+1, mod+1) .. s
		num = math.floor(num / 16)
	end
	if s == '' then s = '0' end
	if string.len(s) == 1 then s = 0 .. s end
	return s
end

function applyPrecDye(inputColors, dyeMode)
  local outputColors = {}
  for i, inputColor in ipairs(inputColors) do
		local r = tonumber("0x"..inputColor:sub(1,2))
		local g = tonumber("0x"..inputColor:sub(3,4))
		local b = tonumber("0x"..inputColor:sub(5,6))
		if dyeMode == 0 then -- Luminosity +
			local h, s, l = rgbToHsl(r, g, b)
			l = l + 0.05
			l = math.min(l,1)
			r, g, b = hslToRgb(h, s, l)
		elseif dyeMode == 1 then -- Luminosity -
			local h, s, l = rgbToHsl(r, g, b)
			l = l - 0.05
			l = math.max(0,l)
			r, g, b = hslToRgb(h, s, l)
		elseif dyeMode == 2 then -- Saturation +
			local h, s, l = rgbToHsl(r, g, b)
			s = s + 0.1
			s = math.min(s,1)
			r, g, b = hslToRgb(h, s, l)
		elseif dyeMode == 3 then -- Saturation -
			local h, s, l = rgbToHsl(r, g, b)
			s = s - 0.1
			s = math.max(0,s)
			r, g, b = hslToRgb(h, s, l)
		elseif dyeMode == 4 then -- Red +
			r = r + 25
			r = math.min(r,255)
		elseif dyeMode == 5 then -- Red -
			r = r - 25
			r = math.max(0,r)
		elseif dyeMode == 6 then -- Green +
			g = g + 25
			g = math.min(g,255)
		elseif dyeMode == 7 then -- Green -
			g = g - 25
			g = math.max(0,g)
		elseif dyeMode == 8 then -- Blue +
			b = b + 25
			b = math.min(b,255)
		elseif dyeMode == 9 then -- Blue -
			b = b - 25
			b = math.max(0,b)
		end
		outputColor = decToHex(math.floor(r)) .. decToHex(math.floor(g)) .. decToHex(math.floor(b))
		table.insert(outputColors, outputColor)
	end
	return outputColors
end
