// A clone of Mature Metal's Jailbird. This is an excellent reference for sizing
// if you are unsure what will fit you, and are hesitant to jump into a custom manufacturing
// process without some additional foresight.

// Inputs - Feel free to change these.
RING_INNER_DIAM = 36;  //<< The inner diameter (wall to wall) of the cage's rings.
LENGTH = 60;           //<< The length of the cage, measured along the central curve,
                       //   from the base of the ring to the tip of the head.
ANGLE = 40;            //<< The total angle of curvature of the cage. 
BAR_DIAM = 4.5;        //<< The diameter of the bars on the side of the cage.
JB_STYLE_HEAD = false; //<< If will eventually have this made by Mature Metal, set this to true to
                       //   see what a cage would look like if made with metal.
N_BARS = 8;            //<< The number of bars the cage will have. TODO: provide similar option for head.
VERTICAL_HEAD_OPEN = false; //<< Change to leave only the vertical bars of the head fully intact. Remove the
                            //   middle portion of the horizontal bars, when set to true.
                            //   only works if JB_STYLE_HEAD is false
EMBOSS_DIMENSIONS = true; //<< Set to true to stamp the dimensions onto the lock insert. Extremely helpful
                            //   if you're printing multiple iterations and could lose track.

// Constants - Feel free to change these too, but things may break unexpectedly.
TOLERANCE = 1.05; // scale by this for tolerance. Move closer to 1 if you have a fancy printer.
RING_DIAM = 6.2;
RING_RAD = RING_DIAM / 2;
BAR_RAD = BAR_DIAM / 2;
RING_INNER_RAD = RING_INNER_DIAM / 2;
POST_INSERT_DIAM = 6.4 * TOLERANCE;
POST_INSERT_RAD = POST_INSERT_DIAM / 2;
LOCK_INSERT_DIAM = 4.4 * TOLERANCE;
LOCK_INSERT_RAD = LOCK_INSERT_DIAM / 2;
INSERT_WIDTH = 10;
INSERT_HEIGHT = 6;
INSERT_LENGTH = 13;
LOCK_INSERT_OFFSET = 7;
BAR_ANGLE_OFFSET = 360 / N_BARS / 2;
FONT_SIZE = 2;


HEAD_RAD_LOWER = 14; // smaller half circle of bars
HEAD_RAD_UPPER = HEAD_RAD_LOWER + BAR_DIAM;

// bars before they curve past the 2nd ring.
TUBE_LEN = LENGTH - HEAD_RAD_LOWER - (2 * RING_DIAM);
echo("TUBE LEN", TUBE_LEN);
// diamater for bars
EFFECTIVE_DIAM = RING_INNER_DIAM + RING_RAD - BAR_RAD;

Cage_Imaginary_Rad = (360 * TUBE_LEN) / (2 * PI * ANGLE);

// Code
module ring(inner_rad, ring_rad) {
  rotate_extrude($fn=100)
  translate([inner_rad + ring_rad, 0, 0])
    circle(r=ring_rad, $fn=50);
}

module insert() {
  union() {
    difference() {
      difference() {
        linear_extrude(INSERT_LENGTH, center=true) {
          hull() {
            translate([INSERT_WIDTH / 2, INSERT_HEIGHT / 2])
              circle(r=2, $fn=50);
            translate([-INSERT_WIDTH / 2, INSERT_HEIGHT / 2])
              circle(r=2, $fn=50);
            translate([INSERT_WIDTH / 2, -INSERT_HEIGHT / 2])
              circle(r=2, $fn=50);
            translate([-INSERT_WIDTH / 2, -INSERT_HEIGHT / 2])
              circle(r=2, $fn=50);
            }
          }
          // post insert
          linear_extrude(INSERT_LENGTH + 15, center=true)
          circle(r = POST_INSERT_RAD, $fn=50);
      }

      // lock insert
      rotate([90, 0, 0])
      linear_extrude(INSERT_LENGTH, center=true)
        circle(r=LOCK_INSERT_RAD, $fn=50);
    }
    translate([-INSERT_WIDTH / 1.5, 0, -INSERT_HEIGHT / 1.8])
      cube([INSERT_WIDTH / 2, INSERT_LENGTH / TOLERANCE - 3, INSERT_HEIGHT / 1.5], center=true);
  }

}

module bar(rad, angle, bar_rad=BAR_RAD) {
  translate([-rad, 0, 0])
  rotate([90, 0, 0])
  rotate_extrude(angle=angle, $fn=100)
  translate([abs(rad), 0, 0])
    circle(r = bar_rad, $fn=100);
}


