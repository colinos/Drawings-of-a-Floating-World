void setup3()
{
  /*
   * Tadpoles_Spring(damping, mass, spring_constant)
   *
   * damping affects by how much the velocity reduces for each oscillation (should be less than 1)
   * higher mass means slower acceleration/deceleration
   * spring_constant affects damping force, which affects acceleration/deceleration (damping force is also influenced by current velocity)
   * (should spring_constant be the same for all objects?)
   */

  for (int i = 0; i < numTadpoles; i++) {
    //tadpoles[i] = new Tadpoles_Spring(random(0.94,0.98), random(75,150), random(0.1,0.2));  // worked well at home, seems too fast in college
    tadpoles[i] = new Tadpoles_Spring(random(0.9,0.985), random(100, 200), 0.2);
  }

  for (int i = 0; i < maxNumIdsToRecognize; i++) {
    tadpoles_bubbleSets[i] = new BubbleSet(color((int)random(52,256)), tadpoles_backgroundColor);
  }
}

void draw3(TuioCursor[] tuioCursorList)
{
  background(tadpoles_backgroundColor); 

  if (masterFrameCounter % 600 == 0) {
    tadpoles_randomID = (int)random(0,smallerOfTuioIdsAndMaxIds);  // random TUIO ID
  }

  if (tadpoles_randomID > 0 && tadpoles_randomID >= smallerOfTuioIdsAndMaxIds) {
    tadpoles_randomID = (int)random(0,smallerOfTuioIdsAndMaxIds);
  }
  for (int i=0; i<numTadpoles; i++) { 
    tadpoles[i].update(touchX[tadpoles_randomID], touchY[tadpoles_randomID]); 
    tadpoles[i].display(); 
  }

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

    if (k != tadpoles_randomID && k < smallerOfTuioIdsAndMaxIds) {
      tadpoles_bubbleSets[k].update(touchX[k], touchY[k]);
    }
    tadpoles_bubbleSets[k].display(tadpoles);

  }
}


class Tadpole
{
  float tadpoleWidth, tadpoleHeight;
  Tail t;

  Tadpole(float w, float h) {
    tadpoleWidth = w;
    tadpoleHeight = h;
    t = new Tail(tadpoleWidth, tadpoleHeight);
  }

  void display(float x, float y, int swimDirection) {
    t.display(x, y, swimDirection);
    noStroke();
    fill(255, 159);
    ellipse(x, y, tadpoleWidth, tadpoleHeight);
  }
}

class Tail
{
  float flapPosition = 0;  // 0 for tail to in "up" position, PI for tail in "down" position
                           // (tail gets rotated around X axis by this amount)
  int frameCounterForTailFlap = 0;
  int numFramesToFlapTail = 3;
  
  float toplineX1;
  float toplineY1;
  float toplineCX1;
  float toplineCY1;
  float toplineX2;
  float toplineY2;
  float toplineCX2;
  float toplineCY2;

  float bottomlineX1;
  float bottomlineY1;
  float bottomlineCX1;
  float bottomlineCY1;
  float bottomlineX2;
  float bottomlineY2;
  float bottomlineCX2;
  float bottomlineCY2;

  Tail(float tadpoleW, float tadpoleH) {
    toplineX1 = tadpoleW/4;  // slightly above tadpole center
    toplineY1 = -0.5 * tadpoleH/2;
    toplineCX1 = toplineX1 - toplineX1/10;  // above (and to the left?)
    toplineCY1 = toplineY1 + toplineY1/10;
    toplineX2 = tadpoleW/4 + tadpoleW;  // to the right of the tadpole center
    toplineY2 = 0;
    toplineCX2 = toplineX2;  // above (and to the right)
    toplineCY2 = toplineY2 - tadpoleH/4;

    bottomlineX1 = tadpoleW/4;  // slightly below tadpole center
    bottomlineY1 = 0.5 * tadpoleH/2;
    bottomlineCX1 = bottomlineX1 + bottomlineX1/2;
    bottomlineCY1 = bottomlineY1 - bottomlineY1/2;
    bottomlineX2 = toplineX2;
    bottomlineY2 = toplineY2;
    bottomlineCX2 = bottomlineX2 - bottomlineX2/5;
    bottomlineCY2 = bottomlineY2 - bottomlineY1/2;
  }

  void display(float x, float y, int swimDirection) {
    pushMatrix();
    translate(x, y);
    
    if (frameCounterForTailFlap % numFramesToFlapTail == 0) {
      flapPosition += PI;
      if (flapPosition >= TWO_PI) {
        flapPosition %= TWO_PI;
      }
    }
    rotateX(flapPosition);
    
    if (swimDirection == 1) {
      rotateY(PI);
    }

    noStroke();
    fill(255, 159);
    beginShape();
     vertex(toplineX1, toplineY1);
     bezierVertex(toplineCX1, toplineCY1, toplineCX2, toplineCY2, toplineX2, toplineY2);
     bezierVertex(bottomlineCX2, bottomlineCY2, bottomlineCX1, bottomlineCY1, bottomlineX1, bottomlineY1);
    endShape();
    popMatrix();
    
    frameCounterForTailFlap++;
  }
}

