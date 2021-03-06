ENT.Base = "swvr_base"

ENT.Category = "CIS"
ENT.Class = "Interceptor"

ENT.PrintName = "Droid Tri-Fighter"
ENT.Author = "Servius"

if SERVER then
  AddCSLuaFile()

  function ENT:SpawnFunction(ply, tr, ClassName)
    if not tr.Hit then
      return
    end

    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 5)
    ent:SetAngles(Angle(0, ply:GetAimVector():Angle().Yaw, 0))
    ent:Spawn()
    ent:Activate()

    return ent
  end

  function ENT:Initialize()
    self:Setup({
      Model = "models/swbf3/vehicles/cis_tri-fighter.mdl",
      Health = 750,
      Speed = 1500,
      BoostSpeed = 2250,
      VerticalSpeed = 550,
      Acceleration = 9,
      Roll = true,
    })

    self:AddWeaponGroup("Pilot", "ls1_cannon", {
      Delay = 0.1,
      Damage = 25,
      Color = "red",
      CanOverheat = true,
      MaxOverheat = 20
    })

    self:AddWeapon("Pilot", "MainT", Vector(102, 0, 154)) -- distance from center, left right, up down.
    self:AddWeapon("Pilot", "MainR", Vector(102, 73, 20))
    self:AddWeapon("Pilot", "MainL", Vector(102, -73, 20))

    self:AddWeaponGroup("Center", "gn40_cannon", {
      Delay = 0.5,
      Damage = 80,
      CanOverheat = true,
      MaxOverheat = 10,
      Cooldown = 10
    })

    self:AddWeapon("Center", "Center", Vector(130, 0, 65))

    self:AddWeaponGroup("Torpedo", "swvr_base_missile", {
      Delay = 2,
      Callback = function()
        local group = self:GetBodygroup(1) == 1 and 2 or 1

        self:SetBodygroup(group, 1)

        timer.Simple(4.1, function()
          if not IsValid(self) then return end
          self:SetBodygroup(group, 0)
        end)
      end
    })

    self:AddWeapon("Torpedo", "Missile1", Vector(170, 3, 30))

    self:AddPilot(nil, nil, {
      FPVPos = Vector(80, 0, 80),
      Weapons = { "Pilot", "Center", "Torpedo" }
    })

    self.BaseClass.Initialize(self)
  end
end

if CLIENT then
  function ENT:Initialize()
    self:Setup({
      Cockpit = "vgui/droid_cockpit",
      AlwaysDraw = true,
      EngineSound = "vehicles/droid/droid_fly.wav",
      ViewDistance = 700,
      ViewHeight = 200
    })

    self:SetupDefaults()

    self:AddEngine(Vector(-140, 30, 47), { -- distance from center, left right, up down.
      StartSize = 15,
      EndSize = 13.5,
      Lifetime = 2.7,
      Color = Color(150, 100, 0),
      Sprite = "sprites/orangecore1"
    })

    self:AddEngine(Vector(-140, 0, 96), {
      StartSize = 15,
      EndSize = 13.5,
      Lifetime = 2.7,
      Color = Color(150, 100, 0),
      Sprite = "sprites/orangecore1"
    })

    self:AddEngine(Vector(-140, -30, 47), {
      StartSize = 15,
      EndSize = 13.5,
      Lifetime = 2.7,
      Color = Color(150, 100, 0),
      Sprite = "sprites/orangecore1"
    })

    self.BaseClass.Initialize(self)
  end
end
