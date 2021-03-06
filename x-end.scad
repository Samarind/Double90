// End of the X axis
include <conf/config.scad>;
use <624-idler.scad>;
use <details/bearing-holder.scad>;

wall = thick_wall; 

Z_bearing_holder_width = bearings_holder_width(Z_bearings);

Z_bearings_holder_height = bearings_holder_height(Z_bearings); 

anti_backlash_wall_radius = Z_nut_radius + 0.2;
anti_backlash_wall_width = max(3, Z_bearing_holder_width / 2 - wall - cos(30) * anti_backlash_wall_radius + 0.5);
anti_backlash_wall_height = nut_thickness(Z_nut);

base_thickness = nut_depth(Z_nut) + 2 * wall;
clamp_length = z_bar_spacing();
clamp_width = X_smooth_rod_diameter + 2 * wall;

spectra_bearing_height_position = clamp_width + ball_bearing_diameter(x_spectra_bearing) / 2 + 4.5;
bearing_y_offset = X_smooth_rod_diameter / 2 + Z_bearing_holder_width / 2;

function x_rod_clamp_length() = clamp_length;
function x_rod_clamp_width() = clamp_width;
function spectra_bearing_height_position() = spectra_bearing_height_position;
function bearing_y_offset() = bearing_y_offset;


module x_end_assembly() {
    color(x_end_bracket_color)
        render() 
            x_end();

    // Z leadscrew nut
    if (is_hex(Z_nut)) {
            // Hex nut
    } else {
        if (is_flanged(Z_nut)) {
            // Round flanged nut
            translate([-z_bar_spacing(), 0, 100])
                rotate([0, 180, 20])
                    flanged_nut(Z_nut);
        } else {
            // Round nut
            translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 - wall])
                round_nut(Z_nut, brass = true, center = true);
        }
    }
    
    //Spectra line tensioning screw
    translate([0, bearing_y_offset, spectra_bearing_height_position + 1.5 * ball_bearing_diameter(x_spectra_bearing)])
        rotate([90, 90, 90])
            color(screw_cap_color)
                render()
                    screw(M3_pan_screw, 30, center = true);

    // Spectra line bearing
    translate([-clamp_length * 3 / 4 + wall, bearing_y_offset, spectra_bearing_height_position])
        rotate([0, 90, 90]) {
            ball_bearing(BB624);
            624idler();
        }

    // Spectra line idler screw
    translate([-clamp_length * 3 / 4 + wall , clamp_width + Z_bearing_holder_width / 2 - wall, spectra_bearing_height_position])
        rotate([0, 90, 90]) 
            screw_and_washer(M4_pan_screw, screw_longer_than(clamp_width), center = true);

    // Z bearings
    for(i = [0, 2]) {
        translate([0, 0, (shelves_coordinate(Z_bearings)[i] + shelves_coordinate(Z_bearings)[i+1])/2 ])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
    }

    // X smooth rods with bearings
    *for (second = [0, x_bar_spacing()]) {
        translate([-clamp_length + 60, bearing_y_offset, clamp_width / 2 + second]) {
            rotate([90, 0, 90]) 
                rod(X_smooth_rod_diameter, 100);
                linear_bearing(X_bearings);
        }
    }
}

module x_end() {
    slit = 0.5;
    union() {
        bearing_holder(Z_bearings);

