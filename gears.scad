include <conf/config.scad>

// Outer diameter of bigger (internal) gear
outer_diameter = 60;

// Thickness of gears
thickness = 10;

// Clearance (backlash)
clearance = 0.1;

// Pressure angle
alpha = 30; 

// Number of teeth to twist across
nthicknesswist = 0.8;

// // Motor shaft hole radius
// hole_radius = 2.6;

// Maximum depth ratio of teeth
DR = 0.5; 

pitch_diameter_of_inner_gear = 0.90 * outer_diameter / (1 + min(PI / (2 * number_of_teeth_on_inner_gear * tan(alpha)), PI * DR / number_of_teeth_on_inner_gear, 2 * cos(alpha) / number_of_teeth_on_inner_gear));
circular_pitch = PI * pitch_diameter_of_inner_gear / number_of_teeth_on_inner_gear;
pitch_diameter_of_pinion = circular_pitch * number_of_teeth_on_pinion / PI;
base_diameter_of_pinion = pitch_diameter_of_pinion * cos(alpha);
// echo(str("circular pitch = ", circular_pitch));
// echo(str("diametral pitch = ", number_of_teeth_on_inner_gear / pitch_diameter_of_inner_gear));
// echo(str("module = ", pitch_diameter_of_inner_gear / number_of_teeth_on_inner_gear));
// echo(str("pitch diameter of pinion = ", circular_pitch * number_of_teeth_on_pinion / PI));

helix_angle = atan(2 * nthicknesswist * circular_pitch / thickness);
// echo(str("helix_angle = ", helix_angle));

function distance_between_gear_centers() = pitch_diameter_of_inner_gear / 2 - (circular_pitch * number_of_teeth_on_pinion / PI) / 2;
function gear_thickness() = thickness + thick_wall;

pinion();

module pinion() {
	difference() { 
		union() {
			herringbone(number_of_teeth_on_pinion, circular_pitch, alpha, DR, clearance, helix_angle, thickness);
			translate([0, 0, -thickness / 2 - 1 / 2])
				cylinder(r = base_diameter_of_pinion / 2 - 0.5, h = 1, center = true, $fn = smooth);
			translate([0, 0, -thickness / 2 - 1 - 6 / 2])
				cylinder(r2 = base_diameter_of_pinion / 2 - 0.5, r1 = 7, h = 6, center = true, $fn = smooth);
			translate([0, 0, -thickness / 2 - 1 - 6 - 5 / 2])
				cylinder(r = 7, h = 5, center = true, $fn = smooth);
		}

		// Screw securing pinion on motor shaft
		translate([0, 4, - NEMA_shaft_length(extruders_motor) + NEMA_boss(extruders_motor) + thickness / 2 + 5 / 2]) {
			cube(size=[nut_outer_radius(M3_nut) * 2 + 1, nut_depth(M3_nut) + 0.225, nut_outer_radius(M3_nut) * 2 + 0.5], center=true);
			translate([0, 0, 0.5])
				rotate([90, 0, 0]) {
					poly_cylinder(r = 1.5, h = 11, center = true, $fn = smooth);
			}
			
		}
		cylinder(r = NEMA_shaft_radius(extruders_motor), h = 50, center = true, $fn = smooth);
	}

	// Nut
	translate([0, 4 + 1.2, - NEMA_shaft_length(extruders_motor) + NEMA_boss(extruders_motor) + thickness / 2 + 5 / 2 + 0.5]) {
		translate([0, 1.5, 0])
			rotate([270, 0, 0])
				screw(M3_grub_screw, 4);
		rotate([90, 0, 0])
			nut(M3_nut);	
	}
}



module large_inner_gear() {
	// Gear ring
	difference() { 
		cylinder(r = outer_diameter / 2, h = thickness + 1, center = true, $fn = smooth);
		herringbone(number_of_teeth_on_inner_gear, circular_pitch, alpha, DR, -clearance, helix_angle, thickness + 1 + eta);
	}

