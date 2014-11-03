void setup1()
{
  for (int i = 0; i < numRipplesGlobal; i++) {
    rippleIncrementsGlobal[i] = i+2;
  }

  for (int i = 0; i < puddleSets.length; i++) {
    puddleSets[i] = new SetOfPuddlesForOneCursor(maxNumPuddlesPerSet, distanceBeforeNewPuddleGlobal, getNewColor());
  }
}

void draw1(TuioCursor[] tuioCursorList)
{
  background(0);
  
  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // Enter behaviour/interaction here.
    //
    // touchX[k] and touchY[k] are the x, y coordinates of each TUIO ID
    //  including previous TUIO IDs that have since disappeared and have not been overwritten by newer IDs.
    // If these are undesired, use an if statement to check the current index accesses a currently valid TUIO ID:
    //  if (k < tuioCursorList.length)
    //
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    //
    // Things to note:
    // touchX[k], touchY[k], previousX[k], previousY[k] are all floats
    // touchX[k] and touchY[k] initialize to 0, even if the TUIO ID hasn't existed yet
    ///////////////////////////////////

    puddleSets[k].update(touchX[k], touchY[k]); 
  }

  frameCounter++;
}

class Puddle {
  // Instance variables (local variables)
  float xPosition, yPosition;
  int numberOfRipples;
  int[] rippleDiameters;
  int[] rippleIncrements;
  int alphaValue;
  int fadeOutSpeed;
  int rippleStrokeFraction;
  color puddleColor;

  // Constructor - define how instances of this class get created
  Puddle(float x, float y, color c) {
    xPosition = x;
    yPosition = y;
    numberOfRipples = numRipplesGlobal;
    rippleDiameters = new int[numberOfRipples];
    rippleIncrements = new int[numberOfRipples];
    for (int i = 0; i < numberOfRipples; i++) {
      rippleDiameters[i] = 1;
      rippleIncrements[i] = rippleIncrementsGlobal[i];
    }
    alphaValue = 255;
    fadeOutSpeed = fadeOutSpeedGlobal;
    rippleStrokeFraction = rippleStrokeAsFractionOfDiameter;
    puddleColor = c;
  }

  // Functions

  void update() {
    for (int i = 0; i < numberOfRipples; i++) {
      rippleDiameters[i] += rippleIncrements[i];
    }
    alphaValue -= fadeOutSpeed;
  }

  void display() {
    stroke(puddleColor, alphaValue);
    noFill();
    
    for (int i = 0; i < numberOfRipples; i++) {
      if (rippleStrokeFraction != 0) {
        strokeWeight(rippleDiameters[i]/rippleStrokeFraction);
      }
      ellipse(xPosition, yPosition, rippleDiameters[i], rippleDiameters[i]);
    }
    
    strokeWeight(1);  // resetting strokeWeight for use elsewhere
  }

  float getX() {
    return xPosition;
  }

  float getY() {
    return yPosition;
  }

  boolean disappeared() {
    if (alphaValue <= 0) {
      return true;
    } else {
      return false;
    }
  }
}

class SetOfPuddlesForOneCursor {
  // Instance variables (local variables)
  int numberOfPuddles;
  Puddle[] puddles;
  float xDistanceToLastPuddle;
  float yDistanceToLastPuddle;
  int distanceBeforeNewPuddle;
  color c;
  float previousX;
  float previousY;

  // Constructor - define how instances of this class get created
  SetOfPuddlesForOneCursor(int numPuddles, int distance, color c_in) {
    numberOfPuddles = numPuddles;
    puddles = new Puddle[numberOfPuddles];
    distanceBeforeNewPuddle = distance;
    c = c_in;
  }

  // Functions

  // The "puddles" array contains instances of the Puddle class
  // When an individual Puddle's alpha value has decreased to 0 (or below) it is no longer drawn, to reduce the processing load
  // These Puddles are set to "null" in the puddles array, and are skipped in the display loop
  // Anytime we reference an element of the puddles array, we have to ensure it's not null

  void update(float xPos, float yPos) {
    if (puddles[numberOfPuddles-1] != null) {
      xDistanceToLastPuddle = abs(xPos - puddles[numberOfPuddles-1].getX());
      yDistanceToLastPuddle = abs(yPos - puddles[numberOfPuddles-1].getY());
    } else {
      if ((xPos != previousX) || (yPos != previousY)) {
        xDistanceToLastPuddle = distanceBeforeNewPuddle;
        yDistanceToLastPuddle = distanceBeforeNewPuddle;
      }
    }

    if ((xDistanceToLastPuddle >= distanceBeforeNewPuddle) || (yDistanceToLastPuddle >= distanceBeforeNewPuddle)) {
      // Reads through the entire array
      // and shifts the values to the left
      for(int i=1; i<numberOfPuddles; i++) {
        puddles[i-1] = puddles[i];
      } 
      // Add the new values to the end of the array
      puddles[numberOfPuddles-1] = new Puddle(xPos, yPos, c);
    }

    for(int i=0; i<numberOfPuddles; i++) {
      if (puddles[i] != null) {
        if (frameCounter % framesBeforeRippleGrowth == 0) {
          puddles[i].update();
        }
        if (puddles[i].disappeared()) {
          puddles[i] = null;
        } else {
          puddles[i].display();
        }
      }
    }

    previousX = xPos;
    previousY = yPos;
  }
}
