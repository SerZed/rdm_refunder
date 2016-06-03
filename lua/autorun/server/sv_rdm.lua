util.AddNetworkString("rdmrefunder_openmenu")
util.AddNetworkString("rdmrefunder_refund")

----------------------------------------------------------------------
-- CONFIG STARTS HERE LOOK HOW I'VE DONE IT AS A GUIDELINE TO HELP! --
----------------------------------------------------------------------

local rdmrefunder_allowedranks = { -- Add ranks that have permission, include commas except for the last like I have done so.
    "owner",
    "superadmin",
    "admin"
}

local rdmrefunder_livestostore = 5 -- I'd recommend 5, feel free to add more.

----------------------------------------------------------------------
--- END OF CONFIG RUN AWAY IF YOU DON'T KNOW WHAT YOU'RE DOING PLZ ---
----------------------------------------------------------------------
hook.Add("PlayerInitialSpawn", "rdmrefunder_spawn", function(ply) -- Create table when player joins.
    ply.rdmrefunder_weapons = {}
    ply.rdmrefunder_life = 1
end)

hook.Add("PlayerDisconnected", "rdmrefunder_disconnect", function(ply) -- Clear table when players leave.
	ply.rdmrefunder_weapons = nil
end)

hook.Add("PlayerDeath", "rdmrefunder_death", function(ply)
    local time = os.time() -- Get timestamp for when the player dies
    local timestring = os.date( "%H:%M:%S" , time) -- Use time to convert it into H, M, S.

    ply.rdmrefunder_weapons[ply.rdmrefunder_life] = {} -- Create index with current life.
    table.insert(ply.rdmrefunder_weapons[ply.rdmrefunder_life], 1, timestring) -- Add timestamp to first position in the table.

    for k, v in pairs (ply:GetWeapons()) do
        table.insert(ply.rdmrefunder_weapons[ply.rdmrefunder_life], k + 1, v:GetClass()) -- Add players weapons to table.
    end

    ply.rdmrefunder_life = ply.rdmrefunder_life + 1 -- Increment life number.

    if ply.rdmrefunder_life  == rdmrefunder_livestostore + 1 then -- Reset life to 1 when we've hit the maximum.
        ply.rdmrefunder_life = 1
    end
end)

hook.Add("PlayerSay", "rdmrefunder_command", function(ply, text)
    if !table.HasValue(rdmrefunder_allowedranks, ply:GetUserGroup()) then return end -- Keep haxors out of the menu, 2nd check is done later.

    text = string.lower(text) -- Convert text to lowercase so we can do !rEfUnd or /rEFUnd.

    if text == "!refund" or text == "/refund" then
        net.Start("rdmrefunder_openmenu")

        for k, v in pairs (player.GetAll()) do -- Loop players and their weapons and get the amount of lives they have.
            v.rdmrefunder_lives = #v.rdmrefunder_weapons
        end

        for k, v in pairs(player.GetAll()) do
            net.WriteInt(v.rdmrefunder_lives, 32) -- Send all the lives data
            net.WriteTable(v.rdmrefunder_weapons) -- Send weapons data
        end
        net.Send(ply) -- Open menu on client calling.
    end
end)

net.Receive("rdmrefunder_refund",function(len, caller)
    local life = net.ReadInt(32) -- Get which life needs to be refunded.
    local ply = net.ReadEntity() -- Player who needs to be refunded.

    if !table.HasValue(rdmrefunder_allowedranks, caller:GetUserGroup()) then return end -- Make sure haxors dont get their weps.

    for k, v in pairs (ply.rdmrefunder_weapons[life]) do
        if k != 1 then -- Make sure not to run 1st value as it's the time!
            ply:Give(v) -- Give them the weapons that correspond to that life :D
        end
    end

    ply.rdmrefunder_weapons[life] = nil
end)
