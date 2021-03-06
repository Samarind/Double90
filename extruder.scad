include <conf/config.scad>
use <gears.scad>
use <vitamins/jhead_hot_end.scad>
use <vitamins/washers.scad>
use <vitamins/springs.scad>
use <x-plate-for-dual-extruder.scad>;

filament_press_bearing = BB624PRINTEDPRESS;


*rotate(-extruder_angle)
	extruder_assembled();

// dual_extruder();

dual_extruder_assembled();

// filament_holder_assembled();

module dual_extruder_assembled() {
	translate([-58.8, -16.5, 51])
		rotate([90, 0, 90])
        	x_plate_for_dual_extruder();

	dual_extruder();
}

module dual_extruder() {
	difference() {
		// Plate to fix to x-carriage
		translate([1, -16.5, 30.3])
			cube(size=[80, 71, thick_wall], center=true);

		// Cutouts in plate for big extruder gears
		translate([0, -17.5, 0]) {
        	rotate([0, 90, 90])
           		poly_cylinder(r = inner_gear_outer_diameter / 2 + 0.2, h = 15.5*2 + 16, $fn = smooth, center = true);
		}
	}

	translate([0, -33, 0])
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

	*translate([distance_between_gear_centers(), 0, 0])
		pinion();

	// Filament holder
	rotate(extruder_angle) 
		translate([0, hobbed_bolt_radius - 1.5 + filament_diameter + ball_bearing_diameter(filament_press_bearing) / 2, -15])
			filament_holder_assembled();

	// Motor
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
	*translate([0, 0, 7])
		rotate(extruder_angle) 
			screw(M8_hex_screw, 25);

	// Nut holding hobbed bolt in place
	*rotate(90 + extruder_angle)
		translate([0, 0, -11])
			nut(M8_half_nut);

	// Hot end
	rotate(extruder_angle)	
		translate([-35, hobbed_bolt_radius + filament_diameter / 2 - 1, -15])
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

				// Some free space for hobbed bolt nut
				rotate(extruder_angle)	
					translate([0, 0, -(2 + 2 * ball_bearing_width(BB618)) / 1 - 1])
						cube([2 * (ball_bearing_diameter(BB618) / 2 + default_wall + 1), 13, 2 + 2 * ball_bearing_width(BB618)], center = true);
			}

			// Motor mounting plate
			translate([distance_between_gear_centers(), 0, -gear_thickness() - 1]) 	
				rotate(extruder_angle) 
					intersection() {	
						translate([0, 1.5, 0])
						cube([NEMA_width(extruders_motor), NEMA_width(extruders_motor) + 3, 2 * thick_wall], center = true);
						translate([NEMA_width(extruders_motor) / 2 , -NEMA_width(extruders_motor) / 2 + 6, 0])
							cylinder(r = NEMA_width(extruders_motor), h = 2 * thick_wall, center = true, $fn = smooth);
					}

			// Hinge
			rotate(extruder_angle) 
				translate([-16, -23.4, -gear_thickness() - 1]) {	
					cube([10, 10, 2 * thick_wall], center = true);
					translate([-5, 0, -2.5]) 
						cube([10, 16.9, ball_bearing_width(filament_press_bearing)]);
				}
		}

		// Hole for screw pushing filament holder against extruder
		translate([distance_between_gear_centers() - 0.8, 22, -gear_thickness() - 1]) 	
			rotate(extruder_angle) {
				translate([2.5, -3, 0])
					cylinder(r = nut_outer_radius(M3_nut), h = 2 * thick_wall + eta, center = true, $fn = smooth);
				rotate([-43, 90, 90])  
					cylinder(r = screw_radius(M3_cap_screw) + 0.1, h = 10, center = true, $fn = smooth);
				}

		// Hole for hinge axle
		rotate(extruder_angle) 
			translate([-16.5, -23.4 + 11.4, -gear_thickness() - 1])
				cylinder(r = screw_radius(M4_cap_screw) + 0.1, h = 20 + eta, center = true, $fn = smooth);


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
		poly_cylinder(r = hobbed_bolt_radius + 0.5, h=40, center=true);

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
			screw(M4_cap_screw, 20);

	// Hinge axle	
	translate([- 31 / 2 -1, - 40 + 20 / 2, 7.5])
		screw(M4_cap_screw, 20);
	translate([- 31 / 2 -1, - 40 + 20 / 2, -11])
		nut(M4_nut);

	// Screw that pushes holder against the extruder
	translate([distance_between_gear_centers() - 3.1, 5, 0]) 	
		rotate([-43, 90, 90]) { 
			translate([0, 0, 11]) {
					screw(M3_cap_screw, 30);
					translate([0, 0, -0.6])
						washer(M3_washer);
					translate([0, 0, -13])
						comp_spring(extruder_spring, l = 12);
				}
			
		}
}

