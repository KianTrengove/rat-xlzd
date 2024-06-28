//this is the TPC .geo file for XLZD radius and height values are just placeholders for now

{
name: "GEO",
index: "xe_skin",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1887.75,
r_min: 1487.75,
size_z:  1887.75,
material: "liquid_Xe",
color: [0.15, 0.0, 0.8, 1.0],
}

{
name: "GEO",
index: "xe_target",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1487.75,
r_min: 0,
size_z: 1487.75,
material: "liquid_Xe",
color: [0.15, 0.0, 0.8, 1.0],
}

{
name: "GEO",
index: "rfr_xe",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1487.75,
r_min: 0,
size_z:  50.0,
material: "liquid_Xe",
posz: -1587.75,
color: [0.15, 0.0, 0.8, 1.0],
}

{
name: "GEO",
index: "gas_xe",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1487.75,
r_min: 0,
size_z:  50.0,
material: "liquid_Xe",
posz: 1587.75,
color: [0.15, 0.0, 0.8, 1.0],
}

{
name: "GEO",
index: "gas_skin",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1887.75,
r_min: 1487.75,
size_z:  50.0,
material: "Xe",
posz: 1587.75,
color: [0.15, 0.0, 0.8, 1.0],
}

{
name: "GEO",
index: "target_surface",
valid_begin: [0, 0],
valid_end: [0, 0],
mother: "outer_cryo", 
type: "border",
volume1: "xe_skin",
volume2: "inner_cryo",
reverse: 0, 
surface: "ptfe",
color: [1.0, 1.0, 1.0],
}

{
name: "GEO",
index: "top_surface",
valid_begin: [0, 0],
valid_end: [0, 0],
mother: "outer_cryo", 
type: "border",
volume1: "gas_xe",
volume2: "inner_cryo",
reverse: 0, 
surface: "ptfe",
color: [1.0, 1.0, 1.0],
}

{
name: "GEO",
index: "bot_surface",
valid_begin: [0, 0],
valid_end: [0, 0],
mother: "outer_cryo", 
type: "border",
volume1: "rfr_xe",
volume2: "inner_cryo",
reverse: 0, 
surface: "ptfe",
color: [1.0, 1.0, 1.0],
}
