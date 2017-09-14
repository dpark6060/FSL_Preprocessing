# FSL_Preprocessing

This creates a simple .fsf file that performs basic preprocessing.  
This includes the following steps, all of which are optional:

1) Initial Volume Removal   (default 0 volumes)
1) Motion Correction        (default YES)
2) Slice Timing Correction  (default YES, must specify acquisition order)
3) Spatial Smoothing        (default 5mmFWHM)
4) Intensity Normalization  (default YES)
5) High-Pass Filtering      (default 100s cutoff)
6) Brain extraction         (default YES)
