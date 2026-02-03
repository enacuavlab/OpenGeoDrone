///*** Create Winglet like a Wing ***///

///*** Main ***///
module CreateWinglet(wglet_y_pos) {

    y_cube_winglet = 10; //Y dimension of the winglet taking in account for the hull
    x_offset = 5; // Offset on winglet cut for hull
    x_offset_winglet = 7; //Offset on winglet position to the wing
    
    all_pts_le = get_leading_edge_points();
    all_pts_te = get_trailing_edge_points();
    z_pos = wing_root_mm +motor_arm_width + wing_mid_mm;
    
    pt_le_top = find_interpolated_point(z_pos, all_pts_le);
    pt_le__bot = find_interpolated_point(z_pos -winglet_to_wing_hull, all_pts_le);
    
    pt_te_top = find_interpolated_point(z_pos, all_pts_te);
    pt_te_bot = find_interpolated_point(z_pos -winglet_to_wing_hull, all_pts_te);

    //Create winglet and attach
    translate([pt_le_top[0]-x_offset_winglet,wglet_y_pos,z_pos])
        rotate([-90,0,0])
            winglet_design();
    Create_winglet_connection();            
    winglet_to_wing_attach();  

    hull(){//connect winglet to wing
            
        intersection(){//We keep the winglet in connection with wings only
        
            translate([pt_le_top[0]-x_offset_winglet,wglet_y_pos,z_pos])
                rotate([-90,0,0])
                    winglet_design();
            
            translate([0,-100,z_pos])
                cube([pt_te_top[0]-aileron_thickness-x_offset-aileron_cyl_radius,y_cube_winglet + 100,5000]);
  
        }//End of intersection
                
        intersection(){//We keep the wingshell slice at winglet_to_wing_hull distance from winglet to hull on it
        
            wing_shell();
                    
            translate([0,-2500,z_pos - winglet_to_wing_hull])
                cube([pt_te_bot[0]-aileron_thickness-x_offset-aileron_cyl_radius,5000,0.0001]);
                  
        } //End of intersection
            
    }//End of hull
    
}

/*
//Module to draw the attach between winglet and wing
module winglet_to_wing_attach(){

    circle_radius = 4;
    attach_height = 2;
    attach_y = 8.3;
    attach_x = 2;
    z_pos = wing_root_mm + wing_mid_mm + motor_arm_width - winglet_to_wing_hull;
    y_offset = -3.4;//-2.8;
    x_offset = 2.9*aileron_thickness; // Offset from TE
    all_pts_te = get_trailing_edge_points();
    pt_te_top = find_interpolated_point(z_pos, all_pts_te);
    x_pos = pt_te_top[0]-x_offset;
    

        translate([x_pos,y_offset,z_pos]) {
            
            rotate([-90,0,0]){
            rotate([0,-90,0]) translate([-attach_x/2,0,0]) linear_extrude(height=attach_x) polygon(points=[[0,0], [0,attach_y], [attach_height,attach_y]]);
            //translate([-attach_x/2,0,0]) cube([attach_x,attach_y,attach_height]);
            translate([0,attach_y,0]) linear_extrude(height=attach_height) circle(r=circle_radius);
            }
            }

}

//Module to void the attach between winglet and wing
module winglet_to_wing_attach_void(){

    scale_up = 1.2;// We use this parameter to get space for the parts to imbricate
    circle_radius = 4*scale_up;
    attach_height = 2.5;
    attach_y = 9;
    attach_x = 2*scale_up;
    z_pos = wing_root_mm + wing_mid_mm + motor_arm_width - winglet_to_wing_hull;
    y_offset = -3.4;//-2.8;
    x_offset = 2.9*aileron_thickness; // Offset from TE
    all_pts_te = get_trailing_edge_points();
    pt_te_top = find_interpolated_point(z_pos, all_pts_te);    
    x_pos = pt_te_top[0]-x_offset;    

    

        translate([x_pos,y_offset,z_pos]) 
            rotate([-90,0,0]){
            translate([-attach_x/2,0,-10]) cube([attach_x,attach_y,attach_height+10]);
            translate([0,attach_y,-10]) linear_extrude(height=attach_height+10) circle(r=circle_radius);
            }

}
*/

