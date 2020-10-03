'# MWS Version: Version 2017.0 - Jan 13 2017 - ACIS 26.0.1 -

'# length = mm
'# frequency = GHz
'# time = ns
'# frequency range: fmin = 1 fmax = 3
'# created = '[VERSION]2017.0|26.0.1|20170113[/VERSION]


'@ use template: Antenna - Planar_8.cfg

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
'set the units
With Units
    .Geometry "mm"
    .Frequency "GHz"
    .Voltage "V"
    .Resistance "Ohm"
    .Inductance "NanoH"
    .TemperatureUnit  "Kelvin"
    .Time "ns"
    .Current "A"
    .Conductance "Siemens"
    .Capacitance "PikoF"
End With
'----------------------------------------------------------------------------
Plot.DrawBox True
With Background
     .Type "Normal"
     .Epsilon "1.0"
     .Mu "1.0"
     .XminSpace "0.0"
     .XmaxSpace "0.0"
     .YminSpace "0.0"
     .YmaxSpace "0.0"
     .ZminSpace "0.0"
     .ZmaxSpace "0.0"
End With
With Boundary
     .Xmin "expanded open"
     .Xmax "expanded open"
     .Ymin "expanded open"
     .Ymax "expanded open"
     .Zmin "expanded open"
     .Zmax "expanded open"
     .Xsymmetry "none"
     .Ysymmetry "none"
     .Zsymmetry "none"
End With
' optimize mesh settings for planar structures
With Mesh
     .MergeThinPECLayerFixpoints "True"
     .RatioLimit "20"
     .AutomeshRefineAtPecLines "True", "6"
     .FPBAAvoidNonRegUnite "True"
     .ConsiderSpaceForLowerMeshLimit "False"
     .MinimumStepNumber "5"
     .AnisotropicCurvatureRefinement "True"
     .AnisotropicCurvatureRefinementFSM "True"
End With
With MeshSettings
     .SetMeshType "Hex"
     .Set "RatioLimitGeometry", "20"
     .Set "EdgeRefinementOn", "1"
     .Set "EdgeRefinementRatio", "6"
End With
With MeshSettings
     .SetMeshType "HexTLM"
     .Set "RatioLimitGeometry", "20"
End With
With MeshSettings
     .SetMeshType "Tet"
     .Set "VolMeshGradation", "1.5"
     .Set "SrfMeshGradation", "1.5"
End With
' change mesh adaption scheme to energy
' 		(planar structures tend to store high energy
'     	 locally at edges rather than globally in volume)
MeshAdaption3D.SetAdaptionStrategy "Energy"
' switch on FD-TET setting for accurate farfields
FDSolver.ExtrudeOpenBC "True"
PostProcess1D.ActivateOperation "vswr", "true"
PostProcess1D.ActivateOperation "yz-matrices", "true"
With FarfieldPlot
	.ClearCuts ' lateral=phi, polar=theta
	.AddCut "lateral", "0", "1"
	.AddCut "lateral", "90", "1"
	.AddCut "polar", "90", "1"
End With
'----------------------------------------------------------------------------
'set the frequency range
Solver.FrequencyRange "1", "3"
Dim sDefineAt As String
sDefineAt = "1.26;2.45;3"
Dim sDefineAtName As String
sDefineAtName = "1.26;2.45;3"
Dim sDefineAtToken As String
sDefineAtToken = "f="
Dim aFreq() As String
aFreq = Split(sDefineAt, ";")
Dim aNames() As String
aNames = Split(sDefineAtName, ";")
Dim nIndex As Integer
For nIndex = LBound(aFreq) To UBound(aFreq)
Dim zz_val As String
zz_val = aFreq (nIndex)
Dim zz_name As String
zz_name = sDefineAtToken & aNames (nIndex)
' Define E-Field Monitors
With Monitor
    .Reset
    .Name "e-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Efield"
    .Frequency zz_val
    .Create
End With
' Define H-Field Monitors
With Monitor
    .Reset
    .Name "h-field ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Hfield"
    .Frequency zz_val
    .Create
End With
' Define Power flow Monitors
With Monitor
    .Reset
    .Name "power ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Powerflow"
    .Frequency zz_val
    .Create
End With
' Define Power loss Monitors
With Monitor
    .Reset
    .Name "loss ("& zz_name &")"
    .Dimension "Volume"
    .Domain "Frequency"
    .FieldType "Powerloss"
    .Frequency zz_val
    .Create
End With
' Define Farfield Monitors
With Monitor
    .Reset
    .Name "farfield ("& zz_name &")"
    .Domain "Frequency"
    .FieldType "Farfield"
    .Frequency zz_val
    .ExportFarfieldSource "False"
    .Create
End With
Next
'----------------------------------------------------------------------------
With MeshSettings
     .SetMeshType "Hex"
     .Set "Version", 1%
End With
With Mesh
     .MeshType "PBA"
End With
'set the solver type
ChangeSolverType("HF Time Domain")

'@ new component: component1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Component.New "component1"

'@ define brick: component1:gnd

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Brick
     .Reset 
     .Name "gnd" 
     .Component "component1" 
     .Material "PEC" 
     .Xrange "-Lg/2", "Lg/2" 
     .Yrange "-Lg/2", "Lg/2" 
     .Zrange "0", "sg" 
     .Create
End With

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:gnd", "1"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define material: FR-4 (lossy)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material
     .Reset
     .Name "FR-4 (lossy)"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .SetMaterialUnit "GHz", "mm"
     .Epsilon "4.3"
     .Mu "1.0"
     .Kappa "0.0"
     .TanD "0.025"
     .TanDFreq "10.0"
     .TanDGiven "True"
     .TanDModel "ConstTanD"
     .KappaM "0.0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstKappa"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "General 1st"
     .DispersiveFittingSchemeMu "General 1st"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .Rho "0.0"
     .ThermalType "Normal"
     .ThermalConductivity "0.3"
     .SetActiveMaterial "all"
     .Colour "0.94", "0.82", "0.76"
     .Wireframe "False"
     .Transparency "0"
     .Create
End With

'@ define brick: component1:substrate

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Brick
     .Reset 
     .Name "substrate" 
     .Component "component1" 
     .Material "FR-4 (lossy)" 
     .Xrange "-Lg/2", "Lg/2" 
     .Yrange "-Lg/2", "Lg/2" 
     .Zrange "g", "2*h+g" 
     .Create
End With

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:substrate", "1"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define brick: component1:patch

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Brick
     .Reset 
     .Name "patch" 
     .Component "component1" 
     .Material "PEC" 
     .Xrange "-Lp/2", "Lp/2" 
     .Yrange "-Lp/2", "Lp/2" 
     .Zrange "0", "sg" 
     .Create
End With

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "2"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define cylinder: component1:feed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Cylinder 
     .Reset 
     .Name "feed" 
     .Component "component1" 
     .Material "PEC" 
     .OuterRadius "rad" 
     .InnerRadius "0.0" 
     .Axis "z" 
     .Zrange "-h", "+sg+g+h+10" 
     .Xcenter "xfeed" 
     .Ycenter "-yfeed" 
     .Segments "0" 
     .Create 
End With

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:feed", "1"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define material: Air

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material
     .Reset
     .Name "Air"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .SetMaterialUnit "Hz", "mm"
     .Epsilon "1.00059"
     .Mu "1.0"
     .Kappa "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstKappa"
     .KappaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstKappa"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "General 1st"
     .DispersiveFittingSchemeMu "General 1st"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .Rho "1.204"
     .DynamicViscosity "1.84e-5"
     .ThermalType "Normal"
     .ThermalConductivity "0.026"
     .HeatCapacity "1.005"
     .SetActiveMaterial "all"
     .Colour "0.682353", "0.717647", "1"
     .Wireframe "False"
     .Transparency "0"
     .Create
End With

'@ define cylinder: component1:dielectric coaxial

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Cylinder 
     .Reset 
     .Name "dielectric coaxial" 
     .Component "component1" 
     .Material "Air" 
     .OuterRadius "outer_rad" 
     .InnerRadius "rad" 
     .Axis "z" 
     .Zrange "0", "-10-sg" 
     .Xcenter "xfeed" 
     .Ycenter "yfeed" 
     .Segments "0" 
     .Create 
End With

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:dielectric coaxial", "2"

'@ define extrude: component1:outercond

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Extrude 
     .Reset 
     .Name "outercond" 
     .Component "component1" 
     .Material "PEC" 
     .Mode "Picks" 
     .Height "sg" 
     .Twist "0.0" 
     .Taper "0.0" 
     .UsePicksForHeight "False" 
     .DeleteBaseFaceSolid "False" 
     .ClearPickedFace "True" 
     .Create 
End With

'@ delete shape: component1:dielectric coaxial

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:dielectric coaxial"

'@ delete shape: component1:outercond

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:outercond"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:feed", "3"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define cylinder: component1:dielectric coaxial

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Cylinder 
     .Reset 
     .Name "dielectric coaxial" 
     .Component "component1" 
     .Material "Air" 
     .OuterRadius "outer_rad" 
     .InnerRadius "rad" 
     .Axis "z" 
     .Zrange "0", "-sg-10" 
     .Xcenter "0" 
     .Ycenter "0" 
     .Segments "0" 
     .Create 
End With

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:dielectric coaxial", "2"

'@ define extrude: component1:outer_cond

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Extrude 
     .Reset 
     .Name "outer_cond" 
     .Component "component1" 
     .Material "PEC" 
     .Mode "Picks" 
     .Height "sg" 
     .Twist "0.0" 
     .Taper "0.0" 
     .UsePicksForHeight "False" 
     .DeleteBaseFaceSolid "False" 
     .ClearPickedFace "True" 
     .Create 
End With

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ boolean insert shapes: component1:gnd, component1:feed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Insert "component1:gnd", "component1:feed"

'@ boolean insert shapes: component1:gnd, component1:dielectric coaxial

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Insert "component1:gnd", "component1:dielectric coaxial"

'@ boolean insert shapes: component1:gnd, component1:outer_cond

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Insert "component1:gnd", "component1:outer_cond"

'@ boolean insert shapes: component1:substrate, component1:feed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Insert "component1:substrate", "component1:feed"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:dielectric coaxial", "3"

'@ define port: 1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Port 
     .Reset 
     .PortNumber "1" 
     .Label "" 
     .NumberOfModes "1" 
     .AdjustPolarization "False" 
     .PolarizationAngle "0.0" 
     .ReferencePlaneDistance "0" 
     .TextSize "50" 
     .TextMaxLimit "0" 
     .Coordinates "Picks" 
     .Orientation "positive" 
     .PortOnBound "False" 
     .ClipPickedPortToBound "False" 
     .Xrange "-1.75", "1.75" 
     .Yrange "-1.75", "1.75" 
     .Zrange "-10", "-10" 
     .XrangeAdd "0.0", "0.0" 
     .YrangeAdd "0.0", "0.0" 
     .ZrangeAdd "0.0", "0.0" 
     .SingleEnded "False" 
     .Create 
