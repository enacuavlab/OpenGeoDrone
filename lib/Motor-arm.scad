module CreateMotorArm(aero_grav_center){

    gravity_line_width = 2;
    gravity_line_height = 1;

    all_pts_le = get_leading_edge_points();
    all_pts_te = get_trailing_edge_points();

    pt_le_leftside_top = find_interpolated_point(wing_root_mm +motor_arm_width +motor_arm_to_wing_hull, all_pts_le);
    pt_le_leftside_bot = find_interpolated_point(wing_root_mm +motor_arm_width/2, all_pts_le);
    pt_le_rightside_top = find_interpolated_point(wing_root_mm, all_pts_le);
    pt_le_rightside_bot = find_interpolated_point(wing_root_mm - motor_arm_to_wing_hull , all_pts_le);
    pt_te_leftside_top = find_interpolated_point(wing_root_mm +motor_arm_width +motor_arm_to_wing_hull, all_pts_te);
    pt_te_leftside_bot = find_interpolated_point(wing_root_mm +motor_arm_width/2, all_pts_te);
    pt_te_rightside_top = find_interpolated_point(wing_root_mm, all_pts_te);
    pt_te_rightside_bot = find_interpolated_point(wing_root_mm - motor_arm_to_wing_hull , all_pts_te);
    
    x_position_front_back = aero_grav_center[1] + motor_arm_grav_center_offset;
    magical_coeff = 0.4; // == 2*(1-0.8) where 0.8 is the z position of end of lock and the 2 times correspond the the mid maj axis


motor_arm(ellipse_maj_ax, ellipse_min_ax, motor_arm_length_front, motor_arm_length_back, motor_arm_height, motor_arm_tilt_angle, motor_arm_screw_fit_offset, aero_grav_center, motor_arm_grav_center_offset, motor_arm_y_offset, back =Motor_arm_back, front = Motor_arm_front, full = Motor_arm_full);

    //**************** Gravity Line Creation **********//
    translate([aero_grav_center[1],-ellipse_maj_ax + gravity_line_height,wing_root_mm- ellipse_maj_ax])  
        color("red")
            cube([gravity_line_width,gravity_line_height, 4*ellipse_maj_ax]);
            
    //**************** Motor Arm **********//
                
        difference() {
        
            hull(){//left side motor arm hull
            
                intersection(){//We keep the motor arm in connection with wings only
                    motor_arm(ellipse_maj_ax, ellipse_min_ax, motor_arm_length_front, motor_arm_length_back, motor_arm_height, motor_arm_tilt_angle, motor_arm_screw_fit_offset, aero_grav_center, motor_arm_grav_center_offset, motor_arm_y_offset, back =Motor_arm_back, front = Motor_arm_front, full = Motor_arm_full);
                    if(Motor_arm_front){
                        translate([pt_le_leftside_bot[0],-2500,wing_root_mm + motor_arm_width-magical_coeff*ellipse_maj_ax])
                            cube([x_position_front_back-pt_le_leftside_bot[0],5000,5000]);
                    }
                    if(Motor_arm_back){
                        translate([x_position_front_back,-2500,wing_root_mm + motor_arm_width-magical_coeff*ellipse_maj_ax])
                            cube([pt_te_leftside_bot[0]-x_position_front_back,5000,5000]);
                    }
                    if(Motor_arm_full || Full_system){
                        translate([pt_le_leftside_bot[0],-2500,wing_root_mm + motor_arm_width-magical_coeff*ellipse_maj_ax])
                            cube([pt_te_leftside_bot[0]-pt_le_leftside_bot[0],5000,5000]);
                    }
                }//End of intersection
                
                intersection(){//We keep the wingshell slice at motor_arm_to_wing_hull distance from motor arm to hull on it
                    wing_shell();
                    if(Motor_arm_front){
                        translate([pt_le_leftside_top[0],-2500,wing_root_mm + motor_arm_width+motor_arm_to_wing_hull])
                            cube([x_position_front_back-pt_le_leftside_top[0],5000,0.0001]);
                    }
                    if(Motor_arm_back){
                        translate([x_position_front_back,-2500,wing_root_mm + motor_arm_width+motor_arm_to_wing_hull])
                            cube([pt_te_leftside_top[0]-x_position_front_back,5000,0.0001]);
                    } 
                    if(Motor_arm_full || Full_system){
                        translate([pt_le_leftside_top[0],-2500,wing_root_mm + motor_arm_width+motor_arm_to_wing_hull])
                            cube([pt_te_leftside_top[0]-pt_le_leftside_top[0],5000,0.0001]);
                    }                    
                } //End of intersection
            
            }//End of hull
            motor_arm(ellipse_maj_ax, ellipse_min_ax, motor_arm_length_front, motor_arm_length_back, motor_arm_height, motor_arm_tilt_angle, motor_arm_screw_fit_offset, aero_grav_center, motor_arm_grav_center_offset, motor_arm_y_offset, back =false, front = false, full = true);
            
        }           
            
            
      difference() {
      
            hull(){//right side motor arm hull
            
                intersection(){//We keep the motor arm in connection with wings only
                    motor_arm(ellipse_maj_ax, ellipse_min_ax, motor_arm_length_front, motor_arm_length_back, motor_arm_height, motor_arm_tilt_angle, motor_arm_screw_fit_offset, aero_grav_center, motor_arm_grav_center_offset, motor_arm_y_offset, back =Motor_arm_back, front = Motor_arm_front, full = Motor_arm_full);
                    if(Motor_arm_front){
                        translate([pt_le_rightside_top[0],-2500,wing_root_mm + magical_coeff*ellipse_maj_ax-5000])
                            cube([x_position_front_back-pt_le_rightside_top[0],5000,5000]);
                    }
                    if(Motor_arm_back){
                        translate([x_position_front_back,-2500,wing_root_mm + magical_coeff*ellipse_maj_ax-5000])
                            cube([pt_te_rightside_top[0]-x_position_front_back,5000,5000]);
                    }  
                    if(Motor_arm_full || Full_system){
                        translate([pt_le_rightside_top[0],-2500,wing_root_mm + magical_coeff*ellipse_maj_ax-5000])
                            cube([pt_te_rightside_top[0]-pt_le_rightside_top[0],5000,5000]);
                    }                    
                }//End of intersection
                
                intersection(){//We keep the wingshell slice at motor_arm_to_wing_hull distance from motor arm to hull on it
                    wing_shell();
                    if(Motor_arm_front){
                        translate([pt_le_rightside_bot[0],-2500,wing_root_mm -motor_arm_to_wing_hull])
                            cube([x_position_front_back-pt_le_rightside_bot[0],5000,0.0001]);
                    }
                    if(Motor_arm_back){
                        translate([x_position_front_back,-2500,wing_root_mm -motor_arm_to_wing_hull])
                            cube([pt_te_rightside_bot[0]-x_position_front_back,5000,0.0001]);
                    }    
                    if(Motor_arm_full || Full_system){
                        translate([pt_le_rightside_bot[0],-2500,wing_root_mm -motor_arm_to_wing_hull])
                            cube([pt_te_rightside_bot[0]-pt_le_rightside_bot[0],5000,0.0001]);
                    }                      
                } //End of intersection
            
            }//End of hull
            motor_arm(ellipse_maj_ax, ellipse_min_ax, motor_arm_length_front, motor_arm_length_back, motor_arm_height, motor_arm_tilt_angle, motor_arm_screw_fit_offset, aero_grav_center, motor_arm_grav_center_offset, motor_arm_y_offset, back =false, front = false, full = true);
            
        } 
        
}



