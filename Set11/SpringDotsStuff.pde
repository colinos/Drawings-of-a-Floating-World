void setup3()
{
  // sprite mask thing stolen from dan shiffman 
  PImage springDots_msk = loadImage("texture.gif");
  springDots_img = new PImage( springDots_msk.width, springDots_msk.height );
  for ( int i = 0; i < springDots_img.pixels.length; i++ ) 
    springDots_img.pixels[i] = color(255);
  springDots_img.mask(springDots_msk);
  imageMode(CORNER);
  tint( 100, 100, 255, 50 );
  //tint( 255, 120, 0, 50 );
  
  springDots_physics = new ParticleSystem( 0, 0.1 );  // new ParticleSystem( float gravityY, float drag )

  /*
   * Particle makeParticle()
   * Particle makeParticle( float mass, float x, float y, float z )
   * create a new particle in the system with some mass and at some x, y, z position.
   * The default a new particle with mass 1.0 at (0, 0, 0).
   */
  for (int i=0; i<maxNumIdsToRecognize; i++){
    springDots_mouse[i] = springDots_physics.makeParticle();
    springDots_mouse[i].moveTo( -100000, -100000, 0 );
    springDots_mouse[i].makeFixed();
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

  springDots_others = new Particle[springDots_numParticles][springDots_numParticles];
  springDots_anchors = new Particle[springDots_numParticles][springDots_numParticles];
  springDots_springs = new Spring[springDots_numParticles][springDots_numParticles];
  
  //float particlePlaceX = ; // gives an evenly spaced number of particles across the screen
  //float particlePlaceY = ; // gives an evenly spaced number of particles across the screen

  for ( int i = 0; i < springDots_others.length; i++ )
  {
    for (int j = 0; j < springDots_others.length; j++  )
    {
      // Particle makeParticle( float mass, float x, float y, float z )
      springDots_others[i][j] = springDots_physics.makeParticle( 1.0, j*(width/springDots_numParticles)+(width/springDots_numParticles)/2, i*(height/springDots_numParticles)+(height/springDots_numParticles)/2, 0 );
      /*
       * Attraction makeAttraction( Particle a, Particle b, float strength, float minimumDistance )
       * make an attraction (or repulsion) force between two particles.
       * If the strength is negative they repel each other, if the strength is positive they attract.
       * There is also a minimum distance that limits how strong this force can get close up. See attraction for details.
       */
      for (int k=0; k<maxNumIdsToRecognize; k++){
        springDots_physics.makeAttraction( springDots_mouse[k], springDots_others[i][j], springDots_attractionStrength, springDots_attractionMinDistance ); 
      }
      springDots_anchors[i][j] = springDots_physics.makeParticle( springDots_others[i][j].mass(), springDots_others[i][j].position().x(), springDots_others[i][j].position().y(), springDots_others[i][j].position().z() );
      springDots_anchors[i][j].makeFixed();
      // Spring makeSpring( Particle a, Particle b, float strength, float damping, float restLength )
      springDots_springs[i][j] = springDots_physics.makeSpring( springDots_others[i][j], springDots_anchors[i][j], springDots_springStrength, springDots_damping, 0 );
    }
  }
}

void draw3(TuioCursor[] tuioCursorList)
{
  //background( 0, 0, 0 );
  fill(0, 6);
  rect(0, 0, width, height);
  
  springDots_physics.tick();

  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // enter behaviour/interaction here
    // use touchX[k] and touchY[k] for the x, y coordinates to use for each TUIO ID
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    // remember, all these variables are floats
    ///////////////////////////////////
    springDots_mouse[k].moveTo( touchX[k], touchY[k], 0 ); 

    if (touchX[k] == previousX[k] && touchY[k] == previousY[k]) {
      springDots_mouse[k].moveTo( -100000, -100000, 0 );
      touchX[k] = -100000;
      touchY[k] = -100000;
    }  
  }

  // DRAW THE RADIAL BACKGROUND ============== COMMENT OUT FOR BLACK BACKGROUND ====
  //drawGradientDisc( ((width)/2)+200 , ((height)/2)-200, width, height, color(255,255,255), color(0,0,255,2) ); 

  // DRAW THE LEAVES ===============================
  for ( int i = 0; i < springDots_others.length; i++ )
  {
    for (int j = 0; j < springDots_others.length; j++  )
    {
      image(springDots_img, springDots_others[i][j].position().x() - springDots_img.width/2, springDots_others[i][j].position().y() - springDots_img.height/2);
    }
  }
}
