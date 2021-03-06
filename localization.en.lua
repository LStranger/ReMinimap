--[[----------------------------------------------------------------------------
  localization.en.lua
  Translator: phresno
  Language:   English (US)
  Created:	  2006.06.27
  Updated:	  2015.07.04
------------------------------------------------------------------------------]]

-- Usage help
RMM_HELP = {
   "Parameters listed in <>'s are required.",
   "Parameters listed in []'s are optional.",
   "\n",
   "/rmm help - this help",
   "/rmm [on/off] - toggles or sets ReMinimap on or off",
   "/rmm time [on/off] - toggles or sets the time of day display",
   "/rmm zoom [on/off] - toggles or sets the zoom buttons display",
   "/rmm wheel [on/off] - toggles or sets the zoom wheel functionality",
   "/rmm zone [on/off] - toggles or sets the display of the location bar",
   "/rmm mapico [on/off] - toggles or sets the display of the worldmap icon",
   "/rmm move <on/off> - toggles or sets the movement lock for the minimap",
   "/rmm move reset - restores the map cluster to the default location",
   "/rmm alpha <0-100> - sets the alpha transparency of the minimap 0 to 100% opaque",
   "/rmm style <style> - sets the minimap style (styles: Default, DLX, Square)",
   "/rmm reset - resets all settings to defaults",
   "/rmm refresh - refreshes the minimap",
};

RMM_HELP_INVSTYLE = "is not a valid minimap style.";

-- Configuration warnings
RMM_CONF_RESET = "New ReMinimap configuration created.";
RMM_CONF_UPDATED = "ReMinimap version changed, you may want check configuration.";

-- Options texts
RMM_OPTIONS = "ReMinimap Options";
RMM_OPT_STYLE = "Minimap style";
RMM_OPT_ZOOM = "Show zoom buttons";
RMM_OPT_WHEEL = "Use mouse wheel to zoom";
RMM_OPT_TIME = "Show time of day icon";
RMM_OPT_ZONE = "Show location bar";
RMM_OPT_WMAP = "Show worldmap icon";
RMM_OPT_PIN = "Pin minimap position";
RMM_OPT_ALPHA = "Alpha of the minimap";
RMM_OPT_ALPHA2 = "opacity";

-- Style texts
RMM_STYLE_TEXT_DLX = "dLx";
RMM_STYLE_TEXT_DEFAULT = "Default";
RMM_STYLE_TEXT_SQUARE = "Square";
