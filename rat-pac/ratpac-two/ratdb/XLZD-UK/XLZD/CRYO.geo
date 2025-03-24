{
name: "GEO",
index: "outer_cryo", //we can define geometry outside of the main detector file
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "tube",
r_max: 1612.6,
r_min: 0, 
size_z: 3112.2,
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.25],
}

{
name: "GEO",
index: "outer_cryo_top", 
valid_begin: [0,0],
valid_end: [0,0],
mother: "outer_cryo",
type: "revolve",
"r_max": [1612.6, 1600.0, 1580.0, 1550.0, 1500.0, 1450.0, 1400.0, 1300.0, 1200.0, 1000.0, 800.0, 500.0, 200.0, 0.0],  
"r_min": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],  
"z": [3112.2, 3162.2, 3212.2, 3262.2, 3312.2, 3362.2, 3412.2, 3462.2, 3512.2, 3562.2, 3612.2, 3662.2, 3712.2, 3762.2], 
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.25],
}

{
name: "GEO",
index: "outer_cryo_bottom", 
valid_begin: [0,0],
valid_end: [0,0],
mother: "outer_cryo",
type: "revolve",
"r_max": [1612.6, 1600.0, 1580.0, 1550.0, 1500.0, 1450.0, 1400.0, 1300.0, 1200.0, 1000.0, 800.0, 500.0, 200.0, 0.0],  
"r_min": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],  
"z": [-3112.2, -3162.2, -3212.2, -3262.2, -3312.2, -3362.2, -3412.2, -3462.2, -3512.2, -3562.2, -3612.2, -3662.2, -3712.2, -3762.2], 
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.25],
}

{
name: "GEO",
index: "vacuum_gap",
valid_begin: [0,0],
valid_end: [0,0],
mother: "outer_cryo",
type: "tube",
r_max: 1609.6,
r_min: 0.0, 
size_z: 3109.2,
material: "cryostat_vacuum",
color: [0.0, 0.0, 0.0, 0.25],
}

{
name: "GEO",
index: "inner_cryo",
valid_begin: [0,0],
valid_end: [0,0],
mother: "vacuum_gap",
type: "tube",
r_max: 1509.6,
r_min: 0.0, 
size_z: 3009.2,
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.65],
}

{
name: "GEO",
index: "inner_cryo_top", 
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "revolve",
"r_max": [1509.6, 1495.0, 1475.0, 1440.0, 1400.0, 1350.0, 1300.0, 1200.0, 1000.0, 800.0, 500.0, 200.0, 0.0],
"r_min": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 
"z": [3009.2, 3059.2, 3109.2, 3159.2, 3209.2, 3259.2, 3309.3, 3359.3, 3409.2, 3459.2, 3509.2, 3559.2, 3609.2], 
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.65],
}

{
name: "GEO",
index: "inner_cryo_bottom", 
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "revolve",
"r_max": [1509.6, 1495.0, 1475.0, 1440.0, 1400.0, 1350.0, 1300.0, 1200.0, 1000.0, 800.0, 500.0, 200.0, 0.0],
"r_min": [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 
"z": [-3009.2, -3059.2, -3109.2, -3159.2, -3209.2, -3259.2, -3309.3, -3359.3, -3409.2, -3459.2, -3509.2, -3559.2, -3609.2], 
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.65],
}

{
name: "GEO",
index: "ICVPTFE",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1450.0,
r_min: 0.0,
size_z: 2900.0,
material: "ptfe",
color: [0.5,0.5,0.8,0.25],
}
