# -*- coding: utf-8 -*-
# File: align2d.py
# Reading the seg files and passing the sequences to a ali file.

from modeller import *

log.verbose()
env = environ()

#Considering heteroatoms and waters molecules
env.io.hetatm = env.io.water = True
# Directories with input atom files:
env.io.atom_files_directory = './:../atom_files'

# Identity matrix filename:
env.matrix_file = 'fer2.id.mat'
# Write out the superposed structures:
env.write_fit = True
# Some alignment parameters:
env.overhang = 4


#Reading file.seq
aln = alignment(env)
mdl = model(env, file='./5xmv.pdb', model_segment= ('FIRST:A','LAST:A')) 
aln.append_model(mdl, atom_files='./5xmv', align_codes='./5xmv')
aln.append(file='./alvo.seq',
           align_codes='all')

# Aligning seq files and writing file.ali and file.pap
aln.align2d()
aln.write(file='./align_5xmv_alvo.ali',
          alignment_format='PIR')
aln.write(file='./align_5xmv_alvo.pap',
          alignment_format='PAP')

