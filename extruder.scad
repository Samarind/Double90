include <conf/config.scad>
use <gears.scad>
use <624-press.scad>
use <vitamins/jhead_hot_end.scad>

filament_press_bearing = BB624PRINTEDPRESS;


// START_POINT

rotate(-extruder_angle)
	extruder_assembled();

// double_extruder();

*filament_holder_assembled();

module double_extruder() {
	translate([0, -26, 0])
		rotate([-90, 0, 0])
			rotate(-extruder_angle)
				extruder_assembled();
	
	mirror(0, 1, 1)
		rotate([90, 0, 0])
			rotate(-extruder_angle)
				rotate(180)
					extruder_assembled();
}

module extruder_assembled () {
	extruder();

	large_inner_gear();

	translate([distance_between_gear_centers(), 0, 0])
		pinion();

	// Hot end
	*rotate(extruder_angle)	
		translate([-30, hobbed_bolt_radius + filament_diameter / 2 - 1, -15])
			rotate([0, 90, 0])	{
				translate([-15, 0, -20])
				cylinder(r=2, h=57.9, center=true);
				jhead_hot_end(hot_end);}

	// Motor
	translate([distance_between_gear_centers(), 0, -gear_thickness() - thick_wall - 1])
		rotate(extruder_angle) 
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
		nut(M8_half_nut);

	// Filament holder
	rotate(extruder_angle) 
		translate([0, ball_bearing_diameter(BB618) / 2 + hobbed_bolt_radius + filament_diameter + ball_bearing_diameter(filament_press_bearing) / 6 - 1.5, -15])
			filament_holder_assembled();
}

module filament_holder_assembled() {
	filament_holder();

	// Outer nut
	translate([0, 0, 5])
		nut(M4_nut);
	
	// Bearing
	ball_bearing(filament_press_bearing);

	// Bearing axle
	translate([0, 0, -7.5])
		rotate([0, 180, 0])
			screw(M4_cap_screw, 15);
}

module filament_holder() {
	difference() {
		// Body
		translate([5, 0, 00])
			cube([35, ball_bearing_diameter(filament_press_bearing) * 3 / 4, 15], center = true);

		// Hole for outer nut
		translate([0, 0, 10])
			cylinder(r = nut_outer_radius(M4_nut) + 0.1, h = 10, center = true, $fn = 6);

		// Hole for bearing
		cylinder(r = ball_bearing_diameter(filament_press_bearing) / 2 + 1, h = ball_bearing_width(filament_press_bearing) + 0.2, center = true, $fn = smooth);
		translate([0, -(ball_bearing_diameter(filament_press_bearing) / 2 + 1) / 2 , 0])
			cube([ball_bearing_diameter(filament_press_bearing) + 2, ball_bearing_diameter(filament_press_bearing) + 2, ball_bearing_width(filament_press_bearing) + 0.2], center = true);

		// Hole for axle
		cylinder(r = screw_radius(M4_cap_screw) + 0.1, h = 50, center = true, $fn = smooth);

		// Cutout for motor
		translate([19.5, -22, -2.5])
			NEMA(extruders_motor);
	}
}

module extruder() {
	difference() {
		union() {
			// Extruder body
			translate([0, 0, -1])
				cylinder(r = 2.5 * thick_wall, h = 2 + 2 * ball_bearing_width(BB618), center = true, $fn = smooth);

			rotate(extruder_angle)
				translate([0, -(2.5 * thick_wall) / 2, -1 ]){
				hull() {
					cube([5 * thick_wall, 2.5 * thick_wall, 2 + 2 * ball_bearing_width(BB618)], center = true);
					translate([0, -18.3, -14 ])
						cube([5 * thick_wall, 2.5 * thick_wall,  2 * thick_wall], center = true);
					}
				}

			// Motor mounting plate
			translate([distance_between_gear_centers(), 0, -gear_thickness() - 1]) 	
				rotate(extruder_angle) 
					intersection() {	
						cube([NEMA_width(extruders_motor), NEMA_width(extruders_motor), 2 * thick_wall], center = true);
						translate([NEMA_width(extruders_motor) / 2 - 1, -NEMA_width(extruders_motor) / 2 , 0])
							cylinder(r = NEMA_width(extruders_motor), h = 2 * thick_wall, center = true, $fn = smooth);
					}

		}

		translate([distance_between_gear_centers(), 0, -gear_thickness() - thick_wall - 1])
				rotate(extruder_angle) {
					// Big motor hole
					poly_cylinder(r = NEMA_big_hole(extruders_motor), h = 20 + eta, center = true); 

					// Motor screw holes
					for (x = NEMA_holes(extruders_motor))                                                         
					    for (y = NEMA_holes(extruders_motor))
					        translate([x, y, thick_wall])
				                #poly_cylinder(r = M3_clearance_radius, h = 10, center = true);
				}

		//Hole for hobbed bolt
		poly_cylinder(r=hobbed_bolt_radius + 0.1, h=40, center=true);

		//Hole for outer bearing
		translate([0, 0, (ball_bearing_width(BB618) + 0.1) / 2])
			poly_cylinder(r=ball_bearing_diameter(BB618) / 2 + 0.1, h=ball_bearing_width(BB618) + 0.1, center=true);

		//Hole for inner bearing
		translate([0, 0, -2 - ball_bearing_width(BB618) / 2 - 6])
			poly_cylinder(r=ball_bearing_diameter(BB618) / 2 + 0.1, h=ball_bearing_width(BB618) + 0.1 + 12, center=true);

		//Hole for filament
		rotate(extruder_angle) 
			translate([0, hobbed_bolt_radius + filament_diameter / 2 - 1, -15])
				rotate([0, 90, 0])
					#cylinder(r = filament_diameter / 2 + 0.1, h = 100, center = true, $fn = smooth);
	}
}
