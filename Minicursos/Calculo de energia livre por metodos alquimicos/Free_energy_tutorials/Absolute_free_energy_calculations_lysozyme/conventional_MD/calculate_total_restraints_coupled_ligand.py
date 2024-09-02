import pandas as pd
import numpy as np

# Constants
R = 1.9872041e-3  # kcal/(mol·K)
T = 298.15  # Temperature in Kelvin
k = 5.0  # Constant value in kcal/(mol·Å^2) or kcal/(mol·rad^2) units

def calculate_dG_restr(delta):
    """
    Calculate the restraint free energy for a series of delta values.
    
    Parameters:
    - delta: Series of delta values.
    
    Returns:
    - dG_restr: The calculated restraint free energy.
    """
    exponent = -k * delta**2 / (R * T)
    mean_exp = np.mean(np.exp(exponent))
    dG_restr = R * T * np.log(mean_exp)
    return dG_restr

def process_distance_file(input_file, output_file, ref_value):
    """
    Processes the distance data file, calculates the delta values,
    and calculates restraint free energies for distance data.
    
    Parameters:
    - input_file: path to the input file containing distance data.
    - output_file: path to save the output file with delta values.
    - ref_value: reference value for the distance.
    """
    # Load the data into a DataFrame, skipping the first row (column names)
    df = pd.read_csv(input_file, sep='\s+', skiprows=1)
    
    # Initialize a DataFrame to hold the delta values and dG_restr
    delta_df = pd.DataFrame()
    
    # Extract the distance values from the second column
    distance_values = df.iloc[:, 1]
    
    # Calculate the delta values
    delta = distance_values - ref_value
    delta_df['Delta_Distance'] = delta
    
    # Calculate the restraint free energy for the distance series
    dG_restr = calculate_dG_restr(delta)
    
    # Save the delta values to the output file
    delta_df.to_csv(output_file, index=False, sep='\t', float_format='%.6f')
    
    return dG_restr

def process_angle_file(input_file, output_file, ref_values):
    """
    Processes the angle data file, calculates the delta values, converts them to radians,
    and calculates restraint free energies for angle data.
    
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
    
    # Save the delta values in radians to the output file
    delta_df.to_csv(output_file, index=False, sep='\t', float_format='%.6f')
    
    total_dG_restr = sum(dG_restr_values)
    return dG_restr_values, total_dG_restr

def adjust_angle_difference(delta_angle):
    """
    Adjust the angle difference to be within the range [-180, 180] degrees.
    """
    return delta_angle - 360 * round(delta_angle / 360.0)

def process_dihedral_file(input_file, output_file, ref_values):
    """
    Processes the dihedral angles file, calculates the delta values,
    adjusts for angle wrapping, converts to radians, and calculates
    restraint free energies for dihedral data.
    
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
    
    # Save the delta values to the output file
    delta_df.to_csv(output_file, index=False, sep='\t', float_format='%.6f')
    
    total_dG_restr = sum(dG_restr_values)
    return dG_restr_values, total_dG_restr

# Define paths and reference values
distance_file_path = 'distance.dat'
angle_file_path = 'angles.dat'
dihedral_file_path = 'dihedrals.dat'
distance_output_path = 'delta_distances.dat'
angle_output_path = 'delta_angles_radians.dat'
dihedral_output_path = 'delta_dihedrals_radians.dat'

distance_ref_value = 4.9016  # Example reference value for distance
angle_reference_values = [63.4117, 51.5664]  # Example reference values for angles
dihedral_reference_values = [23.0070, 97.8647, -82.0506]  # Example reference values for dihedrals

# Process each file and print results
dG_restr_distance = process_distance_file(distance_file_path, distance_output_path, distance_ref_value)
print(f'dG_restr for distance: {dG_restr_distance:.6f} kcal/mol')

dG_restr_angles, total_dG_restr_angles = process_angle_file(angle_file_path, angle_output_path, angle_reference_values)
for i, dG in enumerate(dG_restr_angles, start=1):
    print(f'dG_restr for angle {i}: {dG:.6f} kcal/mol')
print(f'Total dG_restr for angles: {total_dG_restr_angles:.6f} kcal/mol')

dG_restr_dihedrals, total_dG_restr_dihedrals = process_dihedral_file(dihedral_file_path, dihedral_output_path, dihedral_reference_values)
for i, dG in enumerate(dG_restr_dihedrals, start=1):
    print(f'dG_restr for dihedral {i}: {dG:.6f} kcal/mol')
print(f'Total dG_restr for dihedrals: {total_dG_restr_dihedrals:.6f} kcal/mol')
#Calculate final restraint free energy value
total_sum_dG_restr = dG_restr_distance + total_dG_restr_angles + total_dG_restr_dihedrals
print(f'Final dG_restr value: {total_sum_dG_restr:.6f} kcal/mol')
