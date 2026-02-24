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