// RC wing generator for Vase mode printing
//
// Prior work used to create this script:
// https://www.thingiverse.com/thing:3506692
// https://github.com/guillaumef/openscad-airfoil


//Tips
// 1- If you want to add something into the wing, add a void offset around the part you want to add to avoid conflict with intern ribs during vase print  
// 2- When spar hole is far from a edge and the vase circuit connection is too long, the system doesnt like and don't draw the spar hole. Use spar_flip_side parameter to orientate the vase circuit connection to the closest edge
// 3- if you get this error : "WARNING: Normalized tree is growing past 200000 elements. Aborting normalization." -> decrease the wing_sections value
// 4 - Setting you might need to play with : in connection_mid_to_ailerons, there is two offsets to set the  connection as close as possible to the wall. You can play with them in case it's too close to the wall (hole) or too far


// Note Printer 
// 1- No support in motor arm spar holes
// 2- use PLA Aero user preset to get nice print
// 3- Bambulab can crash each time you enter a too large model to slice. It can be due to a NVIDIA parameter for bambulab, here is the solution : https://forum.bambulab.com/t/bambu-studio-crashes-after-slicing-solved-nvidia-problem/162392
// 4- When you import a preset, the import can not work due to version difference. Be carefull to update the version of your printer into the preset document you want to import





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





// TODO
// Arm + center + fuselage => angle pitch comp
// Rear motor pitch or not ?


//Later :
// Technique clean Chat
// Clean too much param
// Ailerons module clean
// Try on Orca and add printer conf in git
// Note on openscad nightly and manifold option
// Readme and clean and comment function with parameters description
// Structure Grid Mode 1 Adapat ? 
// Optimize wing grid and hole vs mass
// NVL implementation



//*******************END***************************//

//****************Global Variables*****************//

// Printing Mode : Choose which part of wings you want
Full_system = false;

Left_side = true;
Right_side = false;

// Choose one at a time
Aileron_part = false;
Root_part = false;
Mid_part = false;
Tip_part = false;
Mid_Aileron_part = false;
Motor_arm_full = false;
Motor_arm_front = false;
Motor_arm_back = false;
Servo_horn = false;

Center_part = true;
Rear_motor_part = true;
Clamp_fixation_big = false;
Clamp_fixation_small = false;
Fuselage_front_part = false;
Fuselage_bottom_back_part = false;
Fuselage_upper_back_part = false;

//**************** Quality settings **********//
draft_quality = false;
$fn = $preview ? 0.05 : 80;
$fa = $preview ?  0.1 :  5;
$fs = $preview ? 0.05 :  1;
//$fa = draft_quality?1:5; //Maximum angle between two segments. → Smaller = more segments = smoother.
//$fs = draft_quality?0.1:1; //(fragment size): maximum length of a segment.→ Smaller = shorter segments = smoother.
wing_sections = draft_quality?5:30; // more is higher resolution but higher processing. We decrease wing_sections for Full_system because it's too much elements just for display


 
echo(str("fn = ",$fn));
echo(str("fa = ",$fa));
echo(str("fs = ",$fs));

//****************Wing Airfoil settings**********//
wing_mm = 500;            // wing length in mm (= Half the wingspan)
wing_root_chord_mm = 210; // Root chord length in mm
wing_tip_chord_mm = 110; // wing tip chord length in mm (Not relevant for elliptic wing);
wing_center_line_perc = 70; // Percentage from the leading edge where you would like the wings center line
wing_mode = 2; // 1=trapezoidal wing 2= elliptic wing
center_airfoil_change_perc = 100; // Where you want to change to the center airfoil 100 is off
tip_airfoil_change_perc = 100;    // Where you want to change to the tip airfoil 100 is off
slice_transisions = 0; // This is the number of slices that will be a blend of airfoils when airfoil is changed 0 is off
elliptic_param = 3.5; //Parameter for surrellipse adjustement. Ellipse = 2. Square tip >2 and Sharp tip <2
pitch_trim = 0; //Parameter for global pitch trim on motor arm, fuselage, center part in degree


//**************** Motor arm **********//
ellipse_maj_ax = 9;        // ellipse's major axis (rayon z)
ellipse_min_ax = 13;        // ellipse's minor axis (rayon y)
motor_arm_length_front = 170;        // Tube length z
motor_arm_length_back = 235;//210;        // Tube length z
motor_arm_y_offset = 3;   //Offset on Y axis
motor_arm_height = 19;      // Height of motor arm
motor_arm_tilt_angle  = 20; // Tilt angle of motor arm
motor_arm_screw_fit_offset = 2; // Offset to adjust screw position after rotation
dummy_motor = false; // Parameters to see how the helix is positionned in comparison of the aircraft
motor_arm_grav_center_offset = 35;
motor_arm_to_wing_hull = 10; //Length of hull for transition from motor arm to wings
gravity_line_y_offset = -1; // Y offset management on motor arm
// More parameters are available inside the motor_arm module



