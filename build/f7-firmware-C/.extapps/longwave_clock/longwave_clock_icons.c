#include "longwave_clock_icons.h"

#include <gui/icon_i.h>

const uint8_t _I_lwc_dcf_0[] = {0x00,0xb3,0x01,0x95,0x00,0x95,0x01,0xb3,0x00,};
const uint8_t* const _I_lwc_dcf[] = {_I_lwc_dcf_0};

const uint8_t _I_lwc_msf_0[] = {0x00,0xb7,0x01,0x95,0x00,0xa5,0x01,0xb5,0x00,};
const uint8_t* const _I_lwc_msf[] = {_I_lwc_msf_0};

const uint8_t _I_lwc_sender_0[] = {0x00,0x92,0x00,0x11,0x01,0x55,0x01,0x55,0x01,0x11,0x01,0x92,0x00,0x38,0x00,0x54,0x00,0x92,0x00,};
const uint8_t* const _I_lwc_sender[] = {_I_lwc_sender_0};

const Icon I_lwc_dcf = {.width=9,.height=4,.frame_count=1,.frame_rate=0,.frames=_I_lwc_dcf};
const Icon I_lwc_msf = {.width=9,.height=4,.frame_count=1,.frame_rate=0,.frames=_I_lwc_msf};
const Icon I_lwc_sender = {.width=9,.height=9,.frame_count=1,.frame_rate=0,.frames=_I_lwc_sender};

