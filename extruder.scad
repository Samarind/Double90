include <conf/config.scad>
use <gears.scad>
use <624-press.scad>
use <vitamins/jhead_hot_end.scad>

// rotate(-extruder_angle)
// 	extruder_assembled();

double_extruder();

 // filament_holder_assembled();

module double_extruder() {
	translate([0, -60, 0])
		rotate(-extruder_angle)
			extruder_assembled();
	
	mirror(0, 1, 1)
		rotate(-extruder_angle)
			rotate(180)
				extruder_assembled();
}

module extruder_assembled () {
	extruder();

	translate([distance_between_gear_centers(), 0, -gear_thickness() - thick_wall - 1])
		rotate(extruder_angle) 
			// rotate(28) 
				NEMA(extruders_motor);

	// Outer bearing for hobbed bolt
	translate([0, 0, ball_bearing_width(BB618) / 2])
		ball_bearing(BB618);

	// Inner bearing for hobbed bolt
	translate([0, 0, -2 - ball_bearing_width(BB618) / 2])
		ball_bearing(BB618);

	// Hobbed bolt	
	translate([0, 0, 7])
		rotate(extruder_angle) 
			screw(M8_hex_screw, 25);

	// Nut holding hobbed bolt in place
	translate([0, 0, -11])
		rotate(extruder_angle) 
		rotate(extruder_angle+8) 
			nut(M8_half_nut);

	// Filament holder
	rotate(extruder_angle) 
		translate([0, ball_bearing_diameter(BB618) / 2 + hobbed_bolt_radius + filament_diameter + ball_bearing_diameter(BB624PRINTEDPRESS) / 6 - 1.5, -15])
			filament_holder_assembled();
}

module filament_holder_assembled() {
	filament_holder();

	// Outer nut
	translate([0, 0, 5])
		nut(M4_nut);
	
	// Bearing
	ball_bearing(BB624);
	624_press();

	translate([0, 0, -7.5])
		rotate([0, 180, 0])
			screw(M4_cap_screw, 15);
}

module filament_holder() {
	difference() {
		// Body
		cube([40, 15, 15], center = true);

		// Hole for outer nut
		translate([0, 0, 10])
			cylinder(r = nut_outer_radius(M4_nut) + 0.1, h = 10, center = true, $fn = 6);

		// Hole for bearing
		cylinder(r = ball_bearing_diameter(BB624PRINTEDPRESS) / 2 + 1, h = ball_bearing_width(BB624PRINTEDPRESS) + 0.2, center = true, $fn = smooth);
		translate([0, -(ball_bearing_diameter(BB624PRINTEDPRESS) / 2 + 1) / 2 , 0])
			cube([ball_bearing_diameter(BB624PRINTEDPRESS) + 2, ball_bearing_diameter(BB624PRINTEDPRESS) + 2, ball_bearing_width(BB624PRINTEDPRESS) + 0.2], center = true);

		// Hole for axle
		cylinder(r = screw_radius(M4_cap_screw) + 0.1, h = 50, center = true, $fn = smooth);

		// Cutout for motor
		translate([19, -8, -8])
			cube([44, 6, 11], center = true);
	}
}

module extruder() {
	difference() {
		union() {
			large_inner_gear();

			translate([distance_between_gear_centers(), 0, 0]) {
				pinion();
			}

			// Extruder body
			rotate(extruder_angle) 
				translate([0, 0, -1])
					cube([5 * thick_wall, 5 * thick_wall - 2, 2 + 2 * ball_bearing_width(BB618)], center = true);
		}
		//Hole for hobbed bolt
		poly_cylinder(r=hobbed_bolt_radius + 0.1, h=35, center=true);

		//Hole for outer bearing
		translate([0, 0, (ball_bearing_width(BB618) + 0.1) / 2])
			poly_cylinder(r=ball_bearing_diameter(BB618) / 2 + 0.1, h=ball_bearing_width(BB618) + 0.1, center=true);

		//Hole for inner bearing
		translate([0, 0, -2 - ball_bearing_width(BB618) / 2])
			poly_cylinder(r=ball_bearing_diameter(BB618) / 2 + 0.1, h=ball_bearing_width(BB618) + 0.1, center=true);

		//Hole for filament
		rotate(extruder_angle) 
			translate([30, hobbed_bolt_radius + filament_diameter / 2 - 1, -15])
				rotate([0, 90, 0])
					#cylinder(r=filament_diameter / 2 + 0.1, h=150, center=true, $fn = smooth);
	}
	rotate(extruder_angle)	
		translate([95, hobbed_bolt_radius + filament_diameter / 2 - 1, -15])
			rotate([0, -90, 0])	
				jhead_hot_end(hot_end);
}
