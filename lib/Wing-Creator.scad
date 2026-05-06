module WashoutSlice(index, current_chord_mm, local_wing_sections)
{

    washout_start_point = (wing_mode == 1) ? (local_wing_sections * (washout_start / 100))
                                           : WashoutStart(0, local_wing_sections, washout_start, wing_mm);
    washout_deg_frac = washout_deg / (local_wing_sections - washout_start_point);
    washout_deg_amount = (washout_start_point - index) * washout_deg_frac;
    rotate_point = current_chord_mm * (washout_pivot_perc / 100);

    translate([ rotate_point, 0, 0 ]) rotate(washout_deg_amount) translate([ -rotate_point, 0, 0 ])

        Slice(index, local_wing_sections);
}

module Slice(index, local_wing_sections)
{
    tip_airfoil_change_index = local_wing_sections * (tip_airfoil_change_perc / 100);
    center_airfoil_change_index = local_wing_sections * (center_airfoil_change_perc / 100);

    if (tip_airfoil_change_perc < 100 && (index > (tip_airfoil_change_index - slice_transisions) &&
                                          index < (tip_airfoil_change_index + slice_transisions)))
    {
        projection()
        {
            intersection()
            {
                hull()
                {
                    translate([ 0, 0, -10 ]) linear_extrude(height = 0.00000001, slices = 0) MidAirfoilPolygon();

                    translate([ 0, 0, 10 ]) linear_extrude(height = 0.00000001, slices = 0) TipAirfoilPolygon();
                }
            }
        }
    }
    else if (index > tip_airfoil_change_index)
    {
        TipAirfoilPolygon();
    }
    else if (center_airfoil_change_perc < 100 && (index > (center_airfoil_change_index - slice_transisions) &&
                                                  index < (center_airfoil_change_index + slice_transisions)))
    {
        projection()
        {
            intersection()
            {
                hull()
                {
                    translate([ 0, 0, -10 ]) linear_extrude(height = 0.00000001, slices = 0) RootAirfoilPolygon();

                    translate([ 0, 0, 10 ]) linear_extrude(height = 0.00000001, slices = 0) MidAirfoilPolygon();
                }
            }
        }
    }
    else if (index > center_airfoil_change_index)
    {
        MidAirfoilPolygon();
    }
    else
    {
        RootAirfoilPolygon();
    }
}

module WingSlice(index, z_location, local_wing_sections)
{
    current_chord_mm = (wing_mode == 1) ? ChordLengthAtIndex(index, local_wing_sections)
                                        : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, z_location);
    scale_factor = current_chord_mm / 100;

    translate([ 0, 0, z_location ]) linear_extrude(height = 0.00000001, slices = 0)
        translate([ -wing_center_line_perc / 100 * current_chord_mm, 0, 0 ])
            scale([ scale_factor, scale_factor,1 ]) 
           if (washout_deg > 0 &&
           ((wing_mode > 1 && 
           index > WashoutStart(0, local_wing_sections, washout_start, wing_mm)) ||
           (wing_mode == 1 && index > (local_wing_sections * (washout_start / 100)))))
    {
        WashoutSlice(index, current_chord_mm, local_wing_sections);
    }
    else
    {
        Slice(index, local_wing_sections);
    }
}

module CreateWing(low_res = false)
{
    local_wing_sections = low_res ? floor(wing_sections / 3) : wing_sections;
    wing_section_mm = wing_mm / local_wing_sections;

    color([0,0.5,0.5, opacity]) //Option for opacity to see ribs through wing
    
