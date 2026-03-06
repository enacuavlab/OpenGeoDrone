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
// ------------------------
// FUSELAGE GENERATOR
// ------------------------
module CreateFuselage(fuse_ellipse_param) {

    s = fuselage_sections();

    //Main fuselage part
    translate([-fuselage_x_offset,0,-fuselage_z_offset])
        rotate([0,90,0]){
            bubble_bezier_fit_superellipse(length=nozzle_length, rx=s[0][1], ry=s[0][2], fuse_ellipse_param);
            for(i = [0 : len(s)-2]) {
                hull() {
                    frame(s[i][0],   s[i][1], s[i][2],fuse_ellipse_param);
                    frame(s[i+1][0], s[i+1][1], s[i+1][2],fuse_ellipse_param);
                }
            }
        }
        
        
        
        // *** HULL from the FUSELAGE to TAIL *** //
        //tail fuselage part, here we need to hull from the end of fuselage to tail of fuselage
        hull() {
            translate([-fuselage_x_offset,0,-fuselage_z_offset])
                rotate([0,90,0])
                    frame(s[len(s)-1][0], s[len(s)-1][1], s[len(s)-1][2],fuse_ellipse_param);
            tail_fuselage();
        }//End of hull FUSELAGE TO TAIL
        
        
        
        
        // *** HULL from the FUSELAGE to WINGS LEFT PART *** //
        hull() {
            
            union(){
            //Main fuselage part
            translate([-fuselage_x_offset,0,-fuselage_z_offset])
                rotate([0,90,0]){
                    for(i = [0 : len(s)-2]) {
                        hull() {
                            frame(s[i][0],   s[i][1], s[i][2],fuse_ellipse_param);
                            frame(s[i+1][0], s[i+1][1], s[i+1][2],fuse_ellipse_param);
                        }
                    }
                }
        
                //tail fuselage part, here we need to hull from the end of fuselage to tail of fuselage
        hull() {
            translate([-fuselage_x_offset,0,-fuselage_z_offset])
                rotate([0,90,0])
                    frame(s[len(s)-1][0], s[len(s)-1][1], s[len(s)-1][2],fuse_ellipse_param);
            tail_fuselage();
        }//End of hull
        }
             intersection(){//We keep a wingshell slice 
                    wing_shell();
                    translate([-2*wing_root_chord_mm,-2500,0])
                            cube([4*wing_root_chord_mm,5000,0.0001]);
             }

        }//End of hull FUSELAGE TO WINGS

        // *** HULL from the FUSELAGE to WINGS RIGHT PART *** //        
        mirror([0, 0, 1]) 
            translate([0, 0, center_width]){
            
        hull() {
            
            union(){
            //Main fuselage part
            translate([-fuselage_x_offset,0,-fuselage_z_offset])
                rotate([0,90,0]){
                    for(i = [0 : len(s)-2]) {
                        hull() {
                            frame(s[i][0],   s[i][1], s[i][2],fuse_ellipse_param);
                            frame(s[i+1][0], s[i+1][1], s[i+1][2],fuse_ellipse_param);
                        }
                    }
                }
        
                //tail fuselage part, here we need to hull from the end of fuselage to tail of fuselage
        hull() {
            translate([-fuselage_x_offset,0,-fuselage_z_offset])
                rotate([0,90,0])
                    frame(s[len(s)-1][0], s[len(s)-1][1], s[len(s)-1][2],fuse_ellipse_param);
            tail_fuselage();
        }//End of hull
        }
             intersection(){//We keep a wingshell slice 
                    wing_shell();
                    translate([-2*wing_root_chord_mm,-2500,0])
                            cube([4*wing_root_chord_mm,5000,0.0001]);
             }

        }//End of hull FUSELAGE TO WINGS
            
            
            
            
            }//End of translate
        



}

module tail_fuselage(){

    hull_width = 0.00000001;
    poly_size = rear_motor_square_support_attach_length_y/2; //Size of original rear motor support square
    hexa_factor = 2.5; //extension on sides of the hexagon
    polygon_points = [[poly_size, -poly_size], [-poly_size, -poly_size],[-hexa_factor*poly_size, -0], [-poly_size, poly_size],[poly_size, poly_size], [hexa_factor*poly_size, 0]]; // Points of polygon

    translate([center_length -main_stage_x_offset,main_stage_y_width-center_height/2 +center_part_y_offset ,-center_width/2]) {
        rotate([0,90,0]) {
        
            linear_extrude(h=hull_width)
                offset(r=6)
                    offset(delta=-6)
                        polygon(points=polygon_points);
                
        }//End of rotate
    }//End of translate
}



