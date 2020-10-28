function all_sub_analysis(indiv)
% ----------------------------------------------------------------------
% all_sub_analysis(indiv)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute automaticaly results of OSF database
% >> Put add to path during first execution
% >> Data must be in ../OSF_raw_data/
% ----------------------------------------------------------------------
% Input(s) :
% indiv = do individual analysis (0 = no, 1 = yes)
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

warning ('off','all');

% Data folder settings
dirF = (which('all_sub_analysis')); 
sub.dirF = dirF(1:end-32);
addpath(genpath(sprintf('%s/',sub.dirF)));

sub.numSjct         =   8;                                      % number of subjects
sub.tasks           =   { 'Visual','Auditory','AudioVisual'};   % task names
sub.blocks          =   4;                                      % number of blocks per task
sub.numBoot         =   10000;                                  % number of bootstrap iterations
sub.preSac          =   [-150,0];                               % time before first saccade to include
sub.interSac        =   [0,-100];                               % time after sac1 and before sac 2

% Sreen settings
scr.dist            = 76.5;                                     % Display distance
scr.scr_sizeX       = 910;                                      % Display pixel equivalent size X
scr.scr_sizeY       = 910;                                      % Display pixel equivalent size Y
scr.disp_sizeX      = 455;                                      % Display size X in mm
scr.disp_sizeY      = 455;                                      % Display size Y in mm
sub.scr_sizeX       = scr.scr_sizeX;
sub.scr_sizeY       = scr.scr_sizeY;

% Eye analayiss 
sub.SAMPRATE        = 1000;                                     % Sampling rate of Eye Tracker.
sub.velSD           = 3;                                        % Lambda threshold for microsaccade detection.
sub.minDur          = 20;                                       % Duration threshold for microsaccade detection.
sub.VELTYPE         = 2;                                        % Velocity type for saccade detection.
sub.maxMSAmp        = 1;                                        % Maximum microsaccade amplitude.
sub.crit_cols       = [2 3];                                    % Collumn in dat file containing critical information (x and y of the eye)
sub.mergeInt        = 20;                                       % Merge interval for subsequent saccadic events.
sub.sacRadBefVal    = 3.5;                                      % Size of saccade fixation tolerance before saccade (degrees)
sub.sacRadBfr       = vaDeg2pix(sub.sacRadBefVal,scr);          % Size of saccade fixation tolerance before saccade (pixels)
sub.sacRadAftVal    = 3.5;                                      % Size of saccade fixation tolerance after saccade (degrees)
sub.sacRadAft       = vaDeg2pix(sub.sacRadAftVal,scr);          % Size of saccade fixation tolerance after saccade (pixels)
DPP = pix2vaDeg(1,scr);sub.DPP = DPP(1);                        % Degrees per pixel
sub.PPD             = vaDeg2pix(1,scr);                         % Pixels per degree
sub.xMat_range      = -sub.sacRadBefVal:sub.DPP:sub.sacRadBefVal;
sub.yMat_range      = -sub.sacRadBefVal:sub.DPP:15+sub.sacRadAftVal;

% Led positions
sub.ledPos          = [855,55;455,55;55,55;655,255;255,255;
                       855,455;455,455;55,455;655,655;255,655;
                       855,855;455,855;55,855];                 % Led positions in pixels


% Create group folder
if ~isdir(sprintf('%s/OSF_deriv_data/',sub.dirF));
    mkdir(sprintf('%s/OSF_deriv_data/',sub.dirF));
end

% Individual analysis
if indiv
    for numSjct = 1:sub.numSjct
        fprintf('\n\n\tsub-0%i analysis\n',numSjct);
        indiv_analysis(numSjct,sub)
    end
end

% Group analysis
sub.ini = 'sub-00';
sub.deriv_filedir = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sub.ini);
if ~isdir(sub.deriv_filedir);mkdir(sub.deriv_filedir);end
fprintf('\n\n\t%s analysis\n',sub.ini);

for normType = 1:2
    % 1 = raw data
    % 2 = data normalized
    
    % Extract mean and do statistics
	extractorAll(sub,normType)
    
end

% Plot Figure 2
plot_figure2(sub)
 
% Plot Figure 3
plot_figure3(sub)

% Plot Figure S1
plot_figureS1(sub)

% Plot Figure S2
plot_figureS2(sub)

% Get statistical values
get_stats(sub)
get_stats_supp(sub)
    
end