    if (wing_mode == 1)
    {
        translate([ wing_root_chord_mm * (wing_center_line_perc / 100), 0, 0 ]) union()
            {
        for (i = [0:local_wing_sections - 1])
        {
            z0 = wing_section_mm * i;
            z1 = wing_section_mm * (i + 1);

            //y0 = use_custom_lead_edge_curve ? interpolate_y(z0) * curve_amplitude : 0;
            //y1 = use_custom_lead_edge_curve ? interpolate_y(z1) * curve_amplitude : 0;
            y0 = use_custom_lead_edge_curve ? tip_dihedral_y(z0) : 0;
            y1 = use_custom_lead_edge_curve ? tip_dihedral_y(z1) : 0;
            
            x_off0 = use_custom_lead_edge_sweep ? interpolate_x(z0) : 0;
            x_off1 = use_custom_lead_edge_sweep ? interpolate_x(z1) : 0;

            hull()
            {
                //translate([x_off0, y0, z0])
                translate([x_off0, y0, 0])
                    WingSlice(i, z0, local_wing_sections);
                //translate([x_off1, y1, z1])
                translate([x_off1, y1, 0])
                    WingSlice(i + 1, z1, local_wing_sections);
            }
        }
        }
    }
    else
    {
        for (i = [0:local_wing_sections - 1])
        {
            z_pos = f(i, local_wing_sections, wing_mm);
            z_npos = f(i + 1, local_wing_sections, wing_mm);

            //y0 = use_custom_lead_edge_curve ? interpolate_y(z_pos) * curve_amplitude : 0;
            //y1 = use_custom_lead_edge_curve ? interpolate_y(z_npos) * curve_amplitude : 0;
            y0 = use_custom_lead_edge_curve ? tip_dihedral_y(z_pos) : 0;
            y1 = use_custom_lead_edge_curve ? tip_dihedral_y(z_npos) : 0;
            
            x_off0 = use_custom_lead_edge_sweep ? interpolate_x(z_pos) : 0;
            x_off1 = use_custom_lead_edge_sweep ? interpolate_x(z_npos) : 0;
            translate([ wing_root_chord_mm * (wing_center_line_perc / 100), 0, 0 ]) union()
            {
            hull()
            {
                translate([x_off0, y0, 0])
                    WingSlice(i, z_pos, local_wing_sections);
                translate([x_off1, y1, 0])
                    WingSlice(i + 1, z_npos, local_wing_sections);
            }
        }
        }
    }
}



//-----------------------------------------------------------
// WING SHELL CUT
// Cuts the wing shell at a given chord percentage and keeps
// either the Leading Edge or Trailing Edge side.
//
// Parameters:
//   keep_side            : "LE" = keep leading edge side
//                          "TE" = keep trailing edge side
//   cut_perc             : cut position as % from LE (0=LE, 100=TE)
//   local_wing_sections  : spanwise resolution (default = wing_sections)
//-----------------------------------------------------------
module WingShellCut(keep_side = "LE", cut_perc, local_wing_sections = wing_sections)
{
    // Spanwise length of each section slice
    wing_section_mm = wing_mm / local_wing_sections;

    // Global X offset applied to every section (chord center alignment)
    global_x_offset = wing_root_chord_mm * (wing_center_line_perc / 100);

    intersection() {

        // ── Full wing shell ──────────────────────────────────────────
        CreateWing();

        // ── Cutting volume ───────────────────────────────────────────
        // Built section by section so the cut plane correctly follows
        // chord taper, sweep and tip dihedral along the span
        union() {
            for (i = [0 : local_wing_sections - 1]) {

                // ── Spanwise Z positions for this slice ──────────────
                z0 = (wing_mode == 1)
                    ? wing_section_mm * i
                    : f(i, local_wing_sections, wing_mm);

                z1 = (wing_mode == 1)
                    ? wing_section_mm * (i + 1)
                    : f(i + 1, local_wing_sections, wing_mm);

                // ── Chord length at each slice boundary ──────────────
                chord0 = (wing_mode == 1)
                    ? ChordLengthAtIndex(i, local_wing_sections)
                    : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, z0);

                chord1 = (wing_mode == 1)
                    ? ChordLengthAtIndex(i + 1, local_wing_sections)
                    : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, z1);

                // ── X cut position in global coordinate space ────────
                // Accounts for: chord percentage, chord center offset,
                // global alignment offset, and leading edge sweep
                x_cut0 = (cut_perc / 100) * chord0
                       - (wing_center_line_perc / 100) * chord0
                       + global_x_offset
                       + (use_custom_lead_edge_sweep ? interpolate_x(z0) : 0);

                x_cut1 = (cut_perc / 100) * chord1
                       - (wing_center_line_perc / 100) * chord1
                       + global_x_offset
                       + (use_custom_lead_edge_sweep ? interpolate_x(z1) : 0);

                // ── Y offset from tip dihedral at each boundary ──────
                y0 = tip_dihedral_y(z0);
                y1 = tip_dihedral_y(z1);

                // ── Cutting box, hulled between the two slice planes ─
                // "LE" : box spans [-500 → x_cut]  (keeps LE side)
                // "TE" : box spans [x_cut → +500]  (keeps TE side)
                hull() {
                    translate([keep_side == "LE" ? -500 : x_cut0, y0 - 500, z0])
                        cube([keep_side == "LE" ? 500 + x_cut0 : 500, 1000, 0.001]);

                    translate([keep_side == "LE" ? -500 : x_cut1, y1 - 500, z1])
                        cube([keep_side == "LE" ? 500 + x_cut1 : 500, 1000, 0.001]);
                }
            }
        }
    }
}


