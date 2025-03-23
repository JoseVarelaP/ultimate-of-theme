local t = Def.ActorFrame{
	OnCommand=function(self)
		self:diffusealpha(0):sleep(1.5):linear(0.5):diffusealpha(1)
	end
}

t[#t+1] = LoadActor(THEME:GetPathB("ScreenWithMenuElements", "background"));

t[#t+1] = LoadActor(THEME:GetPathG("","border"))..{
	InitCommand=function(self)
		self:CenterX():y(SCREEN_TOP+32):zoom(-0.445):vertalign(top):diffuse(0.8,0.8,0.8,1)
	end,
	OnCommand=function (self)
		self:addy(-80):sleep(1.5):decelerate(0.5):addy(80)
	end
};
t[#t+1] = LoadActor(THEME:GetPathG("","footer"))..{
	InitCommand=function(self)
		self:CenterX():y(SCREEN_BOTTOM+8)
	end,
	OnCommand=function (self)
		self:addy(80):sleep(1.5):decelerate(0.5):addy(-80)
	end
};

--[[
t[#t+1] = Def.Sprite {
	InitCommand=cmd(Center;diffusealpha,1);
	BeginCommand=cmd(LoadFromCurrentSongBackground);
	OnCommand=function(self)
		if PREFSMAN:GetPreference("StretchBackgrounds") then
			self:SetSize(SCREEN_WIDTH,SCREEN_HEIGHT)
		else
			self:scale_or_crop_background()
		end
		self:linear(1)
		self:diffusealpha(0)
	end;
};
]]
return t;