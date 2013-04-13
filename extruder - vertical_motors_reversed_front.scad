include <conf/config.scad>
use <gears.scad>

// rotate(-extruder_angle)
// 	extruder_assembled();

rotate([0, 90, 0])
double_extruder();

 // filament_holder_assembled();

module double_extruder() {
	rotate(-extruder_angle)
		extruder_assembled();
	
	translate([43, 0, -85.5])
		// mirror(0, 1, 1)
			rotate(extruder_angle)
				rotate(180)
					rotate([180, 0, 0])
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
		// rotate(extruder_angle) 
			screw(M8_hex_screw, 55);

	// Nut holding hobbed bolt in place
	translate([0, 0, -11])
		// rotate(extruder_angle) 
		*rotate(extruder_angle+8) 
			nut(M8_half_nut);

	*rotate(extruder_angle) 
		translate([0, ball_bearing_diameter(BB618) / 2 + hobbed_bolt_radius + filament_diameter - 1, -15])
			filament_holder_assembled();
}

module filament_holder_assembled() {
	filament_holder();

	// Outer nut
	translate([0, 0, 4])
		nut(M8_half_nut);
	
	// Bearing
	ball_bearing(BB618);

	translate([0, 0, -9.5])
		rotate([0, 180, 0])
			screw(M8_cap_screw, 20);
}

module filament_holder() {
	difference() {
		// Body
		translate([0, 3, 0])
			cube([20, 13, 18], center = true);

		// Hole for outer nut
		translate([0, 0, 4 + 5])
			cylinder(r = nut_outer_radius(M8_half_nut) + 0.1, h = 10, center = true, $fn = 6);

		// Hole for bearing
		cylinder(r = ball_bearing_diameter(BB618) / 2 + 1, h = ball_bearing_width(BB618) + 0.2, center = true, $fn = smooth);
		translate([0, -ball_bearing_diameter(BB618) / 2 - 1, 0])
			cube([ball_bearing_diameter(BB618) + 2, ball_bearing_diameter(BB618) + 2, ball_bearing_width(BB618) + 0.2], center = true);

		// Hole for axle
		cylinder(r = 4 + 0.1, h = 50, center = true, $fn = smooth);

		translate([9, -4, -8])
			rotate(-62) 
				cube([2, 35, 10], center = true);
	}
}

module extruder() {
	difference() {
		union() {
			large_inner_gear();

			translate([distance_between_gear_centers(), 0, 0]) 
				pinion();

			// Extruder body
			// rotate(extruder_angle) 
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
			translate([0, hobbed_bolt_radius + filament_diameter / 2 - 1, -50])
				rotate([0, 90, 0])
					#cylinder(r=filament_diameter / 2 + 0.1, h=200, center=true, $fn = smooth);
	}
}
