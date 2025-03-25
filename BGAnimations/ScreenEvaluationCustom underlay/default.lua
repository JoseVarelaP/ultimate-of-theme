local function CustomInput(event)
    if event.type == "InputEventType_FirstPress" then
        if event.PlayerNumber and SideJoined(event.PlayerNumber) and not Global.lockinput then
            -- Ok, we have pressed the button once. Time to detect what button was pressed.
            local data = {
                Player = event.PlayerNumber,
                Input = "Prev",
            }
            if event.GameButton == "MenuLeft" then
                data.Input = "Prev"
                EvaluationController(data)
            end
            if event.GameButton == "MenuRight" then
                data.Input = "Next"
                EvaluationController(data)
            end
            if event.GameButton == "Start" then
                data.Input = "Start"
                EvaluationController(data)
            end
        end
    end
end

for i,pn in pairs( GAMESTATE:GetEnabledPlayers() ) do
	SCREENMAN:set_input_redirected( pn, true )
end

local t = MenuInputActor()..{
    InitCommand=function(self)
        Global.lockinput = true;
    end;
    OnCommand=cmd(diffusealpha,1;sleep,2.5;queuecommand,"Unlock");
    OffCommand=cmd(linear,0.5;diffusealpha,0;sleep,0.75;queuecommand,"Exit");
    PlayerJoinedMessageCommand=function(self,param)
        GAMESTATE:UnjoinPlayer(param.Player);
    end;
    MenuInputMessageCommand=function(self,param) 
        InputController(self,param) 
    end;
    BeginCommand=function (self)
        SCREENMAN:GetTopScreen():AddInputCallback( CustomInput )
    end,
}

--//================================================================    

function InputController(self,param)
    if param and param.Player and SideJoined(param.Player) and not Global.lockinput then
        MainController(self,param)
        EvaluationController(param)
    end;
end;

--//================================================================    

function MainController(self,param)
    if param.Input == "Options" then
        InputController(self, { Player = param.Player, Input = "Next"})
    end;

    if param.Name == "PressSelect" then
        Global.toggle = true;
        MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = true });
    end

    if param.Name == "ReleaseSelect" then
        Global.toggle = false;
        MESSAGEMAN:Broadcast("ToggleSelect", { Toggled = false })
    end

    if param.Name == "Return" then 
        SCREENMAN:SetNewScreen(SCREENMAN:GetTopScreen():GetNextScreenName()); 
    end;
end;

--//================================================================    

t[#t+1] = LoadActor(THEME:GetPathB("","_assets/fulldisplay"));
t[#t+1] = LoadActor("assets/information");
t[#t+1] = LoadActor("assets/grading");
t[#t+1] = LoadActor("assets/menu");

t[#t+1] = LoadActor(THEME:GetPathB("","_assets/cursteps"));
t[#t+1] = LoadActor(THEME:GetPathB("","_assets/sound"));

--//================================================================    

return t;