//**************** Wing Airfoil dimensions **********//
// Total length must do wing_mm
motor_arm_width = 2*ellipse_maj_ax;
wing_root_mm = 215;
wing_mid_mm = 245;
wing_tip_mm = wing_mm - wing_root_mm - wing_mid_mm - motor_arm_width;
AC_CG_margin = 10; //Margin between mean aerodynamic center and gravity center in percentage
aerodyn_center_plot = false; //Black
gravity_center_plot = false; //Green
//******//


//**************** Fuselage and center part **********//
center_width = 90; //55;
center_length = 275;
center_height = 15;
center_part_y_offset = 0;//1;
main_stage_y_width = 2*center_height/3;
main_stage_x_offset = center_length/10;
battery_width = center_width -20;//-10; // Distance of battery holder void from extremity
//Battery holder void place
battery_x_pos_6 = -5;
battery_x_pos_1 = 35;
battery_x_pos_7 = 99;
battery_x_pos_2 = 100;
battery_x_pos_3 = 125;
battery_x_pos_4 = 170;
battery_x_pos_5 = 190;
//Tawaki x offset on center part position
tawaki_x_offset_pos = 100;
//ESC x offset on center part position (from rear motor end)
esc_x_offset_pos = 25;


fuselage_x_offset = center_length/4;
fuselage_z_offset = center_width/2;
nozzle_length = 35;
tail_length = 45;
L_total = center_length - main_stage_x_offset+ fuselage_x_offset - tail_length;//300;          // fuselage length
fuselage_mid_cut =L_total / 2 - fuselage_x_offset; //Plan used to cut the fuselage in two

D_front = center_width*0.6;           // noze diameter
D_max   = center_width*0.6;           // max center diameter
D_tail  = center_width*0.8;           // final diameter
num       = 100;            // sections numbers (+ = smoother)
fuselage_ellipse_param = [7,4.8]; //Super ellipse fuselage shape parameter [x,y]
fuselage_scale_y = 1.25;
aeration_width = 10;
aeration_length = 20;
//Fuselage screws position
fuselage_screw_radius = 1.6;
x1_fuselage_screw = -15;
z1_fuselage_screw = -4;
x2_fuselage_screw = 23;
x3_fuselage_screw = 84;
x4_fuselage_screw = 165;
//Fuselage and center part magnet position
x1_fuselage_magnet = 30;
x2_fuselage_magnet = 156;
magnet_dimension = [5,5,1];
z1_offset_magnet = -7;
z2_offset_magnet = -6;
pitot_radius = 2;
//******//


//****************Wing Washout settings**********//
washout_deg = 1.5;         // how many degrees of washout you want 0 for none
washout_start = 60;      // where you would like the washout to start in mm from root
washout_pivot_perc = 25; // Where the washout pivot point is percent from LE
//******//


//**************** Wing Sweep X settings **********//
use_custom_lead_edge_sweep = true;
// ([z , x]
lead_edge_sweep = [
  [0, 0],
  [wing_mm,281]
];  
//******//

//**************** Wing Y curve settings **********//
use_custom_lead_edge_curve = false; 
curve_amplitude = 0.10;
max_amplitude = 400;
// ([z , y]
lead_edge_curve_y = [
  [0,     0],
  [wing_mm - wing_tip_mm     ,   0*max_amplitude/10],
  [wing_mm - 9*wing_tip_mm/10,   0*max_amplitude/10],
  [wing_mm - 8*wing_tip_mm/10,   0*max_amplitude/10],
  [wing_mm - 7*wing_tip_mm/10,   0*max_amplitude/10],
  [wing_mm - 6*wing_tip_mm/10,   1*max_amplitude/10],
  [wing_mm - 5*wing_tip_mm/10,   2*max_amplitude/10],
  [wing_mm - 4*wing_tip_mm/10,   4*max_amplitude/10],
  [wing_mm - 3*wing_tip_mm/10,   6*max_amplitude/10],  
  [wing_mm - 2*wing_tip_mm/10,   8*max_amplitude/10],
  [wing_mm - 1*wing_tip_mm/10,   11*max_amplitude/10],
  [wing_mm - 0*wing_tip_mm/10,   14*max_amplitude/10] 
];
//******//

//**************** Grid settings **********//
add_inner_grid = true; // true if you want to add the inner grid for 3d printing
grid_mode = 2;           // Grid mode 1=diamond 2= spar and cross spars
create_rib_voids = false; // add holes to the ribs to decrease weight

