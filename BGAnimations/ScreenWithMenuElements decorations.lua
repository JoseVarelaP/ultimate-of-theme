local t = Def.ActorFrame{}

local spacing = 290;

--=======================================================================================================================
--DECORATIONS (LITERALLY)
--=======================================================================================================================

	t[#t+1] = LoadActor(THEME:GetPathG("","border"))..{
			InitCommand=cmd(CenterX;y,SCREEN_TOP+32;zoom,-0.445;vertalign,top;diffuse,0.8,0.8,0.8,1);
	};
	t[#t+1] = LoadActor(THEME:GetPathG("","footer"))..{
			InitCommand=cmd(CenterX;y,SCREEN_BOTTOM+8);
	};

	-- version
	t[#t+1] = LoadFont("regen small")..{
			InitCommand=cmd(horizalign,left;x,SCREEN_CENTER_X-spacing;y,SCREEN_TOP+20;zoomx,0.317;zoomy,0.305);
			OnCommand=function(self)
					self:diffuse(0.66,0.66,0.66,0.5);
					self:strokecolor(0.1,0.1,0.1,1);

					local ver = ProductVersion();
					ver = string.gsub(string.lower(ver), "-unknown", "-test");

					self:settext(string.upper( ProductFamily() .." "..ver));
			end;
	};
	
	-- date and time
	t[#t+1] = LoadFont("regen small")..{
			InitCommand=cmd(horizalign,right;x,SCREEN_CENTER_X+spacing;y,SCREEN_TOP+20;zoomx,0.317;zoomy,0.305);
			OnCommand=function(self)
				self:diffuse(0.66,0.66,0.66,0.5);
				self:strokecolor(0.1,0.1,0.1,1);
				self:playcommand("UpdateClock")
			end;
			OffCommand=function(self)
				self:stoptweening()
			end,

			UpdateClockCommand=function(self)
				local hour = CapDigits(Hour(), 0, 2);
				local min = CapDigits(Minute(), 0, 2);
				local sec = CapDigits(Second(), 0, 2);
				local time = hour..":"..min..":"..sec;

				local month = CapDigits(MonthOfYear()+1, 0, 2);
				local day = CapDigits(DayOfMonth(), 0, 2);

				local date = Year().."-"..month.."-"..day;

				self:settext(date.."     "..time);
				self:sleep(0.5):queuecommand("UpdateClock")
			end;	
	};

--=======================================================================================================================
--PROFILE BUTTONS
--=======================================================================================================================

--[[
	for pn in ivalues({PLAYER_1,PLAYER_2}) do
		t[#t+1] = Def.Quad{
				InitCommand=cmd(zoomto,190,40;diffuse,1,0,0,0;y,SCREEN_BOTTOM-36+4);
				OnCommand=function(self) if pn == PLAYER_1 then self:x(SCREEN_CENTER_X-220) elseif pn == PLAYER_2 then self:x(SCREEN_CENTER_X+220); end; end;
				UpdateMessageCommand=function(self) if ButtonHover(self,pn.." panel",1) then MESSAGEMAN:Broadcast("ProfilePanel",{Player=pn}); end; end;
		};
	end
]]--

--=======================================================================================================================
-- RESOLUTION DEBUG HELPERS
--=======================================================================================================================

if not true then
	local lines_color = {1,0,0,1};
	t[#t+1] = Def.Quad{ InitCommand=cmd(zoomto,300,SCREEN_HEIGHT;CenterY;x,SCREEN_CENTER_X-320;horizalign,right;diffuse,0,0,0,0.5) }; --right 16:9 fill
	t[#t+1] = Def.Quad{ InitCommand=cmd(zoomto,300,SCREEN_HEIGHT;CenterY;x,SCREEN_CENTER_X+320;horizalign,left;diffuse,0,0,0,0.5) }; --left 16:9 fill
	t[#t+1] = Def.Quad{ InitCommand=cmd(zoomto,1,SCREEN_HEIGHT;CenterY;x,SCREEN_CENTER_X+320;diffuse,lines_color) }; --right 4:3 line
	t[#t+1] = Def.Quad{ InitCommand=cmd(zoomto,1,SCREEN_HEIGHT;CenterY;x,SCREEN_CENTER_X-320;diffuse,lines_color) }; --left 4:3 line
	t[#t+1] = Def.Quad{ InitCommand=cmd(zoomto,1,SCREEN_HEIGHT;CenterY;x,SCREEN_CENTER_X;diffuse,lines_color) }; --center vertical line
	t[#t+1] = Def.Quad{ InitCommand=cmd(zoomto,SCREEN_WIDTH,1;CenterY;x,SCREEN_CENTER_X;diffuse,lines_color) }; --center horizontal line
end;

--=======================================================================================================================
--CONTROLS
--=======================================================================================================================
t[#t+1] = Def.Actor{
	PlayerJoinedMessageCommand=function(self,params) 
		--if Global.blockjoin then 
		--	GAMESTATE:UnjoinPlayer(params.Player) 
		--end; 
	end;
};

--=======================================================================================================================
--BLANK TRANSITION
--=======================================================================================================================

t[#t+1] = LoadActor(THEME:GetPathG("","bg"))..{
	InitCommand=cmd(Center;diffuse,Global.bgcolor;diffusealpha,0);
	FinalDecisionMessageCommand=cmd(diffusealpha,0;sleep,0.1;linear,0.5;diffusealpha,1);
};


return t;