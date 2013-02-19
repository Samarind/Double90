// End of the X axis
include <conf/config.scad>

module x_end_bracket() {
    rounded_corner_radius = 6;

    wall = thick_wall; 
    base_thickness = X_smooth_rod_diameter + wall;
    
    Z_bearing_holder_wall = 2.5;
    Z_bearing_outer_diameter = Z_bearings[1] + 0.2;
    Z_bearing_holder_width = Z_bearing_outer_diameter + 2 * Z_bearing_holder_wall;
    X_rod_holder_width = base_thickness + wall;
    Z_bearing_depth = Z_bearing_holder_width / 2 + 1;
    Z_bearing_length = Z_bearings[0];

    shelf_thickness = 2;
    shelf_clearance = 0.5;
    
    Z_bearings_holder_height = max( min(65, 2.8 * Z_bearing_length), 2 * (Z_bearing_length + shelf_clearance) + 3 * shelf_thickness);
    
    anti_backlash_radius = Z_nut_radius + 0.2;
    anti_backlash_wall_width = max(3, Z_bearing_holder_width / 2 - wall - cos(30) * anti_backlash_radius + 0.5);
    anti_backlash_wall_height = 2 * Z_screw_diameter + base_thickness / 2;

    base_length = z_bar_spacing() ;//- Z_bearing_depth / 2;

    shelf_depth = Z_bearing_depth - (Z_smooth_rod_diameter / 2 + 1);
    
    nut_flat_radius = nut_radius * cos(30);
    clamp_width = 2 * (nut_radius + wall);
    // clamp_height = washer_diameter(washer) / 2 + nut_flat_radius;
    clamp_length = 20;
    clamp_thickness = X_rod_holder_width / 2;
    slit = 2;

    shelves = [ shelf_thickness / 2,
                shelf_thickness + Z_bearing_length + shelf_clearance + shelf_thickness / 2,
                Z_bearings_holder_height - shelf_thickness / 2,
                Z_bearings_holder_height - (shelf_thickness + Z_bearing_length + shelf_clearance + shelf_thickness / 2) ];

