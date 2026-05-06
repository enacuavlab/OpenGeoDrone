CamberAdjust = 0; //% to increase or decrease the camber for difficult airfoils
CenterGap = slice_ext_width;
XandZHeight = 0.0001;

//function scalePath(points, scaleFactor) = [for (p = points)[p[0] * scaleFactor, p[1] * scaleFactor]];

function max_x(points, idx = 0, max_vals = undef,
               max_x_val = -1e10) = (idx == len(points)) ? max_vals
                                    : (points[idx][0] > max_x_val)
                                        ? max_x(points, idx + 1, [points[idx]], points[idx][0])
                                    : (points[idx][0] == max_x_val)
                                        ? max_x(points, idx + 1, concat(max_vals, [points[idx]]), max_x_val)
                                        : max_x(points, idx + 1, max_vals, max_x_val);

function max_y(points, idy = 0, max_val = [ -1e10, -1e10 ]) =
    (idy == len(points)) ? max_val : max_y(points, idy + 1, points[idy][1] > max_val[1] ? points[idy] : max_val);

function min_x(points, idx = 0, min_val = [ 1e10, 1e10 ]) =
    (idx == len(points)) ? min_val : min_x(points, idx + 1, points[idx][0] < min_val[0] ? points[idx] : min_val);

function min_y(points, idy = 0, min_val = [ 1e10, 1e10 ]) =
    (idy == len(points)) ? min_val : min_y(points, idy + 1, points[idy][1] < min_val[1] ? points[idy] : min_val);

function get_y_center_point(points) =
    let(min_point = min_y(points),
        max_point = max_y(points))[(min_point[0] + max_point[0]) / 2, (min_point[1] + max_point[1]) / 2];

function trailing_edge_center(AFPoints) =
    let(trailing_points = max_x(AFPoints))[trailing_points[0][0], avg_y(trailing_points)];

function avg_y(points) = sum_y(points) / len(points);

function tail(points, idx = 1) = idx >= len(points) ? [] : concat([points[idx]], tail(points, idx + 1));

function sum_y(points) = len(points) == 0 ? 0 : points[0][1] + sum_y(tail(points));

module CamberVoidLE(AFPoints)
{
    y_diff = max_y(AFPoints)[1] - min_y(AFPoints)[1];

    union()
    {
        color("red") hull()
        {
            translate(min_x(AFPoints)) cube([ XandZHeight, CenterGap, XandZHeight ], center = true);
            translate([ 0, (CamberAdjust / 100) * (y_diff / 2), 0 ]) translate(get_y_center_point(AFPoints))
                cube([ XandZHeight, CenterGap, XandZHeight ], center = true);
        }
    }
}

module CamberVoidTE(AFPoints)
{
    y_diff = max_y(AFPoints)[1] - min_y(AFPoints)[1];
    union()
    {
        color("blue") hull()
        {
            translate([ 0, (CamberAdjust / 100) * (y_diff / 2), 0 ]) translate(get_y_center_point(AFPoints))
                cube([ XandZHeight, CenterGap, XandZHeight ], center = true);
            translate(trailing_edge_center(AFPoints)) cube([ XandZHeight, CenterGap, XandZHeight ], center = true);
        }
    }
}

module GridWashoutSlice(i, scale_factor, current_chord_mm, LE)
{

    washout_start_point = (wing_mode == 1) ? (wing_sections * (washout_start / 100))
                                           : WashoutStart(0, wing_sections, washout_start, wing_mm);
    washout_deg_frac = washout_deg / (wing_sections - washout_start_point);
    washout_deg_amount = (washout_start_point - i) * washout_deg_frac;
    rotate_point = current_chord_mm * (washout_pivot_perc / 100);

    translate([ rotate_point, 0, 0 ]) rotate(washout_deg_amount) translate([ -rotate_point, 0, 0 ])
        GridESlice(i, scale_factor, LE);
}

module GridESlice(i, scale_factor, LE)
{

