import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;
int port=8000;  //send out to the direct port
int touchID=0;
void setupOsc() {
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", port);
}

void onTouchDown(Touch touch) {
  OscMessage myMessage = new OscMessage("/touchDown");
  myMessage.add(touch.touchID);
  myMessage.add(touch.position.x/tsWidth);
  myMessage.add(touch.position.y/tsHeight);
  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
}

void onTouchMoved(Touch touch)
{
  OscMessage myMessage = new OscMessage("/touchMove");
  myMessage.add(touch.touchID); 
  myMessage.add(touch.position.x/tsWidth);
  myMessage.add(touch.position.y/tsHeight);
  myMessage.add(1.0);  //we don't have shape data for the touch, so just fake it as (1,1) 
  myMessage.add(1.0); 
  oscP5.send(myMessage, myRemoteLocation);
}

void onTouchUp(Touch touch)
{
  OscMessage myMessage = new OscMessage("/touchUp");
  myMessage.add(touch.touchID);
  myMessage.add(touch.position.x/tsWidth);
  myMessage.add(touch.position.y/tsHeight);

  /* send the message */
  oscP5.send(myMessage, myRemoteLocation);
}

