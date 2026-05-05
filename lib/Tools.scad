        //**************** Function **********//
        //Surface sum
        function do_sum(lst, acc = 0, i = 0) =
        i >= len(lst) ? acc : do_sum(lst, acc + lst[i][0], i + 1);
    
        //Surface x Length sum
        function do_double_sum(lst, acc = 0, i = 0) =
        i >= len(lst) ? acc : do_double_sum(lst, acc + lst[i][1] *lst[i][0], i + 1);
    
        function get_section_centers(pts_le, pts_te) = 
        [ for (i = [0 : len(pts_le) - 2]) 
         let (
        midpoint_1 = midpoint(pts_le[i+1], pts_le[i]),
        midpoint_2 = midpoint(pts_te[i+1], pts_te[i]),
        center = midpoint(midpoint_1,midpoint_2)
        )
        midpoint(midpoint_1,center)
        ];

        function vector_subtract(a, b) = [a[0] - b[0], a[1] - b[1], a[2] - b[2]];    
    
        function trapezoid_area(le1, te1, le2, te2) =
        let (
        c1 = norm(vector_subtract(le1, te1)),
        c2 = norm(vector_subtract(le2, te2)),
        dz = le2[2] - le1[2]
        )      
        0.5 * (c1 + c2) * abs(dz);

        function midpoint(p1, p2) = [(p1[0] + p2[0]) / 2, (p1[1] + p2[1]) / 2, (p1[2] + p2[2]) / 2];

        function distance_le_to_midpoint(le2, le1,le_root) = 
        let (mid = midpoint(le2, le1))
        //norm(mid - le);  //if you want other axis
        abs(mid[0] - le_root[0]);

        function wing_section_data(pts_le, pts_te) = 
         [ for (i = [0 : len(pts_le) - 2])
        let (
            le1 = pts_le[i],
            le2 = pts_le[i + 1],
            te1 = pts_te[i],
            te2 = pts_te[i + 1],
            area = trapezoid_area(le1, te1, le2, te2),
            midpoint_1 = midpoint(pts_le[i+1], pts_le[i]),
            midpoint_2 = midpoint(pts_te[i+1], pts_te[i]),
            center = midpoint(midpoint_1,midpoint_2),
            local_AC = midpoint(midpoint_1,center),
            dist_le_to_ca = abs(local_AC[0] - pts_le[0][0]) 
        )
        [area, dist_le_to_ca]
        ];
         
        function get_gravity_aero_center(AC_CG_marg) = 
            let (
            pts_te = get_trailing_edge_points(),  
            pts_le = get_leading_edge_points(),       
            //Get all the wing sections 
            sections = wing_section_data(pts_le, pts_te),
            //Get AC uisng surface as weight
            aero_ct =  do_double_sum(sections)/do_sum(sections),
            //Get CG uisng AC_CG_marg
            gvy_ct =  aero_ct - (aero_ct * AC_CG_marg /100)
            )
        [aero_ct, gvy_ct, sections];



module aerodynamic_gravity_center(wingspan, AC_CG_marg,  display_surface = false, display_point = false, aero_center_plot = false, grav_center_plot = false) {
    
             
        //**************** Module **********// 

        //**************** Display **********// 
        pts_te = get_trailing_edge_points();  
        pts_le = get_leading_edge_points();  
        aero_grav_center = get_gravity_aero_center(AC_CG_marg);
        if(grav_center_plot){
            echo("Aerodynamic Center = ", aero_grav_center[0]);
            echo("Gravity Center = ", aero_grav_center[1]);
        }
        sections = aero_grav_center[2];
        // Display results
        // Print the total wing surface for 2 wings
        print_surface = 2*do_sum(sections);
        echo("Total Wing surface = ", print_surface/1000000, " m2");
        
        if(grav_center_plot){
        for (i = [0 : len(sections) - 1])
            echo("Section", i, ": Area =", sections[i][0], "Dist LE -> center =", sections[i][1]);
        }
        // Draw polyhedron of each section
        for (i = [0 : len(pts_le) - 2]) {
        p1 = pts_le[i];// Add debug leading edge

        p2 = pts_le[i+1];
        p3 = pts_te[i+1];
        p4 = pts_te[i];
        if(display_surface) 
            {
            color("white")
            polyhedron(
                points = [p1, p2, p3, p4],
                faces = [[0, 1, 2, 3]]
            );
            }
            
        // Draw Local AC of each section 
        if(display_point) 
        {
        centers = get_section_centers(pts_le, pts_te);    
        for (p = centers)
            translate(p) color("orange") sphere(r = 1.5);  
        }
    }

