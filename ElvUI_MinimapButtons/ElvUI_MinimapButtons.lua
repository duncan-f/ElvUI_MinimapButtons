local addonName = ...;
local E, L, V, P, G, _ = unpack(ElvUI);
local EP = LibStub("LibElvUIPlugin-1.0")
local addon = E:NewModule("MinimapButtons", "AceHook-3.0", "AceTimer-3.0");

local ceil = math.ceil
local find, len, split, sub = string.find, string.len, string.split, string.sub
local tinsert = table.insert
local ipairs, unpack = ipairs, unpack

local points = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT"
};

local positionValues = {
	TOPLEFT = "TOPLEFT",
	LEFT = "LEFT",
	BOTTOMLEFT = "BOTTOMLEFT",
	RIGHT = "RIGHT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
	CENTER = "CENTER",
	TOP = "TOP",
	BOTTOM = "BOTTOM"
};

P.general.minimap.buttons = {
	buttonsize = 30,
	buttonspacing = 1,
	backdropSpacing = 1,
	buttonsPerRow = 1,
	alpha = 1,
	point = "TOPLEFT",
	mouseover = false,
	backdrop = true,
	insideMinimap = {
		enable = true,
		position = "TOPLEFT",
		xOffset = 1,
		yOffset = 1
	};
};