//****************Tools function for interpolation**********//
// Y interpolation function from X (simple linear)
function interpolate_x(z) =
    let(
        i = search_index_z(lead_edge_sweep, z)
    )
    i == -1 ? 0 :
    let(
        z0 = lead_edge_sweep[i][0],
        x0 = lead_edge_sweep[i][1],
        z1 = lead_edge_sweep[i+1][0],
        x1 = lead_edge_sweep[i+1][1]
    )
    x0 + (z - z0) * (x1 - x0) / (z1 - z0);

function search_index_z(arr, z) = 
    (z < arr[0][0] || z > arr[len(arr)-1][0]) ? -1 :
    search_index_helper_z(arr, z, 0);

function search_index_helper_z(arr, z, i) = 
    (i >= len(arr) - 1) ? len(arr) - 2 :
    (z >= arr[i][0] && z < arr[i+1][0]) ? i :
    search_index_helper_z(arr, z, i + 1);
    
    
function interpolate_y(z) = let(i = search_index_z_y(lead_edge_curve_y, z))
    i == -1 ? 0 :
    let(z0 = lead_edge_curve_y[i][0], y0 = lead_edge_curve_y[i][1],
        z1 = lead_edge_curve_y[i+1][0], y1 = lead_edge_curve_y[i+1][1])
      y0 + (z - z0) * (y1 - y0)/(z1 - z0);

function search_index_z_y(arr, z) = 
    (z < arr[0][0] || z > arr[len(arr)-1][0]) ? -1 : search_index_helper_z_y(arr, z, 0);

function search_index_helper_z_y(arr, z, i) =
    (i >= len(arr)-1) ? len(arr)-2 :
    (z >= arr[i][0] && z < arr[i+1][0]) ? i :
    search_index_helper_z_y(arr, z, i+1);  
    
 
function rotate2D(pt, angle_deg, pivot) =
    let (
        angle = angle_deg * PI / 180,
        dx = pt[0] - pivot,
        dy = pt[1],
        x_rot = cos(angle) * dx - sin(angle) * dy + pivot,
        y_rot = sin(angle) * dx + cos(angle) * dy
    )
    [ x_rot, y_rot ];

//****************Tools function for Trailing Edge points retrieval  **********//     
function trailing_edge_point(index, local_wing_sections) =
    let (
        // Position envergure
        z = (wing_mode == 1) ? (index * wing_mm / local_wing_sections)
                             : f(index, local_wing_sections, wing_mm),

        // Length chord
        chord = (wing_mode == 1) ? ChordLengthAtIndex(index, local_wing_sections)
                                 : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, z),

        // Washout
        washout_start_point = (wing_mode == 1)
                                ? (local_wing_sections * (washout_start / 100))
                                : WashoutStart(0, local_wing_sections, washout_start, wing_mm),
        washout_deg_frac = (local_wing_sections - washout_start_point > 0) ? (washout_deg / (local_wing_sections - washout_start_point)) : 0,
        washout_deg_amount = (index > washout_start_point) ? (index - washout_start_point) * washout_deg_frac : 0,
        washout_pivot = chord * (washout_pivot_perc / 100),

        // Raw TE point (in untransformed 2D profile)
        x_te = chord,
        y_te = 0,

        //String center: translate by percentage of string center
        x_local = x_te - (wing_center_line_perc / 100) * chord,
        y_local = y_te,

        //Apply washout if necessary
        rotated = (washout_deg_amount != 0)
                    ? rotate2D([x_local, y_local], washout_deg_amount, washout_pivot - (wing_center_line_perc / 100) * chord)
                    : [x_local, y_local],

        //Sweep (X offset) and curve (Y offset)
        x_sweep = use_custom_lead_edge_sweep ? interpolate_x(z) : 0,
        //y_curve = use_custom_lead_edge_curve ? interpolate_y(z) * curve_amplitude : 0,
        y_curve = use_custom_lead_edge_curve ? tip_dihedral_y(z) : 0,

        //Global translation to align with the rest of the wing
        global_offset = [ wing_root_chord_mm * (wing_center_line_perc / 100), 0, 0 ],

        //End point with global offset
        point = [rotated[0] + x_sweep, rotated[1] + y_curve, z] + global_offset
    )
    point;
 

