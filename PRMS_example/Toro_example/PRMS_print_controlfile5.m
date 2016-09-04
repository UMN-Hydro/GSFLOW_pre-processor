% PRMS_print_controlfile5.m
% (11/17/15)
% v5 - updated 9/4/16 by gcng

% Creates inputs files to run PRMS, based on the "Merced" example but
% leaves out many of the "extra" options. v5 sets up problem for "Toro"
% site, for Andy's AGU 2015 presentation.
% 
% PRMS Input files:
%   - control file (generate with PRMS_print_controlfile5.m)
%   - parameter file (generate with PRMS_print_paramfile3.m)
%   - variable / data files (generate with PRMS_print_climate_hru_files2.m)
% (Control file includes names of parameter and data files.  Thus, 
% parameter and variable file names must match those specified there!!)


clear all, close all, fclose all;
%% Control file

% see PRMS manual: 
%   - list of control variables in Appendix 1 Table 1-2 (p.33-36), 
%   - description of control file on p.126

% general syntax (various parameters listed in succession):
%   line 1: '####'
%   line 2: control parameter name
%   line 3: number of parameter values specified
%   line 4: data type -> 1=int, 2=single prec, 3=double prec, 4=char str
%   line 5-end: parameter values, 1 per line

% *** CUSTOMIZE TO YOUR COMPUTER! *****************************************
% NOTE: '/' is directory separator for Linux, '\' for Windows!!

inname = 'base'; % test name

% directory for PRMS input and output files (include slash ('/') at end)
PRMSinput_dir = '/home/gcng/workspace/ModelRuns_scratch/PRMS_projects/Toro/inputs/';
PRMSoutput_dir = '/home/gcng/workspace/ModelRuns_scratch/PRMS_projects/Toro/outputs/';

% directory with files to be read in to generate PRMS input files
in_data_dir = '/home/gcng/workspace/matlab_files/PRMS/PRMS_pre-processor_example_Toro_AW/DataToReadIn/';
in_climatedata_dir = strcat(in_data_dir, 'climate/'); % specifically climate data

% control file that will be written with this script
con_filname = strcat(PRMSinput_dir, inname, '/Toro.control');

% command-line executable
PRMS_exe = '/home/awickert/models/prms4.0.1_linux/bin/prms'; 

% java program for GUI (optional, only for printing execution info)
PRMS_java_GUI = '/home/awickert/models/prms4.0.1_linux/dist/oui4.jar'; 

% data file that the control file will point to (generate with PRMS_print_climate_hru_files2.m)
datafil = strcat(PRMSinput_dir, inname, '/empty.dat');

% Climate-hru data files (generate with PRMS_print_climate_hru_files2.m)
precip_datafil = strcat(PRMSinput_dir, inname, '/precip.dat');
tmax_datafil = strcat(PRMSinput_dir, inname, '/tmax.dat');
tmin_datafil = strcat(PRMSinput_dir, inname, '/tmin.dat');
solrad_datafil = strcat(PRMSinput_dir, inname, '/solrad.dat');

% parameter file that the control file will point to (generate with PRMS_print_paramfile3.m)
parfil = strcat(PRMSinput_dir, inname, '/Toro.param');

% output directory that the control file will point to for creating output files (include slash at end!)
outdir = strcat(PRMSoutput_dir, inname, '/');

% To define model start and end dates on the fly
in_datafil = strcat(in_climatedata_dir, 'climate_', inname, '.csv');
fid = fopen(in_datafil, 'r');
fmt = ['%s %f %f %f %f'];
D = textscan(fid, fmt, 'HeaderLines', 1, 'Delimiter', ',');
fclose(fid);
ymdhms_v = datevec(D{1}, 'dd/mm/yyyy');

% *************************************************************************

% Project-specific entries ->

title_str = 'Salta project, Andys AGU 2015 poster';

% n_par_max should be dynamically generated
n_par_max = 100; % there are a lot, unsure how many total...
con_par_name = cell(n_par_max,1);  % name of control file parameter
con_par_num = zeros(n_par_max,1);  % number of values for a control parameter
con_par_type = zeros(n_par_max,1); % 1=int, 2=single prec, 3=double prec, 4=char str
con_par_name = cell(n_par_max,1);  % control parameter values

ii = 0;

% First 2 blocks should be specified, rest are optional (though default 
% values exist for all variables, see last column of App 1 Table 1-2 p.33).  

% 1 - Variables pertaining to simulation execution and required input and output files 
%     (some variable values left out if default is the only choice we want)

ii = ii+1;
con_par_name{ii} = 'model_mode'; % typically 'PRMS', also 'FROST' or 'WRITE_CLIMATE'
con_par_type(ii) = 4; 
con_par_values{ii} = {'PRMS'}; % PRMS to run model