local function GetOptions()
	E.Options.args.maps.args.minimap.args.icons.args.point = {
		order = 1,
		type = "select",
		name = L["Anchor Point"],
		desc = L["The first button anchors itself to this point on the bar."],
		values = points,
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateLayout(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.backdrop = {
		order = 2,
		type = "toggle",
		name = L["Backdrop"],
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateLayout(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.mouseover = {
		order = 3,
		type = "toggle",
		name = L["Mouse Over"],
		desc = L["The frame is not shown unless you mouse over the frame."],
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateAlpha(); end,
	}
	E.Options.args.maps.args.minimap.args.icons.args.alpha = {
		order = 4,
		type = "range",
		name = L["Alpha"],
		min = 0, max = 1, step = 0.01,
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateAlpha(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.buttonsPerRow = {
		order = 5,
		type = "range",
		name = L["Buttons Per Row"],
		desc = L["The amount of buttons to display per row."],
		min = 1, max = 12, step = 1,
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateLayout(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.buttonsPerRow = {
		order = 6,
		type = "range",
		name = L["Buttons Per Row"],
		desc = L["The amount of buttons to display per row."],
		min = 1, max = 12, step = 1,
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateLayout(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.buttonsize = {
		order = 7,
		type = "range",
		name = L["Button Size"],
		min = 2, max = 60, step = 1,
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateLayout(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.buttonspacing = {
		order = 8,
		type = "range",
		name = L["Button Spacing"],
		desc = L["The spacing between buttons."],
		min = -1, max = 24, step = 1,
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateLayout(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.backdropSpacing = {
		order = 9,
		type = "range",
		name = L["Backdrop Spacing"],
		desc = L["The spacing between the backdrop and the buttons."],
		min = 0, max = 10, step = 1,
		get = function(info) return E.db.general.minimap.buttons[ info[#info] ]; end,
		set = function(info, value) E.db.general.minimap.buttons[ info[#info] ] = value; addon:UpdateLayout(); end,
	};
	E.Options.args.maps.args.minimap.args.icons.args.insideMinimapGroup = {
		order = 10,
		type = "group",
		name = L["Inside Minimap"],
		guiInline = true,
		get = function(info) return E.db.general.minimap.buttons.insideMinimap[info[#info]]; end,
		set = function(info, value) E.db.general.minimap.buttons.insideMinimap[info[#info]] = value; addon:UpdatePosition(); end,
		args = {
			enable = {
				order = 1,
				type = "toggle",
				name = L["Enable"],
			},
			position = {
				order = 2,
				type = "select",
				name = L["Position"],
				values = positionValues,
				disabled = function() return not E.db.general.minimap.buttons.insideMinimap.enable; end
			},
			xOffset = {
				order = 3,
				type = "range",
				name = L["xOffset"],
				min = -20, max = 20, step = 1,
				disabled = function() return not E.db.general.minimap.buttons.insideMinimap.enable; end
			};
			yOffset = {
				order = 4,
				type = "range",
				name = L["yOffset"],
				min = -20, max = 20, step = 1,
				disabled = function() return not E.db.general.minimap.buttons.insideMinimap.enable; end
			}
		}
	};
end

local SkinnedButtons = {}

local IgnoreButtons = {
	"ElvConfigToggle",

	"BattlefieldMinimap",
	"ButtonCollectFrame",
	"GameTimeFrame",
	"MiniMapBattlefieldFrame",
	"MiniMapLFGFrame",
	"MiniMapMailFrame",
	"MiniMapPing",
	"MiniMapRecordingButton",
	"MiniMapTracking",
	"MiniMapTrackingButton",
	"MiniMapVoiceChatFrame",
	"MiniMapWorldMapButton",
	"Minimap",
	"MinimapBackdrop",
	"MinimapToggleButton",
	"MinimapZoneTextButton",
	"MinimapZoomIn",
	"MinimapZoomOut",
	"TimeManagerClockButton"
}

local GenericIgnores = {
	"GuildInstance",

	-- GatherMate
	"GatherMatePin",
	"GatherNote",
	-- GuildMap3
	"GuildMap3Mini",
	-- HandyNotes
	"HandyNotesPin",
	-- Nauticus
	"NauticusMiniIcon",
	"WestPointer",
	-- Spy
	"Spy_MapNoteList_mini",
}

local PartialIgnores = {
	"Node",
	"Note",
	"Pin",
}

local WhiteList = {
	"LibDBIcon",
}

function addon:GrabMinimapButtons()
	for i = 1, Minimap:GetNumChildren() do
		local object = select(i, Minimap:GetChildren())

		if(object and object:IsObjectType("Button") and object:GetName()) then
			self:SkinMinimapButton(object)
		end
	end

	for i = 1, MinimapBackdrop:GetNumChildren() do
		local object = select(i, MinimapBackdrop:GetChildren())

		if(object and object:IsObjectType("Button") and object:GetName()) then
			self:SkinMinimapButton(object)
		end
	end

	if(FishingBuddyMinimapFrame) then self:SkinMinimapButton(FishingBuddyMinimapButton); end

	if(self:CheckVisibility() or self.needupdate) then
		self:UpdateLayout();
	end
end

function addon:SkinMinimapButton(button)
	if (not button or button.isSkinned) then return end

	local name = button:GetName()
	if not name then return end

	if button:IsObjectType("Button") then
		local validIcon = false

		for i = 1, #WhiteList do
			if sub(name, 1, len(WhiteList[i])) == WhiteList[i] then validIcon = true break end
		end

		if not validIcon then
			for i = 1, #IgnoreButtons do
				if name == IgnoreButtons[i] then return end
			end

			for i = 1, #GenericIgnores do
				if sub(name, 1, len(GenericIgnores[i])) == GenericIgnores[i] then return end
			end

			for i = 1, #PartialIgnores do
				if find(name, PartialIgnores[i]) ~= nil then return end
			end
		end

		button:SetPushedTexture(nil)
		button:SetHighlightTexture(nil)
		button:SetDisabledTexture(nil)
	end

	for i = 1, button:GetNumRegions() do
		local region = select(i, button:GetRegions())

		if region:GetObjectType() == "Texture" then
			local texture = region:GetTexture()

			if texture and (find(texture, "Border") or find(texture, "Background") or find(texture, "AlphaMask")) then
				region:SetTexture(nil)
			else
				if name == "BagSync_MinimapButton" then region:SetTexture("Interface\\AddOns\\BagSync\\media\\icon") end
				if name == "DBMMinimapButton" then region:SetTexture("Interface\\Icons\\INV_Helmet_87") end
				if name == "SmartBuff_MiniMapButton" then region:SetTexture("Interface\\Icons\\Spell_Nature_Purge") end
				if name == "VendomaticButtonFrame" then region:SetTexture("Interface\\Icons\\INV_Misc_Rabbit_2") end

				region:ClearAllPoints()
				region:SetInside()
				region:SetTexCoord(unpack(E.TexCoords))
				button:HookScript("OnLeave", function(self) region:SetTexCoord(unpack(E.TexCoords)) end)

				region:SetDrawLayer("ARTWORK")
				region.SetPoint = function() return end
			end
		end
	end

	button:SetParent(self.frame);
	button:SetFrameLevel(self.frame:GetFrameLevel() + 2)

	button:SetTemplate("Default");
	button:SetScript("OnDragStart", nil);
	button:SetScript("OnDragStop", nil);
	button:HookScript("OnEnter", self.OnEnter);
	button:HookScript("OnLeave", self.OnLeave);

	button.isSkinned = true;
	tinsert(SkinnedButtons, button);
	self.needupdate = true;
end

function addon:UpdatePosition()
	local db = E.db.general.minimap.buttons.insideMinimap;
	local mover = self.frame.mover;

	if(db.enable) then
		mover:ClearAllPoints();
		mover:Point(db.position, Minimap, db.position, db.xOffset, db.yOffset);

		E:DisableMover(self.frame.mover:GetName());
	else
		E:EnableMover(self.frame.mover:GetName());

		local point, anchor, secondaryPoint, x, y = split(",", E.db["movers"][mover:GetName()] or E.CreatedMovers[mover:GetName()]["point"]);
		mover:ClearAllPoints();
		mover:Point(point, anchor, secondaryPoint, x, y);
	end
end

function addon:UpdateAlpha()
	if(E.db.general.minimap.buttons.mouseover) then
		self.frame:SetAlpha(0);
	else
		self.frame:SetAlpha(E.db.general.minimap.buttons.alpha);
	end
end

function addon:CheckVisibility()
	local updateLayout = false;

	for _, button in ipairs(SkinnedButtons) do
		if(button:IsVisible() and button.hidden) then
			button.hidden = false;
			updateLayout = true;
		elseif(not button:IsVisible() and not button.hidden) then
			button.hidden = true;
			updateLayout = true;
		end
	end

	return updateLayout;
end

function addon:GetVisibleList()
	local tab = {}
	for _, button in ipairs(SkinnedButtons) do
		if button:IsVisible() then
			tinsert(tab, button)
		end
	end

	return tab
end

function addon:UpdateLayout()
	local VisibleButtons = self:GetVisibleList()
	if(#VisibleButtons < 1) then return; end

	local buttonSpacing = E.db.general.minimap.buttons.buttonspacing;
	local backdropSpacing = E.db.general.minimap.buttons.backdropSpacing or E.db.general.minimap.buttons.buttonspacing;
	local buttonsPerRow = E.db.general.minimap.buttons.buttonsPerRow;
	local numButtons = #VisibleButtons;
	local size = E.db.general.minimap.buttons.buttonsize;
	local point = E.db.general.minimap.buttons.point;
	local numColumns = ceil(numButtons / buttonsPerRow);

	if(numButtons < buttonsPerRow) then
		buttonsPerRow = numButtons;
	end

	local barWidth = (size * buttonsPerRow) + (buttonSpacing * (buttonsPerRow - 1)) + (backdropSpacing * 2) + ((E.db.general.minimap.buttons.backdrop == true and E.Border or E.Spacing) * 2);
	local barHeight = (size * numColumns) + (buttonSpacing * (numColumns - 1)) + (backdropSpacing * 2) + ((E.db.general.minimap.buttons.backdrop == true and E.Border or E.Spacing) * 2);
	self.frame:Size(barWidth, barHeight);

	if(E.db.general.minimap.buttons.backdrop == true) then
		self.frame.backdrop:Show();
	else
		self.frame.backdrop:Hide();
	end

	local horizontalGrowth, verticalGrowth;
	if(point == "TOPLEFT" or point == "TOPRIGHT") then
		verticalGrowth = "DOWN";
	else
		verticalGrowth = "UP";
	end

	if(point == "BOTTOMLEFT" or point == "TOPLEFT") then
		horizontalGrowth = "RIGHT";
	else
		horizontalGrowth = "LEFT";
	end

	local firstButtonSpacing = backdropSpacing + (E.db.general.minimap.buttons.backdrop == true and E.Border or E.Spacing);
	for i, button in ipairs(VisibleButtons) do
		local lastButton = SkinnedButtons[i - 1];
		local lastColumnButton = SkinnedButtons[i - buttonsPerRow];
		button:Size(size);
		button:ClearAllPoints();

		if(i == 1) then
			local x, y;
			if(point == "BOTTOMLEFT") then
				x, y = firstButtonSpacing, firstButtonSpacing;
			elseif(point == "TOPRIGHT") then
				x, y = -firstButtonSpacing, -firstButtonSpacing;
			elseif(point == "TOPLEFT") then
				x, y = firstButtonSpacing, -firstButtonSpacing;
			else
				x, y = -firstButtonSpacing, firstButtonSpacing;
			end

			button:Point(point, self.frame, point, x, y);
		elseif((i - 1) % buttonsPerRow == 0) then
			local x = 0;
			local y = -buttonSpacing;
			local buttonPoint, anchorPoint = "TOP", "BOTTOM";
			if(verticalGrowth == "UP") then
				y = buttonSpacing;
				buttonPoint = "BOTTOM";
				anchorPoint = "TOP";
			end
			button:Point(buttonPoint, lastColumnButton, anchorPoint, x, y);
		else
			local x = buttonSpacing;
			local y = 0;
			local buttonPoint, anchorPoint = "LEFT", "RIGHT";
			if(horizontalGrowth == "LEFT") then
				x = -buttonSpacing;
				buttonPoint = "RIGHT";
				anchorPoint = "LEFT";
			end

			button:Point(buttonPoint, lastButton, anchorPoint, x, y);
		end
	end

	self.needupdate = false
end

function addon:OnEnter()
	if(E.db.general.minimap.buttons.mouseover) then
		UIFrameFadeIn(ElvUI_MinimapButtonGrabber, 0.1, ElvUI_MinimapButtonGrabber:GetAlpha(), E.db.general.minimap.buttons.alpha)
	end
end

function addon:OnLeave()
	if(E.db.general.minimap.buttons.mouseover) then
		UIFrameFadeOut(ElvUI_MinimapButtonGrabber, 0.1, ElvUI_MinimapButtonGrabber:GetAlpha(), 0)
	end
end

function addon:Initialize()
	EP:RegisterPlugin(addonName, GetOptions);

	self.frame = CreateFrame("Button", "ElvUI_MinimapButtonGrabber", UIParent)
	self.frame:SetFrameStrata("LOW")
	self.frame:SetClampedToScreen(true)
	self.frame:CreateBackdrop("Default");
	local offset = E.Spacing;
	self.frame.backdrop:SetPoint("TOPLEFT", self.frame, "TOPLEFT", offset, -offset);
	self.frame.backdrop:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -offset, offset);

	self.frame:Point("TOPRIGHT", UIParent, "TOPRIGHT", -3, -201);
	self:GrabMinimapButtons();
	self:UpdateLayout();
	self:UpdateAlpha();

	E:CreateMover(self.frame, "MinimapButtonGrabberMover", L["Minimap Button Grabber"], nil, nil, nil, "ALL,GENERAL");
	self:UpdatePosition();

	self.frame:SetScript("OnEnter", self.OnEnter)
	self.frame:SetScript("OnLeave", self.OnLeave)

	self:ScheduleTimer("GrabMinimapButtons", 6);
	self:ScheduleRepeatingTimer("GrabMinimapButtons", 5);
end

E:RegisterModule(addon:GetName());