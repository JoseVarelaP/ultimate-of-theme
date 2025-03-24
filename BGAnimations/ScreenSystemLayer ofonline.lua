local t = Def.ActorFrame{}

local scoresubmitted = THEME:GetString("ScreenSystemLayer","OFOnlineScoreSent")
local profilesynced = THEME:GetString("ScreenSystemLayer","OFOnlineProfileSynced")
local profilefailSync = THEME:GetString("ScreenSystemLayer","OFOnlineProfileFailSync")
local connectedtoserver = THEME:GetString("ScreenSystemLayer","OFOnlineConnectedToServer")
local errormessage = THEME:GetString("ScreenSystemLayer","OFOnlineErrorMessage")
local scoresavetimeout = THEME:GetString("ScreenSystemLayer","OFScoreSaveTimeout")

-- Settings fro frame
local frame_width = 240;
local frame_height = 0.6;
local base_zoom = 0.75 * (SCREEN_HEIGHT/480)

for ind,plr in pairs(PlayerNumber) do
	t[#t+1] = Def.ActorFrame{
		InitCommand=function(self)
			local xPosSeparation = SAFE_WIDTH + 140
			self:xy( plr == PLAYER_1 and xPosSeparation or SCREEN_WIDTH - xPosSeparation , SCREEN_BOTTOM - 40 )
			:zoom(base_zoom):diffusealpha(0)
		end,
		ActionPlayCommand=function(self)
			self:finishtweening():diffusealpha(0):zoom(base_zoom - 0.1):easeoutexpo(0.5):diffusealpha(1)
			:zoom( base_zoom ):sleep(2):easeinexpo(0.5):diffusealpha(0)
		end,
		MessageOFNetworkResponseMessageCommand=function(self,params)
			self:GetChild("ErrorIcon"):visible(false)
			if params.PlayerNumber == plr then
				local xPosSeparation = SAFE_WIDTH + 140
				self:GetChild("ColorIcon"):setstate(0):visible(true)
				self:x( plr == PLAYER_1 and xPosSeparation or SCREEN_WIDTH - xPosSeparation)
				if params.Name == "ScoreSave" then
					if params.Status == "success" then
						self:GetChild("Status"):settext(scoresubmitted)
					else
						if params.Message == "TimeoutRetry" then
							self:GetChild("Status"):settext( scoresavetimeout )
						else 
							self:GetChild("ColorIcon"):visible(false)
							self:GetChild("ErrorIcon"):visible(true)
							self:GetChild("Status"):settext( errormessage:format(params.Message) )
						end
					end
					self:playcommand("ActionPlay")
				end
				if params.Name == "ProfileSave" then
					self:GetChild("Status"):settext( params.StatusCode == 500 and profilefailSync or profilesynced )
					self:playcommand("ActionPlay")
				end
			end
			if params.Name == "MachineLogin" then
				self:x(SCREEN_CENTER_X)
				self:GetChild("Status"):settext(connectedtoserver)
				self:playcommand("ActionPlay")
			end
		end,
		
		Def.Sprite{
			Texture=THEME:GetPathG("","titlepanel"),
			InitCommand=function (self)
				self:animate(0):setstate(1)
				self:zoomto(frame_width,frame_height*self:GetHeight())
			end
		},
		
		Def.Sprite{
			Texture=THEME:GetPathG("","titlepanel"),
			InitCommand=function (self)
				self:animate(0):setstate(0):halign(1)
				:zoom(frame_height)
				:x(-frame_width/2)
			end
		},

		Def.Sprite{
			Texture=THEME:GetPathG("","titlepanel"),
			InitCommand=function (self)
				self:animate(0):setstate(2):halign(0)
				:zoom(frame_height)
				:x(frame_width/2)
			end
		},

		Def.Sprite{
			Name="ColorIcon",
			Texture=THEME:GetPathG("","cursor"),
			InitCommand=function (self)
				self:diffuseshift():animate(0)
				:effectcolor1(1,1,1,0.5)
				:zoom( frame_height - .2 )
				:xy( -frame_width/2, -2 )
			end
		},

		Def.Sprite{
			Name="ErrorIcon",
			Texture=THEME:GetPathG("","navigation"),
			InitCommand=function (self)
				self:diffuseshift():animate(0):setstate(5)
				:effectcolor1(1,0.5,0.5,0.5)
				:effectcolor2(1,0.5,0.5,1.0)
				:zoom( frame_height )
				:xy( -frame_width/2, -2 )
			end
		},

		Def.BitmapText{
			Font="corbel",
			Name="Status",
			InitCommand=function(self)
				self:zoom(.6):xy(-98,-3):halign(0):maxwidth(380)
			end
		}
	}
end

return t