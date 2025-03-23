-- progress bar
local p_height = 2;
local total_time = clamp(Global.song:GetLastSecond(),1,math.huge);

local function ProgressBar(self)
    if not paused then
        local current_time = clamp(GAMESTATE:GetCurMusicSeconds(),0,math.huge);
        self:GetChild("Progress"):zoomto((SCREEN_WIDTH-2) * (current_time/total_time),p_height);
    end;
end

return Def.ActorFrame{
    OnCommand=function(self)
        self:SetUpdateFunction(ProgressBar)
    end,
    Def.Quad{
        InitCommand=cmd(diffuse,0,0,0,0.25;zoomto,SCREEN_WIDTH,p_height+2;horizalign,left;x,0;vertalign,top;y,SCREEN_TOP);
    },

    Def.Quad{
        Name="Progress",
        InitCommand=cmd(zoomto,0,2;horizalign,left;x,1;vertalign,top;y,SCREEN_TOP+1);
        OnCommand=cmd(diffuse,HighlightColor();diffuserightedge,BoostColor(HighlightColor(),2));
    },
};