//Grid mode 1 settings
grid_size_factor = 2; // changes the size of the inner grid blocks

//Grid mode 2 settings
spar_offset = 12;//15; // Offset the spars from the LE/TE
rib_num = 14;      // Number of ribs
rib_offset = 3;   // Offset
//******//



//**************** WINGLET settings **********//
create_winglet = true;
winglet_mode = 2;
winglet_mm = 60;
winglet_root_chord_mm = ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, wing_root_mm + wing_mid_mm + motor_arm_width);
winglet_sections = 20;
elliptic_param_winglet = 2.5;
winglet_center_line_perc = 70;
washout_deg_winglet = 1.5;         // how many degrees of washout you want 0 for none
washout_start_winglet = 60;      // where you would like the washout to start in mm from root
washout_pivot_perc_winglet = 25; // Where the washout pivot point is percent from LE
winglet_to_wing_hull = 5; //Length of hull for transition from winglet to wings
winglet_arm_attach_to_wing = true;

use_custom_lead_edge_sweep_winglet = true;
lead_edge_sweep_winglet = [ // ([z , x]
  [0, 0],
  [winglet_mm,75]
];  

use_custom_lead_edge_curve_winglet = false; 
curve_amplitude_winglet = 0.10;
max_amplitude_winglet = 10;
// ([z , y]
lead_edge_curve_y_winglet = [
  [0,     0],
  [winglet_mm,  max_amplitude_winglet] 
];

winglet_y_pos = -3.5; //Y offset management
winglet_y_pos_void = -4.5; // Y offset for erase overlapping part between wing and winglet
base_length = 4*wing_root_chord_mm/10;
winglet_attach_dilatation_offset_PLA = 1.1;// We use this offset for the dilation of material after print to keep the right dimensions ==> act on the winglet attach side
winglet_attach_void_clearance = 1.5; // We use this offset to create void in the ribs structure
winglet_attach_sweep_angle = 0;//sweep_angle;
    
attached_1_x_pos = -30;
attached_1_y_pos = 1.5;
attached_1_radius = 2.5;
attached_1_length = 30;
    
attached_2_x_pos = -50;
attached_2_y_pos = 1;
attached_2_radius = 2.2;
attached_2_length = 30;

attached_z_offset = 2.5;
//******//


//**************** Carbon Spar settings **********//
debug_spar_hole = false;
debug_spar_void = false;
spar_num = 3;     // Number of spars for grid mode 2
spar_length_offset_1 = wing_mm - wing_tip_mm - 2*attached_1_length + 13;
spar_length_offset_2 = wing_mm - wing_tip_mm - 2*attached_2_length - 50;
spar_angle_fitting_coeff = 1.15; // Coeff to adjust the spar angle into the wing
spar_circles_nb = 12; //Number of outer circle around spar to maintain the part
spar_circle_holder = 0.25; //radius of outer circle around spar to maintain the part 0.25 too large and 0.30 too tight => 0.26 too tight
spar_inser_lgth_into_center_part = center_width/2;

//*** Spar angle rotation to follow the sweep
sweep_angle = use_custom_lead_edge_sweep ? atan((spar_angle_fitting_coeff * lead_edge_sweep[len(lead_edge_sweep) - 1][1]) / lead_edge_sweep[len(lead_edge_sweep) - 1][0]) : 0;

//*** Spar 1
spar_hole = true;                // Add a spar hole into the wing
spar_hole_perc = 15;             // Percentage from leading edge
spar_hole_size = 5.65;              // Size of the spar hole
spar_hole_length = use_custom_lead_edge_sweep ? spar_length_offset_1/cos(sweep_angle) : spar_length_offset_1; // length of the spar in mm
spar_hole_offset = 7.0;//6.8;            // Adjust where the spar is located
spar_hole_void_clearance = 2.1; // Clearance for the spar to grid interface(at least double extrusion width is usually needed)
spar_flip_side_1 = false; // use to offset the spar attached on a side of the wing to the other

//*** Spar 2
spar_hole_perc_2 = 37;             
spar_hole_size_2 = 5.6;             
spar_hole_length_2= use_custom_lead_edge_sweep ? spar_length_offset_2/cos(sweep_angle) : spar_length_offset_2; 
spar_hole_offset_2 = 7.0;//6.8;            
spar_hole_void_clearance_2 = 2; 
spar_flip_side_2 = false; 

//*** Spar 3
spar_hole_perc_3 = 75;            
spar_hole_size_3 = 6.65;//5.6;              
spar_hole_length_3= 0 + motor_arm_width + wing_root_mm;
spar_hole_offset_3 = 0.3;          
spar_hole_void_clearance_3 = 2;
spar_flip_side_3 = true; 
sweep_angle_3rd_spar = 0;
//******//


