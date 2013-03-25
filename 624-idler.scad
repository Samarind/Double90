include <conf/config.scad>;

inner_radius = ball_bearing_diameter(BB624) / 2 + 0.1;
outer_radius = ball_bearing_diameter(BB624PRINTED) / 2;
sides_height = 0.5;
height = ball_bearing_width(BB624PRINTED);

module idler() {
    difference() {
        union() {
            // Main idler body
            cylinder(r = outer_radius, h = height, center = true, $fn=smooth);
            // Walls
            translate([0, 0, height / 4 + 0.25 ]) 
                cylinder(r1 = outer_radius, r2 = outer_radius + sides_height, h = height / 2 - 0.5, center = true, $fn=smooth);
            translate([0, 0, -height / 4 - 0.25 ]) 
                cylinder(r1 = outer_radius + sides_height, r2 = outer_radius, h = height / 2 - 0.5, center = true, $fn=smooth);
        }
        // Hole
        cylinder(r = inner_radius, h = height + eta, center = true, $fn=smooth);
    }
}

module idler_assembly() {
    idler();
}

// idler();