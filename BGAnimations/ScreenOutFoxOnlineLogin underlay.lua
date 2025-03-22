local t = Def.ActorFrame{}

local height = SCREEN_HEIGHT / 480
local waitingText = THEME:GetString("ScreenOutFoxOnlineLogin","WaitingText")
local logginginText = THEME:GetString("ScreenOutFoxOnlineLogin","LoadingText")
local invalidToken = THEME:GetString("ScreenOutFoxOnlineLogin","InvalidToken")
local successText = THEME:GetString("ScreenOutFoxOnlineLogin","Success")
local cancelButtonText = THEME:GetString("ScreenOutFoxOnlineLogin","CancelText")
local cancelButtonThreeButton = THEME:GetString("ScreenOutFoxOnlineLogin","CancelThreeButtonText")
local invalidPinText = THEME:GetString("ScreenOutFoxOnlineLogin","InvalidPin")
local sameAccountText = THEME:GetString("ScreenOutFoxOnlineLogin","SameAccount")

local threeKey = PREFSMAN:GetPreference("ThreeKeyNavigation")

local allowOnlineGuests = PREFSMAN:GetPreference("AllowOnlineGuests")

t[#t+1] = Def.Sound{ Name="Value", File=THEME:GetPathS("","Switch"), SupportPan = true; }
t[#t+1] = Def.Sound{ Name="Start", File=THEME:GetPathS("","Steps"), SupportPan = true; }
t[#t+1] = Def.Sound{ Name="Cancel", File=THEME:GetPathS("Common","cancel"), SupportPan = true; }

local bg = Def.ActorFrame{
	InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-10.5;diffusealpha,0);
	OnCommand=function(self)
		self:stoptweening();
		self:decelerate(0.25);
		self:diffusealpha(0.9);
	end,
	OffCommand=function(self)
		self:stoptweening();
		self:decelerate(0.25);
		self:diffusealpha(0);
	end,

	Def.Quad{
		InitCommand=cmd(zoomto,_screen.w,_screen.h;cropbottom,1/3;
			diffuse,BoostColor(Global.bgcolor,0.75);diffusebottomedge,BoostColor(AlphaColor(Global.bgcolor,0.5),0.5);fadebottom,1/3);
	},

	Def.Quad{
		InitCommand=cmd(zoomto,_screen.w,_screen.h;diffuse,BoostColor(Global.bgcolor,0.6);cropbottom,1/25;fadetop,0.5);
	},

	LoadActor(THEME:GetPathG("","_pattern"))..{
		InitCommand=cmd(zoomto,_screen.w,_screen.h;blend,Blend.Add;
			diffuse,BoostColor(HighlightColor(1),0.1);diffusebottomedge,0.1,0.1,0.1,0;fadetop,1;
				customtexturerect,0,0,_screen.w / 384 * 2.5 ,_screen.h / 384 * 2.5;texcoordvelocity,0,-0.075);
	},
};

-- Display for every player who is real.
for ind,plr in pairs(GAMESTATE:GetHumanPlayers()) do
	local profile = PROFILEMAN:GetProfile(plr)
	local isPersistent = PROFILEMAN:IsPersistentProfile(plr)
	local needsToLogin = isPersistent and profile:IsOnlineRegistered() or profile:GetType() ~= "ProfileType_Normal"

	local plrAct = Def.ActorFrame{
		FOV=45,
		InitCommand=function(self)
			local xPosSeparation = SAFE_WIDTH + 125
			--self:xy( plr == PLAYER_1 and xPosSeparation or SCREEN_WIDTH - xPosSeparation , SCREEN_CENTER_Y + 10 )
			self:x( SCREEN_CENTER_X + (pnSide(plr)*(140+32) ) )
			:y( SCREEN_CENTER_Y + 10 )
			:visible( needsToLogin )
			:zoom( height*.9 )
		end,
		OnCommand=function(self)
			self:diffusealpha(0):easeoutexpo(0.75):diffusealpha(1):zoom(height)
		end,
		PlayerLoginSuccessCommand=function(self,params)
			if params.Player == plr then
				self:finishtweening()
				self:GetChild("Status"):settext(ToUpper(successText)):diffuse(Color.Green)
				:strokecolor(0,0.25,0,0.25)
				self:GetChild("Loading"):setstate(2):zoom(0.65):linear(0.2):diffusealpha(0):zoom(0.5)
				--self:GetChild("Glow"):easeoutexpo(0.2):diffuse(Color.Green):easeoutexpo(1.5):diffuse(Color.White):diffusealpha(0)

				self:GetChild("SoundSuccess"):play()

				--self:sleep(0.2):easeinexpo(0.25):rotationy(-90)
			end
		end,
		OffCommand=function(self)
			self:easeinexpo(0.25):zoom(height*.9):diffusealpha(0)
		end,
		SkippedCommand=function(self,params)
			if params.Player == plr then
				self:easeinexpo(0.25):zoom(height*.9):diffusealpha(0)
			end
		end,
		PlayerLoginFailCommand=function(self,params)
			if params.Player == plr then
				self:finishtweening():rotationy(0)
				self:GetChild("Status"):settext( ToUpper("Failed") ):diffuse(Color.Red):decelerate(0.25):y(100)
				--self:GetChild("Glow"):easeoutexpo(0.2):diffuse(Color.Red):easeoutexpo(1.5):diffuse(Color.White):diffusealpha(0)
				self:GetChild("Loading"):setstate(0):diffuse(Color.Red):zoom(0.65):linear(0.2):diffusealpha(0):zoom(0.5)

				self:GetChild("SoundFail"):play()

				if params.Reason then
					self:GetChild("Frame"):decelerate(0.2):zoom(1)
					local reasonTranslated = params.Reason
					if params.Reason == "invalid pin" then reasonTranslated = invalidPinText end
					if params.Reason == "invalid token" then reasonTranslated = invalidToken end
					if params.Reason == "same_account" then reasonTranslated = sameAccountText end
					self:GetChild("Status"):settext(ToUpper(reasonTranslated)):y(100)
				end

				--self:sleep(0.45):easeinexpo(0.25):diffusealpha(0)
			end
		end,
		SendingLinkCodeCommand=function(self,params)
			if params.Player == plr then
				self:GetChild("Frame"):decelerate(0.25):zoom(0.5)
				self:GetChild("Loading"):visible(true):diffuse(Color.White):y(0)
				self:GetChild("Status"):decelerate(0.25):y(30):settext(ToUpper(logginginText)):diffuse(Color.White)
			end
		end,

		Def.Sprite{
			Name="Frame",
			Texture=THEME:GetPathG("","panel"),
			InitCommand=function(self)
			end
		},

		Def.Sound{
			File=THEME:GetPathS("ScreenEdit","save"),
			Name="SoundSuccess",
		},

		Def.Sound{
			File=THEME:GetPathS("MemoryCardManager","error"),
			Name="SoundFail",
		},

		Def.BitmapText{
			Name="ProfileName",
			Font=Fonts.onlinelogin["Player"],
			Text=profile:GetDisplayName(),
			InitCommand=function(self)
				self:y( -40 ):zoom(0.5):maxwidth(200)
			end,
			PlayerLoginSuccessCommand=function(self,params)
				if params.Player == plr then
					self:settext(profile:GetDisplayName())
				end
			end
		},

		Def.BitmapText{
			Font=Fonts.onlinelogin["Status"],
			Text=ToUpper(logginginText),
			Name="Status",
			InitCommand=function(self)
				self:y( 30 ):zoom(0.4):wrapwidthpixels(480)
				self:strokecolor(0,0,0,0.25)
				if allowOnlineGuests and not isPersistent then
					self:y( 100 ):settext( ToUpper(waitingText) )
				end
			end,
		},

		Def.Sprite{
			Texture=THEME:GetPathG("","cursor"),
			Name="Loading",
			InitCommand=function(self)
				self:y( 0 ):animate(0):setstate(1):spin():zoom(0.4):effectmagnitude(0,0,720)
				if allowOnlineGuests and not isPersistent then
					self:y( 60 ):visible(false)
				end
			end
		},

		Def.BitmapText{
			Font="ScreenOutFoxOnlineLogin text",
			Text=threeKey and cancelButtonThreeButton or cancelButtonText,
			Name="CancelText",
			InitCommand=function(self)
				self:y( 60 ):zoom(0.5):wrapwidthpixels(330)
				self:visible( allowOnlineGuests and not isPersistent )
			end,
			SendingLinkCodeCommand=function(self,params)
				if params.Player == plr then
					self:visible(false)
				end
			end,
			PlayerLoginFailCommand=function(self,params)
				if params.Player == plr and params.NeedsLinkCode then
					self:visible(true)
				end
			end,
		}
	}

	if allowOnlineGuests then

		--[[
		t[#t+1] = Def.ActorFrame{
			Def.BitmapText{
				Font=Fonts.onlinelogin["Header"],
				Text=ToUpper(Screen.String("LoginWindowHeader")),
				InitCommand=function(self)
					self:y( -0 ):zoom(0.4):strokecolor(BoostColor(PlayerColor(plr,0.9),1/3) );
				end,
				PlayerLoginFailCommand=function(self,params)
					if params.Player == plr and params.NeedsLinkCode then
						self:visible( not isPersistent )
					end
				end,
			},
		}
		]]

		t[#t+1] = Def.ActorFrame{
			OnCommand=function(self)
				self:diffusealpha(0)
				:decelerate(0.4)
				:diffusealpha(1)
			end,
			OffCommand=function(self)
				self:decelerate(0.4)
				:diffusealpha(0)
			end,
			Def.Quad{
				InitCommand=cmd(CenterX;y,SCREEN_CENTER_Y-168;zoomto,_screen.w * 0.5 * pnSide(plr),1;horizalign,left;fadeleft,0.75;cropleft,0.15;diffuse,PlayerColor(plr));
			},

			-- TEXT
			Def.ActorFrame{
				InitCommand=cmd(x,SCREEN_CENTER_X + (pnSide(plr)*(150+32));y,SCREEN_CENTER_Y-168);
				StateChangedMessageCommand=function(self) 
					self:stoptweening();
					self:decelerate(0.4);
				end;

				-- title
				Def.BitmapText{
					Font = "regen strong";
					Text = ToUpper(Screen.String("LoginWindowHeader"));
					InitCommand=cmd(x,-48*pnSide(plr);zoomy,0.31;zoomx,0.3075;horizalign,pnAlign(OtherPlayer[plr]);strokecolor,BoostColor(PlayerColor(plr,0.9),1/3));
					StateChangedMessageCommand=function(self)
						self:stoptweening();
						self:decelerate(Global.state == "HighScores" and 0.2 or 0.3);
						self:diffusealpha(Global.state == "HighScores" and 0.75 or 0);
					end;
				},
			},
		};
		
		plrAct[#plrAct+1] = Def.ActorFrame{
			Name="GuestInfo",
			SendingLinkCodeCommand=function(self,params)
				if params.Player == plr then
					self:visible(false)
				end
			end,
			PlayerLoginFailCommand=function(self,params)
				if params.Player == plr and params.NeedsLinkCode then
					self:visible(true)
				end
			end,

			Def.BitmapText{
				Font="ScreenOutFoxOnlineLogin text",
				Text=Screen.String("LoginWindowInstructions"),
				InitCommand=function(self)
					self:xy( -40,-70 ):zoom(0.45):wrapwidthpixels(180)
				end,
			},

			Def.ActorMultiVertex{
				OnCommand=function (self)
					self:SetDrawState{Mode="DrawMode_Quads"}

					-- Fetch the data from the qrcode file.
					local data = loadfile(THEME:GetPathO("OutFoxOnline","QRCode"))()

					-- Iterate through the data.
					local vertices = {}

					vertices[#vertices+1] = { {-1,-1,0}, Color.White } -- top left
					vertices[#vertices+1] = { {-1,#data+1,0}, Color.White } -- bottom left
					vertices[#vertices+1] = { {#data+1,#data+1,0}, Color.White } -- bottom right
					vertices[#vertices+1] = { {#data+1,-1,0}, Color.White } -- top right
					
					for x=1,#data do
						for y=1,#data do
							local color = data[x][y] > 0 and Color.Black or Color.White
							vertices[#vertices+1] = { {x-1,y-1,0}, color } -- top left
							vertices[#vertices+1] = { {x,y-1,0}, color } -- bottom left
							vertices[#vertices+1] = { {x,y,0}, color } -- bottom right
							vertices[#vertices+1] = { {x-1,y,0}, color } -- top right
						end
					end

					self:SetVertices(vertices):zoom(2.5):xy( 10,-100 )
				end
			}
		}

		for i = 1,4 do
			plrAct[#plrAct+1] = Def.Sprite{
				Texture=THEME:GetPathG("ScreenOutFoxOnlineLogin items/Player Digit","Code"),
				InitCommand=function(self)
					self:xy( scale( i, 1, 4, -50, 50 ), -10 ):zoom(0.5):animate(0)
				end,
				TokenCodeChangedCommand=function(self,params)
					if params.Player == plr then
						self:setstate( params.Length >= i and 1 or 0 )
					end
				end,
				SendingLinkCodeCommand=function(self,params)
					if params.Player == plr then
						self:visible(false)
					end
				end,
				PlayerLoginFailCommand=function(self,params)
					if params.Player == plr and params.NeedsLinkCode then
						self:visible(true):setstate(0)
					end
				end,
			}
		end
	end

	-- Generate keyboard.
	local currentButtonIndex = 0;
	local characters = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9}

	local function CheckOffsetIndex(val)
		currentButtonIndex = currentButtonIndex + val
		if currentButtonIndex < 0 then currentButtonIndex = #characters-1 end
		if currentButtonIndex > #characters-1 then currentButtonIndex = 0 end
	end

	local keyboard = Def.ActorFrame{
		InitCommand=function (self)
			self:y(26):visible(not isPersistent and profile:GetType() ~= "ProfileType_Normal")
		end,
		SendingLinkCodeCommand=function(self,params)
			if params.Player == plr then
				self:visible(false)
			end
		end,
		PlayerLoginFailCommand=function(self,params)
			if params.Player == plr and params.NeedsLinkCode then
				self:visible(true):setstate(0)
			end
		end,
		CodeMessageCommand=function (self,params)
			if params.PlayerNumber ~= plr then return end
			if not SCREENMAN:GetTopScreen():NeedsTyping(params.PlayerNumber) then return end
			
			if params.Name == "Left" then
				local needsWrap = currentButtonIndex == 0
				CheckOffsetIndex(-1)
				self:GetParent():GetParent():GetChild("Value"):playforplayer(params.PlayerNumber)
				self:GetChild("Left"):playcommand("Pressed")
				if needsWrap then
					local num = self:GetChild("Scroller"):GetNumItems()
					self:GetChild("Scroller"):SetCurrentAndDestinationItem( num )
				end
				self:GetChild("Scroller"):SetDestinationItem(currentButtonIndex)
			end
			if params.Name == "Right" then
				local needsWrap = currentButtonIndex == #characters-1
				CheckOffsetIndex(1)
				self:GetParent():GetParent():GetChild("Value"):playforplayer(params.PlayerNumber)
				self:GetChild("Right"):playcommand("Pressed")
				if needsWrap then
					self:GetChild("Scroller"):SetCurrentAndDestinationItem( -1 )
				end
				self:GetChild("Scroller"):SetDestinationItem(currentButtonIndex)
			end
			if params.Name == "Enter" then
				self:GetParent():GetParent():GetChild("Start"):playforplayer(params.PlayerNumber)
				SCREENMAN:GetTopScreen():EnterDigit(params.PlayerNumber, characters[currentButtonIndex+1])
			end
			if params.Name == "Skip" then
				self:GetParent():GetParent():GetChild("Cancel"):playforplayer(params.PlayerNumber)
				SCREENMAN:GetTopScreen():SkipProcess(params.PlayerNumber)
			end
			if params.Name == "SkipThreeButton" and threeKey then
				self:GetParent():GetParent():GetChild("Cancel"):playforplayer(params.PlayerNumber)
				SCREENMAN:GetTopScreen():SkipProcess(params.PlayerNumber)
			end
		end
	}

	local function LetterActors()
		local t = {};

		for v in ivalues(characters) do
			t[#t+1] = Def.BitmapText{
				Font="ScreenOutFoxOnlineLogin text",
				Text=v,
			}
		end

		return t
	end

	keyboard[#keyboard+1] = Def.ActorScroller {
		Name = "Scroller",
		NumItemsToDraw=5,

		OnCommand= function (self)
			self:y(1):SetFastCatchup(true):SetLoop(true):SetSecondsPerItem(0.1)
		end,
		TransformFunction=function(self, offset, itemIndex, numItems)
			local absval = math.abs(offset)
			local focus = scale(absval,0,2,1.2,0.8)
			self:visible(false):diffusealpha( scale(absval,0,2,1,0.2) )
			self:x(math.floor( offset*25 ))
		end,
		children = LetterActors()
	}

	for i,v in ipairs({-1,1}) do
		keyboard[#keyboard+1] = Def.Sprite{
			Name=i == 1 and "Left" or "Right",
			Texture=THEME:GetPathG("ScreenOutFoxOnlineLogin","items/MoveCursor"),
			InitCommand=function(self)
				self:zoom(0.5):xy( 74 * v,2 ):rotationz( i == 1 and 180 or 0 )
			end,
			PressedCommand=function (self)
				self:finishtweening():zoom(0.6):easeoutquad(0.25):zoom(0.5)
			end
		}
	end

	plrAct[#plrAct+1] = keyboard

	t[#t+1] = plrAct
end

return Def.ActorFrame{bg, t}
