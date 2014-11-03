void setup1()
{
  // sprite mask thing stolen from dan shiffman 
  PImage springingSnow_msk = loadImage("texture.gif");
  springingSnow_img = new PImage( springingSnow_msk.width, springingSnow_msk.height );
  for ( int i = 0; i < springingSnow_img.pixels.length; i++ ) 
    springingSnow_img.pixels[i] = color(255);
  springingSnow_img.mask(springingSnow_msk);
  imageMode(CORNER);
  tint( 255, 255, 255, 100 );

  // NEILL SETUP ==============
  springingSnow_physics = new ParticleSystem( 0.01, 0.1 );  // new ParticleSystem( float gravityY, float drag )

  /*
   * Particle makeParticle()
   * Particle makeParticle( float mass, float x, float y, float z )
   * create a new particle in the system with some mass and at some x, y, z position.
   * The default a new particle with mass 1.0 at (0, 0, 0).
   */
  for (int i=0; i<maxNumIdsToRecognize; i++){
    springingSnow_mouse[i] = springingSnow_physics.makeParticle();
    springingSnow_mouse[i].moveTo( -100000, -100000, 0 );
    springingSnow_mouse[i].makeFixed();
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

  springingSnow_others = new Particle[springingSnow_numParticles];
  springingSnow_anchors = new Particle[springingSnow_numParticles];
  springingSnow_springs = new Spring[springingSnow_numParticles];
  for ( int i = 0; i < springingSnow_others.length; i++ )
  {
    // Particle makeParticle( float mass, float x, float y, float z )
    springingSnow_others[i] = springingSnow_physics.makeParticle( 1.0, random( 0, width ), random( 0, height ), 0 );
    /*
     * Attraction makeAttraction( Particle a, Particle b, float strength, float minimumDistance )
     * make an attraction (or repulsion) force between two particles.
     * If the strength is negative they repel each other, if the strength is positive they attract.
     * There is also a minimum distance that limits how strong this force can get close up. See attraction for details.
     */
    for (int j=0; j<maxNumIdsToRecognize; j++){
      springingSnow_physics.makeAttraction( springingSnow_mouse[j], springingSnow_others[i], springingSnow_attractionStrength, springingSnow_attractionMinDistance ); 
    }
    springingSnow_anchors[i] = springingSnow_physics.makeParticle( springingSnow_others[i].mass(), springingSnow_others[i].position().x(), springingSnow_others[i].position().y(), springingSnow_others[i].position().z() );
    springingSnow_anchors[i].makeFixed();
    // Spring makeSpring( Particle a, Particle b, float strength, float damping, float restLength )
    springingSnow_springs[i] = springingSnow_physics.makeSpring( springingSnow_others[i], springingSnow_anchors[i], springingSnow_springStrength, springingSnow_damping, 0 );
  }
  // END NEILL SETUP =====================================
}

void draw1(TuioCursor[] tuioCursorList)
{
  background( 0, 0, 0 );
  springingSnow_physics.tick();

  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // enter behaviour/interaction here
    // use touchX[k] and touchY[k] for the x, y coordinates to use for each TUIO ID
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    // remember, all these variables are floats
    ///////////////////////////////////
    springingSnow_mouse[k].moveTo( touchX[k], touchY[k], 0 );

    if (k >= tuioCursorList.length) {
      springingSnow_mouse[k].moveTo( -100000, -100000, 0 );
      touchX[k] = -100000;
      touchY[k] = -100000;
    }
  }

  // DRAW THE RADIAL BACKGROUND ============== COMMENT OUT FOR BLACK BACKGROUND ====
  drawGradientDisc( ((width)/2)+200 , ((height)/2)-200, width, height, color(255,255,255), color(0,0,255,2) ); 

  // DRAW THE LEAVES ===============================
  for ( int i = 0; i < springingSnow_others.length; i++ )
  {
    image(springingSnow_img, springingSnow_others[i].position().x() - springingSnow_img.width/2, springingSnow_others[i].position().y() - springingSnow_img.height/2);
  }
}
