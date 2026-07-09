# import numpy as np

# # --- 1. Define Dimensions ---
# Nx = 384 - 12
# Ny = 512 - 12
# Nz = 512 - 12

# # Initialize the volume with 1s (Background). uint8 saves memory.
# vol = np.ones((Nx, Ny, Nz), dtype=np.uint8)

# thickness = 12       # Diameter of the cylinder
# radius = thickness / 2.0

# # 5 uniformly spaced positions 
# # (subtracting 1 to convert MATLAB's 1-based to Python's 0-based index)
# xpos = np.round(np.linspace(40, Nx - thickness - 40, 5)).astype(int) - 1
# ypos = np.round(np.linspace(30, Ny - thickness - 30, 5)).astype(int) - 1

# # --- 2. Create a 3D Cylindrical Mask ---
# # Create a 2D local grid (indexing='ij' matches MATLAB's ndgrid)
# xx, yy = np.meshgrid(np.arange(1, thickness + 1), 
#                      np.arange(1, thickness + 1), 
#                      indexing='ij')
# xc = radius + 0.5
# yc = radius + 0.5

# # 2D circular mask using the circle equation
# circle_mask_2D = ((xx - xc)**2 + (yy - yc)**2) <= radius**2

# # Expand the 2D mask into a 3D cylinder that stretches across the Z axis
# # Add a new axis and repeat it Nz times
# circle_mask_3D = np.repeat(circle_mask_2D[:, :, np.newaxis], Nz, axis=2)

# # --- 3. Place 25 Rods (5x5) ---
# for ky in range(5):
#     # Zig-zag ordering in X as Y increases
#     # In Python, ky=0,2,4 are the "odds" if we compare to MATLAB's 1,3,5
#     if ky % 2 == 0:
#         xorder = list(range(5))          # left -> right
#     else:
#         xorder = list(range(4, -1, -1))  # right -> left
        
#     y = ypos[ky]
    
#     for kx in range(5):
#         x = xpos[xorder[kx]]
        
#         # Extract the current background subvolume (all Z slices)
#         sub_vol = vol[x:x+thickness, y:y+thickness, :]
        
#         # Apply the blood material (2) using boolean masking
#         sub_vol[circle_mask_3D] = 2
        
#         # Place updated subvolume back into the main volume
#         vol[x:x+thickness, y:y+thickness, :] = sub_vol

# # Now 'vol' contains your 3D array

# import pyvista as pv

# # 1. Map the NumPy array to a PyVista spatial grid
# grid = pv.ImageData(dimensions=vol.shape)

# # Flatten in Fortran order ('F') to match PyVista/VTK memory layout
# grid.point_data["Materials"] = vol.flatten(order="F")

# # 2. Extract ONLY the blood rods (where value == 2)
# # We use a threshold to hide the background (1s)
# rods = grid.threshold([1.5, 2.5])

# # 3. Setup the Plotter (Publication Quality)
# plotter = pv.Plotter()
# plotter.background_color = "white"

# # Add the rods to the plot
# plotter.add_mesh(rods, color="red", smooth_shading=True, label="Blood Vessels")

# # Add the "3D Box" (bounding box) around the entire volume space
# plotter.add_mesh(grid.outline(), color="black", line_width=3)

# # Add clear axes and a scale
# plotter.show_axes()
# plotter.add_bounding_box(color="gray", line_width=1)

# # 4. Display and Save
# # Uncomment the line below to save a high-res image for your paper. 
# # scale=3 multiplies the window resolution by 3.
# # plotter.screenshot("volume_render_high_res.png", scale=3) 

# plotter.show()

# # ==========================================================================
# # ==========================================================================


# import numpy as np
# import matplotlib.pyplot as plt
# from skimage import measure
# from itertools import product, combinations

# # --- Define Volume ---
# Nx, Ny, Nz = 384-12, 512-12, 512-12
# vol = np.ones((Nx, Ny, Nz), dtype=np.uint8)

# thickness = 12
# radius = thickness / 2.0

# xpos = np.round(np.linspace(40, Nx - thickness - 40, 5)).astype(int)
# ypos = np.round(np.linspace(30, Ny - thickness - 30, 5)).astype(int)

# # --- Create a 3D Cylindrical Mask ---
# xx, yy = np.mgrid[1:thickness+1, 1:thickness+1]
# xc, yc = radius + 0.5, radius + 0.5
# circle_mask_2D = ((xx - xc)**2 + (yy - yc)**2) <= radius**2
# circle_mask_3D = np.repeat(circle_mask_2D[:, :, np.newaxis], Nz, axis=2)

