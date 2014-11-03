// When creating merged sketch:
// make sure global variables have unique name
// remove duplicated (size, tuio, etc) setup steps
// remove tuio stuff from draw functions
// Each tab should have a setup0() function and draw0(tuioCursorList) function

// When shifting individual parts, make sure to move:
// global variables
// setup, draw function and other tab contents
// unique global functions if they exist
// Make sure required global functions are included in all merged sketches
// Update draw function numbers, numDrawFunctions and switch statement in master draw function

import processing.opengl.*;
import netP5.*;
import oscP5.*;
import tuio.*;
import traer.physics.*;

NetAddress myRemoteLocation;
OscP5 oscP5;
TuioClient tuioClient;

/* The number in the following line depends on the machine the sketch will be running on:
 * Machine 0.9 uses 100
 * Machine 0.10 uses 200
 * Machine 0.11 uses 300
 * Machine 0.12 uses 400 */
int tuioIncrementForThisMachine = 400;

// maxNumIdsToRecognize can be increased if required
// it's just to get a counter for cycling through 'for' loops
int maxNumIdsToRecognize = 16;
int smallerOfTuioIdsAndMaxIds;

// arrays to hold touchX and touchY for each TUIO ID on screen
// i.e. touchX[0] and touchY[0] are the x and y coordinates for one TUIO ID on screen
// touchX[1] and touchY[1] are the x and y coordinates for another TUIO ID on screen, and so on
float[] touchX = new float[maxNumIdsToRecognize];
float[] touchY = new float[maxNumIdsToRecognize];

// arrays to store the previous x, y position of each TUIO ID
float[] previousX = new float[maxNumIdsToRecognize];
float[] previousY = new float[maxNumIdsToRecognize];

// if there are no current TUIO IDs, we generate a random TUIO ID every 'numFramesToGenerateRandomId' frames
int numFramesToGenerateRandomId = 600;

boolean fadingOut = false;
boolean fadingTimerRunning = false;
int fadeOutTimer;
int alphaValue = 0;  // start at 10 and increment by 1?
int timeOfLastIncrement;

int numSecondsBeforeChange = 120;
int secondsToFadeOut = 3;

int startTime;
int masterFrameCounter = 0;

int numColors = 6;
color[] colorArray = new color[numColors];

//////////////////////////////////
// Global variables
//////////////////////////////////

//////////////////////////////////
// Tara's global variables start
//////////////////////////////////

color jade = color(144,214,195);
color grass = color(22,156,66);
color orange = color(250,150,0);
color sky = color(0,196,196);
color tourq = color(0,183,250);
color teal = color(41,176,188);
color bamboo = color(137,136,121);

color[] springyBirds_colorArray = new color[3];

//////////////////////////////////
// Tara's global variables end
//////////////////////////////////

//////////////////////////////////
// Puddles global variables start
//////////////////////////////////

SetOfPuddlesForOneCursor[] puddleSets = new SetOfPuddlesForOneCursor[maxNumIdsToRecognize];

int maxNumPuddlesPerSet = 60;

// Variable used to determine when to draw next puddle
int distanceBeforeNewPuddleGlobal = 30;

int frameCounter = 0;
/* If ripples grow every frame, framesBeforeRippleGrowth should be 1
   If ripples grow every 2nd frame, framesBeforeRippleGrowth should be 2, etc */
int framesBeforeRippleGrowth = 2;

// Variables for growth rate of ripples
int numRipplesGlobal = 4;
int[] rippleIncrementsGlobal = new int[numRipplesGlobal];
int fadeOutSpeedGlobal = 5;

// rippleStrokeAsFractionOfDiameter is the stroke weight expressed as a fraction of the ripple's diameter
// Set rippleStrokeAsFractionOfDiameter to 0 to have a stroke weight of 1
int rippleStrokeAsFractionOfDiameter = 16;

//////////////////////////////////
// Puddles global variables end
//////////////////////////////////

//////////////////////////////////
// Calligraphy global variables start
//////////////////////////////////

SetOfLines[] calligraphy_lineSets = new SetOfLines[maxNumIdsToRecognize];

//////////////////////////////////
// Calligraphy global variables end
//////////////////////////////////

//////////////////////////////////
// Seed global variables start
//////////////////////////////////

PImage seed_seeds; 
ArrayList seed_psystems;