module show_trailing_edge_points(points) {
    for (p = points)
        translate(p) color("red") sphere(r = 1.5);
}
function get_trailing_edge_points(local_wing_sections = wing_sections) =
    [ for (i = [0 : local_wing_sections]) trailing_edge_point(i, local_wing_sections) ];
       


//****************Tools function for Leading Edge points retrieval  **********//  
function leading_edge_point(index, local_wing_sections) =
    let (
        // Spanwise position
        z = (wing_mode == 1) ? (index * wing_mm / local_wing_sections)
                             : f(index, local_wing_sections, wing_mm),

        // Chord length
        chord = (wing_mode == 1) ? ChordLengthAtIndex(index, local_wing_sections)
                                 : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, z),

        // Washout parameters
        washout_start_point = (wing_mode == 1)
                                ? (local_wing_sections * (washout_start / 100))
                                : WashoutStart(0, local_wing_sections, washout_start, wing_mm),
        washout_deg_frac = (local_wing_sections - washout_start_point > 0) ? (washout_deg / (local_wing_sections - washout_start_point)) : 0,
        washout_deg_amount = (index > washout_start_point) ? (index - washout_start_point) * washout_deg_frac : 0,
        washout_pivot = chord * (washout_pivot_perc / 100),

        // Raw LE point in local 2D profile
        x_le = 0,
        y_le = 0,

        // Shift origin to string center
        x_local = x_le - (wing_center_line_perc / 100) * chord,
        y_local = y_le,

        // Apply washout rotation
        rotated = (washout_deg_amount != 0)
                    ? rotate2D([x_local, y_local], washout_deg_amount, washout_pivot - (wing_center_line_perc / 100) * chord)
                    : [x_local, y_local],

        // Sweep and curvature offsets
        x_sweep = use_custom_lead_edge_sweep ? interpolate_x(z) : 0,
        //y_curve = use_custom_lead_edge_curve ? interpolate_y(z) * curve_amplitude : 0,
        y_curve = use_custom_lead_edge_curve ? tip_dihedral_y(z) : 0,

        // Global offset
        global_offset = [ wing_root_chord_mm * (wing_center_line_perc / 100), 0, 0 ],

        // Final leading edge point in 3D space
        point = [rotated[0] + x_sweep, rotated[1] + y_curve, z] + global_offset
    )
    point;
  
module show_leading_edge_points(points) {
    for (p = points)
        translate(p) color("blue") sphere(r = 1.5);
}
    
function get_leading_edge_points(local_wing_sections = wing_sections) =
    [ for (i = [0 : local_wing_sections]) leading_edge_point(i, local_wing_sections) ];

    
    
//****************Tools function and modules for Full Wing points retrieval  **********//  
// Display all upper and lower wall points for each airfoil section
// from the Leading Edge (LE, x=0) to the Trailing Edge (TE, x=chord)
module show_all_airfoil_wall_points_full(local_wing_sections = wing_sections, steps_per_chord = 50) {
    for (i = [0 : local_wing_sections]) {

        // Retrieve the actual chord length for this section
        chord = (wing_mode == 1)
                    ? ChordLengthAtIndex(i, local_wing_sections)
                    : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm,
                                                   (wing_mode == 1) ? i*wing_mm/local_wing_sections
                                                                    : f(i, local_wing_sections, wing_mm));

        // Generate the x positions from the LE (0) to the TE (chord)
        x_positions = [for (s = [0 : steps_per_chord]) s/steps_per_chord * chord];

        for (x = x_positions)
            show_airfoil_wall_points(x, i, local_wing_sections);
    }
}




 
// Module to display the outer wall points (upper/lower)
// x : position along the chord (in local mm)
// index : section index (0 → root, N → tip)
// local_wing_sections : number of wing sections
module show_airfoil_wall_points(x, index, local_wing_sections = wing_sections) {

    // Recover Z position at index
    z = (wing_mode == 1)
        ? (index * wing_mm / local_wing_sections)
        : f(index, local_wing_sections, wing_mm);
     
