 // Planetary gear bearing (customizable)

// outer diameter of ring
outer_diameter = 40;

// thickness
thickness = 10;

// clearance
tol = 0.15;

number_of_planets = 1;
number_of_teeth_on_planets = 9;
approximate_number_of_teeth_on_sun = 9;

// pressure angle
alpha = 30; // [30 : 60]

 // number of teeth to twist across
nthicknesswist = 1;

 // width of hexagonal hole
w = 0.1;//6.7;

DR = 0.5 * 1; // maximum depth ratio of teeth

m = 1;//round(number_of_planets);

k1 = round(2 / (approximate_number_of_teeth_on_sun + number_of_teeth_on_planets));
echo(str("k1 = ", k1));

k = k1 * m%2 != 0 ? k1 + 1 : k1;
echo(str("k = ", k));

ns = k / 2 - number_of_teeth_on_planets;
echo(str("ns = ", ns));

number_of_teeth = 47;//ns + 2 * number_of_teeth_on_planets;

pitch_diameter = 0.9 * outer_diameter / (1 + min(PI / (2 * number_of_teeth * tan(alpha)), PI * DR / number_of_teeth));
echo(str("pitch_diameter = ", pitch_diameter));

circular_pitch = PI * pitch_diameter / number_of_teeth;
echo(str("circular_pitch = ", circular_pitch));
echo(str("diametral_pitch1 = ", number_of_teeth / pitch_diameter));
echo(str("diametral_pitch2 = ", circular_pitch * number_of_teeth_on_planets / PI));
echo(str("module = ", pitch_diameter / number_of_teeth));

helix_angle = atan(2 * nthicknesswist * circular_pitch / thickness);
echo(str("helix_angle = ", helix_angle));

phi = $t * 360;

translate([0, 0, thickness / 2]) { 
	difference() { 
		cylinder(r = outer_diameter / 2, h = thickness, center = true, $fn = 100);
		herringbone(number_of_teeth, circular_pitch, alpha, DR, -tol, helix_angle, thickness + 0.2);
	}

	herringbone(number_of_teeth_on_planets, circular_pitch, alpha, DR, tol, helix_angle, thickness);


	// rotate([0, 0, (number_of_teeth_on_planets + 1) * 180 / ns + phi * (ns + number_of_teeth_on_planets) * 2 / ns])
	// difference() { 
	// 	mirror([0, 1, 0])
	// 		herringbone(ns, circular_pitch, alpha, DR, tol, helix_angle, thickness);
	// 	cylinder(r = w / sqrt(3), h = thickness + 1, center = true, $fn = 6);
	// }

}






module herringbone(number_of_teeth = 15, 
					circular_pitch = 10, 
					pressure_angle = 28, 
					depth_ratio = 1, 
					clearance = 0, 
					helix_angle = 0, 
					gear_thickness = 5) { 
union() { 
	gear(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness / 2);
	
	mirror([0, 0, 1])
		gear(number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance, helix_angle, gear_thickness / 2);
}}


module gear(number_of_teeth = 15, 
			circular_pitch = 10, 
			pressure_angle = 28, 
			depth_ratio = 1, 
			clearance = 0, 
			helix_angle = 0, 
			gear_thickness = 5, 
			flat = false) { 

pitch_radius = number_of_teeth * circular_pitch / (2 * PI);
twist = tan(helix_angle) * gear_thickness / pitch_radius * 180 / PI;

flat_extrude(h = gear_thickness, twist = twist, flat = flat)
	gear2D (number_of_teeth, circular_pitch, pressure_angle, depth_ratio, clearance);
}

module flat_extrude(h, twist, flat) { 
	if(flat == false)
		linear_extrude(height = h, twist = twist, slices = twist / 6)
			child(0);
	else
		child(0);
}

module gear2D (number_of_teeth, 
				circular_pitch, 
				pressure_angle, 
				depth_ratio, 
				clearance) {

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
 // source : http : // www.mathhelpforum.com / geometry / 136011 - circle - involute - solving - y - any - given - x.html
function involute_intersect_angle (base_radius, radius) = sqrt (pow (radius / base_radius, 2) - 1) * 180 / PI;

 // Calculate the involute position for a given base radius and involute angle.
function involute (base_radius, involute_angle) = 
[
	base_radius * (cos (involute_angle) + involute_angle * PI / 180 * sin (involute_angle)), 
	base_radius * (sin (involute_angle) - involute_angle * PI / 180 * cos (involute_angle))
];
