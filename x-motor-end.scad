// End of the X axis with motor
include <conf/config.scad>;
use <spool.scad>
use <x-end.scad>

wall = thick_wall; 
Z_bearing_holder_wall = 2.5;
Z_bearing_outer_diameter = Z_bearings[1] + 0.2;
Z_bearing_holder_width = Z_bearing_outer_diameter + 2 * Z_bearing_holder_wall;
axle_height = x_rod_clamp_clamp_width() + ball_bearing_diameter(x_spectra_bearing) / 2 + 1;
base_thickness = nut_depth(Z_nut) + 2 * wall;
anti_backlash_wall_radius = Z_nut_radius + 0.2;
anti_backlash_wall_width = max(3, Z_bearing_holder_width / 2 - wall - cos(30) * anti_backlash_wall_radius + 0.5);
axle_x_offset = -75;

module x_motor_end() {
    color(x_end_bracket_color)
        render() {
            difference() {
                x_end();
                for (height = [0, ball_bearing_diameter(x_spectra_bearing)]) {
                    translate([-x_rod_clamp_clamp_length() / 2, Z_bearing_holder_width / 2 + x_rod_clamp_clamp_width() / 2 - wall - spool_working_width()  / 2 + 1.5, x_rod_clamp_clamp_width() + 1.5 + height])
                        rotate([90, 0, 90]) {
                            teardrop(h = 2 * x_rod_clamp_clamp_length(), r = 1.5, truncate = false, center = true, $fn = smooth); 
                            translate([spool_working_width() - 2.9, 0.2, 0])
                                teardrop(h = 2 * x_rod_clamp_clamp_length(), r = 2.3, truncate = false, center = true, $fn = smooth); 
                        }
                }
            }   
             
            translate([axle_x_offset, Z_nut_radius - (wall - 0.5) / 2, axle_height]) 
                difference() {
                    // Motor holding wall
                    cube([NEMA_width(X_motor) + 2 * wall + 1, 2 * wall - 0.5, 2 * axle_height], center = true);
                    // Big motor hole
                    rotate([90, 0, 0])
                        poly_cylinder(r = NEMA_big_hole(Z_motor), h = 30, center = true);   
                    // Motor screw holes in bottom plate
                    for (x = NEMA_holes(Z_motor))                                                         
                        for (z = NEMA_holes(Z_motor))
                            translate([x, 0, z])
                                rotate([90, 0, 0])
                                    poly_cylinder(r = M3_clearance_radius, h = 2 * wall, center = true);
                }

            // Motor support    
            difference() {
                union() {
                    // Bottom plate
                    translate([axle_x_offset, -(wall + 1.5), (wall - 1) / 2])
                        cube([NEMA_width(X_motor) + 2 * wall + 1, Z_nut_radius * 2, wall - 1], center = true);

                    //Connection of the motor wall with main body  
                    translate([-z_bar_spacing() + wall, Z_nut_radius - (wall - 0.5) / 2, axle_height]) 
                        cube([z_bar_spacing() + wall / 2, 2 * wall - 0.5, 2 * axle_height], center = true);

                    // Bottom connection
                    translate([-z_bar_spacing() - (Z_nut_radius + anti_backlash_wall_width) / 2, -(Z_nut_radius + anti_backlash_wall_width) / 2, (wall - 0.05) / 2]) 
                        cube([Z_nut_radius + 1, Z_nut_radius + anti_backlash_wall_width, wall - 0.05], center = true);
                    
                    // Triangles
                    for (sign = [1, -1]) {
                        translate([axle_x_offset + sign * (NEMA_width(X_motor) / 2 + wall / 2 + 0.5), Z_nut_radius - wall - 1.5, (wall - 1) - 0.1]) 
                            rotate([90, 0, 270])
                                right_triangle(width = Z_nut_radius * 2,  height = 2 * axle_height - (wall - 1), h = wall, center = true); 
                    }

                    // Support triangle on top
                    translate([-x_rod_clamp_clamp_length() + 0.1, Z_nut_radius, axle_height * 2]) 
                        rotate([90, 0, 180]) 
                            right_triangle(width = Z_nut_radius + NEMA_width(X_motor) + 2 * wall + 1,  height = 1.5 * X_smooth_rod_diameter, h = wall, center = true);
                }
                //Round nut
                translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 + wall]) {
                    poly_cylinder(r = Z_nut_radius, h = nut_depth(Z_nut) + 0.1, $fn = smooth, center = true);
                    poly_cylinder(r = Z_screw_diameter / 2, h = 2 * nut_depth(Z_nut), $fn = smooth, center = true);
                }
            }
        }
}

module x_motor_end_assembly() {
    x_motor_end();
    *translate([axle_x_offset, 19.5, axle_height]) {
        rotate([90, 0, 0])
            spool_assembly();
        translate([0, -14, 0])
            rotate([270, 0, 0])
                NEMA(X_motor);
        }
}

 x_motor_end_assembly();