module motor_arm(a_ellipse, b_ellipse, arm_length_front, arm_length_back, motor_height, arm_tilt_angle, arm_screw_fit_offset, aero_grav_center, grav_center_offset, y_offset, back = false, front = false, full = true) {
   
    
    //**************** Parameters **********//
    trim_plan_dim = 100;
    screw_hole_motor_arm_offset = 3.7;
    screw_hole_1 = 3;
    screw_hole_2 = 1.5;
    motor_footprint_long = 8;//9.5; Parameters to change motor screw holes position
    motor_footprint_short = 8; //Parameters to change motor screw holes position
    dummy_motor_base_radius = 9.5;
    dummy_motor_base_height = 20;
    motor_support_scale = 1.8;
    dummy_helix_radius = 90; //6 inch
    dummy_helix_height = 20;
    x_pos_screw_long = cos(45) * (motor_footprint_long );
    y_pos_screw_long = sin(45) * (motor_footprint_long );
    x_pos_screw_short = cos(45) * (motor_footprint_short );
    y_pos_screw_short = sin(45) * (motor_footprint_short );
    motor_x_pos = aero_grav_center[1] + grav_center_offset;

    
    
    //Echo lock parameters
    alpha = 15;
    width = a_ellipse ; 
    taper_angle = 1.5;
    piece_height = 4*b_ellipse;
    offset_clearance = 0.95;
    
        
    width_w_clearance = width * offset_clearance;
    lock_length = 1.52  * width;
    lock_length_2_start = 0.57 *width;
    lock_length_2_stop = 0.8 *width;
    lock_length_2_height = lock_length_2_stop - lock_length_2_start;
    
