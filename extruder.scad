include <conf/config.scad>
use <gears.scad>
use <624-press.scad>
use <vitamins/jhead_hot_end.scad>
use <x-plate-for-dual-extruder.scad>;

filament_press_bearing = BB624PRINTEDPRESS;


*rotate(-extruder_angle)
	extruder_assembled();

dual_extruder();

// dual_extruder_assembled();

// 	filament_holder_assembled();

module dual_extruder_assembled() {
	translate([-58.8, -17, 51])
		rotate([90, 0, 90])
        	x_plate_for_dual_extruder();

	dual_extruder();
}

module dual_extruder() {
	difference() {
		// Plate to fix to x-carriage
		translate([1, -17.5, 30.3])
			cube(size=[80, 73, thick_wall], center=true);

		translate([0, -17.5, 0]) {
	        translate([0, 15.5, 0])
	        	rotate([0, 90, 90])
	           		poly_cylinder(r = inner_gear_outer_diameter / 2 + 0.2, h = 16, $fn = smooth, center = true);

	        translate([0, -15.5, 0])
	        	rotate([0, 90, 90])
	           		poly_cylinder(r = inner_gear_outer_diameter / 2 + 0.2, h = 16, $fn = smooth, center = true);
		}
	}

	translate([0, -35, 0])
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

	*large_inner_gear();

	*translate([distance_between_gear_centers(), 0, 0])
		pinion();

	// Filament holder
	rotate(extruder_angle) 
		translate([0, hobbed_bolt_radius - 1.5 + filament_diameter + ball_bearing_diameter(filament_press_bearing) / 2, -15])
			filament_holder_assembled();

	// Motor
	*translate([distance_between_gear_centers(), 0, -gear_thickness() - thick_wall - 1])
		rotate(extruder_angle) 
			NEMA(extruders_motor);

	// Outer bearing for hobbed bolt
	*translate([0, 0, ball_bearing_width(BB618) / 2])
		ball_bearing(BB618);

	// Inner bearing for hobbed bolt
	*translate([0, 0, -2 - ball_bearing_width(BB618) / 2])
		ball_bearing(BB618);

	// Hobbed bolt	
	translate([0, 0, 7])
		rotate(extruder_angle) 
			screw(M8_hex_screw, 25);

	// Nut holding hobbed bolt in place
	rotate(90 + extruder_angle)
		translate([0, 0, -11])
			nut(M8_half_nut);

	// Hot end
	*rotate(extruder_angle)	
		translate([-25, hobbed_bolt_radius + filament_diameter / 2 - 1, -15])
			rotate([0, 90, 0])	{
				jhead_hot_end(hot_end);}
}

