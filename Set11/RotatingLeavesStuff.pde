void setup2()
{
  // sprite mask thing stolen from dan shiffman 
  PImage leaves_msk = loadImage("leaf.gif");
  leaves_img = new PImage( leaves_msk.width, leaves_msk.height );
  for ( int i = 0; i < leaves_img.pixels.length; i++ ) 
    leaves_img.pixels[i] = color(255);
  leaves_img.mask(leaves_msk);
  imageMode(CORNER);
  tint( 255, 100, 0, 100 );

  leaves_physics = new ParticleSystem( 0.01, 0.1 );  // new ParticleSystem( float gravityY, float drag )

  /*
   * Particle makeParticle()
   * Particle makeParticle( float mass, float x, float y, float z )
   * create a new particle in the system with some mass and at some x, y, z position.
   * The default a new particle with mass 1.0 at (0, 0, 0).
   */
  for (int i=0; i<maxNumIdsToRecognize; i++){
    leaves_mouse[i] = leaves_physics.makeParticle();
    leaves_mouse[i].moveTo( -100000, -100000, 0 );
    leaves_mouse[i].makeFixed();
  }
  /*
   * void makeFixed() 
   * boolean isFixed() 
   * void makeFree() 
   * boolean isFree()
   * Particles can either be fixed or free.
   * If they are free they move around and are affected by forces,
   * if they are fixed they stay where they are.
   */

  leaves_others = new Particle[leaves_numParticles];
  leaves_anchors = new Particle[leaves_numParticles];
  leaves_springs = new Spring[leaves_numParticles];

  leaves_angles = new float[leaves_numParticles];
  leaves_angleIncrements = new float[leaves_numParticles];
  leaves_rotationAsFractionOfMaxSpeed = new float[leaves_numParticles];

  for ( int i = 0; i < leaves_others.length; i++ )
  {
    // Particle makeParticle( float mass, float x, float y, float z )
    leaves_others[i] = leaves_physics.makeParticle( 1.0, random( 0, width ), random( 0, height ), 0 );
    leaves_angles[i] = 0;
    leaves_angleIncrements[i] = random(-6, 6);
    if(leaves_angleIncrements[i] == 0){
      leaves_angleIncrements[i] = 1;
    }
    leaves_rotationAsFractionOfMaxSpeed[i] = 0.0;

    /*
     * Attraction makeAttraction( Particle a, Particle b, float strength, float minimumDistance )
     * make an attraction (or repulsion) force between two particles.
     * If the strength is negative they repel each other, if the strength is positive they attract.
     * There is also a minimum distance that limits how strong this force can get close up. See attraction for details.
     */
    for (int j=0; j<maxNumIdsToRecognize; j++){
      leaves_physics.makeAttraction( leaves_mouse[j], leaves_others[i], leaves_attractionStrength, leaves_attractionMinDistance ); 
    }
    leaves_anchors[i] = leaves_physics.makeParticle( leaves_others[i].mass(), leaves_others[i].position().x(), leaves_others[i].position().y(), leaves_others[i].position().z() );
    leaves_anchors[i].makeFixed();
    // Spring makeSpring( Particle a, Particle b, float strength, float damping, float restLength )
    leaves_springs[i] = leaves_physics.makeSpring( leaves_others[i], leaves_anchors[i], leaves_springStrength, leaves_damping, 0 );
  }
}

void draw2(TuioCursor[] tuioCursorList)
{
  background( 0, 0, 0 );
  //fill(0, 6);
  //rect(0, 0, width, height);
  
  leaves_physics.tick();

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

    leaves_mouse[k].moveTo( touchX[k], touchY[k], 0 );   

    if (k >= tuioCursorList.length) {
      leaves_mouse[k].moveTo( -100000, -100000, 0 );
      touchX[k] = -100000;
      touchY[k] = -100000;
    }
  }

  // DRAW THE RADIAL BACKGROUND ============== COMMENT OUT FOR BLACK BACKGROUND ====
  drawGradientDisc( ((width)/2)+200 , ((height)/2)-200, width, height, color(255,255,255), color(0,0,255,2) ); 

  // DRAW THE LEAVES ===============================
  for ( int i = 0; i < leaves_others.length; i++ )
  {
    float posX = leaves_others[i].position().x();
    float posY = leaves_others[i].position().y();

    float distanceToClosestTuioId = checkDistanceToTuioIds(posX, posY, tuioCursorList);

    if ((distanceToClosestTuioId < 3*leaves_img.width) || (leaves_rotationAsFractionOfMaxSpeed[i] > 0)) {
      if (distanceToClosestTuioId >= 3*leaves_img.width) {
        leaves_rotationAsFractionOfMaxSpeed[i] -= leaves_rotationAsFractionOfMaxSpeed[i] / 1200;
      } 
      else {
        leaves_rotationAsFractionOfMaxSpeed[i] = 1.0;
      }

      leaves_angles[i] += leaves_rotationAsFractionOfMaxSpeed[i] * 150 * leaves_angleIncrements[i]/distanceToClosestTuioId;  // -6/150 < angleIncrement/distance < +6/150
      if (leaves_angles[i] >= 360) {
        leaves_angles[i] %= 360;
      }
    }

    pushMatrix();
    translate(posX, posY);
    rotate(radians(leaves_angles[i]));
    image(leaves_img, -leaves_img.width/2, -leaves_img.height/2);
    popMatrix();
  }
}

float checkDistanceToTuioIds(float leafXPos, float leafYPos, TuioCursor[] tuioCursorList) {
  float closestSoFar = getDistance(0, height, width, 0);  // this just calculates diagonal of the screen
  // this is the farthest away a TUIO ID can be
  for (int i = 0; i < tuioCursorList.length; i++) {
    TuioCursor tcur = tuioCursorList[i];
    float tcurX = tcur.getScreenX(width);
    float tcurY = tcur.getScreenY(height);

    float distanceToCurrentId = getDistance(leafXPos, leafYPos, tcurX, tcurY);
    if (distanceToCurrentId < closestSoFar) {
      closestSoFar = distanceToCurrentId;
    }
  }
  return closestSoFar;
}
