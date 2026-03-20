// ============================================================
//  OpenGeoDrone — Wing Generator
//  RC wing for vase mode FDM printing
// ============================================================
//
//  Tips
//  1 · To embed a part inside the wing, always add a clearance void
//      around it to avoid conflicts with internal ribs
//  2 · If a spar hole disappears: the vase circuit path to the
//      nearest edge is too long → toggle spar_flip_side_X
//  3 · "Normalized tree growing past 200000 elements" → lower wing_sections
//
// ============================================================


// ============================================================
//  AIRFOIL PROFILES
// ============================================================

// Wing airfoils
include <lib/openscad-airfoil/m/mh61.scad>
include <lib/openscad-airfoil/n/naca0008.scad>
af_vec_path_root =             airfoil_MH61_path();
af_vec_path_mid  =             airfoil_MH61_path();
af_vec_path_tip  =             airfoil_MH61_path();
module RootAirfoilPolygon() {  airfoil_MH61();  }
module MidAirfoilPolygon()  {  airfoil_MH61();  }
module TipAirfoilPolygon()  {  airfoil_MH61();  }

//Profil use for winglet => symetric
module wingletAirfoilPolygon() {  airfoil_NACA0008();  }



// ============================================================
//  PART SELECTION
// ============================================================

Left_side      = true;   // generate left half-wing
Right_side     = false;  // generate right half-wing (mirrored)
create_winglet = false;  // attach winglet to tip


// ============================================================
//  RENDER QUALITY
// ============================================================

draft_quality = false;

$fn = $preview ? 0.05 : 80;
$fa = $preview ?  0.1 :  5;   // max angle between segments
$fs = $preview ? 0.05 :  1;   // max segment length (mm)

wing_sections = draft_quality ? 5 : 30;  // spanwise resolution — lower if render is slow


// ============================================================
//  WING PLANFORM
// ============================================================

wing_mm               = 500;  // half-wingspan (mm)
wing_root_chord_mm    = 210;  // root chord (mm)
wing_tip_chord_mm     = 110;  // tip chord — trapezoidal mode only (mm)
wing_center_line_perc = 70;   // reference line position from LE (%)

wing_mode      = 2;    // 1 = trapezoidal   2 = elliptic
elliptic_param = 3.5;  // super-ellipse exponent: 2 = true ellipse, >2 = squarer tip

center_airfoil_change_perc = 100;  // spanwise % where mid airfoil starts  (100 = off)
tip_airfoil_change_perc    = 100;  // spanwise % where tip airfoil starts  (100 = off)
slice_transisions          = 0;    // blend slices between airfoils        (0 = off)


// ============================================================
//  SPAN SECTION LENGTHS   —   must sum to wing_mm
// ============================================================

ellipse_maj_ax = 9;   // motor arm tube semi-axis Z (mm)
ellipse_min_ax = 13;  // motor arm tube semi-axis Y (mm)

motor_arm_width        = 2 * ellipse_maj_ax;  // = 18 mm
motor_arm_to_wing_hull = 10;  // hull blend length between motor arm and wing (mm)

wing_root_mm = 215;  // root section spanwise length (mm)
wing_mid_mm  = 245;  // mid section spanwise length  (mm)
wing_tip_mm  = wing_mm - wing_root_mm - wing_mid_mm - motor_arm_width;  // derived


// ============================================================
//  AERODYNAMIC / GRAVITY CENTER
// ============================================================

AC_CG_margin        = 10;    // CG target: % aft of mean aerodynamic center
aerodyn_center_plot = false; // show aerodynamic center point (debug)
gravity_center_plot = false; // show gravity center point     (debug)


// ============================================================
//  MOTOR ARM  (geometry only — no motor arm printed here)
// ============================================================

motor_arm_length_front       = 170;  // front tube length (mm)
motor_arm_length_back        = 235;  // rear  tube length (mm)
motor_arm_y_offset           = 3;    // Y offset (mm)
motor_arm_height             = 19;   // cross-section height (mm)
motor_arm_tilt_angle         = 20;   // tilt angle (deg)
motor_arm_screw_fit_offset   = 2;    // screw position fine-tune after rotation
motor_arm_grav_center_offset = 35;   // offset from gravity center (mm)
gravity_line_y_offset        = -1;   // Y offset for gravity reference line


// ============================================================
//  CENTER / FUSELAGE DIMENSIONS  (referenced by spar lengths)
// ============================================================

center_width         = 90;   // max fuselage width (mm)
center_length        = 275;  // fuselage total length (mm)
center_height        = 15;   // fuselage height (mm)
center_part_y_offset = 0;
main_stage_y_width   = 2.2 * center_height / 3;
main_stage_x_offset  = center_length / 10;


