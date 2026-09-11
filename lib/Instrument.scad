//  ***  Module for instrument integration in OGD *** //


// ============================================================
//  MAPIR CAMERA -- Create hole in back fuselage for MAPIR
// ============================================================

module mapir_cam_hole() {
    
    x_mapir_position = 110;
    camera_mapir_height = 400;
    camera_mapir_radius = 11.5;
    camera_mapir_pos = [x_mapir_position,-camera_mapir_height/2,-center_width/2 + 3*camera_mapir_radius/2];

            translate(camera_mapir_pos)
                rotate([90,0,0])
                    cylinder(h=camera_mapir_height, r=camera_mapir_radius, center = true, $fn=50);  
}