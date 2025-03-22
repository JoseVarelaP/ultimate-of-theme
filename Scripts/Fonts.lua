Fonts = {
    common = {
        ["Loading"] = "titillium regular",
        ["ProfileName"] = "titillium regular",
        ["ProfileMini"] = "regen silver",
    },
    player = {
        ["Combo"] = "regen silver",
        ["Label"] = "regen small",
        ["Accuracy"] = "corbel",
    },
    overlay = {
        ["Overlay"] = "titillium regular",
        ["Status"] = "titillium regular",
        ["Adjustments"] = "titillium regular",
    },
    titlemenu = {
        ["Title"] = "regen silver",
        ["Subtitle"] = "titillium regular",
        ["Choice"] = "titillium regular",
        ["Version"] = "regen strong",
    },
    edit = {
        ["Menu"] = "titillium regular",
        ["Steps"] = "titillium regular",
    },
    gameplay = {
        ["Main"] = "titillium regular",
    },
    groupselect = {
        ["Name"] = "titillium regular",
        ["Songs"] = "titillium regular",
        ["Folders"] = "regen strong",
    },
    cursteps = {
        ["Info"] = "titillium regular",
        ["Type"] = "regen strong",
        ["Meter"] = "regen silver",
    },
    highscores = {
        ["Main"] = "titillium regular",
        ["Grade"] = "bebas neue",
    },
    radar = {
        ["Label"] = "regen strong",
        ["Number"] = "regen strong",
    },
    stepslist = {
        ["Main"] = "regen small",
        ["Percentage"] = "regen small",
        ["Label"] = "titillium regular"
    },
    mainmenu = {
        ["Main"] = "titillium regular",
        ["Info"] = "regen strong",
    },
    information = {
        ["Main"] = "roboto regular",
    },
    noteskins = {
        ["Main"] = "titillium regular",
    },
    speeds = {
        ["Speed"] = "regen silver",
        ["Options"] = "titillium regular",
    },
    options = {
        ["Main"] = "titillium regular",
        ["Sections"] = "regen strong",
    },
    counter = {
        ["Main"] = "titillium regular",
    },
    eval = {
        ["Caption"] = "regen small",
        ["Info"] = "roboto regular",
        ["Menu"] = "regen strong",
        ["Labels"] = "regen strong",
        ["Numbers"] = "roboto numbers",
        ["Options"] = "regen strong",
        ["Award"] = "titillium regular",
        ["Scores"] = "titillium regular",
    },
    editor = {
        ["Main"] = "titillium regular",
    },
    onlinelogin = {
        ["Status"] = "regen strong",
        ["Player"] = "titillium regular",
        ["Header"] = "regen strong"
    }
}

function Actor:LyricCommand(side)
	self:settext( Var "LyricText" )
	self:draworder(102)

	self:stoptweening()
	self:shadowlengthx(0)
	self:shadowlengthy(1)
    self:valign(1)
	self:strokecolor(color("#000000"))

	local Zoom = SCREEN_WIDTH / (self:GetZoomedWidth()+1)
	if( Zoom > 1 ) then
		Zoom = 1
	end
	self:zoomx( Zoom )

	local lyricColor = Var "LyricColor"
	local Factor = 1
	if side == "Back" then
		Factor = 0.5
	elseif side == "Front" then
		Factor = 0.9
	end
	self:diffuse( {
		lyricColor[1] * Factor,
		lyricColor[2] * Factor,
		lyricColor[3] * Factor,
		lyricColor[4] * Factor } )

	if side == "Front" then
		self:cropright(1)
	else
		self:cropleft(0)
	end

	self:diffusealpha(0)
	self:linear(0.2)
	self:diffusealpha(0.75)
	self:linear( Var "LyricDuration" * 0.75)
	if side == "Front" then
		self:cropright(0)
	else
		self:cropleft(1)
	end
	self:sleep( Var "LyricDuration" * 0.25 )
	self:linear(0.2)
	self:diffusealpha(0)
	return self
end