    if (i > wing_sections * (tip_airfoil_change_perc / 100))
    {
        if (LE)
        {
            CamberVoidLE(scalePath(af_vec_path_tip, scale_factor));
        }
        else
        {
            CamberVoidTE(scalePath(af_vec_path_tip, scale_factor));
        }
    }
    else if (i > wing_sections * (center_airfoil_change_perc / 100))
    {
        if (LE)
        {
            CamberVoidLE(scalePath(af_vec_path_mid, scale_factor));
        }
        else
        {
            CamberVoidTE(scalePath(af_vec_path_mid, scale_factor));
        }
    }
    else
    {
        if (LE)
        {
            CamberVoidLE(scalePath(af_vec_path_root, scale_factor));
        }
        else
        {
            CamberVoidTE(scalePath(af_vec_path_root, scale_factor));
        }
    }
}

module GridSlice(z_location, i, LE)
{
    current_chord_mm = (wing_mode == 1) ? ChordLengthAtIndex(i, wing_sections)
                                        : ChordLengthAtEllipsePosition((wing_mm + 0.1), wing_root_chord_mm, z_location);

    scale_factor = current_chord_mm / 100;
    translate([ 0, 0, z_location ]) translate([ -wing_center_line_perc / 100 * current_chord_mm, 0, 0 ])

        if (washout_deg > 0 && ((wing_mode > 1 && i > WashoutStart(0, wing_sections, washout_start, wing_mm)) ||
                                (wing_mode == 1 && i > (wing_sections * (washout_start / 100)))))
    {
        GridWashoutSlice(i, scale_factor, current_chord_mm, LE);
    }
    else
    {
        GridESlice(i, scale_factor, LE);
    }
}

module CreateGridVoid(low_res = false)
{
    local_wing_sections = low_res ? floor(wing_sections / 3) : wing_sections;
    wing_section_mm = wing_mm / local_wing_sections;


        translate([ wing_root_chord_mm * (wing_center_line_perc / 100), 0, 0 ]) union()
        {
            color("red") union()
            {
                for (i = [0:wing_sections])
                {
                    pos = f(i, local_wing_sections, wing_mm);
                    npos = f(i + 1, local_wing_sections, wing_mm);

                    //y0 = use_custom_lead_edge_curve ? interpolate_y(pos) * curve_amplitude : 0;
                    //y1 = use_custom_lead_edge_curve ? interpolate_y(npos) * curve_amplitude : 0;
                    y0 = use_custom_lead_edge_curve ? tip_dihedral_y(pos) : 0;
                    y1 = use_custom_lead_edge_curve ? tip_dihedral_y(npos) : 0;

                    x_off0 = use_custom_lead_edge_sweep ? interpolate_x(pos) : 0;
                    x_off1 = use_custom_lead_edge_sweep ? interpolate_x(npos) : 0;

                    hull()
                    {
                        translate([x_off0, y0, 0])
                            GridSlice(pos, i, true);
                        translate([x_off1, y1, 0])
                            GridSlice(npos, (i + 1), true);
                    }                    
                    
                    //pos = f(i, wing_sections, wing_mm);
                    //npos = f((i + 1), wing_sections, wing_mm);
                    //hull()
                   // {
                    //    GridSlice(pos, i, true);
                    //    GridSlice(npos, (i + 1), true);
                   // }
                }
            }
            color("blue") union()
            {
                for (i = [0:wing_sections])
                {
                    
                    pos = f(i, local_wing_sections, wing_mm);
                    npos = f(i + 1, local_wing_sections, wing_mm);

                    //y0 = use_custom_lead_edge_curve ? interpolate_y(pos) * curve_amplitude : 0;
                    //y1 = use_custom_lead_edge_curve ? interpolate_y(npos) * curve_amplitude : 0;
                    y0 = use_custom_lead_edge_curve ? tip_dihedral_y(pos) : 0;
                    y1 = use_custom_lead_edge_curve ? tip_dihedral_y(npos) : 0;                    

                    x_off0 = use_custom_lead_edge_sweep ? interpolate_x(pos) : 0;
                    x_off1 = use_custom_lead_edge_sweep ? interpolate_x(npos) : 0;

                    hull()
                    {
                        translate([x_off0, y0, 0])
                            GridSlice(pos, i, false);
                        translate([x_off1, y1, 0])
                            GridSlice(npos, (i + 1), false);
                    }  
                    /*
                    pos = f(i, wing_sections, wing_mm);
                    npos = f((i + 1), wing_sections, wing_mm);
                    hull()
                    {
                        GridSlice(pos, i, false);
                        GridSlice(npos, (i + 1), false);
                    }*/
                }
            }
        }
}