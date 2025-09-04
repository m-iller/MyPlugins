SWEP.PrintName = "Applicator"
    
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
SWEP.ViewModel			= "models/foam_tank/applicator.mdl"
SWEP.WorldModel			= "models/foam_tank/applicator.mdl"
SWEP.UseHands           = true

SWEP.HoldType = "physgun" 

SWEP.FiresUnderwater = true

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

SWEP.IronSightsPos  = Vector(-25, 6, -10)
SWEP.IronSightsAng  = Vector(0, 270, 0)

function SWEP:GetViewModelPosition(EyePos, EyeAng)
	local Mul = 1.0

	local Offset = self.IronSightsPos

	if (self.IronSightsAng) then
        EyeAng = EyeAng * 1
        
		EyeAng:RotateAroundAxis(EyeAng:Right(), 	self.IronSightsAng.x * Mul)
		EyeAng:RotateAroundAxis(EyeAng:Up(), 		self.IronSightsAng.y * Mul)
		EyeAng:RotateAroundAxis(EyeAng:Forward(),   self.IronSightsAng.z * Mul)
	end

	local Right 	= EyeAng:Right()
	local Up 		= EyeAng:Up()
	local Forward 	= EyeAng:Forward()

	EyePos = EyePos + Offset.x * Right * Mul
	EyePos = EyePos + Offset.y * Forward * Mul
	EyePos = EyePos + Offset.z * Up * Mul
	
	return EyePos, EyeAng
end

SWEP.Offset = {
	Pos = {
		Right = -2.5,
		Forward = 6.5,
		Up = 0,
	},
	Ang = {
		Right = 0,
		Forward = 40,
		Up = 250,
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