    //**************** End Parameters **********//
    

            
    difference() // Difference front / back / full
    { 
    union(){ //Union for whole arm
        
    difference() // Difference for trim, screw holes
    {  
        union(){
    // Draw the arm
    translate([ motor_x_pos + arm_length_back, y_offset, wing_root_mm+a_ellipse])
        rotate([ 0, -90, 0 ])
            
            linear_extrude(height = arm_length_front+arm_length_back)
                scale([1, b_ellipse/a_ellipse])
                    circle(r = a_ellipse, $fn=100); 
            
    //**************** Front arm **********//
    //Draw connexion arm to motor support
    translate([ motor_x_pos - arm_length_front, y_offset, wing_root_mm+a_ellipse])
        scale([1, b_ellipse/a_ellipse])
           sphere(a_ellipse, $fn=100 );

    // Draw the motor support
    translate([ motor_x_pos - arm_length_front, y_offset, wing_root_mm+a_ellipse])
        rotate([ 0, 90, 90 ])
            linear_extrude(height = motor_height+b_ellipse, scale = motor_support_scale)
                circle(r = a_ellipse, $fn=100);

    //**************** Back arm **********//
    //Draw connexion arm to motor support
    translate([ motor_x_pos + arm_length_back, y_offset, wing_root_mm+a_ellipse])
        scale([1, b_ellipse/a_ellipse])
           sphere(a_ellipse, $fn=100 );

    // Draw the motor support
    translate([ motor_x_pos + arm_length_back, y_offset, wing_root_mm+a_ellipse])
        rotate([ 0, 90, 90 ])
            linear_extrude(height = motor_height+b_ellipse, scale = motor_support_scale)
                circle(r = a_ellipse, $fn=100);
                
        }
    
    
    union(){    
    //**************** Front arm **********//   
    //Draw trim plan
    translate([ motor_x_pos - arm_length_front -trim_plan_dim/2, y_offset + b_ellipse + motor_height , wing_root_mm+a_ellipse - trim_plan_dim/2 ]) {
            rotate([ arm_tilt_angle, 0, 0]) {
        
        cube([ trim_plan_dim, trim_plan_dim, trim_plan_dim ]);
    
    //Screw hole position           
    translate([trim_plan_dim/2 +y_pos_screw_short, 0, arm_screw_fit_offset + trim_plan_dim/2 + x_pos_screw_short])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Screw hole position   
    translate([trim_plan_dim/2 -y_pos_screw_short, 0, arm_screw_fit_offset + trim_plan_dim/2 - x_pos_screw_short])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Screw hole position   
    translate([trim_plan_dim/2 -y_pos_screw_long, 0, arm_screw_fit_offset + trim_plan_dim/2 + x_pos_screw_long])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Screw hole position   
    translate([trim_plan_dim/2 +y_pos_screw_long, 0, arm_screw_fit_offset + trim_plan_dim/2 - x_pos_screw_long])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Sphere hole position  
    translate([trim_plan_dim/2 , 0, arm_screw_fit_offset + trim_plan_dim/2 ])
        sphere(r=4.25, $fn=100 );
        
      
    }//End of tilt rotation
    }//End translate of trim 
 



    //**************** Back arm **********//    
    //Draw trim plan
    translate([ motor_x_pos + arm_length_back -trim_plan_dim/2, y_offset + b_ellipse + motor_height , wing_root_mm+a_ellipse - trim_plan_dim/2 ]) {
            rotate([ arm_tilt_angle, 0, 0]) {
        
        cube([ trim_plan_dim, trim_plan_dim, trim_plan_dim ]);
    
    //Screw hole position           
    translate([trim_plan_dim/2 +y_pos_screw_short, 0, arm_screw_fit_offset + trim_plan_dim/2 + x_pos_screw_short])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Screw hole position   
    translate([trim_plan_dim/2 -y_pos_screw_short, 0, arm_screw_fit_offset + trim_plan_dim/2 - x_pos_screw_short])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Screw hole position   
    translate([trim_plan_dim/2 -y_pos_screw_long, 0, arm_screw_fit_offset + trim_plan_dim/2 + x_pos_screw_long])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Screw hole position   
    translate([trim_plan_dim/2 +y_pos_screw_long, 0, arm_screw_fit_offset + trim_plan_dim/2 - x_pos_screw_long])
        rotate([ 90, 0, 0]) {   
            linear_extrude(height = 100)
                circle(r = screw_hole_2, $fn=100);
            
         translate([0, 0, screw_hole_motor_arm_offset])   
            linear_extrude(height = 100)
                circle(r = screw_hole_1, $fn=100);
        }
        //Sphere hole position  
    translate([trim_plan_dim/2 , 0, arm_screw_fit_offset + trim_plan_dim/2 ])
        sphere(r=4.25, $fn=100 );
        
      
    }//End of tilt rotation
    }//End translate of trim 
    
    
    
    }//End of 2nd Union
 
 
    
    }//End of difference       
//
        if(dummy_motor){
    translate([ motor_x_pos + arm_length_back, y_offset + motor_height, wing_root_mm+a_ellipse])
        rotate([ 0, 90 - arm_tilt_angle, 90 ])
            union(){
            color("red")
                linear_extrude(height = dummy_motor_base_height)
                    circle(r = dummy_motor_base_radius, $fn=100);
            
             translate([ 0, 0, dummy_motor_base_height])    
                color("green")
                    linear_extrude(height = dummy_helix_height)
                        circle(r = dummy_helix_radius, $fn=100);   
            }

    translate([ motor_x_pos - arm_length_front, y_offset + motor_height, wing_root_mm+a_ellipse])
        rotate([ 0, 90 - arm_tilt_angle, 90 ])
            union(){
            color("red")
                linear_extrude(height = dummy_motor_base_height)
                    circle(r = dummy_motor_base_radius, $fn=100);
            
             translate([ 0, 0, dummy_motor_base_height])    
                color("green")
                    linear_extrude(height = dummy_helix_height)
                        circle(r = dummy_helix_radius, $fn=100);   
            }
            
            
        } // End dummy_motor


        
    } //End Union for whole arm
      
  
    //**************** Difference part to cut the arm in 2 pieces **********//
    if(front){
        union(){
            translate([ motor_x_pos , -arm_length_front, wing_root_mm - arm_length_front])
                cube([ 2*arm_length_front, 2*arm_length_front, 2*arm_length_front ]);
          
            //Echo lock attach remove piece on front arm
            translate([ motor_x_pos, -y_offset-b_ellipse, wing_root_mm+a_ellipse]){
                rotate([ -90, 90, 0 ]){           
                    color("blue")
                        linear_extrude(height=piece_height, scale = 1.2) 
                            polygon(points=[[-width/2,-lock_length_2_start/2], [width/2,-lock_length_2_start/2], [(width/2 + lock_length_2_height * tan(alpha)), lock_length_2_stop/2], [-width/2-lock_length_2_height * tan(alpha),lock_length_2_stop/2]]);  
                }// rotate
            }// End translate
        }//End union
    }// End if



    if(back){
        union(){
            translate([ motor_x_pos - 2*arm_length_back , -arm_length_back, wing_root_mm - arm_length_back])
                cube([ 2*arm_length_back, 2*arm_length_back, 2*arm_length_back ]);

            //Echo lock attach remove piece on front arm
            translate([ motor_x_pos, -y_offset-b_ellipse, wing_root_mm+a_ellipse]){
                rotate([ -90, 90, 0 ]){           
                    color("red")
                        linear_extrude(height=piece_height, scale = 0.8)         
                polygon(points=[[-width/2,-lock_length/2], [width/2,-lock_length/2], [(width/2 - lock_length * tan(alpha)), lock_length/2], [- width/2 +lock_length * tan(alpha),lock_length/2]]); //You center you piece on zero to apply a scale (tapering) in the center of the piece
                }// rotate
            }// End translate        
        }//End union
    }// End if    
    
}// Difference front / back / full
     
