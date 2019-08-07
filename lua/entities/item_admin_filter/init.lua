ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AdminOnly = true

local model = "models/teebeutel/metro/objects/gasmask_filter.mdl" -- What model should it be?
local classname = "item_admin_filter" -- This should be the name of the folder containing this file.
local ShouldSetOwner = false -- Set the entity's owner?
local time = 0
-------------------------------
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )
-------------------------------

--------------------
-- Spawn Function --
--------------------
/*function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	if ( !ply:IsAdmin() ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 25
	local ent = ents.Create( classname )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	if ShouldSetOwner then
		ent.Owner = ply
	end
	return ent
	
end*/
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
	if (ply:GetNWBool("HasGasmask") == true) then
		--ply:SetNWInt("Filter", ply:GetNWInt("Filter") + 200)
		ply:SetNWInt("Filter", 3600 )
		ply:SetNWBool("AdminFilter", true )
		ply:SetNWInt("checkfilter", CurTime() + 1)	
		self.Entity:Remove()
	end
		time = CurTime()+1
	end
end

function applyFilter(ply)

end