//**************** Cable Root Hole settings **********//
debug_cable_root_hole = false;
debug_cable_root_void = false;
root_cab_hole = true;
root_cable_hole_width = 6;
root_cable_hole_perc = 15.5;
root_cable_hole_ellipse = 4;
root_cable_hole_offset = 8.2;
root_cable_passage_arm_perc = 87.8; //Hole position for cable passage from wing to motor arm in percentage of wing chord
root_cable_passage_main_perc = 24.7; //Hole position for cable passage from wing to main stage in percentage of wing chord
//******//


//**************** Servo settings **********// 
create_servo = true; // It is important to check that your servo placement doesnt create any artifacts 
servo_dimension_perso_void = [23,8,70];
servo_dimension_perso = [23,8,27.3]; 
all_pts_servo = get_trailing_edge_points();
pt_start_servo = find_interpolated_point(wing_root_mm, all_pts_servo);
servo_type = 4;           // 1=3.7g 2=5g 3=9g 4=perso

servo_dist_root_mm = wing_root_mm + motor_arm_to_wing_hull+ motor_arm_width - servo_dimension_perso[2]+2.5; // servo placement from root
servo_dist_le_mm = pt_start_servo[0]-40;    // servo placement from the leading edge
servo_dist_depth_mm = -4; // offset the servo into or out of the wing till you dont see red

servo_void_dist_root_mm = wing_root_mm-20; // servo void placement from root
servo_void_dist_le_mm = pt_start_servo[0]-51;    // servo void placement from the leading edge
servo_void_dist_depth_mm = -4; // offset the servo void into or out of the wing till you dont see red

servo_rotate_z_deg = -0;  // degrees to rotate on z axis
servo_show = false;       // for debugging only. Show the servo for easier placement
//******//





//**************** Aileron settings **********//
create_aileron = true;            // Create an Aileron
//Parameters for gap between mid and ailerons
top_y_offset = 1.2;//1.5; //Offset on y axis connexion top side -> use it at last setting
bot_y_offset = 1.5;//1.8; //Offset on y axis connexion bottom side -> use it at last setting
aileron_thickness = 32;           // Aileron dimension on X axis toward Leading Edge
aileron_pin_hole_diameter = 1.5;  // Diameter of the pin hole fixing the aileron to wing
aileron_pin_hole_length = 7;      // Length of the pin hole
ailerons_z_end_offset = 3.5;
aileron_cyl_radius = 6;  // Aileron void cylinder radius 
aileron_reduction = 0; //2.5;            // Aileron size reduction to fit in the ailerons void with ease 
cylindre_wing_dist_nosweep = 1;   // Distance offset between cylinder and cube to avoid discontinuities in cut
cylindre_wing_dist_sweep = -9.5;//-10; // Distance offset between cylinder and cube to avoid discontinuities in cut
aileron_command_pin_void_length = 10;
aileron_command_pin_width = 7.5;
aileron_command_pin_s_radius = 0.6;//1.7;
aileron_command_pin_b_radius = 1.7;//3.15;
aileron_command_pin_x_offset = 3;
y_offset_aileron_to_wing = 0.6;
aileron_dist_LE_command_center = aileron_thickness - aileron_command_pin_width - aileron_command_pin_b_radius - aileron_command_pin_x_offset;
aileron_dist_LE_pin_center = aileron_thickness;// - aileron_command_pin_b_radius - aileron_command_pin_x_offset;
void_offset_command_ailerons = 1.3; // Use this offset for ribs to pin command conflict in vase. It will make a hole in ribs around the pin command void
void_offset_pin_hole_ailerons = 2.5; // Use this offset for ribs to pin conflict in vase. It will make a hole in ribs around the pin void
ailerons_pin_hole_dilatation_offset_PLA = 1.2; // We use this offset for the dilation of material after print to keep the right dimensions
ailerons_pin_hole_dilatation_offset_PETG = 1.3; 
aileron_start_z = wing_root_mm+ motor_arm_width+motor_arm_to_wing_hull;   // Aileron dimension on Z axis on Trailing Edge
aileron_end_z = wing_root_mm + motor_arm_width + wing_mid_mm; // Aileron dimension on Z axis on Trailing Edge
//******//

//**************** Clamp attach **********//
clamp_attach = true;
debug_clamp_fixation_removal = false;
debug_clamp_fixation_void = false;

//Settings for x axis adjustement in root choord percentage
clamp_arm_mid_perc = 100;
clamp_arm_root_perc = 106;
clamp_root_center_perc = 42;
clamp_mid_winglet_perc = 163;
//Settings for y axis adjustement in on y axis in mm
clamp_arm_mid_y_offset = 12;
clamp_arm_root_y_offset = 10;
clamp_root_center_y_offset = 12;
clamp_mid_winglet_y_offset = 7;