//////////////////////////////////
// Seed global variables end
//////////////////////////////////

//////////////////////////////////
// SpringFluidBox global variables start
//////////////////////////////////

ParticleSystem springFluidBox_physics;

int springFluidBox_numParticles = 30;
Particle[] springFluidBox_mouse = new Particle[maxNumIdsToRecognize];
float springFluidBox_attractionStrength = -10000;   // magnitude of attraction/repulsion force between mouse and particles
float springFluidBox_attractionMinDistance = 100;  // "minimum distance that limits how strong this force can get close up"

Particle[][] springFluidBox_others;
Particle[][] springFluidBox_anchors;  // invisible anchor particles to mark rest position of 'other' particles
Spring[][] springFluidBox_springs;    // spring force that returns 'other' particles to rest position when mouse is not moving

float springFluidBox_springStrength = 0.005;  // strength of spring force (how quickly particles will return to rest position)
float springFluidBox_damping = 0.003;          // strength of oscillation effect when particles are returning to rest position

boolean springFluidBox_springsActive = true;    // springs become inactive when mouse is moving
float springFluidBox_periodOfNoMovement = 1;  // length of time before springs come into effect (when mouse is not moving)

PImage springFluidBox_img;

//////////////////////////////////
// SpringFluidBox global variables end
//////////////////////////////////


//////////////////////////////////
// Setup
//////////////////////////////////

void setup()
{
  size(screen.width, screen.height, OPENGL);

  myRemoteLocation = new NetAddress("192.168.0.08",12001);  // this tells it which computer to send the messages to
  oscP5 = new OscP5(this,12000);
  tuioClient  = new TuioClient(this);

  /*
  colorArray[0] = color(255, 0, 0);  // red
  colorArray[1] = color(255, 255, 0);  // yellow
  colorArray[2] = color(0, 255, 0);  // green
  colorArray[3] = color(0, 255, 255);  // cyan
  colorArray[4] = color(0, 0, 255);  // blue
  colorArray[5] = color(255, 0, 255);  // purple
  colorArray[6] = color(255, 255, 255);  // white
  colorArray[7] = color(240, 130, 0);  // orange
  colorArray[8] = color(100, 100, 255);  // lightblue
  */
  /*
  colorArray[0] = color(0, 0, 80);  // navy
  colorArray[1] = color(0, 0, 156);  // blue
  colorArray[2] = color(176, 176, 176);  // light grey
  //colorArray[3] = color(79, 79, 79);  // dark grey
  colorArray[3] = color(255, 127, 0);  // orange
  colorArray[4] = color(179, 89, 0);  // browny orange
  colorArray[5] = color(61, 204, 204);  // turquoise
  colorArray[6] = color(128, 255, 255);  // light turquoise
  */
  colorArray[0] = color(179, 0, 0);  // red
  colorArray[1] = color(179, 89, 0);  // browny orange
  colorArray[2] = color(148, 145, 0);  // mustard green
  colorArray[3] = color(51, 204, 255);  // turquoise
  colorArray[4] = color(0, 51, 149);  // dark blue
  colorArray[5] = color(176, 176, 176);  // light grey

  smooth();

  // Ensure all of these are also included in switch statement below
  setup3();
  //setup2();
  //setup1();
  setup0();
}

//////////////////////////////////
// Master draw
//////////////////////////////////

