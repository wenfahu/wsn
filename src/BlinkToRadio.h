// $Id: BlinkToRadio.h,v 1.4 2006/12/12 18:22:52 vlahan Exp $

#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 30,
  AM_TEST_SERIAL_MSG = 0x89
};

typedef nx_struct BlinkToRadio {
	nx_uint16_t nodeid;
	nx_uint16_t fromid;
	nx_uint16_t counter;

	nx_uint16_t tmp;
	nx_uint16_t hmd;
	nx_uint16_t lht;

	nx_uint16_t tm;
} BlinkToRadioMsg;


typedef nx_struct ChangeTimerMsg {
  nx_uint16_t nodeid;
  nx_uint16_t newtime;
} ChangeTimerMsg;

typedef nx_struct ChangeRadioMsg {
	nx_uint16_t newtime;
} ChangeRadioMsg;

#endif
