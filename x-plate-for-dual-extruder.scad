include <conf/config.scad>;
use <details/x-plate.scad>;

wall = thick_wall;

module x_plate_for_dual_extruder() {
    x_carriage_plate();
}
