void setup2()
{
  noFill();
  
  for (int j = 0; j < maxNumIdsToRecognize; j++) {
    color c = getNewColor();
    //for (int i = 0; i < springs_numSlinkiesPerId; i++) {
      /*
       * Springs_Spring(x, y, size, damping, mass, spring_constant, trail_length)
       *
       * x is starting x-coordinate
       * y is starting y-coordinate
       * size is diameter of ellipse
       * damping affects by how much the velocity reduces for each oscillation (should be less than 1)
       * higher mass means slower acceleration/deceleration
       * spring_constant affects damping force, which affects acceleration/deceleration (damping force is also influenced by current velocity)
       * (should spring_constant be the same for all objects?)
       */
      springs_springs[0][j] = new Springs_Spring(0, 0, 30, 0.98, 24.0, 0.1, 60, c); 
      springs_springs[1][j] = new Springs_Spring(0, 0, 30, 0.98, 20.0, 0.1, 60, c); 
      //springs_springs[i][j] = new Springs_Spring(0, 0, 30, 0.98, random(20.0, 24.0), 0.1, 60, c); 
    //}
    touchX[j] = -500;
    touchY[j] = -500;
  }
}

void draw2(TuioCursor[] tuioCursorList)
{
  //background(51); 
  background(0); 
  
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
    
    /*
    if (k >= tuioCursorList.length) {
      touchX[k] = -100;
      touchY[k] = -100;
    }
    */
    
    for (int i = 0; i < springs_numSlinkiesPerId; i++) {
      springs_springs[i][k].update(touchX[k], touchY[k]); 
      springs_springs[i][k].display(); 
    }
  
  }
}


class Springs_Spring 
{ 
  // Screen values 
  float tempxpos, tempypos; 
  int size = 20; 

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

  int trail = 60;
  float mx[] = new float[trail];
  float my[] = new float[trail];
  color c;

  // Constructor
  // Springs_Spring(x, y, size, damping, mass, spring_constant, trail_length)
  Springs_Spring(float x, float y, int s, float d, float m, float k_in, int t, color c_in) 
  { 
    tempxpos = x;
    tempypos = y;
    rest_posx = x;
    rest_posy = y;
    size = s;
    damp = d; 
    mass = m; 
    k = k_in;
    trail = t;
    c = c_in;
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
    // Reads throught the entire array
    // and shifts the values to the left
    for(int i=1; i<trail; i++) {
      mx[i-1] = mx[i];
      my[i-1] = my[i];
    } 
    // Add the new values to the end of the array
    mx[trail-1] = tempxpos;
    my[trail-1] = tempypos;

    for(int i=0; i<trail; i++) {
      //fill(255, 255 * i / (trail-1)); 
      stroke(c, 255 * i / (trail-1)); 
      ellipse(mx[i], my[i], size * (i+1) / trail, size * (i+1) / trail);
    }
  } 
} 