ii = ii+1;
con_par_name{ii} = 'start_time';
con_par_type(ii) = 1; 
con_par_values{ii} = ymdhms_v(1,:);

ii = ii+1;
con_par_name{ii} = 'end_time';
con_par_type(ii) = 1; 
con_par_values{ii} = ymdhms_v(end,:); % year, month, day, hour, minute, second

ii = ii+1;
con_par_name{ii} = 'data_file';
con_par_type(ii) = 4; 
con_par_values{ii} = {datafil};

ii = ii+1;
con_par_name{ii} = 'param_file';
con_par_type(ii) = 4; 
con_par_values{ii} = {parfil};

ii = ii+1;
con_par_name{ii} = 'model_output_file';
con_par_type(ii) = 4; 
con_par_values{ii} = {[outdir, 'prms.out']};


% 2 - Variables pertaining to module selection and simulation options

% - module selection:
%    See PRMS manual: Table 2 (pp. 12-13), summary pp. 14-16, details in
%    Appendix 1 (pp. 29-122)

% meteorological data
ii = ii+1;
con_par_name{ii} = 'precip_module'; % precip distribution method (should match temp)
con_par_type(ii) = 4; 
con_par_values{ii} = {'climate_hru'}; % climate_hru, ide_dist, precip_1sta, precip_dist2, precip_laps, or xyz_dist
if strcmp(con_par_values{ii}, 'climate_hru')
    ii = ii+1;
    con_par_name{ii} = 'precip_day'; % file with precip data for each HRU
    con_par_type(ii) = 4; 
    con_par_values{ii} = {precip_datafil}; % file name
end

ii = ii+1;
con_par_name{ii} = 'temp_module'; % temperature distribution method (should match precip)
con_par_type(ii) = 4; 
con_par_values{ii} = {'climate_hru'}; % climate_hru, temp_1sta, temp_dist2, temp_laps, ide_dist, xyz_dist
if strcmp(con_par_values{ii}, 'climate_hru')
    ii = ii+1;
    con_par_name{ii} = 'tmax_day'; % file with precip data for each HRU
    con_par_type(ii) = 4; 
    con_par_values{ii} = {tmax_datafil}; % file name
    ii = ii+1;
    con_par_name{ii} = 'tmin_day'; % file with precip data for each HRU
    con_par_type(ii) = 4; 
    con_par_values{ii} = {tmin_datafil}; % file name
end

ii = ii+1;
con_par_name{ii} = 'solrad_module'; % solar rad distribution method
con_par_type(ii) = 4; 
con_par_values{ii} = {'climate_hru'}; % ccsolrad (better for humid climate), ddsolrad (better for mostly clear-skies climates), or climate_hru
if strcmp(con_par_values{ii}, 'climate_hru')
    ii = ii+1;
    con_par_name{ii} = 'swrad_day'; % file with precip data for each HRU
    con_par_type(ii) = 4; 
    con_par_values{ii} = {solrad_datafil}; % file name
end

ii = ii+1;
con_par_name{ii} = 'et_module'; % method for calculating ET
con_par_type(ii) = 4; 
con_par_values{ii} = {'potet_pt'}; % potet_hamon, potet_jh, potet_hs, potet_pt, potet_pm, potet_pan, climate_hru
if strcmp(con_par_values{ii}, 'climate_hru')
    ii = ii+1;
    con_par_name{ii} = 'potet_day,'; % file with precip data for each HRU
    con_par_type(ii) = 4; 
    con_par_values{ii} = {'potet_day.dat'}; % file name
end

ii = ii+1;
con_par_name{ii} = 'transp_module'; % transpiration simulation method
con_par_type(ii) = 4; 
con_par_values{ii} = {'transp_tindex'}; % climate_hru, transp_frost, or transp_tindex
if strcmp(con_par_values{ii}, 'climate_hru')
    ii = ii+1;
    con_par_name{ii} = 'transp_day,'; % file with precip data for each HRU
    con_par_type(ii) = 4; 
    con_par_values{ii} = {'transp_day.dat'}; % file name
end

ii = ii+1;
con_par_name{ii} = 'soilzone_module'; % calculate exchange between soil zone reservoirs
con_par_type(ii) = 4; 
con_par_values{ii} = {'soilzone'};

ii = ii+1;
con_par_name{ii} = 'srunoff_module'; % surface runoff/infil calc method
con_par_type(ii) = 4; 
con_par_values{ii} = {'srunoff_smidx_casc'}; % runoff_carea or srunoff_smidx

