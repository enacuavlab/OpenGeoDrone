    function interpolate_pt(p1, p2, target_z) =
        let (
            dz = p2[2] - p1[2],
            t = (target_z - p1[2]) / dz
        )
        [
            p1[0] + t * (p2[0] - p1[0]),
            p1[1] + t * (p2[1] - p1[1]),
            target_z
        ];

    function find_interpolated_point(target_z, pts) =
        let (
            pairs = [for (i = [0 : len(pts) - 2]) [pts[i], pts[i+1]]],
            valid = [
                for (pair = pairs)
                    if (
                        (pair[0][2] <= target_z && target_z <= pair[1][2]) ||
                        (pair[1][2] <= target_z && target_z <= pair[0][2])
                    ) pair
            ]
        )
        (len(valid) > 0) ? interpolate_pt(valid[0][0], valid[0][1], target_z) : undef;






module Servo3_7g()
{
    difference()
    {
        union()
        {
            color("red") cube([ 21, 9, 20 ]);
            translate([ -6, 0, 13 ]) color("red") cube([ 33, 9, 2 ]);
            translate([ 10, 0, 20 ]) color("red") cube([ 11, 9, 6 ]);
            translate([ 0, 9, 0 ]) color("green") cube([ 21, 5, 20 ]);
            translate([ -6, 9, 13 ]) color("green") cube([ 33, 5, 2 ]);
            translate([ 10, 9, 20 ]) color("green") cube([ 11, 5, 6 ]);
        }
        union()
        {
            translate([ -1, 0, 8 ]) cube([ 1, 12, 10 ]);
            translate([ 9, 0, 19 ]) cube([ 1, 12, 10 ]);
            translate([ 21, 0, 8 ]) cube([ 1, 12, 10 ]);
        }
    }
    difference()
    {
        union()
        {
            color("gray") translate([ 0, 0, -10 ]) cube([ slice_gap_width, 14, 10 ]);
            color("gray") translate([ 10.5-slice_gap_width, 0, -10 ]) cube([ slice_gap_width, 14, 10 ]);
            color("gray") translate([ 21-slice_gap_width, 0, -10 ]) cube([ slice_gap_width, 14, 10 ]);
        }
        rotate([ -35, 0, 0 ]) color("blue") translate([ -1, 0, -10 ]) cube([ 24, 50, 10 ]);
    }

    difference()
    {
        union()
        {
            color("gray") translate([ -6, 0, 3 ]) cube([ slice_gap_width, 14, 10 ]);
            color("gray") translate([ 27 - slice_gap_width, 0, 3 ]) cube([ slice_gap_width, 14, 10 ]);
        }
        rotate([ -35, 0, 0 ]) color("blue") translate([ -10, -8, 0 ]) cube([ 50, 50, 10 ]);
    }
}
module Servo3_7gVoid()
{
    translate([ -0.6, -0.6, -0.6 ]) union()
    {
        color("blue") translate([ 0, 0, -10 ]) cube([ 22.2, 9, 31 ]);
        translate([ -6, 0, 3 ]) color("blue") cube([ 34.2, 9, 13 ]);
        translate([ 10, 0, 20 ]) color("blue") cube([ 12.2, 9, 7.2 ]);

        translate([ 0, 9, -10 ]) color("blue") cube([ 22.2, 30, 31 ]);
        translate([ -6, 9, 3 ]) color("blue") cube([ 34.2, 30, 13 ]);
        translate([ 10, 9, 20 ]) color("blue") cube([ 12.2, 30, 7.2 ]);
    }
}

