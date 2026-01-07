extra_spar_hole_bot_offset=0.2;

module CreateSparHole(sweep_ang, hole_offset, hole_perc, hole_size, hole_length, wing_root_chord, slice_gap, circles_nb, spar_circle_holder, spar_flip_side = false)
{


    //Here we rotate of 180 deg if requested to flip to other side
    flip_side = spar_flip_side ? 180 : 0;
    
    translate([ 0, hole_offset, 0 ]) union()
    {
        translate([ hole_perc / 100 * wing_root_chord, 0, 0 ]) difference()
        {
            color("blue")
                translate([ 0, hole_size / 2 - (slice_gap/2), 0 ]) 
                    rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep 
                        rotate([ 0, 0, flip_side ]) //rotation to flip from on side to the other with 
                            //cube([ slice_gap, 50, hole_length + 10 ]);
                            cube([ slice_gap, 50, hole_length ]);

            color("green")
                translate([ -5, hole_size / 2, hole_length ]) rotate([ 35, 0, 0 ]) 
                    rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep 
                        cube([ 10, 50, 20 ]);
        }

        color("red") translate([ hole_perc / 100 * wing_root_chord, 0, 0 ])
            rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep    
                //cylinder(h = hole_length, r = hole_size / 2);
                //We create a circle with small outer circle to maintain our spar
                linear_extrude(height = hole_length)
                    difference(){
                        circle(r=hole_size / 2);
                        
                            union(){
                                for (i = [0 : 360/circles_nb : 360-360/circles_nb]) {
                                    rotate([0,0,i])
                                        translate([hole_size / 2,0,0])
                                            circle(r=spar_circle_holder); 
                                }            
                            } //End of union
                    } //End of difference                
                
                
                
                
    }
}

module CreateSparVoid(sweep_ang, hole_offset, hole_perc, hole_size, hole_length, wing_root_chord, hole_void_clearance, spar_flip_side = false)
{   
    
    void_length_offset = 1.05;
    void_width = 100;
    offset_to_bottom = 5;
    //Here we offset of void width if requested to flip to other side
    flip_side = spar_flip_side ? void_width : 0;
    
    translate([ 0, hole_offset - extra_spar_hole_bot_offset, 0 ]) 
    union()
    {
        color("blue") 
            translate([ hole_perc / void_width * wing_root_chord, 0, 0 ])
                rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep
                    translate([ 0, 0, -offset_to_bottom ])// We offset in direction to bottom to compensate the rotation when applying a sweep angle. It's a margin
                        cylinder(h = hole_length*void_length_offset, r = hole_size / 2 + (hole_void_clearance / 2));
        
        color("brown") 
            translate([ hole_perc / void_width * wing_root_chord - ((hole_size + hole_void_clearance)/2), -flip_side, 0 ])
                rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep
                    cube([ hole_size + hole_void_clearance, void_width, hole_length ]);
    }
}

module CreateSparHole_center(sweep_ang, hole_offset, hole_perc, hole_size, hole_length, wing_root_chord, ct_width, circles_nb, spar_circle_holder, inser_lgth_into_center_part)
{
    translate([ 0, hole_offset, 0 ])    
        color("red") translate([ hole_perc / 100 * wing_root_chord, 0, 0 ])
            rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep    
                translate([ 0, 0, - inser_lgth_into_center_part ])    
                    //We create a circle with small outer circle to maintain our spar
                    linear_extrude(height = hole_length)
                        difference(){
                            circle(r=hole_size / 2);
                            
                                union(){
                                    for (i = [0 : 360/circles_nb : 360-360/circles_nb]) {
                                        rotate([0,0,i])
                                            translate([hole_size / 2,0,0])
                                                circle(r=spar_circle_holder); 
                                    }            
                                } //End of union
                        } //End of difference                    

}


//Create hole in root part for cable passage
module root_cables_hole(cable_hole_width, cable_hole_perc, cable_hole_ellipse, cable_hole_offset, slice_gap, sweep_ang, cable_passage_arm_perc, cable_passage_main_perc, wingmm, wing_rootmm, motorarm_to_winghull, wing_root_chordmm) {

    offset_bottom_z = -30;
    root_cables_hole_flip_side = true;
    //Here we rotate of 180 deg if requested to flip to other side
    flip_side = root_cables_hole_flip_side ? 180 : 0;
    
