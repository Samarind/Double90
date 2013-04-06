//
// Plexi
// GNU GPL v2
// Configuration file

//Bearings here define diameter of smooth rods
Z_bearings = LM12UU;
Y_bearings = LM12UU;
X_bearings = LM12UU;

X_motor = NEMA23;
Y_motor = NEMA23;
Z_motor = NEMA23;

psu = KY240W;

frame_sheets_distance = max(50, NEMA_length(X_motor) + 29, NEMA_holes_distance(Z_motor) + 4 * structure_wall, 20 + 10 + 14 + NEMA_length(Z_motor), psu_width(psu));
z_coupling_height = 35;

//Parameters of Z leadscrew
Z_nut = TR10x2_round_nut;
Z_screw_diameter = leadscrew_diameter(Z_nut);
Z_nut_radius = nut_outer_radius(Z_nut);
Z_nut_depth = nut_depth(Z_nut);

my_frame_screw = M5_cap_screw;
small_screw = M3_cap_screw;
small_nut = M3_nut;

x_spectra_bearing = BB624PRINTED;


// UNUSED ---------------------------------------------------------
hot_end = JHeadMk5;

X_travel = 200;
Y_travel = 200;
Z_travel = 200;


bed_depth = 214;
bed_width = 214;
bed_pillars = M3x20_pillar;
bed_glass = glass2;
bed_thickness = pcb_thickness + sheet_thickness(bed_glass);    // PCB heater plus glass sheet
bed_holes = 209;

base = PMMA10;                  // Sheet material used for the base. Needs to be thick enough to screw into.
base_corners = 25;
base_nuts = true;

frame = PMMA10;
frame_corners = 25;
frame_nuts = true;

case_fan = fan80x38;
controller = Melzi;
spool = spool_300x85;
bottom_limit_switch = false;
top_limit_switch = true;

single_piece_frame = true;
stays_from_window = false;
cnc_sheets = true;                 // If sheets are cut by CNC we can use slots, etc instead of just round holes
pulley_type = T2p5x16_metal_pulley;

Y_carriage = DiBond;

X_belt = T2p5x6;
Y_belt = T2p5x6;

Y_carriage_depth = bed_holes + 7;
Y_carriage_width = bed_holes + 7;

//
// Default screw use where size doesn't matter
//
cap_screw = M3_cap_screw;
hex_screw = M3_hex_screw;
//
// Screw for the frame and base
//
frame_soft_screw = No6_screw;               // Used when sheet material is soft, e.g. wood
frame_thin_screw = M4_cap_screw;            // Used with nuts when sheets are thin
frame_thick_screw = M4_pan_screw;           // Used with tapped holes when sheets are thick and hard, e.g. plastic or metal

