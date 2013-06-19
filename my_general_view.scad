use <x-end.scad>
use <x-motor-end.scad>
use <z-motor-bracket.scad>
use <x-carriage.scad>
use <z-top.scad>
use <extruder.scad>
use <y-carriage.scad>
include <conf/config.scad>

z_height = 350;

*translate([10, -z_axis_offset, -35]) {
    rotate([0, 270, 0]) 
        z_motor_bracket_assembly();
    rotate([0, 0, 180])   
        translate([24.5, 0, 480])
            z_top();
}

// PSU
translate([220, -13.5, -124])
    psu(psu);

// Y axis
translate([0, 0, -19]) {
    // Hotbed
    translate([220, -hotend_y_offset + bearing_y_offset(), -20])
        cube(size=[350, 350, 10], center=true);

    // Y rods
    translate([220, -hotend_y_offset + bearing_y_offset(), -45])
        for (sign=[1, -1]) {
            translate([sign * 150, 0, 0])
                rotate([90, 0, 0]) {
                    rod(X_smooth_rod_diameter, 500);
                }
            
            translate([sign * 120, 0, -40])
                rotate([90, 0, 0]) {
                    rod(Z_screw_diameter, 500);
                }
    }
}

// Frame
for (sign = [-1, 1]) {
    color(sheet_colour(PMMA10))
        render() 
            translate([220, sign * frame_sheets_distance / 2 - z_axis_offset + sign * 5, 200])
                difference() {
                    translate([-25, 0, 0])
                        cube([630, 10, 650], center=true);
                    // Windows
                    translate([0, 0, -50 + 40])
                        cube([400, 11, 450 + 80], center=true);
                }
}

*translate([0, 0, 0]) {
    translate([220, bearing_y_offset(), x_rod_clamp_width() / 2])
        x_carriage_assembled();

    x_motor_end_assembly();

    *translate([441, 0, 0])
        mirror([1, 0, 0])
            x_end_assembly();

    // Extruder
    translate([237, -31.9, 68.8])
        rotate([90, 90, 180])  
            rotate(180)
                dual_extruder_assembled();
}

*translate([430, 0, 0]) {
    translate([0, -z_axis_offset, -35]) 
        mirror([0, 1, 0])
            rotate([180, 270, 0]) 
                z_motor_bracket_assembly();

    translate([24.5, -z_axis_offset, 480 - 35])
        mirror([0, 1, 0])
            z_top();
}