    intersection() {
    
    union() {
        color("orange") translate([ cable_hole_perc / 100 * wing_root_chordmm, cable_hole_offset, offset_bottom_z ])
            rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep    
                linear_extrude(height = wingmm)    
                    scale([1, cable_hole_ellipse/cable_hole_width])
                        circle(r = cable_hole_width, $fn = 100);
                                                
        color("blue")
            translate([ cable_hole_perc / 100 * wing_root_chordmm, cable_hole_width / 2 - (slice_gap/2), offset_bottom_z ]) 
                rotate([ 0, sweep_ang, 0 ]) //Spar angle rotation to follow the sweep 
                    rotate([ 0, 0, flip_side ]) //rotation to flip from on side to the other with 
                        cube([ slice_gap, 50, wingmm ]);
           
         //Hole for cable passage from wing to motor arm
        color("orange") translate([ cable_passage_arm_perc/ 100 * wing_root_chordmm, cable_hole_offset, wing_rootmm - motorarm_to_winghull ])
            rotate([ 90, 0, 0 ]) //Spar angle rotation to follow the sweep    
                linear_extrude(height = wingmm)    
                    scale([1, cable_hole_ellipse/cable_hole_width])
                        circle(r = cable_hole_width, $fn = 100);        

         //Hole for cable passage from wing to main stage
        color("orange") translate([ cable_passage_main_perc/ 100 * wing_root_chordmm, cable_hole_offset, 0 ])
            rotate([ 90, 0, 0 ]) //Spar angle rotation to follow the sweep    
                linear_extrude(height = wingmm)    
                    scale([1, cable_hole_ellipse/cable_hole_width])
                        circle(r = cable_hole_width, $fn = 100);                          
      }
        translate([-1000, -1000, 0])
            cube([2000, 2000, wing_rootmm - motorarm_to_winghull]);
    }
    
    
   
    
}

//Create hole in root part for cable passage
module root_cables_void(cable_hole_width, cable_hole_perc, cable_hole_ellipse, cable_hole_offset, cable_passage_arm_perc, cable_passage_main_perc, wingmm, wing_rootmm, motorarm_to_winghull, wing_root_chordmm) {

    void_offset = 1.15;
    void_width = 100;
    hole_void_clearance = 2;
    root_cables_hole_flip_side = true;
    //Here we rotate of 180 deg if requested to flip to other side
    flip_side = root_cables_hole_flip_side ? 180 : 0;
    void_cube_width = cable_hole_width/2;
    offset_bottom_z = -30;

    intersection() {
    
        union() {
            color("brown") translate([ cable_hole_perc / 100 * wing_root_chordmm +void_cube_width/2, cable_hole_offset, offset_bottom_z ])
                    rotate([ 0, sweep_angle, 0 ]) //Spar angle rotation to follow the sweep
                        rotate([ 0, 0, flip_side ]) //rotation to flip from on side to the other with
                            cube([ void_cube_width, void_width, wingmm ]);
                                               
            color("blue") translate([ cable_hole_perc / 100 * wing_root_chordmm, cable_hole_offset, -30 ])
                rotate([ 0, sweep_angle, 0 ]) //Spar angle rotation to follow the sweep    
                    linear_extrude(height = wingmm)    
                        scale([1, cable_hole_ellipse/cable_hole_width])
                            circle(r = cable_hole_width * void_offset, $fn = 100);
                          
         //Hole for cable passage from wing to motor arm
        color("orange") translate([ cable_passage_arm_perc/ 100 * wing_root_chordmm, cable_hole_offset, wing_rootmm - motorarm_to_winghull ])
            rotate([ 90, 0, 0 ]) //Spar angle rotation to follow the sweep    
                linear_extrude(height = wingmm)    
                    scale([1, cable_hole_ellipse/cable_hole_width])
                        circle(r = cable_hole_width * void_offset, $fn = 100);   
 
         //Hole for cable passage from wing to main stage
        color("orange") translate([ cable_passage_main_perc/ 100 * wing_root_chordmm, cable_hole_offset,0 ])
            rotate([ 90, 0, 0 ]) //Spar angle rotation to follow the sweep    
                linear_extrude(height = wingmm)    
                    scale([1, cable_hole_ellipse/cable_hole_width])
                        circle(r = cable_hole_width * void_offset, $fn = 100);  
         }
        
        cube_cut(0, wing_rootmm - motorarm_to_winghull);
    }
}