% strmflow: directly routes runoff to basin outlet 
% muskingum: moves through stream segments, change in stream segment storages is by Muskingum eq
% strmflow_in_out: moves through stream segments, input to stream segment = output to stream segment
% strmflow_lake: for lakes...
ii = ii+1;
con_par_name{ii} = 'strmflow_module'; % streamflow routing method
con_par_type(ii) = 4; 
con_par_values{ii} = {'strmflow_in_out'}; % strmflow, muskingum, strmflow_in_out, or strmflow_lake

% cascade module
ncascade = 0;
if ncascade > 0 % default: ncascade = 0
    ii = ii+1;
    con_par_name{ii} = 'cascade_flag'; % runoff routing between HRU's
    con_par_type(ii) = 1; 
    con_par_values{ii} = 1;
end
ncascadegw = 0;
if ncascadegw > 0 % default: ncascadegw = 0
    ii = ii+1;
    con_par_name{ii} = 'cascadegw_flag'; % gw routing between HRU's
    con_par_type(ii) = 1; 
    con_par_values{ii} = 1;
end

ii = ii+1;
con_par_name{ii} = 'dprst_flag'; % flag for depression storage simulations
con_par_type(ii) = 1; 
con_par_values{ii} = 0;


% 3 - Output file: Statistic Variables (statvar) Files
%     See list in Table 1-5 pp.61-74 for variables you can print
ii = ii+1;
con_par_name{ii} = 'statsON_OFF'; % flag to create Statistics output variables
con_par_type(ii) = 1; 
con_par_values{ii} = 1;

ii = ii+1;
con_par_name{ii} = 'stat_var_file'; % output Statistics file location, name
con_par_type(ii) = 4; 
con_par_values{ii} = {[outdir, 'ToroOut.statvar']};

ii = ii+1;
con_par_name{ii} = 'statVar_names';
con_par_type(ii) = 4; 
con_par_values{ii} = {...
'basin_actet', ...
'basin_cfs', ...
'basin_gwflow_cfs', ...
'basin_gwin', ...
'basin_gwsink', ...
'basin_gwstor', ...
'basin_horad', ...
'basin_imperv_evap', ...
'basin_imperv_stor', ...
'basin_infil', ...
'basin_intcp_evap', ...
'basin_intcp_stor', ...
'basin_perv_et', ...
'basin_pk_precip', ...
'basin_potet', ...
'basin_potsw', ...
'basin_ppt', ...
'basin_pweqv', ...
'basin_rain', ...
'basin_snow', ...
'basin_snowcov', ...
'basin_snowevap', ...
'basin_snowmelt', ...
'basin_soil_moist', ...
'basin_soil_rechr', ...
'basin_soil_to_gw', ...
'basin_sroff_cfs', ...
'basin_ssflow_cfs', ...
'basin_ssin', ...
'basin_ssstor', ...
'basin_storage', ...
'basin_tmax', ...
'basin_tmin', ...
'basin_slstor', ...
'basin_pref_stor', ...
}; 

% index of statVar_names to be printed to Statistics Output file
ii = ii+1;
con_par_name{ii} = 'statVar_element'; % ID numbers for variables in stat_Var_names  
con_par_num(ii) = length(con_par_values{strcmp(con_par_name, 'statVar_names')});
con_par_type(ii) = 4; 
ind = ones(con_par_num(ii), 1); % index of variables
% add lines here to specify different variable indices other than 1
ind = num2str(ind);
con_par_values{ii} = mat2cell(ind, ones(con_par_num(ii), 1), 1);


% 4 - For GUI (otherwise ignored during command line execution)

ii = ii+1;
con_par_name{ii} = 'ndispGraphs'; % number runtime graphs with GUI
con_par_type(ii) = 1; 
con_par_values{ii} = 2;

ii = ii+1;
con_par_name{ii} = 'dispVar_names'; % variables for runtime plot
con_par_type(ii) = 4; 
con_par_values{ii} = { ...
'basin_cfs', ...
'runoff'};

% index of dispVar_names to be displayed in runtime plots
ii = ii+1;
con_par_name{ii} = 'dispVar_element'; % variable indices for runtime plot
con_par_num(ii) = length(con_par_values{strcmp(con_par_name, 'dispVar_names')});
con_par_type(ii) = 4; 
ind = ones(con_par_num(ii), 1); % index of variables
% add lines here to specify different variable indices other than 1
ind = num2str(ind);
con_par_values{ii} = mat2cell(ind, ones(con_par_num(ii), 1), 1);

