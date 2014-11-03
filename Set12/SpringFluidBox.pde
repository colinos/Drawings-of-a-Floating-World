void setup2()
{
  // sprite mask thing stolen from dan shiffman 
  PImage springFluidBox_msk = loadImage("texture.gif");
  springFluidBox_img = new PImage( springFluidBox_msk.width, springFluidBox_msk.height );
  for ( int i = 0; i < springFluidBox_img.pixels.length; i++ ) 
    springFluidBox_img.pixels[i] = color(255);
  springFluidBox_img.mask(springFluidBox_msk);
  imageMode(CORNER);
  tint( 100, 100, 255, 50 );
  //tint( 255, 120, 0, 50 );

  springFluidBox_physics = new ParticleSystem( 0, 0.1 );  // new ParticleSystem( float gravityY, float drag )

  /*
   * Particle makeParticle()
   * Particle makeParticle( float mass, float x, float y, float z )
   * create a new particle in the system with some mass and at some x, y, z position.
   * The default a new particle with mass 1.0 at (0, 0, 0).
   */
  for (int i=0; i<maxNumIdsToRecognize; i++){
    springFluidBox_mouse[i] = springFluidBox_physics.makeParticle();
    springFluidBox_mouse[i].moveTo( -100000, -100000, 0 );
    springFluidBox_mouse[i].makeFixed();
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

  springFluidBox_others = new Particle[springFluidBox_numParticles][springFluidBox_numParticles];
  springFluidBox_anchors = new Particle[springFluidBox_numParticles][springFluidBox_numParticles];
  springFluidBox_springs = new Spring[springFluidBox_numParticles][springFluidBox_numParticles];
  
  //float particlePlaceX = ; // gives an evenly spaced number of particles across the screen
  //float particlePlaceY = ; // gives an evenly spaced number of particles across the screen

  for ( int i = 0; i < springFluidBox_others.length; i++ )
  {
    for (int j = 0; j < springFluidBox_others.length; j++  )
    {
      // Particle makeParticle( float mass, float x, float y, float z )
      //springFluidBox_others[i][j] = springFluidBox_physics.makeParticle( 1.0, ((width/4)+j*((width/2)/springFluidBox_numParticles)+((width/2)/springFluidBox_numParticles)/2), ((height/4)+i*((height/2)/springFluidBox_numParticles)+((height/2)/springFluidBox_numParticles)/2), 0 );
      springFluidBox_others[i][j] = springFluidBox_physics.makeParticle( 1.0, ((width/14)+j*(((width/14)*12)/springFluidBox_numParticles)+((width)/springFluidBox_numParticles)/2), ((height/4)+i*((height/2)/springFluidBox_numParticles)+((height/2)/springFluidBox_numParticles)/2), 0 );
      /*
       * Attraction makeAttraction( Particle a, Particle b, float strength, float minimumDistance )
       * make an attraction (or repulsion) force between two particles.
       * If the strength is negative they repel each other, if the strength is positive they attract.
       * There is also a minimum distance that limits how strong this force can get close up. See attraction for details.
       */
      for (int k=0; k<maxNumIdsToRecognize; k++){
        springFluidBox_physics.makeAttraction( springFluidBox_mouse[k], springFluidBox_others[i][j], springFluidBox_attractionStrength, springFluidBox_attractionMinDistance ); 
      }
      springFluidBox_anchors[i][j] = springFluidBox_physics.makeParticle( springFluidBox_others[i][j].mass(), springFluidBox_others[i][j].position().x(), springFluidBox_others[i][j].position().y(), springFluidBox_others[i][j].position().z() );
      springFluidBox_anchors[i][j].makeFixed();
      // Spring makeSpring( Particle a, Particle b, float strength, float damping, float restLength )
      springFluidBox_springs[i][j] = springFluidBox_physics.makeSpring( springFluidBox_others[i][j], springFluidBox_anchors[i][j], springFluidBox_springStrength, springFluidBox_damping, 0 );
    }
  }
}

void draw2(TuioCursor[] tuioCursorList)
{
  //background( 0, 0, 0 );
  fill(0, 6);
  rect(0, 0, width, height);
  
  springFluidBox_physics.tick();

  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // enter behaviour/interaction here
    // use touchX[k] and touchY[k] for the x, y coordinates to use for each TUIO ID
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    // remember, all these variables are floats
    ///////////////////////////////////
    springFluidBox_mouse[k].moveTo( touchX[k], touchY[k], 0 ); 

    if (touchX[k] == previousX[k] && touchY[k] == previousY[k]) {
      springFluidBox_mouse[k].moveTo( -100000, -100000, 0 );
      touchX[k] = -100000;
      touchY[k] = -100000;
    }  
  }

  // DRAW THE RADIAL BACKGROUND ============== COMMENT OUT FOR BLACK BACKGROUND ====
  //drawGradientDisc( ((width)/2)+200 , ((height)/2)-200, width, height, color(255,255,255), color(0,0,255,2) ); 

  // DRAW THE LEAVES ===============================
  for ( int i = 0; i < springFluidBox_others.length; i++ )
  {
    for (int j = 0; j < springFluidBox_others.length; j++  )
    {
      image(springFluidBox_img, springFluidBox_others[i][j].position().x() - springFluidBox_img.width/2, springFluidBox_others[i][j].position().y() - springFluidBox_img.height/2);
    }
  }
}