End With

'@ define time domain solver parameters

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Mesh.SetCreator "High Frequency" 
With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ set mesh properties (Hexahedral)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Mesh 
     .MeshType "PBA" 
     .SetCreator "High Frequency"
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "Version", 1%
     'MAX CELL - WAVELENGTH REFINEMENT 
     .Set "StepsPerWaveNear", "8" 
     .Set "StepsPerWaveFar", "8" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "8" 
     .Set "StepsPerBoxFar", "1" 
     .Set "MaxStepNear", "0" 
     .Set "MaxStepFar", "0" 
     .Set "ModelBoxDescrNear", "maxedge" 
     .Set "ModelBoxDescrFar", "maxedge" 
     .Set "UseMaxStepAbsolute", "0" 
     .Set "GeometryRefinementSameAsNear", "0" 
     'MIN CELL 
     .Set "UseRatioLimitGeometry", "1" 
     .Set "RatioLimitGeometry", "20" 
     .Set "MinStepGeometryX", "0" 
     .Set "MinStepGeometryY", "0" 
     .Set "MinStepGeometryZ", "0" 
     .Set "UseSameMinStepGeometryXYZ", "1" 
End With 
With MeshSettings 
     .Set "PlaneMergeVersion", "2" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "FaceRefinementOn", "0" 
     .Set "FaceRefinementPolicy", "2" 
     .Set "FaceRefinementRatio", "2" 
     .Set "FaceRefinementStep", "0" 
     .Set "FaceRefinementNSteps", "2" 
     .Set "EllipseRefinementOn", "0" 
     .Set "EllipseRefinementPolicy", "2" 
     .Set "EllipseRefinementRatio", "2" 
     .Set "EllipseRefinementStep", "0" 
     .Set "EllipseRefinementNSteps", "2" 
     .Set "FaceRefinementBufferLines", "3" 
     .Set "EdgeRefinementOn", "1" 
     .Set "EdgeRefinementPolicy", "1" 
     .Set "EdgeRefinementRatio", "6" 
     .Set "EdgeRefinementStep", "0" 
     .Set "EdgeRefinementBufferLines", "3" 
     .Set "RefineEdgeMaterialGlobal", "0" 
     .Set "RefineAxialEdgeGlobal", "0" 
     .Set "BufferLinesNear", "3" 
     .Set "UseDielectrics", "1" 
     .Set "EquilibrateOn", "0" 
     .Set "Equilibrate", "1.5" 
     .Set "IgnoreThinPanelMaterial", "0" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "SnapToAxialEdges", "1"
     .Set "SnapToPlanes", "1"
     .Set "SnapToSpheres", "1"
     .Set "SnapToEllipses", "1"
     .Set "SnapToCylinders", "1"
     .Set "SnapToCylinderCenters", "1"
     .Set "SnapToEllipseCenters", "1"
End With 
With Discretizer 
     .ConnectivityCheck "False"
     .UsePecEdgeModel "True" 
     .GapDetection "False" 
     .FPBAGapTolerance "1e-3" 
     .PointAccEnhancement "0" 
End With

'@ create group: meshgroup1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Group.Add "meshgroup1", "mesh"

'@ set local mesh properties for: meshgroup1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With MeshSettings
     With .ItemMeshSettings ("group$meshgroup1")
          .SetMeshType "Hex"
          .Set "EdgeRefinement", "1"
          .Set "Extend", "0", "0", "0"
          .Set "Fixpoints", 1
          .Set "MeshType", "Default"
          .Set "NumSteps", "0", "0", "0"
          .Set "Priority", "0"
          .Set "RefinementPolicy", "ABS_VALUE"
          .Set "SnappingIntervals", 0, 0, 0
          .Set "SnappingPriority", 0
          .Set "SnapTo", "1", "1", "1"
          .Set "Step", "0.8", "0.8", "0.8"
          .Set "StepRatio", "0", "0", "0"
          .Set "UseDielectrics", 1
          .Set "UseEdgeRefinement", 0
          .Set "UseForRefinement", 1
          .Set "UseForSnapping", 1
          .Set "UseSameExtendXYZ", 0
          .Set "UseSameStepWidthXYZ", 1
          .Set "UseSnappingPriority", 0
          .Set "UseStepAndExtend", 1
          .Set "UseVolumeRefinement", 0
          .Set "VolumeRefinement", "1"
     End With
End With

'@ add items to group: "meshgroup1"

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Group.AddItem "solid$component1:feed", "meshgroup1"

'@ set local mesh properties for: meshgroup1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With MeshSettings
     With .ItemMeshSettings ("group$meshgroup1")
          .SetMeshType "Hex"
          .Set "EdgeRefinement", "1"
          .Set "Extend", "0", "0", "0"
          .Set "Fixpoints", 1
          .Set "MeshType", "Default"
          .Set "NumSteps", "0", "0", "0"
          .Set "Priority", "0"
          .Set "RefinementPolicy", "ABS_VALUE"
          .Set "SnappingIntervals", 0, 0, 0
          .Set "SnappingPriority", 0
          .Set "SnapTo", "1", "1", "1"
          .Set "Step", "1", "1", "1"
          .Set "StepRatio", "0", "0", "0"
          .Set "UseDielectrics", 1
          .Set "UseEdgeRefinement", 0
          .Set "UseForRefinement", 1
          .Set "UseForSnapping", 1
          .Set "UseSameExtendXYZ", 0
          .Set "UseSameStepWidthXYZ", 1
          .Set "UseSnappingPriority", 0
          .Set "UseStepAndExtend", 1
          .Set "UseVolumeRefinement", 0
          .Set "VolumeRefinement", "1"
     End With
End With

'@ define farfield monitor: farfield (f=2.6)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.6)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.6" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-37.5", "37.5", "-37.5", "37.5", "-10", "5.12" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "3" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "2"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define curve polygon: curve1:polygon1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Polygon 
     .Reset 
     .Name "polygon1" 
     .Curve "curve1" 
     .Point "Lp/2-11.6", "Lp/2" 
     .LineTo "Lp/2", "Lp/2" 
     .LineTo "Lp/2", "Lp/2-11.6" 
     .LineTo "Lp/2-11.6", "Lp/2" 
     .Create 
End With

'@ define extrudeprofile: component1:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ExtrudeCurve
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "PEC" 
     .Thickness "sg" 
     .Twistangle "0.0" 
     .Taperangle "0.0" 
     .DeleteProfile "True" 
     .Curve "curve1:polygon1" 
     .Create
End With

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ transform: mirror component1:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:solid1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "0", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Mirror" 
End With

'@ transform: mirror component1:solid1_1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:solid1_1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "0", "-1", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Mirror" 
End With

'@ delete shape: component1:solid1_1_1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:solid1_1_1"

'@ transform: mirror component1:solid1_1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:solid1_1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "-1", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Mirror" 
End With

'@ delete shape: component1:solid1_1_1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:solid1_1_1"

'@ transform: mirror component1:solid1_1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:solid1_1" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .PlaneNormal "1", "1", "0" 
     .MultipleObjects "True" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Destination "" 
     .Material "" 
     .Transform "Shape", "Mirror" 
End With

'@ delete shape: component1:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:solid1"

'@ boolean subtract shapes: component1:patch, component1:solid1_1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Subtract "component1:patch", "component1:solid1_1"

'@ boolean subtract shapes: component1:patch, component1:solid1_1_1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Subtract "component1:patch", "component1:solid1_1_1"

'@ define monitor: e-field (f=1.821)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=1.821)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .Frequency "1.821" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-47.3", "47.3", "-47.3", "47.3", "-10", "5.12" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .Create 
End With

'@ define monitor: e-field (f=1.8138)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Delete "e-field (f=1.821)" 
End With 
With Monitor 
     .Reset 
     .Name "e-field (f=1.8138)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .Frequency "1.8138" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-47.3", "47.3", "-47.3", "47.3", "-10", "5.12" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .Create 
End With

'@ define farfield monitor: farfield (f=1.8138)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Delete "e-field (f=1.8138)" 
End With 
With Monitor 
     .Reset 
     .Name "farfield (f=1.8138)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "1.8138" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-47.3", "47.3", "-47.3", "47.3", "-10", "5.12" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Efield" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ define monitor: e-field (f=1.8138)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=1.8138)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .Frequency "1.8138" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-47.3", "47.3", "-47.3", "47.3", "-10", "5.12" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Efield" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ set parametersweep options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
    .SetSimulationType "Transient" 
End With

'@ add parsweep sequence: Sequence 1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 1" 
End With

'@ add parsweep parameter: Sequence 1:g

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 1", "g", "11.275", "22.55", "5" 
End With

'@ set mesh properties (Hexahedral)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Mesh 
     .MeshType "PBA" 
     .SetCreator "High Frequency"
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "Version", 1%
     'MAX CELL - WAVELENGTH REFINEMENT 
     .Set "StepsPerWaveNear", "7" 
     .Set "StepsPerWaveFar", "7" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "7" 
     .Set "StepsPerBoxFar", "1" 
     .Set "MaxStepNear", "0" 
     .Set "MaxStepFar", "0" 
     .Set "ModelBoxDescrNear", "maxedge" 
     .Set "ModelBoxDescrFar", "maxedge" 
     .Set "UseMaxStepAbsolute", "0" 
     .Set "GeometryRefinementSameAsNear", "0" 
     'MIN CELL 
     .Set "UseRatioLimitGeometry", "1" 
     .Set "RatioLimitGeometry", "20" 
     .Set "MinStepGeometryX", "0" 
     .Set "MinStepGeometryY", "0" 
     .Set "MinStepGeometryZ", "0" 
     .Set "UseSameMinStepGeometryXYZ", "1" 
End With 
With MeshSettings 
     .Set "PlaneMergeVersion", "2" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "FaceRefinementOn", "0" 
     .Set "FaceRefinementPolicy", "2" 
     .Set "FaceRefinementRatio", "2" 
     .Set "FaceRefinementStep", "0" 
     .Set "FaceRefinementNSteps", "2" 
     .Set "EllipseRefinementOn", "0" 
     .Set "EllipseRefinementPolicy", "2" 
     .Set "EllipseRefinementRatio", "2" 
     .Set "EllipseRefinementStep", "0" 
     .Set "EllipseRefinementNSteps", "2" 
     .Set "FaceRefinementBufferLines", "3" 
     .Set "EdgeRefinementOn", "1" 
     .Set "EdgeRefinementPolicy", "1" 
     .Set "EdgeRefinementRatio", "6" 
     .Set "EdgeRefinementStep", "0" 
     .Set "EdgeRefinementBufferLines", "3" 
     .Set "RefineEdgeMaterialGlobal", "0" 
     .Set "RefineAxialEdgeGlobal", "0" 
     .Set "BufferLinesNear", "3" 
     .Set "UseDielectrics", "1" 
     .Set "EquilibrateOn", "0" 
     .Set "Equilibrate", "1.5" 
     .Set "IgnoreThinPanelMaterial", "0" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "SnapToAxialEdges", "1"
     .Set "SnapToPlanes", "1"
     .Set "SnapToSpheres", "1"
     .Set "SnapToEllipses", "1"
     .Set "SnapToCylinders", "1"
     .Set "SnapToCylinderCenters", "1"
     .Set "SnapToEllipseCenters", "1"
