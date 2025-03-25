local function Update(self,dt)
	MESSAGEMAN:Broadcast("Update");
end;

local t = Def.ActorFrame {
	InitCommand=function(self) 
		self:SetUpdateFunction(Update); 
		self:SetUpdateRate(1) 
	end;
};

local notecount = {
	[PLAYER_1] = 0,
	[PLAYER_2] = 0
}
local hits = {
	[PLAYER_1] = 0,
	[PLAYER_2] = 0
}
local misses = {
	[PLAYER_1] = 0,
	[PLAYER_2] = 0
}
local all_dp = {
	[PLAYER_1] = 0,
	[PLAYER_2] = 0
}
local cur_dp = {
	[PLAYER_1] = 0,
	[PLAYER_2] = 0
}

local song = GAMESTATE:GetCurrentSong();
local oldbeat = 0;

local TNS_weights = {
	["TapNoteScore_CheckpointMiss"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightCheckpointMiss"),
	["TapNoteScore_CheckpointHit"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightCheckpointHit"),
	["TapNoteScore_W1"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW1"),
	["TapNoteScore_W2"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW2"),
	["TapNoteScore_W3"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW3"),
	["TapNoteScore_W4"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW4"),
	["TapNoteScore_W5"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightW5"),
	["TapNoteScore_Miss"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightMiss"),
	["TapNoteScore_HitMine"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightHitMine"),
	["TapNoteScore_None"] = 0,
};

local HNS_weights = {
	["HoldNoteScore_None"] = 0,
	["HoldNoteScore_Held"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightHeld"),
	["HoldNoteScore_MissedHold"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightMissedHold"),
	["HoldNoteScore_LetGo"] = THEME:GetMetric("ScoreKeeperNormal", "PercentScoreWeightLetGo"),
};

local function TNSToCombo(tns,plr)
	local multiplier = { 1, 1 };
	local curbeat = GAMESTATE:GetSongBeat();
	local master = GAMESTATE:GetMasterPlayerNumber();
	local timing = GAMESTATE:GetCurrentSteps(master):GetTimingData(true);
	local combos = timing:GetCombos(true);

	if timing and combos and #combos > 1 then
		for i=1,#combos do
			local beat = combos[i][1];
			local limit = math.huge;

			if i+1 <= #combos then 
				limit = combos[i+1][1]; 
			end;

			if(curbeat >= beat and curbeat < limit) then
				multiplier = { combos[i][2], combos[i][3] };
			end;
		end;
	end;

	if tns == "TapNoteScore_Miss" or tns == "TapNoteScore_CheckpointMiss" then
		misses[plr] = misses[plr] + multiplier[2];
		hits[plr] = 0;
	elseif tns == "TapNoteScore_W5" then
		misses[plr] = 0;
		hits[plr] = 0;
	elseif tns == ComboMaintain() then
		hits[plr] = 0;
	elseif tns == ComboContinue() then
		hits[plr] = hits[plr] + multiplier[1];
		misses[plr] = 0;
	else
		hits[plr] = hits[plr] + multiplier[1];
		misses[plr] = 0;
	end;
end;

local function ValueOrNil(val)
	if val < 1 then return nil; end;
	return val;
end;

local function ResetTrackers()
	for pn in ivalues(PlayerNumber) do
		notecount[pn] = 0;
		hits[pn] = 0;
		misses[pn] = 0;
		all_dp[pn] = 0;
		cur_dp[pn] = 0;
	end
	oldbeat = GAMESTATE:GetSongBeat();
end;

t[#t+1] = Def.BitmapText{
	Font = Fonts.editor["Main"];
	InitCommand=cmd(diffuse,1,1,1,1;strokecolor,0.1,0.1,0.1,1;zoom,0.6;x,SCREEN_LEFT+8;y,SCREEN_TOP+8;horizalign,left;vertalign,top;zoom,0.575);
	UpdateMessageCommand=function(self)
		if SCREENMAN:GetTopScreen():GetScreenType() == "ScreenType_Gameplay" then
			self:visible(true);
			if GAMESTATE:GetSongBeat() < oldbeat then
				ResetTrackers();
			end;
		else
			ResetTrackers();
			self:visible(false);
		end;

		--self:settext("Notes judged: "..notecount[]);
		
	end;

	JudgmentMessageCommand=function(self, param)
		local pn = param.Player
		if param.TapNoteScore and (
				param.TapNoteScore ~= "TapNoteScore_None" and
				param.TapNoteScore ~= "TapNoteScore_AvoidMine" and
				param.TapNoteScore ~= "TapNoteScore_HitMine") then
			
			notecount[pn] = notecount[pn] + 1; 

			local maximum_value;
			if(PREFSMAN:GetPreference("AllowW1") == "AllowW1_Never") then
				maximum_value = TNS_weights["TapNoteScore_W2"];
			else
				maximum_value = TNS_weights["TapNoteScore_W1"];
			end;

			all_dp[pn] = all_dp[pn] + maximum_value;
			cur_dp[pn] = cur_dp[pn] + TNS_weights[param.TapNoteScore];

			TNSToCombo(param.TapNoteScore,pn);
		end

		if param.HoldNoteScore and param.HoldNoteScore ~= "HoldNoteScore_None" then 
			notecount[pn] = notecount[pn] - 1; 
			all_dp[pn] = all_dp[pn] + HNS_weights["HoldNoteScore_Held"];
			cur_dp[pn] = cur_dp[pn] + HNS_weights[param.HoldNoteScore];
		end

		self:settext("Notes judged: "..notecount[pn]);

		local comboparams = { 
			Combo = ValueOrNil(hits[pn]),
			Misses = ValueOrNil(misses[pn]),
			Player = pn, 
			currentDP = cur_dp[pn], 
			possibleDP = all_dp[pn] 
		};

		local comboActor = SCREENMAN:GetTopScreen():GetChild("Player"..ToEnumShortString(pn)):GetChild("Combo");
		comboActor:playcommand("Judgment", param);
		comboActor:playcommand("Combo", comboparams );
	end;
};

--t[#t+1] = LoadActor(THEME:GetPathG("", "editor_mods_preview"))

return t;
