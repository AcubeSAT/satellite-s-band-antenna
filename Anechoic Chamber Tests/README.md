# Anechoic Chamber Tests
All the raw data and the test results from the anechoic chamber of the Aristotle University of Thessaloniki can be found here. The U-Slot S-band patch antenna was tested, and two different measurements were done, one getting the antenna pattern and the other calculating the gain in the maximum direction.

## Pattern and Directivity
The raw data of the measurements can be found in the `Raw Data/Antenna Pattern` folder, where there are two `.txt` files containing the angle in the first column and the measured `S21` value in `dB` in the second. The files are delimited with a `tab`. Also, a corresponding MATLAB workspace with the files imported, named `Patch_Antenna_Pattern.mat`, can be found in the `MATLAB Workspaces` folder. There are two files calculating the `directivity` and the `antenna pattern`, one for MATLAB named `directivity_calculation.m` and the other for Jupyter Notebook named `Patch_Antenna_Directivity.ipynb`.

## Gain Measurement With A Reference Standard Gain Horn Antenna
The raw data for the gain can be found in the `Raw Data/Gain Measurement` folder, where the `.txt` files have the frequency of the measurement in the first column and the measured `S21` value in the second. They are delimited by a `tab` and the naming convention is that the direction of the patch and the antenna is denoted after the `S21_horn-` prefix. During this reference measurement the patch antenna was plced on tripod and in the same tripod was placed the standard gain horn antenna too. Due to the fact of the larger dimensions of the horn antenna, there was a displacement of the face of the horn antenna by **r=29cm** in front of the patch antenna, thus giving slightly higher readings. We compensated for that by calculating the value that we need to deduct from the measurement using the Friis law as follows:
```math
S_{21}^{patch} = G_{patch} + G_{horn} + 20\log\Bigig(\dfrac{\lambda}{4\pi(D + r)}\Big)
```
```math
S_{21}^{horn} = 2G_{horn} + 20\log\Big(\dfrac{\lambda}{4\pi D}\Big)
```
and the gain for the patch antenna is calculated as:
```math
S_{21}^{patch} - S_{21}^{horn} = G_{patch} - G_{horn} + 20\log\Big(\dfrac{\lambda}{4\pi(D + r)}\Big) - 20\log\Big(\dfrac{\lambda}{4\pi D}\Big) \Rightarrow
```
```math
\Rightarrow G_{patch} = S_{21}^{patch} - S_{21}^{horn} + G_{horn} + 20(\log(D + r) - \log{D})
```
The total distance of the reference horn from the measurement horn was equal to **D=1.4m**. All the required calculations and the final graphs were done in MATLAB and can be found in the file named `gain_calculation.m`, which requires to import the workspace named `gain_data.mat`, from the `MATLAB Workspaces` folder first.
