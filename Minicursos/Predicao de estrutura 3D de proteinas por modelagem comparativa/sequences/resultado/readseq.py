# -*- coding: utf-8 -*-
# File: readseq.py
# Reading the structure file and passing the sequence to a seg file.

from modeller import *

log.verbose()
env = environ()

#Considering heteroatoms and waters molecules
env.io.hetatm = env.io.water = True
# Directories with input atom files:
env.io.atom_files_directory = './:../atom_files'

#Reading file.pdb and writing file.seg
codes = ['./5lsa', './4pyi']
for code in codes:
    mdl = model(env, file=code)
    aln = alignment(env)
    aln.append_model(mdl, align_codes=code)
    aln.write(file=code+'.seq')