module Servo5g()
{
    difference()
    {
        union()
        {
            color("red") cube([ 24, 12, 21 ]);                           // Main body [width, depth, height]
            translate([ -5, 0, 14 ]) color("red") cube([ 34, 12, 3 ]);   // Mounting ears
            translate([ 10, 0, 20 ]) color("red") cube([ 14, 12, 7 ]);   // Gearbox
            translate([ 0, 12, 0 ]) color("green") cube([ 24, 5, 21 ]);  // Extra Main body [width, depth, height]
            translate([ -5, 12, 14 ]) color("green") cube([ 34, 5, 3 ]); // Extra mounting ears
            translate([ 10, 12, 20 ]) color("green") cube([ 14, 5, 7 ]); // Extra gearbox
        }
        union()
        {
            translate([ -1, 0, 8 ]) cube([ 1, 15, 12 ]);
            translate([ 9, 0, 20 ]) cube([ 1, 15, 12 ]);
            translate([ 24, 0, 8 ]) cube([ 1, 15, 12 ]);
        }
    }
    difference()
    {
        union()
        {
            color("gray") translate([ 0, 0, -12 ]) cube([ slice_gap_width, 17, 12 ]);
            color("gray") translate([ 11.5 - slice_gap_width, 0, -12 ]) cube([ slice_gap_width, 17, 12 ]);
            color("gray") translate([ 24 - slice_gap_width, 0, -12 ]) cube([ slice_gap_width, 17, 12 ]);
        }
        rotate([ -35, 0, 0 ]) color("blue") translate([ -1, 0, -10 ]) cube([ 30, 50, 10 ]);
    }

    difference()
    {
        union()
        {
            color("gray") translate([ -5, 0, 0 ]) cube([ slice_gap_width, 17, 14 ]);
            color("gray") translate([ 29 - slice_gap_width, 0, 0 ]) cube([ slice_gap_width, 17, 14 ]);
        }
        rotate([ -35, 0, 0 ]) color("blue") translate([ -10, -8, 0 ]) cube([ 50, 50, 10 ]);
    }
}
module Servo5gVoid()
{
    translate([ -0.6, -0.6, -0.6 ]) union()
    {
        color("blue") translate([ 0, 0, -10 ]) cube([ 25.2, 9, 33 ]);
        translate([ -6, 0, 3 ]) color("blue") cube([ 37.2, 9, 15 ]);
        translate([ 10, 0, 20 ]) color("blue") cube([ 15.2, 9, 8.2 ]);

        translate([ 0, 9, -10 ]) color("blue") cube([ 25.2, 30, 33 ]);
        translate([ -6, 9, 3 ]) color("blue") cube([ 37.2, 30, 15 ]);
        translate([ 10, 9, 20 ]) color("blue") cube([ 15.2, 30, 8.2 ]);
    }
}

module Servo9g()
{
    difference()
    {
        union()
        {
            color("red") cube([ 25, 12, 25 ]);                             // Main body [width, depth, height]
            translate([ -5.5, 0, 16 ]) color("red") cube([ 36, 12, 4 ]);   // Mounting ears
            translate([ 10, 0, 24 ]) color("red") cube([ 15, 12, 8 ]);     // Gearbox
            translate([ 0, 12, 0 ]) color("green") cube([ 25, 5, 25 ]);    // Extra Main body [width, depth, height]
            translate([ -5.5, 12, 16 ]) color("green") cube([ 36, 5, 4 ]); // Extra mounting ears
            translate([ 10, 12, 24 ]) color("green") cube([ 15, 5, 8 ]);   // Extra gearbox
        }
        union()
        {
            translate([ -1, 0, 8 ]) cube([ 1, 15, 12 ]);
            translate([ 9, 0, 23 ]) cube([ 1, 15, 12 ]);
            translate([ 25, 0, 8 ]) cube([ 1, 15, 12 ]);
        }
    }
    difference()
    {
        union()
        {
            color("gray") translate([ 0, 0, -12 ]) cube([ slice_gap_width, 17, 12 ]);
            color("gray") translate([ 12.5 - slice_gap_width, 0, -12 ]) cube([ slice_gap_width, 17, 12 ]);
            color("gray") translate([ 25 - slice_gap_width, 0, -12 ]) cube([ slice_gap_width, 17, 12 ]);
        }
        rotate([ -35, 0, 0 ]) color("blue") translate([ -1, 0, -10 ]) cube([ 30, 50, 10 ]);
    }