// ============================================================
//  LEADING EDGE SWEEP  (X shift of LE along span)
// ============================================================

use_custom_lead_edge_sweep = true;

// [ spanwise_z_mm,  x_shift_mm ]
lead_edge_sweep = [
    [0,       0],
    [wing_mm, 281]
];


// ============================================================
//  DIHEDRAL / Y CURVE  (vertical bow of LE along span)
// ============================================================

use_custom_lead_edge_curve = false;
curve_amplitude = 0.10;
max_amplitude   = 400;

// [ spanwise_z_mm,  y_offset_mm ]
lead_edge_curve_y = [
    [wing_mm - wing_tip_mm,       0 * max_amplitude / 10],
    [wing_mm - 9*wing_tip_mm/10,  0 * max_amplitude / 10],
    [wing_mm - 8*wing_tip_mm/10,  0 * max_amplitude / 10],
    [wing_mm - 7*wing_tip_mm/10,  0 * max_amplitude / 10],
    [wing_mm - 6*wing_tip_mm/10,  1 * max_amplitude / 10],
    [wing_mm - 5*wing_tip_mm/10,  2 * max_amplitude / 10],
    [wing_mm - 4*wing_tip_mm/10,  4 * max_amplitude / 10],
    [wing_mm - 3*wing_tip_mm/10,  6 * max_amplitude / 10],
    [wing_mm - 2*wing_tip_mm/10,  8 * max_amplitude / 10],
    [wing_mm - 1*wing_tip_mm/10, 11 * max_amplitude / 10],
    [wing_mm,                    14 * max_amplitude / 10]
];


// ============================================================
//  WASHOUT  (progressive nose-down rotation toward tip)
// ============================================================

washout_deg        = 1.5;  // total washout angle (deg)  — 0 = none
washout_start      = 60;   // spanwise start of washout from root (mm)
washout_pivot_perc = 25;   // pivot point as % of local chord from LE


// ============================================================
//  INTERNAL GRID STRUCTURE
// ============================================================

add_inner_grid   = true;   // must be true when spar_hole = true
grid_mode        = 2;      // 1 = diamond lattice   2 = spar walls + transverse ribs
create_rib_voids = false;  // punch lightening holes in ribs

// Grid mode 1 — diamond lattice
grid_size_factor = 2;  // scales the diamond cell size

// Grid mode 2 — spar walls + ribs
spar_num    = 3;   // number of longitudinal spar walls
spar_offset = 12;  // outermost spar wall offset from LE/TE (mm)
rib_num     = 14;  // number of transverse ribs
rib_offset  = 3;   // rib wall thickness offset (mm)



// ============================================================
//  ELEVONS
// ============================================================

create_aileron = true;

// Skin gap between elevon and wing (tune if elevon binds after printing)
top_y_offset = 1.2;
bot_y_offset = 1.5;

aileron_thickness         = 32;   // elevon depth toward LE (mm)
aileron_pin_hole_diameter = 1.5;  // hinge pin diameter (mm)
aileron_pin_hole_length   = 7;    // hinge pin length (mm)
ailerons_z_end_offset     = 3.5;
aileron_cyl_radius        = 6;    // void cylinder radius at hinge
aileron_reduction         = 0;    // span reduction each side for fit clearance (mm)

y_offset_aileron_to_wing   = 0.6;   // gap between elevon and wing skin
cylindre_wing_dist_nosweep = 1;     // cylinder-to-cube gap for non-swept sections
cylindre_wing_dist_sweep   = -9.5;  // cylinder-to-cube gap for swept sections

// Command pin geometry (servo horn connection)
aileron_command_pin_void_length = 10;
aileron_command_pin_width       = 7.5;
aileron_command_pin_s_radius    = 0.6;
aileron_command_pin_b_radius    = 1.7;
aileron_command_pin_x_offset    = 3;

// Derived — do not edit
aileron_dist_LE_command_center = aileron_thickness
    - aileron_command_pin_width
    - aileron_command_pin_b_radius
    - aileron_command_pin_x_offset;
aileron_dist_LE_pin_center = aileron_thickness;

void_offset_command_ailerons  = 1.3;  // rib clearance void around command pin
void_offset_pin_hole_ailerons = 2.5;  // rib clearance void around hinge pin

// Print tolerances — increase if pin is too tight after printing
ailerons_pin_hole_dilatation_offset_PLA  = 1.2;
ailerons_pin_hole_dilatation_offset_PETG = 1.3;

