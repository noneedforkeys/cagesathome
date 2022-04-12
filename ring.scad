// Inputs. Change these at will.

TOLERANCE = 0.96;       //<< for shenanigans, make this closer to 1 if you have a fancy ass printer
RING_INNER_DIAM = 48;  //<< Inner diameter of ring (wall to wall)
SPACING = 15;          //<< between ring and start of lock
RING_DIAM = 6.4;       //<< Diamter of ring itself (cross section)
RING_DIP = 4;          //<< Amount ring "dips" on the sides (ergonomics). Set to 0 for a flat ring.
LOCK_HOLE_OFFSET = 13; //<< Distance between the XY plane and the start of the lock hole.
POST_HEIGHT = 25;      //<< Height of the post.
HOR_STRETCH = 0;       //<< Horizontal stretch, favored toward top of ring. Set to 0 for a perfectly round ring.

EMBOSS_DIMENSIONS = true; //<< Set to true to stamp the dimensions onto the ring. Extremely helpful
                          //   if you're printing multiple iterations and could lose track.

FONT_SIZE = 3;
// Constants - Maybe don't mess with these except for fun.
POST_DIAM = 6.2 * TOLERANCE; //<< Diameter of the post (this fits the jailbird).
LOCK_HOLE_DIAM = 3.5 / TOLERANCE;
LOCK_HOLE_RAD = LOCK_HOLE_DIAM / 2;

RING_INNER_RAD = RING_INNER_DIAM / 2;
RING_RAD = RING_DIAM / 2;

module ring() {
  for (i = [0 : 1 : 360]) {
    translate([cos(i) * (RING_INNER_RAD + RING_RAD) + HOR_STRETCH * sin(i + 90) * cos(i + 90),
               sin(i) * (RING_INNER_RAD + RING_RAD), 
               -abs(sin(i) * sin(i)) * RING_DIP]) {
      sphere(d=RING_DIAM, $fn=40);
    }
  }
}

module post() {
  union() {
    // the actual lock post
    translate([0, -(RING_INNER_RAD + RING_RAD), 0])
    difference() {
        cylinder(h=POST_HEIGHT, d=POST_DIAM, $fn=50);
      // lock hole
      translate([0, 0, LOCK_HOLE_OFFSET + LOCK_HOLE_RAD])
      rotate([0, 90, 0])
      cylinder(h=POST_DIAM * 2, d=LOCK_HOLE_DIAM, center=true, $fn=50);
    }
    // connect it to the ring body
    translate([0, -(RING_INNER_RAD + RING_RAD), -(RING_DIP + 1)])
      cylinder(h=RING_DIP + 1, d=POST_DIAM, $fn=50);
  }
}

// put it all together
difference() {
  union() {
    ring();
    post();
  }
  if (EMBOSS_DIMENSIONS) {
    Offset = RING_INNER_RAD + RING_RAD;
    StartAngle = 180 + 36 / 2;
    translate([0, 0, RING_RAD * 0.8])
    rotate([0, 0, 180]) {
      translate([cos(StartAngle) * Offset, sin(StartAngle) * Offset, -abs(sin(StartAngle) * sin(StartAngle)) * RING_DIP])
        rotate([0, 0, tan(StartAngle) * 360 + 180])
        linear_extrude(10) 
        text(str(RING_INNER_DIAM, "D"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([cos(StartAngle + 36) * Offset, sin(StartAngle + 36) * Offset, -abs(sin(StartAngle + 36) * sin(StartAngle + 36)) * RING_DIP])
        rotate([0, 0, tan(StartAngle + 36) * 360 + 180])
        linear_extrude(10) 
        text(str(SPACING, "S"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([cos(StartAngle + 36 * 2) * Offset, sin(StartAngle + 36 * 2) * Offset, -abs(sin(StartAngle + 36 * 2) * sin(StartAngle + 36 * 2)) * RING_DIP])
        rotate([0, 0, 0])
        linear_extrude(10) 
        text(str(RING_DIAM, "R"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([cos(StartAngle + 36 * 3) * Offset, sin(StartAngle + 36 * 3) * Offset, -abs(sin(StartAngle + 36 * 3) * sin(StartAngle + 36 * 3)) * RING_DIP])
        rotate([0, 0, tan(StartAngle + 36 * 3) * 360 + 180])
        linear_extrude(10) 
        text(str(RING_DIP, "d"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
      translate([cos(StartAngle + 36 * 4) * Offset, sin(StartAngle + 36 * 4) * Offset, -abs(sin(StartAngle + 36 * 4) * sin(StartAngle + 36 * 4)) * RING_DIP])
        rotate([0, 0, tan(StartAngle + 36 * 4) * 360 + 180])
        linear_extrude(10) 
        text(str(LOCK_HOLE_OFFSET, "L"), FONT_SIZE, valign="center", halign="center", font = "Liberation Mono:style=bold");
    }
  }
}