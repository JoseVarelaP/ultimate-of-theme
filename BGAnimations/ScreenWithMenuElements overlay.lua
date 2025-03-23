--[[
local function Update(self,dt)
    Global.realH = tonumber(PREFSMAN:GetPreference("DisplayHeight"))
    Global.realW = Global.realH*(SCREEN_WIDTH/SCREEN_HEIGHT)
    Global.mouseX = math.floor(INPUTFILTER:GetMouseX())*(Global.realW/DISPLAY:GetDisplayWidth());
    Global.mouseY = math.floor(INPUTFILTER:GetMouseY())*(Global.realH/DISPLAY:GetDisplayHeight());
    Global.debounce = Global.debounce - dt;
    if Global.debounce < 0 then Global.debounce = 0 end;
    Global.delta = dt;
    MESSAGEMAN:Broadcast("Update");
end;

local t = MouseInputActor()..{
    InitCommand=function(self) self:SetUpdateFunction(Update); end;
    FinalDecisionMessageCommand=function(self) self:SetUpdateFunction(nil); end;
    MenuInputMessageCommand=function(self,param)  end;
}
]]

local t = Def.ActorFrame{}

--=======================================================================================================================
--NAVIGATION ICONS
--=======================================================================================================================

--[[
local function IsScreen(name)
    return SCREENMAN:GetTopScreen():GetName() == name
end

local Navigation = {
    {Icon = 1, Screen= "ScreenProfileLoad", Enabled = "ScreenSelectMusicCustom"},
    {Icon = 2, Screen= "ScreenOptionsManageProfiles", Enabled = true},
    {Icon = 3, Screen= "ScreenReloadSongsCache", Enabled = "ScreenReloadSongsCache"},
    {Icon = 4, Screen= "ScreenTitleMenu", Enabled = "ScreenTitleMenu"},
    {Icon = 5, Screen= "ScreenOptionsService", Enabled = "ScreenOptionsService"},
    {Icon = 6, Screen= "ScreenExit", Enabled = true}
}

local icon_spacing = 27
for i=1,#Navigation do
    t[#t+1] = LoadActor(THEME:GetPathG("","navigation"))..{
        InitCommand=cmd(x,(SCREEN_CENTER_X+(icon_spacing*i))-(icon_spacing*((#Navigation+1)/2));zoom,0.425;animate,false;y,SCREEN_BOTTOM-42+4);
        OnCommand=function(self)
            if IsScreen("ScreenReloadSongsCache") then
                self:y(SCREEN_BOTTOM+300)
            end

            self:setstate(Navigation[i].Icon-1)
            if type(Navigation[i].Enabled) == "string" then
                self.disabled = IsScreen(Navigation[i].Enabled)
            end
        end,
        FinalDecisionMessageCommand=function(self)
            self:sleep(0.1):linear(0.5):diffusealpha(0)
        end,
        GainFocusCommand=cmd(diffuse,0.45,0.9,1,1);
        LoseFocusCommand=cmd(diffuse,1,1,1,1);
        DisabledCommand=cmd(diffuse,0.75,0.75,0.75,0.5);
        UpdateMessageCommand=function(self)
            ButtonHover(self,0.4,self.disabled);
        end;
        MouseLeftClickMessageCommand=function(self,params)
            if params.IsPressed then 
                MouseDown(self,0.4,Navigation[i].Screen,self.disabled); 
            end
        end;
    };
end;
]]

return t