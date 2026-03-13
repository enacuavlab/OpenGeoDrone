// TOP LEVEL Parameters
rear_motor_square_support_attach_width = 4;
rear_motor_square_support_attach_length_z = 34;
rear_motor_square_support_attach_length_y = 28;
rear_motor_int_circle_r = 4.75;
rear_motor_int_circ_attach_r = 1.5;
rear_motor_int_circ_attach_dist_to_ct = 8 + rear_motor_int_circ_attach_r;
rear_motor_screw_hole = 1.25;
radius = 3;         // Radius of rounded corners


gravity_line_width = 1;
gravity_line_height = 0.2;

// ============================================================
//  FUSELAGE GENERATOR — C1 Quintic Bézier
// ============================================================
//
//  LONGITUDINAL PROFILE (side view)
//
//        R_max (= center_width/2)
//          |
//  P2 ·   |     · P3
//         ***
//       **   **
//      *       *        * P4
//  P1 *         *      *
//    *            ****
//  P0*                 *P5
//  |noze|...body...|queue|
//  t=0                    t=1
//
//  Control points layout:
//    P0 = R_front                          (nose radius)
//    P1 = P0 + P1_factor*(R_max-R_front)   (controls nose slope → C1)
//    P2 = P0 + P2_factor*(R_max-R_front)   (controls rise speed)
//    P3 = R_tail + P3_factor*(R_max-R_tail) (controls descent)
//    P4 = R_tail + P4_factor*(R_max-R_tail) (controls tail slope → C1)
//    P5 = R_tail + P5_factor*(R_max-R_tail) (tail radius)
//
//  C1 continuity:
//    B'(0) = 5*(P1-P0) → smooth nose if P1 close to P0
//    B'(1) = 5*(P5-P4) → smooth tail if P4 close to P5
//
//  Normalization:
//    The curve is scaled so that max(R(t)) = R_max = center_width/2
//    regardless of control point values. Uses 500-sample search.
//
//  CROSS SECTION (front view)
//
//        ry
//      ------
//     /      \
//    |   rx   |   super-ellipse: |x/rx|^n + |y/ry|^n = 1
//     \      /    n=2 → ellipse, n=4 → rounded rect, n→∞ → rectangle
//      ------
//
//  fuselage_ellipse_param = [nx, ny] controls cross-section shape
//  ry = rx * fuselage_scale_y  (constant flattening ratio)
//
// ============================================================

// --- Global parameters (defined externally) ---
// nozzle_length, tail_length, L_total  → fuselage_length
// center_width                         → max fuselage diameter
// num                                  → number of frames (smoothness)
// nozzle_length, fuselage_z_offset → position
// fuselage_scale_y                     → vertical flattening ratio
// fuselage_ellipse_param               → super-ellipse exponents [nx, ny]



// --- Bézier control point factors ---
// Each factor is in [0,1]: 0 = at R_front/R_tail, 1 = at R_max
// Tune these to change the fuselage shape
P1_factor = 0.9;   // nose tangent — higher = steeper nose rise
P2_factor = 0.6;   // rise speed  — higher = faster widening
P3_factor = 0.85;  // descent     — higher = wider body kept longer
P4_factor = 0.85;  // tail tangent — higher = slower tail taper
P5_factor = 0.2;   // tail exit   — controls tail radius blending



// ============================================================
//  Quintic Bézier — value and derivative
// ============================================================

function bezier5(t, p0,p1,p2,p3,p4,p5) =
      pow(1-t,5)*p0
    + 5*pow(1-t,4)*t*p1
    + 10*pow(1-t,3)*pow(t,2)*p2
    + 10*pow(1-t,2)*pow(t,3)*p3
    + 5*(1-t)*pow(t,4)*p4
    + pow(t,5)*p5;

function bezier5_deriv(t, p0,p1,p2,p3,p4,p5) =
    5*(
          pow(1-t,4)        * (p1-p0)
        + 4*pow(1-t,3)*t    * (p2-p1)
        + 6*pow(1-t,2)*t*t  * (p3-p2)
        + 4*(1-t)*pow(t,3)  * (p4-p3)
        + pow(t,4)          * (p5-p4)
    );

// ============================================================
//  Numerical max search over N samples (recursive)
//  Used to normalize the curve so max(R) = R_max exactly
// ============================================================

function _bz5_max(p0,p1,p2,p3,p4,p5, i, n, cur) =
    i > n ? cur :
    _bz5_max(p0,p1,p2,p3,p4,p5, i+1, n,
        max(cur, bezier5(i/n, p0,p1,p2,p3,p4,p5)));

function bz5_max(p0,p1,p2,p3,p4,p5, n=500) =
    _bz5_max(p0,p1,p2,p3,p4,p5, 0, n, p0);

// ============================================================
//  Section generation [z, rx, ry]
//  The curve is scaled so that max(rx) = R_max = center_width/2
// ============================================================
function fuselage_sections(bz5_P0, bz5_P1, bz5_P2, bz5_P3, bz5_P4, bz5_P5) =
    let(
        p0 = bz5_P0, p1 = bz5_P1, p2 = bz5_P2,
        p3 = bz5_P3, p4 = bz5_P4, p5 = bz5_P5,
        raw_max = bz5_max(p0,p1,p2,p3,p4,p5),
        scale   = R_max / raw_max
    )
    [ for(i = [0 : num])
        let(
            t  = i / num,
            z  = t * fuselage_length,
            R  = scale * bezier5(t, p0,p1,p2,p3,p4,p5),
            rx = R,
            ry = R * fuselage_scale_y
        )
        [z, rx, ry]
    ];

