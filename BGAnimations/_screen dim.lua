local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:diffuse(0,0,0,0.9):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):Center()
	end
}

return t