    color(x_end_bracket_color) {
        // Shelves for bearings
        for(y = shelves)
            translate([-Z_bearing_depth + shelf_depth / 2 + eta, 0, y])
                cube([shelf_depth, Z_bearing_holder_width, shelf_thickness], center = true);

        difference() {
            union() {

                *translate([-z_bar_spacing(), 0, -flanged_nut_position(Z_flanged_nut) - 0.1])
                    rotate([0,0,23])
                        flanged_nut(Z_flanged_nut);

                //Main vertical block
                translate([-Z_bearing_depth / 2, 0, Z_bearings_holder_height / 2])
                    cube([Z_bearing_depth, Z_bearing_holder_width, Z_bearings_holder_height], center = true);

                // Bottom base
                translate([-Z_bearing_depth - base_length / 2, 0, base_thickness / 2])
                    cube([base_length + wall, Z_bearing_holder_width, base_thickness ], center = true);    

                // Anti-backlash nut holder
                *translate([-z_bar_spacing(), 0, base_thickness / 2 - eta])
                    cylinder(r = anti_backlash_radius + anti_backlash_wall_width, h = anti_backlash_wall_height - base_thickness , $fn = 6);

                //Support wall
                translate([-Z_bearing_depth - washer_diameter(washer), Z_bearing_holder_width / 2 - wall / 2, x_bar_spacing() / 2 + clamp_thickness])
                        cube([clamp_length, wall, x_bar_spacing() - X_rod_holder_width], center = true);

                // Support triangle
                translate([-Z_bearing_depth, -Z_bearing_holder_width, Z_bearings_holder_height]) {
                    rotate([90, 0, -90]) {
                        right_triangle(Z_bearing_holder_width, 30, wall);
                    }
                }

                // X rods holder
                // *translate([front - base_length / 2, Z_bearing_holder_width / 2 + X_bearings_holder_width / 2, Z_bearings_holder_height / 2]) 
                //     cube([base_length, X_bearings_holder_width, Z_bearings_holder_height], center = true); 

                // Z bearings holder
                cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2);

                // X rods holders
                for (second = [0, x_bar_spacing()]) {
                    translate([-Z_bearing_depth - washer_diameter(washer), X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 , clamp_thickness + second]) {
                        difference() {
                            union() {
                                rotate([90, 0, 90])
                                   teardrop(r = clamp_thickness, h = clamp_length, center = true);
                                
                                rotate([-90, 0, 90])
                                   teardrop(r = clamp_thickness, h = clamp_length, center = true);

                               rotate([90, 0, 90])
                                    linear_extrude(height = clamp_length + eta, center = true)
                                    hull() {
                                        translate([slit / 2 + eta, base_thickness / 2 + 1])
                                            square([clamp_thickness / 2, 1]);
                                            circle(r = clamp_thickness);
                                        }

                                translate([0, clamp_thickness / 4 + slit / 2, base_thickness / 2 + wall])
                                    rotate([90, 0, 0])
                                        linear_extrude(height = clamp_thickness / 2, center = true)
                                            hull () {
                                                translate([-clamp_length / 2 + rounded_corner_radius, 0, 0])
                                                    circle(r = rounded_corner_radius);
                                                translate([clamp_length / 2 - rounded_corner_radius, 0, 0])
                                                    circle(r = rounded_corner_radius); 
                                                translate([0, -rounded_corner_radius, 0])
                                                    square([clamp_length, wall], center = true);      
                                            }
                                translate([0, -clamp_thickness/2, base_thickness / 2 + wall])
                                    rotate([90, 0, 0])
                                    linear_extrude(height = clamp_thickness, center = true)
                                        hull () {
                                            translate([-clamp_length / 2 + rounded_corner_radius, 0, 0])
                                                circle(r = rounded_corner_radius);
                                            translate([clamp_length / 2 - rounded_corner_radius, 0, 0])
                                                circle(r = rounded_corner_radius);  
                                            translate([0, -base_thickness / 2 - wall, 0])
                                                square([clamp_length, clamp_thickness * 2], center = true);  
                                            }
                                        // *polygon(points = [
                                        //     [-clamp_length / 2 + eta, wall],
                                        //     [-clamp_length / 2 + eta, -base_thickness / 2 - X_rod_holder_width / 2 - wall],
                                        //     [ clamp_length / 2 - eta, -base_thickness / 2 - X_rod_holder_width / 2 - wall],
                                        //     [ clamp_length / 2 - eta, wall],
                                        //     [ clamp_width / 2, clamp_height],
                                        //     [-clamp_width / 2, clamp_height],
                                        // ]);
                            }

                            // Slits for X rods clamps
                            translate([0, 0, base_thickness / 2])
                                cube([base_length * 2, slit, base_thickness * 1.5], center = true);

                            // Holes for X rods
                            rotate([90, 0, 90])
                                teardrop(r = X_smooth_rod_diameter / 2, h = base_length * 2, center = true, truncate = false);
                        }
                    }
                }
            }

            // Bar clamps nut traps
            for (second = [0, x_bar_spacing()]) {
                translate([-Z_bearing_depth - washer_diameter(washer), X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2 - wall , clamp_thickness + second]) {
                        translate([0, (- slit / 2 - clamp_thickness / 2 - nut_trap_depth / 2  - wall / 2 - eta), base_thickness / 2 + washer_diameter(washer) / 2 + wall / 2])
                            rotate([90,0,0])
                                nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth + wall + eta, true);
                }
            }

            // Hole for Z leadscrew
            // translate([-z_bar_spacing(), 0, -base_thickness / 2])
            //     nut_trap((Z_screw_diameter + 1) / 2, Z_nut_radius, Z_nut_depth);
            translate([-z_bar_spacing(), 0, base_thickness / 2 ])
                poly_cylinder(r = Z_screw_diameter / 2, h = base_thickness + eta, $fn = 50);
            translate([-z_bar_spacing(), 0, -0.1])
                poly_cylinder(r = flanged_nut_barrel_radius(Z_flanged_nut) + 0.2, h = flanged_nut_barrel_thickness(Z_flanged_nut) + eta, $fn = 50);

            //Hole for Z bearings
            translate([0, 0, -1])
                poly_cylinder(h = Z_bearings_holder_height + 2, r = Z_bearing_outer_diameter / 2);

            //Front entry cut out
            translate([Z_bearing_outer_diameter/2, 0, Z_bearings_holder_height / 2])
                rotate([0, 0, 45])
                    cube([Z_bearing_outer_diameter, Z_bearing_outer_diameter, Z_bearings_holder_height + 1], center = true);

        }
    }
}

module x_end_assembly() {
    color(x_end_bracket_color)
     render() x_end_bracket();


    //rods
    *translate([-z_bar_spacing(), 0, 0])
        rod(Z_screw_diameter, 135);
    *translate([0, 0, 0])
        rod(Z_smooth_rod_diameter, 170);
    
    

    // bearings
    *for(i = [0,2]) {
        translate([0, 0, (shelves[i] + shelves[i+1])/2 - base_thickness / 2])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    }
}

x_end_assembly();