// ============================================================
//  Frame — anisotropic super-ellipse cross-section
// ============================================================

module frame(z, rx, ry, n=[4,4]) {
    hull_width = 0.00001;
    steps      = 100;
    translate([0, 0, z])
        linear_extrude(h=hull_width, center=false)
            polygon(points=[
                for(i = [0 : steps-1])
                    let(
                        a  = 360 * i / steps,
                        ca = cos(a),
                        sa = sin(a),
                        x  = rx * sign(ca) * pow(abs(ca), 2/n[0]),
                        y  = ry * sign(sa) * pow(abs(sa), 2/n[1])
                    )
                    [x, y]
            ]);
}

// ============================================================
//  Fuselage assembly — hull between consecutive frames
// ============================================================

module fuselage() {

    // --- Raw control points (before normalization) ---
    bz5_P0 = R_front;
    bz5_P1 = R_front + P1_factor * (R_max - R_front);
    bz5_P2 = R_front + P2_factor * (R_max - R_front);
    bz5_P3 = R_tail  + P3_factor * (R_max - R_tail);
    bz5_P4 = R_tail  + P4_factor * (R_max - R_tail);
    bz5_P5 = R_tail  + P5_factor * (R_max - R_tail);
    
    s = fuselage_sections(bz5_P0, bz5_P1, bz5_P2, bz5_P3, bz5_P4, bz5_P5);
    translate([-nozzle_length, 0, -fuselage_z_offset])
        rotate([0, 90, 0])
            for(i = [0 : len(s)-2])
                hull() {
                    frame(s[i][0],   s[i][1],   s[i][2],   fuselage_ellipse_param);
                    frame(s[i+1][0], s[i+1][1], s[i+1][2], fuselage_ellipse_param);
                }
}

// ============================================================
//  Fuselage hulled — hull with wings, rear motor
// ============================================================

module hulled_fuselage() {

    // *** HULL  *** //
    hull() {
    
        render() // Use for simplification for calculation
        fuselage();
        
        
        // *** HULL from the FUSELAGE to WINGS LEFT PART *** //
        intersection(){//We keep a wingshell slice 
            render() // Use for simplification for calculation
            wing_shell();
            translate([-2*wing_root_chord_mm,-2500,0])
                cube([4*wing_root_chord_mm,5000,0.0001]);
        }//End of intersection
        

        // *** HULL from the FUSELAGE to WINGS LEFT PART *** //
        mirror([0, 0, 1]) 
            translate([0, 0, center_width])
                intersection(){//We keep a wingshell slice 
                    render() // Use for simplification for calculation
                    wing_shell();
                    translate([-2*wing_root_chord_mm,-2500,0])
                        cube([4*wing_root_chord_mm,5000,0.0001]);
                }//End of intersection
        
        
        
    }//End of hull
}





// ------------------------
// FUSELAGE MODIFICATIONS
// ------------------------  


// ============================================================
//  Create_pitot — Module for pitot tube creation
// ============================================================
//outside_diameter == true => outside diameter drawing for fuselage
//outside_diameter == false => make hole inside outside diameter for pitot tube insertion
module Create_pitot(pitot_rad, pitot_len, outside_diameter = true) {


    pitot_translation = [-nozzle_length + pitot_len/2,0,-center_width/2];
    
    if(outside_diameter == true){
    
    difference() {
    
        intersection() {
            
            render(convexity=5) // Use for simplification for calculation
                hulled_fuselage();
           
            translate(pitot_translation)
                rotate([0,90,0])
                    cylinder(h=pitot_len, r=2*pitot_rad, center = true, $fn=50);       
        }//End intersection
    
        translate(pitot_translation)
        rotate([0,90,0])
        cylinder(h=2*pitot_len, r=pitot_rad, center = true, $fn=50); 
        
    }//End difference
    
    }//End if
    
    if(outside_diameter == false){

        translate(pitot_translation)
            rotate([0,90,0])
                cylinder(h=2*pitot_len, r=pitot_rad, center = true, $fn=50);       
        
    }
}




// ============================================================
//  rear_fuselage_block — Module used to create a small block at the end of the center part to stop the fuselage
// ============================================================
//Hole parameter is used when we draw the part to activate a hole drawing in the middle
module rear_fuselage_block (aero_grav_center, rear_offset = 2, hole = false) {

    cube_position = L_total- nozzle_length - rear_offset;
    difference() {
    
        intersection() {
            render() // Use for simplification for calculation
                hulled_fuselage();  

            translate([500+cube_position,500,0])
                cube([1000,1000,1000], center=true);                
                    
        }//End of intersection
        
        rear_motor_screw_removal();
        //we make room for rear motor cable 
        rear_motor_cable_passage(); 
        //We remove part to get smthg lighter and more aeration
        if(hole)
            rear_fuselage_block_grid(); 
        
    
    }//End of difference
}


// ============================================================
//  fuselage_up_front_transition — Module to create a overlapp between upper and to front to get a nice fuselage transition between part
// ============================================================    
module fuselage_up_front_transition(aero_grav_center, x_offset, overlap_length = 15) {

