//this is a very basic placeholder for the outer and inner cryo
//make sure to load it in your macro!

{
name: "GEO",
index: "outer_cryo", //we can define geometry outside of the main detector file
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "tube",
r_max: 1519.6,
r_min: 0, 
size_z: 1169.8,
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.5],
}

{
name: "GEO",
index: "vacuum_gap",
valid_begin: [0,0],
valid_end: [0,0],
mother: "outer_cryo",
type: "tube",
r_max: 1509.6,
r_min: 0.0, 
size_z: 1159.8,
material: "vacuum",
color: [0.0, 0.0, 0.0, 0.5],
}

{
name: "GEO",
index: "inner_cryo",
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "tube",
r_max: 1409.6,
r_min: 0.0, 
size_z: 1059.8,
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.5],
}
