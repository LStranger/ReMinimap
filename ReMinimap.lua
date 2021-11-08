--[[----------------------------------------------------------------------------
  ReMinimap.lua
  Authors:	phresno, lstranger
  Version:	1.4.0
  Revision:	0
  Created:	2006.06.27
  Updated:	2021.11.07

  See ChangeLog.txt for changes.

  See Readme.txt for more information and additional credits.
------------------------------------------------------------------------------]]

-- pseudo constants --
RMM_S_BORDER    = 01; -- indexes
RMM_S_MASK      = 02;
RMM_S_TRACK     = 03;
RMM_S_MAIL      = 04;
RMM_S_ZOOMIN    = 05;
RMM_S_ZOOMOUT   = 06;
RMM_S_BATTLE    = 07;
RMM_S_MEET      = 08;
RMM_S_WMAP      = 09;

RMM_ENABLE      = "enabled";
RMM_CFG_VER     = "version";
RMM_STYLE       = "style";
RMM_SHOWTIME    = "day time";
RMM_SHOWZOOM    = "zoom button";
RMM_SHOWZONE    = "zone";
RMM_ZOOMWHEEL   = "zoom wheel";
RMM_MOVABLE     = "movable";
RMM_ALPHA       = "opaque";
RMM_SHOWWMAP    = "world map";
RMM_POINT       = "point";

RMM_ON          = "ON";
RMM_OFF         = "OFF";
RMM_BUTTON      = "BUTTON";
RMM_TOGGLE      = "TOGGLE"; -- state
RMM_DEFAULT     = "DEFAULT"; -- style
RMM_RESET       = "RESET";
RMM_VERSION     = "1.4.0";
RMM_VERSION_STR = "R|cffcc0000e|rMinimap v"..RMM_VERSION;
RMM_STYLE_PATH  = "Interface\\AddOns\\ReMinimap\\styles";
RMM_ALPHA_RATE  = 0.05;


-- List of elements that need to be re-attached to Minimap from MinimapCluster
RMM_REMAP_LIST = {
   ["MinimapBackdrop"] = { "TOP", "TOP", -9, -2 },
   ["MinimapBorderTop"] = { "TOP", "TOP", -9, 22 },
   ["MinimapZoneTextButton"] = { "BOTTOM", "TOP", -9, 3 },
   ["MiniMapInstanceDifficulty"] = { "TOPLEFT", "TOPLEFT", -13, 5 },
   ["GuildInstanceDifficulty"] = { "TOPLEFT", "TOPLEFT", -13, 5 },
   ["MiniMapChallengeMode"] = { "TOPLEFT", "TOPLEFT", -7, -1 },
};

-- configuration settings (user changeable) --
rmm_default_cfg = {
   [RMM_ENABLE]     = true, -- entire mod
   [RMM_CFG_VER]    = RMM_VERSION,
   [RMM_STYLE]      = "DEFAULT", -- minimap style
   [RMM_SHOWZOOM]   = true, -- show zoom buttons
   [RMM_ZOOMWHEEL]  = true, -- allow zoom control w/ mouse wheel
   [RMM_SHOWTIME]   = true, -- show the day/night indicator
   [RMM_SHOWZONE]   = true, -- show the location bar
   [RMM_SHOWWMAP]   = true, -- show worldmap icon
   [RMM_MOVABLE]    = false,
   [RMM_ALPHA]      = 1, -- 100% opaque
   [RMM_POINT]      = nil,
};

rmm_cfg = {};

RmmSavedPoint = nil;

--------------------------------------------------------------------------------
-- Options Frame
--------------------------------------------------------------------------------
function RMMA_OptionsFrameStyleInitialize()
    if (rmm_cfg[RMM_STYLE] == nil) then return; end
    local info = UIDropDownMenu_CreateInfo();
    info.func = RMMA_OptionsFrameStyle_OnClick;
    info.owner = RMMA_OptionsFrameStyle;
    table.foreach(RMM_STYLES, function(i, v)
	info.text = v["text"];
	info.value = i;
	UIDropDownMenu_AddButton(info, 1);
    end );
    UIDropDownMenu_SetSelectedValue(RMMA_OptionsFrameStyle, rmm_cfg[RMM_STYLE]);
