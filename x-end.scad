//
// End of the X axis
//
include <conf/config.scad>
use <z-motor-bracket.scad>

bearing_wall = 2.3;

bearing_outer_diameter = Z_bearings[1] + 0.2;
bearing_holder_width = bearing_outer_diameter + 2 * bearing_wall;
bearing_depth = bearing_holder_width / 2 + 1;
bearing_length = Z_bearings[0];

shelf_thickness = 2;
shelf_clearance = 0.5;

bearings_system_height = max( min(65, 2.8 * bearing_length), 2 * (bearing_length + shelf_clearance) + 3 * shelf_thickness);
echo(str("bearings_system_height = ", bearings_system_height));

shelves = [ shelf_thickness / 2,
            shelf_thickness + bearing_length + shelf_clearance + shelf_thickness / 2,
            bearings_system_height - shelf_thickness / 2,
            bearings_system_height - (shelf_thickness + bearing_length + shelf_clearance + shelf_thickness / 2) ];

actuator_width = 4;
actuator_depth = 3;
actuator_height = 10;

module z_linear_bearings() {
    smooth_rod_diameter = Z_bearings[2];
    shelf_depth = bearing_depth - (smooth_rod_diameter / 2 + 1);

    union() {
        difference(){
            union(){
                //main vertical block
                translate([-bearing_depth / 2, 0, bearings_system_height / 2])
                    cube([bearing_depth, bearing_holder_width, bearings_system_height], center = true);

                cylinder(h = bearings_system_height, r = bearing_holder_width / 2);

                //actuator
                // *translate([-bearing_depth + eta, 0, bearings_system_height - eta])
                //     rotate([-90, 0, 0])
                //         right_triangle(width = -actuator_depth, height = actuator_height, h = actuator_width, center = true);

            }
            //Hole for bearings
            translate([0, 0, -1])
                poly_cylinder(h = bearings_system_height + 2, r = bearing_outer_diameter / 2);

            //Front entry cut out
            translate([bearing_outer_diameter/2, 0, bearings_system_height / 2])
                rotate([0, 0, 45])
                    cube([bearing_outer_diameter, bearing_outer_diameter, bearings_system_height + 1], center = true);

        }
        // Shelves for bearings
        for(y = shelves)
            translate([-bearing_depth + shelf_depth / 2 + eta, 0, y])
                cube([shelf_depth, bearing_holder_width, shelf_thickness], center = true);
    }
}

wall = thick_wall;                          // 4mm on Mendel and Sturdy, 3mm on Huxley
back = -ceil(z_bar_offset() + Z_nut_radius + wall);
front = -(Z_smooth_rod_diameter / 2 + 1);
length = front - back;
thickness = X_bar_dia + 2 * wall;

function anti_backlash_height() = 24 + thickness / 2;
anti_backlash_radius = Z_nut_radius + 0.2;
anti_backlash_wall = max(3, bearing_holder_width / 2 - wall - cos(30) * anti_backlash_radius + 0.5);

module x_end_bracket(){
    color(x_end_bracket_color) {
        translate([0, 0, - thickness / 2])
            z_linear_bearings();

        difference() {
            union() {
                // Base
                translate([front - length / 2, 0, 0])
                    cube([length, bearing_holder_width, thickness], center = true);
                // Anti-backlash nut holder
                translate([-z_bar_offset(), 0, thickness / 2 - eta])
                    cylinder(r = anti_backlash_radius + anti_backlash_wall, h = anti_backlash_height() - thickness, $fn = 6);

                //Triangular support
                // translate([-bearing_depth + eta, (bearing_holder_width - wall - eta) / 2 , thickness / 2 - eta])
                //     rotate([90, 0, 0])
                //         #right_triangle(width = back + bearing_depth, height = bearings_system_height - thickness, h = wall);

            }

            // Cut out for bearing holder
            cube([bearing_depth * 2 -eta, bearing_holder_width - eta, thickness + 10], center = true);
            
            // Hole for Z leadscrew
            translate([-z_bar_offset(), 0, -thickness / 2])
                nut_trap((Z_screw_dia + 1) / 2, Z_nut_radius, Z_nut_depth);
            translate([-z_bar_offset(), 0, thickness / 2 + eta])
                cylinder(r = anti_backlash_radius, h = bearings_system_height, $fn = 6);
        }
    }
}

module x_end_assembly() {
    color(x_end_bracket_color)
     render() x_end_bracket();
    
    translate([-z_bar_offset(), 0, 2*thickness])
        rod(Z_screw_dia, 135);
    translate([0, 0, 2*thickness])
        rod(Z_smooth_rod_diameter, 170);

    // bearings
    for(i = [0,2])
        translate([0, 0, (shelves[i] + shelves[i+1])/2 - thickness / 2])
            rotate([0,90,0])
                linear_bearing(Z_bearings);
}

x_end_assembly();
