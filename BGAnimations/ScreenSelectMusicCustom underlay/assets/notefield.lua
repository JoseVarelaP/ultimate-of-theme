
local curTime = -1;
local bpm = 60;
local curskin = {
    [PLAYER_1] = "",
    [PLAYER_2] = "",
}

local function UpdateTime(self, delta)
    curTime = GAMESTATE:GetCurMusicSeconds();
    -- MESSAGEMAN:Broadcast("UpdateNotefield");
end

local function CanShowNotefield()
    if Global.state == "SelectSteps" or Global.oplist[PLAYER_1] or Global.oplist[PLAYER_2] then return true end;
    return false;
end;

local t = Def.ActorFrame{
    InitCommand=function(self)
        --[[self:SetUpdateFunction(UpdateTime);]]
        self:diffusealpha(0);
    end;
    StateChangedMessageCommand=cmd(playcommand,"Refresh");
    OptionsListOpenedMessageCommand=cmd(playcommand,"Refresh");
    OptionsListClosedMessageCommand=cmd(playcommand,"Refresh");
    RefreshCommand=function(self)
        self:stoptweening();
        self:linear(0.15);
        if CanShowNotefield() then
            self:diffusealpha(1);
        else
            self:diffusealpha(0);
        end;
    end;
} 

local tex = Def.ActorFrameTexture{
    InitCommand= function(self)
        self:setsize(_screen.w, _screen.h)
        self:SetTextureName("notefield_overlay")
        self:EnableAlphaBuffer(true);
        self:EnablePreserveTexture(false)
        self:Create();
    end;
}