end

function RMMA_OptionsFrameStyle_OnClick(self, button, down)
    rmm_cfg[RMM_STYLE] = self.value;
    UIDropDownMenu_SetText(RMMA_OptionsFrameStyle, RMM_STYLES[self.value]["text"]);
    Rmm_SetStyle(rmm_cfg[RMM_STYLE]);
end

do
    RMMA_OptionsFrame = CreateFrame("FRAME", "RMMA_OptionsFrame", UIParent );
    RMMA_OptionsFrame.name = "ReMinimap";
    RMMA_OptionsFrame.default = function () RMMA_SetGeneralDefaults(); end;
    InterfaceOptions_AddCategory(RMMA_OptionsFrame);

    -- Options title
    RMMA_OptionsFrameTitle = RMMA_OptionsFrame:CreateFontString("RMMA_OptionsFrameTitle", "ARTWORK", "GameFontNormalLarge");
    RMMA_OptionsFrameTitle:SetPoint("TOPLEFT", 16, -16);
    RMMA_OptionsFrameTitle:SetJustifyH("LEFT");
    RMMA_OptionsFrameTitle:SetJustifyV("TOP");
    RMMA_OptionsFrameTitle:SetText(RMM_OPTIONS);

    -- Select frame style
    RMMA_OptionsFrameStyleTitle = RMMA_OptionsFrame:CreateFontString("RMMA_OptionsFrameStyleTitle", "ARTWORK", "GameFontHighlight");
    RMMA_OptionsFrameStyleTitle:SetPoint("TOPLEFT", RMMA_OptionsFrameTitle, "BOTTOMLEFT", 0, -16);
    RMMA_OptionsFrameStyleTitle:SetText(RMM_OPT_STYLE..":");

    RMMA_OptionsFrameStyle = CreateFrame("Frame", "RMMA_OptionsFrameStyle", RMMA_OptionsFrame, "UIDropDownMenuTemplate");
    RMMA_OptionsFrameStyle:SetPoint("BOTTOMLEFT", RMMA_OptionsFrameStyleTitle, "BOTTOMRIGHT", 0, -12);
    --RMMA_OptionsFrameStyle:SetWidth(200);
    --UIDropDownMenu_SetWidth(RMMA_OptionsFrameStyle, 200);
    --UIDropDownMenu_Initialize(RMMA_OptionsFrameStyle, RMMA_OptionsFrameStyleInitialize);

    -- Toggle zoom wheel control
    RMMA_OptionsFrameWheel = CreateFrame("CheckButton", "RMMA_OptionsFrameWheel", RMMA_OptionsFrame, "ChatConfigCheckButtonTemplate");
    RMMA_OptionsFrameWheel:SetPoint("TOPLEFT", RMMA_OptionsFrameStyleTitle, "BOTTOMLEFT", 0, -10);
    RMMA_OptionsFrameWheelText:SetText(RMM_OPT_WHEEL);
    RMMA_OptionsFrameWheel:SetScript("OnClick",
	function()
	    if (RMMA_OptionsFrameWheel:GetChecked()) then
		rmm_cfg[RMM_ZOOMWHEEL] = true;
	    else
		rmm_cfg[RMM_ZOOMWHEEL] = false;
	    end
	    -- wheel switch will be handled in handler
	end);

    -- Toggle zoom buttons
    RMMA_OptionsFrameZoom = CreateFrame("CheckButton", "RMMA_OptionsFrameZoom", RMMA_OptionsFrame, "ChatConfigCheckButtonTemplate");
    RMMA_OptionsFrameZoom:SetPoint("TOPLEFT", RMMA_OptionsFrameWheel, "BOTTOMLEFT", 0, -6);
    RMMA_OptionsFrameZoomText:SetText(RMM_OPT_ZOOM);
    RMMA_OptionsFrameZoom:SetScript("OnClick",
	function()
	    if (RMMA_OptionsFrameZoom:GetChecked()) then
		rmm_cfg[RMM_SHOWZOOM] = true;
	    else
		rmm_cfg[RMM_SHOWZOOM] = false;
	    end
	    Rmm_SetZoomButton(rmm_cfg[RMM_SHOWZOOM]);
	end);

    -- Toggle day/night indicator
    RMMA_OptionsFrameTime = CreateFrame("CheckButton", "RMMA_OptionsFrameTime", RMMA_OptionsFrame, "ChatConfigCheckButtonTemplate");
    RMMA_OptionsFrameTime:SetPoint("TOPLEFT", RMMA_OptionsFrameZoom, "BOTTOMLEFT", 0, -6);
    RMMA_OptionsFrameTimeText:SetText(RMM_OPT_TIME);
    RMMA_OptionsFrameTime:SetScript("OnClick",
	function()
	    if (RMMA_OptionsFrameTime:GetChecked()) then
		rmm_cfg[RMM_SHOWTIME] = true;
	    else
		rmm_cfg[RMM_SHOWTIME] = false;
	    end
	    Rmm_SetTimeOfDay(rmm_cfg[RMM_SHOWTIME]);
	end);

    -- Toggle location bar
    RMMA_OptionsFrameZone = CreateFrame("CheckButton", "RMMA_OptionsFrameZone", RMMA_OptionsFrame, "ChatConfigCheckButtonTemplate");
    RMMA_OptionsFrameZone:SetPoint("TOPLEFT", RMMA_OptionsFrameTime, "BOTTOMLEFT", 0, -6);
    RMMA_OptionsFrameZoneText:SetText(RMM_OPT_ZONE);
    RMMA_OptionsFrameZone:SetScript("OnClick",
	function()
	    if (RMMA_OptionsFrameZone:GetChecked()) then
		rmm_cfg[RMM_SHOWZONE] = true;
	    else
		rmm_cfg[RMM_SHOWZONE] = false;
	    end
	    Rmm_SetZone(rmm_cfg[RMM_SHOWZONE]);
	end);

    -- Toggle world map button
    RMMA_OptionsFrameWMap = CreateFrame("CheckButton", "RMMA_OptionsFrameWMap", RMMA_OptionsFrame, "ChatConfigCheckButtonTemplate");
    RMMA_OptionsFrameWMap:SetPoint("TOPLEFT", RMMA_OptionsFrameZone, "BOTTOMLEFT", 0, -6);
    RMMA_OptionsFrameWMapText:SetText(RMM_OPT_WMAP);
    RMMA_OptionsFrameWMap:SetScript("OnClick",
	function()
	    if (RMMA_OptionsFrameWMap:GetChecked()) then
		rmm_cfg[RMM_SHOWWMAP] = true;
	    else
		rmm_cfg[RMM_SHOWWMAP] = false;
	    end
	    Rmm_SetWMap(rmm_cfg[RMM_SHOWWMAP]);
	end);

    -- Toggle movability
    RMMA_OptionsFramePin = CreateFrame("CheckButton", "RMMA_OptionsFramePin", RMMA_OptionsFrame, "ChatConfigCheckButtonTemplate");
    RMMA_OptionsFramePin:SetPoint("TOPLEFT", RMMA_OptionsFrameWMap, "BOTTOMLEFT", 0, -6);
    RMMA_OptionsFramePinText:SetText(RMM_OPT_PIN);
    RMMA_OptionsFramePin:SetScript("OnClick",
	function()
	    if (RMMA_OptionsFramePin:GetChecked()) then
		rmm_cfg[RMM_MOVABLE] = false;
	    else
		rmm_cfg[RMM_MOVABLE] = true;
	    end
	    Rmm_FramesMovable(rmm_cfg[RMM_MOVABLE]);
	end);

    -- Toggle quest tracker binding to minimap

    -- Change transparency
    RMMA_OptionsFrameAlpha = CreateFrame("Slider", "RMMA_OptionsFrameAlpha", RMMA_OptionsFrame, "OptionsSliderTemplate");
    RMMA_OptionsFrameAlpha:SetWidth(300);
    RMMA_OptionsFrameAlpha:SetHeight(16);
    RMMA_OptionsFrameAlpha:SetPoint("TOPLEFT", RMMA_OptionsFramePin, "BOTTOMLEFT", 0, -20);
    RMMA_OptionsFrameAlphaText:SetText(RMM_OPT_ALPHA);
    RMMA_OptionsFrameAlphaHigh:SetText("100%");
    RMMA_OptionsFrameAlphaLow:SetText("0%");
    RMMA_OptionsFrameAlpha:SetMinMaxValues(0,1);
    RMMA_OptionsFrameAlpha:SetValueStep(0.01);
    RMMA_OptionsFrameAlpha:SetScript("OnValueChanged",
	function()
	     rmm_cfg[RMM_ALPHA] = RMMA_OptionsFrameAlpha:GetValue();
	     Rmm_SetAlpha(rmm_cfg[RMM_ALPHA]);
	     RMMA_OptionsFrameAlphaText:SetText(RMM_OPT_ALPHA.." ("..RMM_OPT_ALPHA2..abs(ceil((rmm_cfg[RMM_ALPHA] * 100)-0.5)).."%)");
	end );

    -- A RESET button
    RMMA_OptionsFrameReset = CreateFrame("Button", "RMMA_OptionsFrameReset", RMMA_OptionsFrame, "UIPanelButtonTemplate");
    RMMA_OptionsFrameReset:SetSize(420, 22);
    RMMA_OptionsFrameReset:SetPoint("TOPLEFT", RMMA_OptionsFrameAlpha, "BOTTOMLEFT", 0, -32);
    RMMA_OptionsFrameReset:SetText(RMM_OPT_RESET);
    RMMA_OptionsFrameReset:SetScript("OnClick",
	function()
	   Rmm_Cmd_Defaults(true);
	end );
