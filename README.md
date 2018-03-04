# colored_creatures_evolution
Processing code to evolve colors of preys chased by predators

Evolution of prey colors using a simple genetic algorithm

The background color corresponds to the environment color. The closest the prey is from this environment color, 
the hardest it is for the predator to see it.

The shapes of preys and predators are made out of vertices whose length follows a Perlin noise. The shapes are symmetrical.
Each prey is characterised by its genotype (a RGB code from 0 to 255) which is expressed by the phenotype (the color of the prey).
 
At creation, a prey has a probability love_probability to be interested in each of its prey-mates. When it reaches the reproduction age
it tracks each loved prey in its vision field and they make a child when they touch each other.
A child is created when two mates reproduce. Each of its gene is randomly selected from one of its parents.
It has a probability p_mutation to be mutated. If it is, one of its gene is modified by a Gaussian noise of std power_mutation.

The predator can see a prey that is &) in its field of view, 2) within a certain distance that depends on the fitness of the prey (how
close is its color to the background color). If a predator sees a prey, it tracks it and eat it when they touch. Subsenquently, there 
is a small delay during which the predator is not hungry anymmore.

New preys can be added by clicking on the screen.

Wandering behavior is obtained by the following process: A circle is positioned in front of the creature (distance to the creature,
diameter of the circle can be tuned). Then, a position around the circle is tracked. The angle of this position evolves with a random angle
added or subtracted to it. The direction towards the position on the circle is used as the driving force. This allows to have a natureal-like
wandering. This idea comes from the online book The Nature of Code (http://natureofcode.com/book/)

This project has been highly inspired by a blog post creating similar creatures (http://blog.otoro.net/2015/05/07/creatures-avoiding-planks/)
and the online book The Nature of Code (to be found here: http://natureofcode.com/book/).

Author: Cédric Colas
Email: cdric.colas@gmail.com
