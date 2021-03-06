
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "fighter_base"
ENT.Type = "vehicle"

ENT.PrintName = "Majestic"
ENT.Author = "Liam0102, Nashatok"
ENT.Category = "Star Wars Vehicles: Rebels"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;
ENT.AdminOnly = true;

ENT.EntModel = "models/fp_majestic/fp_majestic.mdl"
ENT.Vehicle = "fp_majestic"
ENT.StartHealth = 18000;
ENT.DontLock = true;
ENT.IsCapitalShip = true;
ENT.Allegiance = "Rebels";
list.Set("SWVehiclesEU", ENT.PrintName, ENT);

if SERVER then

ENT.FireSound = Sound("weapons/xwing_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),LightSpeed=CurTime(),Switch=CurTime(),};
ENT.HyperDriveSound = Sound("vehicles/hyperdrive.mp3");

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("fp_majestic");
	e:SetPos(tr.HitPos + Vector(0,0,500));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw+180,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()


	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*-500+self:GetUp()*-700+self:GetRight()*-500,
		Right = self:GetPos()+self:GetForward()*-500+self:GetUp()*-700+self:GetRight()*500,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 1500;
	self.ForwardSpeed = 800;
	self.UpSpeed = 500;
	self.AccelSpeed = 16;
	self.CanStandby = true;
	self.CanBack = true;
	self.CanRoll = false;
	self.CanStrafe = false;
	self.Cooldown = 2;
	self.HasWings = false;
	self.CanShoot = false;
	self.Bullet = CreateBulletStructure(125,"red",false);
	self.FireDelay = 0.75;
	self.HasLightspeed = true;
	
	self.SeatPos = {
		{self:GetPos()+self:GetUp()*100+self:GetForward()*75+self:GetRight()*500, self:GetAngles()+Angle(0,180,0)},
		{self:GetPos()+self:GetUp()*100+self:GetForward()*-75+self:GetRight()*-500, self:GetAngles()},
	}
	self.GunnerSeats = {};
	self:SpawnGunnerSeats();

	self.WeaponLocations = {
		Right = self:GetPos()+self:GetForward()*120+self:GetUp()*45+self:GetRight()*87,
		Left = self:GetPos()+self:GetForward()*120+self:GetUp()*43+self:GetRight()*-80,
	}
	self.WeaponsTable = {};
	
	self.LeftWeaponLocations = {
		self:GetPos()+self:GetUp()*25+self:GetForward()*-150+self:GetRight()*700,
		self:GetPos()+self:GetUp()*50+self:GetForward()*-175+self:GetRight()*700,
		self:GetPos()+self:GetUp()*25+self:GetForward()*-200+self:GetRight()*700,
		
		self:GetPos()+self:GetUp()*25+self:GetForward()*150+self:GetRight()*700,
		self:GetPos()+self:GetUp()*50+self:GetForward()*175+self:GetRight()*700,
		self:GetPos()+self:GetUp()*25+self:GetForward()*200+self:GetRight()*700,
		
	}
	

	
	self.RightWeaponLocations = {
		self:GetPos()+self:GetUp()*25+self:GetForward()*-50+self:GetRight()*-700,
		self:GetPos()+self:GetUp()*25+self:GetForward()*-100+self:GetRight()*-700,
		self:GetPos()+self:GetUp()*50+self:GetForward()*-75+self:GetRight()*-700,

		self:GetPos()+self:GetUp()*25+self:GetForward()*50+self:GetRight()*-700,
		self:GetPos()+self:GetUp()*50+self:GetForward()*75+self:GetRight()*-700,
		self:GetPos()+self:GetUp()*25+self:GetForward()*100+self:GetRight()*-700,
		
	}

	self.ExitModifier = {x=0,y=300,z= -320};
	
	self.BaseClass.Initialize(self);
	
	self:GetPhysicsObject():SetMass(1000000)
end


function ENT:Think()

	if(IsValid(self.LeftGunner)) then
		if(self.GunnerSeats[1]:GetThirdPersonMode()) then
			self.GunnerSeats[1]:SetThirdPersonMode(false);
		end
		if(self.LeftGunner:KeyDown(IN_ATTACK)) then
			self:FireLeft(self.LeftGunner:GetAimVector():Angle():Forward());
		end
	end
	
	if(IsValid(self.RightGunner)) then
		if(self.GunnerSeats[2]:GetThirdPersonMode()) then
			self.GunnerSeats[2]:SetThirdPersonMode(false);
		end
		if(self.RightGunner:KeyDown(IN_ATTACK)) then
			self:FireRight(self.RightGunner:GetAimVector():Angle():Forward());
		end
	end

	
	self.BaseClass.Think(self);
end

hook.Add("PlayerLeaveVehicle", "majesticSeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.IsmajesticSeat) then
			local e = v:GetParent();
			if(v.IsRight) then
				e:GunnerExit(true,p);
				p:SetNWBool("RightGunner_majestic",false);
			else
				e:GunnerExit(false,p);
				p:SetNWBool("LeftGunner_majestic",false);
			end
		end
	end
end);

function ENT:FireLeft(angPos)

	if(self.NextUse.Fire < CurTime()) then
		for k,v in pairs(self.LeftWeapons) do

			self.Bullet.Attacker = self.Pilot or self;
			self.Bullet.Src		= v:GetPos();
			self.Bullet.Dir = angPos

			v:FireBullets(self.Bullet)
		end
		self:EmitSound(self.FireSound,100,math.random(85,115));
		self.NextUse.Fire = CurTime() + (self.FireDelay or 0.2);
	end
end

function ENT:FireRight(angPos)

	if(self.NextUse.Fire < CurTime()) then
		for k,v in pairs(self.RightWeapons) do

			self.Bullet.Attacker = self.Pilot or self;
			self.Bullet.Src		= v:GetPos();
			self.Bullet.Dir = angPos

			v:FireBullets(self.Bullet)
		end
		self:EmitSound(self.FireSound,100,math.random(85,115));
		self.NextUse.Fire = CurTime() + (self.FireDelay or 0.2);
	end
end

function ENT:SpawnWeapons()
	self.LeftWeapons = {};
	self.RightWeapons = {};
	for k,v in pairs(self.LeftWeaponLocations) do
		local e = ents.Create("prop_physics");
		e:SetModel("models/props_junk/PopCan01a.mdl");
		e:SetPos(v);
		e:Spawn();
		e:Activate();
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetSolid(SOLID_NONE);
		e:AddFlags(FL_DONTTOUCH);
		e:SetColor(Color(255,255,255,0));
		e:SetParent(self);
		e:GetPhysicsObject():EnableMotion(false);
		self.LeftWeapons[k] = e;
	end

	for k,v in pairs(self.RightWeaponLocations) do
		local e = ents.Create("prop_physics");
		e:SetModel("models/props_junk/PopCan01a.mdl");
		e:SetPos(v);
		e:Spawn();
		e:Activate();
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetSolid(SOLID_NONE);
		e:AddFlags(FL_DONTTOUCH);
		e:SetColor(Color(255,255,255,0));
		e:SetParent(self);
		e:GetPhysicsObject():EnableMotion(false);
		self.RightWeapons[k] = e;
	end
end

function ENT:SpawnGunnerSeats()
	
	for k,v in pairs(self.SeatPos) do
		local e = ents.Create("prop_vehicle_prisoner_pod");
		e:SetPos(v[1]);
		e:SetAngles(v[2]);
		e:SetParent(self);
		e:SetModel("models/nova/airboat_seat.mdl");
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetColor(Color(255,255,255,0));
		e:Spawn();
		e:Activate();
		e:SetThirdPersonMode(false);
		e:GetPhysicsObject():EnableMotion(false);
		e:GetPhysicsObject():EnableCollisions(false);
		self.GunnerSeats[k] = e;
		if(k == 2) then
			e.IsRight = true;
		end
		e.IsmajesticSeat = true;
	end
end

function ENT:Use(p)


	if(!self.Inflight and !p:KeyDown(IN_WALK)) then
		self:Enter(p);
	else
		if(!self.LeftGunner) then
			self:GunnerEnter(p,false);
		else
			self:GunnerEnter(p,true);
		end
	end

end

function ENT:GunnerEnter(p,right)
	if(self.NextUse.Use < CurTime()) then
		if(!right) then
			if(!IsValid(self.LeftGunner)) then
				p:SetNWBool("LeftGunner",true);
				self.LeftGunner = p;
				p:EnterVehicle(self.GunnerSeats[1]);
			end
		else
			if(!IsValid(self.RightGunner)) then
				p:SetNWBool("RightGunner",true);
				self.RightGunner = p;
				p:EnterVehicle(self.GunnerSeats[2]);
			end
		end
		p:SetNWEntity(self.Vehicle,self);
		self.NextUse.Use = CurTime() + 1;
	end
end

function ENT:GunnerExit(right,p)

	if(!right) then
		if(IsValid(self.LeftGunner)) then
			self.LeftGunner:SetNWBool("LeftGunner",false);
			self.LeftGunner = NULL;
		end
	else
		if(IsValid(self.RightGunner)) then
			self.RightGunner:SetNWBool("RightGunner",false);
			self.RightGunner = NULL;
		end
	end
	p:SetPos(self:GetPos()+self:GetRight()*2000);
	p:SetNWEntity(self.Vehicle,NULL);


end

local FlightPhys = {
	secondstoarrive	= 1;
	maxangular		= 5000;
	maxangulardamp	= 10000;
	maxspeed			= 1000000;
	maxspeeddamp		= 500000;
	dampfactor		= 0.8;
	teleportdistance	= 5000;
};
local ZAxis = Vector(0,0,1);
function ENT:PhysicsSimulate(phys,delta)
	local FWD = self:GetForward()*-1;
	local UP = ZAxis;
	local RIGHT = FWD:Cross(UP):GetNormalized();
	if(self.Inflight) then
		phys:Wake();
		if(self.Pilot:KeyDown(IN_FORWARD) and (self.Wings or self.Pilot:KeyDown(IN_SPEED))) then
			self.num = self.BoostSpeed;
		elseif(self.Pilot:KeyDown(IN_FORWARD)) then
			self.num = self.ForwardSpeed;
		elseif(self.Pilot:KeyDown(IN_BACK) and self.CanBack) then
			self.num = (self.ForwardSpeed / 2)*-1;
		else
			self.num = 0;
		end

		self.Accel.FWD = math.Approach(self.Accel.FWD,self.num,self.Acceleration);
		
		if(self.Pilot:KeyDown(IN_MOVERIGHT)) then
			self.TurnYaw = Angle(0,-5,0);
		elseif(self.Pilot:KeyDown(IN_MOVELEFT)) then
			self.TurnYaw = Angle(0,5,0);
		else
			self.TurnYaw = Angle(0,0,0);
		end
		local ang = self:GetAngles() + self.TurnYaw;
		
		if(self.Pilot:KeyDown(IN_JUMP)) then
			self.num3 = self.UpSpeed;
		elseif(self.Pilot:KeyDown(IN_DUCK)) then
			self.num3 = -self.UpSpeed;
		else
			self.num3 = 0;
		end
		self.Accel.UP = math.Approach(self.Accel.UP,self.num3,self.Acceleration*0.9);
		
		--######### Do a tilt when turning, due to aerodynamic effects @aVoN
		local velocity = self:GetVelocity();
		local aim = self.Pilot:GetAimVector();
		--local ang = aim:Angle();
		
		
		local weight_roll = (phys:GetMass()/1000)/1.5
		local pos = self:GetPos()
		local ExtraRoll = math.Clamp(math.deg(math.asin(self:WorldToLocal(pos).y)),-25-weight_roll,25+weight_roll); -- Extra-roll - When you move into curves, make the shuttle do little curves too according to aerodynamic effects
		local mul = math.Clamp((velocity:Length()/1700),0,1); -- More roll, if faster.
		local oldRoll = ang.Roll;
		ang.Roll = (ang.Roll + self.Roll - ExtraRoll*mul) % 360;
		if (ang.Roll!=ang.Roll) then ang.Roll = oldRoll; end -- fix for nan values that cause despawing/crash.

	
		FlightPhys.angle = ang; --+ Vector(90 0, 0)
		FlightPhys.deltatime = deltatime;
		if(self.CanStrafe) then
			FlightPhys.pos = self:GetPos()+(FWD*self.Accel.FWD)+(UP*self.Accel.UP)+(RIGHT*self.Accel.RIGHT);
		else
			FlightPhys.pos = self:GetPos()+(FWD*self.Accel.FWD)+(UP*self.Accel.UP);
		end

		if(!self.CriticalDamage) then
			phys:ComputeShadowControl(FlightPhys);
		end
	else
		if(self.ShouldStandby and self.CanStandby) then
			FlightPhys.angle = self.StandbyAngles or Angle(0,self:GetAngles().y,0);
			FlightPhys.deltatime = deltatime;
			FlightPhys.pos = self:GetPos()+UP;
			phys:ComputeShadowControl(FlightPhys);		
		end
	end
		
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
	function ENT:Draw() self:DrawModel() end;
	local LightSpeed = 0;
	function ENT:Think()
		self.BaseClass.Think(self);
		local p = LocalPlayer();
		local IsFlying = p:GetNWEntity(self.Vehicle);
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		if(IsFlying) then
			LightSpeed = self:GetNWInt("LightSpeed");
		end
		
		if(Flying) then
			self.EnginePos = {
				self:GetPos()+self:GetForward()*1800+self:GetUp()*-30+self:GetRight()*180,
				self:GetPos()+self:GetForward()*1800+self:GetUp()*-30+self:GetRight()*-180,
				self:GetPos()+self:GetForward()*1800+self:GetUp()*50+self:GetRight()*180,
				self:GetPos()+self:GetForward()*1800+self:GetUp()*50+self:GetRight()*-180,
				self:GetPos()+self:GetForward()*1800+self:GetUp()*10+self:GetRight()*180,
				self:GetPos()+self:GetForward()*1800+self:GetUp()*10+self:GetRight()*-180,
			}
			self:Effects();
		end
	end	
	
    ENT.ViewDistance = -5000;
	ENT.ViewHeight = 350;
	
	hook.Add( "ShouldDrawLocalPlayer", "majesticDrawPlayerModel", function( p )
		local sat = p:GetNWBool("LeftGunner_majestic")
		local sat2 = p:GetNWBool("RightGunner_majestic")
		if(sat or sat2) then
			return false;
		end
	end);
	
	function ENT:Effects()

		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetForward() * 1):GetNormalized();
		local id = self:EntIndex();
		local FWD = self:GetForward();
		for k,v in pairs(self.EnginePos) do

			local heatwv = self.Emitter:Add("sprites/heatwave",v+FWD*300);
			heatwv:SetVelocity(normal*2);
			heatwv:SetDieTime(0.1);
			heatwv:SetStartAlpha(255);
			heatwv:SetEndAlpha(255);
			heatwv:SetStartSize(85);
			heatwv:SetEndSize(50);
			heatwv:SetColor(255,255,255);
			heatwv:SetRoll(roll);
			
			local blue = self.Emitter:Add("sprites/orangecore1",v+FWD*300)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.1)
			blue:SetStartAlpha(255)
			blue:SetEndAlpha(255)
			blue:SetStartSize(85)
			blue:SetEndSize(50)
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

	--ENT.CanFPV = false;
	local HUD = surface.GetTextureID("vgui/majestic_cockpit")
	function majesticReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("Flyingmajestic");
		local self = p:GetNWEntity("majestic");
		local LeftGunner = p:GetNWBool("LeftGunner_majestic");
		local RightGunner = p:GetNWBool("RightGunner_majestic");
		if(Flying and IsValid(self)) then
			local FPV = self:GetFPV();
			if(FPV) then
				SW_HUD_FPV(HUD);
			end

			local x = ScrW()/10;
			local y = ScrH()/4*3.5;
			SW_HUD_DrawHull(18000,x,y);		
			
		elseif(LeftGunner and IsValid(self)) then

			local WeaponsPos = {
				self:GetPos()+self:GetUp()*25+self:GetForward()*-150+self:GetRight()*700,
				self:GetPos()+self:GetUp()*50+self:GetForward()*-175+self:GetRight()*700,
				self:GetPos()+self:GetUp()*25+self:GetForward()*-200+self:GetRight()*700,
		
				self:GetPos()+self:GetUp()*25+self:GetForward()*150+self:GetRight()*700,
				self:GetPos()+self:GetUp()*50+self:GetForward()*175+self:GetRight()*700,
				self:GetPos()+self:GetUp()*25+self:GetForward()*200+self:GetRight()*700,
			}
			
			for i=1,8 do
				local tr = util.TraceLine( {
					start = WeaponsPos[i],
					endpos = WeaponsPos[i] + p:GetAimVector():Angle():Forward()*10000,
				} )

				surface.SetTextColor( 255, 255, 255, 255 );
				
				local vpos = tr.HitPos;
				
				local screen = vpos:ToScreen();
				
				surface.SetFont( "HUD_Crosshair" );	
				local tsW, tsH = surface.GetTextSize("+");
				
				local x,y;
				for k,v in pairs(screen) do
					if k=="x" then
						x = v - tsW/2;
					elseif k=="y" then
						y = v - tsH/2;
					end
				end
				
							
				surface.SetTextPos( x, y );
				surface.DrawText( "+" );
			end
		elseif(RightGunner and IsValid(self)) then
			local WeaponsPos = {
				self:GetPos()+self:GetUp()*25+self:GetForward()*-50+self:GetRight()*-700,
				self:GetPos()+self:GetUp()*25+self:GetForward()*-100+self:GetRight()*-700,
				self:GetPos()+self:GetUp()*50+self:GetForward()*-75+self:GetRight()*-700,

				self:GetPos()+self:GetUp()*25+self:GetForward()*50+self:GetRight()*-700,
				self:GetPos()+self:GetUp()*50+self:GetForward()*75+self:GetRight()*-700,
				self:GetPos()+self:GetUp()*25+self:GetForward()*100+self:GetRight()*-700,			
			}
			
			for i=1,8 do
				local tr = util.TraceLine( {
					start = WeaponsPos[i],
					endpos = WeaponsPos[i] + p:GetAimVector():Angle():Forward()*10000,
				} )

				surface.SetTextColor( 255, 255, 255, 255 );
				
				local vpos = tr.HitPos;
				
				local screen = vpos:ToScreen();
				
				surface.SetFont( "HUD_Crosshair" );	
				local tsW, tsH = surface.GetTextSize("+");
				
				local x,y;
				for k,v in pairs(screen) do
					if k=="x" then
						x = v - tsW/2;
					elseif k=="y" then
						y = v - tsH/2;
					end
				end
				
							
				surface.SetTextPos( x, y );
				surface.DrawText( "+" );
			end
		end
	end
	hook.Add("HUDPaint", "MajesticReticle", MajesticReticle)

end