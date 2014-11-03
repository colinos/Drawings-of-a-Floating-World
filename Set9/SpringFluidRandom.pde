void setup0()
{
  // sprite mask thing stolen from dan shiffman 
  PImage springFluidRandom_msk = loadImage("texture.gif");
  springFluidRandom_img = new PImage( springFluidRandom_msk.width, springFluidRandom_msk.height );
  for ( int i = 0; i < springFluidRandom_img.pixels.length; i++ ) 
    springFluidRandom_img.pixels[i] = color(255);
  springFluidRandom_img.mask(springFluidRandom_msk);
  imageMode(CORNER);
  tint( 100, 100, 255, 50 );
  //tint( 255, 120, 0, 50 );

  // NEILL SETUP ==============
  springFluidRandom_physics = new ParticleSystem( 0.01, 0.1 );  // new ParticleSystem( float gravityY, float drag )

  /*
   * Particle makeParticle()
   * Particle makeParticle( float mass, float x, float y, float z )
   * create a new particle in the system with some mass and at some x, y, z position.
   * The default a new particle with mass 1.0 at (0, 0, 0).
   */
  for (int i=0; i<maxNumIdsToRecognize; i++){
    springFluidRandom_mouse[i] = springFluidRandom_physics.makeParticle();
    springFluidRandom_mouse[i].moveTo( -100000, -100000, 0 );
    springFluidRandom_mouse[i].makeFixed();
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


  springFluidRandom_others = new Particle[springFluidRandom_numParticles];
  springFluidRandom_anchors = new Particle[springFluidRandom_numParticles];
  springFluidRandom_springs = new Spring[springFluidRandom_numParticles];
  for ( int i = 0; i < springFluidRandom_others.length; i++ )
  {
    // Particle makeParticle( float mass, float x, float y, float z )
    springFluidRandom_others[i] = springFluidRandom_physics.makeParticle( 1.0, random( 0, width ), random( height/3, (height/3) *2 ), 0 );
    /*
     * Attraction makeAttraction( Particle a, Particle b, float strength, float minimumDistance )
     * make an attraction (or repulsion) force between two particles.
     * If the strength is negative they repel each other, if the strength is positive they attract.
     * There is also a minimum distance that limits how strong this force can get close up. See attraction for details.
     */
    for (int j=0; j<maxNumIdsToRecognize; j++){
      springFluidRandom_physics.makeAttraction( springFluidRandom_mouse[j], springFluidRandom_others[i], springFluidRandom_attractionStrength, springFluidRandom_attractionMinDistance ); 
    }
    springFluidRandom_anchors[i] = springFluidRandom_physics.makeParticle( springFluidRandom_others[i].mass(), springFluidRandom_others[i].position().x(), springFluidRandom_others[i].position().y(), springFluidRandom_others[i].position().z() );
    springFluidRandom_anchors[i].makeFixed();
    // Spring makeSpring( Particle a, Particle b, float strength, float damping, float restLength )
    springFluidRandom_springs[i] = springFluidRandom_physics.makeSpring( springFluidRandom_others[i], springFluidRandom_anchors[i], springFluidRandom_springStrength, springFluidRandom_damping, 0 );
  }
  // END NEILL SETUP =====================================
}

void draw0(TuioCursor[] tuioCursorList)
{
  //background( 0, 0, 0 );
  fill(0, 6);
  rect(0, 0, width, height);
  
  springFluidRandom_physics.tick();

  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // enter behaviour/interaction here
    // use touchX[k] and touchY[k] for the x, y coordinates to use for each TUIO ID
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    // remember, all these variables are floats
    ///////////////////////////////////
    springFluidRandom_mouse[k].moveTo( touchX[k], touchY[k], 0 ); 

    if (touchX[k] == previousX[k] && touchY[k] == previousY[k]) {
      springFluidRandom_mouse[k].moveTo( -100000, -100000, 0 );
      touchX[k] = -100000;
      touchY[k] = -100000;
    }  
  }

  // DRAW THE RADIAL BACKGROUND ============== COMMENT OUT FOR BLACK BACKGROUND ====
  //drawGradientDisc( ((width)/2)+200 , ((height)/2)-200, width, height, color(255,255,255), color(0,0,255,2) ); 

  // DRAW THE LEAVES ===============================
  for ( int i = 0; i < springFluidRandom_others.length; i++ )
  {
    image(springFluidRandom_img, springFluidRandom_others[i].position().x() - springFluidRandom_img.width/2, springFluidRandom_others[i].position().y() - springFluidRandom_img.height/2);
  }
}