    //**************** Echo lock attach **********//  
    if(front){
        
        intersection(){  //Intersection to clean the edge of echo lock
        
            translate([ motor_x_pos - (1-offset_clearance), -y_offset-b_ellipse, wing_root_mm+a_ellipse]){
                rotate([ -90, 90, 0 ]){  
              color("red")
                linear_extrude(height=piece_height, scale = 0.8)         
                    polygon(points=[[-width_w_clearance/2,-lock_length/2], [width_w_clearance/2,-lock_length/2], [(width_w_clearance/2 - lock_length * tan(alpha)), lock_length/2], [- width_w_clearance/2 +lock_length * tan(alpha),lock_length/2]]); //You center you piece on zero to apply a scale (tapering) in the center of the piece
                }    
            }//End translate
                   
            translate([ motor_x_pos + arm_length_front, y_offset, wing_root_mm+a_ellipse])
                rotate([ 0, -90, 0 ])           
                    linear_extrude(height = 2*arm_length_front)
                        scale([1, b_ellipse/a_ellipse])
                            circle(r = a_ellipse, $fn=100); 
            
        }//End Intersection
    }// End if       

    if(back){
        
        
        intersection(){  //Intersection to clean the edge of echo lock
            
            difference(){          
                translate([ motor_x_pos - (1-offset_clearance), -y_offset-b_ellipse, wing_root_mm+a_ellipse]){
                    rotate([ -90, 90, 0 ]){      
                        color("blue")
                            linear_extrude(height=piece_height, scale = 1.2) 
                                polygon(points=[[-width_w_clearance/2,-lock_length_2_start/2], [width_w_clearance/2,-lock_length_2_start/2], [(width_w_clearance/2 + lock_length_2_height * tan(alpha)), lock_length_2_stop/2], [-width_w_clearance/2-lock_length_2_height * tan(alpha),lock_length_2_stop/2]]);
                    }    
                }
                
                translate([ motor_x_pos, -y_offset-b_ellipse, wing_root_mm+a_ellipse]){
                rotate([ -90, 90, 0 ]){      
              color("red")
                linear_extrude(height=piece_height, scale = 0.8)         
                    polygon(points=[[-width/2,-lock_length/2], [width/2,-lock_length/2], [(width/2 - lock_length * tan(alpha)), lock_length/2], [- width/2 +lock_length * tan(alpha),lock_length/2]]); //You center you piece on zero to apply a scale (tapering) in the center of the piece
                }    
            }
            }//End difference
              
            
            translate([ motor_x_pos + arm_length_back, y_offset, wing_root_mm+a_ellipse])
                rotate([ 0, -90, 0 ])           
                    linear_extrude(height = 2*arm_length_back)
                        scale([1, b_ellipse/a_ellipse])
                            circle(r = a_ellipse, $fn=100); 
            
        }//End Intersection        
        
        
    }// End if               
          


}