//Module for pitot tube creation
//outside_diameter == true => outside diameter drawing for fuselage
//outside_diameter == false => make hole inside outside diameter for pitot tube insertion
module Create_pitot(pitot_rad, pitot_len, outside_diameter = true) {

    if(outside_diameter == true){
    
    difference() {
    
        intersection() {
            
            render(convexity=5) // Use for simplification for calculation
                CreateFuselage(fuselage_ellipse_param);
           
            translate([-fuselage_x_offset-nozzle_length+pitot_len/2,0,-center_width/2])
                rotate([0,90,0])
                    cylinder(h=pitot_len, r=2*pitot_rad, center = true, $fn=50);       
        }//End intersection
    
        translate([-fuselage_x_offset-nozzle_length+pitot_len/2,0,-center_width/2])
        rotate([0,90,0])
        cylinder(h=2*pitot_len, r=pitot_rad, center = true, $fn=50); 
        
    }//End difference
    
    }//End if
    
    if(outside_diameter == false){

        translate([-fuselage_x_offset-nozzle_length+pitot_len/2,0,-center_width/2])
            rotate([0,90,0])
                cylinder(h=2*pitot_len, r=pitot_rad, center = true, $fn=50);       
        
    }
}




//Module to create a overlapp between bottom and to front to get a nice fuselage transition between part
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


//Module used to create a small block at the end of the center part to stop the fuselage
//Hole parameter is used when we draw the part to activate a hole drawing in the middle
module rear_fuselage_block (aero_grav_center, rear_offset = 2, hole = false) {

