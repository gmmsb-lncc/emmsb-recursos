import pandas as pd
import numpy as np

# Constants
R = 1.9872041e-3  # kcal/(mol·K)
T = 298.15  # Temperature in Kelvin
k = 5.0  # Constant value in kcal/mol/rad^2 units

def calculate_dG_restr(delta_radians):
    """
    Calculate the restraint free energy for a series of delta angles.
    
    Parameters:
    - delta_radians: Series of delta angle values in radians.
    
    Returns:
    - dG_restr: The calculated restraint free energy.
    """
    exponent = -k * delta_radians**2 / (R * T)
    mean_exp = np.mean(np.exp(exponent))
    dG_restr = R * T * np.log(mean_exp)
    return dG_restr

def process_angle_file(input_file, output_file, ref_values):
    """
    Processes the angle data file, calculates the delta values, converts them to radians,
    and calculates restraint free energies.
    
    Parameters:
    - input_file: path to the input file containing angle data.
    - output_file: path to save the output file with delta values in radians.
    - ref_values: list of reference values for the two angles.
    """
    # Load the data into a DataFrame, skipping the first row (column names)
    df = pd.read_csv(input_file, sep='\s+', skiprows=1)
    
    # Initialize a DataFrame to hold the delta values and dG_restr
    delta_df = pd.DataFrame()
    dG_restr_values = []
    
    # Iterate over the angle columns and calculate deltas and dG_restr
    for i, col in enumerate(df.columns[1:]):
        delta = df[col] - ref_values[i]
        delta_in_radians = np.deg2rad(delta)
        delta_df[f'Delta_{col}'] = delta_in_radians
        
        # Calculate the restraint free energy for this angle series
        dG_restr = calculate_dG_restr(delta_in_radians)
        dG_restr_values.append(dG_restr)
        print(f'dG_restr for angle {i+1}: {dG_restr:.6f} kcal/mol')
    
    # Save the delta values in radians to the output file
    delta_df.to_csv(output_file, index=False,sep='\t', float_format='%.6f')
    
    # Calculate and print the total dG_restr
    total_dG_restr = sum(dG_restr_values)
    print(f'Total dG_restr: {total_dG_restr:.6f} kcal/mol')

# Define the reference values for the two angles (in degrees)
reference_values = [63.4117, 51.5664]  # Example reference values

# Paths to the input and output files
input_file_path = 'angles.dat'
output_file_path = 'delta_angles_radians.dat'

# Process the angles, calculate delta values, and calculate restraint free energies
process_angle_file(input_file_path, output_file_path, reference_values)

