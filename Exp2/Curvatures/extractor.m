function extractor(sub,normType)
% ----------------------------------------------------------------------
% extractor(sub,normType)
% ----------------------------------------------------------------------
% Goal of the function :
% Extract results and make averages
% ----------------------------------------------------------------------
% Input(s) :
% sub : subject configuration
% normType : normalization type
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

txtNormType = {'','_norm'};
txtNormAna = {'raw data ','normalized data'};
fprintf(1,'\n\tData extraction: %s',txtNormAna{normType});

fileDir = sprintf('%s.csv',sub.tab_deriv_filename_all);
fileRes = csvread(fileDir);
fileRes = fileRes(:,1:100);
load(sprintf('%s%s.mat',sub.curv_deriv_filename_all,txtNormType{normType}));

rand1Col  = 4;    % presence, modality and period of dt
nb.rand1  = 5;
% 1 = present - visual (before)
% 2 = present - visual (after)
% 3 = present - auditory (before)
% 4 = present - auditory (after)
% 5 = absent

rand2Col = 5;   % distractor before position
nb.rand2 = 2;
% 1 = cw
% 2 = ccw

rand3Col = 6;   % distractor after position
nb.rand2 = 2;
% 1 = cw
% 2 = ccw

rand4Col = 7;   % hor. saccade
nb.rand3 = 2;
% 1 = saccade right 
% 2 = saccade left

rand5Col = 8;
nb.rand4 = 2;
% 1 = saccade up
% 2 = saccade down

% Add saccade type
matSac2Cond = [];
for tT = 1:size(fileRes,1)
    rand4 = fileRes(tT,rand4Col); % Hor. saccade direction
    rand5 = fileRes(tT,rand5Col); % Ver. saccade direction
    
    switch rand4
        case 1                          % sac1 right
            switch rand5
                case 1;sac2CondNum = 1; % sac2 up
                case 2;sac2CondNum = 2; % sac2 down
            end
        case 2                          % sac1 left
            switch rand5
                case 1;sac2CondNum = 3; % sac2 up
                case 2;sac2CondNum = 4; % sac2 down
            end
    end
    matSac2Cond = [matSac2Cond;sac2CondNum];
end
fileRes = [fileRes,matSac2Cond];
sac2CondCol = size(fileRes,2);
nb.sac2Cond = 4;
% sac2CondNum
% 1 = up of right-up
% 2 = down of right-down
% 3 = up of left-up
% 4 = down of left-down

% Add inter/intra/none hemisphere of distractor transfert
memTransAll = [];
for tFileRes = 1:size(fileRes,1)
    rand1 = fileRes(tFileRes,rand1Col); % Distractor presence, period and modality
    rand2 = fileRes(tFileRes,rand2Col); % Distractor before position  [1 = CW; 2 = CCW]
    rand3 = fileRes(tFileRes,rand3Col); % Distractor after position  [1 = CW; 2 = CCW]
    rand4 = fileRes(tFileRes,rand4Col); % Hor. saccade direction
    rand5 = fileRes(tFileRes,rand5Col); % Ver. saccade direction
    
    if rand1 == 1 || rand1 == 3                         % distractor present before
        switch rand2
            case 1                                      % cw
                switch rand4
                    case 1                              % right saccade
                        switch rand5
                            case 1;memTrans = 1;        % up saccade    = intra
                            case 2;memTrans = 2;        % down saccade  = inter
                        end
                    case 2                              % left saccade
                        switch rand5
                            case 1;memTrans = 2;        % up saccade    = inter
                            case 2;memTrans = 1;        % down saccade  = intra
                        end
                end
            case 2                                      % ccw
                switch rand4
                    case 1                              % right saccade
                        switch rand5
                            case 1; memTrans = 2;       % up saccade    = inter
                            case 2; memTrans = 1;       % down saccade  = intra
                        end
                    case 2                              % left saccade
                        switch rand5
                            case 1; memTrans = 1;       % up saccade    = intra
                            case 2; memTrans = 2;       % down saccade  = inter
                        end
                        
                end
        end
    elseif rand1 == 2 || rand1 == 4                     % distractor present after
        switch rand3
            case 1                                      % cw
                switch rand4
                    case 1                              % right saccade
                        switch rand5
                            case 1;memTrans = 1;        % up saccade    = intra
                            case 2;memTrans = 2;        % down saccade  = inter
                        end
                    case 2                              % left saccade
                        switch rand5
                            case 1;memTrans = 2;        % up saccade    = inter
                            case 2;memTrans = 1;        % down saccade  = intra
                        end
                end
            case 2                                      % ccw
                switch rand4
                    case 1                              % right saccade
                        switch rand5
                            case 1; memTrans = 2;       % up saccade    = inter
                            case 2; memTrans = 1;       % down saccade  = intra
                        end
                    case 2                              % left saccade
                        switch rand5
                            case 1; memTrans = 1;       % up saccade    = intra
                            case 2; memTrans = 2;       % down saccade  = inter
                        end
                end
        end
    elseif rand1 == 5                                   % distractor absent
        memTrans = 3;                                   % no distractor  = none
    end
    memTransAll = [memTransAll;memTrans];
