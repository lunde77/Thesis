# Reverse the X and Y axes
ax.set_xlim(1440, 0)
ax.set_ylim(7500, 0)
ax.autoscale(enable=False, axis='both', tight=True)

ax.grid(False)
ax.xaxis.pane.fill = True  # Removes the pane background
ax.yaxis.pane.fill = True
ax.zaxis.pane.fill = False
ax.zaxis.set_ticklabels([])
ax.zaxis.set_ticks([])
ax.set_facecolor('white')
ax.w_xaxis.set_pane_color((1.0, 1.0, 1.0, 0.0))
ax.w_yaxis.set_pane_color((1.0, 1.0, 1.0, 0.0))
ax.w_zaxis.set_pane_color((1.0, 1.0, 1.0, 0.0))
# Plot the surface
colormap = cm.viridis
norm = colors.Normalize(vmin=Z.min(), vmax=Z.max())

# Plot the surface with the new colormap and normalization
surf = ax.plot_surface(X, Y, Z, cmap=colormap, norm=norm, rstride=1, cstride=1, antialiased=True, alpha=0.5)

# Create a colorbar with a label
cbar = fig.colorbar(surf, shrink=0.5, aspect=5)
cbar.set_label('Probability Density')


ax.plot(x, line1_y_values, line1_Z, color='r', linewidth=3, label='LER requeriment', zorder=5, alpha=0.9)
ax.plot(x, line2_y_values, line2_Z, color='b', linewidth=3, label='Non-LER bid requriments', zorder=5, alpha=0.9)


# Set the labels
ax.set_xlabel('Minute of Day')
ax.set_ylabel('KW')
#ax.set_zlabel('Probability')
# Remove the Z-axis

# Add legend
ax.legend()
ax.view_init(elev=90, azim=270)


# Show the plot
plt.show()