End With 
With Discretizer 
     .ConnectivityCheck "False"
     .UsePecEdgeModel "True" 
     .GapDetection "False" 
     .FPBAGapTolerance "1e-3" 
     .PointAccEnhancement "0" 
End With

'@ delete shape: component1:patch

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:patch"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:substrate", "4"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define curve polygon: curve1:patch

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Polygon 
     .Reset 
     .Name "patch" 
     .Curve "curve1" 
     .Point "-Lp/2", "Lp/2" 
     .LineTo "Lp/2-Lt", "Lp/2" 
     .LineTo "Lp/2", "Lp/2-Lt" 
     .LineTo "Lp/2", "-Lp/2" 
     .LineTo "-(Lp/2-Lt)", "-Lp/2" 
     .LineTo "-Lp/2", "-(Lp/2-Lt)" 
     .LineTo "-Lp/2", "Lp/2" 
     .Create 
End With

'@ define extrudeprofile: component1:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ExtrudeCurve
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "PEC" 
     .Thickness "sg" 
     .Twistangle "0.0" 
     .Taperangle "0.0" 
     .DeleteProfile "False" 
     .Curve "curve1:patch" 
     .Create
End With

'@ delete shape: component1:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:solid1"

'@ define extrudeprofile: component1:patch

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ExtrudeCurve
     .Reset 
     .Name "patch" 
     .Component "component1" 
     .Material "PEC" 
     .Thickness "-sg" 
     .Twistangle "0.0" 
     .Taperangle "0.0" 
     .DeleteProfile "False" 
     .Curve "curve1:patch" 
     .Create
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Pfield" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ define farfield monitor: farfield (broadband)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (broadband)" 
     .Domain "Time" 
     .Accuracy "1e-3" 
     .FrequencySamples "21" 
     .FieldType "Farfield" 
     .Frequency "2" 
     .TransientFarfield "False" 
     .ExportFarfieldSource "False" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ delete parsweep parameter: Sequence 1:g

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "g" 
End With

'@ add parsweep parameter: Sequence 1:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 1", "yfeed", "15.975", "31.95", "4" 
End With

'@ add parsweep sequence: Sequence 2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 2" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ edit parsweep parameter: Sequence 1:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "yfeed" 
     .AddParameter_Linear "Sequence 1", "yfeed", "15.975", "31.95", "10" 
End With

'@ add parsweep parameter: Sequence 2:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 2", "Lt", "7", "12", "6" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ delete parsweep parameter: Sequence 1:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "yfeed" 
End With

'@ delete parsweep parameter: Sequence 2:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 2", "Lt" 
End With

'@ define curve polygon: curve1:slit

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Polygon 
     .Reset 
     .Name "slit" 
     .Curve "curve1" 
     .Point "-W1/2", "Lp/2" 
     .LineTo "-W1/2", "Lp/2-ly" 
     .LineTo "W1/2", "Lp/2-ly" 
     .LineTo "W1/2", "Lp/2" 
     .LineTo "-W1/2", "Lp/2" 
     .Create 
End With

'@ set wcs properties

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With WCS
     .SetNormal "0", "0", "1"
     .SetOrigin "0", "-0.0068419897213824", "1.61"
     .SetUVector "1", "0", "0"
End With

'@ define extrudeprofile: component1:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ExtrudeCurve
     .Reset 
     .Name "solid1" 
     .Component "component1" 
     .Material "PEC" 
     .Thickness "sg" 
     .Twistangle "0.0" 
     .Taperangle "0.0" 
     .DeleteProfile "True" 
     .Curve "curve1:slit" 
     .Create
End With

'@ delete shape: component1:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:solid1"

''@ boolean subtract shapes: component1:patch, component1:solid1
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'Solid.Subtract "component1:patch", "component1:solid1"
'
''@ farfield plot options
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'With FarfieldPlot 
'     .Plottype "Polar" 
'     .Vary "angle1" 
'     .Theta "90" 
'     .Phi "90" 
'     .Step "1" 
'     .Step2 "1" 
'     .SetLockSteps "True" 
'     .SetPlotRangeOnly "False" 
'     .SetThetaStart "0" 
'     .SetThetaEnd "180" 
'     .SetPhiStart "0" 
'     .SetPhiEnd "360" 
'     .SetTheta360 "False" 
'     .SymmetricRange "False" 
'     .SetTimeDomainFF "False" 
'     .SetFrequency "1.8138" 
'     .SetTime "0" 
'     .SetColorByValue "True" 
'     .DrawStepLines "False" 
'     .DrawIsoLongitudeLatitudeLines "False" 
'     .ShowStructure "False" 
'     .ShowStructureProfile "False" 
'     .SetStructureTransparent "False" 
'     .SetFarfieldTransparent "False" 
'     .SetSpecials "enablepolarextralines" 
'     .SetPlotMode "Realized Gain" 
'     .Distance "1" 
'     .UseFarfieldApproximation "True" 
'     .SetScaleLinear "False" 
'     .SetLogRange "40" 
'     .SetLogNorm "0" 
'     .DBUnit "0" 
'     .EnableFixPlotMaximum "False" 
'     .SetFixPlotMaximumValue "1" 
'     .SetInverseAxialRatio "False" 
'     .SetAxesType "user" 
'     .SetAntennaType "unknown" 
'     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
'     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
'     .SetCoordinateSystemType "ludwig3" 
'     .SetAutomaticCoordinateSystem "True" 
'     .SetPolarizationType "Circular" 
'     .SlantAngle 0.000000e+00 
'     .Origin "bbox" 
'     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .SetUserDecouplingPlane "False" 
'     .UseDecouplingPlane "False" 
'     .DecouplingPlaneAxis "X" 
'     .DecouplingPlanePosition "0.000000e+00" 
'     .LossyGround "False" 
'     .GroundEpsilon "1" 
'     .GroundKappa "0" 
'     .EnablePhaseCenterCalculation "False" 
'     .SetPhaseCenterAngularLimit "3.000000e+01" 
'     .SetPhaseCenterComponent "boresight" 
'     .SetPhaseCenterPlane "both" 
'     .ShowPhaseCenter "True" 
'     .ClearCuts 
'     .AddCut "lateral", "0", "1"  
'     .AddCut "lateral", "90", "1"  
'     .AddCut "polar", "90", "1"  
'     .StoreSettings
'End With
'
''@ delete monitor: farfield (f=3)
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'Monitor.Delete "farfield (f=3)"
'
''@ define farfield monitor: farfield (f=1.747)
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'With Monitor 
'     .Reset 
'     .Name "farfield (f=1.747)" 
'     .Domain "Frequency" 
'     .FieldType "Farfield" 
'     .Frequency "1.747" 
'     .ExportFarfieldSource "False" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-27.35", "27.35", "-27.35", "27.35", "-10", "1.62" 
'     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
'     .SetSubvolumeOffsetType "FractionOfWavelength" 
'     .Create 
'End With
'
''@ define monitor: e-field (f=1.747)
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'With Monitor 
'     .Delete "farfield (f=1.747)" 
'End With 
'With Monitor 
'     .Reset 
'     .Name "e-field (f=1.747)" 
'     .Dimension "Volume" 
'     .Domain "Frequency" 
'     .FieldType "Efield" 
'     .Frequency "1.747" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-27.35", "27.35", "-27.35", "27.35", "-10", "1.62" 
'     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
'     .Create 
'End With
'
''@ define farfield monitor: farfield (f=1.747)
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'With Monitor 
'     .Reset 
'     .Name "farfield (f=1.747)" 
'     .Domain "Frequency" 
'     .FieldType "Farfield" 
'     .Frequency "1.747" 
'     .ExportFarfieldSource "False" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-27.35", "27.35", "-27.35", "27.35", "-10", "1.62" 
'     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
'     .SetSubvolumeOffsetType "FractionOfWavelength" 
'     .Create 
'End With
'
''@ farfield plot options
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'With FarfieldPlot 
'     .Plottype "Cartesian" 
'     .Vary "angle1" 
'     .Theta "90" 
'     .Phi "90" 
'     .Step "1" 
'     .Step2 "1" 
'     .SetLockSteps "True" 
'     .SetPlotRangeOnly "False" 
'     .SetThetaStart "0" 
'     .SetThetaEnd "180" 
'     .SetPhiStart "0" 
'     .SetPhiEnd "360" 
'     .SetTheta360 "False" 
'     .SymmetricRange "False" 
'     .SetTimeDomainFF "False" 
'     .SetFrequency "1.8138" 
'     .SetTime "0" 
'     .SetColorByValue "True" 
'     .DrawStepLines "False" 
'     .DrawIsoLongitudeLatitudeLines "False" 
'     .ShowStructure "False" 
'     .ShowStructureProfile "False" 
'     .SetStructureTransparent "False" 
'     .SetFarfieldTransparent "False" 
'     .SetSpecials "enablepolarextralines" 
'     .SetPlotMode "Realized Gain" 
'     .Distance "1" 
'     .UseFarfieldApproximation "True" 
'     .SetScaleLinear "False" 
'     .SetLogRange "40" 
'     .SetLogNorm "0" 
'     .DBUnit "0" 
'     .EnableFixPlotMaximum "False" 
'     .SetFixPlotMaximumValue "1" 
'     .SetInverseAxialRatio "False" 
'     .SetAxesType "user" 
'     .SetAntennaType "unknown" 
'     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
'     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
'     .SetCoordinateSystemType "ludwig3" 
'     .SetAutomaticCoordinateSystem "True" 
'     .SetPolarizationType "Circular" 
'     .SlantAngle 0.000000e+00 
'     .Origin "bbox" 
'     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .SetUserDecouplingPlane "False" 
'     .UseDecouplingPlane "False" 
'     .DecouplingPlaneAxis "X" 
'     .DecouplingPlanePosition "0.000000e+00" 
'     .LossyGround "False" 
'     .GroundEpsilon "1" 
'     .GroundKappa "0" 
'     .EnablePhaseCenterCalculation "False" 
'     .SetPhaseCenterAngularLimit "3.000000e+01" 
'     .SetPhaseCenterComponent "boresight" 
'     .SetPhaseCenterPlane "both" 
'     .ShowPhaseCenter "True" 
'     .ClearCuts 
'     .AddCut "lateral", "0", "1"  
'     .AddCut "lateral", "90", "1"  
'     .AddCut "polar", "90", "1"  
'     .StoreSettings
'End With
'
''@ define farfield monitor: farfield (f=1.72)
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'With Monitor 
'     .Delete "farfield (f=1.747)" 
'End With 
'With Monitor 
'     .Reset 
'     .Name "farfield (f=1.72)" 
'     .Domain "Frequency" 
'     .FieldType "Farfield" 
'     .Frequency "1.72" 
'     .ExportFarfieldSource "False" 
'     .UseSubvolume "False" 
'     .Coordinates "Structure" 
'     .SetSubvolume "-24.65", "24.65", "-24.65", "24.65", "-10", "1.62" 
'     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
'     .SetSubvolumeOffsetType "FractionOfWavelength" 
'     .Create 
'End With
'
''@ farfield plot options
'
''[VERSION]2017.0|26.0.1|20170113[/VERSION]
'With FarfieldPlot 
'     .Plottype "3D" 
'     .Vary "angle2" 
'     .Theta "0" 
'     .Phi "0" 
'     .Step "5" 
'     .Step2 "5" 
'     .SetLockSteps "True" 
'     .SetPlotRangeOnly "False" 
'     .SetThetaStart "0" 
'     .SetThetaEnd "180" 
'     .SetPhiStart "0" 
'     .SetPhiEnd "360" 
'     .SetTheta360 "False" 
'     .SymmetricRange "False" 
'     .SetTimeDomainFF "False" 
'     .SetFrequency "1.8138" 
'     .SetTime "0" 
'     .SetColorByValue "True" 
'     .DrawStepLines "False" 
'     .DrawIsoLongitudeLatitudeLines "False" 
'     .ShowStructure "False" 
'     .ShowStructureProfile "False" 
'     .SetStructureTransparent "False" 
'     .SetFarfieldTransparent "False" 
'     .SetSpecials "enablepolarextralines" 
'     .SetPlotMode "Directivity" 
'     .Distance "1" 
'     .UseFarfieldApproximation "True" 
'     .SetScaleLinear "False" 
'     .SetLogRange "40" 
'     .SetLogNorm "0" 
'     .DBUnit "0" 
'     .EnableFixPlotMaximum "False" 
'     .SetFixPlotMaximumValue "1" 
'     .SetInverseAxialRatio "False" 
'     .SetAxesType "user" 
'     .SetAntennaType "unknown" 
'     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
'     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
'     .SetCoordinateSystemType "ludwig3" 
'     .SetAutomaticCoordinateSystem "True" 
'     .SetPolarizationType "Circular" 
'     .SlantAngle 0.000000e+00 
'     .Origin "bbox" 
'     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
'     .SetUserDecouplingPlane "False" 
'     .UseDecouplingPlane "False" 
'     .DecouplingPlaneAxis "X" 
'     .DecouplingPlanePosition "0.000000e+00" 
'     .LossyGround "False" 
'     .GroundEpsilon "1" 
'     .GroundKappa "0" 
'     .EnablePhaseCenterCalculation "False" 
'     .SetPhaseCenterAngularLimit "3.000000e+01" 
'     .SetPhaseCenterComponent "boresight" 
'     .SetPhaseCenterPlane "both" 
'     .ShowPhaseCenter "True" 
'     .ClearCuts 
'     .AddCut "lateral", "0", "1"  
'     .AddCut "lateral", "90", "1"  
'     .AddCut "polar", "90", "1"  
'     .StoreSettings
'End With
'
'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "90" 
     .Phi "90" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Directivity" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ add parsweep parameter: Sequence 1:g

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 1", "g", "52", "58", "3" 
End With

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ delete parsweep parameter: Sequence 1:g

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "g" 
End With

