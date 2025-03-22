--//================================================================

create_lua_config = setmetatable({
    get_data = function(this, playerSlot)
        if playerSlot == "ProfileSlot_Invalid" or not playerSlot then
            -- It's machine profile configs.
            return this.dataCont["ProfileSlot_Machine"]
        end
        return this.dataCont[playerSlot]
    end,
    --[[
        Load the configuration from the specific player slot.
    ]]
    load = function(this, playerSlot)
        if playerSlot == "ProfileSlot_Invalid" then
            -- It's machine profile configs.
            return this.dataCont["ProfileSlot_Machine"]
        end
        return this.dataCont[playerSlot]
    end,
    save = function(this, playerSlot)
        return this
    end,
    set_dirty = function(this, state)
        this.dirty = state
        return this
    end,
    ------
    dataCont = {
        ["PlayerNumber_P1"] = {},
        ["PlayerNumber_P2"] = {},
        ["ProfileSlot_Machine"] = {}
    },
    name = "",
    dirty = false
},{
    __call = function(self, data)
        if data.name then self.name = data.name end
        if data.file then self.file = data.file end
        if data.default then
            for setting,value in pairs( data.default ) do
                for player in ivalues(PlayerNumber) do
                    self.dataCont[player][setting] = value
                end
                -- special case for the special boi
                self.dataCont["ProfileSlot_Machine"][setting] = value
            end
        end
        return self
    end

})

--//================================================================

local theme_conf_default = {
    BGBrightness = 100,
    DefaultBG = false,
    DisableBGA = false,
    CenterPlayer = false,
    MusicRate = 1.0,
    FailType = "delayed",
    FailMissCombo = true,
    AllowW1 = true,
    TimingDifficulty = 4,
    LifeDifficulty = 4,
}

THEMECONFIG = create_lua_config{
    name = "THEMECONFIG", 
    file = "theme_config.lua",
    default = theme_conf_default,
}

THEMECONFIG:load("ProfileSlot_Invalid");
THEMECONFIG:set_dirty("ProfileSlot_Invalid");
THEMECONFIG:save("ProfileSlot_Invalid");

--//================================================================

function ResetThemeSettings()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.BGBrightness = 100;
    tconf.DefaultBackground = false;
    tconf.DisableBGA = false;
    tconf.CenterPlayer = false;
    tconf.MusicRate = 1.0;
    tconf.FailType = "delayed";
    tconf.FailMissCombo = true;
    tconf.AllowW1 = true;
    tconf.TimingDifficulty = 4;
    tconf.LifeDifficulty = 4;
    THEMECONFIG:save();
end;

--//================================================================

function ResetDisplayOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.BGBrightness = 100;
    tconf.DefaultBG = false;
    tconf.DisableBGA = false;
    tconf.CenterPlayer = false;
    THEMECONFIG:save();
end;

function ResetSongOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.MusicRate = 1.0;
    tconf.FailType = "delayed";
    tconf.FailMissCombo = true;
    THEMECONFIG:save();
end;

function ResetJudgmentOptions()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");
    tconf.AllowW1 = true;
    tconf.TimingDifficulty = 4;
    tconf.LifeDifficulty = 4;
    THEMECONFIG:save();
end;

--//================================================================

function ApplyThemeSettings()
    local tconf = THEMECONFIG:get_data("ProfileSlot_Invalid");

    tconf.BGBrightness      = clamp(tconf.BGBrightness,0,100);
    tconf.MusicRate         = clamp(tconf.MusicRate,0.5,2.0);
    tconf.TimingDifficulty  = clamp(tconf.TimingDifficulty,1,9);
    tconf.LifeDifficulty    = clamp(tconf.LifeDifficulty,1,7);
    if string.lower(tconf.FailType) ~= "delayed" and
       string.lower(tconf.FailType) ~= "immediate" and
       string.lower(tconf.FailType) ~= "off" then
       tconf.FailType = "delayed";
    end;

    -------------------------------------------------------------------------------------------------------
    local timing_mapping = { 1.5, 1.33, 1.16, 1.00, 0.84, 0.66, 0.50, 0.33, 0.20 };
    local life_mapping = { 1.6, 1.40, 1.20, 1.00, 0.80, 0.60, 0.40 };

    PREFSMAN:SetPreference("BGBrightness",          tconf.DefaultBG and 0 or math.round(tconf.BGBrightness*100)/10000);
    PREFSMAN:SetPreference("Center1Player",         tconf.CenterPlayer);
    PREFSMAN:SetPreference("TimingWindowScale",     timing_mapping[tconf.TimingDifficulty] );
    PREFSMAN:SetPreference("LifeDifficultyScale",   life_mapping[tconf.LifeDifficulty] );
    PREFSMAN:SetPreference("AllowW1",               tconf.AllowW1 and "AllowW1_Everywhere" or "AllowW1_Never" );

    -------------------------------------------------------------------------------------------------------
    local sops= GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred");
    sops:MusicRate(tconf.MusicRate);
    sops:StaticBackground(tconf.DisableBGA);
    GAMESTATE:ApplyPreferredSongOptionsToOtherLevels();

    -------------------------------------------------------------------------------------------------------
    local fail_mapping  = {
        ["immediate"]   = "FailType_Immediate",
        ["delayed"]     = "FailType_ImmediateContinue",
        ["off"]         = "FailType_Off",
    };

    for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
        local pstate = GAMESTATE:GetPlayerState(pn);
        local plops = pstate:GetPlayerOptions("ModsLevel_Preferred");
        plops:FailSetting(fail_mapping[string.lower(tconf.FailType)])
        pstate:ApplyPreferredOptionsToOtherLevels();
    end;

