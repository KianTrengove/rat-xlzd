//
// Samantha Contreras - January 14 2024
//Written while at the University of California, Los Angeles supervised by Dr. Alvine Kamaha

//For questions, comments, concerns contact me at:
//scont@physics.ucla.edu
//

//Main .geo file for XLZD with UK geometry


{
name: "GEO",
index: "world", // the world or cavern the detector is in
valid_begin: [0, 0], // start validity period
valid_end: [0, 0], // end validity period
mother: "", // no mother volume, as this is the top-level volume
type: "box", // box shape
size: [10000.0, 10000.0, 10000.0], // dim used in UK geometry (20m -> 10000mm for each half)
material: "vacuum", // equivalent to "G4_Galactic"
invisible: 1, // make the world invisible in visualization
}

//Water Tank

{
name: "GEO",
index: "water_tank", 
valid_begin: [0,0],
valid_end: [0,0],
mother: "world",
type: "tube",
r_max: 5500,
r_min: 0, //water tank is 4.76 cm thick - shows up in cryo.geo
size_z: 5500,
material: "water",
color: [0.6, 1.0, 1.0, 0.5],
}

{
name: "GEO",
index: "TankWall",
valid_begin: [0,0],
valid_end: [0,0],
mother: "world",
type: "tube",
r_min: 5500,
r_max: 5700,
size_z: 5500,
material: "steel",
color: [0.1,0.1,0.1,0.3],
}

//add bottom and top to water tank

//Tyvek Curtain

{
name: "GEO",
index: "Curtain",
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "tube",
r_min: 0, //has to start after OCV
r_max: 4000,
size_z: 4500,
material: "tyvek", 
color: [0.1,0.1,0.1,0.5],
}

{
name: "GEO",
index: "GLS",
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "tube",
r_min: 0, //has to start after OCV
r_max: 2500,
size_z: 4000,
material: "gd_scintillator", 
color: [0.1,0.8,0.5,0.5],
}

//PMTS

{
name: "GEO",
index: "pmts",
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "pmtarray",
pmt_model: "r11410", 
pmt_detector_type: "idpmt", 
sensitive_detector: "/mydet/pmt/inner",
efficiency_correction: 1.000,
pos_table: "PMTINFO_inner", 
orientation: "manual",
light_cone: 0,
color:[1.0, 1.0, 1.0, 0.7],
}

{
name: "GEO",
index: "pmts_od",
valid_begin: [0,0],
valid_end: [0,0],
mother: "water_tank",
type: "pmtarray",
pmt_model: "r11410", 
pmt_detector_type: "idpmt", 
sensitive_detector: "/mydet/pmt/inner",
efficiency_correction: 1.000,
pos_table: "PMTINFO_inner_od", 
orientation: "manual",
light_cone: 0,
color:[1.0, 1.0, 1.0, 0.7],
}