//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Washers
//            Hex   Inner diameter   Width Across Corners    Hex thickness  Nyloc thickness        Nut washer     Nut trap depth
M2p5_nut    = [true,    2.5,             5.8,                    2.2,          3.8,               M2p5_washer,   M2p5_nut_trap_depth];
M3_nut      = [true,    3,               6.4,                    2.4,          4,                 M3_washer,     M3_nut_trap_depth];
M4_nut      = [true,    4,               8.1,                    3.2,          5,                 M4_washer,     M4_nut_trap_depth];
M5_nut      = [true,    5,               9.2,                      4,          6.25,              M5_washer,     M5_nut_depth];
M6_nut      = [true,    6,               11.5,                     5,          8,                 M6_washer,     M6_nut_depth];
M6_half_nut = [true,    6,               11.5,                     3,          8,                 M6_washer,     3];
M8_nut      = [true,    8,               15,                     6.5,          8,                 M8_washer,     M8_nut_depth];
M10_nut     = [true,    10,              19.6,                     8,         10,                 M10_washer,    M10_nut_depth];
TR10x2_nut  = [true,    10,              21,                      15,         10,                 M10_washer,    TR10_nut_depth];

//                      Hex     Flanged    Inner diameter   Barrel diameter  Barrel thickness   Flange diameter    Flange thickness     Holes distance     Holes diameter
TR10x2_round_nut    = [false,   false,        10,                22,              15];
TR10x2_flanged_nut  = [false,   true,         10,                25,              15,                 42,                10,                 34,                 4];

function is_hex(type) = type[0];
function is_flanged(type) = type[1];

function leadscrew_diameter(type) = is_hex(type) ? type[1] : type[2];

function nonhex_nut_thickness(type) = type[4];
function nonhex_nut_radius(type) = type[3] / 2;
function flanged_nut_hole_radius(type) = type[8] / 2;
function flanged_nut_barrel_radius(type) = type[3] / 2;
function flanged_nut_hole_distance_radius(type) = type[7] / 2;
function flanged_nut_barrel_thickness(type) = type[4];
function flanged_nut_flange_thickness(type) = type[6];
function flanged_nut_mounting_hole_radius(type) = type[8] / 2;

function nut_outer_radius(type) = is_hex(type) ? nut_radius(type) : nonhex_nut_radius(type);
function nut_depth(type) = is_hex(type) ? nut_thickness(type) : nonhex_nut_thickness(type);

module flanged_nut(type) {
    inner_radius = type[2] / 2;
    flange_radius = type[5] / 2;
    flange_thickness = type[6];
    barrel_radius = nonhex_nut_radius(type);
    barrel_thickness = flanged_nut_barrel_thickness(type);
    hole_distance_radius = flanged_nut_hole_distance_radius(type);
    hole_radius = type[8] / 2;
    difference() {
        union() {
            // Flange
            translate ([0, 0, - barrel_thickness / 2])
                cylinder (r = flange_radius, h = flange_thickness, $fn = 50, center = true);
            // Barrel
            cylinder (r = barrel_radius, h = flange_thickness + barrel_thickness, $fn = 50, center = true);
        }
        // Inner hole
        cylinder (r = inner_radius, h = flange_thickness + barrel_thickness + 0.1, $fn = 50, center = true);
        // Mounting holes
        for(rot = [0, 60, 120]) {
            rotate([0, 0, rot]) {
                translate ([hole_distance_radius, 0, - barrel_thickness / 2])
                    cylinder (r = hole_radius, h = 4 * barrel_thickness + 0.1, $fn = 50, center = true);
                translate ([-hole_distance_radius, 0, - barrel_thickness / 2])
                    cylinder (r = hole_radius, h = 4 * barrel_thickness + 0.1, $fn = 50, center = true);
            }
        }   
    }
}

function nut_radius(type) = type[2] / 2;
function nut_flat_radius(type) = nut_radius(type) * cos(30);
function nut_thickness(type, nyloc = false) = nyloc ? type[4] : type[3];
function nut_washer(type) = type[5];
function nut_trap_depth(type) = type[6];

module round_nut(type, brass = false) {
    hole_rad  = type[2] / 2;
    outer_rad = nonhex_nut_radius(type);
    thickness = nonhex_nut_thickness(type);

    color(brass ? brass_nut_color : nut_color) render() 
    difference() {
        union() {
            cylinder(r = outer_rad, h = thickness, $fn = 50);
        }
        translate([0, 0, -1])
            cylinder(r = hole_rad, h = thickness + 2);
    }
}

module nut(type, nyloc = false, brass = false) {
    hole_rad  = type[1] / 2;
    outer_rad = nut_radius(type);
    thickness = nut_thickness(type);
    nyloc_thickness = type[4];

    if(nyloc)
        vitamin(str("NYLOCM", type[1], ": Nyloc nut M", type[1]));
    else
        if(brass)
            vitamin(str("NUTBM", type[1], ": Brass nut M", type[1]));
        else
            vitamin(str("NUTM", type[1], ": Nut M", type[1]));

    if(exploded && nyloc)
        cylinder(r = 0.2, h = 10);

    color(brass? brass_nut_color : nut_color) render() translate([0, 0, (exploded && nyloc) ? 10 : 0]) difference() {
        union() {
            cylinder(r = outer_rad, h = thickness, $fn = 6);
            if(nyloc)
                translate([0,0, eta])
                    rounded_cylinder(r = outer_rad * cos(30) , h = nyloc_thickness, r2 = (nyloc_thickness - thickness) / 2);
        }
        translate([0, 0, -1])
            cylinder(r = hole_rad, h = nyloc_thickness + 2);
    }
}

module nut_and_washer(type, nyloc) {
    washer = nut_washer(type);
    translate([0, 0, exploded ? 7 : 0])
        washer(washer);
    translate([0,0, washer_thickness(washer)])
        nut(type, nyloc);
}

M4_wingnut = [4, 10, 3.75, 8, M4_washer, 0, 22, 10, 6, 3];

module wingnut(type) {
    hole_rad  = type[0] / 2;
    bottom_rad = nut_radius(type);
    top_rad = type[3] / 2;
    thickness = nut_thickness(type);
    wing_span = type[6];
    wing_height = type[7];
    wing_width = type[8];
    wing_thickness = type[9];

    top_angle = asin((wing_thickness / 2) / top_rad);
    bottom_angle = asin((wing_thickness / 2) / bottom_rad);

    vitamin(str("WING0", type[0], ": Wingnut M",type[0]));
    if(exploded)
        cylinder(r = 0.2, h = 10);

    color(nut_color) render() translate([0, 0, exploded ? 10 : 0]) difference() {
        union() {
            cylinder(r1 = bottom_rad, r2 = top_rad, h = thickness);
            for(rot = [0, 180])
                rotate([90, 0, rot]) linear_extrude(height = wing_thickness, center = true)
                    hull() {
                        translate([wing_span / 2  - wing_width / 2, wing_height - wing_width / 2])
                            circle(r = wing_width / 2, center = true);
                        polygon([
                            [bottom_rad * cos(top_angle) - eta, 0],
                            [wing_span / 2  - wing_width / 2, wing_height - wing_width / 2],
                            [top_rad * cos(top_angle) - eta, thickness],
                            [bottom_rad * cos(top_angle) - eta, 0],
                        ]);
                    }
        }
        translate([0,0,-1])
            cylinder(r = hole_rad, h = thickness + 2);
    }
}