# # --- Place 25 Rods (5x5) into the Volume ---
# for ky in range(5):
#     if ky % 2 == 0:
#         xorder = range(5)          
#     else:
#         xorder = range(4, -1, -1)  
        
#     y = ypos[ky] - 1
    
#     for kx in range(5):
#         x = xpos[xorder[kx]] - 1
#         sub_vol = vol[x:x+thickness, y:y+thickness, :]
#         sub_vol[circle_mask_3D] = 2

# # ==========================================
# # 3D Visualization (Clean View)
# # ==========================================
# print("Extracting surface for 3D rendering (this may take a moment)...")

# step = 4
# vol_ds = vol[::step, ::step, ::step]

# # Marching Cubes
# verts, faces, normals, values = measure.marching_cubes(vol_ds, level=1.5)
# verts = verts * step  

# # Initialize plot
# fig = plt.figure(figsize=(10, 8))
# ax = fig.add_subplot(111, projection='3d')

# # Plot the rods in green
# ax.plot_trisurf(verts[:, 0], verts[:, 1], faces, verts[:, 2], 
#                 color='green', alpha=0.9, edgecolor='none')

# # Draw the black boundary box
# r_x = [0, Nx]
# r_y = [0, Ny]
# r_z = [0, Nz]

# for s, e in combinations(np.array(list(product(r_x, r_y, r_z))), 2):
#     dist = np.sum(np.abs(s - e))
#     if dist == Nx or dist == Ny or dist == Nz:
#         ax.plot3D(*zip(s, e), color="black", linewidth=1.5)

# # Keep proportional aspect ratio
# ax.set_box_aspect([Nx, Ny, Nz])  

# # --- Remove Axes, Ticks, and Grids ---
# ax.set_axis_off() 

# # Remove extra padding
# plt.tight_layout(pad=0)
# plt.show()



# # ==========================================================================
# # ==========================================================================


import numpy as np
import pyvista as pv

# --- 1. Define Volume ---
Nx, Ny, Nz = 384-12, 512-12, 512-12
vol = np.ones((Nx, Ny, Nz), dtype=np.uint8)

thickness = 12
radius = thickness / 2.0

xpos = np.round(np.linspace(40, Nx - thickness - 40, 5)).astype(int)
ypos = np.round(np.linspace(30, Ny - thickness - 30, 5)).astype(int)

# --- 2. Create Mask ---
xx, yy = np.mgrid[1:thickness+1, 1:thickness+1]
xc, yc = radius + 0.5, radius + 0.5
circle_mask_2D = ((xx - xc)**2 + (yy - yc)**2) <= radius**2
circle_mask_3D = np.repeat(circle_mask_2D[:, :, np.newaxis], Nz, axis=2)

# --- 3. Place Rods ---
for ky in range(5):
    if ky % 2 == 0:
        xorder = range(5)          
    else:
        xorder = range(4, -1, -1)  
        
    y = ypos[ky] - 1
    
    for kx in range(5):
        x = xpos[xorder[kx]] - 1
        sub_vol = vol[x:x+thickness, y:y+thickness, :]
        sub_vol[circle_mask_3D] = 2

# ==========================================
# 3D Visualization using PyVista (FIXED)
# ==========================================
# ==========================================
# 3D Visualization using PyVista (FIXED + SLICE)
# ==========================================
print("Generating 3D render...")

# Wrap the numpy array into a PyVista grid
grid = pv.ImageData()
grid.dimensions = vol.shape 
grid.spacing = (1, 1, 1)
grid.point_data["values"] = vol.flatten(order="F") 

# Extract the surface where value == 2
mesh = grid.contour([1.5], scalars="values")

# Set up the plotter
plotter = pv.Plotter()

# 1. Add the rods (Green, smooth shading)
plotter.add_mesh(mesh, color='green', smooth_shading=True)

# 2. Add a bounding box outline (Black)
plotter.add_mesh(grid.outline(), color='black', line_width=2)

# 3. --- NEW: Highlight Z = 250 slice ---
z_slice = 250
# Create a plane centered in X and Y, sitting at Z = 250
slice_plane = pv.Plane(center=(Nx/2, Ny/2, z_slice), 
                       direction=(0, 0, 1), # Normal vector pointing up Z
                       i_size=Nx, j_size=Ny)

# Plot the plane with a thick blue border and slight blue tint
plotter.add_mesh(slice_plane, 
                 color='blue', 
                 opacity=0.2,       # Slight transparent fill to show the cut
                 show_edges=True,   # Turn on the boundary line
                 edge_color='blue', # Make boundary blue
                 line_width=5)      # Make the boundary thick and visible

# Remove the background grid/axes for a clean view
plotter.set_background('white')
plotter.hide_axes()

# Show the interactive window
plotter.show()
