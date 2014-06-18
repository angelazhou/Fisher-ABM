import numpy as np
import matplotlib.pyplot as plt
from sys import argv 
from scipy import linalg as LA
import networkx as nx
## Load in data
## Usage: Specify the specific data file via the command line argument
#script, argument = argv


#SN      = np.load("../Data/Data_evo_SN_" + argument + ".npy")
#cpue_mu = np.load("../Data/Data_evo_cpue_mu_" + argument + ".npy")
#cpue_s2 = np.load("../Data/Data_evo_cpue_s2_" + argument + ".npy")

#SN is [CP_N, CP_N, iterated through time] 
SN      = np.load("../Data/Data_evo_SN.npy")
cpue_mu = np.load("../Data/Data_evo_cpue_mu.npy")
cpue_s2 = np.load("../Data/Data_evo_cpue_s2.npy")


timesteps = SN.shape[2]
## plot
#Time on the x-axis
x  = np.arange(0,SN.shape[2]);
#average the social network along the PC_N columns
y1 = np.mean(SN,1);
#average the averages 
y2 = np.mean(y1,0);

y3 = cpue_mu;
y4 = np.mean(y3,0);

y5 = cpue_s2;
y6 = np.mean(y5,0);

##Determine eigenvector centrality at end of runtime
# find eigenvalues of SN[:,:,SN.shape[2] - 1]
e_vals, e_vecs = LA.eig(SN[:,:,timesteps - 1])
# select eigenvector associated w largest eigenvalue
eigen_centralities = e_vecs[:,np.argmax(e_vals)] 
print eigen_centralities
# element[i] of eigenvector yields centrality of the ith node 

## Analyze social network dynamics: look at evolution of graph over time
graphs = [nx.Graph(SN[:,:,i]) for i in range(timesteps)]
## Output a PNG for each graph timestep     
for i in np.arange(0,timesteps,10):     
    graphs[i] = nx.Graph(SN[:,:,i])
    nx.draw_circular(graphs[i],cmap='blues')
    plt.savefig('graph-' + str(i) + '.png')
    print("saving figure: ", i);


## Plot Connectance over evo time
fig, ax = plt.subplots(1, figsize=(10, 8),edgecolor=[.4,.4,.4]);
for i in np.arange(0,y1.shape[0]):
    plt.plot(x,y1[i,:],'-',alpha=.5,color=[0,0,1],lw=1);
plt.plot(x,y2,'-',alpha=1,color=[1,0,0],lw=2);
ax.set_ylabel('Connectance', color='k')
ax.set_xlabel('Time', color='k')
print("Saving fig1")
#plt.savefig('./PNG/Fig_diag_' + argument + '1.png',dpi=600,bbox_inches='tight')
plt.savefig('./PNG/Fig_diag1.png',dpi=600,bbox_inches='tight')

## Plot mean CPUE over evo time
fig, ax = plt.subplots(1, figsize=(10, 8),edgecolor=[.4,.4,.4]);
for i in np.arange(0,y1.shape[0]):
    plt.plot(x,y3[i,:],'-',alpha=.5,color=[0,0,1],lw=1);
plt.plot(x,y4,'-',alpha=1,color=[1,0,0],lw=2);
ax.set_ylabel('Expected catch per unit time', color='k')
ax.set_xlabel('Time', color='k')
print("saving fig2")
#plt.savefig('./PNG/Fig_diag_' + argument + '2.png',dpi=600,bbox_inches='tight')
plt.savefig('./PNG/Fig_diag2.png',dpi=600,bbox_inches='tight')

## Plot variance in CPUE over evo time
fig, ax = plt.subplots(1, figsize=(10, 8),edgecolor=[.4,.4,.4]);
for i in np.arange(0,y1.shape[0]):
    plt.plot(x,y5[i,:],'-',alpha=.5,color=[0,0,1],lw=1);
plt.plot(x,y6,'-',alpha=1,color=[1,0,0],lw=2);
ax.set_ylabel('Variance in catch per unit time', color='k')
ax.set_xlabel('Time', color='k')
#plt.savefig('./PNG/Fig_diag_' + argument + '3.png',dpi=600,bbox_inches='tight')
print("saving fig3")
plt.savefig('./PNG/Fig_diag3.png',dpi=600,bbox_inches='tight')



plt.show()
