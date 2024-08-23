//
//Kian Trengove - May 16th 2024, 
//Written while at the University of California, Los Angeles supervised by Dr. Alvine Kamaha

//Implementation of the XLZD geometry for 40, 60, 80t based on the implementation in baccarat
//For questions, comments, concerns contact me at:
//kiantrengove@gmail.com or ktrengove@albany.edu
//

{
name: "GEO",
index: "xe_skin",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1499.6,
r_min: 1299.6,
size_z:  1499.6,
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
r_max: 1299.6,
r_min: 0,
size_z: 1299.6,
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
r_max: 1299.6,
r_min: 0,
size_z:  50.0,
material: "liquid_Xe",
posz: -1149.6,
color: [0.15, 0.0, 0.8, 1.0],
}

{
name: "GEO",
index: "gas_xe",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1299.6,
r_min: 0,
size_z:  50.0,
material: "liquid_Xe",
posz: 1149.6,
color: [0.15, 0.0, 0.8, 1.0],
}

{
name: "GEO",
index: "gas_skin",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1499.6,
r_min: 1299.6,
size_z:  50.0,
material: "Xe",
posz: 1149.6,
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