end
fileRes     = [fileRes,memTransAll];
memTransCol = size(fileRes,2);
nb.memTrans = 3;
% Memory transfert across first saccade
% 1 = intra-hemifield
% 2 = inter-hemifield
% 3 = None (distractor absent)

% Save modified fileRes
fileDir= sprintf('%s.csv',sub.tab_deriv_filename_all);
csvwrite(fileDir,fileRes);

% Add distractor presence
distPresAll = [];
for tFileRes = 1:size(fileRes,1)
    rand1 = fileRes(tFileRes,rand1Col);
    switch rand1
        case 1;distPres = 1;    % present
        case 2;distPres = 1;    % present
        case 3;distPres = 1;    % present
        case 4;distPres = 1;    % present
        case 5;distPres = 2;    % absent
    end
    distPresAll = [distPresAll;distPres];
end
fileRes     = [fileRes,distPresAll];
distPresCol = size(fileRes,2);
nb.distPres = 2;
% distractor presence
% 1 = present
% 2 = absent


% Add sensory modality
sensModAll = [];
for tFileRes = 1:size(fileRes,1)
    rand1 = fileRes(tFileRes,rand1Col);
    switch rand1
        case 1;sensMod = 1;    % visual before
        case 2;sensMod = 1;    % visual after
        case 3;sensMod = 2;    % auditory before
        case 4;sensMod = 2;    % auditory after
        case 5;sensMod = 3;    % none
    end
    sensModAll = [sensModAll;sensMod];
end
fileRes     = [fileRes,sensModAll];
sensModCol = size(fileRes,2);
nb.sensMod = 3;
% distractor modality
% 1 = visual
% 2 = auditory
% 3 = none (absent)

% Distractor1 position relative to the seconde saccade
distPosAll = [];
for tFileRes = 1:size(fileRes,1)
    rand1 = fileRes(tFileRes,rand1Col);
    rand2 = fileRes(tFileRes,rand2Col);
    rand3 = fileRes(tFileRes,rand3Col);
    switch rand1
        case 1;distPos = rand2;     % visual before
        case 2;distPos = rand3;     % visual after
        case 3;distPos = rand2;     % auditory before
        case 4;distPos = rand3;     % auditory after
        case 5;distPos = 3;         % none
    end
    distPosAll = [distPosAll;distPos];
end
fileRes     = [fileRes,distPosAll];
distPosCol = size(fileRes,2);
nb.distPos = 3;
% distractor position 
% 1 = cw
% 2 = ccw
% 3 = none (absent)

% Extract saccades path of different saccade 2 type
% -------------------------------------------------
for sac2Cond = 1:nb.sac2Cond                                        % sac 2 type
    index.sac2Cond = fileRes(:,sac2CondCol) == sac2Cond;
    
    for distPres = 1:nb.distPres                                 % distractor presence
        index.distPres = fileRes(:,distPresCol) == distPres;
        
        allData = find(index.sac2Cond & index.distPres);
        
        if isempty(allData)
            tNum = 0;  coordRaw = NaN;
        else
            xCoordRaw = []; yCoordRaw = [];
            for tNum = 1:size(allData,1)
                xCoordRaw(:,tNum)          = coordSac{allData(tNum)}{3}(:,1);
                yCoordRaw(:,tNum)          = coordSac{allData(tNum)}{3}(:,2);
            end
            
            % mean coordinates
            coordRaw   = [nanmean(xCoordRaw,2),nanmean(yCoordRaw,2)];
            
        end
        sac2CondMat{sac2Cond,distPres} = {tNum,coordRaw};
    end
end

