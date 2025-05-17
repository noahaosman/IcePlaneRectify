Use known camera translation to triangulate feature positions, then rectify image onto a best-fit plane.

Run `mark_features` and select trackable features from frames before and after the drill operation.
Features should be marked in the same order for both frames.
This will create the files `field_data/frame_xxx_rect.csv` and `field_data/frame_xxx_rect_annotated.png` for both frames

Run `ice_normal_rectify` to run triangulation algorithm (`multi_view_triangulation`) and rectify an image to the resulting plane (`rectify_image`).

Scale in mm/pixel is calculated as an average of distances between all pairs of points measured on the pre-drill frame.



Input frames should first be undistorted using the [Camera Calibration Toolbox for Matlab](http://vigir.missouri.edu/Images/Caltech-Toolbox/index.html).  
Calibration intrinsic parameters:
>Focal Length:          fc = [ 4276.55486   4298.06579 ] +/- [ 11.44657   12.17405 ]  
Principal point:       cc = [ 2706.64767   1450.48271 ] +/- [ 5.26535   7.47952 ]  
Skew:             alpha_c = [ 0.00000 ] +/- [ 0.00000  ]   => angle of pixel axes = 90.00000 +/- 0.00000 degrees  
Distortion:            kc = [ 0.97119   2.11713   -0.01975   0.01871  0.00000 ] +/- [ 0.01475   0.05973   0.00318   0.00224  0.00000 ]  
Pixel error:          err = [ 1.54698   1.60190 ]  