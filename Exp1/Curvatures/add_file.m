function sub = add_file(sub)
% ----------------------------------------------------------------------
% add_file(sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Add different parts corresponding to different experimental blocks, 
% ----------------------------------------------------------------------
% Input(s) :
% sub : subject configurations
% ----------------------------------------------------------------------
% Output(s):
% sub : subject configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------


part_all = [];
partCoord_all = [];

for taskNum = 1:size(sub.tasks,2)
    sub.taskName = sub.tasks{taskNum};

    for blockNum = 1:sub.blocks
        sub.blockNum = sprintf('block0%i',blockNum);

        % Define raw and deriv file names
        sub.tab_deriv_filename = sprintf('%s/%s_task-%s_%s_Tab',sub.deriv_filedir,sub.ini,sub.taskName,sub.blockNum);
        sub.coord_deriv_filename = sprintf('%s/%s_task-%s_%s_Coord',sub.deriv_filedir,sub.ini,sub.taskName,sub.blockNum);
                
        part = dlmread(sprintf('%s.csv',sub.tab_deriv_filename));
        part_all = [part_all;part];
    
        load(sprintf('%s.mat',sub.coord_deriv_filename));
        partCoord_all = [partCoord_all,coord];

    end
end

% Delete deriv file to save space
[~,~] = system(sprintf('rm -R %s/',sub.deriv_filedir));
if ~isdir(sub.deriv_filedir);mkdir(sub.deriv_filedir);end

if ~isdir(sub.deriv_filedir);mkdir(sub.deriv_filedir);end
    
dlmwrite(sprintf('%s.csv',sub.tab_deriv_filename_all),part_all,'precision','%10.5f');
save(sprintf('%s.mat',sub.coord_deriv_filename_all),'partCoord_all');

end