    coordinate_to_origin = [-x_offset,0,center_width/2];
    scale_factor_overlappint_y_reduction = 1.5;

 
        difference(){
            
            
                translate(-coordinate_to_origin) 
                    scale(0.98) 
                        translate(coordinate_to_origin) 
                            fuselage_transition(x_offset-2, overlap_length, up = true);
                            
                translate(-coordinate_to_origin) 
                    scale(0.96) 
                        translate(coordinate_to_origin) 
                            fuselage_transition(x_offset, overlap_length+5, up = true);  
  
            translate(-coordinate_to_origin)
            scale([1,scale_factor_overlappint_y_reduction,1])
            translate(coordinate_to_origin)
            render() // Use for simplification for calculation            
                center_part(aero_grav_center, center_width, center_length, center_height, shape_only_mode = true);  
              } 
              
}




// ============================================================
//  fuselage_bottom_front_transition — Module to create a overlapp between bottom and to front to get a nice fuselage transition between part
// ============================================================
module fuselage_bottom_front_transition(aero_grav_center, x_offset, overlap_length = 15) {

    coordinate_to_origin = [-x_offset,0,center_width/2];

 
        difference(){
            
            
                translate(-coordinate_to_origin) 
                    scale(0.98) 
                        translate(coordinate_to_origin) 
                            fuselage_transition(x_offset, overlap_length, up = false);
                            
                translate(-coordinate_to_origin) 
                    scale(0.96) 
                        translate(coordinate_to_origin) 
                            fuselage_transition(x_offset, overlap_length+2, up = false);  
  
            render() // Use for simplification for calculation            
                center_part(aero_grav_center, center_width, center_length, center_height, shape_only_mode = true);  
              } 
              
}


// ============================================================
//  fuselage_transition — Tool module for fuselage top and bottom transition 
// ============================================================  
module fuselage_transition(x_offset, overlap_length = 15, up = true) {

    intersection(){

        render() // Use for simplification for calculation
            hulled_fuselage();
        
            if(up == true)
                translate([x_offset,500,0])
                    cube([overlap_length,1000,1000], center=true);
                    
            if(up == false)
                translate([x_offset,-500,0])
                    cube([overlap_length,1000,1000], center=true);                
    }
}


// ============================================================
//  all_magnet — Tool module for magnet drawing 
// ============================================================  
// if fuselage_mode == true => magnet for fuselage, if fuselage_mode == false => magnet for center part
module all_magnet(magnet_dim, fuselage_mode = true) {
    
    

        shell_scale = 1.8;
        
        intersection() {
        
        render(convexity=5) // Use for simplification for calculation
        hulled_fuselage();
            union() {
            
            fuselage_magnet(x1_fuselage_magnet, z_offset = z1_offset_magnet, magnet_dim, shell_scale, fuselage_mode);
            fuselage_magnet(x2_fuselage_magnet, z_offset = z2_offset_magnet, magnet_dim, shell_scale, fuselage_mode);

            mirror([0, 0, 1]) 
                translate([0, 0, center_width]){
                    fuselage_magnet(x1_fuselage_magnet, z_offset = z1_offset_magnet, magnet_dim, shell_scale, fuselage_mode);
                    fuselage_magnet(x2_fuselage_magnet, z_offset = z2_offset_magnet, magnet_dim, shell_scale, fuselage_mode);

                }//End of Translate
                
                
            }//End of union
            
        }//End of intersection
        
}

// ============================================================
//  fuselage_magnet — Tool module for magnet drawing 
// ============================================================  
// if fuselage_mode == true => magnet for fuselage, if fuselage_mode == false => magnet for center part
module fuselage_magnet(x_pos, z_offset = 0, magnet_dim, shell_scale, fuselage_mode) {

    
    y_pos = main_stage_y_width + magnet_dim[2]*shell_scale;

    
    //magnet for fuselage 
    if(fuselage_mode ==  true)
        translate([x_pos, y_pos, -magnet_dim[2]/2 + z_offset]) 
            rotate([-90,0,0])
                difference(){

                    translate([0, -2*magnet_dim[2]/3, 0])
                        linear_extrude(h=magnet_dim[2]*shell_scale*3, center=false)
                            square([magnet_dim[0]*shell_scale,magnet_dim[1]*shell_scale], center = true, $fn=50);   
                    

                    // Screw clearance hole
                        linear_extrude(h=magnet_dim[2], center=false)
                            square([magnet_dim[0],magnet_dim[1]], center = true, $fn=50);   
              }

    //magnet for center part
    if(fuselage_mode ==  false)
        translate([x_pos, y_pos, -magnet_dim[2]/2 + z_offset]) 
            rotate([90,0,0])
                difference(){

                    linear_extrude(h=magnet_dim[2]*shell_scale, center=false)
                        square([magnet_dim[0]*shell_scale,magnet_dim[1]*shell_scale], center = true, $fn=50);   
                    

                    // Screw clearance hole
                        linear_extrude(h=magnet_dim[2], center=false)
                            square([magnet_dim[0],magnet_dim[1]], center = true, $fn=50);   
              }              

        
}


// ============================================================
//  all_fuselage_screws — Tool module for fuselage screw drawing 
// ============================================================  
module all_fuselage_screws(boss_height = 10, screw_clearance_hole = false) {
    