// Elevon span extent — derived
aileron_start_z = wing_root_mm + motor_arm_width + motor_arm_to_wing_hull;
aileron_end_z   = wing_root_mm + motor_arm_width + wing_mid_mm;


// ============================================================
//  WINGLET
// ============================================================

winglet_mode             = 2;   // 1 = trapezoidal   2 = elliptic
winglet_mm               = 60;  // winglet span (mm)
elliptic_param_winglet   = 2.5;
winglet_sections         = 20;
winglet_center_line_perc = 70;
winglet_to_wing_hull     = 5;   // hull blend at wing/winglet junction (mm)

// Root chord derived from main wing elliptic distribution at tip — do not edit
winglet_root_chord_mm = ChordLengthAtEllipsePosition(
    (wing_mm + 0.1),
    wing_root_chord_mm,
    wing_root_mm + wing_mid_mm + motor_arm_width);

washout_deg_winglet        = 1.5;
washout_start_winglet      = 60;
washout_pivot_perc_winglet = 25;

use_custom_lead_edge_sweep_winglet = true;
lead_edge_sweep_winglet = [
    [0,           0],
    [winglet_mm, 75]
];

use_custom_lead_edge_curve_winglet = false;
curve_amplitude_winglet = 0.10;
max_amplitude_winglet   = 10;
lead_edge_curve_y_winglet = [
    [0,           0],
    [winglet_mm, max_amplitude_winglet]
];

winglet_y_pos      = -3.5;  // Y placement offset
winglet_y_pos_void = -4.5;  // Y offset to trim wing/winglet overlap

winglet_attach_sweep_angle           = 0;
winglet_attach_dilatation_offset_PLA = 1.1;  // rod socket print tolerance
winglet_attach_void_clearance        = 1.5;
winglet_arm_attach_to_wing           = true;

base_length = 4 * wing_root_chord_mm / 10;

// Carbon rods at winglet root — 2 rods slot into matching voids
attached_1_x_pos  = -30;
attached_1_y_pos  =  1.5;
attached_1_radius =  2.5;
attached_1_length = 30;

attached_2_x_pos  = -50;
attached_2_y_pos  =  1.0;
attached_2_radius =  2.2;
attached_2_length = 30;

attached_z_offset = 2.5;

// ============================================================
//  CARBON SPAR HOLES
// ============================================================

spar_circles_nb    = 12;    // snap-fit retaining nubs per hole
spar_circle_holder = 0.25;  // nub interference radius (mm)

spar_inser_lgth_into_center_part = center_width / 2;  // spar insertion into center body (mm)
spar_angle_fitting_coeff         = 1.15;               // sweep angle correction coefficient

// Sweep angle derived from lead_edge_sweep — do not edit
sweep_angle = use_custom_lead_edge_sweep
    ? atan((spar_angle_fitting_coeff * lead_edge_sweep[len(lead_edge_sweep)-1][1])
           / lead_edge_sweep[len(lead_edge_sweep)-1][0])
    : 0;

// Intermediate span offsets used to compute spar lengths
spar_length_offset_1 = wing_mm - wing_tip_mm - 2*attached_1_length + 13;
spar_length_offset_2 = wing_mm - wing_tip_mm - 2*attached_2_length - 50;

// --- Spar 1  (follows LE sweep, dia 5.65 mm) ---
spar_hole              = true;
spar_hole_perc         = 15;    // % chord from LE
spar_hole_size         = 5.65;  // tube outer diameter (mm)
spar_hole_offset       = 7.0;   // vertical fine-tune (mm)
spar_hole_void_clearance = 2.1; // clearance in grid wall (>= 2x extrusion width)
spar_flip_side_1       = false;
spar_hole_length       = use_custom_lead_edge_sweep
    ? spar_length_offset_1 / cos(sweep_angle)
    : spar_length_offset_1;

// --- Spar 2  (follows LE sweep, dia 5.6 mm) ---
spar_hole_perc_2         = 37;
spar_hole_size_2         = 5.6;
spar_hole_offset_2       = 7.0;
spar_hole_void_clearance_2 = 2.0;
spar_flip_side_2         = false;
spar_hole_length_2       = use_custom_lead_edge_sweep
    ? spar_length_offset_2 / cos(sweep_angle)
    : spar_length_offset_2;

// --- Spar 3  (perpendicular to root face, dia 6.65 mm — larger for triangulation) ---
spar_hole_perc_3           = 75;
spar_hole_size_3           = 6.65;
spar_hole_offset_3         = 0.3;
spar_hole_void_clearance_3 = 2.0;
spar_flip_side_3           = true;
sweep_angle_3rd_spar       = 0;
spar_hole_length_3         = motor_arm_width + wing_root_mm;

