SWEP.PrintName = "Ящик с инструментами"
    
SWEP.Author = "Miller"
SWEP.Instructions = ""
SWEP.Category = "Combine Jobs"

SWEP.Spawnable= true
SWEP.AdminOnly = false

SWEP.Base = "weapon_base"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawCrosshair = true
SWEP.DrawAmmo = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 60
SWEP.ViewModel			= ""
SWEP.WorldModel			= "models/props_c17/BriefCase001a.mdl"
SWEP.UseHands           = true

SWEP.HoldType = "passive" 

SWEP.FiresUnderwater = true

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

SWEP.Offset = {
	Pos = {
		Right = 1,
		Forward = 6.5,
		Up = 0,
	},
	Ang = {
		Right = 90,
		Forward = 0,
		Up = 0,
	},
	Scale = Vector( 1, 1, 1 ),
}

function SWEP:DrawWorldModel( )
	if not IsValid( self.Owner ) then
		return self:DrawModel( )
	end
	
	local offset, hand
	
	self.Hand2 = self.Hand2 or self.Owner:LookupAttachment( "anim_attachment_rh" )
	
	hand = self.Owner:GetAttachment( self.Hand2 )
	
	if not hand then
		return
	end
	
	offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * self.Offset.Pos.Forward + hand.Ang:Up( ) * self.Offset.Pos.Up
	
	hand.Ang:RotateAroundAxis( hand.Ang:Right( ), self.Offset.Ang.Right )
	hand.Ang:RotateAroundAxis( hand.Ang:Forward( ), self.Offset.Ang.Forward )
	hand.Ang:RotateAroundAxis( hand.Ang:Up( ), self.Offset.Ang.Up )
	
	self:SetRenderOrigin( hand.Pos + offset )
	self:SetRenderAngles( hand.Ang )
	
	self:SetModelScale( 0.8, 0 )
	
	self:DrawModel( )
end

function SWEP:PrimaryAttack()
	return
end

function SWEP:SecondaryAttack()
	return
end 

function SWEP:Reload() end