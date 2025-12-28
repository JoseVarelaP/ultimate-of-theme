local t = Def.ActorFrame{
	StartTransitioningCommand=function(self)
		self:sleep(0.75)
	end
}

return t