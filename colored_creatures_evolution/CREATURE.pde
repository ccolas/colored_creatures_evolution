int nb_points = 100; // number of vertex for shape design
int prey_radius = 20;
int predator_radius = 50;
float prey_noise_step = 0.01; // step for Perlin noise controlling the vertices length
float predator_noise_step = 0.01;
int eye_pos_prey = 2;
int eye_pos_pred = 10;

float mutation_rate = 0.2;
float mutation_power = 10;
float mating_probability = 0.3;

Boolean red_arrow_of_desire = true;

float wanderR = 25;         // Radius for our "wander circle"
float wanderD = 80;         // Distance for our "wander circle"

class Creature{
  
  PShape cshape;             // creature's shape
  PShape body_shape;         // creature's body shape
  PVector location;          // location
  PVector velocity;          // velocity
  PVector acceleration;      // acceleration
  float orientation;         // orientation
  float t_sin;               // variable for sinusoidal modulation of shape (breathing)
  float sin_step;            // parameter for the period of the sinusoidal modulation
  float[] norm_vertices;     // contains magnitudes of the shape's vertices
  int[] ccolor = new int[3]; // rgb color of the creature
  float wandertheta;         // angle value of wander circle
  float body_radius;         // measures the approximate radius of the creature's body
  
  //constructor
  Creature(float noise_step, int radius, int eye_pos){

    // random location and orientation
    location = new PVector(int(random(10, width-10)), int(random(10, height-10)));
    orientation = radians(random(360));
    velocity = new PVector(0,0);
    acceleration = new PVector(0,0);
    t_sin = random(1000);
    body_radius = 1000;

    // random color
    ccolor[0] = int(random(255));
    ccolor[1] = int(random(255));
    ccolor[2] = int(random(255));
    stroke(0);
    
    // random shape
    norm_vertices = new float[nb_points+1];
    PVector v; //coordinate of points to use as vertex
    float noise_t = random(1000); //initial value for Perlin noise
    float p_noise; //value of Perlin noise
    body_shape = createShape();
    body_shape.beginShape();
    body_shape.fill(ccolor[0], ccolor[1], ccolor[2]);
    for (int i=0;i<nb_points;i++){
      //design symetrical creatures
      if (i<int(nb_points/2)){
        noise_t+=noise_step;
      }
      else{
        noise_t-=noise_step;
      }
      p_noise = noise(noise_t);
      v = PVector.fromAngle((2*PI/nb_points)*i);
      v.mult(p_noise*radius);
      norm_vertices[i] = v.mag(); 
      if(norm_vertices[i]<body_radius){
        body_radius = norm_vertices[i];
      }
      body_shape.vertex(v.x, v.y);
    }
    //close shape
    PVector init_v = body_shape.getVertex(0);
    body_shape.vertex(init_v.x,init_v.y);
    norm_vertices[nb_points] = init_v.mag();   
    body_shape.endShape();
    
    //add eyes
    PVector left_head = body_shape.getVertex(9);
    PVector right_head= body_shape.getVertex(body_shape.getVertexCount()-10);
    float size_head = PVector.sub(left_head, right_head).mag();
    float size_eye = size_head/3;
    float eye_x = body_shape.getVertex(0).mag()-eye_pos;
    PShape eye1_shape = createShape(ELLIPSE,eye_x,-int(3*size_eye/4),int(size_eye),int(size_eye));
    PShape eye2_shape = createShape(ELLIPSE,eye_x,int(3*size_eye/4),int(size_eye),int(size_eye));
    PShape iris1_shape = createShape(ELLIPSE,eye_x,-int(3*size_eye/4),int(size_eye/2),int(size_eye/2));
    PShape iris2_shape = createShape(ELLIPSE,eye_x,int(3*size_eye/4),int(size_eye/2),int(size_eye/2));
    iris1_shape.setFill(0);
    iris2_shape.setFill(0);
       
    cshape = createShape(GROUP);
    cshape.addChild(body_shape);
    cshape.addChild(eye1_shape);
    cshape.addChild(eye2_shape);
    cshape.addChild(iris1_shape);
    cshape.addChild(iris2_shape);
    cshape.translate(location.x, location.y);
    cshape.rotate(orientation);
  }
  