'@ add parsweep parameter: Sequence 1:Lg

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 1", "Lg", "52.02", "58.02", "3" 
End With

'@ delete parsweep parameter: Sequence 1:Lg

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "Lg" 
End With

'@ add parsweep parameter: Sequence 1:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 1", "Lp", "27.57", "28.27", "3" 
End With

'@ delete monitor: farfield (f=1.26)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=1.26)"

'@ delete monitor: farfield (f=1.8138)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=1.8138)"

'@ delete monitor: farfield (f=2.6)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=2.6)"

'@ delete monitor: farfield (f=3)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=3)"

'@ delete monitor: e-field (f=1.26)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=1.26)"

'@ delete monitor: e-field (f=1.8138)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=1.8138)"

'@ delete monitor: h-field (f=1.26)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "h-field (f=1.26)"

'@ delete monitors

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=3)" 
Monitor.Delete "h-field (f=3)" 
Monitor.Delete "loss (f=1.26)" 
Monitor.Delete "loss (f=3)" 
Monitor.Delete "power (f=1.26)" 
Monitor.Delete "power (f=3)"

'@ define farfield monitor: farfield (f=2.4)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.4)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.4" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-29.01", "29.01", "-29.01", "29.01", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ add parsweep parameter: Sequence 1:Lg

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 1", "Lg", "55.4", "65", "4" 
End With

'@ delete parsweep parameter: Sequence 1:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "Lp" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ edit parsweep parameter: Sequence 1:Lg

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "Lg" 
     .AddParameter_Linear "Sequence 1", "Lg", "55.4", "77", "4" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "False" 
     .SymmetricRange "False" 
     .SetTimeDomainFF "False" 
     .SetFrequency "1.8138" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ delete parsweep parameter: Sequence 1:Lg

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "Lg" 
End With

'@ add parsweep parameter: Sequence 1:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 1", "Lt", "5", "7.5", "4" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "-180" 
     .Phi "-180" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.45" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ edit parsweep parameter: Sequence 1:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "Lt" 
     .AddParameter_Linear "Sequence 1", "Lt", "3", "7", "4" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ define farfield monitor: farfield (f=2.5)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.5)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.5" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define material: material1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material 
     .Reset 
     .Name "material1"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "Kelvin"
     .Epsilon "3.38"
     .Mu "1"
     .Sigma "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .EnableUserConstTanDModelOrderEps "False"
     .ConstTanDModelOrderEps "1"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .EnableUserConstTanDModelOrderMu "False"
     .ConstTanDModelOrderMu "1"
     .SetMagParametricConductivity "False"
     .DispModelEps  "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NonlinearMeasurementError "1e-1"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Rho "0"
     .ThermalType "Normal"
     .ThermalConductivity "0"
     .HeatCapacity "0"
     .DynamicViscosity "0"
     .Emissivity "0"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Unused"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With

'@ change material: component1:substrate to: material1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "material1"

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ define material: material2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material 
     .Reset 
     .Name "material2"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "Kelvin"
     .Epsilon "2.55"
     .Mu "1"
     .Sigma "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .EnableUserConstTanDModelOrderEps "False"
     .ConstTanDModelOrderEps "1"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .EnableUserConstTanDModelOrderMu "False"
     .ConstTanDModelOrderMu "1"
     .SetMagParametricConductivity "False"
     .DispModelEps  "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NonlinearMeasurementError "1e-1"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Rho "0"
     .ThermalType "Normal"
     .ThermalConductivity "0"
     .HeatCapacity "0"
     .DynamicViscosity "0"
     .Emissivity "0"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Unused"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With

'@ change material and color: component1:substrate to: material2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "material2" 
Solid.SetUseIndividualColor "component1:substrate", 1
Solid.ChangeIndividualColor "component1:substrate", "0", "255", "255"

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ add parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 3" 
End With

'@ add parsweep parameter: Sequence 2:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 2", "yfeed", "-2", "-7", "4" 
End With

'@ enable parsweep sequence: Sequence 1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 1", "False" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ edit parsweep parameter: Sequence 2:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 2", "yfeed" 
     .AddParameter_Linear "Sequence 2", "yfeed", "-2", "-15", "5" 
End With

'@ define farfield monitor: farfield (f=2.36)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.36)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.36" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-24.83", "24.83", "-24.83", "24.83", "-10", "1.2" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ edit parsweep parameter: Sequence 1:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "Lt" 
     .AddParameter_Linear "Sequence 1", "Lt", "3", "6", "4" 
End With

'@ enable parsweep sequence: Sequence 2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 2", "False" 
End With

'@ enable parsweep sequence: Sequence 1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 1", "True" 
End With

'@ change material: component1:substrate to: FR-4 (lossy)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "FR-4 (lossy)"

'@ define monitor: e-field (f=1.26)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=1.26)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .Frequency "1.26" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .Create 
End With

'@ edit parsweep parameter: Sequence 2:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 2", "yfeed" 
     .AddParameter_Linear "Sequence 2", "yfeed", "-17", "-19", "4" 
End With

'@ define farfield monitor: e-field (f=12)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=12)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "1.26" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define farfield monitor: farfield (f=1.26)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=1.26)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "1.26" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ delete monitor: e-field (f=12)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=12)"

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ define farfield monitor: e-field (f=1)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=1)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "1.2" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define farfield monitor: farfield (f=1.2)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=1.2)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "1.2" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define farfield monitor: farfield (f=1.18)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=1.18)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "1.18" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ add parsweep parameter: Sequence 1:ratio_per

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 1", "ratio_per", "0.012;0.008;0.0010" 
End With

'@ delete parsweep parameter: Sequence 1:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 1", "Lt" 
End With

'@ enable parsweep sequence: Sequence 1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 1", "False" 
End With

'@ add parsweep parameter: Sequence 3:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 3", "Lt", "6.33;6.44;6.8" 
End With

'@ delete monitor: farfield (f=2.45)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=2.45)"

'@ delete monitors

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=2.45)" 
Monitor.Delete "farfield (f=2.36)" 
Monitor.Delete "farfield (f=2.4)" 
Monitor.Delete "farfield (f=2.5)" 
Monitor.Delete "h-field (f=2.45)" 
Monitor.Delete "loss (f=2.45)" 
Monitor.Delete "power (f=2.45)"

'@ delete monitor: e-field (f=1)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=1)"

'@ define farfield monitor: farfield (f=1.27)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=1.27)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "1.27" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "2.395" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ edit parsweep parameter: Sequence 3:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "Lt" 
     .AddParameter_ArbitraryPoints "Sequence 3", "Lt", "8;8.2;7.5;7.3" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ define material: material3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material 
     .Reset 
     .Name "material3"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "Kelvin"
     .Epsilon "3.5"
     .Mu "1"
     .Sigma "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .EnableUserConstTanDModelOrderEps "False"
     .ConstTanDModelOrderEps "1"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .EnableUserConstTanDModelOrderMu "False"
     .ConstTanDModelOrderMu "1"
     .SetMagParametricConductivity "False"
     .DispModelEps  "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NonlinearMeasurementError "1e-1"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Rho "0"
     .ThermalType "Normal"
     .ThermalConductivity "0"
     .HeatCapacity "0"
     .DynamicViscosity "0"
     .Emissivity "0"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Unused"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With

'@ change material: component1:substrate to: material3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "material3"

'@ delete monitor: farfield (f=1.18)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=1.18)"

'@ delete monitor: farfield (f=1.2)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=1.2)"

'@ delete monitor: farfield (f=1.26)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=1.26)"