/*
//Module to draw the attach between motor arm and wing
module motor_arm_to_wing_attach(aero_grav_center){

    circle_radius = 4;
    attach_height = 2;
    attach_y = 6.3;
    attach_x = 2;
    x_pos = aero_grav_center[1] + motor_arm_grav_center_offset+15;
    z_pos = wing_root_mm +motor_arm_width+motor_arm_to_wing_hull;
    y_offset = -3;//-2.8;
    

        translate([x_pos,y_offset,z_pos]) 
            rotate([90,0,0]){
            translate([-attach_x/2,0,0]) cube([attach_x,attach_y,attach_height]);
            translate([0,attach_y,0]) linear_extrude(height=attach_height) circle(r=circle_radius);
            }

}

//Module to void the attach between motor arm and wing
module motor_arm_to_wing_attach_void(aero_grav_center){

    scale_up = 1.2;// We use this parameter to get space for the parts to imbricate
    circle_radius = 4*scale_up;
    attach_height = 4;
    attach_y = 7;
    attach_x = 2*scale_up;
    x_pos = aero_grav_center[1] + motor_arm_grav_center_offset+15;
    z_pos = wing_root_mm +motor_arm_width+motor_arm_to_wing_hull;
    y_offset = -3;//-2.8;

    

        translate([x_pos,y_offset,z_pos]) 
            rotate([90,0,0]){
            translate([-attach_x/2,0,0]) cube([attach_x,attach_y,attach_height]);
            translate([0,attach_y,0]) linear_extrude(height=attach_height) circle(r=circle_radius);
            }

}
*/

