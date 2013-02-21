include <x-end.scad>
include <z-motor-bracket.scad>

z_motor_bracket_assembly();

translate([z_bar_spacing(), 0, 15]) {
    x_end_assembly();
}