'@ delete monitor: farfield (f=1.27)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=1.27)"

'@ delete monitor: e-field (f=1.26)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=1.26)"

'@ define frequency range

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solver.FrequencyRange "1", "3"

'@ define farfield monitor: farfield (f=2.45)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.45)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.45" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "3.264" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define farfield monitor: farfield (f=2.4)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.4)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.4" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "3.264" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define farfield monitor: farfield (f=2.5)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.5)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.5" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-38.5", "38.5", "-38.5", "38.5", "-10", "3.264" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "unknown" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "spherical" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Linear" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ split shape: component1:substrate

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.SplitShape "substrate", "component1"

'@ transform: translate component1:patch

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:patch" 
     .Vector "0", "0", "h" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Transform "Shape", "Translate" 
End With

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:substrate", "4"

'@ define extrude: component1:substrate_layer2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Extrude 
     .Reset 
     .Name "substrate_layer2" 
     .Component "component1" 
     .Material "material3" 
     .Mode "Picks" 
     .Height "h" 
     .Twist "0.0" 
     .Taper "0.0" 
     .UsePicksForHeight "False" 
     .DeleteBaseFaceSolid "False" 
     .ClearPickedFace "True" 
     .Create 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ define farfield monitor: farfield (f=2.8)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.8)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.8" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-23.5", "23.5", "-23.5", "23.5", "-10", "6.464" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "7"

'@ activate local coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "local"

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "8"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "8"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "6"

'@ activate local coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "local"

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "7"

'@ activate local coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "local"

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "7"

'@ activate local coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "local"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ transform: rotate component1:patch

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:patch" 
     .Origin "Free" 
     .Center "0", "0", "0" 
     .Angle "0", "0", "90" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Transform "Shape", "Rotate" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "7"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define curve polygon: curve1:polygon1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Polygon 
     .Reset 
     .Name "polygon1" 
     .Curve "curve1" 
     .Point "-S/2", "Lp/2-d-e+a-W1" 
     .LineTo "-S/2+W1", "Lp/2-d-e+a-W1" 
     .LineTo "-S/2+W1", "Lp/2-d-e" 
     .LineTo "S/2-W1", "Lp/2-d-e" 
     .LineTo "S/2-W1", "Lp/2-d-e+a-W1" 
     .LineTo "S/2", "Lp/2-d-e+a-W1" 
     .LineTo "S/2", "Lp/2-d-e-W1" 
     .LineTo "-S/2", "Lp/2-d-e-W1" 
     .LineTo "-S/2", "Lp/2-d-e+a-W1" 
     .Create 
End With

'@ new component: component2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Component.New "component2"

'@ define extrudeprofile: component2:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ExtrudeCurve
     .Reset 
     .Name "solid1" 
     .Component "component2" 
     .Material "PEC" 
     .Thickness "-sg" 
     .Twistangle "0.0" 
     .Taperangle "0.0" 
     .DeleteProfile "True" 
     .Curve "curve1:polygon1" 
     .Create
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ transform: translate component2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component2" 
     .Vector "0", "0", "-sg" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Transform "Shape", "Translate" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ boolean subtract shapes: component1:patch, component2:solid1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Subtract "component1:patch", "component2:solid1"

'@ set mesh properties (Hexahedral)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Mesh 
     .MeshType "PBA" 
     .SetCreator "High Frequency"
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "Version", 1%
     'MAX CELL - WAVELENGTH REFINEMENT 
     .Set "StepsPerWaveNear", "9" 
     .Set "StepsPerWaveFar", "9" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "9" 
     .Set "StepsPerBoxFar", "9" 
     .Set "MaxStepNear", "0" 
     .Set "MaxStepFar", "0" 
     .Set "ModelBoxDescrNear", "maxedge" 
     .Set "ModelBoxDescrFar", "maxedge" 
     .Set "UseMaxStepAbsolute", "0" 
     .Set "GeometryRefinementSameAsNear", "0" 
     'MIN CELL 
     .Set "UseRatioLimitGeometry", "1" 
     .Set "RatioLimitGeometry", "20" 
     .Set "MinStepGeometryX", "0" 
     .Set "MinStepGeometryY", "0" 
     .Set "MinStepGeometryZ", "0" 
     .Set "UseSameMinStepGeometryXYZ", "1" 
End With 
With MeshSettings 
     .Set "PlaneMergeVersion", "2" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "FaceRefinementOn", "0" 
     .Set "FaceRefinementPolicy", "2" 
     .Set "FaceRefinementRatio", "2" 
     .Set "FaceRefinementStep", "0" 
     .Set "FaceRefinementNSteps", "2" 
     .Set "EllipseRefinementOn", "0" 
     .Set "EllipseRefinementPolicy", "2" 
     .Set "EllipseRefinementRatio", "2" 
     .Set "EllipseRefinementStep", "0" 
     .Set "EllipseRefinementNSteps", "2" 
     .Set "FaceRefinementBufferLines", "3" 
     .Set "EdgeRefinementOn", "1" 
     .Set "EdgeRefinementPolicy", "1" 
     .Set "EdgeRefinementRatio", "6" 
     .Set "EdgeRefinementStep", "0" 
     .Set "EdgeRefinementBufferLines", "3" 
     .Set "RefineEdgeMaterialGlobal", "0" 
     .Set "RefineAxialEdgeGlobal", "0" 
     .Set "BufferLinesNear", "3" 
     .Set "UseDielectrics", "1" 
     .Set "EquilibrateOn", "0" 
     .Set "Equilibrate", "1.5" 
     .Set "IgnoreThinPanelMaterial", "0" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "SnapToAxialEdges", "1"
     .Set "SnapToPlanes", "1"
     .Set "SnapToSpheres", "1"
     .Set "SnapToEllipses", "1"
     .Set "SnapToCylinders", "1"
     .Set "SnapToCylinderCenters", "1"
     .Set "SnapToEllipseCenters", "1"
End With 
With Discretizer 
     .ConnectivityCheck "False"
     .UsePecEdgeModel "True" 
     .GapDetection "False" 
     .FPBAGapTolerance "1e-3" 
     .PointAccEnhancement "0" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "17"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "17"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define curve polygon: curve1:uslot

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Polygon 
     .Reset 
     .Name "uslot" 
     .Curve "curve1" 
     .Point "-S/2", "Lp/2-d-e+a-W1" 
     .LineTo "-S/2+W1", "Lp/2-d-e+a-W1" 
     .LineTo "-S/2+W1", "Lp/2-d-e" 
     .LineTo "S/2-W1", "Lp/2-d-e" 
     .LineTo "S/2-W1", "Lp/2-d-e+a-W1" 
     .LineTo "S/2", "Lp/2-d-e+a-W1" 
     .LineTo "S/2", "Lp/2-d-e-W1" 
     .LineTo "-S/2", "Lp/2-d-e-W1" 
     .LineTo "-S/2", "Lp/2-d-e+a-W1" 
     .Create 
End With

'@ delete curve item: curve1:uslot

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Curve.DeleteCurveItem "curve1", "uslot"

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:patch", "17"

'@ align wcs with face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.AlignWCSWithSelected "Face"

'@ define curve polygon: curve1:uslot

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Polygon 
     .Reset 
     .Name "uslot" 
     .Curve "curve1" 
     .Point "-S/2", "Lp/2-d-e+a-W1" 
     .LineTo "-S/2+W1+0.17", "Lp/2-d-e+a-W1" 
     .LineTo "-S/2+W1+0.17", "Lp/2-d-e" 
     .LineTo "S/2-W1-0.17", "Lp/2-d-e" 
     .LineTo "S/2-W1-0.17", "Lp/2-d-e+a-W1" 
     .LineTo "S/2", "Lp/2-d-e+a-W1" 
     .LineTo "S/2", "Lp/2-d-e-W1" 
     .LineTo "-S/2", "Lp/2-d-e-W1" 
     .LineTo "-S/2", "Lp/2-d-e+a-W1" 
     .Create 
End With

'@ edit parsweep parameter: Sequence 3:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "Lt" 
     .AddParameter_ArbitraryPoints "Sequence 3", "Lt", "6.5;5.5" 
End With

'@ change material: component1:substrate to: FR-4 (lossy)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "FR-4 (lossy)"

'@ change material: component1:substrate_layer2 to: FR-4 (lossy)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate_layer2", "FR-4 (lossy)"

'@ change material: component1:substrate to: material3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "material3"

'@ change material: component1:substrate_layer2 to: material3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate_layer2", "material3"

'@ delete shape: component1:substrate_layer2

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.Delete "component1:substrate_layer2"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ transform: translate component1:patch

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:patch" 
     .Vector "0", "0", "-h" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Transform "Shape", "Translate" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "False" 
End With

'@ add parsweep parameter: Sequence 3:d

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 3", "d", "5;5.5;6;7;7.5" 
End With

'@ delete parsweep parameter: Sequence 3:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "Lt" 
End With

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "True" 
End With

'@ add parsweep parameter: Sequence 3:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 3", "Lt", "5;7;6;" 
End With

'@ edit parsweep parameter: Sequence 3:d

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "d" 
     .AddParameter_ArbitraryPoints "Sequence 3", "d", "6;7;7.5" 
End With

'@ define farfield monitor: farfield (f=2.43)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.43)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.43" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-23.5", "23.5", "-23.5", "23.5", "-6.8", "9.632" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "False" 
End With

'@ add parsweep sequence: Sequence 4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 4" 
End With

'@ add parsweep parameter: Sequence 4:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 4", "Lp", "28.95;28.9;" 
End With

'@ enable parsweep sequence: Sequence 4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 4", "False" 
End With

'@ edit parsweep parameter: Sequence 3:d

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "d" 
     .AddParameter_ArbitraryPoints "Sequence 3", "d", "7;7.5" 
End With

'@ edit parsweep parameter: Sequence 3:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "Lt" 
     .AddParameter_ArbitraryPoints "Sequence 3", "Lt", "7;6;" 
End With

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "True" 
End With

'@ edit parsweep parameter: Sequence 3:d

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "d" 
     .AddParameter_ArbitraryPoints "Sequence 3", "d", "7;7.5;6" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ add parsweep sequence: Sequence 5

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 5" 
End With

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "False" 
End With

'@ add parsweep parameter: Sequence 5:h

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 5", "h", "3;2.5;2.75;" 
End With

'@ add parsweep parameter: Sequence 5:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 5", "Lp", "29;29.6;29.9" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ enable parsweep sequence: Sequence 5

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 5", "False" 
End With

'@ add parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 6" 
End With

'@ delete parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteSequence "Sequence 6" 
End With

'@ edit parsweep parameter: Sequence 3:d

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "d" 
     .AddParameter_Linear "Sequence 3", "d", "6.9", "7.3", "5" 
End With

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "True" 
End With

