import pandas as pd
import numpy as np

# Constants
R = 1.9872041e-3  # kcal/(mol·K)
T = 298.15  # Temperature in Kelvin
k = 5.0  # Constant value in kcal/(mol·Å^2) units

def calculate_dG_restr(delta):
    """
    Calculate the restraint free energy for a series of delta distances.
    
    Parameters:
    - delta: Series of delta distance values.
    
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
    and calculates restraint free energies.
    
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
    
    # Print the total dG_restr (for a single series in this case)
    print(f'Total dG_restr: {dG_restr:.6f} kcal/mol')

# Define the reference value for the distance
reference_value = 4.9016  # Example reference value in distance units

# Paths to the input and output files
input_file_path = 'distance.dat'
output_file_path = 'delta_distances.dat'

# Process the distances, calculate delta values, and calculate restraint free energies
process_distance_file(input_file_path, output_file_path, reference_value)

