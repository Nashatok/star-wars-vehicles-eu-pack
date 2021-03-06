
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "Soulless Two"
ENT.Author = "Servius"
ENT.Category = "Star Wars Vehicles: CIS"; 
list.Set("SWVehiclesEU", ENT.PrintName, ENT);
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/ship_belbu/ship_belbu_servius.mdl"
ENT.Vehicle = "soulless_servius"
ENT.StartHealth = 1500;
ENT.Allegiance = "CIS";

if SERVER then

ENT.FireSound = Sound("weapons/tie_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};


AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("soulless_servius");
	e:SetPos(tr.HitPos + Vector(0,0,70));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+180,0));
	e:Spawn();
	e:Activate();
	return e;
end
function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetUp()*40+self:GetForward()*100+self:GetRight()*-80,
		Right = self:GetPos()+self:GetUp()*40+self:GetForward()*100+self:GetRight()*80,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2250;
	self.ForwardSpeed = 1200;
	self.UpSpeed = 550;
	self.AccelSpeed = 7;
	self.CanStandby = true;
	self.CanBack = false;
	self.CanRoll = true;
	self.Cooldown = 2;
 	self.LandOffset = Vector(0,0,70);-- Change the last 0 if you're vehicle is having trouble landing properly. (Make it larger)
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(50,"red");
	self.FireDelay = 0;
	self.AlternateFire = true;
	self.FireGroup = {"Left","Right",};

	--self.ExitModifier = {x=0,y=225,z=100};
	
	self.BaseClass.Initialize(self);
end


end

if CLIENT then
	
	ENT.CanFPV = false;
	ENT.Sounds={
		Engine=Sound("ambient/atmosphere/ambience_base.wav"),
	}
	
	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
	end
	
	local View = {}
	local function CalcView()
		
		local p = LocalPlayer();
		local self = p:GetNetworkedEntity("soulless_servius", NULL)
		if(IsValid(self)) then
			View = SWVehicleView(self,700,300,fpvPos);		
			return View;
		end
	end
	hook.Add("CalcView", "soulless_serviusView", CalcView)
	
	function ENT:Effects()
	
		self.ThrusterLocations = {
			self:GetPos()+self:GetUp()*0+self:GetForward()*-200+self:GetRight()*-30,
			self:GetPos()+self:GetUp()*0+self:GetForward()*-200+self:GetRight()*30,
		}
		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetForward() * -1):GetNormalized();
		local id = self:EntIndex();
		for k,v in pairs(self.ThrusterLocations) do

			local heatwv = self.Emitter:Add("sprites/heatwave",v);
			heatwv:SetVelocity(normal*2);
			heatwv:SetDieTime(0.1);
			heatwv:SetStartAlpha(255);
			heatwv:SetEndAlpha(255);
			heatwv:SetStartSize(15);
			heatwv:SetEndSize(5);
			heatwv:SetColor(255,255,255);
			heatwv:SetRoll(roll);
			
			local blue = self.FXEmitter:Add("sprites/bluecore",v)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.05)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(255)
			blue:SetStartSize(15)
			blue:SetEndSize(5)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)
			
			local dynlight = DynamicLight(id + 4096 * k);
			dynlight.Pos = v;
			dynlight.Brightness = 5;
			dynlight.Size = 150;
			dynlight.Decay = 1024;
			dynlight.R = 100;
			dynlight.G = 100;
			dynlight.B = 255;
			dynlight.DieTime = CurTime()+1;

		end
	end
	
	function ENT:Think()
	
		self.BaseClass.Think(self)
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			if(!TakeOff and !Land) then
				self:Effects();
			end
		end
		
	end
	
	function soulless_serviusReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("Flyingsoulless_servius");
		local self = p:GetNWEntity("soulless_servius");
		if(Flying and IsValid(self)) then
			
			SW_HUD_DrawHull(1500);
			SW_WeaponReticles(self);
			SW_HUD_DrawOverheating(self);

			SW_HUD_Compass(self);
			SW_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "soulless_serviusReticle", soulless_serviusReticle)

end