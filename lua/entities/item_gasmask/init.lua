local model = "models/half-dead/metroll/p_mask_1.mdl"
local classname = "item_gasmask" -- This should be the name of the folder containing this file.
local ShouldSetOwner = false -- Set the entity's owner?
local time = 0
local hold = 0
-------------------------------
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
-------------------------------
ENT.Dropped = false
--------------------
-- Spawn Function --
--------------------
function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create( classname )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	if ShouldSetOwner then
		ent.Owner = ply
	end
	return ent
	
end
----------------
-- Initialize --
----------------
function ENT:Initialize()
	
	self.Entity:SetModel( model )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

------------
-- On use --
------------
function ENT:Use( activator, caller )
local ply = activator
	if (time < CurTime()) then
		if (ply:GetNWBool("HasGasmask") == false) then
			ply:SetNWBool("HasGasmask", true)
			ply:SetNWInt("GasmaskHealth", 100)
			ply:SetNWInt("FilterDuration", 60)
			if self.Dropped == false then
				ply:SetNWInt("Filter", math.min( 3600, ply:GetNWInt("Filter") + 100) )
			end
			self:Remove()
			time = CurTime()+5
			
		end
	end
	if (ply:GetNWBool("HasGasmask") == true and ply:GetNWInt("GasmaskHealth") < 100) then
		if hold < 10 then
		
			hold = hold + 1 
			
		elseif hold >= 10 and ply:GetNWBool("MetroGasmask") == true then
			self:Remove()
			local wep = ply:GetActiveWeapon()
				
			timer.Remove("MMFX"..ply:SteamID())
			sounds[ply:SteamID()]:Stop()			
				
			if ply:GetActiveWeapon() and ply:GetActiveWeapon() != nil then 
				local wep = ply:GetActiveWeapon():GetClass()
				ply:SetNWString("gasmask_lastwepon", wep) 
			end
				
			ply:Give("metro_gasmask_holster")
			ply:SelectWeapon( "metro_gasmask_holster" )
			
			timer.Simple(1.5, function()
				
				ply:SetNWInt("GasmaskHealth", 100)
					if self.Dropped == false then
						ply:SetNWInt("Filter", math.min( 3600, ply:GetNWInt("Filter") + 100) )
					end
				
				ply:SetNWInt("FilterDuration", 60)
				
				if ply:GetActiveWeapon() and ply:GetActiveWeapon() != nil then 
					local wep = ply:GetActiveWeapon():GetClass()
					ply:SetNWString("gasmask_lastwepon", wep) 
				end
				
				ply:Give("metro_gasmask_deploy")
				ply:SelectWeapon( "metro_gasmask_deploy" )
				
			end)
		elseif hold >= 10 and ply:GetNWBool("MetroGasmask") == false then
			self:Remove()
			ply:SetNWInt("GasmaskHealth", 100)
			ply:SetNWInt("FilterDuration", 60)
		end
	end
end

function applyMask(ply)
	/*if (ply:GetNWBool("Gasmask") == false) then
		ply:SetNWBool("Gasmask", true)
		if (ply:GetNWInt("Filter") <= -1) then ply:SetNWInt("Filter", 360) end
		sounds[ply:SteamID()] = CreateSound(ply, Sound("metromod/gmse2.ogg"))
		sounds[ply:SteamID()]:SetSoundLevel(42)
		sounds[ply:SteamID()]:PlayEx(1, 100)
		timer.Create("MMFX"..ply:SteamID(), 1, 0, function()
			sounds[ply:SteamID()] = CreateSound(ply, Sound("metromod/gmse2.ogg"))
			sounds[ply:SteamID()]:SetSoundLevel(42)
			sounds[ply:SteamID()]:PlayEx(1, 100)
		end)
		return true
	end
	return false*/

end