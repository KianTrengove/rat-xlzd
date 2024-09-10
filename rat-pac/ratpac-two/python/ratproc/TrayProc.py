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
    def __init__(self):
        self.tray = I3Tray()

        #self.tray.AddService("I3SPRNGRandomServiceFactory", Seed=np.random.randint(0, 2 ** 31 - 1), StreamNum=1, NStreams=1000)
        #sets the random seed. Seed can be changed to something else to make testing consitent.
        #currently commented out because it results in a fatal error for some reason?

        #self.frame = icetray.I3Frame(icetray.I3Frame.DAQ) 

        self.tray.AddModule( "I3InfiniteSource", Stream=icetray.I3Frame.DAQ)
        #This creates an infinite stream of empty frames, which we then fill below.
        
        #this is a list of the energy deposits. At the end it will be added to the MCDeposits frame and then passed to NestQuanta

        self.deposits = []

        self.db = RAT.DB.Get()
        

    def dsevent(self, ds):
        mc_data = ds.GetMC().GetMCSummary() #gets the monte carlo information
        pos = dataclasses.I3Position(mc_data.GetTotalScintCentroid().X(), mc_data.GetTotalScintCentroid().Y(), mc_data.GetTotalScintCentroid().Z()) 
        #We might want to use something other than energy centroid? (see MCSummary.hh for details)
        #Also note the caps, GetTotalScintCentroid uses TVector3
        time = mc_data.GetInitialScintTime()
        energy = mc_data.GetTotalScintEdep()
        num_tracks = ds.GetMC().GetMCTrackCount()
        name = ""
        for trk in range(num_tracks):
            if ds.GetMC().GetMCTrack(trk).GetParentID() == 0:
                name = ds.GetMC().GetMCTrack(trk).GetParticleName() 
                break
                #the reason for having this in a loop is to avoid the edge case of when there are no tracks
                #this does in fact occur when PythonProc.cc first initializes this, which I find strange
                #unless, I'm badly misunderstanding how PythonProc.cc works (which is very possible),
                #In this case, it seems like the ideal solution would be to modify PythonProc.cc, however to avoid modifying any kind of
                #source code, I'm leaving this be - Kian August 1st 2024
        depositType = DarwinEnergyDeposit.NotSet
        if name == "neutron":
            depositType = DarwingEnergyDeposit.NR
        elif name == "e-":
            depositType = DarwinEnergyDeposit.beta
        else:
            depositType = DarwinEnergyDeposit.NR #I am using this as a debugging tool for now, while I sort out the Track stuff
        if depositType == DarwinEnergyDeposit.NotSet:
            return 1 #see base.py 1 = FAIL

        self.deposits.append(DarwinEnergyDeposit(pos = pos, time = time, energy = energy, field = 200, type = depositType)) #field is temporary get that later

        return 0 #see base.py 0 = OK


    def finish(self):
        #this is setting up all of the frame stuff (geometry/simulation parameters)

        DriftField = 200 # 200 V/cm, just letting this be a standin for now
        CathodeField = 15 #Same as drift field temporary
        LXeDensity = self.db.GetLink("MATERIAL", "Xe").GetD("density") 

        self.tray.AddModule(DarwinSimParams, DriftField=DriftField, CathodeField = CathodeField, LXeDensity = LXeDensity, PMTQE=1.0) #letting Quantum Efficiency be 1 for now
        
        r_tpc = self.db.GetLink("GEO", "inner_cryo").GetD("r_max") #Note that this depends on the geometry actually being called inner_cryo like in cryo.geo
        z_tpc = self.db.GetLink("GEO", "inner_cryo").GetD("r_max")
        z_lxe = self.db.GetLink("GEO", "xe_skin").GetD("size_z")*2 #Geant uses half z, NEST doesn't
        z_pmt_top = self.db.GetLink("PMTINFO_inner").GetDArray("z")[0] #likewise for PMTINFO_inner
        z_pmt_bottom = self.db.GetLink("PMTINFO_inner").GetDArray("z")[-1]
        z_cathode = self.db.GetLink("PMTINFO_inner").GetDArray("z")[-1] 
        #also I'm just putting the cathode in the same location as the pmt since it's not modeled in the geometry
        self.tray.AddModule(DarwinGeometryParams) 
        #I will have to make my own version for XLZD eventually

        self.tray.AddModule(ConfigureG4)
        self.tray.AddModule(RATDeposit, MCDeposits=self.deposits)
        self.tray.AddModule(DarwinNESTQuantaCalculator) #after all the frames with the energy depositions have been calculated we get the quanta

        # Module that writes the output
        #self.tray.AddModule("I3Writer", "writer", Filename="output.i3.bz2")
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
        self.AddParameter("Dummy Parameter", "This is a dummy parameter that has to exist for the module I think", "")

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
    