    if(screw_clearance_hole == false) {
    
        intersection() {
        
        render(convexity=5) // Use for simplification for calculation
        hulled_fuselage();
            union() {
            
            fuselage_screw(x1_fuselage_screw, z_offset = z1_fuselage_screw);
            fuselage_screw(x2_fuselage_screw, z_offset = z_fuselage_all_screw);
            fuselage_screw(x3_fuselage_screw, z_offset = z_fuselage_all_screw);
            fuselage_screw(x4_fuselage_screw, z_offset = z_fuselage_all_screw);
            mirror([0, 0, 1]) 
                translate([0, 0, center_width]){
                    fuselage_screw(x1_fuselage_screw, z_offset = z1_fuselage_screw);
                    fuselage_screw(x2_fuselage_screw, z_offset = z_fuselage_all_screw);
                    fuselage_screw(x3_fuselage_screw, z_offset = z_fuselage_all_screw);
                    fuselage_screw(x4_fuselage_screw, z_offset = z_fuselage_all_screw);
                }//End of Translate
                
                
            }//End of union
            
        }//End of intersection
        
    } if (screw_clearance_hole == true) {
    
            fuselage_screw(x1_fuselage_screw, z_offset = z1_fuselage_screw, screw_clearance_hole=screw_clearance_hole);
            fuselage_screw(x2_fuselage_screw, z_offset = z_fuselage_all_screw, screw_clearance_hole=screw_clearance_hole);
            fuselage_screw(x3_fuselage_screw, z_offset = z_fuselage_all_screw, screw_clearance_hole=screw_clearance_hole);
            fuselage_screw(x4_fuselage_screw, z_offset = z_fuselage_all_screw, screw_clearance_hole=screw_clearance_hole);
            mirror([0, 0, 1]) 
                translate([0, 0, center_width]){
                    fuselage_screw(x1_fuselage_screw, z_offset = z1_fuselage_screw, screw_clearance_hole=screw_clearance_hole);
                    fuselage_screw(x2_fuselage_screw, z_offset = z_fuselage_all_screw, screw_clearance_hole=screw_clearance_hole);
                    fuselage_screw(x3_fuselage_screw, z_offset = z_fuselage_all_screw, screw_clearance_hole=screw_clearance_hole);
                    fuselage_screw(x4_fuselage_screw, z_offset = z_fuselage_all_screw, screw_clearance_hole=screw_clearance_hole);
                }//End of Translate
                
    }
}

// ============================================================
//  fuselage_screw — Tool module for fuselage screw drawing 
// ============================================================ 
//screw_clearance_hole parameter is used for create hole in center part to insert screws
module fuselage_screw(x_pos, z_offset = 0, boss_height = 10, screw_clearance_hole = false) {

    boss_radius = 14;
    y_pos = -center_height+main_stage_y_width;


    if(screw_clearance_hole == false) {    
    
        translate([x_pos, y_pos, -boss_radius/2 + z_offset])
            rotate([90,0,0])
                difference(){
                
                    //Square for screw reception
                    translate([0, boss_radius/4, 0])
                        linear_extrude(h=boss_height, center=false)
                            square(boss_radius, center = true, $fn=50);   
                    

                    // Screw clearance hole
                    translate([0,0,-1])
                        cylinder(h=boss_height+2, r=fuselage_screw_radius, center = true, $fn=40);
                }
                
    } if (screw_clearance_hole == true) {   

        translate([x_pos, y_pos+boss_height/2, -boss_radius/2 + z_offset])
            rotate([90,0,0])

                    // Screw clearance hole
                    translate([0,0,-1])
                        cylinder(h=4*boss_height+2, r=fuselage_screw_radius, center = true, $fn=40);
                        
    }
   

        
}

// ============================================================
//  full_aeration_fuselage — Tool module for fuselage aeration drawing 
// ============================================================ 
module full_aeration_fuselage(x1_aera, x2_aera, ct_width, ct_height) {

            //We Draw holes for aeration
            translate([x1_aera,-ct_height,-3.5*ct_width/5])
                rotate([90,0,0])
                    aeration_fuselage();

            translate([x1_aera,3*ct_height/2,-3.5*ct_width/5])
                rotate([90,0,0])
                    aeration_fuselage();  

            translate([x2_aera,-ct_height,-3.5*ct_width/5])
                rotate([90,0,0])
                    aeration_fuselage(flip=true);
                
            translate([x2_aera,3*ct_height/2,-1.5*ct_width/5])
                rotate([90,0,0])
                    aeration_fuselage(flip=true);  

}

// ============================================================
//  aeration_fuselage — Tool module for fuselage aeration drawing 
// ============================================================ 
module aeration_fuselage(flip = false) {
    
    base = aeration_width;
    height = aeration_length;
    thickness = 200;
    
    triangle_points = [[-base/2, -height/2], [base/2, -height/2],[0,height/2]];
    
    if(flip == false) 
        rotate([90,0,0])
            rotate([0,0,90])
                linear_extrude(h=thickness, center = true)
                    polygon(points=triangle_points);

    if(flip == true) 
        rotate([0,180,0])
            rotate([90,0,0])
                rotate([0,0,90])
                    linear_extrude(h=thickness, center = true)
                        polygon(points=triangle_points);                    
}    

