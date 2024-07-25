//this is a very basic placeholder for the outer and inner cryo
//make sure to load it in your macro!

{
name: "GEO",
index: "outer_cryo", //we can define geometry outside of the main detector file
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "tube",
r_max: 2000.75,
r_min: 0, 
size_z: 2000.75,
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
r_max: 1997.75,
r_min: 0.0, 
size_z: 1997.75,
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
r_max: 1897.75,
r_min: 0.0, 
size_z: 1897.75,
material: "stainless_steel",
color: [0.5, 0.5, 0.5, 0.25],
}
