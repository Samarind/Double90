// End of the X axis with motor
include <conf/config.scad>;
use <spool.scad>
use <x-end.scad>

wall = thick_wall; 
Z_bearing_holder_wall = 2.5;
Z_bearing_outer_diameter = Z_bearings[1] + 0.2;
Z_bearing_holder_width = Z_bearing_outer_diameter + 2 * Z_bearing_holder_wall;

module x_motor_end() {
    color(x_end_bracket_color)
        render() {
            difference() {
                
                        x_end();
                for (height = [0, ball_bearing_diameter(XLOLX)]) {
                    translate([-x_rod_clamp_clamp_length() / 2, Z_bearing_holder_width / 2 + x_rod_clamp_clamp_width() / 2 - wall - spool_working_width()  / 2 + 1.5, x_rod_clamp_clamp_width() + 1.5 + height])
                        rotate([90, 0, 90]) {
                            teardrop(h = 2 * x_rod_clamp_clamp_length(), r = 1.5, truncate = false, center = true, $fn = smooth); 
                            translate([spool_working_width() - 2.9, 0.2, 0])
                               teardrop(h = 2 * x_rod_clamp_clamp_length(), r = 2.3, truncate = false, center = true, $fn = smooth); 
                           }
                }
            }   
            difference() {
                translate([-z_bar_spacing() -Z_nut_radius + 1 - 30, Z_nut_radius - wall + 0.5 / 2, 30]) 
                    cube([60, wall - 0.5, 60], center = true);
                // Big motor hole
                translate([-73, Z_nut_radius - wall + 0.5 / 2, 12 + 4 + 4 + 1 + 11])
                    rotate([90, 0, 0])
                        poly_cylinder(r = NEMA_big_hole(Z_motor), h = wall * 2, center = true);   
            }
        }
}

module x_motor_end_assembly() {
    x_motor_end();
    translate([-73, 19.5, 12 + 4 + 4 + 1 + 11]) {
        rotate([90, 0, 0])
            spool_assembly();
        translate([0, -14, 0])
            rotate([270, 0, 0])
                NEMA(X_motor);
        }
}

 x_motor_end_assembly();
