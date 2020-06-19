import numpy as np
import matplotlib.pyplot as plt

plt.rcParams["figure.figsize"] = (10,10)
plt.rcParams.update({'font.size': 14})

with open('farfield.txt') as f:
    lines = f.readlines()
    y = [float(line.split()[0]) for line in lines]

x=np.arange(0.000,6.28318,0.000174532925)

fig = plt.figure()
ax = fig.add_subplot(111, polar=True)
ax.plot(x,y,c='#d62728',linewidth=2)
ax.set_ylim(-15,5)
ax.set_rticks([-15, -10, -5, 0, 5])
ax.set_theta_zero_location("N")

yy=np.multiply(y, 0)
yy=np.add(yy,10)

yhpbw=np.arange(-0.824668072+0.0157079633,0.824668072+0.0157079633,0.000045815)

ax.fill_between(x, -15, y, alpha=0.05, color='#d62728',zorder=20)
ax.fill_between(x, -15, yy, alpha=0.05, color='k',zorder=0)

ax.plot(yhpbw,np.multiply(np.ones(36000),-12),c='royalblue')
ax.plot(x,np.zeros(36000),color='m',zorder=-10, linewidth=1.5)

#HPBW
ax.plot((0,0.824668072+0.0157079633), (-15,1.18), zorder = 0, c='royalblue',linewidth=1.5)
ax.scatter(0.824668072+0.0157079633,1.1, c='royalblue', s=10**2, zorder=10, marker='o')
ax.plot((0,-0.824668072+0.0157079633), (-15,1.18), zorder = 0, c='royalblue',linewidth=1.5)
ax.scatter(-0.824668072+0.0157079633,1.1, c='royalblue', s=10**2, zorder=10, marker='o')

ax.scatter(2.15548163, -5.7, c='#d62728', s=10**2, zorder=10, marker='o')

#Main lobe direction
ax.plot((0,0.0157079633), (-15,4.11), zorder = 0, c='#2ca02c',linewidth=1.5)
ax.scatter(0.0157079633,4.13, c='#2ca02c', s=10**2, zorder=10, marker='o')

plt.text(float(2.76*np.pi)/2, 11.2, '$\mathrm{Frequency}$: $\mathrm{2.43 \ GHz}$\n\n$\mathrm{Gain}$: $\mathrm{4.13 \ dBi}$\n$\mathrm{Main \ lobe \ direction}$: $\mathrm{0.9 \degree}$\n\n$\mathrm{Half}$-$\mathrm{power \ beamwidth}$: $\mathrm{94.5 \degree}$\n$\mathrm{Front}$-$\mathrm{to}$-$\mathrm{back \ ratio}$: $\mathrm{11.93 \ dB}$\n\n$\mathrm{Side \ lobe \ gain}$: $\mathrm{-5.7 \ dBi}$\n$\mathrm{Side \ lobe \ direction}$: $\mathrm{123.5 \degree}$\n\n$\mathrm{Simulation \ Solver}$: $\mathrm{Time \ Domain}$ ', color = 'k', fontsize=20)

plt.title(r'$\mathrm{AcubeSAT \ Patch \ Antenna \ | \ Radiation \ Pattern \ } (\phi = 0 \degree)$'+'\n', fontsize=26, x=0.765)

plt.savefig('farfield.png', bbox_inches='tight')