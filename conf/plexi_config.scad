//
// Mendel90
//
// GNU GPL v2
// nop.head@gmail.com
// hydraraptor.blogspot.com
//
// Configuration file
//
echo("Plexi:");

Z_bearings = LM12UU;
Y_bearings = LM12UU;
X_bearings = LM12UU;

X_motor = NEMA23;
Y_motor = NEMA23;
Z_motor = NEMA23;

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
psu = ALPINE500;
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

motor_shaft = 5;

Y_carriage_depth = bed_holes + 7;
Y_carriage_width = bed_holes + 7;

//Parameters of Z threaded rod
Z_screw_dia = 8;                // Threaded rod Studding for Z axis
Z_nut_radius = M8_nut_radius;
Z_nut_depth = M8_nut_depth;
Z_nut = M8_nut;

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
//
// Feature sizes
//
default_wall = 3;
thick_wall = 4;