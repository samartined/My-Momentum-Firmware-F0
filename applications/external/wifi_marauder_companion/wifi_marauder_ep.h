// evil portal helper
#pragma once

#include "wifi_marauder_app_i.h"

bool wifi_marauder_ep_read_html_file(WifiMarauderApp* app, uint8_t** the_html, size_t* html_size);
bool wifi_marauder_ep_read_ap_config_file(WifiMarauderApp* app, char** ap_name, size_t* ap_name_size);