//**************** Other settings **********//
slice_ext_width = 0.6;//Used for some of the interfacing and gap width values
slice_gap_width = 0.01;//This is the gap in the outer skin.(smaller is better but is limited by what your slicer can recognise)
debug_leading_trailing_edge = false;
debug_full_wing_points = false;
opacity = 1;
//******//

//*******************END***************************//










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
module wing_full_system(aero_grav_center) {
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
            intersection_wing_full_system (); //We keep mid and root only
        }
        if (create_winglet) winglet_main(winglet_y_pos);
        
        main_create_ailerons(); // Create aileron



    }
}

//-----------------------------------------------------------
// MAIN WING MODULE
//-----------------------------------------------------------
module wing_main(aero_grav_center) {
    if (!Full_system) {
        intersection() {
            difference() {
                difference() {
                    wing_shell();
                    if (add_inner_grid) wing_inner_grid();
                } 
                wing_modif(aero_grav_center);
            }
            if (Aileron_part) CreateAileron(); //We remove ailerons from wing if request
            wing_cut_sections();
        }
        if (create_winglet && Tip_part)
            winglet_main(winglet_y_pos);
            
        if(Mid_Aileron_part) {
            difference() {
                main_create_ailerons();
                connection_mid_to_ailerons(connexion_void = true);
            }//End difference Mid_Aileron_part       
        }//End if Mid_Aileron_part
        
        
    }
    else  wing_full_system(aero_grav_center);
    
   
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
        if (create_aileron) Ailerons_pin_void();
        if (create_winglet) Create_winglet_connection_void();
        if (root_cab_hole) root_cables_void_main(); 
        //if (create_servo) servo_void_block();
        if (clamp_attach) clamp_fixation_void(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);
    }
}


//-----------------------------------------------------------
// WING MODIFICATIONS (visible outer parts)
//-----------------------------------------------------------
module wing_modif(aero_grav_center) {
    union() {
        if (create_winglet)
            Create_winglet_connection(cube_for_vase = true);

        if (create_aileron && !Aileron_part && !Full_system)
            CreateAileronVoid(); //We create a gap between mid wing and ailerons in Mid_Aileron mode

        if (spar_hole) wing_spar_holes();

        //if (create_servo) servo_block();
        
        //if (motor_arm_attach_to_wing) motor_arm_to_wing_attach_void(aero_grav_center);
        
        if (winglet_arm_attach_to_wing) {
            //winglet_to_wing_hook_void(); 
            winglet_main(winglet_y_pos_void); //remove the overlapping part of wing on winglet
        }
        
        if (root_cab_hole) {
            root_cables_hole_main(); 
        }
        
        if (clamp_attach) {
            clamp_fixation_removal(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); 
        }

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

    //CreateSparVoid_square(sweep_angle_3rd_spar, spar_hole_offset_3, spar_hole_perc_3, spar_hole_size_3, spar_hole_length_3, wing_root_chord_mm, spar_hole_void_clearance_3, spar_flip_side_3);
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

    //CreateSparHole_square(sweep_angle_3rd_spar, spar_hole_offset_3, spar_hole_perc_3, spar_hole_size_3, spar_hole_length_3, wing_root_chord_mm, slice_gap_width, spar_circles_nb, spar_circle_holder, spar_flip_side_3);
    CreateSparHole(sweep_angle_3rd_spar, spar_hole_offset_3, spar_hole_perc_3, spar_hole_size_3,
                   spar_hole_length_3, wing_root_chord_mm, slice_gap_width,
                   spar_circles_nb, spar_circle_holder, spar_flip_side_3);                   
}

//Create Void in ribs for servo (same reason as spar)
module servo_void_block() {
    rotate([0, 0, servo_rotate_z_deg])
    translate([servo_void_dist_le_mm, servo_void_dist_depth_mm, servo_void_dist_root_mm])
    {
        if (servo_type == 1) Servo3_7gVoid();
        else if (servo_type == 2) Servo5gVoid();
        else if (servo_type == 3) Servo9gVoid();
        else if (servo_type == 4) Servo4Void();
    }
}

//Create Void in wings for servo 
module servo_block() {
    rotate([0, 0, servo_rotate_z_deg])
    translate([servo_dist_le_mm, servo_dist_depth_mm, servo_dist_root_mm])
    {
        if (servo_type == 1) Servo3_7g();
        else if (servo_type == 2) Servo5g();
        else if (servo_type == 3) Servo9g();
        else if (servo_type == 4) Servo4();
    }
}

//Create servo horn
module servo_horn_main() {

    ServoHorn();
}
//Create hole in root part for cable passage
module root_cables_hole_main() {

