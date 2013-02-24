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

base_thickness = nut_depth(Z_nut) + wall;
nut_flat_radius = nut_radius * cos(30);
clamp_width = 2 * (nut_radius + wall);
clamp_length = z_bar_spacing();
clamp_thickness = X_smooth_rod_diameter + 2 * wall;
slit = 2;


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
                // Support triangle
            }
            cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2);
        }

        difference() {
            union() {
                // Anti-backlash nut holder
                if (is_hex(Z_nut)) {
                    translate([-z_bar_spacing(), 0, anti_backlash_wall_height / 2])
                       rotate([0, 0, 90])                    
                            cylinder(r = anti_backlash_wall_radius + anti_backlash_wall_width, h = anti_backlash_wall_height, $fn = 6, center = true);
                } else if (is_flanged(Z_nut)) {
                } else { 
                    difference() {
                        hull() {
                            translate([-z_bar_spacing(), 0, base_thickness / 2]) 
                                    cylinder(r = nut_outer_radius(Z_nut) + anti_backlash_wall_width, h = base_thickness, $fn = smooth, center = true);
                            translate([0, 0, base_thickness / 2])
                                cylinder(h = base_thickness, r = Z_bearing_holder_width / 2, $fn = smooth, center = true);
                            translate([-z_bar_spacing() - nut_outer_radius(Z_nut) - 5, 0, base_thickness / 2])  
                                rotate([90, 0, 90])  
                                    cylinder(h = 10, r = nut_radius + wall / 2, $fn = smooth, center = true);
                        }
                        translate([-z_bar_spacing() - nut_outer_radius(Z_nut) - anti_backlash_wall_width, 0, base_thickness / 2])  
                            rotate([90, 0, 90])  
                                nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth + eta, true);
                    }
                }

                // Support wall
                translate([-clamp_length / 2 - 1, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2, (x_bar_spacing() + base_thickness) / 2])
                    difference() {
                        cube([clamp_length, 2 * wall + Z_smooth_rod_diameter, x_bar_spacing() - base_thickness], center = true);
                        translate([0, 0, -Z_smooth_rod_diameter / 2])
                            cube([clamp_length + eta, Z_smooth_rod_diameter, x_bar_spacing() - base_thickness - Z_smooth_rod_diameter / 2 + wall], center = true); 
                        translate([0, 0, base_thickness])
                            rotate([90, 0, 90])  
                                cylinder(h = clamp_length + eta, r = Z_smooth_rod_diameter / 2, $fn = smooth, center = true);  
                    }

                // Rounded connection in the edge
                union() {
                    translate([-Z_bearing_depth + wall / 2 , (Z_bearing_holder_width / 2 - wall) / 2, Z_bearings_holder_height / 2]) 
                        cube([wall, Z_bearing_holder_width / 2 - wall, Z_bearings_holder_height], center = true);
                    
                    difference() {
                        translate([-Z_bearing_depth - (Z_bearing_holder_width / 2 - wall) / 2 , (Z_bearing_holder_width / 2 - wall) / 2, Z_bearings_holder_height / 2]) 
                            cube([Z_bearing_holder_width / 2 - wall, Z_bearing_holder_width / 2 - wall, Z_bearings_holder_height], center = true);

                        translate([-Z_bearing_depth - (Z_bearing_holder_width / 2 - wall), 0, Z_bearings_holder_height / 2]) 
                            cylinder(r=Z_bearing_holder_width / 2 - wall, h = Z_bearings_holder_height + eta, $fn = smooth, center = true);
                    }
                }

                // Z bearings holder
                translate([0, 0, Z_bearings_holder_height / 2])
                    cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2, $fn = smooth, center = true);

                // Bottom X rod holder
                translate([-clamp_length / 2 - 1, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , 0]) {
                    translate([0, 0, clamp_thickness / 2])
                        rotate([90, 0, 90])
                           teardrop(r = clamp_thickness / 2, h = clamp_length, center = true);

                    translate([-clamp_length / 2, -clamp_thickness / 2, 0])
                        cube([clamp_length, clamp_thickness, clamp_thickness * 1.5 - wall]);   
                }


                // Top X rod holder
                translate([-clamp_length / 2 - 1, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , clamp_thickness / 2 + x_bar_spacing()]) {
                    rotate([90, 0, 90])
                       teardrop(r = clamp_thickness / 2, h = clamp_length, center = true);

                    translate([-clamp_length / 2, -clamp_thickness / 2, -clamp_thickness / 2])
                        cube([clamp_length, clamp_thickness, X_smooth_rod_diameter - wall / 2]);   

                    rotate([90, 0, 90])
                        linear_extrude(height = clamp_length + eta, center = true)
                        hull() {
                            translate([slit / 2 + eta, base_thickness / 2 + 1])
                                square([clamp_thickness / 4 - 1, 0.1]);
                                circle(r = clamp_thickness / 2);
                            }

                    translate([0, clamp_thickness / 8 + slit / 2, base_thickness / 2 + wall])
                        rotate([90, 0, 0])
                            linear_extrude(height = clamp_thickness / 4, center = true)
                                hull () {
                                    translate([-clamp_length / 2 + rounded_corner_radius, 0, 0])
                                        circle(r = rounded_corner_radius);
                                    translate([clamp_length / 2 - rounded_corner_radius, 0, 0])
                                        circle(r = rounded_corner_radius); 
                                    translate([0, -rounded_corner_radius, 0])
                                        square([clamp_length, wall], center = true);      
                                }

                    translate([0, -clamp_thickness / 4, base_thickness / 2 + wall])
                        rotate([90, 0, 0])
                        linear_extrude(height = clamp_thickness / 2, center = true)
                            hull () {
                                translate([-clamp_length / 2 + rounded_corner_radius, 0, 0])
                                    circle(r = rounded_corner_radius);
                                translate([clamp_length / 2 - rounded_corner_radius, 0, 0])
                                    circle(r = rounded_corner_radius);  
                                translate([0, -base_thickness / 2 - wall, 0])
                                    square([clamp_length, clamp_thickness], center = true);  
                            }
                }
            }

            for (second = [0, x_bar_spacing()]) {
                translate([-clamp_length / 2 - 1, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 - wall , clamp_thickness / 2 + second]) {

                    // X bar clamps nut traps
                    translate([0, (- slit / 2 - clamp_thickness / 4 - nut_trap_depth / 2  - wall / 2 - eta), clamp_thickness - washer_diameter(washer)])
                        rotate([90,90,0])
                            nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth + wall + eta, true);
                    
                    translate([0, wall, 0]) {
                        // Slits for X rods clamps
                        translate([0, 0, base_thickness / 2])
                            cube([clamp_length * 2, slit, base_thickness * 1.5], center = true);

                        // Holes for X rods
                        rotate([90, 0, 90])
                            teardrop(r = X_smooth_rod_diameter / 2, h = clamp_length * 2, center = true, truncate = false);
                    }
                }
            }

            // Slits for bottom clamp
            translate([-clamp_length / 2 - 1, X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 + 1.5 * wall, 0]) { 
                translate([clamp_length / 4, 0, clamp_thickness * 1.5 - wall -(1.5 * X_smooth_rod_diameter) / 2])
                    rotate([0, 0, 90])
                        cube([clamp_thickness / 4 + 2 * wall, 0.5, 1.5 * X_smooth_rod_diameter], center = true);
                translate([-clamp_length / 4, 0, clamp_thickness * 1.5 - wall - (1.5 * X_smooth_rod_diameter) / 2]) 
                    rotate([0, 0, 90])
                        cube([clamp_thickness / 4 + 2 * wall, 0.5, 1.5 * X_smooth_rod_diameter], center = true);
                translate([0, 0, clamp_thickness * 1.5 - wall]) 
                    rotate([90, 0, 0])
                        cube([clamp_length / 2 + 0.5, 0.5, clamp_thickness / 4 + 2 * wall + eta], center = true);
            }

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
                        poly_cylinder(r = nut_outer_radius(Z_nut) + 0.2, h = nut_depth(Z_nut) + eta, $fn = smooth);
                    translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 - flanged_nut_flange_thickness(Z_nut) / 2 - 0.1])
                    rotate([0,0,23]) {
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
                translate([-z_bar_spacing(), 0, nut_depth(Z_nut) * 2 / 2 + wall]) 
                    poly_cylinder(r = nut_outer_radius(Z_nut) + 0.2, h = 2*nut_depth(Z_nut) + 0.2 + eta, $fn = smooth, center = true);
            }

            //Hole for Z bearings
            translate([0, 0, -1])
                poly_cylinder(h = Z_bearings_holder_height + 1 + eta, r = Z_bearing_outer_diameter / 2);

            //Front entry cut out
            translate([Z_bearing_outer_diameter/2, 0, Z_bearings_holder_height / 2])
                rotate([0, 0, 45])
                    cube([Z_bearing_outer_diameter, Z_bearing_outer_diameter, Z_bearings_holder_height + 1], center = true);

        }
}

