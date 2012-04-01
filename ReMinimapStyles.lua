--[[----------------------------------------------------------------------------
  ReMinimap-Styles.lua
  Author:	phresno
  Revision:	1
  Created:	2006.06.27
  Updated:	2012.04.01
------------------------------------------------------------------------------]]

-- minimap styles
RMM_STYLES = {};
RMM_STYLES["DEFAULT"] = {
   [RMM_S_BORDER] = "Interface\\Minimap\\UI-Minimap-Border",
   [RMM_S_MASK]   = "textures\\MinimapMask",
   ["text"]       = RMM_STYLE_TEXT_DEFAULT,
};
RMM_STYLES["DLX"] = {
   [RMM_S_BORDER] = RMM_STYLE_PATH.."\\dlx\\dlx_border",
   [RMM_S_MASK]   = RMM_STYLE_PATH.."\\dlx\\dlx_mask",
   ["text"]       = RMM_STYLE_TEXT_DLX,
};
RMM_STYLES["SQUARE"] = { -- not yet implemented
   [RMM_S_BORDER] = RMM_STYLE_PATH.."\\square\\square_border",
   [RMM_S_MASK]   = RMM_STYLE_PATH.."\\square\\square_mask",
   ["text"]       = RMM_STYLE_TEXT_SQUARE,
};