end

--------------------------------------------------------------------------------
-- Main Program Control & Config Functions
--------------------------------------------------------------------------------

function Rmm_OnLoad(self)
   -- register events
   self:RegisterEvent("PLAYER_ENTERING_WORLD");

   -- register slash commands
   SlashCmdList["REMINIMAP"] = Rmm_SlashCmdHandler;
   SLASH_REMINIMAP1 = "/rmm";

   -- register for movement
   Minimap:RegisterForDrag("LeftButton");
   Minimap:SetScript("OnDragStart", function(this) Rmm_OnDragStart(this) end);
   Minimap:SetScript("OnDragStop", function(this) Rmm_OnDragStop(this) end);
   Minimap:ClearAllPoints();
   Minimap:SetParent(UIParent);
   MinimapBackdrop:ClearAllPoints();
   MinimapBackdrop:SetPoint("TOP", Minimap, "TOP", 0, 0);
   for k,v in pairs(RMM_REMAP_LIST) do
      local frame = getglobal(k);
      if (frame ~= nil) then
         frame:ClearAllPoints();
         frame:SetParent(Minimap);
         frame:SetPoint(v[1], Minimap, v[2], v[3], v[4]);
      end
   end

   -- print version string
   Rmm_Print(RMM_VERSION_STR.." loaded.");