//Module to draw the attach between winglet and wing
module winglet_to_wing_attach(){

    attach_height = 5;
    attach_y = 3;
    attach_x = 1.2;
    crochet_scale = 1.5;
    z_pos = wing_root_mm + wing_mid_mm + motor_arm_width - winglet_to_wing_hull;
    y_offset = -3.4;//-2.8;
    x_offset = 2.9*aileron_thickness; // Offset from TE
    all_pts_te = get_trailing_edge_points();
    pt_te_top = find_interpolated_point(z_pos, all_pts_te);
    x_pos = pt_te_top[0]-x_offset;
    

        translate([x_pos,y_offset,z_pos]) {
            
            rotate([90,0,90]){
                translate([0,-2*attach_y+1,0]) linear_extrude(height=attach_height) polygon(points=[[0,0], [0,attach_y], [crochet_scale*attach_x,attach_y]]);
                translate([0,-attach_y+1,0]) cube([attach_x,attach_y,attach_height]);
            }
        }

} 

//Module to void the attach between winglet and wing
module winglet_to_wing_attach_void(){

    scale_up = 1.1;// We use this parameter to get space for the parts to imbricate
    height = 5;
    attach_height = height*scale_up;
    attach_y = 3;
    attach_x = 1.2*scale_up;
    crochet_scale = 1.5;
    z_pos = wing_root_mm + wing_mid_mm + motor_arm_width - winglet_to_wing_hull;
    y_offset = -3.4;//-2.8;
    x_offset = 2.9*aileron_thickness; // Offset from TE
    all_pts_te = get_trailing_edge_points();
    pt_te_top = find_interpolated_point(z_pos, all_pts_te);    
    x_pos = pt_te_top[0]-x_offset;    

    
        //(attach_height - height)/2 => correction on x axis of the scale to stay at the same place
        translate([x_pos-(attach_height - height)/2,y_offset,z_pos]) {
            
            rotate([90,0,90]){
                translate([0,-2*attach_y+1,0]) linear_extrude(height=attach_height) polygon(points=[[0,0], [0,attach_y], [crochet_scale*attach_x,attach_y]]);
                translate([0,-attach_y+1,0]) cube([attach_x,attach_y,attach_height]);
                translate([-2*attach_x,-2*attach_y+1,0]) cube([2*attach_x,2*attach_y,attach_height]);
            }
        }

}


///*** Function for connection between winglet to wing ***///
module Create_winglet_connection(cube_for_vase = false)
{
    
    points_le = get_leading_edge_points();
    z_pos = wing_root_mm + wing_mid_mm + motor_arm_width;
    pt_start = find_interpolated_point(z_pos, points_le);

    cube_for_vase_y1 = attached_1_radius*10;
    cube_for_vase_z1 = attached_1_length;
    cube_for_vase_y2 = attached_2_radius*10;
    cube_for_vase_z2 = attached_2_length;   
   
    scale_factor = 0.8; //Factor to decrease length of cylinder connection to avoid too tight junction
    

    translate([pt_start[0]-attached_1_x_pos,attached_1_y_pos,z_pos+attached_z_offset]){
        rotate([180,sweep_angle,0])
            color("green") 
            if(cube_for_vase){ // In vase mode, we create the hole in the mid part, we therefore offset the hole to avoid too tight junction 
                cylinder(h = attached_1_length/scale_factor, r = attached_1_radius*winglet_attach_dilatation_offset_PLA, center = false);
            }
            else {
                 cylinder(h = attached_1_length*scale_factor, r = attached_1_radius, center = false);
            }
                
            if(cube_for_vase){
                rotate([0,sweep_angle,0])
                    translate([0,0,-cube_for_vase_z1])
                        color("green")   
                            cube([slice_gap_width,cube_for_vase_y1,cube_for_vase_z1]);
                 }
               
                }                
            
