// Plexi version
// Configuration file

//Bearings here define diameter of smooth rods
Z_bearings = LM12UU;
Y_bearings = LM12UU;
X_bearings = LM12UU;

X_motor = NEMA23;
Y_motor = NEMA23;
Z_motor = NEMA23;
extruders_motor = NEMA17;

// Extruders settings
number_of_teeth_on_pinion = 9;
number_of_teeth_on_inner_gear = 47;
hobbed_bolt_radius = 4; // Defines hobbed bolt radius
hobbed_bolt_head_radius = screw_head_radius(M8_hex_screw); // Defines hobbed bolt's head radius
filament_diameter = 3; 
extruder_angle = 20; // Angle defines position of pinion relative to inner gear
inner_gear_outer_diameter = 60; // Outer diameter of bigger (internal) gear
hotend_y_offset = hobbed_bolt_radius + filament_diameter / 2 - 1 + 51;

psu = KY240W;

frame_sheets_distance = max(50, NEMA_length(X_motor) + 29, NEMA_holes_distance(Z_motor) + 4 * structure_wall, 20 + 10 + 14 + NEMA_length(Z_motor), psu_width(psu));

// Height of coupling connecting Z motor shaft with leadscrew. Coupling fits inside Z-bracket
z_coupling_height = 30;

Z_nut = TR10x2_round_nut;

my_frame_screw = M5_cap_screw;
small_screw = M3_cap_screw;
small_nut = M3_nut;

x_spectra_bearing = BB624PRINTED;

hot_end = JHeadMk5;

bed_depth = 300;
bed_width = 300;
bed_glass = glass2;
bed_thickness = pcb_thickness + sheet_thickness(bed_glass);    // PCB heater plus glass sheet
bed_holes = 292;
bed_pillars = M3x20_pillar;

frame = PMMA10;

// UNUSED ---------------------------------------------------------

X_travel = 200;
Y_travel = 200;
Z_travel = 200;



base = PMMA10;                  // Sheet material used for the base. Needs to be thick enough to screw into.
base_corners = 25;
base_nuts = true;


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

