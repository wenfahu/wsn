#include <Timer.h>
#include "BlinkToRadio.h"
#include "printf.h"
configuration BlinkToRadioAppC {
}
implementation {
  //necessary components 
    components MainC;
    components LedsC;
    components ActiveMessageC;                 //active radio
    components BlinkToRadioC as App;
    components new TimerMilliC() as Timer0;
    components SerialActiveMessageC as AM;     //open or close serial
    components new AMSenderC(AM_BLINKTORADIO);       //send message between nodes
    components new AMReceiverC(AM_BLINKTORADIO);     //receive message from nodes
    components new SensirionSht11C() as TmpHumSensor;
    components new HamamatsuS1087ParC() as LightSensor;
    
    //binding
    App.Boot -> MainC;
    App.Leds -> LedsC;
    App.Timer0 -> Timer0;
    App.Packet -> AMSenderC;
    App.AMPacket -> AMSenderC;
    App.AMSend -> AMSenderC;
    App.AMControl -> ActiveMessageC;
    

    App.ReadLht -> LightSensor.Read;
    App.ReadTmp -> TmpHumSensor.Temperature;
    App.ReadHmd -> TmpHumSensor.Humidity;

    App.Receive -> AMReceiverC;
    App.ReceiveFromSerial -> AM.Receive[AM_TEST_SERIAL_MSG];
}