//Module to draw the attach between motor arm and wing
module motor_arm_to_wing_attach(aero_grav_center){

    attach_height = 5;
    attach_y = 3;
    attach_x = 1.2;
    crochet_scale = 1.5;
    x_pos = aero_grav_center[1] + motor_arm_grav_center_offset+15;
    z_pos = wing_root_mm +motor_arm_width+motor_arm_to_wing_hull;
    y_offset = -5;//-2.8;
    

        translate([x_pos,y_offset,z_pos]) {
            
            rotate([-90,0,90]){
                translate([0,-2*attach_y+1,0]) linear_extrude(height=attach_height) polygon(points=[[0,0], [0,attach_y], [crochet_scale*attach_x,attach_y]]);
                translate([0,-attach_y+1,0]) cube([attach_x,attach_y,attach_height]);
            }
        }

} 

//Module to void the attach between motor arm and wing
module motor_arm_to_wing_attach_void(aero_grav_center){

    scale_up = 1.1;// We use this parameter to get space for the parts to imbricate
    height = 5;
    attach_height = height*scale_up;
    attach_y = 3;
    attach_x = 1.2*scale_up;
    crochet_scale = 1.5;
    x_pos = aero_grav_center[1] + motor_arm_grav_center_offset+15;
    z_pos = wing_root_mm +motor_arm_width+motor_arm_to_wing_hull;
    y_offset = -5;//-2.8;

    
        //(attach_height - height)/2 => correction on x axis of the scale to stay at the same place
        translate([x_pos+(attach_height - height)/2,y_offset,z_pos]) {
            
            rotate([-90,0,90]){
                translate([0,-2*attach_y+1,0]) linear_extrude(height=attach_height) polygon(points=[[0,0], [0,attach_y], [crochet_scale*attach_x,attach_y]]);
                translate([0,-attach_y+1,0]) cube([attach_x,attach_y,attach_height]);
                translate([-2*attach_x,-2*attach_y+1,0]) cube([2*attach_x,2*attach_y,attach_height]);
            }
        }

}
