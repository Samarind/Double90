// End of the X axis
include <conf/config.scad>

module x_end_bracket() {
    wall = thick_wall; // 4mm on Mendel and Sturdy, 3mm on Huxley
    base_thickness = X_smooth_rod_diameter + wall;
    
    Z_bearing_holder_wall = 2.5;
    X_rod_holder_wall = 2.5;

    Z_bearing_outer_diameter = Z_bearings[1] + 0.2;
    Z_bearing_holder_width = Z_bearing_outer_diameter + 2 * Z_bearing_holder_wall;
    X_rod_holder_width = X_smooth_rod_diameter + X_rod_holder_wall/2;
    Z_bearing_depth = Z_bearing_holder_width / 2 + 1;
    Z_bearing_length = Z_bearings[0];
    X_bearing_length = X_bearings[0];

    shelf_thickness = 2;
    shelf_clearance = 0.5;
    
    Z_bearings_holder_height = max( min(65, 2.8 * Z_bearing_length), 2 * (Z_bearing_length + shelf_clearance) + 3 * shelf_thickness);
    
    anti_backlash_radius = Z_nut_radius + 0.2;
    anti_backlash_wall_width = max(3, Z_bearing_holder_width / 2 - wall - cos(30) * anti_backlash_radius + 0.5);
    anti_backlash_wall_height = 2 * Z_screw_diameter + base_thickness / 2;

    front = -(Z_smooth_rod_diameter / 2 + 1);
    base_length = z_bar_spacing() - Z_bearing_depth / 2;

    shelf_depth = Z_bearing_depth - (Z_smooth_rod_diameter / 2 + 1);

    clamp_wall = default_wall; // 4mm on Sturdy, 3mm on Mendel and Huxley
    nut_flat_radius = nut_radius * cos(30);
    clamp_width = 2 * (nut_radius + clamp_wall);
    clamp_height = washer_diameter(washer) / 2 + nut_flat_radius + clamp_wall;
    clamp_depth = wall + nut_trap_depth;
    clamp_thickness = 5;
    slit = 1;
    bar_y = x_bar_spacing() / 2;

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
                //Main vertical block
                translate([-Z_bearing_depth / 2, 0, Z_bearings_holder_height / 2])
                    cube([Z_bearing_depth, Z_bearing_holder_width, Z_bearings_holder_height], center = true);

                // Bottom base
                translate([-Z_bearing_depth - base_length / 2, 0, base_thickness / 2])
                    #cube([base_length + wall, Z_bearing_holder_width, base_thickness ], center = true);    

                // Anti-backlash nut holder
                *translate([-z_bar_spacing(), 0, base_thickness / 2 - eta])
                    cylinder(r = anti_backlash_radius + anti_backlash_wall_width, h = anti_backlash_wall_height - base_thickness , $fn = 6);

                // X rods holder
                // *translate([front - base_length / 2, Z_bearing_holder_width / 2 + X_bearings_holder_width / 2, Z_bearings_holder_height / 2]) 
                //     cube([base_length, X_bearings_holder_width, Z_bearings_holder_height], center = true); 

                // Z bearings holder
                cylinder(h = Z_bearings_holder_height, r = Z_bearing_holder_width / 2);

