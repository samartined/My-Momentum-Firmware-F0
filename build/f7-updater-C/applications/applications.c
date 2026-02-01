#include "applications.h"
#include <assets_icons.h>
const char* FLIPPER_AUTORUN_APP_NAME = "";
extern int32_t storage_srv(void* p);
extern int32_t gui_srv(void* p);
extern int32_t input_srv(void* p);
extern int32_t notification_srv(void* p);
extern int32_t updater_srv(void* p);
const FlipperInternalApplication FLIPPER_SERVICES[] = {

    {.app = storage_srv,
     .name = "StorageSrv",
     .appid = "storage", 
     .stack_size = 3072,
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

    {.app = notification_srv,
     .name = "NotificationSrv",
     .appid = "notification", 
     .stack_size = 1536,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault },

    {.app = updater_srv,
     .name = "UpdaterSrv",
     .appid = "updater", 
     .stack_size = 2048,
     .icon = NULL,
     .flags = FlipperApplicationFlagDefault }
};
const size_t FLIPPER_SERVICES_COUNT = COUNT_OF(FLIPPER_SERVICES);
const FlipperInternalApplication FLIPPER_SYSTEM_APPS[] = {

};
const size_t FLIPPER_SYSTEM_APPS_COUNT = COUNT_OF(FLIPPER_SYSTEM_APPS);
const FlipperInternalApplication FLIPPER_APPS[] = {

};
const size_t FLIPPER_APPS_COUNT = COUNT_OF(FLIPPER_APPS);
const FlipperInternalApplication FLIPPER_DEBUG_APPS[] = {

};
const size_t FLIPPER_DEBUG_APPS_COUNT = COUNT_OF(FLIPPER_DEBUG_APPS);
extern void storage_on_system_start(void);
const FlipperInternalOnStartHook FLIPPER_ON_SYSTEM_START[] = {
storage_on_system_start
};
const size_t FLIPPER_ON_SYSTEM_START_COUNT = COUNT_OF(FLIPPER_ON_SYSTEM_START);
const FlipperExternalApplication FLIPPER_EXTERNAL_APPS[] = {

};
const size_t FLIPPER_EXTERNAL_APPS_COUNT = COUNT_OF(FLIPPER_EXTERNAL_APPS);
const FlipperExternalApplication FLIPPER_SETTINGS_APPS[] = {

    {
     .name = "LCD and Notifications",
     .icon = NULL,
     .path = "/ext/apps/assets/notification_settings.fap" },

    {
     .name = "Storage",
     .icon = NULL,
     .path = "/ext/apps/assets/storage_settings.fap" },

    {
     .name = "Input",
     .icon = NULL,
     .path = "/ext/apps/assets/input_settings.fap" }
};
const size_t FLIPPER_SETTINGS_APPS_COUNT = COUNT_OF(FLIPPER_SETTINGS_APPS);