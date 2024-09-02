import pandas as pd
import numpy as np

# Constants
R = 1.9872041e-3  # kcal/(mol·K)
T = 298.15  # Temperature in Kelvin
k = 5.0  # Constant value in kcal/mol/rad^2 units

def adjust_angle_difference(delta_angle):
    """
    Adjust the angle difference to be within the range [-180, 180] degrees.
    """
    return delta_angle - 360 * round(delta_angle / 360.0)

def calculate_dG_restr(delta_radians):
    """
    Calculate the restraint free energy for a series of delta dihedrals.
    
    Parameters:
    - delta_radians: Series of delta dihedral angles in radians.
    
    Returns:
    - dG_restr: The calculated restraint free energy.
    """
    exponent = -k * delta_radians**2 / (R * T)
    mean_exp = np.mean(np.exp(exponent))
    dG_restr = R * T * np.log(mean_exp)
    return dG_restr

def process_dihedral_file(input_file, output_file, ref_values):
    """
    Processes the dihedral angles file, calculates the delta values, 
    adjusts for angle wrapping, converts to radians, and calculates
    restraint free energies.
    
    Parameters:
    - input_file: path to the input file containing dihedral angles.
    - output_file: path to save the output file with delta values.
    - ref_values: list of reference values for the three dihedrals.
    """
    # Load the data into a DataFrame, skipping the first row (column names)
    df = pd.read_csv(input_file, sep='\s+', skiprows=1)
    
    # Initialize a DataFrame to hold the delta values and dG_restr
    delta_df = pd.DataFrame()
    dG_restr_values = []
    
    # Iterate over the dihedral columns and calculate deltas and dG_restr
    for i, col in enumerate(df.columns[1:]):
        delta = df[col] - ref_values[i]
        delta_adjusted = delta.apply(adjust_angle_difference)
        delta_in_radians = np.deg2rad(delta_adjusted)
        delta_df[f'Delta_{col}'] = delta_in_radians
        
        # Calculate the restraint free energy for this dihedral
        dG_restr = calculate_dG_restr(delta_in_radians)
        dG_restr_values.append(dG_restr)
        print(f'dG_restr for dihedral {i+1}: {dG_restr:.6f} kcal/mol')
    
    # Save the delta values to the output file
    delta_df.to_csv(output_file, index=False, sep='\t', float_format='%.6f')
    
    # Calculate and print the total dG_restr
    total_dG_restr = sum(dG_restr_values)
    print(f'Total dG_restr: {total_dG_restr:.6f} kcal/mol')

# Define the reference values for the three dihedrals (in degrees)
reference_values = [23.0070, 97.8647, -82.0506]  # Example reference values

# Paths to the input and output files
input_file_path = 'dihedrals.dat'
output_file_path = 'delta_dihedrals_radians.dat'

# Process the dihedral angles and calculate restraint free energies
process_dihedral_file(input_file_path, output_file_path, reference_values)