    root_cables_hole(root_cable_hole_width, root_cable_hole_perc, root_cable_hole_ellipse, root_cable_hole_offset, slice_gap_width, sweep_angle, root_cable_passage_arm_perc, root_cable_passage_main_perc, wing_mm, wing_root_mm, motor_arm_to_wing_hull, wing_root_chord_mm);
}

//Create hole in root part for cable passage
module root_cables_void_main() {

    root_cables_void(root_cable_hole_width, root_cable_hole_perc, root_cable_hole_ellipse, root_cable_hole_offset, root_cable_passage_arm_perc, root_cable_passage_main_perc, wing_mm, wing_root_mm, motor_arm_to_wing_hull, wing_root_chord_mm);
}


//-----------------------------------------------------------
// SECTION CUTS (for printing)
//-----------------------------------------------------------
module wing_cut_sections() {
    if (Aileron_part) cube_cut(wing_root_mm + motor_arm_width+motor_arm_to_wing_hull, wing_mid_mm-motor_arm_to_wing_hull);
    if (Root_part) cube_cut(0, wing_root_mm - motor_arm_to_wing_hull);
    if (Mid_part || Mid_Aileron_part) cube_cut(wing_root_mm + motor_arm_width+motor_arm_to_wing_hull, wing_mid_mm-motor_arm_to_wing_hull);
    if (Tip_part && !create_winglet)
        cube_cut(wing_root_mm + motor_arm_width + wing_mid_mm, wing_tip_mm);
}

module cube_cut(start_z, len_z) {
    translate([-1000, -1000, start_z])
        cube([2000, 2000, len_z]);
}

//We use this intersection for display only on full system mode to get mid and root
module intersection_wing_full_system () {

    union(){
        cube_cut(0, wing_root_mm - motor_arm_to_wing_hull);
        cube_cut(wing_root_mm + motor_arm_width+motor_arm_to_wing_hull, wing_mid_mm-motor_arm_to_wing_hull);
    }            
}





//-----------------------------------------------------------
// MAIN MOTOR ARM MODULE
//-----------------------------------------------------------
module motor_arm_main(aero_grav_center) {
 
       
    if(Motor_arm_full || Motor_arm_front || Motor_arm_back || Full_system){
        difference() {
                 
            CreateMotorArm(aero_grav_center);                   
            wing_spar_holes(); //We remove the spar from the motor arms           
            if (create_servo) {
            servo_void_block(); //We remove the servo from the motor arms
            servo_horn_connection(true);
            clamp_fixation_removal(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); //Clamp fixation btwn motor arm and wing
            }
                        
         }//End of difference
     }//End if

}


//-----------------------------------------------------------
// MAIN WINGLET MODULE
//-----------------------------------------------------------
module winglet_main(winglet_y_p) {

    difference() {
        CreateWinglet(winglet_y_p);
        
        if (clamp_attach) {
            clamp_fixation_removal(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); //Remove clamp from winglet
        }//End if
        
    } //End difference
}


//-----------------------------------------------------------
// MAIN CENTER PART MODULE
//-----------------------------------------------------------
module center_part_main(aero_grav_center, ct_width, ct_length, ct_height) {

    ct_part_origin_offset = [main_stage_x_offset-center_length/2,center_height/2-center_part_y_offset-main_stage_y_width,center_width/2];//Here is a vector from current center part position to origin

    if(Center_part || Full_system){
        intersection(){
            difference() {
                rotate_around_point(ct_part_origin_offset, [0,0,pitch_trim]) //We trim the center part with the trim picth angle
                    center_part(aero_grav_center, ct_width, ct_length, ct_height);
                
                union(){
                    center_spar_holes(ct_width);
                    clamp_fixation_removal(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);
                    fuselage_ct_part_cables_hole(root_cable_hole_width, root_cable_hole_perc, root_cable_hole_ellipse, root_cable_hole_offset, slice_gap_width, sweep_angle, root_cable_passage_arm_perc, root_cable_passage_main_perc, wing_mm, wing_root_mm, motor_arm_to_wing_hull, wing_root_chord_mm);
                    mirror([0, 0, 1])
                        translate([0, 0, ct_width]) {
                            center_spar_holes(ct_width);
                            clamp_fixation_removal(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);
                            fuselage_ct_part_cables_hole(root_cable_hole_width, root_cable_hole_perc, root_cable_hole_ellipse, root_cable_hole_offset, slice_gap_width, sweep_angle, root_cable_passage_arm_perc, root_cable_passage_main_perc, wing_mm, wing_root_mm, motor_arm_to_wing_hull, wing_root_chord_mm);
                         }
                }
                
            //we remove the screws for attaching bottom fuselage
            all_fuselage_screws(screw_clearance_hole = true); 
       
            //we make room for rear motor cable 
            rear_motor_cable_passage ();     
            
            }//End difference  
            CreateFuselage(fuselage_ellipse_param); 
        }//End Intersection
        
        //We remove the very end of fuselage to get the room for the fuselage tail block
        rear_fuselage_block (aero_grav_center);
        //magnet for center part
        all_magnet(magnet_dimension,fuselage_mode = false);   
    }//End if
    