end;

--//================================================================

local player_conf_default= {
    ShowOffsetMeter = false,
    ShowEarlyLate = false,
    ShowJudgmentList = false,
    ShowPacemaker = "off",
    ReverseJudgment = false,
    ScreenFilter = 0,
    SpeedModifier = 25,
}

local notefield_default_prefs= {
	speed_mod= 250,
	speed_type= "multiple",
	hidden= false,
	hidden_offset= 120,
	sudden= false,
	sudden_offset= 190,
	fade_dist= 40,
	glow_during_fade= true,
	fov= 45,
	reverse= 1,
	rotation_x= 0,
	rotation_y= 0,
	rotation_z= 0,
	vanish_x= 0,
	vanish_y= 0,
	yoffset= 130,
	zoom= 1,
	zoom_x= 1,
	zoom_y= 1,
	zoom_z= 1,
	-- migrated_from_newfield_name is temporary, remove it in 5.1.-4. -Kyz
	migrated_from_newfield_name= false,
}

notefield_speed_types= {"multiple","constant", "maximum", "average", "constantaverage"}

-- If the theme author uses Ctrl+F2 to reload scripts, the config that was
-- loaded from the player's profile will not be reloaded.
-- But the old instance of notefield_prefs_config still exists, so the data
-- from it can be copied over.  The config system has a function for handling
-- this.
notefield_prefs_config= create_lua_config{
	name= "notefield_prefs", file= "notefield_prefs.lua",
	default= notefield_default_prefs,
	-- use_alternate_config_prefix is meant for lua configs that are shared
	-- between multiple themes.  It should be nil for preferences that will
	-- only exist in your theme. -Kyz
	use_alternate_config_prefix= "",
}

NOTESCONFIG = notefield_prefs_config;
PLAYERCONFIG = create_lua_config{
    name = "PLAYERCONFIG", 
    file = "player_config.lua",
    default = player_conf_default,
}

local function set_notefield_default_yoffset(yOffset)
    -- Hey, move the notefield by this much.
end

--add_standard_lua_config_save_load_hooks(PLAYERCONFIG);
-- set_notefield_default_yoffset(170)

--//================================================================

pacemaker_targets = {
    "off",
    "no target", 
    "best score", 
    "grade: D", 
    "grade: C", 
    "grade: B", 
    "grade: A", 
    "grade: AA", 
    "grade: AAA"
}

--//================================================================

function ResetPlayerSpeed(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG:get_data(pn);
    nconf.speed_mod = 250;
    pconf.SpeedModifier = 25;
    nconf.speed_type = "maximum";

    NOTESCONFIG:set_dirty(pn);
    PLAYERCONFIG:set_dirty(pn);
end;

function ResetPlayerZoom(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.zoom = 1;
    nconf.zoom_x = 1;
    nconf.zoom_y = 1;
    nconf.zoom_z = 1;

    NOTESCONFIG:set_dirty(pn);
end;

function ResetPlayerRotation(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.rotation_x = 0;
    nconf.rotation_y = 0;
    nconf.rotation_z = 0;

    NOTESCONFIG:set_dirty(pn);
end;

function ResetPlayerView(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    nconf.reverse = 1;
    nconf.yoffset = 170;
    nconf.fov = 60;

    NOTESCONFIG:set_dirty(pn);
end;

function ResetPlayerDisplay(pn)
    local nconf = NOTESCONFIG:get_data(pn);
    local pconf = PLAYERCONFIG:get_data(pn);
    nconf.hidden = false;
    nconf.sudden = false;
    nconf.hidden_offset = 120;
    nconf.sudden_offset = 190;
    nconf.fade_distance = 40;
    nconf.glow_during_fade = true;
    pconf.ReverseJudgment = false;

    NOTESCONFIG:set_dirty(pn);
    PLAYERCONFIG:set_dirty(pn);
end;

function ResetPlayerTransform(pn)
    ResetPlayerZoom(pn)
    ResetPlayerRotation(pn)
    ResetPlayerView(pn)
end;

--/==/ The stub of the ye oldie 5.1-3

function apply_notefield_prefs_nopn(read_bpm, field, prefs)

end