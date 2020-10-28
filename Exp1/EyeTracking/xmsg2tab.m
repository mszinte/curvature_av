function xmsg2tab(sub)
% ----------------------------------------------------------------------
% xmsg2tab(sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Creates tab-File containing information specified for a certain trial.
% ----------------------------------------------------------------------
% Input(s) :
% sub : subject configurations
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

fprintf(1,'\n\t>>> Pre-processing %s %s msg file',sub.taskName,sub.blockNum);

resMat = csvread(sprintf('%s.csv',sub.behav_raw_filename));
msgfid = fopen(sprintf('%s.msg',sub.edf_deriv_filename),'r');

msgTab = ones(size(resMat,1),20)*-8;
t = 0;

stillTheSameData = 1;
while stillTheSameData
    stillTheSameTrial = 1;
    while stillTheSameTrial
        line = fgetl(msgfid);
        if ~ischar(line)                            % end of file
            stillTheSameData = 0;
            break;
        end
        if ~isempty(line)                           % skip empty lines
            la = strread(line,'%s');                % matrix of strings in line
            if length(la) >= 3
                switch char(la(3))
                    % Trial
                    case 'TRIALID';                         t = t+1;
                                                            msgTab(t,1)  = str2double(char(la(4)));
                    case 'TRIAL_START';                     msgTab(t,2)  = str2double(char(la(2)));
                    case 'TRIAL_END';                       msgTab(t,3)  = str2double(char(la(4)));
                                                            msgTab(t,4)  = resMat(t,1); % resmat block
                                                            msgTab(t,5)  = resMat(t,2); % resmat trial
                                                            stillTheSameTrial = 0;

                    % trial beginning
                    case 'EVENT_FixationCheck';             msgTab(t,6)  = str2double(char(la(2)));
                    case 'EVENT_TRIAL_START';               msgTab(t,7)  = str2double(char(la(2)));
                    
                    % Saccade/fixation check
                    case 'EVENT_ONLINE_SAC1ONSET_BOUND';    msgTab(t,8)  = str2double(char(la(2)));
                    case 'EVENT_ONLINE_SAC1OFFSET_BOUND';   msgTab(t,9)  = str2double(char(la(2)));
                    case 'EVENT_ONLINE_SAC2ONSET_BOUND';    msgTab(t,10) = str2double(char(la(2)));
                    case 'EVENT_ONLINE_SAC2OFFSET_BOUND';   msgTab(t,11) = str2double(char(la(2)));    
                    case 'BEFSAC_FIX_BREAK_START';          msgTab(t,12) = str2double(char(la(2)));

                    % Stimulus
                    case 'FT_START';                        msgTab(t,13) = str2double(char(la(2)));
                    case 'ST1_START';                       msgTab(t,14) = str2double(char(la(2)));
                    case 'ST2_START';                       msgTab(t,15) = str2double(char(la(2)));
                    case 'DIST_START';                      msgTab(t,16) = str2double(char(la(2)));
                    case 'DIST_END';                        msgTab(t,17) = str2double(char(la(2)));

                    % End of trial
                    case 'RUN_TRIAL_END';                   msgTab(t,18) = str2double(char(la(2)));
                    case 'TRIAL_EYEOK';                     msgTab(t,19) = str2double(char(la(2)));
                    case 'TRIAL_EYENOTOK';                  msgTab(t,20) = str2double(char(la(2)));
                        
                end
            end
        end
    end
end

save(sprintf('%s.mat',sub.msgtab_deriv_filename),'msgTab');
fclose(msgfid);

end