    if(Rear_motor_part || Full_system){
        center_part(aero_grav_center, ct_width, ct_length, ct_height, rear_motor_mode = true);
    }
    
}

//-----------------------------------------------------------
// FUSELAGE PART MODULE
//-----------------------------------------------------------
module fuselage_main(aero_grav_center, ct_width, ct_length, ct_height) {
    
    pt_to_origin = [ -L_total/2+ main_stage_x_offset+ fuselage_x_offset-tail_length,0,ct_width/2];

    //We do a difference to get an empty inside
    intersection(){
    
        union() {
        
        difference(){
            render() // Use for simplification for calculation
                CreateFuselage(fuselage_ellipse_param);
            
            render() // Use for simplification for calculation
                translate(-pt_to_origin) 
                    scale(0.98) 
                        translate(pt_to_origin) 
                            CreateFuselage(fuselage_ellipse_param);
                        
            render() // Use for simplification for calculation            
                center_part(aero_grav_center, ct_width, ct_length, ct_height, shape_only_mode = true);
               
            //We remove the tail fuselage used to hull as well
            render() // Use for simplification for calculation
                tail_fuselage();
            
            //We Draw holes for aeration
            translate([0,0,-3.5*ct_width/5])
                aeration_fuselage();
                
            translate([0,0,-1.5*ct_width/5])
                aeration_fuselage();   
       
            translate([3*ct_length/4,0,-3.5*ct_width/5])
                    aeration_fuselage(flip=true);
                
            translate([3*ct_length/4,0,-1.5*ct_width/5])
                    aeration_fuselage(flip=true); 
                
            render()
                union(){
                    center_spar_holes(ct_width);
                    clamp_fixation(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);
                    fuselage_ct_part_cables_hole(root_cable_hole_width, root_cable_hole_perc, root_cable_hole_ellipse, root_cable_hole_offset, slice_gap_width, sweep_angle, root_cable_passage_arm_perc, root_cable_passage_main_perc, wing_mm, wing_root_mm, motor_arm_to_wing_hull, wing_root_chord_mm);
                    clamp_fuselage_remove(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); 
                    mirror([0, 0, 1])
                        translate([0, 0, ct_width]) {
                            center_spar_holes(ct_width);
                            clamp_fixation(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);
                            fuselage_ct_part_cables_hole(root_cable_hole_width, root_cable_hole_perc, root_cable_hole_ellipse, root_cable_hole_offset, slice_gap_width, sweep_angle, root_cable_passage_arm_perc, root_cable_passage_main_perc, wing_mm, wing_root_mm, motor_arm_to_wing_hull, wing_root_chord_mm);
                            clamp_fuselage_remove(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); 
                        }
                    }//end of union
        
            render(convexity=5) // Use for simplification for calculation
                intersection(){
                    difference(){
                        union(){
                            translate(-pt_to_origin)
                            scale([1,1,1.1])
                            translate(pt_to_origin)
                            render(convexity=5) // Use for simplification for calculation
                            main_stage_and_gravity_line(aero_grav_center, ct_width, ct_length, ct_height);
                            } //End of Union
                        render(convexity=5) // Use for simplification for calculation
                        void_battery_holder(ct_width, ct_length, ct_height);
                        }//End of difference
               
                    translate([0,-500,-500])
                        cube([wing_root_chord_mm,1000,1000]);
                    }//End of intersection
        

                //We remove the very end of fuselage to get the room for the fuselage tail block
                rear_fuselage_block (aero_grav_center);
                
                //We draw hole for pitot tube insertion
                Create_pitot(pitot_radius, outside_diameter = false);
                
            }//End of 1st difference
            
        //We add fuselage screws
        all_fuselage_screws();   
        

        
        }//End of union 
        
        
        if(Fuselage_front_part && Full_system == false)   
            union() {
            translate([-500+fuselage_mid_cut,-500,0])
                cube([1000,1000,1000], center=true);

            translate([-500+x1_fuselage_screw-3,500,0])
                cube([1000,1000,1000], center=true);
                }

        if(Fuselage_bottom_back_part && Full_system == false)   
            translate([500+fuselage_mid_cut,-500,0])
                cube([1000,1000,1000], center=true);                

        if(Fuselage_upper_back_part && Full_system == false)   
            translate([500+x1_fuselage_screw-3,500,0])
                cube([1000,1000,1000], center=true);  
                
    }//End of 1st intersection
    

