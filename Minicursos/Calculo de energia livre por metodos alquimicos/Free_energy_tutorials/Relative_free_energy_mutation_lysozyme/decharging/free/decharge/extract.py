import os
import numpy as np
import matplotlib.pyplot as plt

def extract_mean_dvdl_values(directory):
    mean_values = []
    lambda_values = []

    # Iterate over all directories in the working directory
    for folder_name in sorted(os.listdir(directory)):
        folder_path = os.path.join(directory, folder_name)
        if os.path.isdir(folder_path):
            # Define the path to the ti001.out file
            ti001_file = os.path.join(folder_path, 'ti001.out')

            if os.path.isfile(ti001_file):
                with open(ti001_file, 'r') as file:
                    lines = file.readlines()
                
                # Extract numeric values after the line that starts with "Summary of dvdl values"
                start_index = None
                for i, line in enumerate(lines):
                    if line.startswith("Summary of dvdl values"):
                        start_index = i + 1
                        break
                
                if start_index is not None:
                    # Collect numeric values from the file
                    values = []
                    for line in lines[start_index:]:
                        stripped_line = line.strip()
                        if stripped_line:
                            try:
                                value = float(stripped_line)
                                values.append(value)
                            except ValueError:
                                continue
                    
                    # Calculate the mean of the extracted values
                    if values:
                        mean_value = np.mean(values)
                        mean_values.append(mean_value)
                        lambda_values.append(float(folder_name))
    
    return lambda_values, mean_values

def plot_and_integrate(lambda_values, mean_values):
    # Plotting the values
    plt.figure(figsize=(4, 2), dpi=300)
    plt.plot(lambda_values, mean_values, marker='o', linestyle='-', color='b', markersize=4)  # Reduce dot size
    
    # Shade the area between the curve and the x-axis
    plt.fill_between(lambda_values, mean_values, color='lightblue', alpha=0.5)
    
    # Customizing the plot
    plt.xlabel(r'$\lambda$')
    plt.ylabel(r'$\frac{\partial V}{\partial \lambda}$ (kcal/mol)')
    
    # Set x-ticks to strides of 0.2 and minor ticks in between
    x_ticks = np.arange(min(lambda_values), max(lambda_values) + 0.2, 0.2)
    plt.xticks(x_ticks)
    plt.gca().xaxis.set_minor_locator(plt.MultipleLocator(0.05))
    
    # Adjust the y-axis range
    min_y = min(mean_values)
    max_y = max(mean_values)
    
    # Ensure the y-axis spans at least over 10 units
    if abs(max_y - min_y) < 10:
        range_span = 10 - (max_y - min_y)
        min_y -= range_span / 2
        max_y += range_span / 2
    
    # Ensure y-axis includes 0
    if min_y > 0:
        min_y = 0
    elif max_y < 0:
        max_y = 0
    
    plt.ylim(min_y, max_y)
    
    # Set y-ticks with a stride of 5 units
    y_tick_min = int(np.floor(min_y / 5) * 5)
    y_tick_max = int(np.ceil(max_y / 5) * 5)
    plt.yticks(np.arange(y_tick_min, y_tick_max + 5, 5))
    
    # Set minor ticks for y-axis with no labels
    plt.gca().yaxis.set_minor_locator(plt.MultipleLocator(1))
    plt.tick_params(axis='y', which='minor', length=4, color='gray')
    
    # Calculate the integral under the curve
    integral = np.trapz(mean_values, lambda_values)
    
    # Annotate the integral value on the plot
    plt.text(1, max_y - 0.06 * (max_y - min_y), 
             f'ΔG = {integral:.4f} kcal/mol', 
             horizontalalignment='right', 
             verticalalignment='top',
             fontsize=10)  # Adjust the font size here
    
    # Save the plot as a TIFF file
    plt.savefig('dvdl_vs_lambda.tiff', format='tiff', bbox_inches='tight', dpi=300)
    plt.show()

    print(f"Integral under the curve (from lambda 0 to 1): {integral:.4f}")

# Usage
working_directory = '.'  # Set your working directory path here
lambda_values, mean_values = extract_mean_dvdl_values(working_directory)
plot_and_integrate(lambda_values, mean_values)

