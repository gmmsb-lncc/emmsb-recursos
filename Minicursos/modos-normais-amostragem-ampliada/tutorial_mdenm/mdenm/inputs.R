# configuration file for running excitedMD - NM

#########  starting structure  ###############
#                                            #
# equilibrated coordinates                   #
coor.user <- "step4_equilibration.coor"
# equilibrated velocities                    #
vel.user <- "step4_equilibration.vel"   
# extended system XSC file                   #
ext.system <- "step4_equilibration.xsc"
# topology                                   #
topol <- "step3_input.psf"            
# segments included in NM or PCA calculation #
seg.user <- c("PROA")                        
# selection of protein residues for applying excitation   #
sel.res <- "all"                             
##############################################

#######################  excitation parameters ##############################
# normal modes 
modes = c(7:8) 
#  temperature of the NM space 
temp.user = 5
# ENM forcefield for NM calculation    
enm.ff = 'aaenm'  
# temperature of MD thermostat
temp.md = 300
# total number of cycles of excitation/relaxation
maxcycles = 5
# MD steps per excitation (here 1000 steps correspond to 2 ps)
steps_md = 1000
###############################################################################

######################  execution MD  ######################################
# the command line for executing MD should be inserted 
# in quotes as given in the example below
# users may change this according to the resources available

# example for CPU usage
namd.input = "namd2 +p2"
# example for GPU usage
#namd.input = "namd3  +idlepoll +p12 +devices 0"
###########################################################

# advanced options
shake = TRUE
temp.fix = TRUE # fixed excitation temperature  
