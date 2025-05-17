Use known camera translation to triangulate feature positions, then rectify image onto a best-fit plane.

Run `mark_features` and select trackable features from frames before and after the drill operation.
Features should be marked in the same order for both frames.
This will create the files `field_data/frame_xxx_rect.csv` and `field_data/frame_xxx_rect_annotated.png` for both frames

Run `ice_normal_rectify` to run triangulation algorithm (`multi_view_triangulation`) and rectify an image to the resulting plane (`rectify_image`).

Scale in mm/pixel is calculated as an average of distances between all pairs of points measured on the pre-drill frame.