// Debug
debug_spar_hole = false;
debug_spar_void = false;

// ============================================================
//  SLICER / VASE MODE
// ============================================================

slice_ext_width = 0.6;   // extrusion width — used for gap and interface sizing
slice_gap_width = 0.01;  // outer skin gap width (smaller = better; limited by slicer)
opacity         = 1;


// ============================================================
//  DEBUG FLAGS
// ============================================================

debug_leading_trailing_edge = false;
debug_full_wing_points      = false;


// ============================================================
//  LIBRARY INCLUDES
// ============================================================

include <lib/Grid-Structure.scad>
include <lib/Grid-Void-Creator.scad>
include <lib/Helpers.scad>
include <lib/Rib-Void-Creator.scad>
include <lib/Servo-Hole.scad>
include <lib/Spar-Hole.scad>
include <lib/Wing-Creator.scad>
include <lib/Aileron-Creator.scad>
include <lib/Motor-arm.scad>
include <lib/Tools.scad>
include <lib/Winglet-Creator.scad>
include <lib/Center-part.scad>
include <lib/Clamp-Fixation.scad>


    
//-----------------------------------------------------------
// FULL SYSTEM BUILD
//-----------------------------------------------------------
module wing_main(aero_grav_center) {
    union() {
        render(convexity=10) //simplify for visu    
        intersection() {
            render(convexity=10) //simplify for visu    
            difference() {
                render(convexity=10) //simplify for visu
                difference() {
                    wing_shell();
                    if (add_inner_grid) wing_inner_grid();
                }
                    wing_modif(aero_grav_center);
                    CreateAileronVoid(); //We remove the ailerons the ailerons
            }
            //We remove the tip for Winglet
            if (create_winglet) cube_cut(0,wing_root_mm + motor_arm_width + wing_mid_mm);
        }
        if (create_winglet) winglet_main(winglet_y_pos);
        
        main_create_ailerons(); // Create aileron



    }
}



//-----------------------------------------------------------
// WING SHELL (outer skin)
//-----------------------------------------------------------
module wing_shell() {
    CreateWing();
}


//-----------------------------------------------------------
// INTERNAL STRUCTURE (grid, ribs, spars)
//-----------------------------------------------------------
module wing_inner_grid() {
    difference() {
        if (grid_mode == 1)
            StructureGrid(wing_mm, wing_root_chord_mm, grid_size_factor);
        else
            StructureSparGrid(3 * wing_mm, wing_root_chord_mm, grid_size_factor,
                              spar_num, spar_offset, 3 * rib_num, rib_offset); //We multiply by 3 to to cover largely the whole wing

        if (create_rib_voids) //Void in ribs to decrease weight
            if(grid_mode == 1) CreateRibVoids(); 
            else CreateRibVoids2();

        wing_voids();      // servo, spar, aileron, and winglet voids
        CreateGridVoid();  // internal grid clearance for vase mode
    }
}


//-----------------------------------------------------------
// INTERNAL VOIDS (spar, servo, aileron, winglet, clamp, ...)
//-----------------------------------------------------------
module wing_voids() {
    union() {
        if (spar_hole) wing_spar_voids();
        if (create_winglet) Create_winglet_connection_void();
    }
}


//-----------------------------------------------------------
// WING MODIFICATIONS (visible outer parts)
//-----------------------------------------------------------
module wing_modif(aero_grav_center) {
    union() {
        if (create_winglet)
            Create_winglet_connection(cube_for_vase = true);

        CreateAileronVoid(); //We create a gap between mid wing and ailerons in Mid_Aileron mode

        wing_spar_holes();


    }
}


//-----------------------------------------------------------
// WING SHELL (outer skin)
//-----------------------------------------------------------
module main_create_ailerons() {

    // Create aileron block in full mode
    intersection() {
        difference() {
            wing_shell();
            if (add_inner_grid) wing_inner_grid();
            //if (create_servo) servo_block();
        }
        if (create_aileron) CreateAileron();
        cube_cut(wing_root_mm + motor_arm_width + motor_arm_to_wing_hull, wing_mid_mm-motor_arm_to_wing_hull-ailerons_z_end_offset); //We remove the part in superposition with the motor arm    
    }
}

//-----------------------------------------------------------
// SUBMODULES: Spars, Servos, Winglets, Cable holes
//-----------------------------------------------------------
//Create Void into ribs for spars to avoid conflict between spar and ribs for vase print
module wing_spar_voids() {
    CreateSparVoid(sweep_angle, spar_hole_offset, spar_hole_perc, spar_hole_size,
                   spar_hole_length, wing_root_chord_mm, spar_hole_void_clearance, spar_flip_side_1);

