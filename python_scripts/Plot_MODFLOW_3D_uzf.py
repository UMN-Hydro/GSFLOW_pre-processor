# -*- coding: utf-8 -*-
"""
Created on Fri Oct 27 23:36:53 2017

@author: gcng
"""
import sys
import platform
import struct
import numpy as np
from matplotlib import pyplot as plt
import settings_test

if platform.system() == 'Linux':
    slashstr = '/'
else:
    slashstr = '\\'


# ***Select which option:
# (1: head, 2: water table depth, 3: change in head per print-time increment)
sw_head_WTD_dhead = 3


#%% from Settings file 

# *** Change file names as needed
uzf_file = settings_test.MODFLOWoutput_dir + slashstr + 'uzf.dat'  # head data
surfz_fil = settings_test.GISinput_dir + slashstr + settings_test.DEM + '.asc'

print '\n******************************************'
print 'Plotting results from: ', uzf_file
print ' (domain data in: ' + surfz_fil + ')'
print '******************************************\n'

#%% In general: don't change below here

# Only ONE can be 1, others 0
if sys.platform[:3] == 'win':
    nread = 0
elif (platform.linux_distribution()[0] == 'Ubuntu') or (platform.linux_distribution()[0] == 'debian'):
    nread = 1
elif platform.linux_distribution()[0][:3] == 'Red':
    # Hope this works; haven't tried Red Hat here
    nread = 2
else:
    sys.exit("You should add your OS binary formatting to this script!")


# -- get surface elevations [m] (to plot WTD)
# function for parsing ASCII grid header in GIS data files
def read_grid_file_header(fname):
    f = open(fname, 'r')
    sdata = {}
    for i in range(6):
        line = f.readline()
        line = line.rstrip() # remove newline characters
        key, value = line.split(': ')
        try:
          value = int(value)
        except:
          value = float(value)
        sdata[key] = value
    f.close()

    return sdata
    
sdata = read_grid_file_header(surfz_fil)
    
NSEW = [sdata['north'], sdata['south'], sdata['east'], sdata['west']]
NROW = sdata['rows'] 
NCOL = sdata['cols']

# - space discretization
DELR = (NSEW[2]-NSEW[3])/NCOL # width of column [m]
DELC = (NSEW[0]-NSEW[1])/NROW # height of row [m]


# =========================================================================

if platform.system() == 'Linux':
    slashstr = '/'
else:
    slashstr = '\\'


fl_binary = 1;  # 1 for binary
fl_dble = 0;  # 1 for dble prec, 0 for single prec



# Save precision to variables;
if fl_dble:
    prec = 8
else:
    prec = 4


# -- Get head data and plot it as contour image plots
fid = open(uzf_file, 'rb')

#fid.read(4)
#struct.unpack('i', fid.read(4)) 
#fid.close()

def binbuild(nitems, nbytes, typecode, infile):
    outdata = []
    for i in range(nitems):
        x = infile.read(nbytes)
        if len(x) == 0:
            return ''
        outdata.append( struct.unpack(typecode, x) )
    return np.squeeze(np.array(outdata))

all_head_all = np.zeros([NROW,NCOL,0])
time_info = np.zeros([4,0])
all_label = []
nvar = 5;
ii = 0
t_i = 0
while True:
    # NOTE: for some reason, int w/ bit-length info is trailed by 0!!!
    a_info = binbuild( nitems=nread, nbytes=prec, typecode='i', infile=fid )
    if not a_info:
        break
    kstp = binbuild(nitems=1, nbytes=prec, typecode='i', infile=fid ) # FIX THESE TO SCALAR
    kper = binbuild(nitems=1, nbytes=prec, typecode='i', infile=fid ) # FIX THESE TO SCALAR
#    pertim = binbuild(nitems=1, nbytes=prec, typecode='f', infile=fid ) # FIX THESE TO SCALAR
#    totim = binbuild(nitems=1, nbytes=prec, typecode='f', infile=fid ) # FIX THESE TO SCALAR
    label = binbuild(nitems=16, nbytes=1, typecode='c', infile=fid ) # FIX TO CHAR ARRAY
    ncol = binbuild(nitems=1, nbytes=prec, typecode='i', infile=fid ) # FIX THESE TO SCALAR
    nrow = binbuild(nitems=1, nbytes=prec, typecode='i', infile=fid ) # FIX THESE TO SCALAR
    ilay = binbuild(nitems=1, nbytes=prec, typecode='i', infile=fid ) # FIX THESE TO SCALAR
    a_info = binbuild(nitems=nread, nbytes=prec, typecode='i', infile=fid )
    
    a_data = binbuild(nitems=nread, nbytes=prec, typecode='i', infile=fid )
    if nread == 0:
        nn = ncol*nrow
    else:
        nn = a_data/prec # is floor divide OK? Also, shouldn't it just be nlay?
    
    data = binbuild(nitems=nn, nbytes=prec, typecode='f', infile=fid)
    a_data = binbuild(nitems=nread, nbytes=prec, typecode='i', infile=fid )
    
    if nread == 0:
        all_data = np.reshape(data, (nrow,ncol), order='C') 
    else:
        all_data = np.reshape(data, (nrow,ncol,ilay), order='C') 
