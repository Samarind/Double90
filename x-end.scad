// End of the X axis
include <conf/config.scad>;

rounded_corner_radius = 6;

wall = thick_wall; 

Z_bearing_holder_wall = 2.5;
Z_bearing_outer_diameter = Z_bearings[1] + 0.2;
Z_bearing_holder_width = Z_bearing_outer_diameter + 2 * Z_bearing_holder_wall;
Z_bearing_depth = Z_bearing_holder_width / 2;
Z_bearing_length = Z_bearings[0];

shelf_thickness = 2;
shelf_clearance = 0.2; // distance between top of bearing and a shelf
shelf_depth = Z_bearing_depth - (Z_smooth_rod_diameter / 2 + 1);

Z_bearings_holder_height = max( min(65, 2.8 * Z_bearing_length), 2 * (Z_bearing_length + shelf_clearance) + 3 * shelf_thickness);

anti_backlash_wall_radius = Z_nut_radius + 0.2;
anti_backlash_wall_width = max(3, Z_bearing_holder_width / 2 - wall - cos(30) * anti_backlash_wall_radius + 0.5);
anti_backlash_wall_height = nut_thickness(Z_nut);

base_thickness = nut_depth(Z_nut) + 2 * wall;
clamp_length = z_bar_spacing();
clamp_width = X_smooth_rod_diameter + 2 * wall;
slit = 1;


shelves_Z_coordinate = [ shelf_thickness / 2, // shelve at the bottom
            shelf_thickness + Z_bearing_length + shelf_clearance + shelf_thickness / 2, // shelve at the top of bottom bearing
            Z_bearings_holder_height - shelf_thickness / 2, // shelve at the bottom of top bearing
            Z_bearings_holder_height - (shelf_thickness + Z_bearing_length + shelf_clearance + shelf_thickness / 2) ]; // shelve at the top