        //We add overlapping transition between part 
        if(Fuselage_upper_back_part) {
            fuselage_up_front_transition(aero_grav_center, x1_fuselage_screw, overlap_length = 15);
            //magnet for fuselage
            all_magnet(magnet_dimension,fuselage_mode = true); 

        }
        
        if(Fuselage_bottom_back_part)    
            fuselage_bottom_front_transition(aero_grav_center, fuselage_mid_cut, overlap_length = 12);
            
            
        //We draw outside diameter for pitot tube insertion
        if(Fuselage_front_part || Full_system) 
            Create_pitot(pitot_radius);
            

}

//-----------------------------------------------------------
// SPAR VOIDS
//-----------------------------------------------------------
module center_spar_holes(ct_width) {   
    CreateSparHole_center(sweep_angle, spar_hole_offset, spar_hole_perc, spar_hole_size, spar_hole_length, wing_root_chord_mm, ct_width, spar_circles_nb, spar_circle_holder, spar_inser_lgth_into_center_part);
    
    CreateSparHole_center(sweep_angle, spar_hole_offset_2, spar_hole_perc_2, spar_hole_size_2, spar_hole_length_2, wing_root_chord_mm, ct_width, spar_circles_nb, spar_circle_holder, spar_inser_lgth_into_center_part);
    
    //CreateSparHole_center_square(sweep_angle_3rd_spar, spar_hole_offset_3, spar_hole_perc_3, spar_hole_size_3, spar_hole_length_3, wing_root_chord_mm, ct_width, spar_circles_nb, spar_circle_holder, spar_inser_lgth_into_center_part);
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
    if(Full_system || Root_part || Mid_part || Tip_part || Aileron_part || Mid_Aileron_part){
             
        if(Left_side || Full_system) wing_main(aero_grav_center);

        if(Right_side || Full_system)
            mirror([0, 0, 1])
                translate([0, 0, center_width])
                    wing_main(aero_grav_center); 
    }
 
    //**************** Motor arm **********//
    if(Left_side || Full_system) motor_arm_main(aero_grav_center);
    
    if(Right_side || Full_system)
        mirror([0, 0, 1]) 
            translate([0, 0, center_width]){
                motor_arm_main(aero_grav_center); 
                }

    //**************** Center part **********//
    center_part_main(aero_grav_center, center_width, center_length, center_height);

    //**************** Fuselage part **********//
    if(Fuselage_front_part || Fuselage_bottom_back_part || Fuselage_upper_back_part || Full_system) fuselage_main(aero_grav_center, center_width, center_length, center_height);  
    
    //**************** Servo horn **********//    
    if((Left_side && Servo_horn) || Full_system) servo_horn_main();
    
    if((Right_side && Servo_horn) || Full_system)
        mirror([0, 0, 1]) 
            translate([0, 0, center_width])
                servo_horn_main();
                
    //**************** Clamp fixation **********//    
    if(Clamp_fixation_big)
        clamp_fixation_big(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);
        
    if(Clamp_fixation_small)
        clamp_fixation_small(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);        

    
    if(Full_system){
        clamp_fixation_big(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);
        clamp_fixation_small(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); 
        mirror([0, 0, 1]) 
            translate([0, 0, center_width]) {
                clamp_fixation(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);   
                clamp_fixation_small(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull);   
                }   
    }       
        
    //**************** Debug **********//
    if(debug_leading_trailing_edge)
    {
        points_te = get_trailing_edge_points();     
        show_trailing_edge_points(points_te); 
        points_le = get_leading_edge_points();     
        show_leading_edge_points(points_le); 
    }
    
    if(debug_full_wing_points) show_all_airfoil_wall_points_full(wing_sections, 10);
    
    if(debug_spar_hole)
    {        
        wing_spar_holes();//Spar hole in Wings       
        center_spar_holes(center_width);//Spar hole in Center Part                          
    }    

    if(debug_spar_void) wing_spar_voids(); //Show voids for wing spar in ribs structure
    
    if(debug_cable_root_void) root_cables_void_main();  //Show voids for cable root hole
    
    if(debug_cable_root_hole) root_cables_hole_main();  //Show cable root hole

    if(debug_clamp_fixation_removal) clamp_fixation_removal(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); // Show Clamp fixation removal
    
    if(debug_clamp_fixation_void) clamp_fixation_void(wing_root_chord_mm, wing_root_mm, motor_arm_width, motor_arm_to_wing_hull); // Show Clamp fixation void for inner structure

    if (servo_show)
    {
        //servo_void_block();
        servo_block();
    }
    



} //End if main
        


 



