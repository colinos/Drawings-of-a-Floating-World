void setup0()
{
  // sprite mask thing stolen from dan shiffman 
  PImage dandilines_msk = loadImage("texture.gif");
  dandilines_img = new PImage( dandilines_msk.width, dandilines_msk.height );
  for ( int i = 0; i < dandilines_img.pixels.length; i++ ) 
    dandilines_img.pixels[i] = color(255);
  dandilines_img.mask(dandilines_msk);
  imageMode(CORNER);
  tint( 255, 255, 255, 80 );

  dandilines_physics = new ParticleSystem( 0.01, 0.25 );  // new ParticleSystem( float gravityY, float drag )

  /*
   * Particle makeParticle()
   * Particle makeParticle( float mass, float x, float y, float z )
   * create a new particle in the system with some mass and at some x, y, z position.
   * The default a new particle with mass 1.0 at (0, 0, 0).
   */
  for (int i=0; i<maxNumIdsToRecognize; i++){
    dandilines_mouse[i] = dandilines_physics.makeParticle();
    dandilines_mouse[i].moveTo( -100000, -100000, 0 );
    dandilines_mouse[i].makeFixed();
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

  dandilines_others = new Particle[dandilines_numParticles];
  dandilines_anchors = new Particle[dandilines_numParticles];
  dandilines_springs = new Spring[dandilines_numParticles];
  //roots = new Particle[dandilines_numParticles];
  rootsX = new int[dandilines_numParticles];
  rootsY = new int[dandilines_numParticles];
  grassTops = new Particle[dandilines_numParticles];
  grassAnchors = new Particle[dandilines_numParticles];
  heads = new Particle[dandilines_numParticles];

  for ( int i = 0; i < dandilines_others.length; i++ )
  {

    //float particlePlace = (width/dandilines_numParticles)+(width/dandilines_numParticles)/2;
    // gives an evenly spaced number of particles across the screen

      // Particle makeParticle( float mass, float x, float y, float z )
    dandilines_others[i] = dandilines_physics.makeParticle( 1.0, i*(width/dandilines_numParticles+2) + (int)random(-25, 25), ( height/2 ) + (int)random(-50, 50), 0 );
    grassTops[i] = dandilines_physics.makeParticle( 1.0, i*(width/dandilines_numParticles+2) + (int)random(-25, 25), ( height/2 ) + (int)random(-50, 50), 0 );
    heads[i] = dandilines_physics.makeParticle( 1.0, dandilines_others[i].position().x(), dandilines_others[i].position().y(), dandilines_others[i].position().z() );
    rootsX[i] = i*(width/dandilines_numParticles+2) + (int)random(-25, 25);
    rootsY[i] = height;

    /*    dandilines_others[i] = dandilines_physics.makeParticle( 1.0, i*(width/dandilines_numParticles+2), ( height/2 ), 0 );
     grassTops[i] = dandilines_physics.makeParticle( 1.0, i*(width/dandilines_numParticles+2), ( height/2 ), 0 );
     heads[i] = dandilines_physics.makeParticle( 1.0, dandilines_others[i].position().x(), dandilines_others[i].position().y(), dandilines_others[i].position().z() );
     rootsX[i] = i*(width/dandilines_numParticles+2);
     rootsY[i] = height;
     */
    //roots[i].makeFixed();
    /*
     * Attraction makeAttraction( Particle a, Particle b, float strength, float minimumDistance )
     * make an attraction (or repulsion) force between two particles.
     * If the strength is negative they repel each other, if the strength is positive they attract.
     * There is also a minimum distance that limits how strong this force can get close up. See attraction for details.
     */
    for (int j=0; j<maxNumIdsToRecognize; j++){
      dandilines_physics.makeAttraction( dandilines_mouse[j], dandilines_others[i], dandilines_attractionStrength, dandilines_attractionMinDistance ); 
      dandilines_physics.makeAttraction( dandilines_mouse[j], grassTops[i], dandilines_attractionStrength, dandilines_attractionMinDistance ); 
      dandilines_physics.makeAttraction( dandilines_mouse[j], heads[i], dandilines_attractionStrength, dandilines_attractionMinDistance );       
    }

    dandilines_anchors[i] = dandilines_physics.makeParticle( dandilines_others[i].mass(), dandilines_others[i].position().x(), dandilines_others[i].position().y(), dandilines_others[i].position().z() );
    dandilines_anchors[i].makeFixed();
    grassAnchors[i] = dandilines_physics.makeParticle( grassTops[i].mass(), grassTops[i].position().x(), grassTops[i].position().y(), grassTops[i].position().z() );
    grassAnchors[i].makeFixed();

    // Spring makeSpring( Particle a, Particle b, float strength, float damping, float restLength )
    dandilines_springs[i] = dandilines_physics.makeSpring( dandilines_others[i], dandilines_anchors[i], dandilines_springStrength, dandilines_damping, 0 );
    dandilines_springs[i] = dandilines_physics.makeSpring( grassTops[i], grassAnchors[i], dandilines_springStrength, dandilines_damping, 0 );

  }
}

void draw0(TuioCursor[] tuioCursorList)
{
  background( 0, 0, 0 );
  dandilines_physics.tick();

  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // enter behaviour/interaction here
    // use touchX[k] and touchY[k] for the x, y coordinates to use for each TUIO ID
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    // remember, all these variables are floats
    ///////////////////////////////////
    dandilines_mouse[k].moveTo( touchX[k], touchY[k], 0 );

    if (touchX[k] == previousX[k] && touchY[k] == previousY[k]) {
      dandilines_mouse[k].moveTo( -100000, -100000, 0 );
      touchX[k] = -100000;
      touchY[k] = -100000;
    }   
  }

  // DRAW THE RADIAL BACKGROUND ============== COMMENT OUT FOR BLACK BACKGROUND ====
  // drawGradientDisc( ((width)/2)+200 , ((height)/2)-200, width, height, color(255,255,255), color(0,0,255,2) ); 

  // DRAW EVERYTHING ===============================
  for ( int i = 0; i < dandilines_others.length; i++ )
  {
    // DRAW DANDILINE HEADS ===================================================================
    image(dandilines_img, heads[i].position().x() - dandilines_img.width/2, heads[i].position().y() - dandilines_img.height/2);
    /*fill(255, 255, 255, 126);
     noStroke();
     ellipse(heads[i].position().x(), heads[i].position().y(), 40, 40);*/

    // DRAW STALKS =============================================================================
    stroke(0, 64, 0, 150);
    //    stroke(255,0,0);
    strokeWeight(2);
    noFill();
    //bezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2);
    bezier( dandilines_others[i].position().x(), dandilines_others[i].position().y(),
    dandilines_others[i].position().x() + variableXCurve, dandilines_others[i].position().y() + variableYCurve,
    rootsX[i] + variableXCurve, rootsY[i] + variableYCurve,
    rootsX[i], rootsY[i] );
    strokeWeight(1);

    // DRAW GRASS ===============================================================================
    fill(0, 255, 0, 60);
    noStroke();
    beginShape();
    vertex( grassTops[i].position().x(), grassTops[i].position().y() ); // first x, y position

    bezierVertex( (grassTops[i].position().x()) + grassXCurve1, (grassTops[i].position().y()) + grassYCurve,
    rootsX[i] + rootXCurve, rootsY[i] + rootYCurve, rootsX[i], rootsY[i] );

    vertex( rootsX[i] - 50, rootsY[i] );

    bezierVertex( (rootsX[i] + rootXCurve) - 40, rootsY[i] + rootYCurve, 
    (grassTops[i].position().x()) + grassXCurve2, (grassTops[i].position().y()) + grassYCurve, grassTops[i].position().x(), grassTops[i].position().y() ); 

    endShape();
  }
}
