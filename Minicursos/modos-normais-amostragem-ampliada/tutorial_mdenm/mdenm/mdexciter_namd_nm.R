library(bio3d)

######################################################################################
# function  to generate linear combination of vectors
# according to Eq. 1 in the JCTC paper (Costa et al, 2015)
combine <- function(M, v){
  n <- length(v)
  if(n > 1){
    out <- M[,1] * v[1]
    if(ncol(M) != n) stop("The number of vectors and alphas must be equal ")
    for(i in 2:n){
      out <- out + M[,i] * v[i]
    }
  }else{
    out <- M * v[1]
  }
  # normalize resulting vectors 
  out / sqrt(sum(out*out))
}
#####################################################################################

#####################################################################################
read.mass.psf <- function(top){
  a <- as.numeric(system(command = paste0("grep '!NATOM' ",top," | awk '{print $1}'"),intern = TRUE))
  out <- as.numeric(system(command = paste0("grep -A ",a," '!NATOM' ",top," | awk '{print $8}' | tail -n +2"), intern = TRUE)) 
  #names(out) <-  c("eleno", "segid", "resno","resid","elety","elesy","charge","mass","zero","zero2","wmain")
  return(out)
}
######################################################################################
# function to calculate normal modes using distinct elastic network models
nm.calc <- function(x, ff, n.modes){
  switch(ff,
         hca = nma(x, ff = 'calpha', mass = T, temp = NULL, keep = n.modes),
         anm = nma(x, ff = 'anm',cutoff = 15, mass=FALSE, temp=NULL, keep = n.modes),
         aaenm = aanma.pdb(x, outmodes = 'noh', mass = T, keep = n.modes, rtb = T, temp = NULL))
}
#####################################################################################
com.mau <- function (pdb, inds = NULL, use.mass = TRUE, mass = NULL, ...) 
{
  if (missing(pdb)) 
    stop("Please supply an input 'pdb' object, i.e. from 'read.pdb()'")
  if (!is.pdb(pdb)) 
    stop("Input 'pdb' must be of type 'pdb'")
  if (is.null(inds)) {
    xyz <- pdb$xyz
    at <- pdb$atom[, "elety"]
  }
  else {
    if (!is.select(inds)) 
      stop("provide a select object as obtained from 'atom.select'")
    if (length(inds$xyz) < 3) 
      stop("insufficient atoms in selection")
    xyz <- pdb$xyz[, inds$xyz]
    at <- pdb$atom[inds$atom, "elety"]
  }
  if (use.mass) {
    #m <- atom2mass(at, ...)
    m <- mass
  }
  else {
    m <- NULL
  }
  com <- com.xyz(xyz, m)
  return(com)
}

######################################################################################
# function to extend model from ENMs calculated considering only c-alpha atoms
# REQUIRED INPUTS: 
# pdb -> pdb of the protein obtained after trim.pdb
# nma object
# modes selection
# selection of residues to apply excitations
# resno table is generated previously and contains
# the number of atoms per residue
extend.model <- function(pdb, nma, modes, selection, resno.table){
  n <- sum(pdb_ptn$calpha)
  times <- resno.table
  n.modes <- length(nma$L)
  #n.modes <- length(modes)
  sel.xyz <- atom2xyz(selection)
  m.aux <- matrix(0, nr = 3* n, nc =  n.modes)
  #m.aux <- matrix(0, nr = 3* n, nc = n.modes - 6)
  m.aux[sel.xyz,] <- nma$U[sel.xyz,]
  index <- NULL
  for ( i in 1:n ) {
    index <- c(index, rep(atom2xyz(i), times[i]))
  }
  # matrix of normal mode vectors "all atom" 
  out <- m.aux[index,modes]
}
#####################################################################################
splitseg <- function(pdbfile,segments){
  system(command = paste0("rm -f tempsegs"))
  for ( seg in segments ){
    system(command = paste0("grep ",seg," ",pdbfile," >> tempsegs"))
  }
  system(command = paste0("echo 'END' > end"))
  system(command = paste0("cat tempsegs end > not_ptn"))
}
######################################################################################

