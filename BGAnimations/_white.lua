local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	OnCommand=function(self)
		self:diffuse(Color.White):FullScreen()
	end
}

return t
