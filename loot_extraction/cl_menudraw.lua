local PLUGIN = PLUGIN

if CLIENT then

local function DrawExtractionMenu(entity, itemid, itemamount)
	local menucolor = ix.config.Get("color")
	local MAIN_COLOR = Color(menucolor.r, menucolor.g, menucolor.b, menucolor.a - 55)
	local DARKER_COLOR = Color( 77, 77, 77,200 )
	local COLOR_WHITE = Color(255, 255, 255)

	local w,h = ScrW(), ScrH()

	local item = ix.item.Get(itemid)
	local itemmodel = item:GetModel() or "models/props_junk/popcan01a.mdl"

	local iconpan = h*0.43*0.75

	local frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:SetSize(w * 0.45, h * 0.43)
	frame:Center()			
	frame:MakePopup()
	frame.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, h/4, w, h*0.75, DARKER_COLOR )
		draw.RoundedBox( 0, 0, 0, w, h/4, MAIN_COLOR)
		draw.DrawText(entity.PrintName, "ixMenuButtonHugeFont", w/50, h/50, COLOR_WHITE, TEXT_ALIGN_LEFT)

		draw.DrawText("/// Now extracting: "..item:GetName().." ///", "ixBigFont", w/20, h/3, COLOR_WHITE)
		draw.DrawText("| Currently extracted: "..itemamount, "ixBigFont", w/20, h/3+h/10, COLOR_WHITE)
	end

	local Panel = vgui.Create( "DPanel", frame )
	Panel:SetPos( w * 0.45 - iconpan, h * 0.43 - iconpan )
	Panel:SetSize( iconpan, iconpan )

	local modelicon = vgui.Create("DModelPanel", Panel)
	modelicon:SetSize(iconpan,iconpan)
	modelicon:SetModel(itemmodel)
	local clentic = modelicon:GetEntity()
	modelicon:SetLookAt(clentic:GetPos())
	modelicon:SetFOV(10)

	local itemchoise = vgui.Create( "DComboBox", frame )
	itemchoise:SetPos( w/10, h/4 )
	itemchoise:SetSize( w/5, h/20 )
	itemchoise:SetFont("ixBigFont")
	itemchoise:SetValue( "--> Change produced item <--" )
	for _,v in pairs(PLUGIN.itemlist) do
		itemchoise:AddChoice(ix.item.Get(v):GetName(), v)
	end
	itemchoise.OnSelect = function( self, index, value )
		local data = itemchoise:GetOptionData(index)

		net.Start("ixLootExtractionMenuCallBack")
        	net.WriteEntity(entity)
			net.WriteString(data)
   		net.SendToServer()
	end

	local getitems = vgui.Create( "DButton", frame )
	getitems:SetText( "" )
	getitems:SetPos( w * 0.45 - w * 0.45 * 0.99, h * 0.43 - h * 0.43 * 0.2)
	getitems:SetSize( w/7, h/20 )
	getitems.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, MAIN_COLOR)
		draw.DrawText("Get all items", "ixMenuButtonFont", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)
	end
	getitems.DoClick = function()
		net.Start("ixLootExtractionItemsCallback")
        	net.WriteEntity(entity)
			net.WriteBool(true)
   		net.SendToServer()
		frame:Close()
	end

	local getoneitem = vgui.Create( "DButton", frame )
	getoneitem:SetText( "" )
	getoneitem:SetPos( w * 0.45 - w * 0.45 * 0.65, h * 0.43 - h * 0.43 * 0.2)
	getoneitem:SetSize( w/7, h/20 )
	getoneitem.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, MAIN_COLOR)
		draw.DrawText("Get one item", "ixMenuButtonFont", 0, 0, COLOR_WHITE, TEXT_ALIGN_LEFT)
	end
	getoneitem.DoClick = function()
		net.Start("ixLootExtractionItemsCallback")
        	net.WriteEntity(entity)
			net.WriteBool(false)
   		net.SendToServer()
		frame:Close()
	end
end

net.Receive("ixOpenLootExtractionMenu", function(len)
	local entity = net.ReadEntity()
	local itemid = net.ReadString()
	local amount = net.ReadUInt(8)

    DrawExtractionMenu(entity, itemid, amount)
end)

end