end

function Rmm_OnEvent(self, event, arg1)
   if (event == "PLAYER_ENTERING_WORLD") then
      Rmm_Init();
      Rmm_Update();

      -- frames always (re)start locked
--      rmm_cfg[RMM_MOVABLE] = false;
   end
end

function Rmm_SlashCmdHandler(_msg)
   if (_msg) then
      local _, _, cmd, arg1 = string.find(string.upper(_msg), "([%w]+)%s*(.*)$");

      if ("HELP" == cmd) then
         Rmm_Cmd_Help();
      elseif ("TIME" == cmd) then
         Rmm_Cmd_Time(arg1);
      elseif ("ZOOM" == cmd) then
        Rmm_Cmd_Zoom(arg1);
      elseif ("WHEEL" == cmd or "ZOOMWHEEL" == cmd) then
         Rmm_Cmd_Wheel(arg1);
      elseif ("ZONE" == cmd or "LOCATION" == cmd) then
         Rmm_Cmd_Zone(arg1);
      elseif ("MAPICO" == cmd) then
         Rmm_Cmd_WMap(arg1);
      elseif ("STYLE" == cmd) then
         Rmm_Cmd_Style(arg1);
      elseif ("ALPHA" == cmd) then
         Rmm_Cmd_Alpha(arg1);
      elseif ("MOVE" == cmd) then
         Rmm_Cmd_Movable(arg1);
      elseif ("RESET" == cmd) then
         Rmm_Cmd_Defaults(arg1);
      elseif ("STATUS" == cmd) then
         Rmm_Cmd_Status();
      elseif ("LOADMSG" == cmd) then
         Rmm_Cmd_Loadmsg();
      elseif ("REFRESH" == cmd) then
         Rmm_Update();
      else
         Rmm_Cmd_ModEnable(cmd);
      end
   end
