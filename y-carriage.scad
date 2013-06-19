include <conf/config.scad>
use <y-bearing-mount.scad>



y_carriage_assembled();

module y_carriage_assembled() {
    // Bed
    bed_assembled();

    translate([0, 0, -sheet_thickness(frame) / 2])
        y_carriage();
    
    translate([0, 0, -40])
        for (sign=[1, -1]) {
                // Y smooth rod
                translate([sign * 150, 0, 0])
                    rotate([90, 0, 0]) 
                        rod(Y_smooth_rod_diameter, 500);
                
                // holder - screw
                translate([sign * 120, 0, -20])
                color(sheet_colour(frame))
                    render() 
                        cube(size=[10, 500, 40], center=true);
        }
}

module y_carriage() {
    sheet(frame, bed_width, bed_depth);

    translate([0, 0, -sheet_thickness(frame) / 2])
        bearing_mount(Y_bearings, 50);
}

module bed_assembled() {

    for(distance = [-bed_holes / 2, bed_holes /2]) {
        translate([distance, -distance, 0])
            washer(M3_washer);

        translate([distance, distance , 0])
            washer(M3_washer);

        for(y = [-bed_holes / 2, bed_holes /2])
            translate([distance, y, washer_thickness(M3_washer)]) {
                hex_pillar(bed_pillars);

                translate([0,0, pillar_height(bed_pillars) + pcb_thickness])
                    screw(M3_cap_screw, 10);
            }
    }

    
    translate([0, 0, washer_thickness(M3_washer)]) {
        // PCB or other heater
        translate([0,0, pillar_height(bed_pillars) + pcb_thickness / 2])
            color(bed_color) 
                cube([bed_width, bed_depth, pcb_thickness], center = true);

        // Glass
        translate([0,0, pillar_height(bed_pillars) + pcb_thickness + sheet_thickness(bed_glass) / 2 + eta * 3])
            sheet(bed_glass, bed_width, bed_depth - 15);

        // Clips  
        for(x = [-1, 1])
            for(y = [-1,1])
                translate([bed_width / 2 * x, ((bed_depth - bulldog_length(small_bulldog)) / 2 - washer_diameter(M3_washer)) * y, pillar_height(bed_pillars) + (pcb_thickness + sheet_thickness(bed_glass))/ 2])
                    rotate([0, 0, 90 + x * 90])
                        bulldog(small_bulldog, pcb_thickness + sheet_thickness(bed_glass));
    }
}