    // Recover X, Ymin, Ymax
    xy_wall = airfoil_y_minmax_at(x, z, index, local_wing_sections);

    // Display
    if (xy_wall[1] != undef && xy_wall[2] != undef) {
        translate([xy_wall[0], xy_wall[1], z])
            color("red") sphere(r = 1.5);   // mur inférieur
        translate([xy_wall[0], xy_wall[2], z])
            color("green") sphere(r = 1.5); // mur supérieur
    }
}

  
       
    
    
    
    
//Return the x position requested with transformation and Y min and max
function airfoil_y_minmax_at(x, z, index, local_wing_sections) =
    let (

        //We use the profil pints  
        airfoil_points = af_vec_path_root,

        // Real chord at this section
        chord = (wing_mode == 1)
            ? ChordLengthAtIndex(index, local_wing_sections)
            : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, z),

        // Scale Factor of the chord
        scale_factor = chord / 100,

        // Washout progressive
        washout_start_point = (wing_mode == 1)
            ? (local_wing_sections * (washout_start / 100))
            : WashoutStart(0, local_wing_sections, washout_start, wing_mm),

        washout_deg_frac = (local_wing_sections - washout_start_point > 0)
            ? (washout_deg / (local_wing_sections - washout_start_point))
            : 0,

        washout_deg_amount = (index > washout_start_point)
            ? (index - washout_start_point) * washout_deg_frac
            : 0,

        washout_pivot = chord * (washout_pivot_perc / 100),

        // Transformation on profil : scale, rotation, sweep, curve ,etc
        pts_global = [
            for (p = airfoil_points)
                let(
                    // Scaling from 0–100% to mm
                    p_scaled = [p[0] * scale_factor, p[1] * scale_factor],

                    // Shift to chord center position
                    p_centered = [p_scaled[0] - (wing_center_line_perc / 100) * chord, p_scaled[1]],

                    // Washout
                    p_rot = (washout_deg_amount != 0)
                                ? rotate2D(p_centered, washout_deg_amount,
                                           washout_pivot - (wing_center_line_perc / 100) * chord)
                                : p_centered,
                                
                    // Sweep and Curve
                    x_sweep = use_custom_lead_edge_sweep ? interpolate_x(z) : 0,
                    //y_curve = use_custom_lead_edge_curve ? interpolate_y(z) : 0,
                    y_curve = use_custom_lead_edge_curve ? tip_dihedral_y(z) : 0,
                    p_swept = [p_rot[0] + x_sweep, p_rot[1] + y_curve * curve_amplitude],

                    // Global offset 
                    p_global = [p_swept[0] + wing_root_chord_mm * (wing_center_line_perc / 100), p_swept[1]]

                ) p_global
        ],

        
        
        //We update the x demanded chord to our transformation
        x1 = x - (wing_center_line_perc / 100) * chord,
        rotated = (washout_deg_amount != 0)
                                ? rotate2D([x1,0], washout_deg_amount,
                                           washout_pivot - (wing_center_line_perc / 100) * chord)
                                : [x1,0],
        x_sweep = use_custom_lead_edge_sweep ? interpolate_x(z) : 0,
        x2 = rotated[0] + x_sweep,
        x_updated = x2 + wing_root_chord_mm * (wing_center_line_perc / 100),

        
        
        // Tolerance to find points at x position
        eps = chord * 0.005, //0.005,
        // Y Points around x
        y_candidates = [ for (p = pts_global) if (abs(p[0] - x_updated) < eps) p[1] ],

        // Y values
        y_min = (len(y_candidates) > 0) ? min(y_candidates) : undef,
        y_max = (len(y_candidates) > 0) ? max(y_candidates) : undef
    )
    [x_updated, y_min, y_max];



//**************** dihedral wingtip — power equation **********//
function tip_dihedral_y(z) =
    let(
        z_start = wing_root_mm + motor_arm_width + wing_mid_mm  // tip section start
    )
    (!use_tip_dihedral || z <= z_start) ? 0 :
    let(
        z_end     = wing_mm,
        t         = (z - z_start) / max(z_end - z_start, 0.001),  // progression 0→1 in tip
        t_clamped = min(t, 1)
    )
    tip_dihedral_amplitude * pow(t_clamped, tip_dihedral_exponent);    