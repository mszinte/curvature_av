function indiv_analysis(numSjct,sub)
% ----------------------------------------------------------------------
% indiv_analysis(numSjct,sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Do individual subject analysis
% ----------------------------------------------------------------------
% Input(s) :
% numSjct : subject number
% sub : struct containing analysis settings
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------
close all
warning ('off','all');
sub.ini = sprintf('sub-0%i',numSjct);
edf2asc_dir = '/Applications/Eyelink/EDF_Access_API/Example';

sub.raw_filedir = sprintf('%s/OSF_raw_data/%s',sub.dirF,sub.ini);
sub.deriv_filedir = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sub.ini);
if ~isdir(sub.deriv_filedir);mkdir(sub.deriv_filedir);end

% get block number
sub.blocks = size(dir([sub.raw_filedir '/*.edf']),1);

% Trial analysis
for taskNum = 1:size(sub.tasks,2)
    sub.taskName = sub.tasks{taskNum};

    for blockNum = 1:sub.blocks
        sub.blockNum = sprintf('block0%i',blockNum);

        % Define raw and deriv file names
        sub.behav_raw_filename = sprintf('%s/%s_task-%s_%s_BehavData',sub.raw_filedir,sub.ini,sub.taskName,sub.blockNum);
        sub.edf_raw_filename = sprintf('%s/%s_task-%s_%s_EyeData',sub.raw_filedir,sub.ini,sub.taskName,sub.blockNum);
        sub.edf_deriv_filename = sprintf('%s/%s_task-%s_%s_EyeData',sub.deriv_filedir,sub.ini,sub.taskName,sub.blockNum);
        sub.msgtab_deriv_filename = sprintf('%s/%s_task-%s_%s_MsgTab',sub.deriv_filedir,sub.ini,sub.taskName,sub.blockNum);
        sub.tab_deriv_filename = sprintf('%s/%s_task-%s_%s_Tab',sub.deriv_filedir,sub.ini,sub.taskName,sub.blockNum);
        sub.coord_deriv_filename = sprintf('%s/%s_task-%s_%s_Coord',sub.deriv_filedir,sub.ini,sub.taskName,sub.blockNum);

        % Data conversion
        fprintf('\n');
        [~,~] = system(sprintf('%s/edf2asc %s.edf -e -y',edf2asc_dir,sub.edf_raw_filename));
        movefile(sprintf('%s.asc',sub.edf_raw_filename),sprintf('%s.msg',sub.edf_deriv_filename));
        [~,~] = system(sprintf('%s/edf2asc %s.edf -s -miss -1.0 -y',edf2asc_dir,sub.edf_raw_filename));
        movefile(sprintf('%s.asc',sub.edf_raw_filename),sprintf('%s.dat',sub.edf_deriv_filename));
        
        % Create a tab file from msgFile
        xmsg2tab(sub);
        
        % Data analysis
        anaEyeMovements(sub)
        
    end
end

% Put block together
sub.tab_deriv_filename_all = sprintf('%s/%s_Tab',sub.deriv_filedir,sub.ini);
sub.coord_deriv_filename_all = sprintf('%s/%s_Coord',sub.deriv_filedir,sub.ini);
add_file(sub);

% Compute curvatures and extract data
for normType = 1:2
    % 1 = raw data
    % 2 = data normalized

    % Saccade curvature processing
    sub.curv_deriv_filename_all = sprintf('%s/%s_Curv',sub.deriv_filedir,sub.ini);
    curvProcessing(sub,normType)

    % Extract means
    extractor(sub,normType)
end

end