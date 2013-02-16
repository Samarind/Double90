//
// Fastens the Z motor to the frame
//
include <conf/config.scad>
include <positions.scad>
// use <z-coupling.scad> 

rounded_corner_radius = 5;
thickness = 5;
x_overhang_over_motor = thickness * 2;
length = ceil(NEMA_width(Z_motor)) + x_overhang_over_motor;
back_thickness = part_base_thickness + (frame_nut_traps ? nut_trap_depth(frame_nut) : 0);
back_height = 24;
big_motor_hole = NEMA_big_hole(Z_motor);
clamp_height = washer_diameter(washer) + 4;
clamp_thickness = bar_clamp_band;
clamp_screw_clearance = 2;
clamp_length = Z_smooth_rod_diameter / 2 + bar_clamp_tab - 2;
smooth_rod_clamp_slot_width = 1.5;

clamp_width = Z_smooth_rod_diameter + 2 * clamp_thickness;

clamp_x = z_bar_offset() + clamp_length - bar_clamp_tab / 2;

module z_motor_bracket(y_offset) {
    width = y_offset + (length / 2);
    radius = ((back_height * back_height) + ((width/2) * (width/2))) / (2 * back_height); 
    color(z_motor_bracket_color) {
        difference() {
            union() {
                // Main body
                translate([0, 0, back_height / 2])
                difference() {
                    cube([length, width + 2*back_thickness, back_height], center = true);

                    translate([0, 0, thickness])
                       cube([length + eta, width, back_height], center = true);
                }

                // Supports
                difference() {
                    union() {
                        for(x = [(length  - x_overhang_over_motor - big_motor_hole) / 4, -((length + x_overhang_over_motor - big_motor_hole) / 4)]) {
                            translate([x, width / 2, thickness])
                                rotate([0, 0, -90])
                                    cube([width, thickness, back_height - thickness]);
                        }
                    }

                    rotate([90, 0, 90])
                        translate([0, radius+(thickness/2), -length/2])
                            cylinder(h = length - x_overhang_over_motor, r = radius, $fn = 200);
                }
                difference() {
                    union() {
                    // Z-rod clamp body
                    translate([z_bar_offset() + clamp_length / 2, 0, clamp_height / 2])
                        cube([clamp_length, clamp_width, clamp_height], center = true);
                    translate([z_bar_offset(), 0, clamp_height / 2])
                        cylinder(h = clamp_height, r = Z_smooth_rod_diameter / 2 + clamp_thickness, center = true);
                    }
                    // Hole for Z-rod
                    translate([z_bar_offset(), 0, clamp_height / 2 + thickness])
                       poly_cylinder(r = Z_smooth_rod_diameter / 2, h = 2 * clamp_height, center = true); 
                }
            }
            
            // Motor screw holes
            for(x = NEMA_holes(Z_motor))                                                         
                    for(y = NEMA_holes(Z_motor))
                        translate([x,y,0])
                            poly_cylinder(r = M3_clearance_radius, h = 2 * thickness + 1, center = true);

            // Central motor hole
            poly_cylinder(r = big_motor_hole, h = thickness * 3, center = true);

            // Z-rod clamp slot 
            translate([(length + 2*x_overhang_over_motor)/2, 0, 0]) 
                cube([clamp_length, smooth_rod_clamp_slot_width,  clamp_height * 2 + 1], center = true);
            // Clamp screw hole
            translate([clamp_x, Z_smooth_rod_diameter / 2 + clamp_thickness, clamp_height / 2])
                rotate([90, 0, 0])
                    nut_trap(screw_clearance_radius, nut_radius, nut_trap_depth, horizontal = true);  
            

            for(side = [-1, 1]) {
                // Screw slots in the back
                translate([side * (length / 2 - z_slot_inset + z_nut_offset), width - length / 2 - back_thickness,  back_height / 2 + thickness / 2])
                    rotate([90, 0, 0])
                        if(frame_nut_traps)
                            nut_trap(screw_clearance_radius(frame_screw), nut_radius(frame_nut), back_thickness - part_base_thickness, true);
                        else
                            vertical_tearslot(h = back_thickness * 2 + 1, l = back_height - thickness - 2 * z_slot_inset,
                                r = screw_clearance_radius(frame_screw), center = true);
                // screw slots in the front
                translate([side * (length / 2 - z_slot_inset + z_nut_offset), -width + length / 2 + back_thickness,  back_height / 2 + thickness / 2])
                    rotate([90, 0, 0])
                        if(frame_nut_traps)
                            nut_trap(screw_clearance_radius(frame_screw), nut_radius(frame_nut), back_thickness - part_base_thickness, true);
                        else
                            vertical_tearslot(h = back_thickness * 2 + 1, l = back_height - thickness - 2 * z_slot_inset,
                                r = screw_clearance_radius(frame_screw), center = true);
            }
            
            // rounded corners
            translate([-length / 2, 0, back_height])
                rotate([-90, 0, 0])
                    fillet(r = rounded_corner_radius, h = width*2);
            translate([length / 2, 0, back_height])
                rotate([-90, 90, 0])
                    fillet(r = rounded_corner_radius, h = width*2);      
        }
    }

    //Motor
    NEMA(Z_motor);

}

z_motor_bracket(gantry_setback);