// ------------------------
// CENTER PART
// ------------------------
module center_part(aero_grav_center, ct_width, ct_length, ct_height, rear_motor_mode = false, shape_only_mode = false){    

// 
// Parameters
// ------------------------
size = [ct_length, ct_width];    // Square size (X, Y)
tawaki_int_pin_rad = 1.25;
tawaki_ext_pin_rad = 2.9;
tawaki_ext_pin_filet_rad = 1;
tawaki_pin_height = 7;
tawaki_pin_space_length = 30.2;
tawaki_pin_space_width = 30.2;

esc_int_pin_rad = 1.25;
esc_ext_pin_rad = 3.15;
esc_ext_pin_filet_rad = 1;
esc_pin_height = 5;
esc_pin_space_length = 32;
esc_pin_space_width = 30.7;



y_offset_rear_motor = rear_motor_square_support_attach_length_y/2 + ct_height/2;

tawaki_esc_space = ct_length - main_stage_x_offset - esc_pin_space_length - 2*esc_ext_pin_rad  - esc_x_offset_pos;

main_part_rear_spar_screw_radius = 1.13;

// === Grid Parameters ===
front_offset = 6;
grid_width = 40;
grid_length = 210;


front_x_length = tawaki_pin_space_length - front_offset -2.5;
front_x_offset = tawaki_x_offset_pos + front_offset+ front_x_length/2 +1;// + tawaki_pin_space_length/2;  
front_x_width = ct_width - 25;//15; //tawaki_pin_space_width - 2*tawaki_ext_pin_rad; 
very_front_x_length = tawaki_x_offset_pos + main_stage_x_offset - front_offset-1.5;
very_front_x_offset = front_offset+ very_front_x_length/2 - main_stage_x_offset; 
mid_x_length = tawaki_esc_space-tawaki_pin_space_length-2*tawaki_ext_pin_rad - 3 - tawaki_x_offset_pos;
mid_x_offset = tawaki_x_offset_pos + tawaki_pin_space_length + mid_x_length/2 + 2*tawaki_ext_pin_rad+2;
//mid_x_offset = tawaki_esc_space  - mid_x_length/2;
mid_x_width = ct_width - 25;//15;
mid_rear_x_length = esc_pin_space_length - 3*esc_ext_pin_rad;
mid_rear_x_offset = tawaki_esc_space + 2.5*esc_ext_pin_rad + mid_rear_x_length/2; 
mid_rear_x_width = ct_width - 25; //Below ESC
rear_x_length = ct_length- main_stage_x_offset - (tawaki_esc_space + 5*esc_ext_pin_rad + mid_rear_x_length) - front_offset;
rear_x_offset = tawaki_esc_space + 5.5*esc_ext_pin_rad + mid_rear_x_length+ rear_x_length/2;
rear_x_width = ct_width - 52;//30;
one_front_length = ct_length- front_offset - rear_x_length - mid_rear_x_length -7.5*esc_ext_pin_rad;
one_front_offset = front_offset+ (one_front_length)/2 - main_stage_x_offset;




 

        if(rear_motor_mode == false && shape_only_mode == false) {


            translate([0,center_part_y_offset,0]) {
            //**** Rear Motor Attach ****//

            difference(){ //Difference for battery holder   
            
            difference(){ //Difference for the grid   
                main_stage_and_gravity_line(aero_grav_center, ct_width, ct_length, ct_height);
                grid_center_part();
            
            } // End Difference for the grid   
             
            void_battery_holder(ct_width, ct_length, ct_height);
            rear_motor_screw_removal();//Remove rear motor screw hole
            
            //*** ESC ***//
            esc_pin_support();
            
            }// End of Difference for battery holder 
                       
            //*** Tawaki ***//
            tawaki_pin_support();
            

            } // End of translate
        
        } //End if rear_motor_mode

        if(rear_motor_mode == true) {
            translate([0,center_part_y_offset,0]) {
                rear_motor();
            } // End of translate
    
        } //End if rear_motor_mode
        
        if(shape_only_mode == true) {
            translate([0,center_part_y_offset,0]) 
                    main_stage_and_gravity_line(aero_grav_center, ct_width, ct_length, ct_height);

        } //End if shape_only_mode
        
        
 
   
  


// ============================================================
//  grid_center_part — Tool module to Grid the Center Part 
// ============================================================ 
module grid_center_part(){

    union(){ //Union Object to withdraw
    
    //Very Front part
    render(convexity=5) // Use for simplification for calculation
    translate([one_front_offset,0,-center_width/2])
        rotate([90, 0, 0])
        difference() {
            // Principal part
            cube([one_front_length, front_x_width, 2*center_height], center = true);

            // Slot grid
            slot_grid();
        }
        
        
     //Rear Mid part below ESC  
    render(convexity=5) // Use for simplification for calculation
    translate([mid_rear_x_offset,0,-center_width/2])
    rotate([90, 0, 0])
        difference() {
            // Principal part
            cube([mid_rear_x_length, mid_rear_x_width, 2*center_height], center = true);

            // Slot grid
            slot_grid();
        } 
        