    CreateSparVoid(sweep_angle, spar_hole_offset_2, spar_hole_perc_2, spar_hole_size_2,
                   spar_hole_length_2, wing_root_chord_mm, spar_hole_void_clearance_2, spar_flip_side_2);

                   CreateSparVoid(sweep_angle_3rd_spar, spar_hole_offset_3, spar_hole_perc_3, spar_hole_size_3,spar_hole_length_3, wing_root_chord_mm, spar_hole_void_clearance_3, spar_flip_side_3);
}

//Create holes for spars in wings
module wing_spar_holes() {
    CreateSparHole(sweep_angle, spar_hole_offset, spar_hole_perc, spar_hole_size,
                   spar_hole_length, wing_root_chord_mm, slice_gap_width,
                   spar_circles_nb, spar_circle_holder, spar_flip_side_1);

    CreateSparHole(sweep_angle, spar_hole_offset_2, spar_hole_perc_2, spar_hole_size_2,
                   spar_hole_length_2, wing_root_chord_mm, slice_gap_width,
                   spar_circles_nb, spar_circle_holder, spar_flip_side_2);

    CreateSparHole(sweep_angle_3rd_spar, spar_hole_offset_3, spar_hole_perc_3, spar_hole_size_3,
                   spar_hole_length_3, wing_root_chord_mm, slice_gap_width,
                   spar_circles_nb, spar_circle_holder, spar_flip_side_3);                   
}




//-----------------------------------------------------------
// SECTION CUTS (for printing)
//-----------------------------------------------------------
module cube_cut(start_z, len_z) {
    translate([-1000, -1000, start_z])
        cube([2000, 2000, len_z]);
}





//-----------------------------------------------------------
// MAIN WINGLET MODULE
//-----------------------------------------------------------
module winglet_main(winglet_y_p) {

    CreateWinglet(winglet_y_p);

}




//-----------------------------------------------------------
// SPAR VOIDS
//-----------------------------------------------------------
module center_spar_holes(ct_width) {   
    CreateSparHole_center(sweep_angle, spar_hole_offset, spar_hole_perc, spar_hole_size, spar_hole_length, wing_root_chord_mm, ct_width, spar_circles_nb, spar_circle_holder, spar_inser_lgth_into_center_part);
    
    CreateSparHole_center(sweep_angle, spar_hole_offset_2, spar_hole_perc_2, spar_hole_size_2, spar_hole_length_2, wing_root_chord_mm, ct_width, spar_circles_nb, spar_circle_holder, spar_inser_lgth_into_center_part);
    
    CreateSparHole_center(sweep_angle_3rd_spar, spar_hole_offset_3, spar_hole_perc_3, spar_hole_size_3, spar_hole_length_3, wing_root_chord_mm, ct_width, spar_circles_nb, spar_circle_holder, spar_inser_lgth_into_center_part);    
}



//-----------------------------------------------------------
// MAIN 
//-----------------------------------------------------------
    
if (wing_sections * 0.2 < slice_transisions) echo("ERROR: You should lower the amount of slice_transisions.");

else if (center_airfoil_change_perc < 0 || center_airfoil_change_perc > 100) echo("ERROR: center_airfoil_change_perc has to be in a range of 0-100.");

else if (add_inner_grid == false && spar_hole == true) echo("ERROR: add_inner_grid needs to be true for spar_hole to be true");

else
{
    //**************** Aero and Gravity Center **********//
    aerodynamic_gravity_center(wing_mm, AC_CG_margin, display_surface = false, display_point = false, aero_center_plot = aerodyn_center_plot, grav_center_plot = gravity_center_plot);
    aero_grav_center = get_gravity_aero_center(AC_CG_margin);
    
    //**************** Spar Length for user **********//
    echo(str("[SPAR] Spar 1 at ",spar_hole_perc,"% from LE is ", spar_hole_length + spar_inser_lgth_into_center_part, "mm length."));
    echo(str("[SPAR] Spar 2 at ",spar_hole_perc_2,"% from LE is ", spar_hole_length_2 + spar_inser_lgth_into_center_part, "mm length."));    
    echo(str("[SPAR] Spar 3 at ",spar_hole_perc_3,"% from LE is ", spar_hole_length_3 + spar_inser_lgth_into_center_part, "mm length."));        
   
    //**************** Wing **********//             
        if(Left_side) wing_main(aero_grav_center);

        if(Right_side)
            mirror([0, 0, 1])
                translate([0, 0, center_width])
                    wing_main(aero_grav_center); 

 

    

} //End if main
