//this is the main .geo file for XLZD

{
name: "GEO",
index: "world", //aka the cavern the detector is in
valid_begin: [0,0],
valid_end: [0,0],
mother: "",
type: "box",
size: [15000.0, 15000.0, 15000.0], 
material: "air",
invisible: 1,
}

{
name: "GEO",
index: "water_tank", //since the water tank is relatively simple (just a cylinder) I think it makes more sense to define it in here instead of it's own file.
valid_begin: [0,0],
valid_end: [0,0],
mother: "world",
type: "tube",
r_max: 5500,
r_min: 0, //water tank is 4.76 cm thick - shows up in cryo.geo
size_z: 5500,
material: "water",
color: [0.6, 1.0, 1.0, 0.1],
}

//PMTS and PTFE reflector

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