        difference() {
            union() {
                // X rods holders vertical block
                translate([-clamp_length / 2 , bearing_y_offset, (x_bar_spacing() + clamp_width) / 2]) {
                    difference() {
                        cube([clamp_length, clamp_width, x_bar_spacing() + wall], center = true);
                        translate([0, 0, -X_smooth_rod_diameter / 2 + wall / 2])
                            cube([clamp_length + eta, X_smooth_rod_diameter - wall, x_bar_spacing() - clamp_width], center = true); 
                        translate([ 1.5 * wall, 0, -(x_bar_spacing() + clamp_width) / 2 + spectra_bearing_height_position + 1.5 * ball_bearing_diameter(x_spectra_bearing) - 1.5])
                            rotate([90, 0, 90])  
                                teardrop(h = clamp_length - 1.5 * wall + eta, r = (X_smooth_rod_diameter - wall) / 2, truncate=false, $fn = smooth, center = true);  
                    }
                    difference() {
                        // Spectra line tensioner plate 
                        translate([ -clamp_length / 2 + (clamp_length / 2 - 1.5 * wall) / 2, 0, (x_bar_spacing() - 1.5 * clamp_width) / 2 - wall / 2])
                            cube([clamp_length / 2 - 1.5 * wall, X_smooth_rod_diameter - wall, X_smooth_rod_diameter + wall], center = true);
                        translate([ -clamp_length / 2 + (clamp_length / 2 - 1.5 * wall) / 2, 0, (x_bar_spacing() - 1.5 * clamp_width) / 2 - wall / 2 - (X_smooth_rod_diameter + wall) / 2])
                            rotate([90, 0, 90])  
                                teardrop(h = clamp_length + eta, r = (X_smooth_rod_diameter - wall) / 2, truncate=false, $fn = smooth, center = true);  
                    }
                }

                // Z nut holder
                if (is_hex(Z_nut)) {
                    translate([-z_bar_spacing(), 0, anti_backlash_wall_height / 2])
                        rotate([0, 0, 90])                    
                            cylinder(r = anti_backlash_wall_radius + anti_backlash_wall_width, h = anti_backlash_wall_height, $fn = 6, center = true);
                } else if (is_flanged(Z_nut)) {
                } else { 
                    translate([-z_bar_spacing(), 0, (base_thickness- wall ) / 2])
                        cylinder(h = base_thickness- wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                    translate([-z_bar_spacing() + Z_nut_radius + z_bar_spacing() / 4 + wall / 2, 0, base_thickness / 2])
                        cube([z_bar_spacing() / 2 + wall, Z_bearing_holder_width, base_thickness], center = true);

                    translate([-z_bar_spacing(), 0, base_thickness - wall / 2]) {
                        rotate ([0, 0, 90]) {
                            intersection() {
                                cylinder(h = wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                                union() {
                                    // Right thin bar
                                    translate([-Z_screw_diameter / 2 - (wall - 1) / 2 - 0.5, 0, 0])
                                        cube([wall - 0.5, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    // Left thicker cover
                                    translate([Z_screw_diameter / 2 + wall + 0.5, 0, 0])
                                        cube([wall * 2, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    difference() {
                                        cylinder(h = wall, r = Z_nut_radius + anti_backlash_wall_width, $fn = smooth, center = true);
                                        cylinder(h = wall + eta, r = Z_nut_radius, $fn = smooth, center = true);
                                        translate([-Z_screw_diameter / 2 - (wall * 3) / 2 - 0.5, 0, 0])
                                            cube([wall * 3, (Z_nut_radius + anti_backlash_wall_width) * 2, wall], center = true);
                                    }
                                }
                            }
                        }
                    }

                    // Large triangles
                    for (y = [Z_nut_radius - wall + 0.5 / 2, -Z_nut_radius + wall]) {
                        translate([(-z_bar_spacing() + Z_screw_diameter / 2 + 1.5 * wall) / 2, y, base_thickness]) 
                            rotate([90, 0, 180]) 
                                right_triangle(width = z_bar_spacing(),  height = Z_bearings_holder_height - base_thickness, h = wall - 0.5, center = true);
                    }

                    // Bottom connection 
                    translate([-z_bar_spacing() + Z_nut_radius - wall, -Z_bearing_holder_width / 4, wall / 2])
                        cube([Z_screw_diameter, Z_bearing_holder_width / 2, wall], center = true);
                }

                // Small triangle
                translate([-clamp_length + 0.1, Z_nut_radius + 0.1, base_thickness]) 
                    rotate([90, 0, 180]) 
                        right_triangle(width = wall + 1,  height = x_bar_spacing() - X_smooth_rod_diameter / 2 - wall, h = wall, center = true);

                // Bottom X rod holder
                translate([-clamp_length / 2 , bearing_y_offset , 0]) {
                    translate([0, 0, clamp_width / 2])
                        rotate([90, 0, 90])
                            teardrop(r = clamp_width / 2, h = clamp_length, center = true);

                    translate([0, 0, clamp_width / 2])
                        cube([clamp_length, clamp_width, clamp_width], center = true);   
                }

                // Top X rod holder
                translate([-clamp_length / 2 , bearing_y_offset , clamp_width / 2 + x_bar_spacing() + wall / 2]) {
                    rotate([90, 0, 90])
                        cylinder(h = clamp_length, r = clamp_width / 2, $fn = smooth, center = true);
                }
            }

            // Had to add this to insert Z bearing holder
            empty_space_for_bearing_holder(Z_bearings);

            // Holes for X rods
            for (second = [0, x_bar_spacing()]) {
                translate([-clamp_length / 2, bearing_y_offset, clamp_width / 2 + second]) 
                    rotate([90, 0, 90])
                        cylinder(r = X_smooth_rod_diameter / 2, h = clamp_length * 4, center = true);
            }

            // Vertical slit in X rods holder's block
            translate([-clamp_length / 2, bearing_y_offset, x_bar_spacing() / 2 ]) 
                cube([clamp_length + 1, slit, x_bar_spacing() + clamp_width / 2], center = true);

            // Hole for Z leadscrew
            translate([-z_bar_spacing(), 0, Z_bearings_holder_height / 2])
                poly_cylinder(r = Z_screw_diameter / 2, h = 2 * Z_bearings_holder_height + eta, $fn = smooth, center = true);

            //Hole for Z leadscrew nut
            if (is_hex(Z_nut)) {
                // Hex nut
                translate([-z_bar_spacing(), 0, base_thickness / 2])
                    cylinder(r = anti_backlash_wall_radius, h = base_thickness + eta, $fn = 6, center = true);
            } else if (is_flanged(Z_nut)) {
                    //Flanged nut
                    translate([-z_bar_spacing(), 0, 0])
                        poly_cylinder(r = Z_nut_radius + 0.2, h = nut_depth(Z_nut) + eta, $fn = smooth);
                    translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 - flanged_nut_flange_thickness(Z_nut) / 2 - 0.1])
                        rotate([0, 0, 23]) {
                            flanged_nut(Z_nut);
                            rotate([0, 0, 120]) {
                                translate ([flanged_nut_hole_distance_radius(Z_nut), 0, base_thickness / 2])
                                    poly_cylinder (r = flanged_nut_mounting_hole_radius(Z_nut), h = 2 * flanged_nut_barrel_thickness(Z_nut) + 0.1, center = true);
                                translate ([-flanged_nut_hole_distance_radius(Z_nut), 0, base_thickness / 2])
                                    poly_cylinder (r = flanged_nut_mounting_hole_radius(Z_nut), h = 2 * flanged_nut_barrel_thickness(Z_nut) + 0.1, center = true);
                            }           
                        }
            } else {
                //Round nut
                translate([-z_bar_spacing(), 0, nut_depth(Z_nut) / 2 + wall]) 
                    poly_cylinder(r = Z_nut_radius, h = nut_depth(Z_nut) + 0.1, $fn = smooth, center = true);
                translate([-z_bar_spacing(), - Z_nut_radius / 2 - wall, nut_depth(Z_nut) / 2 + wall])
                    cube([(Z_nut_radius + 0.1) * 2, Z_nut_radius + 2 * wall, nut_depth(Z_nut) + 0.1], center = true);
            }

            // Endstop mount
            translate([-wall, clamp_width / 2 + Z_bearing_holder_width / 2 + wall, spectra_bearing_height_position + 1.5 * ball_bearing_diameter(x_spectra_bearing) - microswitch_slot_length() / 2])
                rotate([90, 90, 0]) {
                    microswitch_slot();
                }

            // Hole for spectra line bearing screw
            translate([-clamp_length * 3 / 4 + wall, bearing_y_offset, spectra_bearing_height_position])
                rotate([90, 0, 0]) 
                   teardrop_plus(r = 4/2, h = 2 * clamp_width + eta, center = true);

            // Hole for spectra line tensioning screw
            translate([-clamp_length / 2, bearing_y_offset, spectra_bearing_height_position + 1.5 * ball_bearing_diameter(x_spectra_bearing)])
                rotate([90, 90, 90]) 
                    translate([0, 0, -clamp_length / 2])
                        nut_trap(M3_clearance_radius, nut_outer_radius(M3_nut), nut_depth(M3_nut));
        }
    }
}

mirror([1, 0, 0]) {
    x_end_assembly();
}
