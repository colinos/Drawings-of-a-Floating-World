void setup0()
{
  int springsPerSet = 25; 
  for (int i = 0; i < calligraphy_lineSets.length; i++) {
    calligraphy_lineSets[i] = new SetOfLines(springsPerSet, getNewColor());
  }
  
  for (int i = 0; i<maxNumIdsToRecognize; i++) {
    touchX[i] = -100;
    touchY[i] = -100;
  }
}

void draw0(TuioCursor[] tuioCursorList) 
{
  //background(51,0,0); 
  //fill(51,0,0,4);
  fill(0,0,0,2);
  rect(-2, -2, width+2, height+2);

  for (int i = 0; i < maxNumIdsToRecognize; i++) {

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

    //stroke(255);
    //ellipse(touchX[i], touchY[i], 10, 10);

    calligraphy_lineSets[i].update((int)touchX[i], (int)touchY[i]); 
    calligraphy_lineSets[i].display(); 
  }
}


class SetOfLines {
  // Instance variables (local variables)
  Calligraphy_Spring[] springs;
  float medianMass = 24.0;  // mass of median Spring
  float massIncrement = 0.2;  // mass increments for other Springs above and below median
  color c;

  // Constructor - define how instances of this class get created
  SetOfLines(int x, color c_in) {
    springs = new Calligraphy_Spring[x];
    c = c_in;
    for (int i = 0; i < x; i++) {
      // this equation just distributes the masses of the Springs according to massIncrement
      float mass = medianMass - (massIncrement * x/2) + (massIncrement * i);

      /*
       * Calligraphy_Spring(x, y, size, damping, mass, spring_constant, trail_length, r, g, b)
       *
       * x is starting x-coordinate
       * y is starting y-coordinate
       * size is diameter of ellipse
       * damping affects by how much the velocity reduces for each oscillation (should be less than 1)
       * higher mass means slower acceleration/deceleration
       * spring_constant affects damping force, which affects acceleration/deceleration (damping force is also influenced by current velocity)
       * (should spring_constant be the same for all objects?)
       * r, g, b values for displaying
       */
      springs[i] = new Calligraphy_Spring(0, 0, 30, 0.98, mass, 0.1, 60, c);
    }
  }

  // Functions

  void update(int xPos, int yPos) {
    for (int i=0; i<springs.length; i++) { 
      springs[i].update(xPos, yPos); 
    }  
  }

  void display() {
    for (int i=0; i<springs.length; i++) { 
      springs[i].display(); 
    }  
  }
}

class Calligraphy_Spring 
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
  
  // Colour of lines
  color c;

  // Constructor
  // Calligraphy_Spring(x, y, size, damping, mass, spring_constant, trail_length)
  Calligraphy_Spring(float x, float y, int s, float d, float m, float k_in, int t, color c_in) 
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

  void update(int xPos, int yPos) 
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

    stroke(c); 
    line(mx[trail-2], my[trail-2], mx[trail-1], my[trail-1]);
  } 
} 
