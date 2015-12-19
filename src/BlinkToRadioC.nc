#include <Timer.h>
#include "BlinkToRadio.h"
#include "printf.h"

//Sender
module BlinkToRadioC {
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as Timer0;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface Receive;
	uses interface SplitControl as AMControl;
	uses interface Read<uint16_t> as ReadLht;
	uses interface Read<uint16_t> as ReadHmd;
	uses interface Read<uint16_t> as ReadTmp;
	uses interface Receive as ReceiveFromSerial;
}
implementation {
	uint16_t ID;             //node ID
	uint16_t SOURCE_ID;     //receice the packet trasmit from node SOURCE_ID
	message_t ownpkt;        //its own packet
	message_t otherpkt;       //intertransmit other packet

	uint16_t system_time = 0;
	uint16_t counter = 0;
	uint16_t TIMER_PERIOD = 50;   //sending intervel

	bool havePkt = FALSE;      //have packet to be send
	bool sendOwnPkt = TRUE;    //to send own packet, not intertrasmit

	bool SendBusy = FALSE;
	bool LhtBusy = FALSE;
	bool HmdBusy = FALSE;
	bool TmpBusy = FALSE;

	uint16_t LhtValue;
	uint16_t HmdValue;
	uint16_t TmpValue;

	bool LhtReady = FALSE;
	bool HmdReady = FALSE;
	bool TmpReady = FALSE;

	event void Boot.booted() {
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			ID = TOS_NODE_ID;
			SOURCE_ID = ID + 1;
			call Timer0.startOneShot(TIMER_PERIOD/2);
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err) {
	}

	event void Timer0.fired() {
		sendOwnPkt = TRUE ^ sendOwnPkt;
		system_time += TIMER_PERIOD/2;
		call Leds.led2Toggle();
		call Timer0.startOneShot(TIMER_PERIOD/2);
		if (ID == 0) 
			return;
		if (sendOwnPkt)
		{
			if (LhtReady&&HmdReady&&TmpReady)
			{			
				if (!SendBusy) {
					BlinkToRadioMsg* pkt = (BlinkToRadioMsg*)(call Packet.getPayload(&ownpkt, sizeof(BlinkToRadioMsg)));
					if (pkt == NULL) {
						return;
					}
					pkt->nodeid = ID;
					pkt->fromid = ID;
					pkt->counter = counter;
					pkt->tmp = TmpValue;
					pkt->hmd = HmdValue;
					pkt->lht = LhtValue;
					pkt->tm = system_time;
					counter++;
					if (call AMSend.send(AM_BROADCAST_ADDR, &ownpkt, sizeof(BlinkToRadioMsg)) == SUCCESS) 
					{
						SendBusy = TRUE;
					}
				}
			}
			if (!LhtBusy) 
			{
				LhtBusy = TRUE;
				call ReadLht.read();        
			}
			if (!HmdBusy) 
			{
				HmdBusy = TRUE;
				call ReadHmd.read();        
			}
			if (!TmpBusy) 
			{
				TmpBusy = TRUE;
				call ReadTmp.read();        
			}
		}
		else
		{
			if (havePkt&&ID)
			{
				if (call AMSend.send(AM_BROADCAST_ADDR, &otherpkt, sizeof(BlinkToRadioMsg)) == SUCCESS) 
				{
					SendBusy = TRUE;
				}
			}
		}
	}

	event void AMSend.sendDone(message_t* msg, error_t err) {
		if (&ownpkt == msg) {
			SendBusy = FALSE;
		}
		if (&otherpkt == msg) {
			SendBusy = FALSE;
			havePkt = FALSE;
		}
	}
	
	void sendTimerMsg(uint16_t newtime)
	{
		if (ID==0)
		{
			ChangeTimerMsg* pkt = (ChangeTimerMsg*)(call Packet.getPayload(&ownpkt, sizeof(ChangeTimerMsg)));
			if (pkt == NULL) {
				return;
			}
			counter++;
			pkt->nodeid = ID;
			pkt->newtime = newtime;
			call AMSend.send(AM_BROADCAST_ADDR, &ownpkt, sizeof(ChangeTimerMsg));
		}
	}

	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
		call Leds.led1On();
		if (len == sizeof(ChangeRadioMsg))
		{
			ChangeRadioMsg* pkt = (ChangeRadioMsg*)payload;
			call Leds.led0On();
			sendTimerMsg(pkt->newtime);
		}

		if (len == sizeof(ChangeTimerMsg))
		{
			ChangeTimerMsg* pkt = (ChangeTimerMsg*)payload;
			if (pkt->nodeid == 0)
			{
				TIMER_PERIOD = pkt->newtime;				
			}
		}

		if (len == sizeof(BlinkToRadioMsg)) {
			BlinkToRadioMsg* pkt = (BlinkToRadioMsg*)payload;
			BlinkToRadioMsg* pkt1 = (BlinkToRadioMsg*)(call Packet.getPayload(&otherpkt, sizeof(BlinkToRadioMsg)));
			if (pkt->nodeid == SOURCE_ID)
			{
				if (ID == 0)//打印
				{
					printf("%c%c%c%c%c%c", pkt->fromid, pkt->counter, pkt->tmp, pkt->hmd, pkt->lht, pkt->tm);		
					printfflush();
				}
				else
				{
					havePkt = TRUE;
					pkt1->nodeid = ID;
					pkt1->fromid = pkt->fromid; 
					pkt1->counter = pkt->counter;
					pkt1->tmp = pkt->tmp;
					pkt1->hmd = pkt->hmd;
					pkt1->lht = pkt->lht;
					pkt1->tm = pkt->tm;
				}
			}
		}
		return msg;
	}	
	
	event message_t* ReceiveFromSerial.receive(message_t* msg, void* payload, uint8_t len){
		if (len == sizeof(ChangeRadioMsg)) {
			ChangeRadioMsg* pkt = (ChangeRadioMsg*)payload;
			sendTimerMsg(pkt->newtime);
		}
		return msg;
	}


	event void ReadLht.readDone(error_t result, uint16_t data) 
	{
		LhtBusy = FALSE;
		if (result == SUCCESS)
		{
			LhtValue = data;
			LhtReady=TRUE;
		}
	}
	event void ReadHmd.readDone(error_t result, uint16_t data) 
	{
		HmdBusy = FALSE;
		if (result == SUCCESS)
		{
			HmdValue = data;
			HmdReady=TRUE;
		}
	}
	event void ReadTmp.readDone(error_t result, uint16_t data) 
	{
		TmpBusy = FALSE;
		if (result == SUCCESS)
		{
			TmpValue = data;
			TmpReady=TRUE;
		}
	}
}