save(sprintf('%s/%s_sac2CondMat%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2CondMat');
% sac2CondMat
% ===========
% sac2CondMat{sac2Cond,distPres}{1}  => numTrials
% sac2CondMat{sac2Cond,distPres}{2}  => mean coord of sac

% Extract second saccade relatively to sac2 onset for inter-saccadic interval distractor (i.e. after)
% ---------------------------------------------------------------------------------------------------
distOnSac1OffCol = 54; % dist onset relative to saccade 1 offset
distOffSac2OnCol = 70; % dist offset relative to saccade 2 onset
index.interSac = fileRes(:,distOnSac1OffCol) >= sub.interSac(1) & fileRes(:,distOffSac2OnCol) <= sub.interSac(2);

for sensMod = 1:nb.sensMod   % sensory modality
    index.sensMod = fileRes(:,sensModCol) == sensMod;
    
    for distPres = 1:nb.distPres  % distractor presence
        index.distPres = fileRes(:,distPresCol) == distPres;
        if distPres == 1       % present
            allData = find(index.sensMod & index.distPres & index.interSac);
        elseif distPres == 2   % absent
            allData = find(index.distPres);
        end
        
        tNum1 = 0;tNum2 = 0;tNum3 = 0;tNum4 = 0;
        if isempty(allData)
            tNum = 0; coordRaw = NaN; curvMedian = NaN;
        else
            xCoordRaw1 = []; yCoordRaw1 = []; curvMedianVal1 = [];
            xCoordRaw2 = []; yCoordRaw2 = []; curvMedianVal2 = [];
            xCoordRaw3 = []; yCoordRaw3 = []; curvMedianVal3 = [];
            xCoordRaw4 = []; yCoordRaw4 = []; curvMedianVal4 = [];
            
            for tNum = 1:size(allData,1)
                if distPres == 1       % distractor present
                    distPos = fileRes(allData(tNum),distPosCol);
                    switch distPos
                        case 1;multiVal = 1;  % cw
                        case 2;multiVal = -1; % ccw
                    end
                elseif distPres == 2   % distractor absent
                    multiVal = 1;
                end
                
                sacType = fileRes(allData(tNum),sac2CondCol);
                switch sacType
                    case 1;
                        tNum1 = tNum1 + 1;
                        xCoordRaw1(:,tNum1)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw1(:,tNum1)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal1(:,tNum1) = coordSac{allData(tNum)}{4}*multiVal;
                    case 2;
                        tNum2 = tNum2 + 1;
                        xCoordRaw2(:,tNum2)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw2(:,tNum2)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal2(:,tNum2) = coordSac{allData(tNum)}{4}*multiVal;
                    case 3;
                        tNum3 = tNum3 + 1;
                        xCoordRaw3(:,tNum3)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw3(:,tNum3)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal3(:,tNum3) = coordSac{allData(tNum)}{4}*multiVal;
                    case 4;
                        tNum4 = tNum4 + 1;
                        xCoordRaw4(:,tNum4)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw4(:,tNum4)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal4(:,tNum4) = coordSac{allData(tNum)}{4}*multiVal;
                end
            end
            
            % mean coordinates
            coordRaw      = [nanmean([nanmean(xCoordRaw1,2),nanmean(xCoordRaw2,2),nanmean(xCoordRaw3,2),nanmean(xCoordRaw4,2)],2),...
                             nanmean([nanmean(yCoordRaw1,2),nanmean(yCoordRaw2,2),nanmean(yCoordRaw3,2),nanmean(yCoordRaw1,2)],2)];
            
            curvMedian	  = nanmean([nanmean(curvMedianVal1,2),nanmean(curvMedianVal2,2),nanmean(curvMedianVal3,2),nanmean(curvMedianVal4,2)],2);
            
        end
        sac2After{sensMod,distPres} = {tNum,coordRaw,curvMedian};
    end
end

save(sprintf('%s/%s_sac2After%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2After');
% sac2After
% =========
% sac2After{sensMod,distPres}{1}  => numTrials
% sac2After{sensMod,distPres}{2}  => mean coord of sac
% sac2After{sensMod,distPres}{3}  => mean median curvature

% Extract second saccade relatively to sac2 onset for pre-saccadic interval distractor (i.e. before)
% --------------------------------------------------------------------------------------------------
distOffSac1OnCol = 53;
index.preSac   = (fileRes(:,distOffSac1OnCol) >= sub.preSac(1) & fileRes(:,distOffSac1OnCol) <= sub.preSac(2));

% Before for intra-hemifield trials
index.memTrans = fileRes(:,memTransCol) == 1;

for sensMod = 1:nb.sensMod   % sensory modality
    index.sensMod = fileRes(:,sensModCol) == sensMod;
    for distPres = 1:nb.distPres  % distractor presence
        index.distPres = fileRes(:,distPresCol) == distPres;
        
        if distPres == 1 % present
            allData = find(index.memTrans & index.sensMod & index.distPres & index.preSac);
        elseif distPres == 2 % absent
            allData = find(index.distPres);
        end
        
        tNum1 = 0;tNum2 = 0;tNum3 = 0;tNum4 = 0;
        if isempty(allData)
            tNum = 0; coordRaw = NaN; curvMedian = NaN;
        else
            xCoordRaw1 = []; yCoordRaw1 = []; curvMedianVal1 = [];
            xCoordRaw2 = []; yCoordRaw2 = []; curvMedianVal2 = [];
            xCoordRaw3 = []; yCoordRaw3 = []; curvMedianVal3 = [];
            xCoordRaw4 = []; yCoordRaw4 = []; curvMedianVal4 = [];
            
            for tNum = 1:size(allData,1)
                if distPres == 1 % distractor present
                    distPos = fileRes(allData(tNum),distPosCol);
                    switch distPos
                        case 1;multiVal = 1;  %cw
                        case 2;multiVal = -1; %ccw
                    end
                elseif distPres == 2   % distractor absent
                    multiVal = 1;
                end
                sacType = fileRes(allData(tNum),sac2CondCol);
                switch sacType
                    case 1;
                        tNum1 = tNum1 + 1;
                        xCoordRaw1(:,tNum1)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw1(:,tNum1)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal1(:,tNum1) = coordSac{allData(tNum)}{4}*multiVal;
                    case 2;
                        tNum2 = tNum2 + 1;
                        xCoordRaw2(:,tNum2)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw2(:,tNum2)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal2(:,tNum2) = coordSac{allData(tNum)}{4}*multiVal;
                    case 3;
                        tNum3 = tNum3 + 1;
                        xCoordRaw3(:,tNum3)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw3(:,tNum3)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal3(:,tNum3) = coordSac{allData(tNum)}{4}*multiVal;
                    case 4;
                        tNum4 = tNum4 + 1;
                        xCoordRaw4(:,tNum4)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw4(:,tNum4)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal4(:,tNum4) = coordSac{allData(tNum)}{4}*multiVal;
                end
            end
            % mean coordinates
            coordRaw      = [nanmean([nanmean(xCoordRaw1,2),nanmean(xCoordRaw2,2),nanmean(xCoordRaw3,2),nanmean(xCoordRaw4,2)],2),...
                             nanmean([nanmean(yCoordRaw1,2),nanmean(yCoordRaw2,2),nanmean(yCoordRaw3,2),nanmean(yCoordRaw1,2)],2)];
            
            curvMedian    = nanmean([nanmean(curvMedianVal1,2),nanmean(curvMedianVal2,2),nanmean(curvMedianVal3,2),nanmean(curvMedianVal4,2)],2);
        end
        sac2BeforeIntra{sensMod,distPres} = {tNum,coordRaw,curvMedian};
    end
end

save(sprintf('%s/%s_sac2BeforeIntra%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeIntra');
% sac2BeforeIntra
% ===============
% sac2BeforeIntra{sensMod,distPres}{1}  => numTrials
% sac2BeforeIntra{sensMod,distPres}{2}  => mean coord of sac
% sac2BeforeIntra{sensMod,distPres}{3}  => mean median curvature

% Before for inter-hemifield trials
index.memTrans = fileRes(:,memTransCol) == 2;

for sensMod = 1:nb.sensMod   % sensory modality
    index.sensMod = fileRes(:,sensModCol) == sensMod;
    for distPres = 1:nb.distPres  % distractor presence
        index.distPres = fileRes(:,distPresCol) == distPres;
        
        if distPres == 1 % present
            allData = find(index.memTrans & index.sensMod & index.distPres & index.preSac);
        elseif distPres == 2 % absent
            allData = find(index.distPres);
        end
        
        tNum1 = 0;tNum2 = 0;tNum3 = 0;tNum4 = 0;
        if isempty(allData)
            tNum = 0; coordRaw = NaN; curvMedian = NaN;
        else
            xCoordRaw1 = []; yCoordRaw1 = []; curvMedianVal1 = [];
            xCoordRaw2 = []; yCoordRaw2 = []; curvMedianVal2 = [];
            xCoordRaw3 = []; yCoordRaw3 = []; curvMedianVal3 = [];
            xCoordRaw4 = []; yCoordRaw4 = []; curvMedianVal4 = [];
            for tNum = 1:size(allData,1)
                if distPres == 1 % distractor present
                    distPos = fileRes(allData(tNum),distPosCol);
                    switch distPos
                        case 1;multiVal = 1;  %cw
                        case 2;multiVal = -1; %ccw
                    end
                elseif distPres == 2   % distractor absent
                    multiVal = 1;
                end
                sacType = fileRes(allData(tNum),sac2CondCol);
                switch sacType
                    case 1;
                        tNum1 = tNum1 + 1;
                        xCoordRaw1(:,tNum1)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw1(:,tNum1)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal1(:,tNum1) = coordSac{allData(tNum)}{4}*multiVal;
                    case 2;
                        tNum2 = tNum2 + 1;
                        xCoordRaw2(:,tNum2)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw2(:,tNum2)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal2(:,tNum2) = coordSac{allData(tNum)}{4}*multiVal;
                    case 3;
                        tNum3 = tNum3 + 1;
                        xCoordRaw3(:,tNum3)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw3(:,tNum3)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal3(:,tNum3) = coordSac{allData(tNum)}{4}*multiVal;
                    case 4;
                        tNum4 = tNum4 + 1;
                        xCoordRaw4(:,tNum4)     = coordSac{allData(tNum)}{3}(:,1)*multiVal;
                        yCoordRaw4(:,tNum4)     = coordSac{allData(tNum)}{3}(:,2);
                        curvMedianVal4(:,tNum4) = coordSac{allData(tNum)}{4}*multiVal;
                end
            end
            % mean coordinates 
            coordRaw      = [nanmean([nanmean(xCoordRaw1,2),nanmean(xCoordRaw2,2),nanmean(xCoordRaw3,2),nanmean(xCoordRaw4,2)],2),...
                             nanmean([nanmean(yCoordRaw1,2),nanmean(yCoordRaw2,2),nanmean(yCoordRaw3,2),nanmean(yCoordRaw1,2)],2)];
            
            curvMedian    = nanmean([nanmean(curvMedianVal1,2),nanmean(curvMedianVal2,2),nanmean(curvMedianVal3,2),nanmean(curvMedianVal4,2)],2);
        end
        sac2BeforeInter{sensMod,distPres} = {tNum,coordRaw,curvMedian};
    end
end
save(sprintf('%s/%s_sac2BeforeInter%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeInter');
% sac2BeforeInter
% ===============
% sac2BeforeInter{sensMod,distPres}{1}  => numTrials
% sac2BeforeInter{sensMod,distPres}{2}  => mean coord of sac
% sac2BeforeInter{sensMod,distPres}{3}  => mean median curvature


% Extract saccade latencies and inter-saccadic time
if normType == 1
    sac1LatCol = 50; % sac1 latency
    sac2LatCol = 67; % sac2 latency
    sac1OffCol = 48; % sac1 offset
    sac2OnCol  = 64; % sac2 onset

    for sensMod = 1:nb.sensMod % modality
        index.sensMod = fileRes(:,sensModCol) == sensMod;
        
        for distPres = 1:nb.distPres  % distractor presence
            index.distPres = fileRes(:,distPresCol) == distPres;
            
            if distPres == 1
                allData = fileRes(index.distPres & index.sensMod & (index.preSac | index.interSac),:);
            elseif distPres == 2 % absent
                allData = fileRes(index.distPres,:);
            end
            
            values1     =   allData(:,sac1LatCol);                          % 1st sac. latency
            values2     =   allData(:,sac2LatCol);                          % 2nd sac. latency
            values3     =   allData(:,sac2OnCol) - allData(:,sac1OffCol);   % inter-saccadic time
            
            numVal     =    size(values1,1);
            mean1Val    =   nanmean(values1);
            mean2Val    =   nanmean(values2);
            mean3Val    =   nanmean(values3);
            
            sacTimeMat{sensMod,distPres} = {numVal,mean1Val,mean2Val,mean3Val};    
        end
        
    end
    save(sprintf('%s/%s_sacTimeMat.mat',sub.deriv_filedir,sub.ini),'sacTimeMat');
    % sacHistMat
    % ==========
    % sacTimeMat{sensMod,distPres}{1}  => number of trials
    % sacTimeMat{sensMod,distPres}{2}  => 1st saccade latency
    % sacTimeMat{sensMod,distPres}{3}  => 2nd saccade latency
    % sacTimeMat{sensMod,distPres}{4}  => intersaccadic duration
end


end