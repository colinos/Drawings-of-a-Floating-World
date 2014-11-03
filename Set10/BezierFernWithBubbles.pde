//////////////////////////////////
// Setup
//////////////////////////////////

void setup0()
{
  // empty
  for (int i = 0; i < maxNumIdsToRecognize; i++) {
    touchX[i] = width/2;
    touchY[i] = height/2;
  }
}


//////////////////////////////////
// draw
//////////////////////////////////

void draw0(TuioCursor[] tuioCursorList)
{
  fill(0,50);
  rect(-2,-2,width+2,height+2);

  ///////////// FERN //////////////////
  // draw branches
  strokeWeight(1); 
  stroke(jade,50); //colour
  float a = (touchX[0] / (float) width) * 22f;
  bezierFern_theta = radians(a);
  // move around with mouse
  // translate(mouseX,mouseY);

  pushMatrix();
  translate(width/10 * 3, width/10 * 3);
  scale(1.25);
  stroke(bamboo, 200);
  line(0,0,0,-20);
  branch(150);
  popMatrix();

  pushMatrix();
  translate(width/10 * 4, width/10 * 7.5);
  scale(1.5);
  stroke(jade, 220);
  line(0,0,0,-20);
  branch(150);
  popMatrix();

  pushMatrix();
  translate(width/10 * 5, height/10 * 2);
  stroke(jade, 200);
  line(0,0,0,-20);
  branch(150);
  popMatrix();

  pushMatrix();
  translate(width/10 * 9, height/10 * 4);
  scale(1.35);
  stroke(jade, 200);
  line(0,0,0,-20);
  branch(150);
  popMatrix();

  pushMatrix();
  translate(width/10 * 6, height/10 * 6);
  scale(1.5);
  stroke(grass, 100);
  line(0,0,0,-20);
  branch2(150);
  popMatrix();

  pushMatrix();
  translate(width/10 * 8, height/10 * 7);
  scale(2);
  stroke(teal, 150);
  line(0,0,0,-20);
  branch(150);
  popMatrix();

  pushMatrix();
  translate(width/10 * 1.5, height/10 * 9);
  scale(2);
  stroke(tourq, 150);
  line(0,0,0,-20);
  branch2(150);
  popMatrix();

  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // Enter behaviour/interaction here.
    //
    // touchX[k] and touchY[k] are the x, y coordinates of each TUIO ID
    //  including previous TUIO IDs that have since disappeared and have not been overwritten by newer IDs
    //  If these are undesired, use an if statement to check the current index accesses a currently valid TUIO ID:
    //   if (k < tuioCursorList.length)
    //
    // The 'for' loop in which this comment is located cycles through all TUIO IDs
    // If only specific IDs (e.g. first or second IDs) are required, there is no need for the 'for' loop
    // Remove 'for' loop and just use touchX[0] and touchY[0], etc
    //
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    //
    // Things to note:
    // touchX[k], touchY[k], previousX[k], previousY[k] are all floats
    // touchX[k] and touchY[k] initialize to 0, even if the TUIO ID hasn't existed yet
    ///////////////////////////////////

    ///////// DROPS ///////

    if (bezierFern_drops[bezierFern_maxDrops-1][k] != null) {
      //bezierFern_distanceToLastDrop = getDistance(touchX[k], touchY[k], bezierFern_drops[bezierFern_maxDrops-1][k].getX(), bezierFern_drops[bezierFern_maxDrops-1][k].getY());
      bezierFern_distanceToLastDrop = getDistance(touchX[k], touchY[k], bezierFern_lastDropCreatedX[k], bezierFern_lastDropCreatedY[k]);
    } 
    else {  // we're in first frame
      bezierFern_distanceToLastDrop = bezierFern_criticalDistance + 1;
    }

    if (bezierFern_distanceToLastDrop > bezierFern_criticalDistance) {
      for (int i = 1; i < bezierFern_maxDrops; i++) {
        bezierFern_drops[i-1][k] = bezierFern_drops[i][k];
      }

      // create a new drop
      bezierFern_lastDropCreatedX[k] = touchX[k];
      bezierFern_lastDropCreatedY[k] = touchY[k];
      bezierFern_drops[bezierFern_maxDrops-1][k] = new Drop(touchX[k], touchY[k]);
    }
  }

  // Move and display drops
  for (int k = 0; k < maxNumIdsToRecognize; k++) {
    for (int i = 0; i < bezierFern_maxDrops; i++ ) { 
      if (bezierFern_drops[i][k] != null) {
        if (bezierFern_drops[i][k].reachedBottom()) {
          bezierFern_drops[i][k] = null;
        } else {
          bezierFern_drops[i][k].move();
          bezierFern_drops[i][k].display();
        }
      }
    }
  }
}


