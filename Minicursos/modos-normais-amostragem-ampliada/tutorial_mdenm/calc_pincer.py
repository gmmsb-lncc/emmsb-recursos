#!/usr/bin/env python
# coding: utf-8
import sys
import pandas as pd
from prody import *
from os import chdir
from pylab import *
from matplotlib import *
import matplotlib.pyplot as plt
import numpy as np


#chdir('~/tutorial_mdenm/')
ref = parsePDB('lyso_ca.pdb')

traj = sys.argv[1]

#trajetoria mdenm
mdenm = parseDCD('mdenm/mdenm_lyso_10exc.dcd')
md = parseDCD('lyso_2019_md_fit_CA.dcd')
exp = parseDCD('experimental_lyso_814s.dcd')

ensemble_pdb = globals()[traj] 
ensemble_pdb.setCoords(ref)
ensemble_pdb.setAtoms(ref)

pincer_traj=[]


# getAngle function from Prody 


RAD2DEG =57.2958
def getAngle(coords1, coords2, coords3, radian=False):
    """Returns bond angle in degrees unless ``radian=True``"""

    v1 = coords1 - coords2
    v2 = coords3 - coords2

    rad = arccos((v1*v2).sum(-1) / ((v1**2).sum(-1) * (v2**2).sum(-1))**0.5)
    if radian:
        return rad
    else:
        return rad * RAD2DEG


# Get CoM of pincer angle regions


for i in range(len(ensemble_pdb)):
    reg10 = ensemble_pdb.getCoordsets(i)[27:31]
    reg11 = ensemble_pdb.getCoordsets(i)[110:114]
    reg2 = ensemble_pdb.getCoordsets(i)[89:93]
    reg30 = ensemble_pdb.getCoordsets(i)[43:45]
    reg31 = ensemble_pdb.getCoordsets(i)[50:52]
    reg1 = np.concatenate((reg10, reg11),axis = 0)
    reg3 = np.concatenate((reg30, reg31),axis = 0)
    reg1_massa = np.repeat(12.0107,len(reg1))
    reg2_massa = np.repeat(12.0107,len(reg2))
    reg3_massa = np.repeat(12.0107,len(reg3))
    reg1_com =  calcCenter(reg1,weights=reg1_massa)
    reg2_com =  calcCenter(reg2,weights=reg2_massa)
    reg3_com =  calcCenter(reg3,weights=reg3_massa)
    pincer = getAngle(reg1_com, reg2_com, reg3_com)
    pincer_traj.append(pincer)


# Writing .csv file


out = pd.DataFrame(pincer_traj, columns=["angle"])
out.to_csv("pincer_"+traj+".csv")

