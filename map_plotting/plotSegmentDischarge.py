from osgeo import ogr
from matplotlib import pyplot as plt
from matplotlib import cm
import numpy as np
import pandas as pd
import matplotlib.gridspec as gridspec
import matplotlib as mpl
import matplotlib.animation as manimation


moviefile_name = 'testmovie.mp4'

projdir_GIS = '/home/awickert/dataanalysis/GRASS-fluvial-profiler/Shullcas_2lay/'
_shapefile = ogr.Open(projdir_GIS + "shapefiles/segments/segments.shp")
_shape = _shapefile.GetLayer(0)

segment_outputs = pd.read_csv('/home/awickert/Downloads/Shullcas_spinup/outputs/PRMS_GSFLOW/Shullcas.ani.nsegment.corrected', comment='#', delim_whitespace=True, error_bad_lines=False, warn_bad_lines=False, skiprows=[8])

dates = sorted(list(set(list(segment_outputs.timestamp))))
cmap = plt.get_cmap('RdYlBu')

plotting_variable = 'streamflow_sfr'
_min = np.min(segment_outputs[plotting_variable])
_max = np.max(segment_outputs[plotting_variable])

fig = plt.figure(figsize=(8,6))
#plt.ion()

ax = plt.subplot(111)

cax, _ = mpl.colorbar.make_axes(ax, location='right')
cbar = mpl.colorbar.ColorbarBase(cax, cmap=cm.jet,
               norm=mpl.colors.Normalize(vmin=_min, vmax=_max))

FFMpegWriter = manimation.writers['ffmpeg']
metadata = dict(title='Movie Test', artist='Matplotlib',
                comment='Movie support!')
writer = FFMpegWriter(fps=10, metadata=metadata)

with writer.saving(fig, moviefile_name, 100):
    for date in dates:
        print date
        _segment_outputs_on_date = segment_outputs.loc[segment_outputs['timestamp'] == date]
        _values = []
        for i in range(_shape.GetFeatureCount()):
            _feature = _shape.GetFeature(i)
            _n = _feature['id']
            #print _nhru
            _row = _segment_outputs_on_date.loc[_segment_outputs_on_date['nsegment'] == _n]
            try:
                _values.append(float(_row[plotting_variable].values))
            except:
                _values.append(np.nan)
                print _n
                continue
        _values = np.array(_values)
        # Floating colorbar
        colors = cm.jet(plt.Normalize( _min, _max) (_values) )
        ax.cla()
        _lines = []
        for i in range(_shape.GetFeatureCount()):
            _feature = _shape.GetFeature(i)
            #feature = shape.GetFeature(0) # how to get it otherwise
            _geometry = _feature.geometry()
            _line_points = np.array(_geometry.GetLinearGeometry().GetPoints())
            _x = _line_points[:,0]/1000.
            _y = _line_points[:,1]/1000.
            _lines.append( ax.plot(_x, _y, '-', color=colors[i], linewidth=_values[i]**.5+.25) )
        ax.set_title(plotting_variable+': '+date)
        ax.set_xlabel('E [km]', fontsize=16)
        ax.set_ylabel('N [km]', fontsize=16)
        #plt.tight_layout()
        writer.grab_frame()
        #plt.pause(0.01)
        #plt.waitforbuttonpress()
    