% which plot (of ndispGraphs) to show variable (dispVar_names) on
ii = ii+1;
con_par_name{ii} = 'dispVar_plot';
con_par_num(ii) = length(con_par_values{strcmp(con_par_name, 'dispVar_names')});
con_par_type(ii) = 4; 
ind = ones(con_par_num(ii), 1); % index of plots
% add lines here to specify different plot indices other than 1
ind(2) = 2;
ind = num2str(ind);
con_par_values{ii} = mat2cell(ind, ones(con_par_num(ii), 1), 1);

ii = ii+1;
con_par_name{ii} = 'dispGraphsBuffSize'; % num timesteps (days) before updating runtime plot
con_par_type(ii) = 1; 
con_par_values{ii} = 1;

ii = ii+1;
con_par_name{ii} = 'initial_deltat'; % initial time step length (hrs)
con_par_type(ii) = 2; 
con_par_values{ii} = 24.0; % 24 hrs matches model's daily time step

ii = ii+1;
con_par_name{ii} = 'executable_desc';
con_par_type(ii) = 4; 
con_par_values{ii} = {'PRMS IV'};

ii = ii+1;
con_par_name{ii} = 'executable_model';
con_par_type(ii) = 4; 
con_par_values{ii} = {PRMS_exe};


% 5 - Initial condition file

% (default is init_vars_from_file = 0, but still need to specify for GUI)
ii = ii+1;
con_par_name{ii} = 'init_vars_from_file'; % use IC from initial cond file
con_par_type(ii) = 1; 
con_par_values{ii} = 0; % 0 for no, use default

% (default is save_vars_to_file = 0, but still need to specify for GUI)
ii = ii+1;
con_par_name{ii} = 'save_vars_to_file'; % save IC to output file
con_par_type(ii) = 1; 
con_par_values{ii} = 0;



% 6 - Suppress printing of some execution warnings

ii = ii+1;
con_par_name{ii} = 'print_debug';
con_par_type(ii) = 1; 
con_par_values{ii} = -1;


%% -----------------------------------------------------------------------
% Generally, do not change below here

% - Write to control file

if ~isempty(find(strcmp(con_par_name, 'statVar_names'), 1))
    ii = ii+1;
    con_par_name{ii} = 'nstatVars'; % num output vars in statVar_names (for Statistics output file)
    con_par_type(ii) = 1; 
    con_par_values{ii} = length(con_par_values{strcmp(con_par_name, 'statVar_names')});
end

if ~isempty(find(strcmp(con_par_name, 'aniOutVar_names'), 1))
    ii = ii+1;
    con_par_name{ii} = 'naniOutVars'; % num output vars in aniOutVar_names (for animation output file)
    con_par_type(ii) = 1; 
    con_par_values{ii} = length(con_par_values{strcmp(con_par_name, 'aniOutVar_names')});
end


nvars = ii;


for ii = 1: nvars
    con_par_num(ii) = length(con_par_values{ii});
end


% - Write to control file
line1 = '####';
fmt_types = {'%d', '%f', '%f', '%s'};
fid = fopen(con_filname, 'w');
fprintf(fid,'%s\n', title_str);
for ii = 1: nvars
    % Line 1
    fprintf(fid,'%s\n', line1);
    % Line 2
    fprintf(fid,'%s\n', con_par_name{ii});
    % Line 3: 
    fprintf(fid,'%d\n', con_par_num(ii));
    % Line 4: 
    fprintf(fid,'%d\n', con_par_type(ii));
    % Line 5 to end:
    if con_par_type(ii) == 4 
        for jj = 1: con_par_num(ii) 
            fprintf(fid,[fmt_types{con_par_type(ii)}, '\n'], con_par_values{ii}{jj});
        end
    else
        fprintf(fid,[fmt_types{con_par_type(ii)}, '\n'], con_par_values{ii});
    end
end

fclose(fid);

%% ------------------------------------------------------------------------
% Prepare for model execution

if ~exist(outdir, 'dir')
    mkdir(outdir);
end

fprintf('Make sure the below data files are ready: \n  %s\n', datafil);
fprintf('  %s\n', precip_datafil);
fprintf('  %s\n', tmax_datafil);
fprintf('  %s\n', tmin_datafil);
fprintf('  %s\n', solrad_datafil);

fprintf('Make sure the below parameter file is ready: \n  %s\n', parfil);
cmd_str = [PRMS_exe, ' -C ', con_filname];
fprintf('To run command-line execution, enter at prompt: \n %s\n', cmd_str);
gui_str1 = [cmd_str, ' -print'];
gui_str2 = ['java -cp ', PRMS_java_GUI, ' oui.mms.gui.Mms ', con_filname];
fprintf('To launch GUI, enter the following 2 lines (one at a time) at prompt: \n %s\n %s\n', gui_str1, gui_str2);