int numDrawFunctions = 2;
int idOfCurrentDrawFunction = 0;
void draw()
{
  TuioCursor[] tuioCursorList = tuioClient.getTuioCursors();

  if (tuioCursorList.length > 0) {
    smallerOfTuioIdsAndMaxIds = min(tuioCursorList.length, maxNumIdsToRecognize);

    for (int i = 0; i < smallerOfTuioIdsAndMaxIds; i++) {
      TuioCursor tcur = tuioCursorList[i];

      touchX[i] = tcur.getScreenX(width);   // cycle through all current TUIO IDs and
      touchY[i] = tcur.getScreenY(height);  // assign their coordinates into the touchX and touchY arrays
    }
  }

  switch(idOfCurrentDrawFunction) {
  case 0: 
    draw0(tuioCursorList);  // Calligraphy
    if (fadingOut) {
      fadeOut(0);
    }
    break;
  /*
  case 1: 
    draw1(tuioCursorList);  // Seed
    if (fadingOut) {
      fadeOut(0);
    }
    break;
  */
  /* SpringFluidBox not working
  case 2: 
    draw2(tuioCursorList);  // SpringFluidBox
    if (fadingOut) {
      fadeOut(0);
    }
    break;
  */
  case 1: 
    draw3(tuioCursorList);  // Puddles
    if (fadingOut) {
      fadeOut(0);
    }
    break;
  }
  
  for (int i = 0; i < maxNumIdsToRecognize; i++) {
    previousX[i] = touchX[i];
    previousY[i] = touchY[i];
  }

  float runningTime = (millis() - startTime) / 1000;  // number of seconds that current draw function has been running
  if (runningTime >= numSecondsBeforeChange && !fadingTimerRunning) {  // initiate the fade out process after numSecondsBeforeChange seconds
    fadingOut = true;
    fadeOutTimer = millis();
    fadingTimerRunning = true;
  }
  
  float fadingOutTime = (millis() - fadeOutTimer) / 1000;
  if (fadingOut && fadingOutTime >= secondsToFadeOut) {
    fadingOut = false;
    fadingTimerRunning = false;
    alphaValue = 0;

    idOfCurrentDrawFunction++;  // advance to the next sketch
    if (idOfCurrentDrawFunction == numDrawFunctions) {  // ensure this is a valid sketch
      idOfCurrentDrawFunction = 0;  // if not, return to start
    }
    
    switch(idOfCurrentDrawFunction) {  // call setup() again to reset everything
    case 0: 
      setup0();
      break;
    /*
    case 1: 
      setup1();
      break;
    */
    /*
    case 2: 
      setup2();
      break;
    */
    case 1: 
      setup3();
      break;
    }

    startTime = millis();  // restart sketch timer
  }
  
  masterFrameCounter++;
}


//////////////////////////////////
// Global functions
//////////////////////////////////

color getNewColor() {
  int newColorIndex = (int)random(0, numColors);
  return colorArray[newColorIndex];
}

float getDistance(float x1, float y1, float x2, float y2) {
  return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}

/*
void fadeOut(int shade)
{
  if (masterFrameCounter % 5 == 0) {  // maybe fade out quicker than every 5 frames
    fill(shade, 10);
    rect(-2, -2, width+2, height+2);
  }
}
*/

void fadeOut(int shade) {
  // alphaValue should increase only every secondsToFadeOut/25.5 seconds
  float intervalForIncreasingAlpha = 1000*secondsToFadeOut/25.5;
  if (millis() - timeOfLastIncrement >= (int)intervalForIncreasingAlpha) {
    alphaValue += 10;
    timeOfLastIncrement = millis();
  }
  fill(shade, alphaValue);
  rect(-2, -2, width+2, height+2);
}


//////////////////////////////////
// Neill's global functions start
//////////////////////////////////

//FUNCTION FOR CREATING A RADIAL BLEND ========================
void drawGradientDisc(float x,float y, float radiusX, float radiusY, int innerCol, int outerCol) {
  noStroke();
  beginShape(TRIANGLE_STRIP);
  for(float theta = 0; theta < TWO_PI; theta += TWO_PI/36) {
    fill(innerCol);
    vertex(x,y);
    fill(outerCol);
    vertex(x + radiusX*cos(theta), y + radiusY*sin(theta));
  }
  endShape();
}

//////////////////////////////////
// Neill's global functions end
//////////////////////////////////


//////////////////////////////////
// Touchlib/TUIO functions
//////////////////////////////////

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  println("add object "+tobj.getFiducialID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  println("remove object "+tobj.getFiducialID()+" ("+tobj.getSessionID()+")");
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  println("update object "+tobj.getFiducialID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getFingerID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  OscMessage myOscMessage = new OscMessage("/on");
  myOscMessage.add(tcur.getFingerID() + tuioIncrementForThisMachine);
  oscP5.send(myOscMessage, myRemoteLocation);
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("update cursor "+tcur.getFingerID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getFingerID()+" ("+tcur.getSessionID()+")");
  OscMessage myOscMessage = new OscMessage("/off");
  myOscMessage.add(tcur.getFingerID() + tuioIncrementForThisMachine);
  oscP5.send(myOscMessage, myRemoteLocation);
}

// called after each message bundle
// representing the end of an image frame
void refresh(long timestamp) { 
  //redraw();
}
