include <../conf/config.scad>;

bearing_holder_wall = 2.5;
shelf_thickness = 2;
shelf_clearance = 0.2; // distance between top of bearing and a shelf

function bearing_outer_diameter(bearing_type) = bearing_type[1] + 0.2;
function bearings_holder_width(bearing_type) = bearing_outer_diameter(bearing_type) + 2 * bearing_holder_wall;
function bearings_holder_height(bearing_type) = max( min(65, 2.8 * bearing_type[0]), 2 * (bearing_type[0] + shelf_clearance) + 3 * shelf_thickness);
function shelves_coordinate(bearing_type) = [ shelf_thickness / 2, // shelve at the bottom
                            shelf_thickness + bearing_type[0] + shelf_clearance + shelf_thickness / 2, // shelve at the top of bottom bearing
                            bearings_holder_height(bearing_type) - shelf_thickness / 2, // shelve at the bottom of top bearing
                            bearings_holder_height(bearing_type) - (shelf_thickness + bearing_type[0] + shelf_clearance + shelf_thickness / 2) ]; // shelve at the top

module bearing_holder (bearing_type) {
    bearing_depth = bearings_holder_width(bearing_type) / 2;
    smooth_rod_diameter = bearing_type[2];
    shelf_depth = bearing_depth - (smooth_rod_diameter / 2 + 1);

    // Shelves for bearings
    intersection() {
        for(z = shelves_coordinate(bearing_type)) {
            translate([-bearing_depth + shelf_depth / 2, 0, z])
                cube([shelf_depth, bearing_outer_diameter(bearing_type), shelf_thickness], center = true);
        }
        cylinder(h = bearings_holder_height(bearing_type), r = bearings_holder_width(bearing_type) / 2, $fn = smooth);
    }

    difference() {
        union() {
            // Bearings holder
            translate([0, 0, bearings_holder_height(bearing_type) / 2])
                cylinder(h = bearings_holder_height(bearing_type), r = bearings_holder_width(bearing_type) / 2, $fn = smooth, center = true);
        }
        //Hole for bearings
        translate([0, 0, -1])
            poly_cylinder(h = bearings_holder_height(bearing_type) + 1 + eta, r = bearing_outer_diameter(bearing_type) / 2);

        //Front entry cut out
        translate([bearing_outer_diameter(bearing_type) / 2, 0, bearings_holder_height(bearing_type) / 2])
            rotate([0, 0, 45])
                cube([bearing_outer_diameter(bearing_type), bearing_outer_diameter(bearing_type), bearings_holder_height(bearing_type) + 1], center = true);
    }      
}

module empty_space_for_bearing_holder (bearing_type) {
    translate([0, 0, bearings_holder_height(bearing_type) / 2])
                cylinder(h = bearings_holder_height(bearing_type) + eta, r = bearings_holder_width(bearing_type) / 2 + eta / 2, $fn = smooth, center = true);
}

// bearing_holder(X_bearings);