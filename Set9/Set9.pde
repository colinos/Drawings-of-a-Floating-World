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
int tuioIncrementForThisMachine = 100;

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
// Springs global variables start
//////////////////////////////////

int springs_numSlinkiesPerId = 2;
Springs_Spring[][] springs_springs = new Springs_Spring[springs_numSlinkiesPerId][maxNumIdsToRecognize];

//////////////////////////////////
// Springs global variables end
//////////////////////////////////

//////////////////////////////////
// Tadpoles global variables start
//////////////////////////////////

int tadpoles_randomID;

int numTadpoles = 12; 
Tadpoles_Spring[] tadpoles = new Tadpoles_Spring[numTadpoles]; 

BubbleSet[] tadpoles_bubbleSets = new BubbleSet[maxNumIdsToRecognize];

int tadpoles_criticalDistance = 100;

//color tadpoles_backgroundColor = color(51);
color tadpoles_backgroundColor = color(0);

//////////////////////////////////
// Tadpoles global variables end
//////////////////////////////////

//////////////////////////////////
// SpringingSnow global variables start
//////////////////////////////////

ParticleSystem springingSnow_physics;

int springingSnow_numParticles = 500;
Particle[] springingSnow_mouse = new Particle[maxNumIdsToRecognize];
float springingSnow_attractionStrength = -10000;   // magnitude of attraction/repulsion force between mouse and particles
float springingSnow_attractionMinDistance = 1;  // "minimum distance that limits how strong this force can get close up"

Particle[] springingSnow_others;
Particle[] springingSnow_anchors;  // invisible anchor particles to mark rest position of 'other' particles
Spring[] springingSnow_springs;    // spring force that returns 'other' particles to rest position when mouse is not moving
float springingSnow_springStrength = 0.0005;  // strength of spring force (how quickly particles will return to rest position)
float springingSnow_damping = 0.0001;          // strength of oscillation effect when particles are returning to rest position

int[][] springingSnow_angles;
int[][] springingSnow_angleIncrements;
float[][] springingSnow_scales;

boolean springingSnow_springsActive = true;    // springs become inactive when mouse is moving
float springingSnow_timer;                     // timer to time length of time mouse has been stationary
float springingSnow_periodOfNoMovement = 1;  // length of time before springs come into effect (when mouse is not moving)

PImage springingSnow_img;

float springingSnow_orbit = -180;

//////////////////////////////////
// SpringingSnow global variables end
//////////////////////////////////

//////////////////////////////////
// SpringFluidRandom global variables start
//////////////////////////////////

ParticleSystem springFluidRandom_physics;

int springFluidRandom_numParticles = 500;
Particle[] springFluidRandom_mouse = new Particle[maxNumIdsToRecognize];
float springFluidRandom_attractionStrength = -10000;   // magnitude of attraction/repulsion force between mouse and particles
float springFluidRandom_attractionMinDistance = 50;  // "minimum distance that limits how strong this force can get close up"

Particle[] springFluidRandom_others;
Particle[] springFluidRandom_anchors;  // invisible anchor particles to mark rest position of 'other' particles
Spring[] springFluidRandom_springs;    // spring force that returns 'other' particles to rest position when mouse is not moving

float springFluidRandom_springStrength = 0.005;  // strength of spring force (how quickly particles will return to rest position)
float springFluidRandom_damping = 0.003;          // strength of oscillation effect when particles are returning to rest position

boolean springFluidRandom_springsActive = true;    // springs become inactive when mouse is moving
float springFluidRandom_periodOfNoMovement = 1;  // length of time before springs come into effect (when mouse is not moving)

float springFluidRandom_particlePlaceX = (screen.width/springFluidRandom_numParticles)+(screen.width/springFluidRandom_numParticles)/2; // gives an evenly spaced number of particles across the screen
float springFluidRandom_particlePlaceY = (screen.height/springFluidRandom_numParticles)+(screen.height/springFluidRandom_numParticles)/2; // gives an evenly spaced number of particles across the screen

PImage springFluidRandom_img;

//////////////////////////////////
// SpringFluidRandom global variables end
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
  setup2();
  setup1();
  setup0();
}

//////////////////////////////////
// Master draw
//////////////////////////////////

int numDrawFunctions = 4;
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
    draw0(tuioCursorList);  // SpringFluidRandom
    if (fadingOut) {
      fadeOut(0);
    }
    break;
  case 1: 
    draw1(tuioCursorList);  // SpringingSnow
    if (fadingOut) {
      fadeOut(0);
    }
    break;
  case 2: 
    draw2(tuioCursorList);  // Springs
    if (fadingOut) {
      fadeOut(0);
    }
    break;
  case 3: 
    draw3(tuioCursorList);  // Tadpoles
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
    case 1: 
      setup1();
      break;
    case 2: 
      setup2();
      break;
    case 3: 
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
  if (masterFrameCounter % 5 == 0) {  // maybe fade out quicker than every 5 frames?
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
  OscMessage myOscMessage0 = new OscMessage("/XYfilter0");

  int myTuioCursor = tcur.getFingerID();

 if (myTuioCursor == 1){
         myOscMessage0.add(tcur.getFingerID());
         myOscMessage0.add(tcur.getX());                                       //  X = filter cutoff       
         myOscMessage0.add(tcur.getY());                                       //  Y = filter resonance
         oscP5.send(myOscMessage0, myRemoteLocation);
       }

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
