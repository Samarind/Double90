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
                // Top bearing holder
                translate([0, 0, x_bar_spacing()])
                    rotate([90, 0, 90]) 
                        cylinder(r = bearing_outer_diameter(X_bearings) / 2 + 1.5 * wall, h = X_bearings_holder_length, $fn = smooth, center = true);

                // Main plate
                translate([0, 0, x_bar_spacing() / 2 + wall / 2 - wall])
                    cube([X_bearings_holder_length, bearing_outer_diameter(X_bearings) + 2 * 1.5 * wall, x_bar_spacing() + 2 * wall], center = true);

            }

            //Front rail cutout
            translate([0, -bearing_outer_diameter(X_bearings) / 2 - 1.5 * wall + 4, x_bar_spacing() / 2])
                rotate([0, 90, 0]) 
                    rail(X_bearings_holder_length + eta, 40, 4 + eta);

            //Back rail cutout
            translate([0, bearing_outer_diameter(X_bearings) / 2 + 1.5 * wall - 4, x_bar_spacing() / 2])
                rotate([90, 270, 90]) 
                    rail(X_bearings_holder_length + eta, 40, 4 + eta);

            // Slit
            translate([0, 0, x_bar_spacing() / 2])
                cube([X_bearings_holder_length + eta, 1, x_bar_spacing()], center = true);

            // Bottom cutout for spectra line
            translate([0, 0, axle_height - 1.5 * ball_bearing_diameter(x_spectra_bearing) - 0.25])
                cube([X_bearings_holder_length + eta, spool_working_width() + 2, 2], center = true);

            // Cutouts for spectra line idlers && idler screw holes
            for (sign = [-1, 1]) {
                translate([sign * (X_bearings_holder_length / 2  - 2 * wall), 0, axle_height]) {
                    translate([sign * (624idler_outer_radius() + 1), 0, 0])
                        cube([(624idler_outer_radius() + 1) * 2, 624idler_width() + 1, (624idler_outer_radius() + 1) * 2], center = true);
                    rotate([0, 90, 90]) 
                        poly_cylinder(r = 624idler_outer_radius() + 1, h = 624idler_width() + 1, $fn = smooth, center = true);
                    translate([0, -bearing_outer_diameter(X_bearings) / 2 - 1.5 * wall + 6.1, 0])
                        rotate([90, 0, 0]) 
                            poly_cylinder(r=screw_head_radius(M4_pan_screw), h=screw_head_height(M4_pan_screw) + 1, center = true);
                    translate([0, -(-bearing_outer_diameter(X_bearings) / 2 - 1.5 * wall + 5), 0])
                        rotate([90, 0, 0]) 
                            nut_trap(M4_clearance_radius, nut_outer_radius(M4_nut) + 0.1, nut_depth(M4_nut));
                }
            }

            // Central hole
            translate([-wall / 2 , 0, x_bar_spacing() / 2])
                rotate([90, 90, 0]) 
                    teardrop_plus(r = 13, h = X_bearings_holder_length + eta, truncate=false, $fn = smooth, center = true);
            

            //Empty space for bearings and rods
            for (second = [0, x_bar_spacing()]) {
                translate([0, 0, second])
                    rotate([90, 0, 90]) 
                        poly_cylinder(r = bearing_outer_diameter(X_bearings) / 2 + eta, h = X_bearings_holder_length + eta, $fn = smooth, center = true);
            }
        }

    }
}

module x_carriage_assembled() {
    color(x_end_bracket_color)
        render() 
            x_carriage();

    // X smooth rods with bearings
    *for (second = [0, x_bar_spacing()]) {
        translate([0, 0 , second]) {
            rotate([90, 0, 90]) 
                rod(X_smooth_rod_diameter, 97 * 2);
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

    // Idler screws
    for (sign = [-1, 1]) {
        translate([sign * (X_bearings_holder_length / 2  - 2 * wall), 0, axle_height]) {
            translate([0, -bearing_outer_diameter(X_bearings) / 2 - 1.5 * wall + 8.3, 0])
                rotate([90, 0, 0]) 
                    screw(M4_pan_screw, 20, center = true);
            translate([0, -(-bearing_outer_diameter(X_bearings) / 2 - 1.5 * wall + 5), 0])
                rotate([90, 0, 0]) 
                    nut(M4_nut);
        }

    }

    *translate([- 44, -bearing_y_offset(), -(X_smooth_rod_diameter / 2 + wall)])
        x_motor_end_assembly();

    *translate([56, -bearing_y_offset(), -(X_smooth_rod_diameter / 2 + wall)])
        translate([11, 0, 0])
            mirror([1, 0, 0]) {
                x_end_assembly();
            }

    *translate([0, -50, axle_height])
        rotate([0, -90, 0]) 
            NEMA(X_motor);
}

x_carriage_assembled();