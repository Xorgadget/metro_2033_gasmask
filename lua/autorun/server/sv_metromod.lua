resource.AddFile("materials/metromod/metromask2.vmt")
resource.AddFile("sound/metromod/gmse2.wav")
sounds = {}
local function defaultVariables(ply)
	ply:SetNWBool("MetroGasmask", false)
	ply:SetNWBool("HasGasmask", false)
	ply:SetNWInt("Filter", -1)
	ply:SetNWInt("FilterDuration", 0)
	ply:SetNWInt("FLBattery", 360)
	ply:SetNWInt("GasmaskHealth", 5000)
	ply:SetNWBool("HasNV", false)
	ply:SetNWBool("AdminFilter", false)
	ply:SetNWInt("waitTime", 0)
end

if SERVER then
	util.AddNetworkString( "DeployMask" )
	util.AddNetworkString( "RemoveMask" )
	util.AddNetworkString( "WipeMask" )
	util.AddNetworkString( "ClearMask" )
	util.AddNetworkString( "WipeMaskHud" )
	util.AddNetworkString( "SwapFilter" )
	util.AddNetworkString( "AddShitOnScreengasmask" )

	util.AddNetworkString( "UseMedkit" )

	util.AddNetworkString( "MetroHudCheck" )

	net.Receive( "DeployMask", function(len, ply)

			local ply = ply
      ply.weargasmask = true
			if IsValid(ply:GetActiveWeapon()) then
				local wep = ply:GetActiveWeapon():GetClass()
				ply:SetNWString("gasmask_lastwepon", wep)
			end

			ply:Give("metro_gasmask_deploy")
			ply:SelectWeapon( "metro_gasmask_deploy" )

	end)

	net.Receive( "SwapFilter", function(len, ply)

			local ply = ply

			if IsValid(ply:GetActiveWeapon()) then
				local wep = ply:GetActiveWeapon():GetClass()
				ply:SetNWString("gasmask_lastwepon", wep)
			end

			ply:Give("metro_gasmask_filter_swap")
			ply:SelectWeapon( "metro_gasmask_filter_swap" )

	end)

	net.Receive( "WipeMask", function(len, ply)

			local ply = ply
			if IsValid(ply:GetActiveWeapon()) then
				local wep = ply:GetActiveWeapon():GetClass()
				ply:SetNWString("gasmask_lastwepon", wep)
			end

			ply:Give("metro_gasmask_wipe")
			ply:SelectWeapon( "metro_gasmask_wipe" )

	end)

	net.Receive( "RemoveMask", function(len, ply)

			local ply = ply
	    ply.weargasmask = false
			timer.Remove("MMFX"..ply:SteamID())
			sounds[ply:SteamID()]:Stop()

			if IsValid(ply:GetActiveWeapon()) then
				local wep = ply:GetActiveWeapon():GetClass()
				ply:SetNWString("gasmask_lastwepon", wep)
			end

			ply:Give("metro_gasmask_holster")
			ply:SelectWeapon( "metro_gasmask_holster" )
	end)

end

hook.Add("DoPlayerDeath","DoPlayerDeathMetroModCyka",function( ply, attacker, dmginfo )

	timer.Remove("MMFX"..ply:SteamID())
	if sounds[ply:SteamID()] then
		sounds[ply:SteamID()]:Stop()
	end

end)

local function DropStuffOnScreen(dist, damage, attacker, types)
	if types == "red" then
			if dist < 100 then
				for i = 1, math.Round(damage/30) do
					net.Start( "AddShitOnScreengasmask" )
						net.WriteString("blooddrop")
					net.Send(attacker)
				end
			end
			if dist < 80 and damage >= 20 then
				for i = 1, math.Round(damage/80) do
					net.Start( "AddShitOnScreengasmask" )
						net.WriteString("bloodsplat")
					net.Send(attacker)
				end
			end
	elseif types == "yellow" then
			if dist < 80 and damage >= 20 then
				for i = 1, math.Round(damage/50) do
					net.Start( "AddShitOnScreengasmask" )
						net.WriteString("ybloodsplat")
					net.Send(attacker)
				end
			end
	end
end

hook.Add("EntityTakeDamage", "EntityTakeDamageMetro", function(trg, dmg)
		if dmg:GetDamage() > 1 and dmg:GetAttacker():IsPlayer() then
			local tr = dmg:GetAttacker():GetEyeTrace()
			local dist = dmg:GetAttacker():GetShootPos():Distance(trg:GetPos())
			local damage = dmg:GetDamage()
			local attacker = dmg:GetAttacker()
			--print(damage)
			if trg:GetBloodColor() == BLOOD_COLOR_RED then
				if attacker:GetNWBool("MetroGasmask") == true then
					DropStuffOnScreen(dist, damage, attacker, "red")
				end
			elseif trg:GetBloodColor() == BLOOD_COLOR_YELLOW or trg:GetBloodColor() == BLOOD_COLOR_GREEN or trg:GetBloodColor() == BLOOD_COLOR_ZOMBIE or trg:GetBloodColor() == BLOOD_COLOR_ANTLION then
				if attacker:GetNWBool("MetroGasmask") == true then
					DropStuffOnScreen(dist, damage, attacker, "yellow")
				end
			end
		end
end)

