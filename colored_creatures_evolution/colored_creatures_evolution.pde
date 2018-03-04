//
// Evolution of prey colors using a simple genetic algorithm
//
// The background color corresponds to the environment color. The closest the prey is from this environment color, 
// the hardest it is for the predator to see it.
//
// The shapes of preys and predators are made out of vertices whose length follows a Perlin noise. The shapes are symmetrical.
// Each prey is characterised by its genotype (a RGB code from 0 to 255) which is expressed by the phenotype (the color of the prey).
// 
// At creation, a prey has a probability love_probability to be interested in each of its prey-mates. When it reaches the reproduction age
// it tracks each loved prey in its vision field and they make a child when they touch each other.
// A child is created when two mates reproduce. Each of its gene is randomly selected from one of its parents.
// It has a probability p_mutation to be mutated. If it is, one of its gene is modified by a Gaussian noise of std power_mutation.
//
// The predator can see a prey that is &) in its field of view, 2) within a certain distance that depends on the fitness of the prey (how
// close is its color to the background color). If a predator sees a prey, it tracks it and eat it when they touch. Subsenquently, there 
// is a small delay during which the predator is not hungry anymmore.
//
// New preys can be added by clicking on the screen.
//
// Wandering behavior is obtained by the following process: A circle is positioned in front of the creature (distance to the creature,
// diameter of the circle can be tuned). Then, a position around the circle is tracked. The angle of this position evolves with a random angle
// added or subtracted to it. The direction towards the position on the circle is used as the driving force. This allows to have a natureal-like
// wandering. This idea comes from the online book The Nature of Code (http://natureofcode.com/book/)

int nb_preys = 20; // number of preys
int max_preys = 30; // maximum number of preys
int nb_preds = 2; // number of predators
int[] background_color = new int[3];
float love_probability = 1; // proability that a prey can reproduce with another specific one

ArrayList<Prey> preys = new ArrayList<Prey>();
ArrayList<Predator> preds = new ArrayList<Predator>();

void setup(){
  size(1000,600);
  background_color[0] = int(random(255));
  background_color[1] = int(random(255));
  background_color[2] = int(random(255));
  
  // create the first generation of preys  
  for(int i=0;i<nb_preys;i++){
    preys.add(new Prey(background_color));
    preys.get(i).lifespan = int(random(0,3500));
  }
  
  //update mating interest towards peers
  for(Prey p:preys){
    for(Prey p2:preys){
      if(p==p2){
        p.mating_interests.add(false); // no interest for itself
      }
      else{
        if(random(1)<love_probability){
          p.mating_interests.add(true);
        }
        else{
          p.mating_interests.add(false);
        }
      }
    }
  }
  
  // create the predators
  for(int i=0;i<nb_preds;i++){
    preds.add(new Predator());
  }
}

void draw(){
  background(background_color[0], background_color[1], background_color[2]);
 
  ArrayList<Prey> all_childs = new ArrayList<Prey>();
  for(Prey p : preys){
    shape(p.cshape);
    p.update(); // updates lifespan, position, and shape
    p.checkBorders(); // check borders of the canvas
    p.display(); // draw new shape in new position
    p.wander(); // creature wander unless driven by other forces (mating, avoiding, predator, avoiding borders..)
    
    ArrayList<Prey> childs = p.checkMates(preys); // check if close enough to mates to reproduce
    for(Prey child:childs){
      all_childs.add(child);
    }
    p.isDead(); // check if lifespan is over
    p.checkPredators(preds); // avoiding behavior
  }
  
  // create childs
  create_preys(preys, all_childs);

  // remove deads
  for(int i=0;i<preys.size();i++){
    if(!preys.get(i).alive){
      preys.remove(i);
    }
  }

  
  for(Predator p : preds){
    shape(p.cshape);
    p.update(); // update location and shape
    p.display(); // draw predator at new location
    p.wander();  // wander if not driven by any other force (chasing, avoid borders)
    p.checkPreys(preys); // seeking behavior: chasing
    p.checkBorders(); // avoid borders
  }
}

//void mousePressed(){
//  Prey new_prey = new Prey(background_color);
//  new_prey.location = new PVector(mouseX,mouseY);
//  preys.add(new_prey); 
//  for(Prey p:preys){
//    if(random(1)<love_probability){
//      p.mating_interests.add(true);
//    }
//    else{
//      p.mating_interests.add(false);
//    }
//    if(random(1)<love_probability){
//      new_prey.mating_interests.add(true);
//    }
//    else{
//      new_prey.mating_interests.add(false);
//    }
//  }
//  new_prey.mating_interests.add(false); // no interest for himself
//}


// creation of new prey
void create_preys(ArrayList<Prey> preys, ArrayList<Prey> childs){
  for(Prey child : childs){
    if (preys.size()<max_preys){
       preys.add(child);
       for(Prey p:preys){
        if(random(1)<love_probability){
          p.mating_interests.add(true);
        }
        else{
          p.mating_interests.add(false);
        }
        if(random(1)<love_probability){
          child.mating_interests.add(true);
        }
        else{
          child.mating_interests.add(false);
        }
      }
      child.mating_interests.add(false); // no interest for himself
    }
  }
}