class Tadpoles_Spring 
{ 
  // Screen values 
  float tempxpos, tempypos; 

  // Spring simulation constants 
  float mass;       // Mass 
  float k = 0.2;    // Spring constant 
  float damp;       // Damping 
  float rest_posx;  // Rest position X  // x position ball will eventually come to rest at
  float rest_posy;  // Rest position Y  // y position ball will eventually come to rest at

  // Spring simulation variables 
  float velx = 0.0;   // X Velocity 
  float vely = 0.0;   // Y Velocity 
  float accel = 0;    // Acceleration 
  float force = 0;    // Force 

  Tadpole tp;
  float tadpoleWidth = 30;
  float tadpoleHeight = 20;

  // Constructor
  // Tadpoles_Spring(x, y, size, damping, mass, spring_constant, trail_length)
  //Tadpoles_Spring(float x, float y, int s, float d, float m, float k_in, int t) 
  Tadpoles_Spring(float d, float m, float k_in) 
  { 
    tempxpos = 0;
    tempypos = 0;
    rest_posx = 0;
    rest_posy = 0;
    damp = d; 
    mass = m; 
    k = k_in;
    
    tp = new Tadpole(tadpoleWidth, tadpoleHeight);
  } 

  void update(float xPos, float yPos) 
  { 
    rest_posy = yPos; 
    rest_posx = xPos;

    force = -k * (tempypos - rest_posy);  // f=-ky 
    accel = force / mass;                 // Set the acceleration, f=ma == a=f/m 
    vely = damp * (vely + accel);         // Set the velocity 
    tempypos = tempypos + vely;           // Updated position 

    force = -k * (tempxpos - rest_posx);  // f=-kx 
    accel = force / mass;                 // Set the acceleration, f=ma == a=f/m 
    velx = damp * (velx + accel);         // Set the velocity 
    tempxpos = tempxpos + velx;           // Updated position 
  } 
  
  void display() 
  { 
    if (tempxpos >= rest_posx) {
      tp.display(tempxpos, tempypos, 0);
    } else {
      tp.display(tempxpos, tempypos, 1);
    }
  } 
  
  float getCurrentXPos() {
    return tempxpos;
  }
  
  float getCurrentYPos() {
    return tempypos;
  }
  
  float getTadpoleWidth() {
    return tadpoleWidth;
  }
} 

class BubbleSet
{
  int numBubbles = 128;
  Bubble[] bubbles;
  float distanceToLastBubble;
  color strokeColor, fillColor;

  BubbleSet(color sc, color fc) {
    bubbles = new Bubble[numBubbles];
    strokeColor = sc;
    fillColor = fc;
  }

  void update(float x, float y) {
    if (bubbles[numBubbles-1] != null) {
      distanceToLastBubble = getDistance(x, y, bubbles[numBubbles-1].getX(), bubbles[numBubbles-1].getY());
    } else {
      distanceToLastBubble = tadpoles_criticalDistance;
    }

    if (distanceToLastBubble >= tadpoles_criticalDistance) {
      for (int i = 1; i < numBubbles; i++) {
        bubbles[i-1] = bubbles[i];
      }
      bubbles[numBubbles-1] = new Bubble(x, y, strokeColor, fillColor);
    }
  }

  void display(Tadpoles_Spring[] t) {
    for (int i = 0; i < numBubbles; i++) {
      if (bubbles[i] != null) {
        bubbles[i].display();
        bubbles[i].update(t); 
        if (!bubbles[i].isStillVisible()) {
          bubbles[i] = null;
        }
      }
    }
  }
}

class Bubble
{
  float xPos, yPos, diameter;
  color strokeColor;
  color fillColor;
  boolean stillVisible = true;

  Bubble(float x, float y, color sc, color fc) {
    xPos = x;
    yPos = y;
    diameter = 5;
    strokeColor = sc;
    fillColor = fc;
  }

  void update(Tadpoles_Spring[] t) {
    if (isTouchingTadpole(t)) {
      stillVisible = false;
    } else {
      xPos += random(-1,1);
      yPos -= 2;
      diameter += 0.05;
      if (yPos + diameter < 0) {
        stillVisible = false;
      }
    }
  }

  void display() {
    stroke(strokeColor);
    fill(fillColor);
    ellipse(xPos, yPos, diameter, diameter);
    ellipse(xPos+diameter/4, yPos-diameter/4, diameter/6, diameter/6);
  }
  
  float getX() {
    return xPos;
  }
  
  float getY() {
    return yPos;
  }
  
  float getDiam() {
    return diameter;
  }
  
  boolean isStillVisible() {
    return stillVisible;
  }
  
  boolean isTouchingTadpole(Tadpoles_Spring[] t) {
    for (int i = 0; i < t.length; i++) {
      if (getDistance(xPos, yPos, t[i].getCurrentXPos(), t[i].getCurrentYPos()) < (diameter + t[i].getTadpoleWidth())) {
        return true;
      }
    }
    return false;
  }
}