    cube_position = L_total- main_stage_x_offset - rear_offset;
    difference() {
    
        intersection() {
            render() // Use for simplification for calculation
                CreateFuselage(fuselage_ellipse_param);  

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


//Module to create a overlapp between upper and to front to get a nice fuselage transition between part
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

module fuselage_transition(x_offset, overlap_length = 15, up = true) {

    intersection(){

        render() // Use for simplification for calculation
            CreateFuselage(fuselage_ellipse_param);
        
            if(up == true)
                translate([x_offset,500,0])
                    cube([overlap_length,1000,1000], center=true);
                    
            if(up == false)
                translate([x_offset,-500,0])
                    cube([overlap_length,1000,1000], center=true);                
    }
}


// if fuselage_mode == true => magnet for fuselage, if fuselage_mode == false => magnet for center part
module all_magnet(magnet_dim, fuselage_mode = true) {
    
    

        shell_scale = 1.8;
        
        intersection() {
        
        render(convexity=5) // Use for simplification for calculation
        CreateFuselage(fuselage_ellipse_param);
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

module all_fuselage_screws(boss_height = 10, screw_clearance_hole = false) {
    
    if(screw_clearance_hole == false) {
    
        intersection() {
        
        render(convexity=5) // Use for simplification for calculation
        CreateFuselage(fuselage_ellipse_param);
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


//screw_clearance_hole parameter is used for create hole in center part to insert screws
module fuselage_screw(x_pos, z_offset = 0, boss_height = 10, screw_clearance_hole = false) {

    y_pos = center_height-main_stage_y_width - boss_height;
    boss_radius = 14;

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





function fuselage_sections() = 
    [ for(i = [0 : num]) 
        let(
            t = i/num,                              // progression 0 → 1
            z = t * L_total,                      // position on length
            // Shape law: "water drop"
            // rapid rise -> plateau -> slow descent
            //k = sin(t*180),                       // smooth aerodynamic shape
            //D = D_front*(1-t) + D_max*k*(1-t/1.2) + D_tail*t  // tapered interpolation
            D = bezier1D(t,
             D_front,
             D_front + 0.6*D_max,
             D_tail + 0.6*D_max,
             D_tail)
        )
        [z, D/2, D*0.75/2 * fuselage_scale_y]                        // rx, ry elliptical axes
    ];



    
// frame super-ellipse generalised / anisotrope (rounded rectangle)
module frame(z, rx, ry, n = [4,4]){

    hull_width = 0.00000001;
    steps = 100;

    translate([0,0,z])
        linear_extrude(h=hull_width, center=false)
            polygon(points = [
                for (i = [0:steps-1])
                    let(
                        a = 360 * i/steps,
                        ca = cos(a),
                        sa = sin(a),

                        x = rx * sign(ca) * pow(abs(ca), 2/n[0]),
                        y = ry * sign(sa) * pow(abs(sa), 2/n[1])
                    )
                    [x, y]
            ]);
}



function bezier1D(t,p0,p1,p2,p3) =
    (1-t)*(1-t)*(1-t)*p0 +
    3*(1-t)*(1-t)*t*p1 +
    3*(1-t)*t*t*p2 +
    t*t*t*p3;
    


module bubble_bezier_fit_superellipse(length, rx, ry, n = [4,4]){

    
    P0 = [0,1];
    P1 = [-0.05,1];
    P2 = [-0.75,0.55];
    P3 = [-1,0];

    function bezier(t,p0,p1,p2,p3) =
        (1-t)*(1-t)*(1-t)*p0 +
        3*(1-t)*(1-t)*t*p1 +
        3*(1-t)*t*t*p2 +
        t*t*t*p3;

    steps = 40;

    // Section Generation
    sections = [
        for(i=[0:steps])
            let(
                t = i/steps,
                p = bezier(t,P0,P1,P2,P3),
                z = p[0] * length,
                scale_factor = p[1]
            )
            [z, rx*scale_factor, ry*scale_factor]
    ];

    // Loft progressive
    for(i=[0:len(sections)-2]){
        hull(){
            frame(
                sections[i][0],
                sections[i][1],
                sections[i][2],
                n
            );
            frame(
                sections[i+1][0],
                sections[i+1][1],
                sections[i+1][2],
                n
            );
        }
    }
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
rear_x_width = ct_width - 30;//15;
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




//Module use ofr removing center part and make room for rear motor cables
module rear_motor_cable_passage (){

    cable_passage_radius = 3.5;
    cable_passage_length = 20;    
    
    translate([center_length -main_stage_x_offset-cable_passage_length/4,main_stage_y_width-center_height/2  ,-center_width/4]) {
    
        rotate([0,90,0])
            cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50);  
            
     /*   translate([-cable_passage_length/2,0,0])
            rotate([0,0,90])
                rotate([0,90,0])
                    cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50); 
*/
    }
    
    translate([center_length -main_stage_x_offset-cable_passage_length/4,main_stage_y_width-center_height/2  ,-3*center_width/4]) {
    
        rotate([0,90,0])
            cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50);  
            
       /* translate([-cable_passage_length/2,0,0])
            rotate([0,0,90])
                rotate([0,90,0])
                    cylinder(h=cable_passage_length, r=cable_passage_radius, center = true, $fn=50); */

    }    
}


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

//Module use for remove part from rear motor fuselage
module rear_fuselage_block_grid(rear_offset = 2) {


    diameter = rear_motor_screw_distance+3*rear_motor_int_circ_attach_dist_to_ct/4;
    length = 10;
    

    translate([L_total -main_stage_x_offset - rear_offset + length/2,main_stage_y_width-center_height/2 + diameter/4,-center_width/2])  
        
        rotate([0,90,0])
            cylinder(h = length,d = diameter, center = true);


}

 

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
 
//bubble_bezier_fit_elliptic(length=nozzle_length, rx=s[0][1], ry=s[0][2]);
/*    
module bubble_bezier_fit_elliptic(length, rx, ry) {
    // rx = X semi-axis of the first fuselage section
    // ry = Y semi-axis of the first fuselage section

    // 2D normalized profile (radius = 1)
    P0 = [0,1];                   // start of the connection
    P1 = [-0.3, 1.02];            // slightly wider bubble just after the start
    P2 = [-0.8, 0.3];             // gradual tapering
    P3 = [-1, 0];                  // nose tip

    // Cubic Bézier function
    function bezier(t,p0,p1,p2,p3) = 
        (1-t)*(1-t)*(1-t)*p0 +
        3*(1-t)*(1-t)*t*p1 +
        3*(1-t)*t*t*p2 +
        t*t*t*p3;

    // Sample the Bézier curve from t=0 to t=1
    profile = [for(t=[0:0.01:1]) bezier(t,P0,P1,P2,P3)];

    // Scale the profile to match the ellipse axes of the fuselage
    translate([0,0,-0.01])   // slight offset to avoid z-fighting
    scale([rx, ry, length])
        rotate([0,180,0])
            rotate_extrude($fn=160)
                polygon(profile);
}
*/
 
                    /*frame(s[i][0],   s[i][1], s[i][2], s[i][3]);
                    frame(s[i+1][0], s[i+1][1], s[i+1][2], s[i+1][3]);*/ 
/*
poly_size = rear_motor_square_support_attach_length_y/2; // taille du carré de base
hexa_factor = 2.5;                                        // extensions pour hexagone
hex_points = [[poly_size, -poly_size],
              [-poly_size, -poly_size],
              [-hexa_factor*poly_size, 0],
              [-poly_size, poly_size],
              [poly_size, poly_size],
              [hexa_factor*poly_size, 0]]; // points de ton hexagone
*/
 
 

/*
rx_tail = rear_motor_square_support_attach_length_z/2;
ry_tail = rear_motor_square_support_attach_length_y/2;
L_total_full = L_total + tail_length;
tail_steps = 20;*/
/*
function fuselage_sections() =
[
    for(i = [0:num])
        let(
            t = i/num,
            z = t * L_total,

            // Bézier 1D pour diamètre
            D = bezier1D(t,
                         D_front,
                         D_front + 0.6*D_max,
                         D_tail,
                         D_tail)
        )
        [z, D/2, D*0.75/2 * fuselage_scale_y],

    // -------- Transition vers tail --------

    for(i = [1:tail_steps])
        let(
            t = i/tail_steps,
            z = L_total + t*tail_length,

            rx = bezier1D(t,
                          D_tail/2,
                          D_tail/2,
                          rx_tail,
                          rx_tail),

            ry = bezier1D(t,
                          D_tail*0.75/2 *fuselage_scale_y,
                          D_tail*0.75/2 *fuselage_scale_y,
                          ry_tail,
                          ry_tail)
        )
        [z, rx, ry]
];
*/

//n_fuse = fuselage_ellipse_param;   // ex: [4,4]
//n_tail = [40,40];              // approx hexagone
/*
function fuselage_sections() =
[
    // ----- FUSELAGE -----
    for(i = [0:num])
        let(
            t = i/num,
            z = t * L_total,

            D = bezier1D(t,
                         D_front,
                         D_front + 0.6*D_max,
                         D_tail,
                         D_tail),

            n_interp = n_fuse
        )
        [z, D/2, D*0.75/2 * fuselage_scale_y, n_interp],

    // ----- TRANSITION VERS HEX -----
    for(i = [1:tail_steps])
        let(
            t = i/tail_steps,
            z = L_total + t*tail_length,

            rx = bezier1D(t,
                          D_tail/2,
                          D_tail/2,
                          rx_tail,
                          rx_tail),

            ry = bezier1D(t,
                          D_tail*0.75/2 * fuselage_scale_y,
                          D_tail*0.75/2 * fuselage_scale_y,
                          ry_tail,
                          ry_tail),

            n_interp = [
                bezier1D(t, n_fuse[0], n_fuse[0], n_tail[0], n_tail[0]),
                bezier1D(t, n_fuse[1], n_fuse[1], n_tail[1], n_tail[1])
            ]
        )
        [z, rx, ry, n_interp]
];*/
/*
function fuselage_sections() =
[
    // ----- FUSELAGE -----
    for(i=[0:num])
        let(
            t = i/num,
            z = t*L_total,
            D = bezier1D(t,D_front,D_front+0.6*D_max,D_tail,D_tail),
            n_interp = fuse_ellipse_param,
            shape = "super"
        )
        [z, D/2, D*0.75/2*fuselage_scale_y, n_interp, shape],

    // ----- TRANSITION VERS HEX CUSTOM -----
    for(i=[1:tail_steps])
        let(
            t = i/tail_steps,
            z = L_total + t*tail_length,
            rx = bezier1D(t,D_tail/2,D_tail/2,rx_tail,rx_tail),
            ry = bezier1D(t,D_tail*0.75/2*fuselage_scale_y,D_tail*0.75/2*fuselage_scale_y,ry_tail,ry_tail),
            n_interp = [bezier1D(t,fuse_ellipse_param[0],fuse_ellipse_param[0],20,20),
                        bezier1D(t,fuse_ellipse_param[1],fuse_ellipse_param[1],20,20)],
            shape = t < 0.5 ? "super" : "hex"
        )
        [z, rx, ry, n_interp, shape]
];
*/ 




/*
module frame(z, rx, ry, n=[4,4], shape="super") {
    hull_width = 0.00000001;
    steps = 100;

    translate([0,0,z])
        linear_extrude(h=hull_width, center=false)
            if(shape=="super") {
                polygon(points=[
                    for(i=[0:steps-1])
                        let(
                            a = 360*i/steps,
                            ca = cos(a),
                            sa = sin(a),
                            x = rx*sign(ca)*pow(abs(ca),2/n[0]),
                            y = ry*sign(sa)*pow(abs(sa),2/n[1])
                        )
                        [x,y]
                ]);
                }
            if(shape=="hex") {
                polygon(points=[
                    for(p=[for(pt = hex_points) pt])
                        [p[0]*rx/poly_size, p[1]*ry/poly_size] // <--- Scale correct
                ]);}
}
*/