end

--------------------------------------------------------------------------------
-- Slash commands (note: Rmm_Update() must be explicitly called)
--------------------------------------------------------------------------------

function Rmm_Cmd_Help()
   Rmm_Print(RMM_VERSION_STR.."\n");

   for k, v in pairs(RMM_HELP) do
      Rmm_Print(v);
   end
end

function Rmm_Cmd_Time(_set)
   Rmm_CfgToggle(RMM_SHOWTIME, _set);
   Rmm_Update();
end

function Rmm_Cmd_Zoom(_set)
   Rmm_CfgToggle(RMM_SHOWZOOM, _set);
   Rmm_Update();
end

function Rmm_Cmd_Wheel(_set)
   Rmm_CfgToggle(RMM_ZOOMWHEEL, _set);
end

function Rmm_Cmd_Zone(_set)
   Rmm_CfgToggle(RMM_SHOWZONE, _set);
   Rmm_Update();
end

function Rmm_Cmd_WMap(_set)
   Rmm_CfgToggle(RMM_SHOWWMAP, _set);
   Rmm_Update();
end

function Rmm_Cmd_Movable(_set)
   if (RMM_RESET == _set) then
      Rmm_SetMapPos();
      Rmm_CfgSet(RMM_POINT, nil);
   else
      if (RMM_ON == _set) then
         Rmm_FramesMovable(true);
         Rmm_CfgSet(RMM_MOVABLE, true);
      elseif (RMM_OFF == _set) then
         Rmm_FramesMovable(false);
         Rmm_CfgSet(RMM_MOVABLE, false);
      end
   end
end

function Rmm_Cmd_Alpha(_set)
   -- range and sanity checks
   _set = math.floor(_set); -- Blizz lua does not properly typecast

   if (nil == _set or 0 > _set) then
      _set = 0;
   elseif (100 < _set) then
      _set = 100;
   end

   _set = _set / 100;

   Rmm_CfgSet(RMM_ALPHA, _set);
   Rmm_Update();
end

function Rmm_Cmd_ModEnable(_set)
   Rmm_CfgToggle(RMM_ENABLE, _set);
   Rmm_Update();
end

function Rmm_Cmd_Style(_set)
   if (nil == _set) then _set = RMM_DEFAULT end

   if (nil ~= RMM_STYLES[_set]) then
      Rmm_CfgSet(RMM_STYLE, _set);
      Rmm_Update();
   else
      Rmm_Print("'".._set.."' "..RMM_HELP_INVSTYLE);
   end
end

function Rmm_Cmd_Defaults(_set)
   Rmm_Cfg_Init();
   Rmm_SetMapPos();
   Rmm_Update();
end

function Rmm_Cmd_Status()
   for k, v in pairs(rmm_cfg) do
      if (nil == v) then vstr = "nil";
      elseif (false == v) then vstr = "false";
      elseif (true == v) then vstr = "true";
      else vstr = v;
      end
      Rmm_Print("IDX "..k.." = "..vstr);
   end
end

function Rmm_Cmd_Loadmsg(_set)
   Rmm_CfgToggle(RMM_LOAD_MSG, _set);
end

--------------------------------------------------------------------------------
-- Main Program Control & Config Functions
--------------------------------------------------------------------------------

-- configuration (re)initialization
function Rmm_Cfg_Init()
   rmm_cfg = rmm_default_cfg;
   Rmm_Print(RMM_CONF_RESET);
end