module make_bars() {
  Step = 360 / N_BARS;
  Bar_Place_Rad = RING_INNER_RAD + RING_RAD;
  
  // make those bars
  for (a = [0 : N_BARS - 1]) {
    placement_angle = a * Step + BAR_ANGLE_OFFSET;
    // these need to meet at the same plane at the end
    // we know the center has TUBE_LEN length, so they
    // will vary in length by the x offset from origin
    translate([cos(placement_angle) * Bar_Place_Rad, sin(placement_angle) * Bar_Place_Rad, RING_RAD - 1])
      bar(Cage_Imaginary_Rad + (cos(placement_angle) * (RING_INNER_RAD + RING_RAD)), ANGLE);
  }
}

ARC_DIST = sqrt(2 * pow(Cage_Imaginary_Rad, 2) * (1 - cos(ANGLE)));
OMEGA = (180 - ANGLE) / 2;
EPSILON = 90 - OMEGA;
echo ("OMEGA", OMEGA);
echo ("EPSILON", EPSILON);
echo ("ARC DIST: ", ARC_DIST);


X_OFFSET = (ARC_DIST - 1) * cos(OMEGA);
echo ("X OFFSET: ", X_OFFSET);
Z_OFFSET = (ARC_DIST - 1) * sin(OMEGA) + RING_RAD;
echo ("Z OFFSET: ", Z_OFFSET);

// TODO fix hard coding of 45 deg
module head() {
  HARD45 = 45;
  to_middle = RING_INNER_RAD + RING_RAD - BAR_RAD;
  
  
  translate([0, to_middle * sin(HARD45 / 2), 0])
    bar(to_middle, 180);
  
  translate([0, -to_middle * sin(HARD45 / 2), 0])
    bar(to_middle, 180);
  
  if (JB_STYLE_HEAD) {
    resize([0, 0, to_middle + BAR_DIAM + 2])
    translate([-to_middle * cos(HARD45) * 2, to_middle, 0])
    rotate([0, 0, 90])
      bar(to_middle, 180);
    
    resize([0, 0, to_middle + BAR_DIAM + 2])
    translate([-to_middle * cos(HARD45) + 1, to_middle, 0])
    rotate([0, 0, 90])
      bar(to_middle, 180);
  } else {
    if (VERTICAL_HEAD_OPEN) {
      difference() {
        union() {
        translate([-to_middle * cos(HARD45) * 2, to_middle, 0])
        rotate([0, 0, 90])
          bar(to_middle, 180, BAR_RAD - 0.5); // FIXME - hack to make the bars meet nicely
        
        translate([-to_middle * cos(HARD45) + 2, to_middle, 0])
        rotate([0, 0, 90])
          bar(to_middle, 180, BAR_RAD - 0.5);
        }
        cube([100, RING_INNER_RAD * cos(HARD45 - 5), 100], center=true);
      }
    } else {
      translate([-to_middle * cos(HARD45) * 2, to_middle, 0])
      rotate([0, 0, 90])
        bar(to_middle, 180);
      
      translate([-to_middle * cos(HARD45) + 1, to_middle, 0])
      rotate([0, 0, 90])
        bar(to_middle, 180);
    }
  }
}

// putting it all together...
difference() {
  union() {
    translate([RING_INNER_RAD + RING_RAD + INSERT_WIDTH / 2 + 2.7, 0, INSERT_HEIGHT / 2])
      insert();
    ring(RING_INNER_RAD, RING_RAD);
    make_bars();
    
    translate([-X_OFFSET, 0, Z_OFFSET])
    rotate([0, -ANGLE, 0])
      ring(RING_INNER_RAD, RING_RAD);
    
    
    translate([-X_OFFSET, 0, Z_OFFSET])
    rotate([0, -ANGLE, 0])
    translate([RING_INNER_RAD + RING_RAD - BAR_RAD, 0, 0])
      head();
      

  } 
  
  if (EMBOSS_DIMENSIONS) {
    translate([RING_INNER_RAD + RING_RAD + INSERT_HEIGHT + 8.4, 0, 3.5 * FONT_SIZE])
    rotate([90, 0, 90])
    linear_extrude(10) {
      text(str(RING_INNER_DIAM, "D"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([0, -FONT_SIZE, 0])
        text(str(LENGTH, "L"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([0, -FONT_SIZE * 2, 0])
        text(str(ANGLE, "A"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([0, -FONT_SIZE * 3, 0])
        text(str(BAR_DIAM, "B"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([0, -FONT_SIZE * 4, 0])
        text(str(RING_DIAM, "R"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
    }
  }
}






































