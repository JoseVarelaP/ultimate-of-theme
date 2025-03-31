local t = Def.ActorFrame{}
-- local notefield = {
--     [PLAYER_1] = nil,
--     [PLAYER_2] = nil,
-- }

for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
    if SideJoined(pn) then

        local styleType = ToEnumShortString(GAMESTATE:GetCurrentStyle(pn):GetStyleType())
        t[#t+1] = Def.Quad{
            InitCommand=cmd(vertalign,top);
            OnCommand=function(self)

                local gameplay = SCREENMAN:GetTopScreen();
                local player = gameplay:GetChild("Player"..ToEnumShortString(pn))
                local conf = PLAYERCONFIG:get_data(pn);

                local cols = GAMESTATE:GetCurrentStyle(pn):ColumnsPerPlayer()
                --notefield[pn] = player:GetChild("NoteField");

                local FieldSize = (64 * cols) + 8 -- GAMESTATE:GetStyleFieldSize(pn)

                if GetScreenAspectRatio() < 1.4 then
                    player:GetChild("NoteField"):addy(20)
                end

                self:x(player:GetX())
                    :zoomto(FieldSize,_screen.h)
                    :diffuse(0.05,0.05,0.05,conf.ScreenFilter/100);

            end;
        }
 
    end;
end;

return t;