module filament_holder() {
	length = 31;
	width = 15;
	lever = 40;
	hinge_radius = 5;
	thickness = 4 * hinge_radius;

	difference() {
		union() {
			// Body
			translate([4 - 1, 0, 0])
				cube([length - 2, thickness, width], center = true);

			// Round top
			hull() {
				translate([17, 2.7, 0])
					cylinder(r = 7.4, h = width, center = true, $fn = smooth);

				translate([35, 7, 0])
					cylinder(r = 3, h = width, center = true, $fn = smooth);
			}

			// Lever
			translate([- length / 2 - 6 + hinge_radius, thickness / 2 - lever / 2 - hinge_radius, 0])
				cube([2 * hinge_radius, lever - 2 * hinge_radius, width], center = true);
			
			// Hinge
			translate([- length / 2 - 6 + hinge_radius, - lever + thickness / 2, 0])
				cylinder(r = hinge_radius, h = width, center = true, $fn = smooth);

			// Round bottom
			translate([- length / 2 - 6 + 2 * hinge_radius, 0, 0])
				cylinder(r = 2 * hinge_radius, h = width, center = true, $fn = smooth);
		}
		// Cutout on the top to form a handle
		translate([26.5, 28.2, 0])
			cylinder(r = 20, h = width + 1, center = true, $fn = smooth);

		// Hole for screw pushing against the extruder
		translate([distance_between_gear_centers() - 3.1, 5, 0]) 	
			rotate([-43, 90, 90]) { 
				cylinder(r = screw_radius(M3_cap_screw) + 0.1, h = 20, center = true, $fn = smooth);
				
				translate([0, -10, 5])
					rotate([90, 0, 0])
						cube([7.5, 15, 6 + 20], center = true);
			}

		// Cutout for extruder
		translate([40, -40, 0])
			cylinder(r = NEMA_width(extruders_motor), h = width + 1, center = true, $fn = smooth);

		// Hole for nut
		translate([0, 0, 10])
			cylinder(r = nut_outer_radius(M4_nut) + 0.1, h = 10, center = true, $fn = 6);

		// Hole for bearing
		cylinder(r = ball_bearing_diameter(filament_press_bearing) / 2 + 0.5, h = ball_bearing_width(filament_press_bearing) + 0.2, center = true, $fn = smooth);
		translate([0, -(ball_bearing_diameter(filament_press_bearing) / 2 + 1) / 2, 0])
			cube([ball_bearing_diameter(filament_press_bearing) + 1, ball_bearing_diameter(filament_press_bearing) / 2 + 1, ball_bearing_width(filament_press_bearing) + 0.2], center = true);

		// Slit in the lever
		translate([- length / 2 - 6 + hinge_radius,  - lever / 2, 0])
			cube([2 * hinge_radius + eta, lever, ball_bearing_width(filament_press_bearing) + 0.2], center = true);

		// Hole for axle
		cylinder(r = screw_radius(M4_cap_screw) + 0.1, h = 50, center = true, $fn = smooth);

		// Cutout for motor
		translate([length / 2 + 2, -thickness / 2 + 1.5, - width / 2 + (width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1) / 2])
			cube([length, thickness / 2 + 0.5, width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1 + eta], center = true);
		translate([screw_head_radius(M3_cap_screw) , -thickness / 2 + 1, - width / 2 + (width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1) / 2])
			cylinder(r = (thickness / 2 + 0.5) / 2 + 0.5, h = width / 2 - ball_bearing_width(filament_press_bearing) / 2 - 1 + eta, center = true, $fn = smooth);

		// Hole for hinge axle
		translate([- length / 2 + hinge_radius - 6, - lever + thickness / 2, 0])
			cylinder(r = screw_radius(M4_cap_screw) + 0.1, h = width + eta, center = true, $fn = smooth);
	}
}
