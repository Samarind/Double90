include <conf/config.scad>
use <gears.scad>

extruder_assembled();

angle = 22;

module double_extruder() {
	rotate(-angle)
		extruder_assembled();

	translate([0, -60, 0])
		mirror(0, 1, 1)
			rotate(-angle)
				rotate(180)
					extruder_assembled();
}

module extruder_assembled () {
	large_inner_gear();

	// Outer bearing for hobbed bolt
	translate([0, 0, 2.5])
		ball_bearing(BB618);

	// Inner bearing for hobbed bolt
	translate([0, 0, -4.5])
		ball_bearing(BB618);

	// Hobbed bolt	
	translate([0, 0, 12])
		screw(M8_hex_screw, 30);

	// Nut holding hobbed bolt in place
	translate([0, 0, -11])
		nut(M8_half_nut);
	
	translate([distance_between_gear_centers(), 0, 0]) {
		pinion();

		translate([0, 0, -gear_thickness() - thick_wall - 1])
			rotate(angle) 
				NEMA(extruders_motor);
	}
}
