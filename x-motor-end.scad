// End of the X axis with motor
include <conf/config.scad>;
use <spool.scad>;
use <x-end.scad>;
use <bearing-holder.scad>;

axle_height = spectra_bearing_height_position();
axle_x_offset = -74.3;
wall = thick_wall; 

module x_motor_end() {
    Z_bearings_holder_height = bearings_holder_height(Z_bearings);
    Z_bearing_holder_width = bearings_holder_width(Z_bearings);
    anti_backlash_wall_radius = Z_nut_radius + 0.2;
    anti_backlash_wall_width = max(3, Z_bearing_holder_width / 2 - wall - cos(30) * anti_backlash_wall_radius + 0.5);
    union () {
        difference() {
            color(x_end_bracket_color)
                render()
                    x_end();

            // Cutout for spectra line
            translate([-x_rod_clamp_length() / 2, bearing_y_offset(), axle_height - 0.5]) {
                cube([x_rod_clamp_length() * 2, spool_working_width() + 0.5, ball_bearing_diameter(x_spectra_bearing)], center = true);
                for (sign = [1, -1]) {
                    translate([0, sign * (spool_working_width() + 0.5) / 2 - sign * 2, ball_bearing_diameter(x_spectra_bearing) / 2])
                        rotate([90, 0, 90]) 
                            teardrop(h = 2 * x_rod_clamp_length(), r = 2, truncate = false, center = true, $fn = smooth); 
                }
            }  
        }   
                
        color(x_end_bracket_color)
            render() { 
                translate([axle_x_offset, Z_nut_radius - (wall - 0.5) / 2 + 0.1, 0]) 
                    difference() {
                        // Motor holding wall
                        translate([0, 0, Z_bearings_holder_height / 2])
                            cube([NEMA_width(X_motor) + 2 * wall + 1, 2 * wall - 0.5, Z_bearings_holder_height], center = true);
                        translate([0, 0, axle_height]) {
                            // Big motor hole
                            rotate([90, 0, 0])
                                poly_cylinder(r = NEMA_big_hole(Z_motor), h = 30, center = true);   
                            // Motor screw holes
                            for (x = NEMA_holes(Z_motor))                                                         
                                for (z = NEMA_holes(Z_motor))
                                    translate([x, 0, z])
                                        rotate([90, 0, 0])
                                            poly_cylinder(r = M3_clearance_radius, h = 2 * wall, center = true);
                        }
                    }

                // Motor support    
                difference() {
                    union() {
                        // Bottom plate
                        translate([axle_x_offset, 0, wall / 2])
                            cube([NEMA_width(X_motor) + 2 * wall + 1, Z_bearing_holder_width, wall], center = true);

                        //Connection of the motor wall with main body  
                        translate([-z_bar_spacing() + wall, Z_nut_radius - (wall - 0.5) / 2 + 0.1, Z_bearings_holder_height / 2]) 
                            cube([z_bar_spacing() + wall / 2, 2 * wall - 0.5, Z_bearings_holder_height], center = true);

                        // Bottom connection
                        translate([-z_bar_spacing() - (Z_nut_radius + anti_backlash_wall_width) / 2, 0, (wall - 0.05) / 2]) 
                            cube([Z_nut_radius + 1, Z_bearing_holder_width, wall - 0.05], center = true);
                        
                        // Triangles on both sides of motor
                        for (sign = [1, -1]) {
                            translate([axle_x_offset + sign * (NEMA_width(X_motor) / 2 + wall / 2 + 0.5), Z_nut_radius - (wall - 0.5) / 2 + 0.1 - (2 * wall - 0.5) / 2  + 0.15, wall]) 
                                rotate([90, 0, 270])
                                    right_triangle(width = Z_bearing_holder_width - (2 * wall - 0.5),  height = Z_bearings_holder_height - wall, h = wall, center = true); 
                        }

                        // Support triangle on top
                        translate([-x_rod_clamp_length() + 0.1, Z_nut_radius + 0.1, Z_bearings_holder_height]) 
                            rotate([90, 0, 180]) 
                                right_triangle(width = Z_nut_radius + NEMA_width(X_motor) + 2 * wall + 1,  height = X_smooth_rod_diameter + wall, h = wall, center = true);
                    }

                    //Round Z leadscrew nut
                    translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 + wall]) {
                        poly_cylinder(r = Z_nut_radius, h = nut_depth(Z_nut) + 0.1, $fn = smooth, center = true);
                        poly_cylinder(r = Z_screw_diameter / 2, h = 2 * nut_depth(Z_nut), $fn = smooth, center = true);
                    }

                    // Screw holding X-block together
                    translate([-x_rod_clamp_length() * 3 / 4 + wall, Z_bearing_holder_width / 2 + x_rod_clamp_width() / 2 - wall, axle_height])
                        rotate([90, 0, 0]) 
                           teardrop_plus(r = 4/2, h = 2 * x_rod_clamp_width() + eta, center = true);
                }
            }
    }
}

module x_motor_end_assembly() {
    x_motor_end();

    // Z leadscrew nut
    if (is_hex(Z_nut)) {
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

    // Z bearings
    for(i = [0, 2]) {
        translate([0, 0, (shelves_coordinate(Z_bearings)[i] + shelves_coordinate(Z_bearings)[i+1])/2 ])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    }

    translate([axle_x_offset, bearing_y_offset(), axle_height]) {
        rotate([90, 0, 0])
            spool_assembly();
        translate([0, -14, 0])
            rotate([270, 0, 0])
                NEMA(X_motor);
        }
}

 x_motor_end_assembly();
