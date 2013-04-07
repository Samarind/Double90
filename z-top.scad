// Fastens Z motor to the frame
include <conf/config.scad>

module z_top() {
    thickness = thick_wall;
    main_thickness = structure_wall;

    width = frame_sheets_distance;
    sidewalls_height = z_bar_spacing() / 2;
    length = z_bar_spacing() + 2 * thickness + main_thickness + ball_bearing_diameter(BB6800ZZ);

    cutout_edge_height = 2 * main_thickness;
    cutout_radius = (pow(sidewalls_height + main_thickness - cutout_edge_height, 2) + pow(((width - 2 * main_thickness) / 2), 2)) / (2 * (sidewalls_height + main_thickness - cutout_edge_height));

    color(z_motor_bracket_color)
        render()
            difference() {
                union() {
                    // Main plate
                    translate([main_thickness / 2, 0, main_thickness / 2])
                        cube([length, width, main_thickness], center = true);

                    // Bearing support
                    translate([z_bar_spacing() / 2, -z_axis_offset, 2 * main_thickness]) {
                        cylinder(r = ball_bearing_diameter(BB6800ZZ) / 2 + thickness, h = 1.5 * main_thickness, center = true);
                        translate([ball_bearing_diameter(BB6800ZZ) / 2 + thickness, 0, 0])
                            cube([2 * main_thickness, ball_bearing_diameter(BB6800ZZ), 1.5 * main_thickness], center = true);    
                    }

                    for (sign = [1, -1]) {
                        // Left and right walls
                        translate([main_thickness / 2, sign * (width - main_thickness) / 2, sidewalls_height / 2 + main_thickness])
                            cube([length, main_thickness, sidewalls_height], center = true);

                        // Front and back support walls
                        translate([main_thickness / 2, 0, 0])
                            translate([sign * (length - main_thickness) / 2, 0, sidewalls_height / 2 + main_thickness])
                                cube([main_thickness, width - 2 * main_thickness, sidewalls_height], center = true);
                    }
                }

                // Cutout
                translate([0, 0, cutout_radius + cutout_edge_height])
                    rotate([0, 90, 0]) 
                        cylinder(r = cutout_radius, h = 2 * length, center = true);

                // Frame mounting holes in side walls
                for (sign = [1, -1])
                    for (y = [sign * width / 2, - sign * width / 2])
                        translate([sign * (length / 4 ) + main_thickness / 2, y, main_thickness + sidewalls_height / 2])
                            rotate([0, 90, 90]) 
                                poly_cylinder(r = screw_radius(my_frame_screw), h = 3 * main_thickness, center = true);

                // Bearing fixing screw hole
                translate([z_bar_spacing() / 2 + ball_bearing_diameter(BB6800ZZ) / 2 + thickness + nut_depth(screw_nut(small_screw)) / 2, -z_axis_offset, 1.5 * main_thickness]) {
                    // translate([0, 0, main_thickness / 2])
                        cube([nut_depth(screw_nut(small_screw)) + 1, screw_nut_radius(small_screw) * 2, 2 * main_thickness], center = true);
                    rotate([0, 90, 0]) {
                        poly_cylinder(r = screw_radius(small_screw), h = 30, center = true);
                    }
                }

                // Endstop slot
                *translate([sidewalls_height / 2 + 1, ball_bearing_diameter(BB6800ZZ) / 2 + main_thickness + z_axis_offset, (microswitch_length() + 1 ) / 2 + 1]) 
                    cube([microswitch_width() + 1, microswitch_thickness() + 1, microswitch_length() + 1 + eta], center = true);

                translate([- z_bar_spacing() / 2, -z_axis_offset, 0]){
                    // Z smooth rod hole
                    poly_cylinder(r = Z_smooth_rod_diameter / 2, h = 3 * main_thickness, center = true);

                    translate([z_bar_spacing(), 0, 2 * main_thickness]) {
                        // Leadscrew hole in top plate
                        poly_cylinder(r = Z_screw_diameter / 2, h = 4 * main_thickness , center = true);

                        // Leadscrew bearing hole in top plate
                        poly_cylinder(r = ball_bearing_diameter(BB6800ZZ) / 2 + 0.1, h = 1.5 * main_thickness + eta, center = true);
                    }

                }
            }
}

module z_top_assembled() {
    z_top();
}

// z_top_assembled();


