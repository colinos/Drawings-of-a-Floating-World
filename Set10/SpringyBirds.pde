void setup3()
{
  for (int i = 0; i <maxNumIdsToRecognize; i++) {
    touchX[i] = -100;
    touchY[i] = -100;
  }

  noStroke();
  fill(0);

  a = new Bird(10,10,0.25); // Constructs object 
  b = new Bird(150,150,0.5); // Constructs object
  c = new Bird(250,250,0.75); // Constructs object

  for (int j=0; j < springyBirds_numFlocks; j++) { // cycle through all the flocks
    for (int i=0; i < springyBirds_numSprings; i++){  // cycles through the springs in one flock
      springyBirds_s[i][j] = new Spring2D (i, i, springyBirds_mass,springyBirds_gravity);
    }
  }
}

void draw3(TuioCursor[] tuioCursorList)
{
  fill(0,50);
  rect(-1,-1,width+1,height+1);

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

  //fill(255);
  //frameRate(12);

  /*  
  int[] randomPosX = { -2000, width+2000,       -2000,  width+2000 };
  int[] randomPosY = { -2000,      -2000, height+2000, height+2000 };

  for (int i = 0; i <maxNumIdsToRecognize; i++) {
    if (i >= tuioCursorList.length && (touchX[i] > 0 && touchX[i] < width)) {
      int randomIndex = (int)random(0, randomPosX.length);
      touchX[i] = randomPosX[randomIndex];
      touchY[i] = randomPosY[randomIndex];
    }
  }
  */

  //for (int j = 0; j < springyBirds_numFlocks; j++) { // cycling through flocks for update/display

    springyBirds_s[0][0].update(touchX[0], touchY[0]);
    springyBirds_s[0][0].display(touchX[0], touchY[0]);
    for (int i = 1; i < springyBirds_numSprings; i++){
      //springyBirds_s[i][j].update(springyBirds_s[i-1][j].x, springyBirds_s[i-1][j].y);
      springyBirds_s[i][0].update(springyBirds_s[i-1][0].x-100, springyBirds_s[i-1][0].y-30);  // it's i-1 because you're moving to previous spring
      springyBirds_s[i][0].display(springyBirds_s[i-1][0].x, springyBirds_s[i-1][0].y);  // but the flock (j) is the same
    }

  //}
}


class Bird{
  float x,y;
  float resize = 0.1;
  float tilt1 = 1;
  float tilt2 = 1;
  float angle;                     // Used to define tilt

  Bird(float xpos, float ypos, float s){
    x = xpos;
    y = ypos;
    resize = s;
  }

  void display(float x, float y){
    wing1(x,y,resize);
    wing2(x,y,resize);
  }

  void flap(){
    tilt1 = cos(angle)/8;
    tilt2 = -tilt1;
    angle +=0.05;
  }

  void wing1(float x, float y, float s){
    pushMatrix();
    translate(x,y);
    scale(s);
    rotate(tilt1);
    beginShape();
    vertex( 0, 0 );
    bezierVertex (21.0, -98.0, 198.0, -22.0, 167.0, -124.0);
    bezierVertex (131.0, -45.0, 8.0, -133.0, 0.0, 0.0);
    endShape();
    popMatrix();

  }

  void wing2(float x, float y, float s){
    pushMatrix();
    translate(x,y);
    scale(s);
    rotate(tilt2);
    beginShape();
    vertex( 0, 0 );
    bezierVertex (-55.0, -98.0, -188.0, -17.0, -169.0, -123.0);
    bezierVertex (-139.0, -60.0, -25.0, -130.0, 0.0, 0.0);
    endShape();
    popMatrix();
  }
}

class Spring2D{
  float vx, vy;
  float x, y;
  float gravity;
  float mass;
  float stiffness = 0.5;
  float damping = 0.5;

  color color1;
  color color2;
  color color3;


  Spring2D(float xpos, float ypos, float m, float g){
    x = xpos;
    y = ypos;
    mass = m;
    gravity = g;
    color1 = springyBirds_getNewColor();
    color2 = springyBirds_getNewColor();
    color3 = springyBirds_getNewColor();
  }

  void update(float targetX, float targetY){
    float forceX = (targetX - x) * stiffness;
    float ax = forceX / mass;
    vx = damping * (vx + ax);
    x += vx;
    float forceY = (targetY -y) * stiffness;
    forceY += gravity;
    float ay = forceY / mass;
    vy = damping * (vy + ay);
    y += vy;
  }

  void display( float nx, float ny){
    noStroke();
    a.flap();
    //fill(jade,200);
    fill(color1,200);
    a.display(x+50,y+80);
    b.flap();
    //fill(sky,200);
    fill(color2,200);
    b.display(x,y);
    c.flap();
    //fill(tourq,200);
    fill(color3,200);
    c.display(x-50,y-150);
  }
}

color springyBirds_getNewColor() {
  int newColorIndex = (int)random(0, springyBirds_colorArray.length);
  return springyBirds_colorArray[newColorIndex];
}