'@ define monitor: e-field (f=2.38)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "e-field (f=2.38)" 
     .Dimension "Volume" 
     .Domain "Frequency" 
     .FieldType "Efield" 
     .Frequency "2.38" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-23.5", "23.5", "-23.5", "23.5", "-7", "9.032" 
     .SetSubvolumeOffset "0.0", "0.0", "0.0", "0.0", "0.0", "0.0" 
     .Create 
End With

'@ define farfield monitor: farfield (f=2.38)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.38)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.38" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-23.5", "23.5", "-23.5", "23.5", "-7", "9.032" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ transform: translate component1:dielectric coaxial

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:dielectric coaxial" 
     .Vector "0", "0", "-h" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:feed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:feed" 
     .Vector "0", "0", "-h" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "True" 
     .Transform "Shape", "Translate" 
End With

'@ transform: translate component1:outer_cond

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Transform 
     .Reset 
     .Name "component1:outer_cond" 
     .Vector "0", "0", "-h" 
     .UsePickedPoints "False" 
     .InvertPickedPoints "False" 
     .MultipleObjects "False" 
     .GroupObjects "False" 
     .Repetitions "1" 
     .MultipleSelection "False" 
     .Transform "Shape", "Translate" 
End With

'@ enable parsweep sequence: Sequence 4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 4", "True" 
End With

'@ edit parsweep parameter: Sequence 4:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 4", "Lp" 
     .AddParameter_Linear "Sequence 4", "Lp", "29.3", "29.8", "4" 
End With

'@ add parsweep parameter: Sequence 4:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 4", "Lt", "6", "7", "3" 
End With

'@ add parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 6" 
End With

'@ add parsweep parameter: Sequence 6:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 6", "yfeed", "5.8", "7", "6" 
End With

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "False" 
End With

'@ delete parsweep parameter: Sequence 3:d

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "d" 
End With

'@ edit parsweep parameter: Sequence 3:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 3", "Lt" 
     .AddParameter_Linear "Sequence 3", "Lt", "6", "6.5", "5" 
End With

'@ delete parsweep parameter: Sequence 4:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 4", "Lp" 
End With

'@ edit parsweep parameter: Sequence 4:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 4", "Lt" 
     .AddParameter_Linear "Sequence 4", "Lt", "6", "7", "4" 
End With

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "False" 
End With

'@ enable parsweep sequence: Sequence 4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 4", "False" 
End With

'@ enable parsweep sequence: Sequence 3

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 3", "False" 
End With

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "True" 
End With

'@ edit parsweep parameter: Sequence 6:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "yfeed" 
     .AddParameter_Linear "Sequence 6", "yfeed", "6.7", "7.6", "5" 
End With

'@ add parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_ArbitraryPoints "Sequence 6", "Lp", "29.3;29.4" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ edit parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
     .AddParameter_ArbitraryPoints "Sequence 6", "Lp", "29.9;30" 
End With

'@ delete parsweep parameter: Sequence 6:yfeed

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "yfeed" 
End With

'@ add parsweep sequence: Sequence 7

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddSequence "Sequence 7" 
End With

'@ delete parsweep sequence: Sequence 7

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteSequence "Sequence 7" 
End With

'@ add parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 6", "Lt", "6", "7", "4" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ define material: material4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material 
     .Reset 
     .Name "material4"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "Kelvin"
     .Epsilon "4.5"
     .Mu "1"
     .Sigma "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .EnableUserConstTanDModelOrderEps "False"
     .ConstTanDModelOrderEps "1"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .EnableUserConstTanDModelOrderMu "False"
     .ConstTanDModelOrderMu "1"
     .SetMagParametricConductivity "False"
     .DispModelEps  "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NonlinearMeasurementError "1e-1"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Rho "0"
     .ThermalType "Normal"
     .ThermalConductivity "0"
     .HeatCapacity "0"
     .DynamicViscosity "0"
     .Emissivity "0"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Unused"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With

'@ change material: component1:substrate to: material4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "material4"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ edit parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
     .AddParameter_ArbitraryPoints "Sequence 6", "Lp", "27;27.3;27.5;26.8" 
End With

'@ edit parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
     .AddParameter_Linear "Sequence 6", "Lt", "6", "7", "3" 
End With

'@ set mesh properties (Hexahedral)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Mesh 
     .MeshType "PBA" 
     .SetCreator "High Frequency"
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "Version", 1%
     'MAX CELL - WAVELENGTH REFINEMENT 
     .Set "StepsPerWaveNear", "10" 
     .Set "StepsPerWaveFar", "10" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "10" 
     .Set "StepsPerBoxFar", "10" 
     .Set "MaxStepNear", "0" 
     .Set "MaxStepFar", "0" 
     .Set "ModelBoxDescrNear", "maxedge" 
     .Set "ModelBoxDescrFar", "maxedge" 
     .Set "UseMaxStepAbsolute", "0" 
     .Set "GeometryRefinementSameAsNear", "0" 
     'MIN CELL 
     .Set "UseRatioLimitGeometry", "1" 
     .Set "RatioLimitGeometry", "20" 
     .Set "MinStepGeometryX", "0" 
     .Set "MinStepGeometryY", "0" 
     .Set "MinStepGeometryZ", "0" 
     .Set "UseSameMinStepGeometryXYZ", "1" 
End With 
With MeshSettings 
     .Set "PlaneMergeVersion", "2" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "FaceRefinementOn", "0" 
     .Set "FaceRefinementPolicy", "2" 
     .Set "FaceRefinementRatio", "2" 
     .Set "FaceRefinementStep", "0" 
     .Set "FaceRefinementNSteps", "2" 
     .Set "EllipseRefinementOn", "0" 
     .Set "EllipseRefinementPolicy", "2" 
     .Set "EllipseRefinementRatio", "2" 
     .Set "EllipseRefinementStep", "0" 
     .Set "EllipseRefinementNSteps", "2" 
     .Set "FaceRefinementBufferLines", "3" 
     .Set "EdgeRefinementOn", "1" 
     .Set "EdgeRefinementPolicy", "1" 
     .Set "EdgeRefinementRatio", "6" 
     .Set "EdgeRefinementStep", "0" 
     .Set "EdgeRefinementBufferLines", "3" 
     .Set "RefineEdgeMaterialGlobal", "0" 
     .Set "RefineAxialEdgeGlobal", "0" 
     .Set "BufferLinesNear", "3" 
     .Set "UseDielectrics", "1" 
     .Set "EquilibrateOn", "0" 
     .Set "Equilibrate", "1.5" 
     .Set "IgnoreThinPanelMaterial", "0" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "SnapToAxialEdges", "1"
     .Set "SnapToPlanes", "1"
     .Set "SnapToSpheres", "1"
     .Set "SnapToEllipses", "1"
     .Set "SnapToCylinders", "1"
     .Set "SnapToCylinderCenters", "1"
     .Set "SnapToEllipseCenters", "1"
End With 
With Discretizer 
     .ConnectivityCheck "False"
     .UsePecEdgeModel "True" 
     .GapDetection "False" 
     .FPBAGapTolerance "1e-3" 
     .PointAccEnhancement "0" 
End With

'@ delete port: port1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Port.Delete "1"

'@ pick face

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickFaceFromId "component1:dielectric coaxial", "3"

'@ define port: 1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Port 
     .Reset 
     .PortNumber "1" 
     .Label "" 
     .NumberOfModes "1" 
     .AdjustPolarization "False" 
     .PolarizationAngle "0.0" 
     .ReferencePlaneDistance "0" 
     .TextSize "50" 
     .TextMaxLimit "0" 
     .Coordinates "Picks" 
     .Orientation "positive" 
     .PortOnBound "False" 
     .ClipPickedPortToBound "False" 
     .Xrange "-1.75", "1.75" 
     .Yrange "4.615", "8.115" 
     .Zrange "-10", "-10" 
     .XrangeAdd "0.0", "0.0" 
     .YrangeAdd "0.0", "0.0" 
     .ZrangeAdd "0.0", "0.0" 
     .SingleEnded "False" 
     .Create 
End With

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "False" 
End With

'@ edit parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
     .AddParameter_Linear "Sequence 6", "Lp", "26", "26.5", "1" 
End With

'@ edit parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
     .AddParameter_Linear "Sequence 6", "Lt", "6", "7", "2" 
End With

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "True" 
End With

'@ delete parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
End With

'@ edit parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
     .AddParameter_Linear "Sequence 6", "Lp", "26.1", "26.28", "5" 
End With

'@ add parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 6", "Lt", "6", "6.5", "4" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ edit parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
     .AddParameter_Linear "Sequence 6", "Lp", "26.3", "26.45", "3" 
End With

'@ edit parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
     .AddParameter_Linear "Sequence 6", "Lt", "5.85", "6.3", "4" 
End With

'@ delete parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
End With

'@ edit parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
     .AddParameter_Linear "Sequence 6", "Lp", "26.38", "26.4", "3" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ delete parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
End With

'@ add parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 6", "Lt", "5.7", "5.9", "3" 
End With

'@ edit parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
     .AddParameter_Linear "Sequence 6", "Lt", "5.55", "5.7", "3" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ pick mid point

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickMidpointFromId "component1:substrate", "3"

'@ pick mid point

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickMidpointFromId "component1:substrate", "7"

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "False" 
End With

'@ add parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 6", "Lp", "26.25", "26.5", "4" 
End With

'@ delete parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
End With

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "True" 
End With

'@ edit parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
     .AddParameter_Linear "Sequence 6", "Lp", "26.4", "26.52", "5" 
End With

'@ add parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 6", "Lt", "5.7", "6", "3" 
End With

'@ delete parsweep parameter: Sequence 6:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lp" 
End With

'@ edit parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
     .AddParameter_Linear "Sequence 6", "Lt", "5.4", "5.5", "5" 
End With

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "False" 
End With

'@ delete parsweep parameter: Sequence 5:h

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 5", "h" 
End With

'@ edit parsweep parameter: Sequence 5:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 5", "Lp" 
     .AddParameter_ArbitraryPoints "Sequence 5", "Lp", "26.8;26.75;26.9" 
End With

'@ enable parsweep sequence: Sequence 5

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 5", "True" 
End With

'@ edit parsweep parameter: Sequence 5:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 5", "Lp" 
     .AddParameter_ArbitraryPoints "Sequence 5", "Lp", "26.95;27;27.1" 
End With

'@ add parsweep parameter: Sequence 5:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .AddParameter_Linear "Sequence 5", "Lt", "5.8", "6.2", "4" 
End With

'@ edit parsweep parameter: Sequence 5:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 5", "Lt" 
     .AddParameter_Linear "Sequence 5", "Lt", "5.4", "5.75", "4" 
End With

'@ edit parsweep parameter: Sequence 5:Lp

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 5", "Lp" 
     .AddParameter_ArbitraryPoints "Sequence 5", "Lp", "26.95;27;27.1;27.2;" 
End With

'@ enable parsweep sequence: Sequence 5

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 5", "False" 
End With