    //Rear part behind ESC
    render(convexity=5) // Use for simplification for calculation
    translate([rear_x_offset,0,-center_width/2])
        rotate([90, 0, 0])
            difference() {
                // Principal part
                cube([rear_x_length, rear_x_width, 2*center_height], center = true);

                // Slot grid
                slot_grid();
            }

    }//End Union Object to withdraw
}

// ============================================================
//  slot_grid — Tool module to design the grid
// ============================================================ 
module slot_grid(){
    translate([0, grid_z_offset, 0])
        rotate([0, 0, grid_angle])
            for (x = [-grid_length : slot_spacing : grid_length])
                translate([x, 0, 0])
                    cube([slot_width, grid_width * 10, 2*center_height], center = true);

    translate([0, grid_z_offset, 0])                    
        rotate([0, 0, -grid_angle])
            for (x = [-grid_length : slot_spacing : grid_length])
                translate([x, 0, 0])
                    cube([slot_width, grid_width * 10, 2*center_height], center = true);

}



// ============================================================
//  cyl_with_fillet — Tool module to draw tawaki attach with fillet
// ============================================================ 
module cyl_with_fillet(h, r, fillet_r) {

    union() {
        // cylindre principal
        cylinder(h = h, r = r, $fn = 64, center = false);

        // congé de pied (cône tronqué)
        translate([0,0,h-1])
        cylinder(
            h = fillet_r,
            r1 = r,
            r2 = r+ fillet_r,
            $fn = 64
        );
    }
}


// ============================================================
//  tawaki_pin_support — Tool module for tawaki pin 
// ============================================================ 
module tawaki_pin_support(){

//Tawaki pin support definition 1                
    //translate([tawaki_x_offset_pos + tawaki_ext_pin_rad,main_stage_y_width + tawaki_pin_height,-ct_width/2-tawaki_pin_space_width/2])
    translate([tawaki_esc_space + esc_ext_pin_rad,main_stage_y_width+tawaki_pin_height,-ct_width/2-tawaki_pin_space_width/2])
        rotate([90,0,0])                    
            color("grey")
                difference(){
                    cyl_with_fillet(h = tawaki_pin_height, r = tawaki_ext_pin_rad, tawaki_ext_pin_filet_rad);
                    cylinder(h = tawaki_pin_height, r = tawaki_int_pin_rad, center = false);
                }
    //Tawaki pin support definition 2                
    translate([tawaki_esc_space + esc_ext_pin_rad,main_stage_y_width+tawaki_pin_height,-ct_width/2+tawaki_pin_space_width/2])
        rotate([90,0,0])                    
            color("grey")
                difference(){
                    cyl_with_fillet(h = tawaki_pin_height, r = tawaki_ext_pin_rad, tawaki_ext_pin_filet_rad);
                    cylinder(h = tawaki_pin_height, r = tawaki_int_pin_rad, center = false);
                }                
    //Tawaki pin support definition 3                
    translate([tawaki_esc_space + esc_ext_pin_rad + tawaki_pin_space_length+1,main_stage_y_width+tawaki_pin_height,-ct_width/2-tawaki_pin_space_width/2])
        rotate([90,0,0])                    
            color("grey")
                difference(){
                    cyl_with_fillet(h = tawaki_pin_height, r = tawaki_ext_pin_rad, tawaki_ext_pin_filet_rad);
                    cylinder(h = tawaki_pin_height, r = tawaki_int_pin_rad, center = false);
                }                
    //Tawaki pin support definition 4                
    translate([tawaki_esc_space + esc_ext_pin_rad + tawaki_pin_space_length+1,main_stage_y_width+tawaki_pin_height,-ct_width/2+tawaki_pin_space_width/2])
        rotate([90,0,0])                    
            color("grey")
                difference(){
                    cyl_with_fillet(h = tawaki_pin_height, r = tawaki_ext_pin_rad, tawaki_ext_pin_filet_rad);
                    cylinder(h = tawaki_pin_height, r = tawaki_int_pin_rad, center = false);
                }

}


// ============================================================
//  esc_pin_support — Tool module for ESC pin 
// ============================================================ 
module esc_pin_support(){

//ESC pin support definition 1                
    translate([tawaki_esc_space + esc_ext_pin_rad,-ct_height + main_stage_y_width ,-ct_width/2-esc_pin_space_width/2])
        rotate([-90,0,0])                    
            color("grey")
                //difference(){
                    //cyl_with_fillet(h = esc_pin_height, r = esc_ext_pin_rad, esc_ext_pin_filet_rad);
                    cylinder(h = esc_pin_height, r = esc_int_pin_rad, center = false);
                //}
    //ESC pin support definition 2                
    translate([tawaki_esc_space + esc_ext_pin_rad,-ct_height + main_stage_y_width,-ct_width/2+esc_pin_space_width/2])
        rotate([-90,0,0])                    
            color("grey")
               // difference(){
                   //cyl_with_fillet(h = esc_pin_height, r = esc_ext_pin_rad, esc_ext_pin_filet_rad);
                    cylinder(h = esc_pin_height, r = esc_int_pin_rad, center = false);
               // }                
    //ESC pin support definition 3                
    translate([tawaki_esc_space + esc_ext_pin_rad + esc_pin_space_length,-ct_height + main_stage_y_width,-ct_width/2-esc_pin_space_width/2])
        rotate([-90,0,0])                    
            color("grey")
                //difference(){
                    //cyl_with_fillet(h = esc_pin_height, r = esc_ext_pin_rad, esc_ext_pin_filet_rad);
                    cylinder(h = esc_pin_height, r = esc_int_pin_rad, center = false);
                //}                
    //ESC pin support definition 4                
    translate([tawaki_esc_space + esc_ext_pin_rad + esc_pin_space_length,-ct_height + main_stage_y_width,-ct_width/2+esc_pin_space_width/2])
        rotate([-90,0,0])                    
            color("grey")
                //difference(){
                    //cyl_with_fillet(h = esc_pin_height, r = esc_ext_pin_rad, esc_ext_pin_filet_rad);
                    cylinder(h = esc_pin_height, r = esc_int_pin_rad, center = false);
               // }   

}


// ============================================================
//  rear_motor — Tool module for rear_motor
// ============================================================ 
module rear_motor(){