####################################
# MAIN ROUTINE
####################################

# read user defined parameters
source("inputs.R")

pdbvelfactor = 20.4548270 
kb = 0.001987191
##########################################################################
# MAIN LOOP CONTROL
cycle = 0 
while (cycle < maxcycles){
  ############################################
  # READ FILES
  if (cycle == 0){
    system(paste0("cp ../",coor.user," cycle_",cycle,".coor"))
    system(paste0("cp ../",vel.user," cycle_",cycle,".vel"))
    system(paste0("cp ../",ext.system," cycle_",cycle,".xsc"))
    pdb <- read.pdb("cycle_0.coor", hex = T)
    vel <- read.pdb("cycle_0.vel", hex = T)
    mass.sys <- read.mass.psf(paste0("../",topol))
    pdb$atom$b <- mass.sys
    pdb_ptn <- trim.pdb(pdb,inds = atom.select(pdb, segid = seg.user))  #picks the desired segment
    pdb.noh.inds <- atom.select(pdb_ptn, string = 'noh')
    pdb.ca.inds <- atom.select(pdb_ptn, string = 'calpha')
    vel_ptn <- trim.pdb(vel,inds = atom.select(vel, segid = seg.user))
    vel_ptn$xyz <- vel_ptn$xyz / pdbvelfactor
    if(sel.res == "all"){
      sel.res <- c(1: sum(pdb_ptn$calpha))
    }
    
    N <- length(pdb$atom$type)
    prot <- length(pdb_ptn$atom$type)
    nres <- sum(pdb_ptn$calpha)
    
    temp.pdb <- NULL
    new.resno <- NULL
    times.sys <- NULL
    for(seg in unique(seg.user)){
      pdb_seg <- trim.pdb(pdb_ptn,inds = atom.select(pdb_ptn, segid = seg)) #picks each segment
      nres.segi <- sum(pdb_seg$calpha)
      new.resno <- c(new.resno,rep(c(1:nres.segi), times=table(pdb_seg$atom$resno)))
      times.sys <- c(times.sys,table(pdb_seg$atom$resno))
      temp.pdb <- cat.pdb(temp.pdb, pdb_seg)
    }
    pdb_ptn$atom$resno <- new.resno
    
    if(shake == T){
      # number of degrees of freedon (assuming that SHAKE usage)
      not_h <- atom.select(pdb, string = 'h')
      n.wat <- atom.select(pdb, string = 'water')
      number.h <- length(not_h$atom)
      # tip-3 rigid waters have an extra degree of freedon for the dummy H-H bond
      number.wat <- length(n.wat$atom)/3
      dof <- 3*N-3 -number.h - number.wat
    }else{ 
      dof <- 3*N 
    } 
    
    message('#######################################')
    message('SUMMARY OF FILES AND PARAMETERS:')
    message(paste0("read ",coor.user," file"))
    message(paste0("read ",vel.user," file"))
    message(paste0("read ",ext.system," file"))
    message(paste0(N,' total atoms /',prot,' protein atoms'))
    message(paste0(dof,' degrees of freedom'))
    
    # randomize temperature of excitation (if temp.fix == FALSE)
    if(temp.fix == T){y <- 1}else{y <- runif(1,1e-10,1)}
    temp.rand <- temp.user * y
    
  }else{
    pdb <- read.pdb(paste0("cycle_",cycle,".coor"), hex = T)
    vel <- read.pdb(paste0("cycle_",cycle,".vel"), hex = T)
    vel_ptn <- trim.pdb(vel,inds = atom.select(vel, segid = seg.user))
    vel_ptn$xyz <- vel_ptn$xyz / pdbvelfactor
    message(paste0("read cycle_",cycle,".coor file"))
    message(paste0("read cycle_",cycle,".vel file"))
  }
  
  ###############################
  # loop update control
  cycle = cycle + 1
  message(paste0("STARTING CYCLE ", cycle))
  message('#######################################')
  
  # separate atoms not included in NM calculation
  segs <- unique(pdb$atom$segid)
  not.ptn.segs <- segs[segs != seg.user]
  splitseg(pdbfile =paste0("cycle_",cycle-1,".coor"), segments = not.ptn.segs)
  
  ###################################################
  # NORMAL MODE CALCULATIONS
  if (cycle == 1){
    alpha.q <- runif(length(modes), -0.5, 0.5)
    message('EXCITATION PARAMETERS:')
    message(paste0('excitation temperature: ',temp.rand))
    message(paste0('Number of excited modes: ',length(modes)))
    message('excited modes:')
    cat(modes)

    nmodes <- modes[length(modes)]
    m <- nm.calc(pdb_ptn, ff= enm.ff, n.modes = nmodes)
    if(enm.ff == 'aaenm'){
      message("Normal modes calculated with AAENM forcefield")
      q <- matrix(0, nr = 3*prot, nc = length(modes))
      q[pdb.noh.inds$xyz,] <- m$U[,modes]
      }else{
        message("Normal modes calculated with C-alpha ENMs")
        q <- extend.model(pdb=pdb_ptn, nma = m, modes = modes, selection = sel.res, resno.table = times.sys)
      }
    
    ###################################################
    # LINEAR COMBINATIONS 
    message(paste0("alpha coeficients writen to alphas.txt"))
    write.table(x = round(alpha.q,3),file = "alphas.txt",sep = " ",row.names = F,col.names = F, quote = F)
    Q <- combine(q, alpha.q)
    Q2 <- rbind(matrix(Q, nc=3, byrow = T), matrix(0, nr = N-prot, nc = 3))
    
    ###################################################
    # EXCITE STEP
    Ek <- sum(mass.sys*(((Q2[,1])^2)+((Q2[,2])^2)+((Q2[,3])^2)))/2
    temp.calc <- (2*Ek)/(dof*kb)
    lambda <- sqrt(temp.rand/temp.calc)
    Q.exct <- t(Q) * lambda
  }
  vel.update = vel_ptn$xyz + Q.exct
  
  ###################################################
  # WRITE EXCITATION VELOCITIES
  out.vel <- paste0("cycle_",cycle,".vel")
  write.pdb(vel_ptn, xyz = vel.update * pdbvelfactor, file= "temp.vel", print.segid = T, end = F)
  splitseg(pdbfile = paste0('cycle_',cycle-1,'.vel'), segments = not.ptn.segs)
  system(command = paste0("cat temp.vel not_ptn > ",out.vel)) 
  ###########################################
  # MD SIMULATION WITH EXCITATION VELOCITIES
  message(paste0("#############################"))
  message("STARTING MD")
  if(cycle==1){
    system(command = paste0("sed s/PDBFILE/cycle_0.coor/g config.namd | sed s/STEPS/",steps_md,"/g | sed s/VEL/",cycle,"/g | sed s/XSC/",cycle-1,"/g | sed s/SORTIE/",cycle,"/g | sed s/PSFFILE/",topol,"/g | sed s/TEMP/",temp.md,"/g | sed s/TS/",steps_md,"/g> config_run.namd"))
  }else{
    system(command = paste0("sed s/PDBFILE/cycle_",cycle-1,".coor/g config.namd | sed s/STEPS/",steps_md,"/g | sed s/VEL/",cycle,"/g | sed s/XSC/",cycle-1,"/g | sed s/SORTIE/",cycle,"/g | sed s/PSFFILE/",topol,"/g | sed s/TEMP/",temp.md,"/g | sed s/TS/",steps_md,"/g> config_run.namd"))
  }
  
  system(command = paste0(namd.input," config_run.namd > cycle_",cycle,".log"))
} # end while loop
    