module x_end_bracket() {
        // Shelves for bearings
        intersection() {
            for(z = shelves_Z_coordinate) {
                translate([-Z_bearing_depth + shelf_depth / 2, 0, z])
                    cube([shelf_depth, Z_bearing_outer_diameter, shelf_thickness], center = true);
            }
            cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2, $fn = smooth);
        }

        difference() {
            union() {
                // X rods holders vertical block
                translate([-clamp_length / 2 , X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, (x_bar_spacing() + clamp_width) / 2]) {
                    difference() {
                        cube([clamp_length, clamp_width, x_bar_spacing() + wall], center = true);
                        translate([0, 0, -X_smooth_rod_diameter / 2 + wall / 2])
                            cube([clamp_length + eta, X_smooth_rod_diameter - wall, x_bar_spacing() - clamp_width], center = true); 
                        translate([0, 0, (x_bar_spacing() - 1.5 * clamp_width) / 2])
                            rotate([90, 0, 90])  
                                teardrop(h = clamp_length + eta, r = (X_smooth_rod_diameter - wall) / 2, truncate=false, $fn = smooth, center = true);  
                    }
                    // Spectra line stabilizer
                    *translate([wall, 0, - X_smooth_rod_diameter / 2])
                        difference() {
                            cube([2, clamp_width, x_bar_spacing() / 2 + wall], center = true);
                            cube([2 * 2, slit, x_bar_spacing() / 2 + wall], center = true);
                        }
                }

                // Z nut holder
                if (is_hex(Z_nut)) {
                    translate([-z_bar_spacing(), 0, anti_backlash_wall_height / 2])
                       rotate([0, 0, 90])                    
                            cylinder(r = anti_backlash_wall_radius + anti_backlash_wall_width, h = anti_backlash_wall_height, $fn = 6, center = true);
                } else if (is_flanged(Z_nut)) {
                } else { 
                    translate([-z_bar_spacing(), 0, (base_thickness- wall ) / 2])
                        cylinder(h = base_thickness- wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                    translate([-z_bar_spacing() + Z_nut_radius + z_bar_spacing() / 4 + wall / 2, 0, base_thickness / 2])
                        cube([z_bar_spacing() / 2 + wall, Z_bearing_holder_width, base_thickness], center = true);

                    translate([-z_bar_spacing(), 0, base_thickness - wall / 2]) {
                        rotate ([0, 0, 90]) {
                            intersection() {
                                cylinder(h = wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                                union() {
                                    // Right thin bar
                                    translate([-Z_screw_diameter / 2 - (wall - 1) / 2 - 0.5, 0, 0])
                                        cube([wall - 0.5, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    // Left thicker cover
                                    translate([Z_screw_diameter / 2 + wall + 0.5, 0, 0])
                                        cube([wall * 2, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    difference() {
                                        cylinder(h = wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                                        cylinder(h = wall + eta, r = Z_nut_radius, $fn = smooth, center = true);
                                        translate([-Z_screw_diameter / 2 - (wall * 3) / 2 - 0.5, 0, 0])
                                            cube([wall * 3, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    }
                                }
                            }
                        }
                    }

                    // Large triangles
                    for (y = [Z_nut_radius - wall + 0.5 / 2, -Z_nut_radius + wall]) {
                        translate([(-z_bar_spacing() + Z_screw_diameter / 2 + 1.5 * wall) / 2, y, base_thickness]) 
                            rotate([90, 0, 180]) 
                                right_triangle(width = z_bar_spacing(),  height = Z_bearings_holder_height - base_thickness, h = wall - 0.5, center = true);
                    }

                    // Bottom connection 
                    translate([-z_bar_spacing() + Z_nut_radius - wall, -Z_bearing_holder_width / 4, wall / 2])
                        cube([Z_screw_diameter, Z_bearing_holder_width / 2, wall], center = true);
                }

                // Small triangle
                translate([-clamp_length + 0.1, Z_nut_radius, base_thickness]) 
                    rotate([90, 0, 180]) 
                        right_triangle(width = wall + 1,  height = x_bar_spacing() - X_smooth_rod_diameter / 2 - wall, h = wall, center = true);

                // Z bearings holder
                translate([0, 0, Z_bearings_holder_height / 2])
                    cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2, $fn = smooth, center = true);

                // Bottom X rod holder
                translate([-clamp_length / 2 , X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , 0]) {
                    translate([0, 0, clamp_width / 2])
                        rotate([90, 0, 90])
                            teardrop(r = clamp_width / 2, h = clamp_length, center = true);

                    translate([0, 0, clamp_width / 2])
                        cube([clamp_length, clamp_width, clamp_width], center = true);   
                }


                // Top X rod holder
                translate([-clamp_length / 2 , X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , clamp_width / 2 + x_bar_spacing() + wall / 2]) {
                    rotate([90, 0, 90])
                        cylinder(h = clamp_length, r = clamp_width / 2, $fn = smooth, center = true);
                }
            }

            // Holes for X rods
            for (second = [0, x_bar_spacing()]) {
                translate([-clamp_length / 2, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, clamp_width / 2 + second]) 
                    rotate([90, 0, 90])
                        cylinder(r = X_smooth_rod_diameter / 2, h = clamp_length * 4, center = true);
            }

            // Vertical slit in X rods holder's block
            translate([-clamp_length / 2, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, x_bar_spacing() / 2 ]) 
                cube([clamp_length + 1, slit, x_bar_spacing() + clamp_width / 2], center = true);

            // Hole for Z leadscrew
            translate([-z_bar_spacing(), 0, Z_bearings_holder_height / 2])
                poly_cylinder(r = Z_screw_diameter / 2, h = 2 * Z_bearings_holder_height + eta, $fn = smooth, center = true);

            //Hole for Z leadscrew nut
            if (is_hex(Z_nut)) {
                // Hex nut
                translate([-z_bar_spacing(), 0, base_thickness / 2])
                    cylinder(r = anti_backlash_wall_radius, h = base_thickness + eta, $fn = 6, center = true);
            } else if (is_flanged(Z_nut)) {
                    //Flanged nut
                    translate([-z_bar_spacing(), 0, 0])
                        poly_cylinder(r = Z_nut_radius + 0.2, h = nut_depth(Z_nut) + eta, $fn = smooth);
                    translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 - flanged_nut_flange_thickness(Z_nut) / 2 - 0.1])
                    rotate([0, 0, 23]) {
                        flanged_nut(Z_nut);
                        rotate([0, 0, 120]) {
                            translate ([flanged_nut_hole_distance_radius(Z_nut), 0, base_thickness / 2])
                                poly_cylinder (r = flanged_nut_mounting_hole_radius(Z_nut), h = 2 * flanged_nut_barrel_thickness(Z_nut) + 0.1, center = true);
                            translate ([-flanged_nut_hole_distance_radius(Z_nut), 0, base_thickness / 2])
                                poly_cylinder (r = flanged_nut_mounting_hole_radius(Z_nut), h = 2 * flanged_nut_barrel_thickness(Z_nut) + 0.1, center = true);
                        }           
                    }
            } else {
                //Round nut
                translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 + wall]) 
                    poly_cylinder(r = Z_nut_radius, h = nut_depth(Z_nut) + 0.1, $fn = smooth, center = true);
                translate([-z_bar_spacing(), - Z_nut_radius / 2 - wall, nut_depth(Z_nut) / 2 + wall])
                    cube([Z_nut_radius * 2, Z_nut_radius + 2 * wall, nut_depth(Z_nut) + 0.1], center = true);
            }

            // Endstop mount
            translate([-wall, clamp_width / 2 + Z_bearing_holder_width / 2 + wall, clamp_width + wall + microswitch_slot_length() / 2])
                rotate([90, 90, 0]) {
                    microswitch_slot();
                }

            // Hole for spectra line bearing screw
            translate([-clamp_length * 3 / 4 + wall, Z_bearing_holder_width / 2 + clamp_width / 2 - wall, clamp_width + ball_bearing_diameter(XLOLX) / 2 + 1])
                rotate([90, 0, 0]) 
                   teardrop_plus(r = 4/2, h = 2 * clamp_width + eta, center = true);
                
            // Hole for spectra line fixing screw
            #translate([-wall, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, clamp_width + ball_bearing_diameter(XLOLX) / 2 + 1 + 1.5 * ball_bearing_diameter(XLOLX)])
                rotate([90, 90, 90])
                    cylinder(r = M4_clearance_radius, h = clamp_width, center = true);                    

            //Hole for Z bearings
            translate([0, 0, -1])
                poly_cylinder(h = Z_bearings_holder_height + 1 + eta, r = Z_bearing_outer_diameter / 2);

            //Front entry cut out
            translate([Z_bearing_outer_diameter/2, 0, Z_bearings_holder_height / 2])
                rotate([0, 0, 45])
                    cube([Z_bearing_outer_diameter, Z_bearing_outer_diameter, Z_bearings_holder_height + 1], center = true);
        }
}

module x_end_assembly() {
    color(x_end_bracket_color)
        render() x_end_bracket();

    // Z leadscrew nut
    *if (is_hex(Z_nut)) {
            // Hex nut
        } else {
            if (is_flanged(Z_nut)) {
                // Round flanged nut
                translate([-z_bar_spacing(), 0, 100])
                    rotate([0, 180, 20])
                        flanged_nut(Z_nut);
            } else {
                // Round nut
                translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 - wall])
                    round_nut(Z_nut, brass = true, center = true);
            }
        }

    // Spectra line bearing
    translate([-clamp_length * 3 / 4 + wall, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, clamp_width + ball_bearing_diameter(XLOLX) / 2 + 1])
        rotate([0, 90, 90]) 
            ball_bearing(XLOLX);

    // Spectra line bearing screw
    *translate([-clamp_length * 3 / 4 + wall , clamp_width + Z_bearing_holder_width / 2 - wall, clamp_width + ball_bearing_diameter(XLOLX) / 2 + 1])
        rotate([0, 90, 90]) 
            screw_and_washer(M4_pan_screw, screw_longer_than(clamp_width), center = true);

    // Spectra line fixing screw
    *translate([-wall, clamp_width + Z_bearing_holder_width / 2 - wall, clamp_width + ball_bearing_diameter(XLOLX) / 2 + 1 + 1.5 * ball_bearing_diameter(XLOLX)])
        rotate([0, 90, 90])
            screw_and_washer(M4_pan_screw, screw_shorter_than(clamp_width), center = true); 

    // Z leadscrew
    *translate([-z_bar_spacing(), 0, 40])
        rod(Z_screw_diameter, 150);
    
    // Z smooth rod
    *translate([0, 0, 40])
        rod(Z_smooth_rod_diameter, 200);

    // Z bearings
    *for(i = [0, 2]) {
        translate([0, 0, (shelves_Z_coordinate[i] + shelves_Z_coordinate[i+1])/2 ])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    }

    // X smooth rods
    *for (second = [0, x_bar_spacing()]) {
        translate([-clamp_length + 60, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , clamp_width / 2 + second]) {
            rotate([90, 0, 90]) {
                rod(X_smooth_rod_diameter, 100);
            }
        }
    }

}

x_end_assembly();