function Rmm_Cfg_Renit()
   local old_cfg = rmm_cfg;
   rmm_cfg = rmm_default_cfg;
   for k, v in pairs(rmm_cfg) do
      if (old_cfg[k] ~= nil) then
         rmm_cfg[k] = old_cfg[k];
      end
   end
   rmm_cfg[RMM_CFG_VER] = RMM_VERSION;
   Rmm_Print(RMM_CONF_UPDATED);
end

function Rmm_Init()
   -- save original minimap cluster as a reference
   if (RmmSavedPoint == nil) then
      local point, _, _, xOfs, yOfs = MinimapCluster:GetPoint(1);
      if (point == "TOPRIGHT") then
         RmmSavedPoint = { xOfs, yOfs };
      end
   end
   -- if vars not loaded, or there's a version mismatch - defaults
   if (nil == rmm_cfg
       or nil == rmm_cfg[RMM_CFG_VER]
      )
   then
      Rmm_Cfg_Init();
   elseif (RMM_VERSION ~= rmm_cfg[RMM_CFG_VER]) then
      Rmm_Cfg_Renit();
   end
   UIDropDownMenu_Initialize(RMMA_OptionsFrameStyle, RMMA_OptionsFrameStyleInitialize);
end

function Rmm_Update()
   -- minimap style
   if (false == rmm_cfg[RMM_ENABLE]) then
      Rmm_SetStyle(RMM_DEFAULT);
      Rmm_SetZoomButton(true);
      Rmm_SetTimeOfDay(true);
      Rmm_SetZone(true);
      Rmm_SetWMap(true);
      Rmm_SetAlpha(1);
      Rmm_SetMapPos();
      Rmm_FramesMovable(false);
   else
      Rmm_SetStyle(rmm_cfg[RMM_STYLE]);
      Rmm_SetZoomButton(rmm_cfg[RMM_SHOWZOOM]);
      Rmm_SetTimeOfDay(rmm_cfg[RMM_SHOWTIME]);
      Rmm_SetZone(rmm_cfg[RMM_SHOWZONE]);
      Rmm_SetWMap(rmm_cfg[RMM_SHOWWMAP]);
      Rmm_SetAlpha(rmm_cfg[RMM_ALPHA]);
      Rmm_SetMapPos(rmm_cfg[RMM_POINT]); -- map position
      Rmm_FramesMovable(rmm_cfg[RMM_MOVABLE]);
      MiniMapTracking:SetFrameStrata("LOW"); -- fix tracking icon

      -- set options now
      local info = RMM_STYLES[rmm_cfg[RMM_STYLE]];
      if info then
         UIDropDownMenu_SetText(RMMA_OptionsFrameStyle, info["text"]);
      end
      RMMA_OptionsFrameZoom:SetChecked(rmm_cfg[RMM_SHOWZOOM]);
      RMMA_OptionsFrameWheel:SetChecked(rmm_cfg[RMM_ZOOMWHEEL]);
      RMMA_OptionsFrameTime:SetChecked(rmm_cfg[RMM_SHOWTIME]);
      RMMA_OptionsFrameZone:SetChecked(rmm_cfg[RMM_SHOWZONE]);
      RMMA_OptionsFrameWMap:SetChecked(rmm_cfg[RMM_SHOWWMAP]);
      RMMA_OptionsFramePin:SetChecked(not rmm_cfg[RMM_MOVABLE]);
      RMMA_OptionsFrameAlpha:SetValue(rmm_cfg[RMM_ALPHA]);
   end

   -- zoom wheel is handled in the event function itself
end

function Rmm_SetStyle(_style)
   MinimapBorder:SetTexture(RMM_STYLES[_style][RMM_S_BORDER]);
   Minimap:SetMaskTexture(RMM_STYLES[_style][RMM_S_MASK]);
end

function Rmm_SetZoomButton(_state)
   -- do not disable the buttons, they're called by the scroll wheel
   if (false == _state) then
      MinimapZoomIn:Hide();
      MinimapZoomOut:Hide();
   else
      MinimapZoomIn:Show();
      MinimapZoomOut:Show();
   end
end

function Rmm_SetTimeOfDay(_state)
   if (false == _state) then
      GameTimeFrame:Hide();
   else
      GameTimeFrame:Show();
   end
end

