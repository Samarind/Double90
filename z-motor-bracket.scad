// Fastens Z motor to the frame
include <conf/config.scad>
use <z-coupling.scad> 
use <x-motor-end.scad> 

module z_motor_bracket(z_coupling_height, thick_wall, structure_wall, my_frame_screw, small_screw, M3_clearance_radius) {
    thickness = thick_wall;
    main_thickness = structure_wall;

    width = frame_sheets_distance;
    length = z_coupling_height + NEMA_shaft_length(Z_motor);
    height = NEMA_holes_distance(Z_motor) / 2 + z_bar_spacing() + Z_smooth_rod_diameter / 2 + 2 * main_thickness;
    big_motor_hole = NEMA_big_hole(Z_motor);

    smooth_rod_height = Z_smooth_rod_diameter / 2 + thickness - 0.5;

    cutout_edge_height = smooth_rod_height + z_bar_spacing() + ball_bearing_diameter(BB6800ZZ) / 2 + main_thickness;
    cutout_radius = (pow(height - cutout_edge_height, 2) + pow(((width - 2 * main_thickness) / 2), 2)) / (2 * (height - cutout_edge_height));

    color(z_motor_bracket_color)
        render()
            difference() {
                union() {
                    difference() {
                        for (sign = [1, -1]) {
                            // Body - bottom and top plates
                            translate([sign * (length / 2 + main_thickness / 2), 0, height / 2])
                                cube([main_thickness, width, height], center = true);

                            // Body - left and right plates
                            translate([0, sign * width / 2 + (-1) * sign * main_thickness / 2, height / 2])
                                    cube([length, main_thickness, height], center = true);
                        }

                        // Cutout in top plate
                        translate([length / 2 + main_thickness / 2, 0, cutout_radius + cutout_edge_height])
                            rotate([90, 90, 90]) 
                                cylinder(r = cutout_radius, h = 2 * main_thickness, center = true);

                        // Holes in side plates
                        translate([0, 0, height / 2])
                            rotate([90, 0, 0]) 
                                cylinder(r = big_motor_hole, h = 2 * width, center = true);

                        // Frame mounting holes in side walls
                        translate([0, 0, height / 2])
                            rotate([0, 90, 90]) {
                                for (x = [- height + height / 2 + 1.5 * main_thickness, height - height / 2 - 1.5 * main_thickness])                                                         
                                    for (y = [- length / 2 + 1.5 * main_thickness, length / 2 - 1.5 * main_thickness])
                                        translate([x, y, 0])
                                            poly_cylinder(r = screw_radius(my_frame_screw), h = width * 2, center = true);
                            }
                    }

                    // Bearing support
                    translate([length / 2 - main_thickness / 2, z_axis_offset, (smooth_rod_height + z_bar_spacing()) / 2]) {
                        translate([0, 0, (smooth_rod_height + z_bar_spacing()) / 2])
                            rotate([0, 90, 0]) 
                                cylinder(r = ball_bearing_diameter(BB6800ZZ) / 2 + thickness, h = main_thickness, center = true);
                        cube([main_thickness, ball_bearing_diameter(BB6800ZZ) + 2 * thickness, smooth_rod_height + z_bar_spacing()], center = true);
                    }

                    // Smooth rod support
                    translate([0, z_axis_offset, smooth_rod_height]) {
                        rotate([0, 90, 0]) 
                            cylinder(r = smooth_rod_height, h = length, center = true);
                        translate([0, 0, -smooth_rod_height / 2])   
                            cube([length, Z_smooth_rod_diameter + 2 * thickness -1, smooth_rod_height], center = true);
                    }
                }

                // Bearing fixing screw
                translate([length / 2 + main_thickness / 2, z_axis_offset, cutout_edge_height - main_thickness + nut_depth(screw_nut(small_screw)) / 2]) {
                    cube([screw_nut_radius(small_screw) * 2, screw_nut_radius(small_screw) * 2, nut_depth(screw_nut(small_screw)) + 1], center = true);
                    translate([0, 0, main_thickness + nut_depth(screw_nut(small_screw)) / 2])
                        cube([screw_nut_radius(small_screw) * 2, screw_nut_radius(small_screw) * 2, nut_depth(screw_nut(small_screw)) + 1], center = true);
                    rotate([0, 0, 90]) {
                        translate([0, 0, 10])
                            poly_cylinder(r = screw_radius(small_screw), h = 30, center = true);
                    }
                }

                // Endstop slot
                translate([length / 2 + 1, ball_bearing_diameter(BB6800ZZ) / 2 + main_thickness + z_axis_offset, (microswitch_length() + 1 ) / 2 + 1]) 
                    cube([microswitch_width() + 1, microswitch_thickness() + 1, microswitch_length() + 1 + eta], center = true);

                translate([-length / 2 - main_thickness / 2, z_axis_offset, 0])
                    rotate([0, 90, 0]) {
                        // Mount for Z smooth rod in top plate
                        translate([-(smooth_rod_height), 0, length + main_thickness])
                            poly_cylinder(r = Z_smooth_rod_diameter / 2, h = 6 * main_thickness + eta, center = true);

                        translate([-(smooth_rod_height) - z_bar_spacing(), 0, length + main_thickness]) {
                            // Leadscrew hole in top plate
                            poly_cylinder(r = Z_screw_diameter / 2, h = 4 * main_thickness , center = true);

                            // Leadscrew bearing hole in top plate
                            poly_cylinder(r = ball_bearing_diameter(BB6800ZZ) / 2 + 0.1, h = main_thickness + 2 * eta, center = true);
                        }

                        // Motor big hole in bottom plate
                        translate([-(smooth_rod_height) - z_bar_spacing(), 0, ]) {
                            poly_cylinder(r = big_motor_hole, h = main_thickness * 2, center = true);

                            // Motor screw holes in bottom plate
                            for (x = NEMA_holes(Z_motor))                                                         
                                for (y = NEMA_holes(Z_motor))
                                    translate([x, y, 0])
                                        poly_cylinder(r = M3_clearance_radius, h = main_thickness + eta, center = true);
                        }
                    }
            }
}

module z_motor_bracket_assembly() {
    z_motor_bracket(z_coupling_height, thick_wall, structure_wall, my_frame_screw, small_screw, M3_clearance_radius);

    //Motor
    translate([- 31.5, z_axis_offset, Z_smooth_rod_diameter / 2 + thick_wall - 0.5 + z_bar_spacing()])
        rotate([0, 90, 0])
            NEMA(Z_motor);

    // Z coupler
    translate([0, z_axis_offset, Z_smooth_rod_diameter / 2 + thick_wall - 0.5 + z_bar_spacing()])
        rotate([90, 180, 90])
            z_coupler_assembly();

    // Z leadscrew
    translate([251, z_axis_offset, Z_smooth_rod_diameter / 2 + thick_wall - 0.5 + z_bar_spacing()])
        rotate([0, 90, 0])
            rod(Z_screw_diameter, 500);
    
    // Z smooth rod
    translate([251, z_axis_offset, Z_smooth_rod_diameter / 2 + thick_wall - 0.5])
        rotate([0, 90, 0])
            rod(Z_smooth_rod_diameter, 500);

}

// translate([10, -z_axis_offset, -35]) 
//     rotate([0, 270, 0]) 
        z_motor_bracket_assembly();


// x_motor_end_assembly();