                // Bar holders
                difference() {
                    translate([front - base_length / 2, X_rod_holder_width / 2 + Z_bearing_holder_width / 2, X_rod_holder_width / 2]) {
                        union() {
                            rotate([90, 0, 90])
                                teardrop(r = X_rod_holder_width/2, h = X_bearing_length, center = true);
                            
                            rotate([-90, 0, 90])
                                teardrop(r = X_rod_holder_width / 2, h = X_bearing_length, center = true);

                            rotate([90, 0, 90])
                                linear_extrude(height = X_bearing_length - 4 * eta, center = true)
                                    hull() {
                                        translate([slit / 2 + eta, base_thickness / 2 - 1])
                                            square([clamp_thickness - 2 * eta, 0.5]);
                                        circle(r = X_rod_holder_width / 2 - eta);
                                    }

                            // Bottom connection
                            *translate([0, -X_rod_holder_width / 4, -(X_rod_holder_width / 2 - base_thickness / 2)])
                                cube([X_bearing_length, X_rod_holder_width / 2, base_thickness ], center = true); 

                            *translate([0, clamp_thickness / 2 + slit / 2 - eta, base_thickness / 2])
                            rotate([90, 0, 0])
                                linear_extrude(height = clamp_thickness, center = true)
                                    polygon(points = [
                                        [-base_length / 2 + eta, 0],
                                        [-base_length / 2 + eta, -Z_bearing_holder_width / 2],
                                        [ base_length / 2 - eta, -Z_bearing_holder_width / 2],
                                        [ base_length / 2 - eta, 0],
                                        [ clamp_width / 2, clamp_height],
                                        [-clamp_width / 2, clamp_height],
                                    ]);

                            translate([0, -clamp_thickness, base_thickness / 2 + clamp_height / 2])
                                #cube([clamp_width, clamp_depth, clamp_height], center = true);
                        }
                    }

                    // Holes for X rods
                    translate([front - base_length / 2, X_rod_holder_width / 2 + Z_bearing_holder_width / 2, 0]) {
                        translate([0, 0, base_thickness / 2])
                            cube([base_length + 1, slit, base_thickness + 1], center = true);
                        rotate([90, 0, 90])
                            teardrop_plus(r = X_smooth_rod_diameter / 2 + 0.2, h = X_bearing_length + 1, center = true, truncate = false);
                    }
                    //
                    // Bar clamp nut traps
                    //
                    *translate([front - base_length / 2, (X_rod_holder_width / 2 + Z_bearing_holder_width / 2 - clamp_depth - slit / 2), base_thickness / 2 + washer_diameter(washer) / 2])
                        rotate([90,0,0])
                            nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth, true);
                }
            }

            // Hole for Z leadscrew
            translate([-z_bar_spacing(), 0, -base_thickness / 2])
                nut_trap((Z_screw_diameter + 1) / 2, Z_nut_radius, Z_nut_depth);
            translate([-z_bar_spacing(), 0, base_thickness / 2 + eta])
                cylinder(r = anti_backlash_radius, h = Z_bearings_holder_height, $fn = 6);

            //Hole for Z bearings
            translate([0, 0, -1])
                poly_cylinder(h = Z_bearings_holder_height + 2, r = Z_bearing_outer_diameter / 2);

            //Front entry cut out
            translate([Z_bearing_outer_diameter/2, 0, Z_bearings_holder_height / 2])
                rotate([0, 0, 45])
                    cube([Z_bearing_outer_diameter, Z_bearing_outer_diameter, Z_bearings_holder_height + 1], center = true);
        }

        difference() {
            union() {

                //Triangular support
                // translate([-Z_bearing_depth + eta, (Z_bearing_holder_width - wall - eta) / 2 , base_thickness / 2 - eta])
                //     rotate([90, 0, 0])
                //         #right_triangle(width = back + Z_bearing_depth, height = Z_bearings_holder_height - base_thickness , h = wall);

                
            }

            // Cut out for bearing holder
            // *cube([Z_bearing_depth * 2 -eta, Z_bearing_holder_width - eta, base_thickness + 10], center = true);
        }
    }
}

module x_end_assembly() {
    color(x_end_bracket_color)
     render() x_end_bracket();
    
    *translate([-z_bar_spacing(), 0, 2 * base_thickness ])
        rod(Z_screw_diameter, 135);
    *translate([0, 0, 2 * base_thickness ])
        rod(Z_smooth_rod_diameter, 170);

    // bearings
    *for(i = [0,2]) {
        translate([0, 0, (shelves[i] + shelves[i+1])/2 - base_thickness / 2])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    }
}

x_end_assembly();