module extruder() {
	difference() {
		union() {
			difference() {
				// Holder of the hobbed bolt
				rotate(extruder_angle) {
					translate([0, 0, -1])
						cylinder(r = ball_bearing_diameter(BB618) / 2 + default_wall, h = 2 + 2 * ball_bearing_width(BB618), center = true, $fn = smooth);

					translate([0, -(2 * (ball_bearing_diameter(BB618) / 2 + default_wall)) / 4, -1 ]) {
						hull() {
							cube([2 * (ball_bearing_diameter(BB618) / 2 + default_wall), (ball_bearing_diameter(BB618) / 2 + default_wall), 2 + 2 * ball_bearing_width(BB618)], center = true);
							translate([0, -11.9, -14 ])
								cube([2 * (ball_bearing_diameter(BB618) / 2 + default_wall), 2 * (ball_bearing_diameter(BB618) / 2 + default_wall),  2 * thick_wall], center = true);
							}
					}
				}

				rotate(extruder_angle)	
					translate([0, 0, -(2 + 2 * ball_bearing_width(BB618)) / 1 - 1])
						cube([2 * (ball_bearing_diameter(BB618) / 2 + default_wall + 1), 13, 2 + 2 * ball_bearing_width(BB618)], center = true);
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

		translate([distance_between_gear_centers(), 0, -gear_thickness() - 1])
				rotate(extruder_angle) {
					// Big motor hole
					translate([0, 0, -2 * thick_wall + 2.4])
						poly_cylinder(r = NEMA_big_hole(extruders_motor), h = 2 * thick_wall + eta, center = true); 
					// Hole for pinion
					poly_cylinder(r = pinion_diameter() / 2 + 1, h = 2 * thick_wall + eta, center = true); 		

					// Motor screw holes
					for (x = NEMA_holes(extruders_motor))                                                         
					    for (y = NEMA_holes(extruders_motor))
					        translate([x, y, 0])
				                poly_cylinder(r = M3_clearance_radius, h = 2 * thick_wall + eta, center = true);

	                translate([NEMA_holes(extruders_motor)[0], NEMA_holes(extruders_motor)[0], thick_wall])
	                	poly_cylinder(r = screw_head_radius(M3_cap_screw), h = 2 * thick_wall + eta);
				}

		// Cutout for fitting hobbed bolt in place
		rotate(extruder_angle)	
			translate([0, 2.5 * thick_wall, -1])
				cube([(hobbed_bolt_radius + 0.1) * 2, (2.5 * thick_wall) * 2, 2 + 2 * ball_bearing_width(BB618) + eta], center = true);

		//Hole for hobbed bolt
		poly_cylinder(r = hobbed_bolt_radius + 1, h=40, center=true);

		//Hole for outer bearing
		translate([0, 0, (ball_bearing_width(BB618) + 0.1) / 2])
			poly_cylinder(r = ball_bearing_diameter(BB618) / 2 + 0.1, h = ball_bearing_width(BB618) + 0.1, center=true);

		//Hole for inner bearing
		translate([0, 0, -2 - ball_bearing_width(BB618) / 2 - ball_bearing_width(BB618) / 2 - 0.5])
			poly_cylinder(r = ball_bearing_diameter(BB618) / 2 + 0.1, h = ball_bearing_width(BB618) * 2 + 1, center=true);

		//Hole for filament
		#rotate(extruder_angle) 
			translate([0, hobbed_bolt_radius + filament_diameter / 2 - 1, -15])
				rotate([0, 90, 0])
					cylinder(r = filament_diameter / 2 + 0.2, h = 100, center = true, $fn = smooth);
	}
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
	length = 30;
	width = 15;
	thickness = ball_bearing_diameter(filament_press_bearing) * 3 / 4;

	difference() {
		union() {
			// Body
			translate([5, 0, 0])
				cube([length, thickness, width], center = true);

			
		}

		// Hole for nut
		translate([0, 0, 10])
			cylinder(r = nut_outer_radius(M4_nut) + 0.1, h = 10, center = true, $fn = 6);

		// Hole for bearing
		cylinder(r = ball_bearing_diameter(filament_press_bearing) / 2 + 1, h = ball_bearing_width(filament_press_bearing) + 0.2, center = true, $fn = smooth);
		translate([0, -(ball_bearing_diameter(filament_press_bearing) / 2 + 1) / 2 , 0])
			cube([ball_bearing_diameter(filament_press_bearing) + 2, ball_bearing_diameter(filament_press_bearing) + 2, ball_bearing_width(filament_press_bearing) + 0.2], center = true);

		// Hole for axle
		cylinder(r = screw_radius(M4_cap_screw) + 0.1, h = 50, center = true, $fn = smooth);

		// Cutout for motor
		translate([length / 2 + 3, -thickness / 2 + 1, - width / 2 + (width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1) / 2])
			cube([length, thickness / 2 + 0.5, width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1 + eta], center = true);
		translate([screw_head_radius(M3_cap_screw) + 1, -thickness / 2, - width / 2 + (width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1) / 2])
			cylinder(r = 2 * screw_head_radius(M3_cap_screw) + 0.5, h = width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1 + eta, center = true, $fn = smooth);
	}
}
