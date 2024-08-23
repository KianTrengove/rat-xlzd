'''
Kian Trengove - August 6th 2024, 
Written while at the University of California, Los Angeles supervised by Dr. Alvine Kamaha

Implementation of Tray inside of RAT - Takes the enery deposits from Geant4/Rat and feeds them into Tray
For questions, comments, concerns contact me at:
kiantrengove@gmail.com or ktrengove@albany.edu
'''


#RAT Stuff
from ratproc.base import Processor
from rat import ROOT, RAT, ratiter
from rat.parser import create_evaluation_tree


#Tray Stuff
from array import array
import operator
import itertools
from icecube import icetray, dataio, dataclasses, phys_services
from I3Tray import *

#I am sincerely very confused why I need to do it like this.
#I discovered when working in jupyter notebook, if I just try to import DarwinChainModules twice
#then the error goes away. It is very confusing and I have yet to figure out why :\
try:
    from icecube import DarwinChainModules
except:
    from icecube import DarwinChainModules


from icecube.DarwinChainModules import DarwinNESTQuantaCalculator, DarwinEnergyDeposit, I3VectorDarwinEnergyDeposit, DarwinSimParams, DarwinGeometryParams
import numpy as np

class TrayProc(Processor):
    def __init__(self, particle="e-"):
        self.tray = I3Tray()

        self.tray.AddModule( "I3InfiniteSource", Stream=icetray.I3Frame.DAQ)
        #This creates an infinite stream of empty frames, which we then fill below.
        
        #this is a list of the energy deposits. At the end it will be added to the MCDeposits frame and then passed to NestQuanta

        self.deposits = []

        self.db = RAT.DB.Get()

        self.name = particle #default particle is an electron
        

    def dsevent(self, ds):
        mc_data = ds.GetMC().GetMCSummary() #gets the monte carlo information
        pos = dataclasses.I3Position(mc_data.GetTotalScintCentroid().X(), mc_data.GetTotalScintCentroid().Y(), mc_data.GetTotalScintCentroid().Z()) 
        #We might want to use something other than energy centroid? (see MCSummary.hh for details)
        #Also note the caps, GetTotalScintCentroid uses TVector3
        time = mc_data.GetInitialScintTime()
        energy = mc_data.GetTotalScintEdep()
        depositType = DarwinEnergyDeposit.NotSet
        if self.name == "neutron":
            depositType = DarwingEnergyDeposit.NR
        elif self.name == "e-":
            depositType = DarwinEnergyDeposit.beta
        if depositType == DarwinEnergyDeposit.NotSet:
            return 2 #see base.py; 2 = ABORT
        

        self.deposits.append(DarwinEnergyDeposit(pos = pos, time = time, energy = energy, field = 200, type = depositType)) #field is temporary get that later

        return 0 #see base.py; 0 = OK


    def finish(self):
        #this is setting up all of the frame stuff (geometry/simulation parameters)

        DriftField = 200 # 200 V/cm, just letting this be a standin for now
        CathodeField = 15 #Same as drift field just temporary
        LXeDensity = self.db.GetLink("MATERIAL", "Xe").GetD("density") 

        self.tray.AddModule(DarwinSimParams, DriftField=DriftField, CathodeField = CathodeField, LXeDensity = LXeDensity, PMTQE=1.0) #letting Quantum Efficiency be 1 for now
        
        r_tpc = self.db.GetLink("GEO", "inner_cryo").GetD("r_max") #Note that this depends on the geometry actually being called inner_cryo like in cryo.geo
        z_gate = self.db.GetLink("GEO", "inner_cryo").GetD("size_z")*2 #Don't know where the gate is, I'm just putting it at the top of the inner cryo for now, even though that's definately incorrect
        z_lxe = self.db.GetLink("GEO", "xe_skin").GetD("size_z")*2 #Geant uses half z, NEST doesn't
        z_pmt_top = self.db.GetLink("PMTINFO_inner").GetDArray("z")[0] #likewise for PMTINFO_inner
        z_pmt_bottom = self.db.GetLink("PMTINFO_inner").GetDArray("z")[-1]
        z_cathode = self.db.GetLink("PMTINFO_inner").GetDArray("z")[-1] 
        #also I'm just putting the cathode in the same location as the pmt since it's not modeled in the geometry
        self.tray.AddModule(XLZDGeometryParams, r_tpc=r_tpc, z_gate=z_gate, z_lxe=z_lxe, z_pmt_top=z_pmt_top, z_pmt_bottom=z_pmt_bottom, z_cathode=z_cathode) 

        self.tray.AddModule(ConfigureG4)
        self.tray.AddModule(RATDeposit, MCDeposits=self.deposits)
        self.tray.AddModule(DarwinNESTQuantaCalculator) #after all the frames with the energy depositions have been calculated we get the quanta
        
        #TODO: Currently the DarwinNestQuantaCalculator uses the Xenon-10 detector template, but really we should replace this with something more modular that takes inputs from RAT

        # Module that writes the output
        #self.tray.AddModule("I3Writer", "writer", Filename="output.i3.bz2") #if we prefer to keep it in the tray format use this instead
        self.tray.AddModule(ROOTOutput, Filename="output.root", TreeLength=len(self.deposits))
        self.tray.Execute()
        

