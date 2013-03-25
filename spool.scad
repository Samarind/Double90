include <conf/config.scad>;

radius = 11;
width = 11;
top_height = 5;

function spool_working_width() = width;

module spool() {
    difference() {
        union() {
            // Main spool body
            cylinder(r = radius, h = width, center = true, $fn=smooth);
            // Right wall    
            *translate([0, 0, (width + 2) / 2])
                cylinder(r1 = radius, r2 = radius + 2, h = 2, center = true, $fn=smooth);
            // Left wall    
            translate([0, 0, (-width - 2) / 2])
                cylinder(r2 = radius, r1 = radius + 2, h = 2, center = true, $fn=smooth);
            // Thick motor shaft mounting part
            translate([0, 0, (width + top_height) / 2 ])
                cylinder(r = radius + 2, h = top_height, center = true, $fn=smooth);
        }
        // Motor shaft.
        cylinder(r = NEMA_shaft_radius(X_motor) + 0.1, h = 50, center = true, $fn=24);

        // Spectra line tunnels.
        translate([0, radius, width / 2 - 0.5]) 
            rotate([-5, 0, 0])
                cube([1, 2 * radius, 1], center=true);
        translate([0, radius, -width / 2 + 0.5]) 
            rotate([25, 0, 0])
                cube([1, 2 * radius, 1], center = true);
        translate([0, 5, 0])
            cylinder(r = 0.6, h = 40, center = true, $fn=6);

        // M3 screws and nuts on three sides.
        for (a = [0:120:359]) {
            rotate([0, 0, a]) 
                translate([0, 4.5, width / 2 + 2.5]) 
                    rotate([90, 0, 0]) {
                        cylinder(r = screw_radius(small_screw), h = radius + 5, center = true, $fn=12);
                        translate([0, 0, 1 - radius]) 
                            cylinder(r = 10, h = 6, center = true);
                        for (z = [0:10]) {
                            translate([0, z, 1.5]) 
                                rotate([0, 0, 30])
                                    cylinder(r = nut_radius(small_nut), h = 5, center = true, $fn=6);
                        }
                    } 
        }
    }
}

module spool_assembly() {
    spool();
}

spool();