    translate([pt_start[0]-attached_2_x_pos,attached_2_y_pos,z_pos + attached_z_offset]){
        rotate([180,sweep_angle,0])
            color("green") 
            if(cube_for_vase){   // In vase mode, we create the hole in the mid part, we therefore offset the hole to avoid too tight junction         
                cylinder(h = attached_2_length/scale_factor, r = attached_2_radius*winglet_attach_dilatation_offset_PLA, center = false);
            }
            else {
                 cylinder(h = attached_2_length*scale_factor, r = attached_2_radius, center = false);
            }
            
            if(cube_for_vase){
                rotate([0,sweep_angle,0])    
                    translate([0,0,-cube_for_vase_z2])
                        color("green")   
                            cube([slice_gap_width,cube_for_vase_y2,cube_for_vase_z2]);
                 }
    }                

}

///*** Function for void connection between winglet to wing ***///
module Create_winglet_connection_void()
{

    points_le = get_leading_edge_points();
    z_pos = wing_root_mm + wing_mid_mm + motor_arm_width;
    pt_start = find_interpolated_point(z_pos, points_le);
    

    translate([pt_start[0]-attached_1_x_pos,attached_1_y_pos,z_pos+attached_z_offset])
        rotate([180,sweep_angle,0])
            color("green") 
                cylinder(h = attached_1_length*winglet_attach_void_clearance, r = attached_1_radius*winglet_attach_void_clearance, center = false);

            
    translate([pt_start[0]-attached_2_x_pos,attached_2_y_pos,z_pos+attached_z_offset])
        rotate([180,sweep_angle,0])
            color("green") 
                cylinder(h = attached_2_length*winglet_attach_void_clearance, r = attached_2_radius*winglet_attach_void_clearance, center = false);  

                
                
}




///***                                           ***///
///*** Function winglet creation as wing design  ***///
///***                                           ***///

module WashoutSlice_winglet(index, current_chord_mm, local_wing_sections)
{

    washout_start_point = (winglet_mode == 1) ? (local_wing_sections * (washout_start_winglet / 100))
                                           : WashoutStart(0, local_wing_sections, washout_start_winglet, winglet_mm);
    washout_deg_frac = washout_deg_winglet / (local_wing_sections - washout_start_point);
    washout_deg_amount = (washout_start_point - index) * washout_deg_frac;
    rotate_point = current_chord_mm * (washout_pivot_perc_winglet / 100);

    translate([ rotate_point, 0, 0 ]) rotate(washout_deg_amount) translate([ -rotate_point, 0, 0 ])

        Slice_winglet(index, local_wing_sections);
}

module Slice_winglet(index, local_wing_sections)
{
        wingletAirfoilPolygon();
}

module WingSlice_winglet(index, z_location, local_wing_sections)
{

    // Function to calculate the rib cord length along an elliptical path
    function ChordLengthAtEllipsePosition_winglet(a, b, x) = b * pow(1 - pow(abs(x / a), elliptic_param_winglet), 1 / elliptic_param_winglet);
    
    
    current_chord_mm = (winglet_mode == 1) ? ChordLengthAtIndex(index, local_wing_sections)
                                        : ChordLengthAtEllipsePosition_winglet((winglet_mm + 0.1), winglet_root_chord_mm, z_location);
    scale_factor = current_chord_mm / 100;

    translate([ 0, 0, z_location ]) linear_extrude(height = 0.00000001, slices = 0)
        translate([ -winglet_center_line_perc / 100 * current_chord_mm, 0, 0 ])
            scale([ scale_factor, scale_factor,1 ]) 
           if (washout_deg_winglet > 0 &&
           ((winglet_mode > 1 && 
           index > WashoutStart(0, local_wing_sections, washout_start_winglet, winglet_mm)) ||
           (winglet_mode == 1 && index > (local_wing_sections * (washout_start_winglet / 100)))))
    {
        WashoutSlice_winglet(index, current_chord_mm, local_wing_sections);
    }
    else
    {
        Slice_winglet(index, local_wing_sections);
    }
}

module winglet_design(low_res = false)
{

    local_wing_sections = low_res ? floor(winglet_sections / 3) : winglet_sections;
    winglet_section_mm = winglet_mm / local_wing_sections;

    color("yellow")
    
