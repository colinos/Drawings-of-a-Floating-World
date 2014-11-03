void setup1()
{
  seed_seeds = loadImage("seeds.png");
  colorMode(RGB,255,255,255,100);
  seed_psystems = new ArrayList();
}

void draw1(TuioCursor[] tuioCursorList)
{
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

    if (touchX[k] != previousX[k] || touchY[k] != previousY[k]) {
      seed_psystems.add(new Seed_ParticleSystem(int(random(1,5)),new Seed_Vector3D(touchX[k],touchY[k])));
    }

    // Cycle through all particle systems, run them and delete old ones
    for (int i = seed_psystems.size()-1; i >= 0; i--) {
      Seed_ParticleSystem psys = (Seed_ParticleSystem) seed_psystems.get(i);
      psys.run();
      if (psys.dead()) {
        seed_psystems.remove(i);
      }
    }

  }
}

class Seed_CrazyParticle extends Seed_Particle {

  // Just adding one new variable to a Seed_CrazyParticle
  // It inherits all other fields from "Seed_Particle", and we don't have to retype them!
  float theta;

  // The Seed_CrazyParticle constructor can call the parent class (super class) constructor
  Seed_CrazyParticle(Seed_Vector3D l) {
    // "super" means do everything from the constructor in Seed_Particle
    super(l);
    // One more line of code to deal with the new variable, theta
    theta = 0.0;

  }

  // Notice we don't have the method run() here; it is inherited from Seed_Particle

  // This update() method overrides the parent class update() method
  void update() {
    super.update();
    // Increment rotation based on horizontal velocity
    float theta_vel = (vel.x * vel.magnitude()) / 10.0f;
    theta += theta_vel;
  }

  // Override timer
  void timer() {
    timer -= 0.5;
  }
  
  // Method to display
  void render() {
    // Render the ellipse just like in a regular particle
    super.render();

    // Then add a rotating line
    pushMatrix();
    translate(loc.x,loc.y);
    rotate(theta);
    //stroke(255,timer);
    tint(255,timer); //fade
    //line(0,0,25,0);
    imageMode(CORNER);
    image(seed_seeds,0,0,75,90);

    popMatrix();
  }
}

// A simple Particle class

class Seed_Particle {
  Seed_Vector3D loc;
  Seed_Vector3D vel;
  Seed_Vector3D acc;
  float r;
  float timer;

  // One constructor
  Seed_Particle(Seed_Vector3D a, Seed_Vector3D v, Seed_Vector3D l, float r_) {
    acc = a.copy();
    vel = v.copy();
    loc = l.copy();
    r = r_;
    timer = 100.0;
  }

  // Another constructor (the one we are using here)
  Seed_Particle(Seed_Vector3D l) {
    acc = new Seed_Vector3D(0,0.05,0);
    vel = new Seed_Vector3D(random(-1,1),random(-2,0),0);
    loc = l.copy();
    r = 10.0;
    timer = 100.0;
  }


  void run() {
    update();
    render();
  }

  // Method to update location
  void update() {
    vel.add(acc);
    loc.add(vel);
    timer -= 1.0;
  }

  // Method to display
  void render() {
    ellipseMode(CENTER);
    noStroke();
    fill(jade,timer);
    ellipse(loc.x,loc.y,r,r);
    fill(grass,timer);
    ellipse(loc.x+100,loc.y+100,r+10,r+10);
  }

  // Is the particle still useful?
  boolean dead() {
    if (timer <= 0.0) {
      return true;
    } 
    else {
      return false;
    }
  }
}

// A class to describe a group of Particles
// An ArrayList is used to manage the list of Particles 

class Seed_ParticleSystem {

  ArrayList particles;    // An arraylist for all the particles
  Seed_Vector3D origin;        // An origin point for where particles are birthed

  Seed_ParticleSystem(int num, Seed_Vector3D v) {
    particles = new ArrayList();              // Initialize the arraylist
    origin = v.copy();                        // Store the origin point
    for (int i = 0; i < num; i++) {
      particles.add(new Seed_CrazyParticle(origin));    // Add "num" amount of particles to the arraylist
    }
  }

  void run() {
    // Cycle through the ArrayList backwards b/c we are deleting
    for (int i = particles.size()-1; i >= 0; i--) {
      Seed_Particle p = (Seed_Particle) particles.get(i);
      p.run();
      if (p.dead()) {
        particles.remove(i);
      }
    }
  }

  void addParticle() {
    particles.add(new Seed_Particle(origin));
  }

  void addParticle(Seed_Particle p) {
    particles.add(p);
  }

  // A method to test if the particle system still has particles
  boolean dead() {
    if (particles.isEmpty()) {
      return true;
    } else {
      return false;
    }
  }

}

// Simple Vector3D Class 

public class Seed_Vector3D {
  public float x;
  public float y;
  public float z;

  Seed_Vector3D(float x_, float y_, float z_) {
    x = x_; 
    y = y_; 
    z = z_;
  }

  Seed_Vector3D(float x_, float y_) {
    x = x_; 
    y = y_; 
    z = 0f;
  }

  Seed_Vector3D() {
    x = 0f; 
    y = 0f; 
    z = 0f;
  }

  void setX(float x_) {
    x = x_;
  }

  void setY(float y_) {
    y = y_;
  }

  void setZ(float z_) {
    z = z_;
  }

  void setXY(float x_, float y_) {
    x = x_;
    y = y_;
  }

  void setXYZ(float x_, float y_, float z_) {
    x = x_;
    y = y_;
    z = z_;
  }

  void setXYZ(Seed_Vector3D v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }
  public float magnitude() {
    return (float) Math.sqrt(x*x + y*y + z*z);
  }

  public Seed_Vector3D copy() {
    return new Seed_Vector3D(x,y,z);
  }

  public Seed_Vector3D copy(Seed_Vector3D v) {
    return new Seed_Vector3D(v.x, v.y,v.z);
  }

  public void add(Seed_Vector3D v) {
    x += v.x;
    y += v.y;
    z += v.z;
  }

  public void sub(Seed_Vector3D v) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
  }

  public void mult(float n) {
    x *= n;
    y *= n;
    z *= n;
  }

  public void div(float n) {
    x /= n;
    y /= n;
    z /= n;
  }

  public void normalize() {
    float m = magnitude();
    if (m > 0) {
      div(m);
    }
  }

  public void limit(float max) {
    if (magnitude() > max) {
      normalize();
      mult(max);
    }
  }

  public float heading2D() {
    float angle = (float) Math.atan2(-y, x);
    return -1*angle;
  }

  public Seed_Vector3D add(Seed_Vector3D v1, Seed_Vector3D v2) {
    Seed_Vector3D v = new Seed_Vector3D(v1.x + v2.x,v1.y + v2.y, v1.z + v2.z);
    return v;
  }

  public Seed_Vector3D sub(Seed_Vector3D v1, Seed_Vector3D v2) {
    Seed_Vector3D v = new Seed_Vector3D(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
    return v;
  }

  public Seed_Vector3D div(Seed_Vector3D v1, float n) {
    Seed_Vector3D v = new Seed_Vector3D(v1.x/n,v1.y/n,v1.z/n);
    return v;
  }

  public Seed_Vector3D mult(Seed_Vector3D v1, float n) {
    Seed_Vector3D v = new Seed_Vector3D(v1.x*n,v1.y*n,v1.z*n);
    return v;
  }

  public float distance (Seed_Vector3D v1, Seed_Vector3D v2) {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;
    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }

}