#        all_data = reshape(data,ncol,nrow,ilay);
#        all_data = permute(all_data, [2 1 3]);
        
    var_i = ii % nvar;
    if ii % 100 == 0:  # mod 100
        if nread == 0:
            all_head_all2 = np.zeros([NROW,NCOL,nvar,ii+100])
            all_head_all2[:,:,:ii] = all_head_all
            all_head_all = all_head_all2
        elif nread == 1:
            all_head_all2 = np.zeros([NROW,NCOL,ilay,nvar,ii+100])
            all_head_all2[:,:,:ii] = all_head_all
            all_head_all = all_head_all2
            
        time_info2 = np.zeros([2,ii+100])
        time_info2[:,:ii] = time_info
        time_info = time_info2
    
    if nread == 0:
        all_head_all[:,:,var_i,t_i] = all_data
    elif nread == 1:
        all_head_all[:,:,:,var_i,t_i] = all_data
    time_info[:,t_i] = [kstp, kper]
    if ii < 5:
        all_label.append(label)
    
    if (ii % nvar) == 0: 
        t_i = t_i + 1
    ii = ii + 1

fid.close()    

if nread == 0:
    all_head_all = all_head_all[:,:,:,:t_i]
elif nread == 1:
    all_head_all = all_head_all[:,:,:,:,:t_i]
time_info = time_info[:,:t_i]
ntimes = t_i


#x = np.arange(DELR/2., DELR*NCOL+DELR/2., DELR)
#y = np.arange(DELC/2., DELC*NROW+DELC/2., DELC)
#X, Y = np.meshgrid(x,y)
#
#
#data_head_all_NaN = data_head_all
#data_head_all_NaN[data_head_all_NaN > 1e29] = np.nan
#data_head_all_NaN[data_head_all_NaN <= 999] = np.nan
#
#
## use this to plot WTD:
#TOP2 = np.tile(TOP[:,:,np.newaxis], (1,1,ntimes))
#WTD_all = TOP2 - data_head_all_NaN
#
## use this to plot change in head:        
#dhead_all = np.zeros((NROW,NCOL,ntimes))
#dhead_all[:,:,1:] = data_head_all_NaN[:,:,1:] - data_head_all_NaN[:,:,:-1]
#
#
#
## head plot movie
#plt.figure()
#for ii in range(ntimes):
#    for lay_i in range(NLAY):
#        
#        if sw_head_WTD_dhead == 1:
#            # head:
#            ti = 'head [m], '
#            data_all = data_head_all_NaN
#        elif sw_head_WTD_dhead == 2:        
#            # WTD:
#            ti = 'WTD [m], '
#            data_all = WTD_all
#        elif sw_head_WTD_dhead == 3:
#            # change in head:
#            ti = 'Change in head [m], '
#            data_all = dhead_all
#               
#        data = data_all[:,:,ii]    
#        
#        if ii == 0:
#            plt.subplot(2,2,lay_info[0,ii])
#            p = plt.imshow(data, extent=[x.min(), x.max(), y.min(), y.max()], aspect='auto', interpolation='none')
#            p.set_cmap(plt.cm.hsv)
#            plt.colorbar(p)
##            plt.clim()
#            x = data_all[~np.isnan(data_all)]
#            p.set_clim(vmin=np.min(x), vmax=np.max(x))
#            plt.xlabel('[m]', fontsize=16)
#            plt.ylabel('[m]', fontsize=16)
#        else:
#            p.set_data(data)        
#            str0 = ti + str(time_info[0,ii]) + ', lay ' + str(int(lay_info[0,ii]))
#            plt.title(str0)
#        plt.tight_layout()
#                      
#    #    plt.show()
#        plt.pause(0.5)
#            
#    #plt.savefig("myplot.png", dpi = 300)
#
#