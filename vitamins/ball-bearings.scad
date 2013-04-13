//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Ball bearings
//      Inner dia   Outer dia    Thickness
BB624 =       [4,         13,         5,      "624"];            
BB608 =       [8,         22,         7,      "608"];            
BB618 =       [8,         16,         5,      "618"];            // For extruder
BB6900 =      [10,        22,         6,      "6900"];           // For fixing Z leadscrew in Z motor bracket
BB6800ZZ =    [10,        19,         5,      "6800"];
BB624PRINTED =[4,         22,         5,      "624 + Printed"];  // for spectra line idler
BB624PRINTEDPRESS=[4,     23,         5,      "624 + PRINTEDPRESS"];  // for extruder

function ball_bearing_diameter(type) = type[1];
function ball_bearing_width(type) = type[2];


module ball_bearing(type) {
    vitamin(str("BB",type[3],": Ball bearing ",type[3]," ",type[0], "mm x ", type[1], "mm x ", type[2], "mm"));
    rim = type[1] / 10;

    color(bearing_color) render() difference() {
        cylinder(r = type[1] / 2, h = type[2], center = true);
        cylinder(r = type[0] / 2, h = type[2] + 1, center = true);
        for(z = [-type[2] / 2, type[2] / 2])
            translate([0,0,z]) difference() {
                cylinder(r = (type[1] - rim) / 2, h = 2, center = true);
                cylinder(r = (type[0] + rim) / 2, 2, center = true);
            }
    }
}