    if (winglet_mode == 1)
    {
        translate([ winglet_root_chord_mm * (winglet_center_line_perc / 100), 0, 0 ]) union()
            {
        for (i = [0:local_wing_sections - 1])
        {
            z0 = winglet_section_mm * i;
            z1 = winglet_section_mm * (i + 1);

            y0 = use_custom_lead_edge_curve_winglet ? interpolate_y_winglet(z0) * curve_amplitude_winglet : 0;
            y1 = use_custom_lead_edge_curve_winglet ? interpolate_y_winglet(z1) * curve_amplitude_winglet : 0;

            x_off0 = use_custom_lead_edge_sweep_winglet ? interpolate_x_winglet(z0) : 0;
            x_off1 = use_custom_lead_edge_sweep_winglet ? interpolate_x_winglet(z1) : 0;

            hull()
            {
                translate([x_off0, y0, 0])
                    WingSlice_winglet(i, z0, local_wing_sections);
                translate([x_off1, y1, 0])
                    WingSlice_winglet(i + 1, z1, local_wing_sections);
            }
        }
        }
    }
    else
    {
        for (i = [0:local_wing_sections - 1])
        {
            z_pos = f(i, local_wing_sections, winglet_mm);
            z_npos = f(i + 1, local_wing_sections, winglet_mm);

            y0 = use_custom_lead_edge_curve_winglet ? interpolate_y_winglet(z_pos) * curve_amplitude_winglet : 0;
            y1 = use_custom_lead_edge_curve_winglet ? interpolate_y_winglet(z_npos) * curve_amplitude_winglet : 0;

            x_off0 = use_custom_lead_edge_sweep_winglet ? interpolate_x_winglet(z_pos) : 0;
            x_off1 = use_custom_lead_edge_sweep_winglet ? interpolate_x_winglet(z_npos) : 0;
            
            translate([ winglet_root_chord_mm * (winglet_center_line_perc / 100), 0, 0 ]) union()
            {
            
            hull()
            {
                translate([x_off0, y0, 0])
                    WingSlice_winglet(i, z_pos, local_wing_sections);
                translate([x_off1, y1, 0])
                    WingSlice_winglet(i + 1, z_npos, local_wing_sections);
            }
        }
        }
    }
}


//****************Tools function for interpolation**********//
// Y interpolation function from X (simple linear)
function interpolate_x_winglet(z) =
    let(
        i = search_index_z_winglet(lead_edge_sweep_winglet, z)
    )
    i == -1 ? 0 :
    let(
        z0 = lead_edge_sweep_winglet[i][0],
        x0 = lead_edge_sweep_winglet[i][1],
        z1 = lead_edge_sweep_winglet[i+1][0],
        x1 = lead_edge_sweep_winglet[i+1][1]
    )
    x0 + (z - z0) * (x1 - x0) / (z1 - z0);

function search_index_z_winglet(arr, z) = 
    (z < arr[0][0] || z > arr[len(arr)-1][0]) ? -1 :
    search_index_helper_z_winglet(arr, z, 0);

function search_index_helper_z_winglet(arr, z, i) = 
    (i >= len(arr) - 1) ? len(arr) - 2 :
    (z >= arr[i][0] && z < arr[i+1][0]) ? i :
    search_index_helper_z_winglet(arr, z, i + 1);
    
    
function interpolate_y_winglet(z) = let(i = search_index_z_y_winglet(lead_edge_curve_y_winglet, z))
    i == -1 ? 0 :
    let(z0 = lead_edge_curve_y_winglet[i][0], y0 = lead_edge_curve_y_winglet[i][1],
        z1 = lead_edge_curve_y_winglet[i+1][0], y1 = lead_edge_curve_y_winglet[i+1][1])
      y0 + (z - z0) * (y1 - y0)/(z1 - z0);

function search_index_z_y_winglet(arr, z) = 
    (z < arr[0][0] || z > arr[len(arr)-1][0]) ? -1 : search_index_helper_z_y_winglet(arr, z, 0);

function search_index_helper_z_y_winglet(arr, z, i) =
    (i >= len(arr)-1) ? len(arr)-2 :
    (z >= arr[i][0] && z < arr[i+1][0]) ? i :
    search_index_helper_z_y_winglet(arr, z, i+1); 
    
    