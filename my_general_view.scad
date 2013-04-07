use <x-end.scad>
use <x-motor-end.scad>
use <z-motor-bracket.scad>
use <x-carriage.scad>
use <z-top.scad>
use <Gregs/jonaskuehling_gregs-wade-v3.scad>
include <conf/config.scad>

z_height = 350;

translate([220, -55, 400])
    rotate([90, 0, 180])   {
        translate([11, 38, -14.5]) 
            import("Gregs/biggearmod_fixed.stl");
        wade(hotend_mount=arcol_mount, legacy_mount=false);
        translate([50, 37, 8]) 
            rotate(20)
                rotate([180, 0, 0]) {
                    NEMA(X_motor);
                    translate([0, 0, 2]) 
                    import("Gregs/smallgearmod_fixed.stl");
                }
    }

*translate([10, -z_axis_offset, -35]) {
    rotate([0, 270, 0]) 
        z_motor_bracket_assembly();
    rotate([0, 0, 180])   
        translate([24.5, 0, 480])
            z_top();
}

*translate([220, -8.5, -124])
    psu(psu);

*translate([0, 0, z_height])
    x_motor_end_assembly(); 



*for (sign = [-1, 1]) {
// FRAME
%translate([220, sign * frame_sheets_distance / 2 - z_axis_offset + sign * 5, 200])
    difference() {
        translate([-25, 0, 0])
            cube([630, 10, 650], center=true);
        // Window
        translate([0, 0, -50 + 40])
            cube([400, 11, 450 + 80], center=true);
    }
}

*translate([220, bearing_y_offset(), x_rod_clamp_width() / 2 + z_height])
    x_carriage_assembled();


*translate([430, 0, 0]) {
        translate([11, 0, z_height])
            mirror([1, 0, 0])
                x_end_assembly();

        translate([0, -z_axis_offset, -35]) 
            mirror([0, 1, 0])
                rotate([180, 270, 0]) 
                    z_motor_bracket_assembly();

        translate([24.5, -z_axis_offset, 480 - 35])
            mirror([0, 1, 0])
                z_top();
}