        // Draw AC reference
        if(aero_center_plot){
            color("black") 
            translate([ aero_grav_center[0], -50, 0 ])
            cube([ 1, 100, wingspan ]);
        }
    
        // Draw CG reference
        if(grav_center_plot){
            color("green") 
            translate([ aero_grav_center[1], -50, 0 ])
            cube([ 1, 100, wingspan ]);
        }
}


module rotate_around_point(point, angles) {
    translate(-point)
        rotate(angles)
            translate(point)
                children();
}

//Module use to create a projection of the whole system in order to get the footprint of the drones
module silouhette_projection_main(aero_grav_center) {
rear_motor_square_support_attach_length_z = 34;    
Display_pitot(pitot_radius, 60);  

//Back motor place
back_motor_place = 80;
translate([center_length -main_stage_x_offset,main_stage_y_width-center_height/2  ,-center_width/2])
    rotate([90,0,0])
    linear_extrude(rear_motor_square_support_attach_width)
    square([back_motor_place, rear_motor_square_support_attach_length_z], center=true);  
    
//Back propeller place
back_prop_place = 40;
back_prop_width = 116;
translate([center_length -main_stage_x_offset + back_motor_place/2,main_stage_y_width-center_height/2  ,-center_width/2])
    rotate([90,0,0])
    linear_extrude(rear_motor_square_support_attach_width)
    square([back_prop_place, 2*back_prop_width], center=true);  
    
    
//Propellers    
dxf_motor_base_radius = 15;
dxf_motor_base_height = 20; 
dxf_hoov_prop_width = 20;
dxf_hoov_prop_length = 92;
motor_arm_x_pos = aero_grav_center[1] + motor_arm_grav_center_offset;
//BL
translate([ motor_arm_x_pos + motor_arm_length_back, motor_arm_y_offset + motor_arm_height, wing_root_mm+ellipse_maj_ax]) {
    rotate([ 0, 90 - motor_arm_tilt_angle, 90 ])
            color("red")
                linear_extrude(height = dxf_motor_base_height)
                    circle(r = dxf_motor_base_radius, $fn=100);
    rotate([90,0,0])
    linear_extrude(height = dxf_motor_base_height)
    square([dxf_hoov_prop_width, 2*dxf_hoov_prop_length], center=true);                      
      
} 

//FL
translate([ motor_arm_x_pos - motor_arm_length_front, motor_arm_y_offset + motor_arm_height, wing_root_mm+ellipse_maj_ax]) {
    rotate([ 0, 90 - motor_arm_tilt_angle, 90 ])
            color("red")
                linear_extrude(height = dxf_motor_base_height)
                    circle(r = dxf_motor_base_radius, $fn=100);
    rotate([90,0,0])
    linear_extrude(height = dxf_motor_base_height)
    square([dxf_hoov_prop_width, 2*dxf_hoov_prop_length], center=true);                      
      
} 

//FR
mirror([0, 0, 1]) 
    translate([0, 0, center_width]) 
        translate([ motor_arm_x_pos - motor_arm_length_front, motor_arm_y_offset + motor_arm_height, wing_root_mm+ellipse_maj_ax]) {
            rotate([ 0, 90 - motor_arm_tilt_angle, 90 ])
                    color("red")
                        linear_extrude(height = dxf_motor_base_height)
                            circle(r = dxf_motor_base_radius, $fn=100);
            rotate([90,0,0])
            linear_extrude(height = dxf_motor_base_height)
            square([dxf_hoov_prop_width, 2*dxf_hoov_prop_length], center=true); 
        } 

     
//BR
mirror([0, 0, 1]) 
    translate([0, 0, center_width]) 
        translate([ motor_arm_x_pos + motor_arm_length_back, motor_arm_y_offset + motor_arm_height, wing_root_mm+ellipse_maj_ax])  {
            rotate([ 0, 90 - motor_arm_tilt_angle, 90 ])
                    color("red")
                        linear_extrude(height = dxf_motor_base_height)
                            circle(r = dxf_motor_base_radius, $fn=100);
            rotate([90,0,0])
            linear_extrude(height = dxf_motor_base_height)
            square([dxf_hoov_prop_width, 2*dxf_hoov_prop_length], center=true); 
        } 
   
//Servo left
    translate([servo_dist_le_mm+5, servo_dist_depth_mm, servo_dist_root_mm])
        cube([50,30,40]);
    
//Servo right
mirror([0, 0, 1]) 
    translate([0, 0, center_width]) 
        translate([servo_dist_le_mm+5, servo_dist_depth_mm, servo_dist_root_mm])
            cube([50,30,40]);    

            
}