class RATDeposit(icetray.I3Module):
    def __init__(self, context):
        """
        This is initialization function, where one defines parameters
        """
        icetray.I3Module.__init__(self, context)
        self.AddParameter("MCDeposits", "The Monte Carlo Deposits from RAT", I3VectorDarwinEnergyDeposit([]))

    def Configure(self):
        """
        This function configures the module, for example - get parameters etc.
        """
        self.mcdeposit = self.GetParameter("MCDeposits")
        self.count = 0
        self.nevents = len(self.mcdeposit)



    def DAQ(self, frame):
        """
        This functions actually processes the frame
        """
        if self.count < self.nevents:
            frame['MCDeposits'] = I3VectorDarwinEnergyDeposit([self.mcdeposit[self.count]])
            self.count += 1                
            self.PushFrame(frame)
        else:
            self.RequestSuspension()

class ConfigureG4(icetray.I3Module):
    def __init__(self, context):
        """
        The reason this class exists is because there is a single parameter in DarwinNestQuantaCalculator that calls G4InputExtraDeps
        Without this variable being defined RAT/Tray will crash (based on the comments in the code, it seems this might be a known bug?)
        As there is a TODO to explaining that the flag needs to be changed for the correct one. As a stop gap while we are just trying
        To prove this as a proof of concept, I've just added this module that does nothing else except set G4InputExtraDeps as True
        """
        icetray.I3Module.__init__(self, context)

    def Configure(self):
        pass
        


    def DAQ(self, frame):
        frame['G4InputExtraDeps'] = icetray.I3Bool(True)
        self.PushFrame(frame)


class ROOTOutput(icetray.I3Module):
    def __init__(self, context):
        icetray.I3Module.__init__(self, context)
        self.AddParameter("Filename", "Outputfilename", "output.root")
        self.AddParameter("TreeLength", "How many deposits will be written in the tree", 0)

    def Configure(self):
        self.file = ROOT.TFile.Open(self.GetParameter("Filename"), "RECREATE")
        self.tree = ROOT.TTree("tree1", "tree1")

        self.photon_branch = np.array([0], dtype=np.float64)
        self.electron_branch = np.array([0], dtype=np.float64)
        self.exciton_branch = np.array([0], dtype=np.float64) #This array will get filled with the data we want from the deposits and then write that to the root file
        self.tree.Branch("photon",  self.photon_branch,  'photon/D') #/D indicates that the data type being stored is a double
        self.tree.Branch("electron",  self.electron_branch,  'electron/D')
        self.tree.Branch("exciton",  self.exciton_branch,  'exciton/D')
        
        self.ncount = 0
        self.nevents = self.GetParameter("TreeLength")

    def DAQ(self, frame):
        deposits = frame['MCDeposits']
        for i in range(len(deposits)):
            self.photon_branch[0] = deposits[i].n_photons
            self.electron_branch[0] = deposits[i].n_electrons
            self.exciton_branch[0] = deposits[i].n_excitons
            self.tree.Fill()
        self.ncount += 1
        if self.ncount == self.nevents:
            self.file.Write()
            self.file.Close()
        self.PushFrame(frame)
    

class XLZDGeometryParams(icetray.I3Module):
    def __init__(self, context):
        icetray.I3Module.__init__(self, context)
        self.AddParameter("Outname", "Name of parameters in sim frame", "DarwinGeometry" ) 
        #Note that I'm continuin to keep this as DarwinGeometry to keep it consitent with the rest of the Darwin Modules
        #And we can't just use the DarwinGeometryParams because those have the Darwin Geometry Parameters hard coded in
        self.AddParameter("r_tpc", "Radius of the tpc", 0)
        self.AddParameter("z_gate", "Z coordinates of the gate", 0)
        self.AddParameter("z_lxe", "Z coordinate of the lXe", 0)
        self.AddParameter("z_pmt_top", "Position of the top pmts", 0)
        self.AddParameter("z_pmt_bottom", "Position of the bottom pmts", 0)
        self.AddParameter("z_cathode", "Position of the cathode", 0)


    def Configure(self):
        self.has_gframe=False
        self.outname=self.GetParameter("Outname")
        self.r_tpc = self.GetParameter("r_tpc")
        self.z_gate = self.GetParameter("z_gate")
        self.z_lxe = self.GetParameter("z_lxe")
        self.z_pmt_top = self.GetParameter("z_pmt_top")
        self.z_pmt_bottom = self.GetParameter("z_pmt_bottom")
        self.z_cathode = self.GetParameter("z_cathode")
        self.SetFunctions()
    def Geometry(self,frame=None):
        if frame is None:
            frame = icetray.I3Frame(icetray.I3Frame.Geometry)       
        gparams=dataclasses.I3MapStringDouble()
        gparams['z_gate']=self.z_gate
        gparams['z_cathode']=self.z_cathode
        gparams['r_tpc']=self.r_tpc
        gparams['z_pmt_bottom']=self.z_pmt_bottom
        gparams['z_pmt_top']=self.z_pmt_top
        gparams['z_lxe']=self.z_lxe
        frame[self.outname]=gparams
        self.PushFrame(frame)
    def AddGFrame(self, frame):
        if not self.has_gframe:
            self.Geometry()
        self.has_gframe=True
        self.PushFrame(frame)
    def SetFunctions(self):
        self.Calibration=self.AddGFrame
        self.Simulation=self.AddGFrame
        self.DAQ=self.AddGFrame
        self.Physics=self.AddGFrame
