include <conf/config.scad>;
use <624-idler.scad>

module x_carriage() {
}

module x_carriage_assembled() {
    x_carriage();

    // X smooth rods with bearings
    for (second = [0, x_bar_spacing()]) {
        translate([0, 0 , second]) {
            rotate([90, 0, 90]) 
                rod(X_smooth_rod_diameter, 200);
                for (offset = [-20, 20]) {
                    translate([offset, 0, 0]) 
                        linear_bearing(X_bearings);
                }
        }
    }
}

x_carriage_assembled();