include <../conf/config.scad>;
use <../details/bearing-holder.scad>;

wall = thick_wall;
X_bearings_holder_length = bearings_holder_height(X_bearings);

x_carriage_plate();

module x_carriage_plate() {
    difference() {
        union() {
            difference() {
                union() {
                    // Top bearing holder
                    translate([0, 0, x_bar_spacing()])
                        rotate([90, 0, 90]) 
                            cylinder(r = bearing_outer_diameter(X_bearings) / 2 + 2 * wall, h = X_bearings_holder_length, $fn = smooth, center = true);

                    // Main plate
                    translate([0, 0, x_bar_spacing() / 2 + wall / 2 - wall])
                        cube([X_bearings_holder_length, bearing_outer_diameter(X_bearings) + 4 * wall, x_bar_spacing() + 2 * wall], center = true);

                }
                // Cutout
                translate([0, 0, x_bar_spacing()])
                    rotate([90, 0, 90]) 
                        cylinder(r = bearing_outer_diameter(X_bearings) / 2 + wall, h = X_bearings_holder_length + 1, $fn = smooth, center = true);
                translate([0, 0, x_bar_spacing() / 2 + wall / 2 - wall - 1])
                    cube([X_bearings_holder_length + 1, bearing_outer_diameter(X_bearings) + 2 * wall, x_bar_spacing() + 2 * wall + 2], center = true);
                translate([0, 0, (x_bar_spacing() / 2 - 20 - wall ) / 2])
                    cube([X_bearings_holder_length + 2, bearing_outer_diameter(X_bearings) + 4 * wall + 2, x_bar_spacing() / 2 - 20 + 2 * wall + eta], center = true);
            }

            //Front rail 
            translate([0, -bearing_outer_diameter(X_bearings) / 2 - wall + 4 - 0.1, x_bar_spacing() / 2])
                rotate([0, 90, 0]) 
                    rail(X_bearings_holder_length, 40 - 0.2, 4 - 0.1);

            //Back rail 
            translate([0, bearing_outer_diameter(X_bearings) / 2 + wall - 4 + 0.1, x_bar_spacing() / 2])
                rotate([90, 270, 90]) 
                    rail(X_bearings_holder_length, 40, 4 - 0.1);
        }
        translate([0, bearing_outer_diameter(X_bearings) / 2 + wall, x_bar_spacing() / 2 - wall])
            cube([X_bearings_holder_length + 2, 3 * wall, x_bar_spacing() / 2], center = true);
    }
}

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

