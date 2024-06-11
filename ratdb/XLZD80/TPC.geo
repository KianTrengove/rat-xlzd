//this is the TPC .geo file for XLZD radius and height values are just placeholders for now

{
name: "GEO",
index: "xe_skin",
valid_begin: [0,0],
valid_end: [0,0],
mother: "inner_cryo",
type: "tube",
r_max: 1499.6,
r_min: 1299.6,
size_z:  2999.2,
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
size_z: 2599.2,
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
posz: -2299.2,
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
posz: 2299.2,
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
posz: 2299.2,
color: [0.15, 0.0, 0.8, 1.0],
}