function Rmm_SetZone(_state)
   if (false == _state) then
      MinimapZoneTextButton:Disable();
      -- MinimapToggleButton:Disable();
      MinimapZoneTextButton:Hide();
      -- MinimapToggleButton:Hide();
      MinimapBorderTop:Hide();
   else
      MinimapZoneTextButton:Show();
      -- MinimapToggleButton:Show();
      MinimapBorderTop:Show();
      MinimapZoneTextButton:Enable();
      -- MinimapToggleButton:Enable();
   end
end

function Rmm_SetWMap(_state)
   if (false == _state) then
      MiniMapWorldMapButton:Hide();
   else
      MiniMapWorldMapButton:Show();
   end
end

function Rmm_SetAlpha(_val)
   Rmm_CfgSet(RMM_ALPHA, _val);
   Minimap:SetAlpha(_val);
end

function Rmm_SetMapPos(point)
   Minimap:ClearAllPoints();

   if (type(point) == "table" and #point == 4) then
      Minimap:SetPoint(point[1], UIParent, point[2], point[3], point[4]);
   else
      local cpt = RmmSavedPoint or { 0, 0 };
      -- Trying to use correct point if some panel shifted it
      Minimap:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", cpt[1]-17, cpt[2]-22);
   end
end

--------------------------------------------------------------------------------
-- On<Event> functions
--------------------------------------------------------------------------------

function Rmm_OnDragStart(self, target)
   local v = Minimap;
   if InCombatLockdown() then
       return
   elseif (target ~= nil) then
      v = getglobal(target);
   end
   if (rmm_cfg[RMM_MOVABLE]) then
      v.moving = true;
      v:StartMoving();
   else
      return;
   end
end

function Rmm_OnDragStop(self, target)
   local v = Minimap;
   if InCombatLockdown() then
       return
   elseif (target ~= nil) then
      v = getglobal(target);
   end
   v.moving  = false;

   v:StopMovingOrSizing();

   if (v == Minimap) then
      local point, relativeTo, relativePoint, xOfs, yOfs = v:GetPoint(1);

      Rmm_CfgSet(RMM_POINT, { point, relativePoint, xOfs, yOfs });
   end
end

function Rmm_Map_OnMouseWheel(self, _arg)
   if InCombatLockdown() then
       return;
   elseif (IsControlKeyDown()) then
      Rmm_SetAlpha(Rmm_AlphaChange(rmm_cfg[RMM_ALPHA], _arg));
   elseif (rmm_cfg[RMM_ZOOMWHEEL]) then
      if (_arg > 0) then
         Minimap_ZoomIn();
      elseif (_arg < 0 ) then
         Minimap_ZoomOut();
      end
   end
end

--------------------------------------------------------------------------------
-- Generic functions (library style functions)
--------------------------------------------------------------------------------

function Rmm_Print(_text)
   if (_text) then DEFAULT_CHAT_FRAME:AddMessage(_text); end
end

function Rmm_CfgToggle(_opt, _state)
   if (nil ~= _state) then
      _state = string.upper(_state); -- insurance
   end

   if (RMM_ON == _state) then
      rmm_cfg[_opt] = true;
   elseif (RMM_OFF == _state) then
      rmm_cfg[_opt] = false;
   else
      if (rmm_cfg[_opt]) then
         rmm_cfg[_opt] = false;
      else
         rmm_cfg[_opt] = true;
      end
   end

   return rmm_cfg[_opt];
end

function Rmm_CfgSet(_opt, _val)
   rmm_cfg[_opt] = _val;

   return rmm_cfg[_opt];
end

function Rmm_AlphaChange(_cur, _chg)
   -- change by arbitrary rate
   if(_chg > 0 and _cur < 1) then
      _cur = _cur + RMM_ALPHA_RATE;
   elseif (_chg < 0 and _cur > 0) then
      _cur = _cur - RMM_ALPHA_RATE;
   end

   -- sanity check
   if (0 > _cur) then
      _cur = 0;
   elseif (1 < _cur) then
      _cur = 1;
   end

   return _cur;
end

function Rmm_FramesMovable(_state)
   Minimap:SetMovable(_state);
end