	// Gear body
	difference() { 
		translate([0, 0, (thickness + 1) / 2 + thick_wall / 2]) {
			difference() { 
				cylinder(r = outer_diameter / 2, h = thick_wall, center = true, $fn = smooth);
				poly_cylinder(r = outer_diameter / 2 - thick_wall, h = thick_wall + 1, center = true, $fn = smooth);
			}

			for (angle = [0, 45, 90, 135, 180, 225, 270, 315]) {
				rotate(angle)
					cube([thick_wall, outer_diameter - 1, thick_wall], center = true);
			}

			// Central piece that holds hobbed bolt's head
			cylinder(r = hobbed_bolt_radius + 2 * thick_wall, h = thick_wall, center = true, $fn = smooth);
		}
		
		// Hole for hobbed bolt
		poly_cylinder(r = hobbed_bolt_radius, h = 50, center=true, $fn = smooth);

		// Hole for hobbed bolt's head
		rotate(extruder_angle)
			translate([0, 0, (thickness + 1) / 2 + thick_wall / 2 + 2.5])
				cylinder(r = hobbed_bolt_head_radius, h = 6, center=true, $fn = 6);
	}
}











module herringbone(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness) { 
	union() { 
		gear(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness / 2);
		
		mirror([0, 0, 1])
			gear(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness / 2);
	}
}


module gear(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness) { 

	pitch_radius = number_of_teeth * circular_pitch / (2 * PI);
	twist = tan(helix_angle) * gear_thickness / pitch_radius * 180 / PI;

	linear_extrude(height = gear_thickness, twist = twist, slices = twist / 6)
		gear2D (number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance);
}


module gear2D (number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance) {
	pitch_radius = number_of_teeth * circular_pitch / (2 * PI);
	base_radius = pitch_radius * cos(pressure_angle);
	depth = circular_pitch / (2 * tan(pressure_angle));
	outer_radius = clearance<0 ? pitch_radius + depth / 2 - clearance : pitch_radius + depth / 2;
	root_radius1 = pitch_radius - depth / 2 - clearance / 2;
	root_radius = (clearance<0 && root_radius1<base_radius) ? base_radius : root_radius1;
	backlash_angle = clearance / (pitch_radius * cos(pressure_angle)) * 180 / PI;
	half_thick_angle = 90 / number_of_teeth - backlash_angle / 2;
	pitch_point = involute (base_radius, involute_intersect_angle (base_radius, pitch_radius));
	pitch_angle = atan2 (pitch_point[1], pitch_point[0]);
	min_radius = max (base_radius, root_radius);

	intersection() { 
		rotate(90 / number_of_teeth)
			circle($fn = number_of_teeth * 3, r = pitch_radius + depth_ratio * circular_pitch / 2 - clearance / 2);
		
		union() { 
			rotate(90 / number_of_teeth)
				circle($fn = number_of_teeth * 2, r = max(root_radius, pitch_radius - depth_ratio * circular_pitch / 2 - clearance / 2));

			for (i = [1 : number_of_teeth])
				rotate(i * 360 / number_of_teeth) { 
					halftooth (pitch_angle, base_radius, min_radius, outer_radius, half_thick_angle);		
					mirror([0, 1])
						halftooth (pitch_angle, base_radius, min_radius, outer_radius, half_thick_angle);
				}
		}
	}
}

module halftooth(pitch_angle, base_radius, min_radius, outer_radius, half_thick_angle) { 
	index = [0, 1, 2, 3, 4, 5];
	start_angle = max(involute_intersect_angle(base_radius, min_radius) - 5, 0);
	stop_angle = involute_intersect_angle(base_radius, outer_radius);
	angle = index * (stop_angle - start_angle) / index[len(index) - 1];
	p = [[0, 0], 
		involute(base_radius, angle[0] + start_angle), 
		involute(base_radius, angle[1] + start_angle), 
		involute(base_radius, angle[2] + start_angle), 
		involute(base_radius, angle[3] + start_angle), 
		involute(base_radius, angle[4] + start_angle), 
		involute(base_radius, angle[5] + start_angle)];

	difference() { 
		rotate( - pitch_angle - half_thick_angle)
			polygon(points = p);
		square(2 * outer_radius);
	}
}

 // Mathematical Functions
 // == == == == == == == = 

 // Finds the angle of the involute about the base radius at the given distance (radius) from it's center.
 // source : http://www.mathhelpforum.com/geometry/136011-circle-involute-solving-y-any-given-x.html
function involute_intersect_angle(base_radius, radius) = sqrt(pow(radius / base_radius, 2) - 1) * 180 / PI;

 // Calculate the involute position for a given base radius and involute angle.
function involute(base_radius, involute_angle) = [base_radius * (cos(involute_angle) + involute_angle * PI / 180 * sin(involute_angle)), 
												  base_radius * (sin(involute_angle) - involute_angle * PI / 180 * cos(involute_angle))];
