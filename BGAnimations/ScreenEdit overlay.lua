local t = Def.ActorFrame {};
local combo = 0;

t[#t+1] = LoadFont("Common normal") .. {
		InitCommand=cmd(diffuse,1,1,1,1;strokecolor,0.1,0.1,0.1,1;zoom,0.75;x,SCREEN_LEFT+20;y,SCREEN_TOP+3;horizalign,left;vertalign,top);
		OnCommand=function(self)
			if SCREENMAN:GetTopScreen():GetScreenType() == "ScreenType_Gameplay" then
				self:visible(true);
			else
				combo = 0;
				--	self:settext("Note count: "..combo);
				self:visible(false);
			end;
			self:sleep(0.05);
			self:queuecommand("On");
		end;
		JudgmentMessageCommand=function(self, param)
			--combo = combo+1;
			if param.TapNoteScore then combo = combo+1; end
			if param.HoldNoteScore then combo = combo-1; end;	
			self:settext("Note count: "..combo);
		end;
};


return t;
