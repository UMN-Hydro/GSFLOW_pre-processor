% PRMS_print_climate_hru_files2.m
% (12/8/15)
% v2 - updated 9/4/16 by gcng

% Creates climate data inputs files to run PRMS for climate_hru mode using 
% by uniformly applying data from a single weather station:
%   Specify precip, tmax, tmin, and solrad for each HRU for each
%   simulation day.  Can have start day earlier and end day later than
%   simulation period.
% 
% v2 sets up problem for "Toro" site, for Andy's AGU 2015 presentation.
%
% PRMS Input files:
%   - control file (generate with PRMS_print_controlfile5.m)
%   - parameter file (generate with PRMS_print_paramfile3.m)
%   - variable / data files (generate with PRMS_print_climate_hru_files2.m)
% (Control file includes names of parameter and data files.  Thus, 
% parameter and variable file names must match those specified there!!)



% *** CUSTOMIZE TO YOUR COMPUTER! *****************************************
% NOTE: '/' is directory separator for Linux, '\' for Windows!!
inname = 'base'; % test name

% directory for PRMS input and output files (include slash ('/') at end)
PRMSinput_dir = '/home/gcng/workspace/ModelRuns_scratch/PRMS_projects/Toro/inputs/';
PRMSoutput_dir = '/home/gcng/workspace/ModelRuns_scratch/PRMS_projects/Toro/outputs/';

% directory with files to be read in to generate PRMS input files in_GISdata_dir
in_data_dir = '/home/gcng/workspace/matlab_files/PRMS/PRMS_pre-processor_example_Toro_AW/DataToReadIn/';
in_climatedata_dir = strcat(in_data_dir, 'climate/'); % specifically climate data

% -- These files will be generated (names must match those in Control file!)
empty_datafil = strcat(PRMSinput_dir, inname, '/empty.dat');
precip_datafil = strcat(PRMSinput_dir, inname, '/precip.dat');
tmax_datafil = strcat(PRMSinput_dir, inname, '/tmax.dat');
tmin_datafil = strcat(PRMSinput_dir, inname, '/tmin.dat');
solrad_datafil = strcat(PRMSinput_dir, inname, '/solrad.dat');
% *************************************************************************

% Project-specific entries ->

% -- Number of HRU's over which to apply data uniformly
% nhru should be generated dynamically (from GIS data)
nhru = 25;

% -- Set any description of data here (example: location, units)
descr_str = 'Toro';

% -- Read in daily values from 1 station for:
%   - precip (check 'precip_units')
%   - tmax (check 'temp_units')
%   - tmin (check 'temp_units') 
%   - swrad [langleys for F temp_units] 
%   - ymdhms_v
in_datafil = strcat(in_climatedata_dir, 'climate_', inname, '.csv');
fid = fopen(in_datafil, 'r');
fmt = ['%s %f %f %f %f'];
D = textscan(fid, fmt, 'HeaderLines', 1, 'Delimiter', ',');
fclose(fid);
ymdhms_v = datevec(D{1}, 'dd/mm/yyyy');
precip = D{2} /10 /2.54; % mm -> inch
tmax = D{3} *(9/5)+32; % C -> F
tmin = D{4} *(9/5)+32; % C -> F
swrad = D{end}*1e6/41840; % MJ/m2 -> Langeley (1 Langely = 41840 J/m2)

%% ------------------------------------------------------------------------
% Generally, do no change below here

% - Write to data variable files

print_fmt1 = ['%4d ', repmat('%2d ', 1, 5), ' \n'];
print_fmt2 = ['%4d ', repmat('%2d ', 1, 5), repmat('%6.2f ', 1, nhru), ' \n'];
for ii = 0: 4
    switch ii
        case 0, 
            outdatafil = empty_datafil;
            data = [];
            label = {'precip 0', 'tmax 0', 'tmin 0'};
        case 1, 
            outdatafil = precip_datafil;
            data = precip;
            label = {['precip ', num2str(nhru)]};
        case 2, 
            outdatafil = tmax_datafil;
            data = tmax;
            label = {['tmax ', num2str(nhru)]};
        case 3, 
            outdatafil = tmin_datafil;
            data = tmin;
            label = {['tmin ', num2str(nhru)]};
        case 4, 
            outdatafil = solrad_datafil;
            data = swrad;
            label = {['swrad ', num2str(nhru)]};
            % ***NOTE: if you get errors related to swrad or orad, use instead:
            % 'orad'
            % and/or try setting orad_flag=0 in control file
    end    
    
    data0 = [ymdhms_v, repmat(data, 1, nhru)];
    
    fid = fopen(outdatafil, 'wt');
    fprintf(fid, '%s \n', descr_str);
    for ll = 1: length(label), fprintf(fid, '%s \n', label{ll}); end
    fprintf(fid, '########## \n');  % divider required
    
    if ii == 0
        fprintf(fid, print_fmt1, ymdhms_v');
    else
        fprintf(fid, print_fmt2, data0');
    end
end