    difference()
    {
        union()
        {
            color("gray") translate([ -5.5, 0, 2 ]) cube([ slice_gap_width, 17, 14 ]);
            color("gray") translate([ 30.5 - slice_gap_width, 0, 2 ]) cube([ slice_gap_width, 17, 14 ]);
        }
        rotate([ -35, 0, 0 ]) color("blue") translate([ -10, -8, 0 ]) cube([ 50, 50, 10 ]);
    }
}
module Servo9gVoid()
{
    translate([ -0.6, -0.6, -0.6 ]) union()
    {
        color("blue") translate([ 0, 0, -10 ]) cube([ 26.7, 9, 36 ]);
        translate([ -6, 0, 6 ]) color("blue") cube([ 38.2, 9, 15 ]);
        translate([ 10.5, 0, 24 ]) color("blue") cube([ 16.2, 9, 9.2 ]);

        translate([ 0, 9, -10 ]) color("blue") cube([ 26.7, 30, 36 ]);
        translate([ -6, 9, 6 ]) color("blue") cube([ 38.2, 30, 15 ]);
        translate([ 10.5, 9, 24 ]) color("blue") cube([ 16.2, 30, 9.2 ]);
    }
}

// Use for display only
module Servo4 () 
{   
    all_pts = get_trailing_edge_points();
    
    pt_start = find_interpolated_point(aileron_start_z, all_pts);
    pt_end   = find_interpolated_point(aileron_end_z, all_pts);
    inner_pts = [for (pt = all_pts) if (pt[2] > aileron_start_z && pt[2] < aileron_end_z) pt];
    full_pts = concat(
        pt_start != undef ? [pt_start] : [],
        inner_pts,
        pt_end != undef ? [pt_end] : []
    );
    
    // Get the sweep angle between extrem point of ailerons
    sweep_ang = atan((full_pts[len(full_pts) - 1][0] - full_pts[0][0])/(full_pts[len(full_pts) - 1][2] -full_pts[0][2])); 
    
    rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep
        union(){
        cube([ servo_dimension_perso[0],servo_dimension_perso[1],servo_dimension_perso[2]]);
        
        }
        

    //Add cylinder to represent the rotation axis
    translate([servo_dimension_perso[0]*tan(sweep_ang)+1, servo_dimension_perso[1]/2, servo_dimension_perso[2]*cos(sweep_ang)])
        rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep
            translate([5,0,0])
                cylinder(h=1,r=2); 
                    
}

// Use for remove the servo space from motor arm
module Servo4Void () 
{
    all_pts = get_trailing_edge_points();
    
    pt_start = find_interpolated_point(aileron_start_z, all_pts);
    pt_end   = find_interpolated_point(aileron_end_z, all_pts);
    inner_pts = [for (pt = all_pts) if (pt[2] > aileron_start_z && pt[2] < aileron_end_z) pt];
    full_pts = concat(
        pt_start != undef ? [pt_start] : [],
        inner_pts,
        pt_end != undef ? [pt_end] : []
    );
    
    // Get the sweep angle between extrem point of ailerons
    sweep_ang = atan((full_pts[len(full_pts) - 1][0] - full_pts[0][0])/(full_pts[len(full_pts) - 1][2] -full_pts[0][2])); 
    
    rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep
        cube([ servo_dimension_perso_void[0],servo_dimension_perso_void[1],servo_dimension_perso_void[2]]);
    
}

module ServoHorn()
{
    scale_factor = 1.2;   
    difference(){
    
        //Draw the connection to servo horn
        servo_horn_connection();
        
        //Withdraw the wing to the horn to grab the wing
        intersection(){
            scale([1,scale_factor,1]) wing_shell();
            cube_cut(wing_root_mm + motor_arm_width+motor_arm_to_wing_hull, wing_mid_mm-motor_arm_to_wing_hull);
        }
    }        
     
}

 
 
