include <conf/config.scad>;

function 624idler_outer_radius() = ball_bearing_diameter(BB624PRINTED) / 2 + 0.5;
function 624idler_width() = ball_bearing_width(BB624PRINTED);

module 624idler() {
    inner_radius = ball_bearing_diameter(BB624) / 2 + 0.05;
    outer_radius = ball_bearing_diameter(BB624PRINTED) / 2;

    difference() {
        union() {
            // Main idler body
            cylinder(r = outer_radius, h = 624idler_width(), center = true, $fn=smooth);
            // Walls
            translate([0, 0, 624idler_width() / 4 + 0.25 ]) 
                cylinder(r1 = outer_radius, r2 = 624idler_outer_radius(), h = 624idler_width() / 2 - 0.5, center = true, $fn=smooth);
            translate([0, 0, -624idler_width() / 4 - 0.25 ]) 
                cylinder(r1 = 624idler_outer_radius(), r2 = outer_radius, h = 624idler_width() / 2 - 0.5, center = true, $fn=smooth);
        }
        // Hole
        cylinder(r = inner_radius, h = 624idler_width() + eta, center = true, $fn=smooth);
    }
}

module idler_assembly() {
    624idler();
}

// idler();