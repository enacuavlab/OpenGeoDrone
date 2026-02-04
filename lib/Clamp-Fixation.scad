//  ***  Module for Clamp fixation between part *** //
 
module clamp_fixation(wing_root_chord, wing_root, motor_arm_wdth, motor_arm_to_wg_hull)
{
    attach_z_top = 20;
    attach_y_top = 2;
    attach_x_top = 10;
    
    attach_z_bot = 2;
    attach_y_bot = 13;
    attach_x_bot = 10;
    
    // **** Motor Arm to Mid attach **** //
    x1_offset_perc = clamp_arm_mid_perc;
    
    x1_offset = x1_offset_perc / 100 * wing_root_chord;
    y1_offset = clamp_arm_mid_y_offset;
    z1_offset = wing_root + motor_arm_wdth+motor_arm_to_wg_hull - attach_z_top/2;
    
    // **** Motor Arm to Mid attach **** //
    translate([x1_offset,y1_offset,z1_offset]) {
        cube([attach_x_top,attach_y_top,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }
 /*   
    // **** Motor Arm to root attach **** //
    x2_offset_perc = clamp_arm_root_perc;
    
    x2_offset = x2_offset_perc / 100 * wing_root_chord;
    y2_offset = clamp_arm_root_y_offset;
    z2_offset = wing_root - motor_arm_to_wg_hull - attach_z_top/2;
    
    // **** Motor Arm to root attach **** //
    translate([x2_offset,y2_offset,z2_offset]) {
        cube([attach_x_top,attach_y_top,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }
    
    
    
    // **** Root to center part attach **** //
    x3_offset_perc = clamp_root_center_perc;
    
    x3_offset = x3_offset_perc / 100 * wing_root_chord;
    y3_offset = clamp_root_center_y_offset;
    z3_offset = - attach_z_top/2;
    
    // **** Motor Arm to root attach **** //
    translate([x3_offset,y3_offset,z3_offset]) {
        cube([attach_x_top,attach_y_top,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }
  */  
}

module clamp_fixation_removal(wing_root_chord, wing_root, motor_arm_wdth, motor_arm_to_wg_hull)
{
    
    scale_up =1.1;
    
    
    
    attach_z_top = 20;
    attach_y_top = 10;
    attach_x_top = 10;
    
    attach_z_bot = 2;
    attach_y_bot = 13;
    attach_x_bot = 10;
    
    // **** Motor Arm to Mid attach **** //
    x1_offset_perc = clamp_arm_mid_perc;
    
    x1_offset = x1_offset_perc / 100 * wing_root_chord - (attach_x_top*(scale_up-1)/2); // The last correction in the equation is to center after scale up
    y1_offset = clamp_arm_mid_y_offset;
    z1_offset = (wing_root + motor_arm_wdth+motor_arm_to_wg_hull - attach_z_top/2);
    
    // **** Motor Arm to Mid attach **** //
    translate([x1_offset,y1_offset,z1_offset]) {
        //scale(scale_up)
        cube([attach_x_top*scale_up,attach_y_top*scale_up,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }//End of transalte
    
    
    // **** Motor Arm to Mid attach **** //
    x2_offset_perc = clamp_arm_root_perc;
    
    x2_offset = x2_offset_perc / 100 * wing_root_chord - (attach_x_top*(scale_up-1)/2); // The last correction in the equation is to center after scale up
    y2_offset = clamp_arm_root_y_offset;
    z2_offset = (wing_root - motor_arm_to_wg_hull - attach_z_top/2);
    
    // **** Motor Arm to Mid attach **** //
    translate([x2_offset,y2_offset,z2_offset]) {
        //scale(scale_up)
        cube([attach_x_top*scale_up,attach_y_top*scale_up,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }//End of transalte
    
    
    // **** Root to center part attach **** //
    x3_offset_perc = clamp_root_center_perc;
    
    x3_offset = x3_offset_perc / 100 * wing_root_chord - (attach_x_top*(scale_up-1)/2); // The last correction in the equation is to center after scale up
    y3_offset = clamp_root_center_y_offset;
    z3_offset = - attach_z_top/2;
    
    // **** Motor Arm to Mid attach **** //
    translate([x3_offset,y3_offset,z3_offset]) {
        //scale(scale_up)
        cube([attach_x_top*scale_up,attach_y_top*scale_up,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }//End of transalte    
}

module clamp_fixation_void(wing_root_chord, wing_root, motor_arm_wdth, motor_arm_to_wg_hull)
{

    scale_up =1.3;
    y_bottom_scale = 1.1; //Parameter to increase depth of void to avoid collision with inside structure
    
    
    attach_z_top = 20;
    attach_y_top = 10;
    attach_x_top = 10;
    
    attach_z_bot = 2;
    attach_y_bot = 13*y_bottom_scale;
    attach_x_bot = 10;
    
    // **** Motor Arm to Mid attach **** //
    x1_offset_perc = clamp_arm_mid_perc;
    
    x1_offset = x1_offset_perc / 100 * wing_root_chord - (attach_x_top*(scale_up-1)/2); // The last correction in the equation is to center after scale up
    y1_offset = clamp_arm_mid_y_offset- (attach_y_bot*(scale_up-1)/2);
    z1_offset = (wing_root + motor_arm_wdth+motor_arm_to_wg_hull - attach_z_top/2) - (attach_z_bot*(scale_up-1)/2);
    
    // **** Motor Arm to Mid attach **** //
    translate([x1_offset,y1_offset,z1_offset]) {
        //scale(scale_up)
        cube([attach_x_top*scale_up,attach_y_top*scale_up,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }//End of transalte
    
    
    
    // **** Motor Arm to Mid attach **** //
    x2_offset_perc = clamp_arm_root_perc;
    
    x2_offset = x2_offset_perc / 100 * wing_root_chord - (attach_x_top*(scale_up-1)/2); // The last correction in the equation is to center after scale up
    y2_offset = clamp_arm_root_y_offset;
    z2_offset = (wing_root - motor_arm_to_wg_hull - attach_z_top/2);
    
    // **** Motor Arm to Mid attach **** //
    translate([x2_offset,y2_offset,z2_offset]) {
        //scale(scale_up)
        cube([attach_x_top*scale_up,attach_y_top*scale_up,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }//End of transalte    

    
    // **** Root to center part attach **** //
    x3_offset_perc = clamp_root_center_perc;
    
    x3_offset = x3_offset_perc / 100 * wing_root_chord - (attach_x_top*(scale_up-1)/2); // The last correction in the equation is to center after scale up
    y3_offset = clamp_root_center_y_offset;
    z3_offset = - attach_z_top/2;
    
    // **** Motor Arm to Mid attach **** //
    translate([x3_offset,y3_offset,z3_offset]) {
        //scale(scale_up)
        cube([attach_x_top*scale_up,attach_y_top*scale_up,attach_z_top]); // top part
        translate([0,-attach_y_bot,0])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part
        translate([0,-attach_y_bot,attach_z_top-attach_z_bot])
            scale(scale_up)
            cube([attach_x_bot,attach_y_bot,attach_z_bot]); // Bot left part    
    }//End of transalte 
    
}