//void == true -> use for removing motor part which block the horn servo movement
module servo_horn_connection (void = false) 
{

    void_x_offset = -12;
    void_y_offset = -8;
    void_z_offset = -9.5;
    horn_pos_x_offset = 10;
    horn_pos_z_offset = 1.5;
    horn_dim_z = 1; //Part connected to servo
    horn_attach_dim_z = 16; //Part connected to wing
    cmd_dim_x = 31.5;
    cmd_dim_y = 9;
    screw_face_length_offset = 4; //Offset to reduce the length x on the screw face
    screw_diameter = 1;

    all_pts = get_trailing_edge_points();
    
    pt_start = find_interpolated_point(aileron_start_z, all_pts);
    pt_end   = find_interpolated_point(aileron_end_z, all_pts);
    inner_pts = [for (pt = all_pts) if (pt[2] > aileron_start_z && pt[2] < aileron_end_z) pt];
    full_pts = concat(
        pt_start != undef ? [pt_start] : [],
        inner_pts,
        pt_end != undef ? [pt_end] : []
    );
    
    // Get the sweep angle between extrem point of ailerons
    sweep_ang = atan((full_pts[len(full_pts) - 1][0] - full_pts[0][0])/(full_pts[len(full_pts) - 1][2] -full_pts[0][2])); 

    if(void) {
    
                     rotate([0, 0, servo_rotate_z_deg])
            translate([void_x_offset,void_y_offset,void_z_offset])         
            translate([servo_dist_le_mm + servo_dimension_perso[0]*cos(sweep_ang)+2, servo_dist_depth_mm, servo_dist_root_mm + servo_dimension_perso[2]*cos(sweep_ang)-1])
                cube([ cmd_dim_x*1.5,cmd_dim_y*3,horn_attach_dim_z]);    
    
    }
    
    else {
    
    difference(){ // We remove from the part two cylinder to fix with screws
    union(){
    
    hull(){ //We hull 2 cube to get the horn
    
    //Part on which there is the screws
        rotate([0, 0, servo_rotate_z_deg])
            translate([servo_dist_le_mm + servo_dimension_perso[0]*tan(sweep_ang)+1, servo_dist_depth_mm, servo_dist_root_mm + servo_dimension_perso[2]*cos(sweep_ang)])
                rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep
                    translate([horn_pos_x_offset,0,horn_pos_z_offset])
                        cube([ servo_dimension_perso[0]-horn_pos_x_offset -screw_face_length_offset,servo_dimension_perso[1],horn_dim_z]);
    
        rotate([0, 0, servo_rotate_z_deg])
            translate([servo_dist_le_mm + servo_dimension_perso[0]*cos(sweep_ang)+2, servo_dist_depth_mm, servo_dist_root_mm + servo_dimension_perso[2]*cos(sweep_ang)-1])
                cube([ cmd_dim_x,cmd_dim_y,0.1]);
                     
    }//End of hull

        rotate([0, 0, servo_rotate_z_deg])
            translate([servo_dist_le_mm + servo_dimension_perso[0]*cos(sweep_ang)+2, servo_dist_depth_mm, servo_dist_root_mm + servo_dimension_perso[2]*cos(sweep_ang)-1])
                cube([ cmd_dim_x,cmd_dim_y,horn_attach_dim_z]); 
    } // End of union
    
    rotate([0, 0, servo_rotate_z_deg])
    translate([servo_dist_le_mm+servo_dimension_perso[0]*tan(sweep_ang)+1, servo_dist_depth_mm+servo_dimension_perso[1]/2, servo_dist_root_mm+servo_dimension_perso[2]*cos(sweep_ang)])
        rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep
            {
            translate([12.5,0,0])
                cylinder(h=8,r=screw_diameter);
                
            translate([17.5,0,0])
                cylinder(h=8,r=screw_diameter);                
                
            }
            
      }//End of difference
    }//End of else
     
    
}
