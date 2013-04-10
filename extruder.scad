include <conf/config.scad>
use <gears.scad>

extruder_assembled();

module double_extruder() {
	rotate(-extruder_angle)
		extruder_assembled();

	translate([0, -60, 0])
		mirror(0, 1, 1)
			rotate(-extruder_angle)
				rotate(180)
					extruder_assembled();
}

module extruder_assembled () {
	extruder();

	translate([distance_between_gear_centers(), 0, -gear_thickness() - thick_wall - 1])
		rotate(extruder_angle) 
			NEMA(extruders_motor);

	// Outer bearing for hobbed bolt
	*translate([0, 0, ball_bearing_width(BB618) / 2])
		ball_bearing(BB618);

	// Inner bearing for hobbed bolt
	*translate([0, 0, -2 - ball_bearing_width(BB618) / 2])
		ball_bearing(BB618);

	// Hobbed bolt	
	translate([0, 0, 12])
		rotate(extruder_angle) 
			screw(M8_hex_screw, 30);

	// Nut holding hobbed bolt in place
	translate([0, 0, -11])
		rotate(extruder_angle) 
			nut(M8_half_nut);

	// Bearing holding filament in place
	rotate(extruder_angle) 
		translate([0, ball_bearing_diameter(BB618) / 2 + hobbed_bolt_radius + filament_diameter, -15])
			ball_bearing(BB618);
}

module extruder() {
	difference() {
		union() {
			*large_inner_gear();

			translate([distance_between_gear_centers(), 0, 0]) {
				pinion();
			}

			// Extruder body
			rotate(extruder_angle) 
				translate([0, 0, -1])
					cube([5 * thick_wall, 5 * thick_wall, 2 + 2 * ball_bearing_width(BB618)], center = true);
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
			translate([0, hobbed_bolt_radius + filament_diameter / 2, -15])
				rotate([0, 90, 0])
					#cylinder(r=filament_diameter / 2 + 0.1, h=100, center=true, $fn = smooth);
	}
}
