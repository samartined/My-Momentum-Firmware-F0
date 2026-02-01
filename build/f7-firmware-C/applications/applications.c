#include "applications.h"
#include <assets_icons.h>
const char* FLIPPER_AUTORUN_APP_NAME = "";
extern int32_t storage_srv(void* p);
extern int32_t cli_vcp_srv(void* p);
extern int32_t bt_srv(void* p);
extern int32_t dialogs_srv(void* p);
extern int32_t dolphin_srv(void* p);
extern int32_t desktop_srv(void* p);
extern int32_t gui_srv(void* p);
extern int32_t input_srv(void* p);
extern int32_t loader_srv(void* p);
extern int32_t notification_srv(void* p);
extern int32_t power_srv(void* p);
const FlipperInternalApplication FLIPPER_SERVICES[] = {

    {.app = storage_srv,
     .name = "StorageSrv",
     .appid = "storage", 
     .stack_size = 3072,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = cli_vcp_srv,
     .name = "CliVcpSrv",
     .appid = "cli_vcp", 
     .stack_size = 1024,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = bt_srv,
     .name = "BtSrv",
     .appid = "bt", 
     .stack_size = 1024,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = dialogs_srv,
     .name = "DialogsSrv",
     .appid = "dialogs", 
     .stack_size = 1024,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = dolphin_srv,
     .name = "DolphinSrv",
     .appid = "dolphin", 
     .stack_size = 1024,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = desktop_srv,
     .name = "DesktopSrv",
     .appid = "desktop", 
     .stack_size = 2048,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = gui_srv,
     .name = "GuiSrv",
     .appid = "gui", 
     .stack_size = 2048,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = input_srv,
     .name = "InputSrv",
     .appid = "input", 
     .stack_size = 1024,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = loader_srv,
     .name = "LoaderSrv",
     .appid = "loader", 
     .stack_size = 2048,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = notification_srv,
     .name = "NotificationSrv",
     .appid = "notification", 
     .stack_size = 1536,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = power_srv,
     .name = "PowerSrv",
     .appid = "power", 
     .stack_size = 1024,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault }
};
const size_t FLIPPER_SERVICES_COUNT = COUNT_OF(FLIPPER_SERVICES);
extern int32_t updater_srv(void* p);
const FlipperInternalApplication FLIPPER_SYSTEM_APPS[] = {

    {.app = updater_srv,
     .name = "UpdaterApp",
     .appid = "updater_app", 
     .stack_size = 2048,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault }
};
const size_t FLIPPER_SYSTEM_APPS_COUNT = COUNT_OF(FLIPPER_SYSTEM_APPS);
extern int32_t subghz_app(void* p);
const FlipperInternalApplication FLIPPER_APPS[] = {

    {.app = subghz_app,
     .name = "Sub-GHz",
     .appid = "subghz", 
     .stack_size = 3072,
     .icon = &A_Sub1ghz_14,
     .flags = FlipperApplicationFlagDefault }
};
const size_t FLIPPER_APPS_COUNT = COUNT_OF(FLIPPER_APPS);
const FlipperInternalApplication FLIPPER_DEBUG_APPS[] = {

};
const size_t FLIPPER_DEBUG_APPS_COUNT = COUNT_OF(FLIPPER_DEBUG_APPS);
extern void cli_on_system_start(void);
extern void rpc_on_system_start(void);
extern void storage_on_system_start(void);
extern void locale_on_system_start(void);
extern void updater_on_system_start(void);
extern void expansion_on_system_start(void);
extern void region_on_system_start(void);
extern void subghz_extended_freq(void);
extern void clock_settings_start(void);
extern void findmy_startup(void);
const FlipperInternalOnStartHook FLIPPER_ON_SYSTEM_START[] = {
cli_on_system_start,
rpc_on_system_start,
storage_on_system_start,
locale_on_system_start,
updater_on_system_start,
expansion_on_system_start,
region_on_system_start,
subghz_extended_freq,
clock_settings_start,
findmy_startup
};
const size_t FLIPPER_ON_SYSTEM_START_COUNT = COUNT_OF(FLIPPER_ON_SYSTEM_START);
extern int32_t archive_app(void* p);
const FlipperInternalApplication FLIPPER_ARCHIVE = 
    {.app = archive_app,
     .name = "Archive",
     .appid = "archive", 
     .stack_size = 6144,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault };
const FlipperExternalApplication FLIPPER_EXTERNAL_APPS[] = {

    {
     .name = "125 kHz RFID",
     .icon = &A_125khz_14,
     .path = "/ext/apps/RFID/lfrfid.fap" },

    {
     .name = "NFC",
     .icon = &A_NFC_14,
     .path = "/ext/apps/NFC/nfc.fap" },

    {
     .name = "Infrared",
     .icon = &A_Infrared_14,
     .path = "/ext/apps/Infrared/infrared.fap" },

    {
     .name = "GPIO",
     .icon = &A_GPIO_14,
     .path = "/ext/apps/GPIO/gpio.fap" },

    {
     .name = "iButton",
     .icon = &A_iButton_14,
     .path = "/ext/apps/iButton/ibutton.fap" },

    {
     .name = "Bad KB",
     .icon = &A_BadUsb_14,
     .path = "/ext/apps/Tools/bad_kb.fap" },

    {
     .name = "U2F",
     .icon = &A_U2F_14,
     .path = "/ext/apps/USB/u2f.fap" },

    {
     .name = "Momentum",
     .icon = &A_Momentum_14,
     .path = "/ext/apps/assets/momentum_app.fap" }
};
const size_t FLIPPER_EXTERNAL_APPS_COUNT = COUNT_OF(FLIPPER_EXTERNAL_APPS);
const FlipperExternalApplication FLIPPER_SETTINGS_APPS[] = {

    {
     .name = "Bluetooth",
     .icon = NULL,
     .path = "/ext/apps/assets/bt_settings.fap" },

    {
     .name = "LCD and Notifications",
     .icon = NULL,
     .path = "/ext/apps/assets/notification_settings.fap" },

    {
     .name = "Storage",
     .icon = NULL,
     .path = "/ext/apps/assets/storage_settings.fap" },

    {
     .name = "Power",
     .icon = NULL,
     .path = "/ext/apps/assets/power_settings.fap" },

    {
     .name = "Desktop",
     .icon = NULL,
     .path = "/ext/apps/assets/desktop_settings.fap" },

    {
     .name = "Passport",
     .icon = NULL,
     .path = "/ext/apps/assets/passport.fap" },

    {
     .name = "System",
     .icon = NULL,
     .path = "/ext/apps/assets/system_settings.fap" },

    {
     .name = "Expansion Modules",
     .icon = NULL,
     .path = "/ext/apps/assets/expansion_settings.fap" },

    {
     .name = "Clock & Alarm",
     .icon = NULL,
     .path = "/ext/apps/assets/clock_settings.fap" },

    {
     .name = "Input",
     .icon = NULL,
     .path = "/ext/apps/assets/input_settings.fap" },

    {
     .name = "About",
     .icon = NULL,
     .path = "/ext/apps/assets/about.fap" }
};
const size_t FLIPPER_SETTINGS_APPS_COUNT = COUNT_OF(FLIPPER_SETTINGS_APPS);