-- <Kyzentun> Luizsan: Yeah, it's touchy about the order.  I tried to make it less 
-- touchy in the notefield_targets branch, but good luck finding someone to build that.
for pn in ivalues(GAMESTATE:GetHumanPlayers()) do

    local PlayerToPreview = ( GAMESTATE:IsPlayerEnabled(pn) and pn or GAMESTATE:GetMasterPlayerNumber() )
    -- Load preview notefield
    local isDouble = GAMESTATE:GetCurrentStyle():GetStyleType() == "StyleType_OnePlayerTwoSides"
    local def_ds  = THEME:GetMetric("Player","DrawDistanceBeforeTargetsPixels")
    local def_dsb = THEME:GetMetric("Player","DrawDistanceAfterTargetsPixels")
    local receptposnorm = THEME:GetMetric("Player","ReceptorArrowsYStandard")
    local receptposreve = THEME:GetMetric("Player","ReceptorArrowsYReverse")
    local yoffset = receptposreve-receptposnorm
    local notefieldmid = (receptposnorm + receptposreve)/2
    local PlayerOptions = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
    local height_ratio = SCREEN_HEIGHT/480

    local notefieldWidth = GAMESTATE:GetStyleFieldSize(pn)

    tex[#tex+1] = Def.NoteField{
        Player= tonumber( string.sub(PlayerToPreview,-1) )-1,
        AutoPlay = true,
        Chart = "Invalid",
        NoteSkin= PlayerOptions:NoteSkin(),--With this, I can make extra notefields take on the appearance of P1/P2. -Kid
        DrawDistanceAfterTargetsPixels= def_dsb,
        SendMessageOnStep = true,
        DrawDistanceBeforeTargetsPixels= def_ds,
        YReverseOffsetPixels= yoffset,--REVERSE minus STANDARD
        FieldID= 0,

        InitCommand=function(self)
            self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
            if GAMESTATE:IsPlayerEnabled(PLAYER_1) and GAMESTATE:IsPlayerEnabled(PLAYER_2) then
                self:x( SCREEN_CENTER_X + 150 * pnSide(pn) )
            end
        end,

        OnCommand=function(self)
            local tempstate = GAMESTATE:GetPlayerState(pn)
            local modstring = tempstate:GetPlayerOptionsString("ModsLevel_Preferred")
            self:ModsFromString( modstring )
        end,

        StepsChangedMessageCommand=cmd(playcommand,"Refresh");
        SpeedChangedMessageCommand=cmd(playcommand,"Refresh");
        FolderChangedMessageCommand=cmd(playcommand,"Refresh");
        PropertyChangedMessageCommand=cmd(playcommand,"Refresh");
        OptionsListChangedMessageCommand=cmd(playcommand,"Refresh");
        NoteskinChangedMessageCommand=function(self,param)
            if param and param.noteskin and param.Player == pn then
                self:ChangeReload( GAMESTATE:GetCurrentSteps( pn ), param.noteskin )
            end;
        end;

        OptionsListOpenedMessageCommand=function(self)
            self:ChangeReload( Global.pncursteps[pn] )
        end,

        RefreshCommand=function(self)
            if GAMESTATE:IsSideJoined(pn) and Global.pncursteps[pn] then
                if Global.state ~= "SelectSteps" then
                    self:visible(Global.oplist[pn]);
                else
                    self:visible(true);
                end;

                local prefs = notefield_prefs_config:get_data(pn);
                if Global.state == "SelectSteps" and not Global.oplist[pn] then
                    local steps = Global.pncursteps[pn];
                    -- local skin = GetPreferredNoteskin(pn);

                    --self:set_vanish_type("FieldVanishType_RelativeToSelf")

                    -- if curskin[pn] ~= skin then
                    --     --self:set_skin(skin, {});
                    --     curskin[pn] = skin;
                    -- end;

                    self:ChangeReload(steps, skin);
                end

                local speed = prefs.speed_mod;
                local mode = prefs.speed_type;
                local bpm = Global.song:GetDisplayBpms()[2];
                apply_notefield_prefs_nopn(bpm, self, prefs)
                self:playcommand("WidthSet");
                --self:set_curr_second(curTime);

                local tempstate = GAMESTATE:GetPlayerState(pn)
                local playeroptions = tempstate:GetPlayerOptions("ModsLevel_Preferred")

                local style = NOTESCONFIG:get_data(pn).speed_type
                local speed = NOTESCONFIG:get_data(pn).speed_mod
                
                if style == "multiple" then
                    playeroptions:XMod(speed/100)
                elseif style == "average" then
                    playeroptions:AMod(speed)
                elseif style == "constant" then
                    playeroptions:CMod(speed)
                elseif style == "maximum" then
                    playeroptions:MMod(speed)
                elseif style == "constantaverage" then
                    playeroptions:CAMod(speed)
                end

                playeroptions:Hidden( NOTESCONFIG:get_data(pn).hidden == true and 1 or 0 )
                playeroptions:Sudden( NOTESCONFIG:get_data(pn).sudden == true and 1 or 0 )
                playeroptions:Reverse( NOTESCONFIG:get_data(pn).reverse == -1 and 1 or 0 )

                self:y( NOTESCONFIG:get_data(pn).reverse == -1 and SCREEN_CENTER_Y+50 or SCREEN_CENTER_Y-50 )

                if self:GetVisible() then
                    local modstring = playeroptions:GetString()
                    self:ModsFromString("clearall")
                    self:ModsFromString( modstring )
                end
            end;
        end;

        WidthSetCommand=function(self,param)
            if GAMESTATE:IsSideJoined(pn) and Global.pncursteps[pn] then
                local steps = Global.pncursteps[pn];
                local st = PureType(steps);

                --[[
                if (st == "Double" or st == "Routine") or GAMESTATE:GetNumSidesJoined() == 1 then
                    self:set_base_values{
                        transform_pos_x = _screen.cx, 
                        transform_pos_y = _screen.cy,
                    }
                else
                    self:set_base_values{
                        transform_pos_x = _screen.cx + (self:get_width() + 32) * 0.5 * pnSide(pn), 
                        transform_pos_y = _screen.cy,
                    }
                end;
                ]]
            end;
        end;
    };

end;

t[#t+1] = tex;

t[#t+1] = Def.Sprite{
    Texture = "notefield_overlay";
    InitCommand=cmd(zoom,0.515;xy,_screen.cx,_screen.cy-177;vertalign,top;diffusealpha,0);
    OnCommand=cmd(playcommand,"Reload");
    MusicWheelMessageCommand=cmd(playcommand,"Reload");
    StepsChangedMessageCommand=cmd(stoptweening;diffusealpha,0;linear,0.15;diffusealpha,1);
    ReloadCommand=cmd(stoptweening;diffusealpha,0;sleep,0.6;linear,0.25;diffusealpha,1);
    StateChangedMessageCommand=cmd(finishtweening;linear,0.15;fadebottom,Global.state == "GroupSelect" and 0.2 or 0);
}


return t;