module rounded_cylinder(height, rounding, radius, x_offset = 0) {
    difference() {
        translate([x_offset, 0, height/2])
            cylinder(r = radius / 2, h = height, $fn = smooth, center = true);

        translate([0, 0, rounding/2])
            difference() {
                cylinder(r = radius / 2, h = rounding, $fn = smooth, center = true);
                
                rotate_extrude(convexity=10, $fn = smooth)
                    translate([radius / 2 - rounding, rounding / 2, 0])
                        circle(r=rounding, $fn=50, center=true);

                cylinder(r = radius / 2 - rounding, h = rounding + eta, $fn = smooth, center = true);
            }
    }
}

module x_end_assembly() {
    color(x_end_bracket_color)
        render() x_end_bracket();

    // Z leadscrew
    *translate([-z_bar_spacing(), 0, 40])
        rod(Z_screw_diameter, 200);
    
    // Z smooth rod
    *translate([0, 0, 40])
        rod(Z_smooth_rod_diameter, 200);
    
    // Z leadscrew nut
    if (is_hex(Z_nut)) {
            // Hex nut
        } else {
            if (is_flanged(Z_nut)) {
                // Round flanged nut
                translate([-z_bar_spacing(), 0, /*nut_depth(Z_nut) / 2 - flanged_nut_flange_thickness(Z_nut) / 2 - 0.1*/ 100])
                    rotate([0, 180, 20])
                        flanged_nut(Z_nut);
            } else {
                // Round nut
                *translate([-z_bar_spacing(), 0, 50])
                    round_nut(Z_nut, brass = true, center = true);
            }
        }

    // Spectra line bearing
    translate([-Z_bearing_depth / 2 - 10, 
                X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 + 3, 
                (x_bar_spacing() + clamp_thickness) / 2]) {
        rotate([0,90,90])
            ball_bearing(BB624);
    }

    // Z bearings
    *for(i = [0, 2]) {
        translate([0, 0, (shelves_Z_coordinate[i] + shelves_Z_coordinate[i+1])/2 ])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    }
}

x_end_assembly();