'@ edit parsweep parameter: Sequence 6:Lt

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .DeleteParameter "Sequence 6", "Lt" 
     .AddParameter_Linear "Sequence 6", "Lt", "5.5", "7", "5" 
End With

'@ enable parsweep sequence: Sequence 6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ParameterSweep
     .EnableSequence "Sequence 6", "True" 
End With

'@ define farfield monitor: farfield (f=2.41)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.41)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.41" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-23.5", "23.5", "-23.5", "23.5", "-10", "4.564" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define farfield monitor: farfield (f=2.42)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.42)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.42" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-23.5", "23.5", "-23.5", "23.5", "-10", "4.564" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define farfield monitor: farfield (f=2.44)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Monitor 
     .Reset 
     .Name "farfield (f=2.44)" 
     .Domain "Frequency" 
     .FieldType "Farfield" 
     .Frequency "2.44" 
     .ExportFarfieldSource "False" 
     .UseSubvolume "False" 
     .Coordinates "Structure" 
     .SetSubvolume "-23.5", "23.5", "-23.5", "23.5", "-10", "4.564" 
     .SetSubvolumeOffset "10", "10", "10", "10", "10", "10" 
     .SetSubvolumeOffsetType "FractionOfWavelength" 
     .Create 
End With

'@ define material: Copper (pure)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material
     .Reset
     .Name "Copper (pure)"
     .Folder ""
     .FrqType "all"
     .Type "Lossy metal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "s"
     .MaterialUnit "Temperature", "Kelvin"
     .Mu "1.0"
     .Sigma "5.96e+007"
     .Rho "8930.0"
     .ThermalType "Normal"
     .ThermalConductivity "401.0"
     .HeatCapacity "0.39"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Isotropic"
     .YoungsModulus "120"
     .PoissonsRatio "0.33"
     .ThermalExpansionRate "17"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .FrqType "static"
     .Type "Normal"
     .SetMaterialUnit "Hz", "mm"
     .Epsilon "1"
     .Mu "1.0"
     .Kappa "5.96e+007"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .KappaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .DispersiveFittingSchemeMu "Nth Order"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .Colour "1", "1", "0"
     .Wireframe "False"
     .Reflection "False"
     .Allowoutline "True"
     .Transparentoutline "False"
     .Transparency "0"
     .Create
End With

'@ change material: component1:patch to: Copper (pure)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:patch", "Copper (pure)"

'@ define material: FR4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material 
     .Reset 
     .Name "FR4"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "Kelvin"
     .Epsilon "4.5"
     .Mu "1"
     .Sigma "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .EnableUserConstTanDModelOrderEps "False"
     .ConstTanDModelOrderEps "1"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .EnableUserConstTanDModelOrderMu "False"
     .ConstTanDModelOrderMu "1"
     .SetMagParametricConductivity "False"
     .DispModelEps  "General2nd"
     .EpsInfinity "1.0"
     .DispCoeff1Eps "0.0"
     .DispCoeff2Eps "0.0"
     .DispCoeff3Eps "0.0"
     .DispCoeff4Eps "0.0"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NonlinearMeasurementError "1e-1"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Rho "1850"
     .ThermalType "Normal"
     .ThermalConductivity "0.4"
     .HeatCapacity "0"
     .DynamicViscosity "0"
     .Emissivity "0"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Unused"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With

'@ change material: component1:substrate to: FR4

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "FR4"

'@ set mesh properties (Hexahedral)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Mesh 
     .MeshType "PBA" 
     .SetCreator "High Frequency"
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "Version", 1%
     'MAX CELL - WAVELENGTH REFINEMENT 
     .Set "StepsPerWaveNear", "10" 
     .Set "StepsPerWaveFar", "10" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "10" 
     .Set "StepsPerBoxFar", "10" 
     .Set "MaxStepNear", "0" 
     .Set "MaxStepFar", "0" 
     .Set "ModelBoxDescrNear", "maxedge" 
     .Set "ModelBoxDescrFar", "maxedge" 
     .Set "UseMaxStepAbsolute", "0" 
     .Set "GeometryRefinementSameAsNear", "0" 
     'MIN CELL 
     .Set "UseRatioLimitGeometry", "1" 
     .Set "RatioLimitGeometry", "20" 
     .Set "MinStepGeometryX", "0" 
     .Set "MinStepGeometryY", "0" 
     .Set "MinStepGeometryZ", "0" 
     .Set "UseSameMinStepGeometryXYZ", "1" 
End With 
With MeshSettings 
     .Set "PlaneMergeVersion", "2" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "FaceRefinementOn", "0" 
     .Set "FaceRefinementPolicy", "2" 
     .Set "FaceRefinementRatio", "2" 
     .Set "FaceRefinementStep", "0" 
     .Set "FaceRefinementNSteps", "2" 
     .Set "EllipseRefinementOn", "0" 
     .Set "EllipseRefinementPolicy", "2" 
     .Set "EllipseRefinementRatio", "2" 
     .Set "EllipseRefinementStep", "0" 
     .Set "EllipseRefinementNSteps", "2" 
     .Set "FaceRefinementBufferLines", "3" 
     .Set "EdgeRefinementOn", "1" 
     .Set "EdgeRefinementPolicy", "1" 
     .Set "EdgeRefinementRatio", "6" 
     .Set "EdgeRefinementStep", "0" 
     .Set "EdgeRefinementBufferLines", "3" 
     .Set "RefineEdgeMaterialGlobal", "0" 
     .Set "RefineAxialEdgeGlobal", "0" 
     .Set "BufferLinesNear", "3" 
     .Set "UseDielectrics", "1" 
     .Set "EquilibrateOn", "0" 
     .Set "Equilibrate", "1.5" 
     .Set "IgnoreThinPanelMaterial", "0" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "SnapToAxialEdges", "1"
     .Set "SnapToPlanes", "1"
     .Set "SnapToSpheres", "1"
     .Set "SnapToEllipses", "1"
     .Set "SnapToCylinders", "1"
     .Set "SnapToCylinderCenters", "1"
     .Set "SnapToEllipseCenters", "1"
End With 
With Discretizer 
     .ConnectivityCheck "False"
     .UsePecEdgeModel "True" 
     .GapDetection "False" 
     .FPBAGapTolerance "1e-3" 
     .PointAccEnhancement "0" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "3D" 
     .Vary "angle2" 
     .Theta "0" 
     .Phi "0" 
     .Step "5" 
     .Step2 "5" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ define material: material5

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material 
     .Reset 
     .Name "material5"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "Kelvin"
     .Epsilon "4.5"
     .Mu "1"
     .Sigma "0"
     .TanD "0.0"
     .TanDFreq "0.0"
     .TanDGiven "False"
     .TanDModel "ConstTanD"
     .EnableUserConstTanDModelOrderEps "False"
     .ConstTanDModelOrderEps "1"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .EnableUserConstTanDModelOrderMu "False"
     .ConstTanDModelOrderMu "1"
     .SetMagParametricConductivity "False"
     .DispModelEps  "General2nd"
     .EpsInfinity "4.5"
     .DispCoeff1Eps "0.0"
     .DispCoeff2Eps "0.0"
     .DispCoeff3Eps "0.0"
     .DispCoeff4Eps "0.0"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NonlinearMeasurementError "1e-1"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Rho "1850"
     .ThermalType "Normal"
     .ThermalConductivity "0.29"
     .HeatCapacity "0"
     .DynamicViscosity "0"
     .Emissivity "0"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Unused"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With

'@ change material: component1:substrate to: material5

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "material5"

'@ change material: component1:dielectric coaxial to: FR-4 (lossy)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:dielectric coaxial", "FR-4 (lossy)"

'@ define material: material6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Material 
     .Reset 
     .Name "material6"
     .Folder ""
     .FrqType "all"
     .Type "Normal"
     .MaterialUnit "Frequency", "GHz"
     .MaterialUnit "Geometry", "mm"
     .MaterialUnit "Time", "ns"
     .MaterialUnit "Temperature", "Kelvin"
     .Epsilon "4.5"
     .Mu "1"
     .Sigma "0"
     .TanD "0.025"
     .TanDFreq "0.0"
     .TanDGiven "True"
     .TanDModel "ConstTanD"
     .EnableUserConstTanDModelOrderEps "False"
     .ConstTanDModelOrderEps "1"
     .SetElParametricConductivity "False"
     .ReferenceCoordSystem "Global"
     .CoordSystemType "Cartesian"
     .SigmaM "0"
     .TanDM "0.0"
     .TanDMFreq "0.0"
     .TanDMGiven "False"
     .TanDMModel "ConstTanD"
     .EnableUserConstTanDModelOrderMu "False"
     .ConstTanDModelOrderMu "1"
     .SetMagParametricConductivity "False"
     .DispModelEps "None"
     .DispModelMu "None"
     .DispersiveFittingSchemeEps "Nth Order"
     .MaximalOrderNthModelFitEps "10"
     .ErrorLimitNthModelFitEps "0.1"
     .UseOnlyDataInSimFreqRangeNthModelEps "False"
     .DispersiveFittingSchemeMu "Nth Order"
     .MaximalOrderNthModelFitMu "10"
     .ErrorLimitNthModelFitMu "0.1"
     .UseOnlyDataInSimFreqRangeNthModelMu "False"
     .UseGeneralDispersionEps "False"
     .UseGeneralDispersionMu "False"
     .NonlinearMeasurementError "1e-1"
     .NLAnisotropy "False"
     .NLAStackingFactor "1"
     .NLADirectionX "1"
     .NLADirectionY "0"
     .NLADirectionZ "0"
     .Rho "1850"
     .ThermalType "Normal"
     .ThermalConductivity "0.3"
     .HeatCapacity "0"
     .DynamicViscosity "0"
     .Emissivity "0"
     .MetabolicRate "0"
     .BloodFlow "0"
     .VoxelConvection "0"
     .MechanicsType "Unused"
     .Colour "0", "1", "1" 
     .Wireframe "False" 
     .Reflection "False" 
     .Allowoutline "True" 
     .Transparentoutline "False" 
     .Transparency "0" 
     .Create
End With

'@ change material: component1:dielectric coaxial to: material6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:dielectric coaxial", "material6"

'@ change material: component1:dielectric coaxial to: Air

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:dielectric coaxial", "Air"

'@ delete monitor: e-field (f=2.38)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "e-field (f=2.38)"

'@ delete monitor: farfield (f=2.8)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=2.8)"

'@ delete monitor: farfield (f=2.5)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=2.5)"

'@ delete monitor: farfield (f=2.38)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=2.38)"

'@ change material: component1:substrate to: material6

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:substrate", "material6"

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ change problem type

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
ChangeProblemType "Thermal"

'@ change solver type

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
ChangeSolverType "Thermal Steady State"

'@ define temperature source: temperaturesource1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With TemperatureSource
     .Reset
     .Name "temperaturesource1"
     .Value "25"
     .AddFace "component1:patch", "17"
     .Type "Initial"
     .Create
End With

