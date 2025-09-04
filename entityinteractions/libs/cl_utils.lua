local COLOR = FindMetaTable("Color")
if not COLOR.Lerp then
    function COLOR:Lerp(target_clr, frac)
        return Color(Lerp(frac, self.r, target_clr.r), Lerp(frac, self.g, target_clr.g), Lerp(frac, self.b, target_clr.b), Lerp(frac, self.a, target_clr.a))
    end
end

local CopyColor do
    local Color = Color
    function CopyColor(col)
        return Color(col.r, col.g, col.b, col.a)
    end

    COLOR.Copy = CopyColor
end

local GetScaledFont, Scale, scrW, scrH do
    local max = math.max
    function Scale(value)
        return max(value * (scrH / 1080), 1)
    end

    local scaledFonts = {}
    local function RegisterFont(font, size, weight)
        weight = weight or 500
        local fontName = font .. ":" .. tostring(size) .. "-" .. tostring(weight)
        scaledFonts[fontName] = {
            font = font,
            size = Scale(size),
            weight = weight,
            extended = true,
            antialias = true,
        }

        surface.CreateFont(fontName, scaledFonts[fontName])
        return fontName
    end

    function GetScaledFont(font, size, weight)
        weight = weight or 500
        local fontName = font .. ":" .. tostring(size) .. "-" .. tostring(weight)
        if scaledFonts[fontName] then
            return fontName
        else
            return RegisterFont(font, size, weight)
        end
    end

    hook.Add("OnScreenSizeChanged", "ix.Scale", function(_, _, newWidth, newHeight)
        scrW, scrH = newWidth, newHeight
        for _, v in next, scaledFonts do
            RegisterFont(v.font, v.size, v.weight)
        end
    end)

    scrW, scrH = ScrW(), ScrH()
end

local RequestInput do
    function RequestInput(title, callback)
        local panel = vgui.Create("ix.RequestPanel")
        panel:SetSize(Scale(290), Scale(90))
        panel:Center()
        panel:MakePopup()
        panel:SetCallback(callback)
        panel:SetTitle(title)
        panel:AlphaTo(255, 0.2)
        return panel
    end

    if CLIENT and ix and ix.util then ix.util.RequestInput = RequestInput end
end

return {
    CopyColor = CopyColor,
    GetScaledFont = GetScaledFont,
    Scale = Scale,
}