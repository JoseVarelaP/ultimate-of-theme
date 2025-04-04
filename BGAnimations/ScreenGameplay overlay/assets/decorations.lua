local t = Def.ActorFrame{
    InitCommand=cmd(diffusealpha,0);
    OnCommand=cmd(sleep,0.6;linear,1;diffusealpha,1);
}

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) then

        -- detail top
        t[#t+1] = LoadActor(THEME:GetPathG("","hex decoration"))..{
            InitCommand=cmd(diffuse,0.8,0.8,0.8,0.2;zoomx,0.8 * -pnSide(pn);zoomy,0.4;x,_screen.cx + (_screen.w/2 * pnSide(pn));horizalign,left;vertalign,top);     
        };

        -- detail bottom
        t[#t+1] = LoadActor(THEME:GetPathG("","hex decoration"))..{
            InitCommand=cmd(diffuse,0.8,0.8,0.8,0.15;zoomx,0.5 * -pnSide(pn);zoomy,-0.3;x,_screen.cx + (_screen.w/2 * pnSide(pn));y,_screen.h;horizalign,left;vertalign,top);
        };

        -- glow
        t[#t+1] = LoadActor(THEME:GetPathG("","glow"))..{
            InitCommand=cmd(diffuse,PlayerColor(pn);diffusealpha,0.2;zoomto,512,160;x,_screen.cx + (_screen.w/2 * pnSide(pn));;skewx,0.75*pnSide(pn));
        };

        --player
        t[#t+1] = Def.ActorFrame{
            InitCommand=cmd(y,SCREEN_BOTTOM-22;x,_screen.cx + (_screen.w/2 * pnSide(pn)) + (12 * -pnSide(pn)));
            -- player name
            Def.BitmapText{
                Font = Fonts.gameplay["Main"];
                InitCommand=cmd(zoom,0.5;strokecolor,0.15,0.15,0.15,1;horizalign,pnAlign(pn);vertalign,bottom);
                OnCommand=function(self)
                    local name = PROFILEMAN:GetProfile(pn):GetDisplayName();
                    if name == "" then
                        self:diffusealpha(0.33);
                        self:settext(THEME:GetString("Labels","NoProfile"));
                    else
                        self:diffusealpha(1);
                        self:settext(name);
                    end;
                end;
            },

            -- steps
            Def.BitmapText{
                Font = Fonts.gameplay["Main"];
                InitCommand=cmd(zoom,0.375;strokecolor,0.15,0.15,0.15,1;horizalign,pnAlign(pn);y,12;vertalign,bottom);
                OnCommand=function(self)
                    local steps = Global.pncursteps[pn] or GAMESTATE:GetCurrentSteps(pn);
                    local tint = StepsColor(steps);
                    local meter = "00";
                    if TotalNotes(steps) > 0 then
                        meter = FormatMeter(steps:GetMeter());
                    end;

                    self:diffuse(tint);
                    self:diffusetopedge(BoostColor(tint,9));
                    self:strokecolor(BoostColor(tint,0.2));
                    self:settext(PureType(steps).." "..meter);

                end;
            },
        };

    end;
end;

return t;