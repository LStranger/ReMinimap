--[[----------------------------------------------------------------------------
  localization.ru.lua
  Translator: lstranger
  Language:   Russian (RU)
  Created:    01.04.2012
------------------------------------------------------------------------------]]

if (GetLocale() == "ruRU") then

-- Usage help
RMM_HELP = {
   "Параметры, заключённые в <> - обязательны.",
   "Параметры, заключённые в [] - не обязательны.",
   "\n",
   "/rmm help - данное описание",
   "/rmm [on/off] - включает или выключает ReMinimap",
   "/rmm time [on/off] - включает или выключает значок календаря",
   "/rmm zoom [on/off] - включает или выключает кнопки изменения масштаба",
   "/rmm wheel [on/off] - включает или выключает изменение масштаба колесом мыши",
   "/rmm zone [on/off] - включает или выключает отображение региона",
   "/rmm mapico [on/off] - включает или выключает значок карты мира",
   "/rmm move <on/off> - включает или выключает фиксацию миникарты",
   "/rmm move reset - восстанавливает положение миникарты по умолчанию",
   "/rmm alpha <0-100> - устанавливает непрозрачность миникарты (от 0 до 100%)",
   "/rmm style <style> - устанавливает стиль миникарты (Default, DLX, Square)",
   "/rmm reset - восстанавливает все настройки до стандартных",
   "/rmm refresh - обновить миникарту",
};

RMM_HELP_INVSTYLE = "is not a valid minimap style.";

-- Configuration warnings
RMM_CONF_RESET = "Создана конфигурация ReMinimap из значений по умолчанию!";
RMM_CONF_UPDATED = "ReMinimap обновился, проверьте конфигурацию!";

-- Options text
RMM_OPTIONS = "Настройки ReMinimap";
RMM_OPT_STYLE = "Стиль миникарты";
RMM_OPT_ZOOM = "Показать кнопки изменения масштаба";
RMM_OPT_WHEEL = "Использовать колесо мыши для изменения масштаба";
RMM_OPT_TIME = "Показать значок календаря";
RMM_OPT_ZONE = "Показать панель отображения региона";
RMM_OPT_WMAP = "Показать значок карты мира";
RMM_OPT_PIN = "Зафиксировать положение миникарты";
RMM_OPT_ALPHA = "Прозрачность миникарты";
RMM_OPT_ALPHA2 = "видимость";

-- Style text
RMM_STYLE_TEXT_DLX = "dLx";
RMM_STYLE_TEXT_DEFAULT = "Круглая";
RMM_STYLE_TEXT_SQUARE = "Квадратная";

end -- locale ruRU
