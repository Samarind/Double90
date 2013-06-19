include <conf/config.scad>
use <details/bearing-holder.scad>

y_bearing_mount_assembled();

module y_bearing_mount_assembled() {
    y_bearing_mount(100);
}

module y_bearing_mount(y_bearings_distance) {
    for (offset = [y_bearings_distance / 2, -y_bearings_distance / 2]) {
        // rotate([0, -90, 0]) {
            difference() {
                // Square base of bearing holders
                translate([-bearings_holder_width(Y_bearings) / 4, 0, - offset])
                    cube([bearings_holder_width(Y_bearings) / 2 + eta, bearings_holder_width(Y_bearings) + eta, single_bearing_holder_height(Y_bearings) - eta], center=true);
                translate([0, 0, -single_bearing_holder_height(Y_bearings) / 2 - offset]) 
                    empty_space_for_single_bearing_holder(Y_bearings);
            }
            // Bearing holders
            translate([0, 0, -single_bearing_holder_height(Y_bearings) / 2 - offset]) 
                single_bearing_holder(Y_bearings);

            // Connection
            translate([-bearings_holder_width(Y_bearings) / 2 + shelf_depth(Y_bearings) /2, 0, 0])
                cube(size=[shelf_depth(Y_bearings), bearings_holder_width(Y_bearings), y_bearings_distance - single_bearing_holder_height(Y_bearings) + eta], center=true);
            // }
    }
}