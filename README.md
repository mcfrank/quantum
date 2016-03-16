# quantum

Code and data for the analyses reported in Frank, Vul, & Saxe (2011), Infancy.

Raw eye-tracking data can be found [here](https://figshare.com/articles/Frank_Vul_Saxe_2011_Infancy_Raw_Data/3116971) on figshare. They should be in a sub-directory called `raw_data`. 

Stimulus movies are available [here](http://langcog.stanford.edu/materials/social_attention.html).

+ `preprocessing` transforms the raw data into `.mat` files for further analysis
+ `ROIs` does ROI analyses
+ `tagger` is a simple tagger for movies
+ `kdes` does kernel density estimates for the entropy analysis in the paper
+ `calib_adjust` does calibration adjustment
+ `descriptives` has descriptive statistics
+ `on_task` is analyses of basic statistics for how long babies were looking
+ `cross-recurrence` is cross-recurrence analyses, not reported in the paper

Please email mcfrank (at) stanford.edu for further information. 
