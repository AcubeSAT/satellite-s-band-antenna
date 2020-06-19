import numpy as np
import matplotlib.pyplot as plt

plt.rcParams["figure.figsize"] = (20,10)
plt.rcParams.update({'font.size': 14})

with open('simulated_data.txt') as f:
    lines = f.readlines()
    x = [1000*float(line.split()[0]) for line in lines]
    y = [line.split()[1] for line in lines]

#with open('measured_data.txt') as f2:
#    lines_m = f2.readlines()
#    x_m = [float(line2.split()[0])/1000000 for line2 in lines_m]
#    y_m = [line2.split()[1] for line2 in lines_m]

plt.plot(x, y, c='royalblue', zorder=5, linewidth=2, label="$S_{11} \ \mathrm{(Simulated)}$")
#plt.plot(x_m, y_m, c='#2ca02c', zorder=10, linewidth=2, label="$S_{11} \ \mathrm{(Measured)}$")
#plt.xticks(np.arange(200, 3000+1, 200))


plt.xlim(0,3000)
plt.ylim(-25,0)
plt.title('$\mathrm{AcubeSAT \ Patch \ Antenna} \ | \ \mathrm{Reflection \ Coefficient} \ (S_{11})$', y=1.01, fontsize=24)
plt.xlabel('$\mathrm{Frequency \ (MHz)}$', fontsize=20)
plt.ylabel('$\mathrm{Magnitude \ (dB)}$', fontsize=20)

#plt.axvline(x=2400, color='brown', linestyle='--', linewidth=2, zorder=15)
plt.axvline(x=2425, color='brown', linestyle='--', linewidth=2, zorder=15)
#plt.axvline(x=2450, color='brown', linestyle='--', linewidth=2, zorder=15)

plt.fill_between([2400,2450], [-25,-25], facecolor='green', alpha=0.2)

plt.axhline(y=-10, color='black', linestyle='--', zorder=1, linewidth=1)
plt.annotate('$\mathrm{Center \ frequency} \ \ \ \ \ \ \ \ f_{0} = 2.425 \mathrm{\ GHz}$', xy=(750, 7), xycoords='axes points', size=18, ha='left', va='bottom', color='brown')

#plt.annotate('$\mathrm{Band \ of \ interest}$', xy=(750, 20), xycoords='axes points', size=18, ha='left', va='bottom', color='green')

plt.text(23.6, -9.7, '$\mathrm{Fractional \ Bandwidth}$: $\mathrm{10.16 \%}$', color = 'forestgreen', fontsize=18)

plt.text(2313-237, -9.8, '$\mathrm{2313 \ MHz}$', color = 'b', fontsize=18)
plt.scatter(2313, -10, c='royalblue', s=10**2, zorder=10, marker='o')
plt.text(2565+25, -9.8, '$\mathrm{2565 \ MHz}$', color = 'b', fontsize=18)
plt.scatter(2565, -10, c='royalblue', s=10**2, zorder=10, marker='o')


plt.text(24, -24.5, '$\mathrm{Simulated \ with \ a \ Time \ Domain \ Solver.}$', color = 'dimgray', fontsize=18)

#plt.fill_between([-100,3000], [-100,-500], facecolor='green', alpha=0.2)

plt.legend(bbox_to_anchor=(0.00, 0.99), loc="upper left")

plt.grid()

#plt.show()

plt.savefig('s11.png', bbox_inches='tight')