    screw_position = 6.5;
    z_screw_position_offset = 5.5;

    
    translate([ct_length -main_stage_x_offset,main_stage_y_width-center_height/2  ,-ct_width/2])

        rotate([0,90,0])
    difference(){
        linear_extrude(rear_motor_square_support_attach_width)
            offset(r=5)
                offset(delta=-5)
                    square([rear_motor_square_support_attach_length_z, rear_motor_square_support_attach_length_y], center=true);
            
        //rotate([45,0,0])    
        linear_extrude(rear_motor_square_support_attach_width){
        circle(r = rear_motor_int_circle_r); //hole for rear motor tree passage

        translate([rear_motor_int_circ_attach_dist_to_ct,0,0]){//Hole for screwing the rear motor
            translate([-rear_motor_int_circ_attach_r,0,0]) 
            circle(r = rear_motor_int_circ_attach_r);     
            translate([rear_motor_int_circ_attach_r,0,0]) 
            circle(r = rear_motor_int_circ_attach_r);       
            square([2*rear_motor_int_circ_attach_r, 2*rear_motor_int_circ_attach_r], center=true);
        }     
                   
        translate([-rear_motor_int_circ_attach_dist_to_ct,0,0]){//Hole for screwing the rear motor
            translate([-rear_motor_int_circ_attach_r,0,0]) 
            circle(r = rear_motor_int_circ_attach_r);     
            translate([rear_motor_int_circ_attach_r,0,0]) 
            circle(r = rear_motor_int_circ_attach_r);       
            square([2*rear_motor_int_circ_attach_r, 2*rear_motor_int_circ_attach_r], center=true);
        }         
         
        translate([0,rear_motor_int_circ_attach_dist_to_ct,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([-rear_motor_int_circ_attach_r,0,0]) 
                circle(r = rear_motor_int_circ_attach_r);     
                translate([rear_motor_int_circ_attach_r,0,0]) 
                circle(r = rear_motor_int_circ_attach_r);       
                square([2*rear_motor_int_circ_attach_r, 2*rear_motor_int_circ_attach_r], center=true);
            }
        }   

        translate([0,-rear_motor_int_circ_attach_dist_to_ct,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([-rear_motor_int_circ_attach_r,0,0]) 
                circle(r = rear_motor_int_circ_attach_r);     
                translate([rear_motor_int_circ_attach_r,0,0]) 
                circle(r = rear_motor_int_circ_attach_r);       
                square([2*rear_motor_int_circ_attach_r, 2*rear_motor_int_circ_attach_r], center=true);
            }
        }  
        
        
        //Hole for screwing rear motor support to center part 
                translate([-z_screw_position_offset-rear_motor_int_circ_attach_dist_to_ct,screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([-rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        } 
                translate([-z_screw_position_offset-rear_motor_int_circ_attach_dist_to_ct,-screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        }         
                translate([z_screw_position_offset+rear_motor_int_circ_attach_dist_to_ct,screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([-rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        } 
                translate([z_screw_position_offset+rear_motor_int_circ_attach_dist_to_ct,-screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        }
        }// End of Linear Extrude
    } // End of difference
}

}// End of Center part module



// ============================================================
//  rear_motor_cable_passage — Module use for removing center part and make room for rear motor cables
// ============================================================ 
module rear_motor_cable_passage (){

    cable_passage_radius = 3.5;
    cable_passage_length = 30;
    z_adjust = 2.5;
    
    translate([center_length -main_stage_x_offset-cable_passage_length/4,main_stage_y_width-center_height/2  ,-center_width/4 + z_adjust]) {
    
        rotate([0,90,0])
            cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50);  
            
        translate([-cable_passage_length/2,0,0])
            rotate([0,0,90])
                rotate([0,90,0])
                    cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50); 

    }
    
    translate([center_length -main_stage_x_offset-cable_passage_length/4,main_stage_y_width-center_height/2  ,-3*center_width/4 - z_adjust]) {
    
        rotate([0,90,0])
            cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50);  
            
        translate([-cable_passage_length/2,0,0])
            rotate([0,0,90])
                rotate([0,90,0])
                    cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50); 

    }    
}


// ============================================================
//  rear_motor_screw_removal — Module use for removing screw for rear motor in center part
// ============================================================ 
module rear_motor_screw_removal(){

    screw_position = 6.5;
    srew_hole_length = rear_motor_square_support_attach_width*2;
    z_screw_position_offset = rear_motor_screw_distance/2;

    
    translate([center_length -main_stage_x_offset- srew_hole_length,main_stage_y_width-center_height/2  ,-center_width/2])

        rotate([0,90,0])
        linear_extrude(rear_motor_square_support_attach_width*3){

        
        
        //Hole for screwing rear motor support to center part 
                translate([-z_screw_position_offset-rear_motor_int_circ_attach_dist_to_ct,screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([-rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        } 
                translate([-z_screw_position_offset-rear_motor_int_circ_attach_dist_to_ct,-screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        }         
                translate([z_screw_position_offset+rear_motor_int_circ_attach_dist_to_ct,screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([-rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        } 
                translate([z_screw_position_offset+rear_motor_int_circ_attach_dist_to_ct,-screw_position,0]){//Hole for screwing the rear motor
            rotate([0,0,90]){
                translate([rear_motor_int_circ_attach_r,-0,0]) 
                circle(r = rear_motor_int_circ_attach_r);           
            } 
        }
        
        }// End of Linear Extrude

}


// ============================================================
//  rear_fuselage_block_grid — Module use for remove part from rear motor fuselage
// ============================================================ 
module rear_fuselage_block_grid(rear_offset = 2) {


    diameter = rear_motor_screw_distance+3*rear_motor_int_circ_attach_dist_to_ct/4;
    length = 10;
    y_offset = 4;
    

    translate([L_total -nozzle_length - rear_offset, main_stage_y_width-center_height/2 + diameter/4+ y_offset,-center_width/2])  
        
        rotate([0,90,0])
            cylinder(h = length,d = diameter, center = true);
            
            
    translate([L_total -nozzle_length - rear_offset, -main_stage_y_width+center_height/2 -diameter/4- y_offset,-center_width/2])  
        
        rotate([0,90,0])
            cylinder(h = length,d = diameter, center = true);            


}

 
// ============================================================
//  main_stage_and_gravity_line — Module use to draw gravity line 
// ============================================================ 
module main_stage_and_gravity_line(aero_grav_center, ct_width, ct_length, ct_height){

        union(){
        //Main stage support definition
        translate([ct_length/2 - main_stage_x_offset,main_stage_y_width,-ct_width/2])
            rotate([90,0,0])
                linear_extrude(ct_height)
                    offset(r=radius)
                        offset(delta=-radius)
                            square([ct_length, ct_width], center=true);
                          
        //Draw CG Line on main stage up and bottom
        translate([aero_grav_center[1],main_stage_y_width,-ct_width])  
            color("red")
                cube([gravity_line_width,gravity_line_height, ct_width]);

        translate([aero_grav_center[1],main_stage_y_width - ct_height - gravity_line_height,-ct_width])  
            color("red")
                cube([gravity_line_width,gravity_line_height, ct_width]);
     } // End of union 1
}  
 

// ============================================================
//  void_battery_holder — Module use to draw battery holder in Center part 
// ============================================================  
module void_battery_holder(ct_width, ct_length, ct_height){

    batt_6_hole_width = 3*battery_hole_width/4;
    batt_6_z_offset = 1*battery_hole_width/4;
    batt_5_hole_width = 3*battery_hole_width/5;
    batt_5_z_offset = 2*battery_hole_width/5;    

     union(){ //Union for battery hole to attach to Center part

        translate([battery_x_pos_1,main_stage_y_width-2*ct_height,-ct_width/2 + battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);

        translate([battery_x_pos_1,main_stage_y_width-2*ct_height,-ct_width/2 - battery_hole_width - battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);
                    
        translate([battery_x_pos_2,main_stage_y_width-2*ct_height,-ct_width/2 + battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);

        translate([battery_x_pos_2,main_stage_y_width-2*ct_height,-ct_width/2 - battery_hole_width - battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);     
                   
        translate([battery_x_pos_3,main_stage_y_width-2*ct_height,-ct_width/2 + battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);

        translate([battery_x_pos_3,main_stage_y_width-2*ct_height,-ct_width/2 - battery_hole_width - battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);                       

        translate([battery_x_pos_4,main_stage_y_width-2*ct_height,-ct_width/2 + battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);

        translate([battery_x_pos_4,main_stage_y_width-2*ct_height,-ct_width/2 - battery_hole_width - battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);  
                    
        translate([battery_x_pos_5,main_stage_y_width-2*ct_height,-ct_width/2 + battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, batt_5_hole_width]);

        translate([battery_x_pos_5,main_stage_y_width-2*ct_height,-ct_width/2 - battery_hole_width - battery_width/2 + batt_5_z_offset])  
            color("green")
                    cube([battery_hole_length,4*ct_height, batt_5_hole_width]);       
     
        translate([battery_x_pos_6,main_stage_y_width-2*ct_height,-ct_width/2 + battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, batt_6_hole_width]);

        translate([battery_x_pos_6,main_stage_y_width-2*ct_height,-ct_width/2 - battery_hole_width - battery_width/2 + batt_6_z_offset])  
            color("green")
                    cube([battery_hole_length,4*ct_height, batt_6_hole_width]);
               
        translate([battery_x_pos_7,main_stage_y_width-2*ct_height,-ct_width/2 + battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);

        translate([battery_x_pos_7,main_stage_y_width-2*ct_height,-ct_width/2 - battery_hole_width - battery_width/2])  
            color("green")
                    cube([battery_hole_length,4*ct_height, battery_hole_width]);          
          
                    
     }// End of union 2

} 
 