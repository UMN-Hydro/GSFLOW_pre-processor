
% -------------------------------------------------------------------------
% input variables
% see Table 2., page 12

% Iteration Control
headtol = 1e-4;
fluxtol = 500;
maxiterout = 100;

% Dry Cell Tolerance
thickfact = 0.00001;

% NWT Options
linmeth = 1;
iprnwt = 0;
ibotav = 0;
options = 'SPECIFIED';

% Under Relaxation Input
dbdtheta = 0.7;
dbdkappa = 0.0001;
dbdgamma = 0.0;
momfact = 0.1;

%Residual Control
backflag = 0;
maxbackiter = 50;
backtol = 1.2;
backreduce = 0.75;

% Linear Solution Control and Options for GMRES
maxitinner = 50;
ilumethod = 2;
levfill = 1;
stoptol = 1e-10;
msdr = 10;

% Linear Solution Control and Options for xMD
iacl = 2;
norder = 1;
level = 1;
north = 2;
iredsys = 0;
rrctols = 0.0;
idroptol = 1;
epsrn = 1e-3;
hclosexmd = 1e-4;
mxiterxmd = 50;

filename = '/home/gcng/workspace/ProjectFiles/AndesWaterResources/GSFLOW/inputs/MODFLOW/test2lay.nwt';

headings = {'NWT Input File'; 'Test Problem 3 for MODFLOW-NWT'};

% -------------------------------------------------------------------------

fid = fopen(filename, 'w');

% item 0 -------
for i=1:length(headings)
    fprintf(fid, '%s\n', horzcat('# ', headings{i}));
end

% item 1 -------
fprintf(fid, '%10.3e  %10.3e  %4d  %10.3e  %d  %d  %d  ', ...
    headtol, fluxtol, maxiterout, thickfact, linmeth, iprnwt, ibotav);

fprintf(fid, '%s  ', options);

if strcmp(options, 'SPECIFIED')
    fprintf(fid, '%10.3g  %10.3g  %10.3g  %10.3g  %d  ', ...
        dbdtheta, dbdkappa, dbdgamma, momfact, backflag);
    
    if backflag > 0
        fprintf(fid, '%d  %10.3g  %10.3', maxbackiter, backtol, backreduce);
    end
    
    fprintf(fid, '\n');
    
    % item 2a -------
    if linmeth == 1
        fprintf(fid, '%4d  %d  %d  %10.3g  %2d', ...
            maxitinner, ilumethod, levfill, stoptol, msdr);
    % item 2b -------
    elseif linmeth == 2
        fprintf(fid, '%d  %d  %2d  %2d  %d  %10.3g  %d  %10.3g  %10.3g  %4d', ...
            iacl, norder, level, north, iredsys, rrctols, idroptol, ...
            epsrn, hclosexmd, mxiterxmd);
    end
end

fprintf(fid, '\n');

fclose(fid);