//////////////////////////////////
// Global functions
//////////////////////////////////

void branch(float h) {
  // Each branch will be 2/3rds the size of the previous one
  h *= 0.5f;

  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (h > 6) {
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    rotate(bezierFern_theta*2);   // Rotate by bezierFern_theta
    line(0,0,0,-h);  // Draw the branch
    translate(0,-h); // Move to the end of the branch
    pushMatrix();
    rotate(-bezierFern_theta);
    line(0,0,0,-h);
    translate(0,-h);
    pushMatrix();
    rotate(-bezierFern_theta);
    line(0,0,0,-h);
    branch(h);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    popMatrix();
    branch(h);
    popMatrix();
    branch(h);

    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(-bezierFern_theta);
    line(0,0,0,-h);
    translate(0,-h);
    branch(h);
    popMatrix();
  }
}

void branch2(float g) {
  // Each branch will be 2/3rds the size of the previous one
  g *= 0.5f;

  // All recursive functions must have an exit condition!!!!
  // Here, ours is when the length of the branch is 2 pixels or less
  if (g > 6) {
    pushMatrix();    // Save the current state of transformation (i.e. where are we now)
    rotate(-bezierFern_theta*2);   // Rotate by bezierFern_theta
    line(0,0,0,-g);  // Draw the branch
    translate(0,-g); // Move to the end of the branch
    pushMatrix();
    rotate(bezierFern_theta);
    line(0,0,0,-g);
    translate(0,-g);
    pushMatrix();
    rotate(bezierFern_theta);
    line(0,0,0,-g);
    branch(g);       // Ok, now call myself to draw two new branches!!
    popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
    popMatrix();
    branch(g);
    popMatrix();
    branch(g);

    // Repeat the same thing, only branch off to the "left" this time!
    pushMatrix();
    rotate(bezierFern_theta);
    line(0,0,0,-g);
    translate(0,-g);
    branch(g);
    popMatrix();
  }
}


/////////////////////////////////////////////////////////////////////////////////
class Drop {

  float x,y;   // Variables for location of raindrop
  float speed; // Speed of raindrop
  color c;
  float r;     // Radius of raindrop

  Drop(float x_in, float y_in) {
    r = 16;                 // All raindrops are the same size
    //if((touchX[k]!=previousX[k])||(touchY[k]!=previousY[k])){
    x = x_in;    
    y = y_in;              
    //speed = random(5,60);   // Pick a random speed
    speed = random(0.5,2);
    //c = color(50,100,150); // Color
    //}
  }

  // Move the raindrop down
  void move() {
    // Increment by speed
    y -= speed; 
  }

  // Check if it hits the bottom
  boolean reachedBottom() {
    // If we go a little beyond the bottom
    if (y > height + r*4) { 
      return true;
    } 
    else {
      return false;
    }
  }

  // Display the raindrop
  void display() {
    // Display the drop

    noStroke();
    //for (int i = 2; i < r; i++ ) {
    fill(255);
    ellipse(x-random(1,3),y-random(1,3),8,8);
    fill(sky,100);
    ellipse(x,y,random(15,20),random(15,20));
    //  }
  }

  float getX() {
    return x;
  }

  float getY() {
    return y;
  }
}
