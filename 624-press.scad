include <conf/config.scad>;

function 624_press_outer_radius() = ball_bearing_diameter(BB624PRINTEDPRESS) / 2 + 0.5;
function 624_press_width() = ball_bearing_width(BB624PRINTEDPRESS);

module 624_press() {
    inner_radius = ball_bearing_diameter(BB624) / 2 + 0.05;
    outer_radius = ball_bearing_diameter(BB624PRINTEDPRESS) / 2;

    difference() {
        union() {
            // Main idler body
            cylinder(r = outer_radius, h = 624_press_width(), center = true, $fn=smooth);
        }
        // Hole
        cylinder(r = inner_radius, h = 624_press_width() + eta, center = true, $fn=smooth);
    }
}

