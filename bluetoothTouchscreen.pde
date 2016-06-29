import processing.serial.*;

Serial serial;  // Create object from Serial class
int lineFeed=10;
ArrayList touches;
ArrayList currentTouches;
boolean newPacket=false;
boolean debug=false;
float tsWidth=800;
float tsHeight=500;
int numLines=0;
void setup() 
{
  size(800, 800);
  setupOsc();
  touches=new ArrayList<Touch>();
  currentTouches=new ArrayList<Touch>();
  println(Serial.list());
  String portName = "/dev/tty.HC-05-DevB-2";
  serial = new Serial(this, portName, 115200);
  serial.bufferUntil(lineFeed);
}

void draw()
{
  background(0);
  noFill();
  stroke(255);
  for (int i=0; i<touches.size (); i++)
  {
    Touch t=(Touch)touches.get(i);
    ellipse(t.position.x, t.position.y, 10, 10);
  }
}

void serialEvent(Serial p) { 
  String line=trim(p.readString());  //remove linefeed and whitespace characters
  println(line);
  printStatus();
  // if (debug)
  //   println("line:"+line);
  if (line.length()>0)
  {
    if (line.charAt(0)!='-')
    {
      if (!newPacket)
      {
        currentTouches.clear();
        newPacket=true;
        //if (debug)
        println("starting new packet");
      }
      String[] parts=split(line, ' ');
      if (parts.length==3)
      {
        int touchID=Integer.parseInt(parts[0]);
        int x=Integer.parseInt(parts[1]);
        int y=Integer.parseInt(parts[2]);
        y=480-y;
        if (debug)
          println("received packet!  "+touchID+"  "+x+", "+y);
        Touch touch=new Touch(touchID, new PVector(x, y));
        currentTouches.add(touch);
      }
    } else
    {
      if (newPacket)
      {
        numLines=0;
        newPacket=false;
        //see if one of the existing touches is *not* in currentTouches -- means we have a touchUp
        if (debug)
          println("checking for touch up");
        for (int i=0; i<touches.size (); i++)
        {
          Touch touch=(Touch)touches.get(i);
          boolean inCurrentTouches=false;
          for (int j=0; j<currentTouches.size (); j++)
          {
            Touch currentTouch=(Touch)currentTouches.get(j);
            if (currentTouch.touchID==touch.touchID)
              inCurrentTouches=true;
          }
          if (!inCurrentTouches)
          {
            if (debug)
              println("touchUp:  "+touch.touchID);
            touches.remove(i);
            onTouchUp(touch);
          }
        }

        if (debug)
          println("checking for touchDown or touchMoved");
        for (int i=0; i<currentTouches.size (); i++)
        {
          Touch touch=(Touch)currentTouches.get(i);
          boolean existingTouch=false;
          Touch t=new Touch(0, new PVector(0,0));
          for (int j=0; j<touches.size (); j++)
          {
            t=(Touch)touches.get(j);
            if (t.touchID==touch.touchID)
              existingTouch=true;
          }
          if (existingTouch)
          {
            if (debug)
              println("touch moved: "+touch.touchID);
            onTouchMoved(touch);
            t.position.x=touch.position.x;
            t.position.y=touch.position.y;
          } else
          {
            if (debug)
              println("new touch: "+touch.touchID);
            touches.add(touch);
            onTouchDown(touch);
          }
        }
      } else
      {
        numLines++;
        if (numLines>2)
        {
          currentTouches.clear();
          for (int i=0; i<touches.size (); i++)
          {
            Touch touch=(Touch) touches.get(i);
            onTouchUp(touch);
          }

          touches.clear();
        }
      }
    }
  }
  //  if(debug)
  //    printStatus();
} 

class Touch
{
  PVector position;
  int touchID;

  Touch(int _touchID, PVector _position)
  {
    touchID=_touchID;
    position=_position;
  }
}

void keyPressed()
{
  println(numLines); 
  printStatus();
}

void printStatus()
{
  print("current touch:  ");
  for (int i=0; i<currentTouches.size (); i++)
  {
    Touch t=(Touch)currentTouches.get(i);
    print(t.touchID+" ");
  }
  println();
  print("touches:  ");
  for (int i=0; i<touches.size (); i++)
  {
    Touch t=(Touch)touches.get(i);
    print(t.touchID+" ");
  }
  println();
}