  void update_shape(float sin_step){
    // update shape with sinusoidale modulations (breathing)
    t_sin += sin_step;
    for (int i = 0; i < body_shape.getVertexCount(); i++) {        
      PVector v = body_shape.getVertex(i);
      v.normalize();
      if (i<int(body_shape.getVertexCount()/2)){
        v.mult(norm_vertices[i]+sin(t_sin+i/10)*2);
      }
      else{
        v.mult(norm_vertices[i]+sin(t_sin+(body_shape.getVertexCount()-i)/10)*2);
      }
      body_shape.setVertex(i, v);
    }
  }
  
  void wander(float change_angle, float maxspeed, float maxforce) {
  
    wandertheta += random(-change_angle,change_angle);     // Randomly change wander theta

    // Now we have to calculate the new location to steer towards on the wander circle
    PVector circleloc = velocity.copy();    // Start with velocity
    circleloc.normalize();            // Normalize to get heading
    circleloc.mult(wanderD);          // Multiply by distance
    circleloc.add(location);          // Make it relative to boid's location
    
    float h = velocity.heading();        // We need to know the heading to offset wandertheta

    PVector circleOffSet = new PVector(wanderR*cos(wandertheta+h),wanderR*sin(wandertheta+h));
    PVector target = PVector.add(circleloc,circleOffSet);
    seek(target, maxspeed, maxforce);

  }  
  
  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  void seek(PVector target, float maxspeed, float maxforce) {
    PVector desired = PVector.sub(target,location);  // A vector pointing from the location to the target

    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    applyForce(steer);
  }
  
  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }
  
  void update(float maxspeed, float sin_step, int r) {
    update_pos(maxspeed);
    update_shape(sin_step);
  }
  
  void update_pos(float maxspeed) {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }
  
  void display() {
    cshape.resetMatrix();
    cshape.translate(location.x,location.y);
    cshape.rotate(velocity.heading());
  }
  
    // Wraparound
  void borders(int r) {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }
  
  void boundaries(float maxspeed, float maxforce, int r) {

    PVector desired = null;

    if (location.x < r) {
      desired = new PVector(maxspeed, velocity.y);
    } 
    else if (location.x > width -r) {
      desired = new PVector(-maxspeed, velocity.y);
    } 

    if (location.y < r) {
      desired = new PVector(velocity.x, maxspeed);
    } 
    else if (location.y > height-r) {
      desired = new PVector(velocity.x, -maxspeed);
    } 

    if (desired != null) {
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      acceleration.mult(0);
      //velocity.mult(0.1);
      applyForce(steer);
    }
  }  

 
 
}

class Prey extends Creature{
  
  float maxLifespan;
  float lifespan;
  float fitness;
  float camouflage; // distance above which the prey is not seen by the predator. Mapped from the fitness function
  float sin_step = 0.1;
  float change_angle = 0.5;
  float maxspeed = random(0.7,1.1);         // maximum speed of the creature
  float maxforce = 0.03;      // maximum force applied to the creature
  int r = 1;        
  boolean alive;
  float vision_angle = radians(180);
  int vision_distance = 100;
  int mate_distance = 200;
  float mate_vision_angle = radians(360);
  int reproducingAge = 3500;
  
  ArrayList<Boolean> mating_interests = new ArrayList<Boolean>();
  
  Prey(int[] background_color){
    super(prey_noise_step, prey_radius, eye_pos_prey);
    alive = true;
    lifespan = 0;
    maxLifespan = int(random(20000,30000));
    float distance;
    distance = sqrt(sq(background_color[0]-ccolor[0])+sq(background_color[1]-ccolor[1])+sq(background_color[2]-ccolor[2]));
    fitness = distance;
    float max_distance = 0;
    for(int i=0;i<3;i++){
     if (background_color[i]>=128){
       max_distance += sq(background_color[i]);
     }
     else {
      max_distance += sq(255-background_color[i]); 
     }
    }
    max_distance = sqrt(max_distance);
    camouflage = map(fitness, 0, max_distance, 0, 400); 
    // helps preys with good fitness to have an even better one
    if(camouflage<150){
      camouflage = map(camouflage, 0, 150, 0, 10);
    }
  }
  
  void wander() {
    super.wander(change_angle, maxspeed, maxforce);
  }
  