'@ set tetrahedral mesh type

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Mesh.MeshType "Tetrahedral"

'@ define thermal solver parameters

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With ThermalSolver
     .Reset
     .Accuracy "1e-6"
     .MaxLinIter "0"
     .NonlinearAccuracy "1e-6"
     .Preconditioner "ILU"
     .StoreResultsInCache "False"
     .AmbientTemperature "2.7", "Kelvin"
     .PTCDefault "Ambient"
     .ConsiderBioheat "True"
     .BloodTemperature "37.0"
     .Method "Tetrahedral Mesh"
     .MeshAdaption "True"
     .LSESolverType "Auto"
     .TetSolverOrder "2"
     .CalcThermalConductanceMatrix "False"
     .TetAdaption "True"
     .TetAdaptionMinCycles "2" 
     .TetAdaptionMaxCycles "6" 
     .TetAdaptionAccuracy "0.01" 
     .TetAdaptionRefinementPercentage "10" 
     .SnapToGeometry "True" 
     .UseMaxNumberOfThreads "True"
     .MaxNumberOfThreads "96"
     .MaximumNumberOfCPUDevices "2"
     .UseDistributedComputing "False"
End With

'@ change problem type

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
ChangeProblemType "High Frequency"

'@ change solver type

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
ChangeSolverType "HF Time Domain"

'@ define time domain solver parameters

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Mesh.SetCreator "High Frequency" 
With Solver 
     .Method "Hexahedral"
     .CalculationType "TD-S"
     .StimulationPort "All"
     .StimulationMode "All"
     .SteadyStateLimit "-40"
     .MeshAdaption "False"
     .AutoNormImpedance "False"
     .NormingImpedance "50"
     .CalculateModesOnly "False"
     .SParaSymmetry "False"
     .StoreTDResultsInCache  "False"
     .FullDeembedding "False"
     .SuperimposePLWExcitation "False"
     .UseSensitivityAnalysis "False"
End With

'@ set mesh properties (Hexahedral)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Mesh 
     .MeshType "PBA" 
     .SetCreator "High Frequency"
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "Version", 1%
     'MAX CELL - WAVELENGTH REFINEMENT 
     .Set "StepsPerWaveNear", "18" 
     .Set "StepsPerWaveFar", "18" 
     .Set "WavelengthRefinementSameAsNear", "1" 
     'MAX CELL - GEOMETRY REFINEMENT 
     .Set "StepsPerBoxNear", "18" 
     .Set "StepsPerBoxFar", "11" 
     .Set "MaxStepNear", "0" 
     .Set "MaxStepFar", "0" 
     .Set "ModelBoxDescrNear", "maxedge" 
     .Set "ModelBoxDescrFar", "maxedge" 
     .Set "UseMaxStepAbsolute", "0" 
     .Set "GeometryRefinementSameAsNear", "0" 
     'MIN CELL 
     .Set "UseRatioLimitGeometry", "1" 
     .Set "RatioLimitGeometry", "20" 
     .Set "MinStepGeometryX", "0" 
     .Set "MinStepGeometryY", "0" 
     .Set "MinStepGeometryZ", "0" 
     .Set "UseSameMinStepGeometryXYZ", "1" 
End With 
With MeshSettings 
     .Set "PlaneMergeVersion", "2" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "FaceRefinementOn", "0" 
     .Set "FaceRefinementPolicy", "2" 
     .Set "FaceRefinementRatio", "2" 
     .Set "FaceRefinementStep", "0" 
     .Set "FaceRefinementNSteps", "2" 
     .Set "EllipseRefinementOn", "0" 
     .Set "EllipseRefinementPolicy", "2" 
     .Set "EllipseRefinementRatio", "2" 
     .Set "EllipseRefinementStep", "0" 
     .Set "EllipseRefinementNSteps", "2" 
     .Set "FaceRefinementBufferLines", "3" 
     .Set "EdgeRefinementOn", "1" 
     .Set "EdgeRefinementPolicy", "1" 
     .Set "EdgeRefinementRatio", "6" 
     .Set "EdgeRefinementStep", "0" 
     .Set "EdgeRefinementBufferLines", "3" 
     .Set "RefineEdgeMaterialGlobal", "0" 
     .Set "RefineAxialEdgeGlobal", "0" 
     .Set "BufferLinesNear", "3" 
     .Set "UseDielectrics", "1" 
     .Set "EquilibrateOn", "0" 
     .Set "Equilibrate", "1.5" 
     .Set "IgnoreThinPanelMaterial", "0" 
End With 
With MeshSettings 
     .SetMeshType "Hex" 
     .Set "SnapToAxialEdges", "1"
     .Set "SnapToPlanes", "1"
     .Set "SnapToSpheres", "1"
     .Set "SnapToEllipses", "1"
     .Set "SnapToCylinders", "1"
     .Set "SnapToCylinderCenters", "1"
     .Set "SnapToEllipseCenters", "1"
End With 
With Discretizer 
     .ConnectivityCheck "False"
     .UsePecEdgeModel "True" 
     .GapDetection "False" 
     .FPBAGapTolerance "1e-3" 
     .PointAccEnhancement "0" 
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ change material: component1:gnd to: Copper (pure)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Solid.ChangeMaterial "component1:gnd", "Copper (pure)"

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Cartesian" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "1" 
     .Step2 "1" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "False" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+000", "0.000000e+000", "0.000000e+000" 
     .Thetastart "0.000000e+000", "0.000000e+000", "1.000000e+000" 
     .PolarizationVector "0.000000e+000", "1.000000e+000", "0.000000e+000" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+000 
     .Origin "bbox" 
     .Userorigin "0.000000e+000", "0.000000e+000", "0.000000e+000" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+000" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+001" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  
     .StoreSettings
End With

'@ delete monitor: farfield (f=2.42)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=2.42)"

'@ delete monitor: farfield (f=2.44)

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Monitor.Delete "farfield (f=2.44)"

'@ switch working plane

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Plot.DrawWorkplane "false"

'@ switch bounding box

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Plot.DrawBox "True"

'@ pick edge

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickEdgeFromId "component1:substrate", "4", "4"

'@ define distance dimension

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "0"
    .SetOrientation "Smart Mode"
    .SetDistance "-1.546599"
    .SetViewVector "0.000000", "-0.000054", "-1.000000"
    .SetConnectedElement1 "component1:substrate"
    .SetConnectedElement2 "component1:substrate"
    .Create
End With
Pick.ClearAllPicks

'@ change dimension 0 label

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .Reset
    .SetID "0"
    .SetLabelPattern "Lp"
    .Modify
End With

'@ delete dimension 0

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .RemoveDimension "0"
End With

'@ pick edge

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickEdgeFromId "component1:substrate", "4", "4"

'@ define distance dimension

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "1"
    .SetOrientation "Smart Mode"
    .SetDistance "-1.633817"
    .SetViewVector "0.000000", "-0.000054", "-1.000000"
    .SetConnectedElement1 "component1:substrate"
    .SetConnectedElement2 "component1:substrate"
    .Create
End With
Pick.ClearAllPicks

'@ change dimension 1 label

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .Reset
    .SetID "1"
    .SetLabelPattern "Lp = 47 mm"
    .Modify
End With

'@ pick edge

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickEdgeFromId "component1:patch", "41", "27"

'@ delete dimension 1

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .RemoveDimension "1"
End With

'@ activate global coordinates

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
WCS.ActivateWCS "global"

'@ clear picks

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.ClearAllPicks

'@ pick edge

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
Pick.PickEdgeFromId "component1:substrate", "14", "4"

'@ define distance dimension

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .Reset
    .CreationType "picks"
    .SetType "Distance"
    .SetID "2"
    .SetOrientation "Smart Mode"
    .SetDistance "-2.699023"
    .SetViewVector "-1.000000", "-0.000026", "0.000000"
    .SetConnectedElement1 "component1:substrate"
    .SetConnectedElement2 "component1:substrate"
    .Create
End With
Pick.ClearAllPicks

'@ change dimension 2 label

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With Dimension
    .Reset
    .SetID "2"
    .SetLabelPattern "h = 4.5mm"
    .Modify
End With

'@ farfield plot options

'[VERSION]2017.0|26.0.1|20170113[/VERSION]
With FarfieldPlot 
     .Plottype "Polar" 
     .Vary "angle1" 
     .Theta "0" 
     .Phi "0" 
     .Step "0.01" 
     .Step2 "0.01" 
     .SetLockSteps "True" 
     .SetPlotRangeOnly "False" 
     .SetThetaStart "0" 
     .SetThetaEnd "180" 
     .SetPhiStart "0" 
     .SetPhiEnd "360" 
     .SetTheta360 "True" 
     .SymmetricRange "True" 
     .SetTimeDomainFF "False" 
     .SetFrequency "2.4" 
     .SetTime "0" 
     .SetColorByValue "True" 
     .DrawStepLines "False" 
     .DrawIsoLongitudeLatitudeLines "False" 
     .ShowStructure "False" 
     .ShowStructureProfile "False" 
     .SetStructureTransparent "False" 
     .SetFarfieldTransparent "True" 
     .SetSpecials "enablepolarextralines" 
     .SetPlotMode "Realized Gain" 
     .Distance "1" 
     .UseFarfieldApproximation "True" 
     .SetScaleLinear "False" 
     .SetLogRange "40" 
     .SetLogNorm "0" 
     .DBUnit "0" 
     .EnableFixPlotMaximum "False" 
     .SetFixPlotMaximumValue "1" 
     .SetInverseAxialRatio "False" 
     .SetAxesType "user" 
     .SetAntennaType "directional_circular" 
     .Phistart "1.000000e+00", "0.000000e+00", "0.000000e+00" 
     .Thetastart "0.000000e+00", "0.000000e+00", "1.000000e+00" 
     .PolarizationVector "0.000000e+00", "1.000000e+00", "0.000000e+00" 
     .SetCoordinateSystemType "ludwig3" 
     .SetAutomaticCoordinateSystem "True" 
     .SetPolarizationType "Circular" 
     .SlantAngle 0.000000e+00 
     .Origin "bbox" 
     .Userorigin "0.000000e+00", "0.000000e+00", "0.000000e+00" 
     .SetUserDecouplingPlane "False" 
     .UseDecouplingPlane "False" 
     .DecouplingPlaneAxis "X" 
     .DecouplingPlanePosition "0.000000e+00" 
     .LossyGround "False" 
     .GroundEpsilon "1" 
     .GroundKappa "0" 
     .EnablePhaseCenterCalculation "False" 
     .SetPhaseCenterAngularLimit "3.000000e+01" 
     .SetPhaseCenterComponent "boresight" 
     .SetPhaseCenterPlane "both" 
     .ShowPhaseCenter "True" 
     .ClearCuts 
     .AddCut "lateral", "0", "1"  
     .AddCut "lateral", "90", "1"  
     .AddCut "polar", "90", "1"  

     .StoreSettings
End With 


