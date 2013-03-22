// Fastens Z motor to the frame
include <conf/config.scad>
include <positions.scad>
use <z-coupling.scad> 
use <x-end.scad> 

module z_motor_bracket(z_coupling_height, thick_wall, structure_wall, my_frame_screw, small_screw, M3_clearance_radius) {
    thickness = thick_wall;
    main_thickness = structure_wall;

    width = frame_sheets_distance;
    length = z_coupling_height + NEMA_shaft_length(Z_motor);
    height = NEMA_holes_distance(Z_motor) / 2 + z_bar_spacing() + Z_smooth_rod_diameter / 2 + 2 * main_thickness;
    big_motor_hole = NEMA_big_hole(Z_motor);

    color(z_motor_bracket_color)
            difference() {
                union() {
                    difference() {
                        for (sign = [1, -1]) {
                            // Body - bottom and top plates
                            translate([sign * (length / 2 + main_thickness / 2), 0, height / 2])
                                difference() {
                                    cube([main_thickness, width, height], center = true);
                                }

                            // Body - left and right plates
                            translate([0, sign * width / 2 + (-1) * sign * main_thickness / 2, height / 2])
                                    cube([length, main_thickness, height], center = true);
                        }
                        // Cutout in top plate
                        translate([length / 2 + main_thickness / 2, 0, height + 2.5 * main_thickness + ball_bearing_diameter(XXX) / 2])
                            rotate([90, 90, 90]) 
                                cylinder(r = (width + main_thickness / 2) / 2, h = 2 * main_thickness, center = true);

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
                    translate([length / 2 - main_thickness / 2, 0, height / 2 + thickness]) {
                        rotate([0, 90, 0]) 
                            cylinder(r = ball_bearing_diameter(XXX) / 2 + thickness, h = main_thickness, center = true);
                        translate([0, 0, -(height / 2 + thickness) / 2])
                            cube([main_thickness, ball_bearing_diameter(XXX) + 2 * thickness, height / 2 + thickness], center = true);
                        translate([- (length / 2 - main_thickness / 2), 0, -z_bar_spacing()]) {
                            rotate([0, 90, 0]) 
                                cylinder(r = Z_smooth_rod_diameter / 2 + thickness - 0.5, h = length, center = true);
                            translate([0, 0, -( height / 2 + thickness - z_bar_spacing()) / 2])   
                                cube([length, Z_smooth_rod_diameter + 2 * thickness -1, height / 2 + thickness - z_bar_spacing()], center = true);
                            }
                    }
                }

                // Bearing fixing screw
                translate([length / 2 + main_thickness / 2, 0, height / 2 + thickness + ball_bearing_diameter(XXX) / 2 + nut_depth(screw_nut(small_screw)) - 1])
                rotate([0, 0, 90]) {
                    cube([screw_nut_radius(small_screw) * 2, screw_nut_radius(small_screw) * 2, nut_depth(screw_nut(small_screw)) + 1], center = true);
                    translate([0, 0, 10])
                        poly_cylinder(r = screw_radius(small_screw), h = 30, center = true);
                }

                // Endstop slot
                translate([length / 2 + 1, ball_bearing_diameter(XXX) / 2 + main_thickness, (microswitch_length() + 1 ) / 2 + 1]) 
                    cube([microswitch_width() + 1, microswitch_thickness() + 1, microswitch_length() + 1 + eta], center = true);

                translate([-length / 2 - main_thickness / 2, 0, height / 2 + thickness])
                    rotate([0, 90, 0]) {
                        // Mount for Z smooth rod in top plate
                        translate([z_bar_spacing(), 0, length + main_thickness])
                            poly_cylinder(r = Z_smooth_rod_diameter / 2, h = 6 * main_thickness + eta, center = true);

                        translate([0, 0, length + main_thickness]) {
                            // Leadscrew hole in top plate
                            poly_cylinder(r = Z_screw_diameter / 2, h = 4 * main_thickness , center = true);

                            // Leadscrew bearing hole in top plate
                            poly_cylinder(r = ball_bearing_diameter(XXX) / 2 + 0.1, h = main_thickness + 2 * eta, center = true);
                        }

                        // Motor big hole in bottom plate
                        poly_cylinder(r = big_motor_hole, h = main_thickness * 2, center = true);

                        // Motor screw holes in bottom plate
                        for (x = NEMA_holes(Z_motor))                                                         
                            for (y = NEMA_holes(Z_motor))
                                translate([x, y, 0])
                                    poly_cylinder(r = M3_clearance_radius, h = main_thickness + eta, center = true);
                    }
            }
}

module z_motor_bracket_assembly() {
    z_motor_bracket(z_coupling_height, thick_wall, structure_wall, my_frame_screw, small_screw, M3_clearance_radius);

    //Motor
    *translate([- 31.5, 0, 71.6 / 2 + 4])
        rotate([0, 90, 0])
            NEMA(Z_motor);

    // Z coupler
    *translate([0, 0, 71.6 / 2 + 4])
        rotate([90, 180, 90])
            z_coupler_assembly();
}

    z_motor_bracket_assembly();

