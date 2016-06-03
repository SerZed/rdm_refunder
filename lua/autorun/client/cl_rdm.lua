surface.CreateFont( "rdmrefunder_font_title", {
	font = "Roboto Lt",
	size = ScreenScale(20),
	weight = 100,
	antialias = true
})

surface.CreateFont( "rdmrefunder_font_button", {
	font = "Roboto Lt",
	size = ScreenScale(15),
	weight = 100,
	antialias = true
})

surface.CreateFont( "rdmrefunder_font_close", {
	font = "Roboto",
	size = ScreenScale(12),
	weight = 500,
	antialias = true
})

local bg
local playerbox
local lifebox

net.Receive("rdmrefunder_openmenu", function()
    if ValidPanel(bg) then bg:Remove() end -- Make sure menu isn't opened 100000 times.

	local function rdmrefunder_refresh(ply) -- Resets the DComboBox when changes are made.
		lifebox:Clear()
		lifebox:SetValue("Life to refund")
        for i = 1, ply.rdmrefunder_lives do
			if istable(ply.rdmrefunder_weapons[i]) == true and #ply.rdmrefunder_weapons[i] > 0 then
        		lifebox:AddChoice(table.concat(ply.rdmrefunder_weapons[i], "", 1, 1).. " - " .. i, i)
			end
        end
	end

    for k, v in pairs(player.GetAll()) do -- Read our lives and weapons we sent for all players.
        v.rdmrefunder_lives = net.ReadInt(32)
        v.rdmrefunder_weapons = net.ReadTable()
    end

    bg = vgui.Create("DFrame")
    bg:SetSize(ScrW() * 0.45, ScrH() * 0.4)
    bg:Center()
	bg:ShowCloseButton()
    bg:MakePopup()
    bg:SetTitle("")
    bg.Paint = function (self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(23, 23, 23))
     	draw.RoundedBox(0, 0, 0, w, h * 0.1, Color(41, 128, 185))
        draw.DrawText("RDM Refunder", "rdmrefunder_font_title", w / 2, h * 0.2, Color(255,255,255), TEXT_ALIGN_CENTER)
    end

	local bgclose = vgui.Create("DButton", bg)
	bgclose:SetSize(bg:GetWide() * 0.05, bg:GetTall() * 0.101)
	bgclose:SetPos(bg:GetWide() - bgclose:GetWide(), 0)
	bgclose:SetFont("rdmrefunder_font_close")
	bgclose:SetTextColor(Color(255,255,255))
	bgclose:SetText("X")

	bgclose.Paint = function (self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
	end

	bgclose.DoClick = function ()
		for k, v in pairs(player.GetAll()) do -- Lets clear everything off our client who closes the menu.
			v.rdmrefunder_lives = nil
	        v.rdmrefunder_weapons = nil
		end
		bg:Remove()
	end

    playerbox = vgui.Create( "DComboBox", bg)
    playerbox:SetSize( bg:GetWide() * 0.7, bg:GetTall() * 0.1)
    playerbox:SetPos(0, bg:GetTall() * 0.4)
	playerbox:CenterHorizontal()
    playerbox:SetValue( "Player to refund" )
    for k, v in pairs(player.GetAll()) do
        playerbox:AddChoice(v:Nick(), v:SteamID(), false)
    end

    lifebox = vgui.Create( "DComboBox", bg)
    lifebox:SetSize( bg:GetWide() * 0.7, bg:GetTall() * 0.1)
    lifebox:SetPos(0, bg:GetTall() * 0.6)
    lifebox:CenterHorizontal()
    lifebox:SetValue( "Life to refund" )

    playerbox.OnSelect = function( index, value, data ) -- When selected loop players, loop their lives and add the times n stuff
		local useless, steam_id = playerbox:GetSelected()
		local ply = player.GetBySteamID(steam_id)
		rdmrefunder_refresh(ply) -- Clean up
    end

    local submit = vgui.Create("DButton", bg)
    submit:SetSize(bg:GetWide() * 0.7, bg:GetTall() * 0.1)
    submit:SetPos(0, bg:GetTall() * 0.8)
    submit:CenterHorizontal()
    submit:SetFont("rdmrefunder_font_button")
    submit:SetTextColor(Color(255,255,255))
    submit:SetText("REFUND")
    submit.Paint = function (self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(41, 128, 185))
    end

	submit.DoClick = function()
		local useless, life = lifebox:GetSelected()
		ply.rdmrefunder_weapons[life] = nil

		net.Start("rdmrefunder_refund")
		net.WriteInt(life, 32)
		net.WriteEntity(ply)
		net.SendToServer()

		rdmrefunder_refresh(ply)
	end
end)