local dmgs = {
	DMG_ACID,
	DMG_POISON,
	DMG_NERVEGAS,
	DMG_RADIATION
}

hook.Add("EntityTakeDamage","EntityTakeDamageMetroGasmaskmod",function( target, dmginfo )
	local damagetaken = dmginfo:GetDamage()
	local dmgtype = dmginfo:GetDamageType()


	if target:IsPlayer() and (!table.HasValue(dmgs, dmgtype)) then
		local ply = target
			if ply:GetNWBool("MetroGasmask") == true and math.random(1,2) == 2 then
				ply:SetNWInt("GasmaskHealth", ply:GetNWInt("GasmaskHealth") - damagetaken )
			end
	elseif target:IsPlayer() and (table.HasValue(dmgs, dmgtype)) then
		local ply = target
		if ply:GetNWBool("MetroGasmask") == true then
			return true
		end
	end
end)

local function gasCheck(ply)

	if ply:GetNWBool("MetroGasmask") == true and ply:GetNWInt("FilterDown") < CurTime() and ply:GetNWBool("AdminFilter") == false then
		if ply:GetNWInt("FilterDuration") <= 0 then
			ply.weargasmaskfilter = nil


			if ply:GetNWInt("waitTime", 0) < CurTime() then
			local d = DamageInfo()
			d:SetDamage(1)
			d:SetAttacker( ply )
			d:SetDamageType( DMG_DROWN )
			ply:TakeDamageInfo( d )
				ply:SetNWInt("waitTime", CurTime() + 5)
		end
		else
			ply:SetNWInt("Filter", ply:GetNWInt("Filter")-1)
			ply:SetNWInt("FilterDuration", ply:GetNWInt("FilterDuration")-1)
			ply:SetNWInt("FilterDown", CurTime() + 1)
			ply.weargasmaskfilter = true
		end
	end
end

hook.Add( "PlayerPostThink", "PlayerPostThinkGasmaskHandleKeysShitBlyat", function(ply)

local maskhlth = ply:GetNWInt("GasmaskHealth")
gasCheck(ply)
if maskhlth <= 0 and ply:GetNWBool("MetroGasmask") == true then
	timer.Remove("MMFX"..ply:SteamID())
	if not sounds[ply:SteamID()] then return end
	sounds[ply:SteamID()]:Stop()
	ply:SetNWBool("MetroGasmask", false)
	ply:SetNWBool("HasGasmask", false)
		local wep = ply:GetActiveWeapon()
		ply:SetNWEntity("gasmask_lastwepon", wep:GetClass())

		ply:Give("metro_gasmask_holster")
		ply:SelectWeapon( "metro_gasmask_holster" )
end

end)

local function removeMask(ply)
	if not ply:GetNWBool("MetroGasmask") or ply:IsBot() then return end
	ply:SetNWBool("MetroGasmask", false)
	timer.Remove("MMFX"..ply:SteamID())
	sounds[ply:SteamID()]:Stop()
	local ent = ents.Create("mm_gasmask")
	ent:SetPos(ply:EyePos())
	ent:Spawn()
end

hook.Add("PlayerInitialSpawn", "MMPlayerJoin", function(ply)
	defaultVariables(ply)
end)

hook.Add("PlayerSpawn", "MMPlayerSpawn", function(ply)
	defaultVariables(ply)
	ply:SetCanZoom( true )
	if ply != nil then
		if timer.Exists( "MM"..ply:SteamID() ) then
			timer.Remove("MM"..ply:SteamID())
			sounds[ply:SteamID()]:Stop()
		end
	end
	--ply:SetNWBool("MetroGasmask", true)
end)

hook.Add("PlayerDeath", "MMPlayerIsKill", function(ply)
	--removeMask(ply)
end)

hook.Add("PlayerSay", "MMPlayerSay", function(ply, text)
	if text == "/mask" then
		if ply:GetNWBool("HasGasmask") == true then
		--removeMask(ply)
			ply:SetNWBool("HasGasmask", false)
			local ent = ents.Create("item_gasmask")
			ent:SetPos(ply:GetShootPos()+ply:GetAimVector()*45)
			ent:Spawn()
			ent.Dropped = true
				if ply:GetNWBool("MetroGasmask") == true then
					ply:SetNWBool("MetroGasmask", false)
					timer.Remove("MMFX"..ply:SteamID())
					sounds[ply:SteamID()]:Stop()

					local wep = ply:GetActiveWeapon()
					ply:SetNWEntity("gasmask_lastwepon", wep:GetClass())

					ply:Give("metro_gasmask_holster")
					ply:SelectWeapon( "metro_gasmask_holster" )
				end
		end
		return ""
	end
end)

hook.Add("PlayerDisconnected", "MMPlayerLeave", function(ply)
	if ply != nil then
		if timer.Exists( "MM"..ply:SteamID() ) then
			timer.Remove("MM"..ply:SteamID())
			sounds[ply:SteamID()]:Stop()
		end
	end
end)
