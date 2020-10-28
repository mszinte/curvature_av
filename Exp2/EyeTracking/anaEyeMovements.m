function anaEyeMovements(sub)
% ----------------------------------------------------------------------
% anaEyeMovements(sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Data analysis of eye tracker data
% ----------------------------------------------------------------------
% Input(s) :
% sub : struct containing subject and analysis information.
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

%% Create file strings
fprintf(1,'\n\t>>> Pre-processing %s %s dat file',sub.taskName,sub.blockNum);
datfile = sprintf('%s.dat',sub.edf_deriv_filename);dat = load(datfile);
resMat = csvread(sprintf('%s.csv',sub.behav_raw_filename));
load(sprintf('%s.mat',sub.msgtab_deriv_filename));tab  = msgTab;

%% Loop on all trials
matCor      = [];
coord    = [];
nt          = 0;
tCorPP      = 0;

for t = 1:(size(tab,1))
    
    nt = nt + 1;
    
    % fixation target position
    rand4 = resMat(t,7);
    
    if      rand4 == 1; numFix = 8;
    elseif  rand4 == 2; numFix = 6;
    end
    fix1Pos = sub.ledPos(numFix,:);

    % saccade target(s) position
    rand5 = resMat(t,8);
    numSac1 = 7;
    if rand5 == 1
        numSac2 = 2;
    elseif rand5 == 2
        numSac2 = 12;
    end
    tar1Pos = sub.ledPos(numSac1,:);
    fix2Pos = sub.ledPos(numSac1,:);
    tar2Pos = sub.ledPos(numSac2,:);
    
    % 1st saccade
    fix1Rad = sub.sacRadBfr;
    tar1Rad = sub.sacRadAft;
    fix1Rec = [fix1Pos fix1Pos] + [-fix1Rad -fix1Rad fix1Rad fix1Rad];
    tar1Rec = [tar1Pos tar1Pos] + [-tar1Rad -tar1Rad tar1Rad tar1Rad];
    
    % 2nd saccade
    fix2Rad = sub.sacRadBfr;
    tar2Rad = sub.sacRadAft;
    fix2Rec = [fix2Pos fix2Pos] + [-fix2Rad -fix2Rad fix2Rad fix2Rad];
    tar2Rec = [tar2Pos tar2Pos] + [-tar2Rad -tar2Rad tar2Rad tar2Rad];
    
    
    tTrialStart         =   tab(t,7);
    tTrialEnd           =   tab(t,20);      durTrial       =   tTrialEnd - tTrialStart;
    
    tFixTarOnset        =   tab(t,13);
    tSac1TarOnset       =   tab(t,14);      durFTST1       =   tSac1TarOnset - tFixTarOnset;
    tSac2TarOnset       =   tab(t,15);      durFTST2       =   tSac2TarOnset - tFixTarOnset;
    
    rand1 = resMat(t,4);
    if rand1 == 1 || rand1 == 3
        tDistOnset          =   tab(t,16);
        tDistOffset         =   tab(t,17);      durDist        =   tDistOffset - tDistOnset;
        durST1DIST_soa      =   tDistOnset - tSac1TarOnset;
        durST2DIST_soa      =   tDistOnset - tSac2TarOnset;
    elseif rand1 == 2 || rand1 == 4
        tDistOnset          =   tab(t,18);
        tDistOffset         =   tab(t,19);      durDist        =   tDistOffset - tDistOnset;
        durST1DIST_soa      =   tDistOnset - tSac1TarOnset;
        durST2DIST_soa      =   tDistOnset - tSac2TarOnset;
    else
        tDistOnset          =   0;
        tDistOffset         =   0;              durDist        =   -8;
        durST1DIST_soa      =   -8;
        durST2DIST_soa      =   -8;
    end
    
    tSac1Onset          =   tab(t,8);
    tSac1Offset         =   tab(t,9);       durSac1Online =   tSac1Offset - tSac1Onset;
    
    tSac2Onset          =   tab(t,10);
    tSac2Offset         =   tab(t,11);      durSac2Online =   tSac2Offset - tSac2Onset;
    
    tTrialEndBlock      =   tab(t,3);
    tWaitAnswer         =   tab(t,23);      durRT         =   tTrialEndBlock-tWaitAnswer;
    
    %% Exclusion indicator
    onlineError         = 0; % #1    Online error (error fixation, too slow saccade, too slow responses)
    
    missDurTrial        = 0; % #2    Blinks during all trials
    missTimeStamps      = 0; % #3    Missing times stamps trials during all trials
    
    noSac1Detect        = 0; % #4    no saccade 1 detected
    inaccurateSac1Trial = 0; % #4bis Inaccuracy of the saccade 1
    accurateSac1Trial   = 0; % #4ter Accuracy of the saccade 1
    
    noSac2Detect        = 0; % #5    no saccade 2 detected
    inaccurateSac2Trial = 0; % #5bis Inaccuracy of the saccade 2
    accurateSac2Trial   = 0; % #5ter Accuracy of the saccade 2
    
    % All criterion
    goodTrial           = 0; % All criterion okay
    badTrial            = 0; % Not all criterion okay
    
    % #1 Online error
    if resMat(t,13) ~= 1
        onlineError = 1;
    end
    
    % #2 Blink during trial (check between saccade cue and end of trial)
    idx  = find(dat(:,1) >= tTrialStart & dat(:,1) <= tTrialEnd);
    idxmbdi = find(dat(idx,sub.crit_cols)==-1, 1);
    if ~onlineError
        if ~isempty(idxmbdi);
            missDurTrial = 1;
        end
    end
    
    % #3 Missing time stamps trial
    time = dat(idx,1);
    if ~onlineError
        if sum(diff(time)>(1000/sub.SAMPRATE)) || isempty(time);
            missTimeStamps  = 1;
        end
    end
    
    % trace saving
    idx2  = find(dat(:,1) >= tTrialStart & dat(:,1) <= tTrialEnd);
    time2 = dat(idx2,1);
    matSave = [time2, dat(idx2,2), dat(idx2,3)];
    
    if ~missTimeStamps && ~missDurTrial && ~onlineError
    
        % #4 & #4bis & #4ter Saccade1 detection & Accuracy/inacuracy of saccade 1
        sAcc1 = [];
        
        x1 = sub.DPP*([dat(idx,2), (dat(idx,3))]);
        v1 = vecvel(x1, sub.SAMPRATE, sub.VELTYPE);
        ms1 = microsaccMerge(x1,v1,sub.velSD,sub.minDur,sub.mergeInt);
        ms1 = saccpar(ms1);
        
        % (ms1,1)    =   saccade onset
        % (ms1,2)    =   saccade offset
        % (ms1,3)    =   saccade duration
        % (ms1,4)    =   peak velocity
        % (ms1,5)    =   saccade distance
        % (ms1,6)    =   distance angle
        % (ms1,7)    =   saccade amplitude
        % (ms1,8)    =   amplitude angle
        
        if size(ms1,1)>0
            amp  = ms1(:,7);
            ms1   = ms1(amp>sub.maxMSAmp,:);
        end
        
        if size(ms1,1) > 0 && ~isempty(ms1)
            
            nSac1   = size(ms1,1);
            % check for response saccade
            if nSac1 > 0
                s1 = 0;
                while s1 < nSac1
                    s1 = s1+1;
                    xBeg1  = sub.PPD*x1(ms1(s1,1),1);                  % beginning eye position x1
                    yBeg1  = sub.PPD*x1(ms1(s1,1),2);                  % beginning eye position y1
                    xEnd1  = sub.PPD*x1(ms1(s1,2),1);                  % final eye position x1
                    yEnd1  = sub.PPD*x1(ms1(s1,2),2);                  % final eye position y1
                    
                    fixedFix1 = isincircle(xBeg1,yBeg1,fix1Rec);
                    fixedTar1 = isincircle(xEnd1,yEnd1,tar1Rec);
                    
                    if fixedTar1 && fixedFix1
                        sAcc1 = s1;
                    end
                end
            end
            
            if ~isempty(sAcc1)
                accurateSac1Trial   = 1;
                sac1Onset           = time(ms1(sAcc1,1));
                sac1Offset          = time(ms1(sAcc1,2));
                sac1Dur             = ms1(sAcc1,3);
                sac1Latency         = sac1Onset - tSac1TarOnset;
                sac1OffOnLatency    = tSac1Onset - sac1Onset;
                distOnSac1On        = tDistOnset - sac1Onset;
                distOffSac1On       = tDistOffset - sac1Onset;
                distOnSac1Off       = tDistOnset - sac1Offset;
                distOffSac1Off      = tDistOffset - sac1Offset;
                
                sac1VPeak           = ms1(sAcc1,4);
                sac1Dist            = ms1(sAcc1,5);
                sac1Angle1          = ms1(sAcc1,6);
                sac1AmpGet          = ms1(sAcc1,7);
                sac1xOnset          = sub.PPD*x1(ms1(sAcc1,1),1);
                sac1yOnset          = sub.PPD*x1(ms1(sAcc1,1),2);
                sac1xOffset         = sub.PPD*x1(ms1(sAcc1,2),1);
                sac1yOffset         = sub.PPD*x1(ms1(sAcc1,2),2);
                
            else
                inaccurateSac1Trial = 1;
                sac1Onset           = -8;
                sac1Offset          = -8;
                sac1Dur             = -8;
                sac1Latency         = -8;
                sac1OffOnLatency    = -8;
                distOnSac1On        = -8;
                distOffSac1On       = -8;
                distOnSac1Off       = -8;
                distOffSac1Off      = -8;
                sac1VPeak           = -8;
                sac1Dist            = -8;
                sac1Angle1          = -8;
                sac1AmpGet          = -8;
                sac1xOnset          = -8;
                sac1yOnset          = -8;
                sac1xOffset         = -8;
                sac1yOffset         = -8;
            end
        else
            noSac1Detect        = 1;
            sac1Onset           = -8;
            sac1Offset          = -8;
            sac1Dur             = -8;
            sac1Latency         = -8;
            sac1OffOnLatency    = -8;
            distOnSac1On        = -8;
            distOffSac1On       = -8;
            distOnSac1Off       = -8;
            distOffSac1Off      = -8;
            sac1VPeak            = -8;
            sac1Dist             = -8;
            sac1Angle1           = -8;
            sac1AmpGet           = -8;
            sac1xOnset           = -8;
            sac1yOnset           = -8;
            sac1xOffset          = -8;
            sac1yOffset          = -8;
        end
        
        % #5 & #5bis & #5ter Saccade2 detection & Accuracy/inacuracy of saccade 2
        
        sAcc2 = [];
        
        x2 = sub.DPP*([dat(idx,2), (dat(idx,3))]);
        
        v2 = vecvel(x2, sub.SAMPRATE, sub.VELTYPE);
        ms2 = microsaccMerge(x2,v2,sub.velSD,sub.minDur,sub.mergeInt);
        ms2 = saccpar(ms2);
        
        % (ms2,1)    =   saccade onset
        % (ms2,2)    =   saccade offset
        % (ms2,3)    =   saccade duration
        % (ms2,4)    =   peak velocity
        % (ms2,5)    =   saccade distance
        % (ms2,6)    =   distance angle
        % (ms2,7)    =   saccade amplitude
        % (ms2,8)    =   amplitude angle
        
        if size(ms2,1)>0
            amp  = ms2(:,7);
            ms2   = ms2(amp>sub.maxMSAmp,:);
        end
        
        if size(ms2,1) > 0 && ~isempty(ms2) % only a microsaccade
            
            nSac2   = size(ms2,1);
            % check for response saccade
            if nSac2 > 0
                s2 = 0;
                while s2 < nSac2
                    s2 = s2+1;
                    xBeg2  = sub.PPD*x2(ms2(s2,1),1);                  % beginning eye position x2
                    yBeg2  = sub.PPD*x2(ms2(s2,1),2);                  % beginning eye position y2
                    xEnd2  = sub.PPD*x2(ms2(s2,2),1);                  % final eye position x2
                    yEnd2  = sub.PPD*x2(ms2(s2,2),2);                  % final eye position y2
                    
                    fixedFix2 = isincircle(xBeg2,yBeg2,fix2Rec);
                    fixedTar2 = isincircle(xEnd2,yEnd2,tar2Rec);
                    
                    if fixedTar2 && fixedFix2
                        sAcc2 = s2;
                    end
                end
            end
            
            if ~isempty(sAcc2)
                accurateSac2Trial   = 1;
                sac2Onset           = time(ms2(sAcc2,1));
                sac2Offset          = time(ms2(sAcc2,2));
                sac2Dur             = ms2(sAcc2,3);
                sac2Latency         = sac2Onset - tSac2TarOnset;
                sac2OffOnLatency    = tSac2Onset - sac2Onset;
                distOnSac2On        = tDistOnset - sac2Onset;
                distOffSac2On       = tDistOffset - sac2Onset;
                distOnSac2Off       = tDistOnset - sac2Offset;
                distOffSac2Off      = tDistOffset - sac2Offset;
                
                sac2VPeak           = ms2(sAcc2,4);
                sac2Dist            = ms2(sAcc2,5);
                sac2Angle1          = ms2(sAcc2,6);
                sac2AmpGet          = ms2(sAcc2,7);
                sac2xOnset          = sub.PPD*x2(ms2(sAcc2,1),1);
                sac2yOnset          = sub.PPD*x2(ms2(sAcc2,1),2);
                sac2xOffset         = sub.PPD*x2(ms2(sAcc2,2),1);
                sac2yOffset         = sub.PPD*x2(ms2(sAcc2,2),2);
                
            else
                inaccurateSac2Trial = 1;
                sac2Onset           = -8;
                sac2Offset          = -8;
                sac2Dur             = -8;
                sac2Latency         = -8;
                sac2OffOnLatency    = -8;
                distOnSac2On        = -8;
                distOffSac2On       = -8;
                distOnSac2Off       = -8;
                distOffSac2Off      = -8;
                sac2VPeak           = -8;
                sac2Dist            = -8;
                sac2Angle1          = -8;
                sac2AmpGet          = -8;
                sac2xOnset          = -8;
                sac2yOnset          = -8;
                sac2xOffset         = -8;
                sac2yOffset         = -8;
            end
        else
            noSac2Detect        = 1;
            sac2Onset           = -8;
            sac2Offset          = -8;
            sac2Dur             = -8;
            sac2Latency         = -8;
            sac2OffOnLatency    = -8;
            distOnSac2On        = -8;
            distOffSac2On       = -8;
            distOnSac2Off       = -8;
            distOffSac2Off      = -8;
            sac2VPeak           = -8;
            sac2Dist            = -8;
            sac2Angle1          = -8;
            sac2AmpGet          = -8;
            sac2xOnset          = -8;
            sac2yOnset          = -8;
            sac2xOffset         = -8;
            sac2yOffset         = -8;
        end

    else
        sac1Onset           = -8;
        sac1Offset          = -8;
        sac1Dur             = -8;
        sac1Latency         = -8;
        sac1OffOnLatency    = -8;
        distOnSac1On        = -8;
        distOffSac1On       = -8;
        distOnSac1Off       = -8;
        distOffSac1Off      = -8;
        sac1VPeak           = -8;
        sac1Dist            = -8;
        sac1Angle1          = -8;
        sac1AmpGet          = -8;
        sac1xOnset          = -8;
        sac1yOnset          = -8;
        sac1xOffset         = -8;
        sac1yOffset         = -8;
        sac2Onset           = -8;
        sac2Offset          = -8;
        sac2Dur             = -8;
        sac2Latency         = -8;
        sac2OffOnLatency    = -8;
        distOnSac2On        = -8;
        distOffSac2On       = -8;
        distOnSac2Off       = -8;
        distOffSac2Off      = -8;
        sac2VPeak           = -8;
        sac2Dist            = -8;
        sac2Angle1          = -8;
        sac2AmpGet          = -8;
        sac2xOnset          = -8;
        sac2yOnset          = -8;
        sac2xOffset         = -8;
        sac2yOffset         = -8;
    end
    
    % All Saccades detected
    valSac = [  sac1Onset,      sac1Offset,     sac1Dur,            sac1Latency,        sac1OffOnLatency,...
                distOnSac1On,   distOffSac1On,  distOnSac1Off,      distOffSac1Off,     sac1VPeak,...
                sac1Dist,       sac1Angle1,     sac1AmpGet,         sac1xOnset,         sac1yOnset,...
                sac1xOffset,    sac1yOffset,    ...     % 17
                sac2Onset,      sac2Offset,     sac2Dur,            sac2Latency,        sac2OffOnLatency,...
                distOnSac2On,   distOffSac2On,  distOnSac2Off,      distOffSac2Off,     sac2VPeak,...
                sac2Dist,       sac2Angle1,     sac2AmpGet,         sac2xOnset,         sac2yOnset,...
                sac2xOffset,    sac2yOffset,    ...     % 24
                durTrial,       durFTST1,       durFTST2,           durDist,            durST1DIST_soa,...
                durST2DIST_soa, durSac1Online,  durSac2Online       durRT]; % 32

    
    if accurateSac1Trial && accurateSac2Trial
        goodTrial = 1;
    else
        badTrial = 1;
    end
    
    typeT = [goodTrial,           badTrial,           missDurTrial,         missTimeStamps, onlineError,...
             inaccurateSac1Trial, accurateSac1Trial,  noSac1Detect,...
             inaccurateSac2Trial, accurateSac2Trial,  noSac2Detect,...
             ];
    
    matTypeTrial(t,:) = [resMat(t,:),tab(t,:),valSac,typeT];
    
    if goodTrial
        tCorPP = tCorPP+1;
        matCor = [[matCor];matTypeTrial(t,:)];
        coord{tCorPP} = {matTypeTrial(t,:);matSave};
    end
    
    
end

% Saving procedure
dlmwrite(sprintf('%s.csv',sub.tab_deriv_filename),matCor,'precision','%10.5f');
save(sprintf('%s.mat',sub.coord_deriv_filename),'coord');

end