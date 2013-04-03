include <conf/config.scad>;
use <624-idler.scad>;
use <bearing-holder.scad>;
use <spool.scad>;
use <x-end.scad>;
use <x-motor-end.scad>;

wall = thick_wall;
axle_height = spectra_bearing_height_position() - X_smooth_rod_diameter / 2 - wall + ball_bearing_diameter(x_spectra_bearing);
X_bearings_holder_length = bearings_holder_height(X_bearings);
X_bearings_holder_width = bearings_holder_width(X_bearings);    

module rail(length, width, thickness) {
    translate([0, 0, -length / 2])
        linear_extrude(height = (length))
               polygon(points=[[-width / 2, 0], [width / 2, 0], [(width - thickness) / 2, -thickness], [-(width - thickness) / 2,-thickness]], paths=[[0,1,2,3]]);
}

module halfrail(length, width, thickness) {
    translate([0, 0, -length / 2])
        linear_extrude(height = (length))
               polygon(points=[[-width / 2, 0], [0, 0], [0, -thickness], [-(width - thickness) / 2,-thickness]], paths=[[0,1,2,3]]);
}

module x_carriage() {
    union() {
        difference() {
            union() {
                translate([-X_bearings_holder_length / 2, 0, 0]) {
                    // Bottom bearing holder
                    rotate(a = 270, v = [1, 0, 0])
                        rotate([90, 0, 90]) 
                            bearing_holder(X_bearings, center = true);

                    // Top bearing holder
                    translate([0, 0, x_bar_spacing()])
                        // cube([X_bearings_holder_length - 20, X_bearings_holder_width, X_bearings_holder_width], center = true);
                        // rotate(a = 270, v = [1, 0, 0])
                            rotate([90, 0, 90]) 
                                bearing_holder(X_bearings, center = true);
                        *rotate([90, 0, 90]) 
                            cylinder(r = X_bearings_holder_width / 2, h = X_bearings_holder_length, $fn = smooth, center=true);
                }

                // Main plate
                translate([0, -X_bearings_holder_width / 4, x_bar_spacing() / 2 + X_bearings_holder_width / 4 - X_smooth_rod_diameter / 8])
                    cube([X_bearings_holder_length, X_bearings_holder_width / 2, x_bar_spacing() + X_bearings_holder_width / 2 + X_smooth_rod_diameter / 4], center = true);

                for (z = [axle_height - 25, axle_height, axle_height + 25]) {
                    translate([0, -X_bearings_holder_width / 2 - 5, z])
                        rotate([0, 90, 180]) 
                            rail(X_bearings_holder_length, 15, 5);
                }
                translate([0, -X_bearings_holder_width / 2 - 5, axle_height - 50])
                    rotate([0, 90, 180]) 
                        halfrail(X_bearings_holder_length, 15, 5);

            }
            // Cutout in top bearing holder
            translate([0, ball_bearing_diameter(x_spectra_bearing) / 2, x_bar_spacing() - ball_bearing_diameter(x_spectra_bearing) / 2])
                cube([X_bearings_holder_length + eta, ball_bearing_diameter(x_spectra_bearing), ball_bearing_diameter(x_spectra_bearing)], center = true);

            // Bottom cutout for spectra line
            translate([0, 0, axle_height - 1.5 * ball_bearing_diameter(x_spectra_bearing) - 0.25])
                cube([X_bearings_holder_length + eta, spool_working_width() + 0.5, 1], center = true);

            // Cutouts for spectra line idlers && idler screw holes
            for (sign = [-1, 1]) {
                translate([sign * (X_bearings_holder_length / 2  - 2 * wall), 0, axle_height]) {
                    translate([sign * (624idler_outer_radius() + 1), 0, 0])
                        cube([(624idler_outer_radius() + 1) * 2, 624idler_width() + 1, (624idler_outer_radius() + 1) * 2], center = true);
                    rotate([0, 90, 90]) 
                        poly_cylinder(r = 624idler_outer_radius() + 1, h = 624idler_width() + 1, $fn = smooth, center = true);
                    rotate([90, 0, 0]) 
                        teardrop_plus(r = 4/2, h = 2 * X_bearings_holder_width + eta, center = true);
                        // nut_trap(M4_clearance_radius, nut_outer_radius(M4_nut), nut_depth(M4_nut));
                }
            }

            //Empty space for bearings and rods
            for (second = [0, x_bar_spacing()]) {
                translate([0, 0, second]) {
                    rotate([90, 0, 90]) 
                        rod(X_smooth_rod_diameter + 2, 200);
                    rotate([90, 0, 0]) 
                        for (i = [0, 2]) {
                            translate([(shelves_coordinate(X_bearings)[i] + shelves_coordinate(X_bearings)[i+1]) / 2 - bearings_holder_height(X_bearings) / 2, 0, 0])
                                linear_bearing(X_bearings);
                        }
                }
            }
        }
    }
}

module x_carriage_assembled() {
    color(x_end_bracket_color)
        render() 
            x_carriage();

    // X smooth rods with bearings
    for (second = [0, x_bar_spacing()]) {
        translate([0, 0 , second]) {
            rotate([90, 0, 90]) 
                rod(X_smooth_rod_diameter, 200);
                for (i = [0, 2]) {
                    translate([(shelves_coordinate(X_bearings)[i] + shelves_coordinate(X_bearings)[i+1]) / 2 - bearings_holder_height(X_bearings) / 2, 0, 0])
                        linear_bearing(X_bearings);
                }
        }
    }

    // Spectra line idlers
    for (sign = [-1, 1]) {
        translate([sign * (X_bearings_holder_length / 2  - 2 * wall), 0, axle_height]) {
            rotate([0, 90, 90]) {
                ball_bearing(BB624);
                624idler();
            }
        }
    }

    translate([- 45, -bearing_y_offset(), -(X_smooth_rod_diameter / 2 + wall)])
        x_motor_end_assembly();
        echo(str("Variable = ", X_bearings_holder_length));
}

x_carriage_assembled();