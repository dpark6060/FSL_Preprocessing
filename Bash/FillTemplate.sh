#!/bin/sh

TEMPLATE=../Template/Template.fsf

# This should be set up in some universal path file
FSL_DIR=/usr/local/fsl/5.0.7/bin


####################################################################
# VOLUME INFO
####################################################################

# THE INPUT FMRI VOLUME TO USE (CAN BE .NII OR .NII.GZ)
INPUT_DATA='/share/dbp2123/dparker/Code/FSL_DefaultProcessing/fMRI.nii.gz'

# USE 'FSLHD' TO FIND AND SET THE TR
#TR=` fslhd ${INPUT_DATA} | grep pixdim3 | tr -s ' ' | cut -d' ' -f2 `
TR=` fslhd ${INPUT_DATA} | grep pixdim4 | awk '{print $2}' `

# FOR SOME REASON IT LIKES TO KNOW THE NUMBER OF VOXELS.  WE'LL
# use 'fslhd' again to do this
DXYZ=(` fslhd ${INPUT_DATA} | grep ^dim[1-4] `)
NX=${DXYZ[1]}
NY=${DXYZ[3]}
NZ=${DXYZ[5]}
NUM_VOL=${DXYZ[7]}

# As long as NX NY NZ and NUM_VOL are int, this works fine.
# Decimals will mess it up
NUM_VOX=$(( NX*NY*NZ*NUM_VOL ))

# SET THE NUMBER OF VOLUMES TO DELETE 
DEL_VOL=0

# SET THE OUTPUT DIRECTORY
OUTPUTDIR=` dirname ${INPUT_DATA} `/fsl_preproc
if [ ! -e ${OUTPUTDIR} ]; then
    mkdir ${OUTPUTDIR}
fi



####################################################################
# STATISTICS
# Strictly speaking, these aren't important for the preprocessing
# and COULD be ignored
####################################################################

# SET THE BRAIN BACKGROUND THRESHOLD
# It is used in intensity normalisation, brain mask
# generation and various other places in the analysis.
BB_THRESH=10

# SET THE Z THRESHOLD FOR DESIGN EFFICIENCY CALCULATION
# used to determine what level of activation would
# be statistically significant, to be used only in the design
# efficiency calculation. Increasing this will result in higher
# estimates of required effect.
Z_THRESH=5.3

# SET THE FMRI NOISE LEVEL
# the standard deviation (over time) for a
# typical voxel, expressed as a percentage of the baseline signal level.
NOISE_LVL=0.66

# SET TNE TEMPORAL SMOOTHNESS
# is the smoothness coefficient in a simple
# AR(1) autocorrelation model (much simpler than that actually used in
# the FILM timeseries analysis but good enough for the efficiency
# calculation here).
T_SMOOTH=0.34

####################################################################
# PREPROCESSING OPTIONS
####################################################################

# RUN MOTION CORRECTION
MC=1

# RUN SLICE TIMING CORRECTION
# 0 : None
# 1 : Regular up (0, 1, 2, 3, ...)
# 2 : Regular down
# 3 : Use slice order file
# 4 : Use slice timings file
# 5 : Interleaved (0, 2, 4 ... 1, 3, 5 ... )
STC=1

# SLICE ORDER/TIMING FILE
# If at slice order or timing file is chosen,
# This must also be set
SLICE_FILE=''

# RUN BRAIN EXTRACTION USING FSL's BET
BET=1

# SET THE FWHM FOR SPATIAL SMOOTHING (mm)
FWHM=5

# RUN INTENSITY NORMILIZATION
INT_NORM=1

# HIGHPASS FILTER CUTOFF (seconds)
HPF_CUTOFF=100

# RUN HIGHPASS FILTERING
HPF=1

####################################################################
# CREATE TEMPLATE
####################################################################

# Create a lost of all the variable names
# which match the place-holding text in the template
VAR_STRINGS=( INPUT_DATA TR NUM_VOL NUM_VOX DEL_VOL OUTPUTDIR BB_THRESH Z_THRESH NOISE_LVL T_SMOOTH MC STC SLICE_FILE BET FWHM INT_NORM HPF_CUTOFF HPF )

cp ${TEMPLATE} ${OUTPUTDIR}/MyDesign.fsf

# loop through and preform substitution
for var_name in ${VAR_STRINGS[@]}; do
    
    var_val=` eval 'echo $'$var_name `
    #We need to repalce and backslashes with "\/"
    var_val=` echo ${var_val////"\/"} `
    
    sed -i -e "s/\^${var_name}\^/${var_val}/g" ${OUTPUTDIR}/MyDesign.fsf
    
done

## Or with a bash-only approach:
#
#for var_name in ${VAR_STRINGS[@]}; do
#    
#    var_val=eval 'echo $'$var_name
#    while read a ; do echo ${a//^${var_name}^/${var_val}} ; done < ${OUTPUTDIR}/MyDesign.fsf > ${OUTPUTDIR}/MyDesign.fsf.t ; mv ${OUTPUTDIR}/MyDesign.fsf{.t,}
#    
#done

# 

# RUN THE .FSF FILE
$FSL_DIR/feat ${OUTPUTDIR}/MyDesign.fsf

# CLEANUP THE OUTPUT DIRECTORIES
# fsl will create an ${OUTPUTDIR}.feat directory anyways,
# so we can delete the old one
rm -rf ${OUTPUTDIR}
