  void isDead(){
    if (lifespan>=maxLifespan){
      alive=false;
    }
  }
    
  void update() {
    super.update(maxspeed, sin_step, r);
    lifespan+=1;
  }
  
  ArrayList<Prey> checkMates(ArrayList<Prey> preys){
    ArrayList<Prey> childs = new ArrayList<Prey>();
    float min_distance=500;
    PVector desired = null;
    int ind = 0; // index of current prey
    for(Prey p : preys){
      if(ccolor!=p.ccolor){
        PVector p_vector = PVector.sub(p.location, location);
        float distance = p_vector.mag();
        float angle = PVector.angleBetween(velocity,p_vector);
        if(distance<body_radius+10&&p.lifespan>reproducingAge&&lifespan>reproducingAge&&mating_interests.get(ind)){
          childs.add(makeBaby(p));
          int rand = int(random(1));
          mating_interests.set(ind,false);
        }
        if(angle<mate_vision_angle/2&&distance<mate_distance&&distance<min_distance&&mating_interests.get(ind)&&p.lifespan>reproducingAge&&lifespan>reproducingAge){
            desired=p_vector;
            min_distance = distance;
        }
      }
      ind++;
    }
    if(desired!=null){
      if(red_arrow_of_desire){
        stroke(255,0,0);
        line(location.x,location.y,desired.x+location.x,desired.y+location.y);
      }
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      acceleration.mult(0);
      applyForce(steer);
    }
    return childs;
  }
  
  Prey makeBaby(Prey p){
    print("\n Baby !");
    Prey child = new Prey(background_color);
    child.location = location.copy();
    // for each rgb component, select randomly one of the parent's
    for(int i=0;i<3;i++){
      if(random(1)>0.5){
        child.ccolor[i] = ccolor[i];
      }
      else{
        child.ccolor[i] = p.ccolor[i];
      }
    }
    //apply mutation
    if(random(1)<mutation_rate){
      child.ccolor[int(random(3))] += randomGaussian()*mutation_power;
    }
    return child;
  }
  
    void checkPredators(ArrayList<Predator> preds){
    float min_distance=500;
    PVector desired = null;
    for(Predator p : preds){
      PVector p_vector = PVector.sub(p.location, location);
      float distance = p_vector.mag();
      //float angle = PVector.angleBetween(velocity,p_vector);
      if(distance<vision_distance && distance<min_distance){
          desired=p_vector.mult(-1);
          min_distance=distance;
      }
    }
    if(desired!=null){
      if(red_arrow_of_desire){
        stroke(255,0,0);
        line(location.x,location.y,desired.x+location.x,desired.y+location.y);
      }
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      acceleration.mult(0);
      applyForce(steer);
    }
  }
  
  void checkBorders(){
    super.borders(r);
  }
}

class Predator extends Creature{
  
  float sin_step = 0.05;
  float change_angle = 0.3;
  float maxspeed = 1.4;
  float maxforce = 0.03;
  int r = 40;
  float vision_angle=radians(180);
  int hungry; //hungry when hungry goes negative
   
  Predator(){
    super(predator_noise_step, predator_radius,eye_pos_pred);
    body_shape.setFill(0);
    hungry = 60;
  }
  
  void wander() {
    super.wander(change_angle, maxspeed, maxforce);
  }
  
  void update() {
    super.update(maxspeed, sin_step, r);
    hungry-=1;
  }
  
  void checkBorders(){
    super.boundaries(maxspeed, maxforce, r);
  }
  
  void checkPreys(ArrayList<Prey> preys){
    float min_distance=500;
    PVector desired = null;
    for(Prey p : preys){
      PVector p_vector = PVector.sub(p.location, location);
      float distance = p_vector.mag();
      float angle = PVector.angleBetween(velocity,p_vector);
      if(distance<body_radius && hungry<0){
        p.alive=false;
        hungry=100;
      }
      if(angle<vision_angle/2 && distance<p.camouflage && distance<min_distance &&hungry<0){
          desired=p_vector;
          min_distance=distance;
      }
    }
    if(desired!=null){
      if(red_arrow_of_desire){
        stroke(255,0,0);
        line(location.x,location.y,desired.x+location.x,desired.y+location.y);
      }
      desired.normalize();
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      acceleration.mult(0);
      applyForce(steer);
    }
  }
}