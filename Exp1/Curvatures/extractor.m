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
fileRes = fileRes(:,1:93);
load(sprintf('%s%s.mat',sub.curv_deriv_filename_all,txtNormType{normType}));

cond1Col  = 3;    % sensory modality of dt
nb.cond1  = 3;
% 1 = visual
% 2 = auditory
% 3 = audio-visual

rand1Col = 5;   % distractor presence
nb.rand1 = 2;
% 1 = present
% 2 = absent

rand2Col = 6;   % distractor position
nb.rand2 = 2;
% 1 = cw
% 2 = ccw

rand3Col = 7;   % hor. saccade
nb.rand3 = 2;
% 1 = saccade right 
% 2 = saccade left

rand4Col = 8;
nb.rand4 = 2;
% 1 = saccade up
% 2 = saccade down

% Add saccade type
matSac2Cond = [];
for tT = 1:size(fileRes,1)
    rand3 = fileRes(tT,rand3Col); % Hor. saccade direction
    rand4 = fileRes(tT,rand4Col); % Ver. saccade direction
    
    switch rand3 
        case 1                          % sac1 right
            switch rand4
                case 1;sac2CondNum = 1; % sac2 up
                case 2;sac2CondNum = 2; % sac2 down
            end
        case 2                          % sac1 left
            switch rand4
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
    rand1 = fileRes(tFileRes,rand1Col); % Distractor presence
    rand2 = fileRes(tFileRes,rand2Col); % Distractor position  [1 = CW; 2 = CCW]
    rand3 = fileRes(tFileRes,rand3Col); % Hor. saccade direction
    rand4 = fileRes(tFileRes,rand4Col); % Ver. saccade direction
    
    if rand1 == 1                                       % distractor present
        switch rand2
            case 1                                      % cw
                switch rand3
                    case 1                              % right saccade
                        switch rand4
                            case 1;memTrans = 1;        % up saccade    = intra
                            case 2;memTrans = 2;        % down saccade  = inter
                        end
                    case 2                              % left saccade
                        switch rand4
                            case 1;memTrans = 2;        % up saccade    = inter
                            case 2;memTrans = 1;        % down saccade  = intra
                        end
                end
            case 2                                      % ccw
                switch rand3
                    case 1                              % right saccade
                        switch rand4
                            case 1; memTrans = 2;       % up saccade    = inter
                            case 2; memTrans = 1;       % down saccade  = intra
                        end
                    case 2                              % left saccade
                        switch rand4
                            case 1; memTrans = 1;       % up saccade    = intra
                            case 2; memTrans = 2;       % down saccade  = inter
                        end
                        
                end                
        end
    elseif rand1 == 2                                   % distractor absent
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

% Extract saccades path of different saccade 2 type
% -------------------------------------------------
for sac2Cond = 1:nb.sac2Cond                                        % sac 2 type
    index.sac2Cond = fileRes(:,sac2CondCol) == sac2Cond;
    
    for rand1 = 1:nb.rand1                                          % distractor presence
        index.rand1 = fileRes(:,rand1Col) == rand1;
        
        allData = find(index.sac2Cond & index.rand1);
        
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
        sac2CondMat{sac2Cond,rand1} = {tNum,coordRaw};
    end
end

save(sprintf('%s/%s_sac2CondMat%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2CondMat');
% sac2CondMat
% ===========
% sac2CondMat{sac2Cond,rand1}{1}  => numTrials
% sac2CondMat{sac2Cond,rand1}{2}  => mean coord of sac

% Extract second saccade relatively to sac2 onset for inter-saccadic interval distractor (i.e. after)
% ---------------------------------------------------------------------------------------------------
distOnSac1OffCol = 48; % dist onset relative to saccade 1 offset
distOffSac2OnCol = 64; % dist offset relative to saccade 2 onset
index.interSac = fileRes(:,distOnSac1OffCol) >= sub.interSac(1) & fileRes(:,distOffSac2OnCol) <= sub.interSac(2);

for cond1 = 1:nb.cond1   % sensory modality
    index.cond1 = fileRes(:,cond1Col) == cond1;
    
    for rand1 = 1:nb.rand1  % distractor presence
        index.rand1 = fileRes(:,rand1Col) == rand1;
        if rand1 == 1       % present
            allData = find(index.cond1 & index.rand1 & index.interSac);
        elseif rand1 == 2   % absent
            allData = find(index.rand1);
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
                if rand1 == 1       % distractor present
                    rand2 = fileRes(allData(tNum),rand2Col);
                    switch rand2
                        case 1;multiVal = 1;  % cw
                        case 2;multiVal = -1; % ccw
                    end
                elseif rand1 == 2   % distractor absent
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
        sac2After{cond1,rand1} = {tNum,coordRaw,curvMedian};
    end
end

save(sprintf('%s/%s_sac2After%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2After');
% sac2After
% =========
% sac2After{cond1,rand1}{1}  => numTrials
% sac2After{cond1,rand1}{2}  => mean coord of sac
% sac2After{cond1,rand1}{3}  => mean median curvature

% Extract second saccade relatively to sac2 onset for pre-saccadic interval distractor (i.e. before)
% --------------------------------------------------------------------------------------------------
distOffSac1OnCol = 47;
index.preSac   = (fileRes(:,distOffSac1OnCol) >= sub.preSac(1) & fileRes(:,distOffSac1OnCol) <= sub.preSac(2));

% Before for intra-hemifield trials
index.memTrans = fileRes(:,memTransCol) == 1;

for cond1 = 1:nb.cond1   % sensory modality
    index.cond1 = fileRes(:,cond1Col) == cond1;
    for rand1 = 1:nb.rand1  % distractor presence
        index.rand1 = fileRes(:,rand1Col) == rand1;
        
        if rand1 == 1 % present
            allData = find(index.memTrans & index.cond1 & index.rand1 & index.preSac);
        elseif rand1 == 2 % absent
            allData = find(index.rand1);
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
                if rand1 == 1 % distractor present
                    rand2 = fileRes(allData(tNum),rand2Col);
                    switch rand2
                        case 1;multiVal = 1;  %cw
                        case 2;multiVal = -1; %ccw
                    end
                elseif rand1 == 2   % distractor absent
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
        sac2BeforeIntra{cond1,rand1} = {tNum,coordRaw,curvMedian};
    end
end

save(sprintf('%s/%s_sac2BeforeIntra%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeIntra');
% sac2BeforeIntra
% ===============
% sac2BeforeIntra{cond1,rand1}{1}  => numTrials
% sac2BeforeIntra{cond1,rand1}{2}  => mean coord of sac
% sac2BeforeIntra{cond1,rand1}{3}  => mean median curvature

% Before for inter-hemifield trials
index.memTrans = fileRes(:,memTransCol) == 2;

for cond1 = 1:nb.cond1   % sensory modality
    index.cond1 = fileRes(:,cond1Col) == cond1;
    for rand1 = 1:nb.rand1  % distractor presence
        index.rand1 = fileRes(:,rand1Col) == rand1;
        
        if rand1 == 1 % present
            allData = find(index.memTrans & index.cond1 & index.rand1 & index.preSac);
        elseif rand1 == 2 % absent
            allData = find(index.rand1);
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
                if rand1 == 1 % distractor present
                    rand2 = fileRes(allData(tNum),rand2Col);
                    switch rand2
                        case 1;multiVal = 1;  %cw
                        case 2;multiVal = -1; %ccw
                    end
                elseif rand1 == 2   % distractor absent
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
        sac2BeforeInter{cond1,rand1} = {tNum,coordRaw,curvMedian};
    end
end
save(sprintf('%s/%s_sac2BeforeInter%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeInter');
% sac2BeforeInter
% ===============
% sac2BeforeInter{cond1,rand1}{1}  => numTrials
% sac2BeforeInter{cond1,rand1}{2}  => mean coord of sac
% sac2BeforeInter{cond1,rand1}{3}  => mean median curvature

% Analysis of curvature as a function of saccade latency of the first saccade
sac1LatCol = 44;

if normType == 2
    % Extract second saccade relatively to sac2 onset for inter-saccadic interval distractor (i.e. after)
    % ---------------------------------------------------------------------------------------------------
    for cond1 = 1:nb.cond1   % sensory modality
        index.cond1 = fileRes(:,cond1Col) == cond1;
        
        condTrials = index.interSac & index.cond1;
        sac1Lat_val = fileRes(condTrials,sac1LatCol);
        sac1Lat_t_val = prctile(sac1Lat_val,[0,50,100]);
        
        for sac1Lat_t = 1:2
            if sac1Lat_t == 1
                index.sac1Lat_t = fileRes(:,sac1LatCol) >= sac1Lat_t_val(1) & fileRes(:,sac1LatCol) <= sac1Lat_t_val(2);
            elseif sac1Lat_t == 2
                index.sac1Lat_t = fileRes(:,sac1LatCol) >= sac1Lat_t_val(2) & fileRes(:,sac1LatCol) <= sac1Lat_t_val(3);
            end
            
            for rand1 = 1:nb.rand1  % distractor presence
                index.rand1 = fileRes(:,rand1Col) == rand1;
                
                if rand1 == 1       % present
                    allData = find(index.cond1 & index.rand1 & index.interSac & index.sac1Lat_t);
                elseif rand1 == 2   % absent
                    allData = find(index.rand1 & index.sac1Lat_t);
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
                        if rand1 == 1       % distractor present
                            rand2 = fileRes(allData(tNum),rand2Col);
                            switch rand2
                                case 1;multiVal = 1;  % cw
                                case 2;multiVal = -1; % ccw
                            end
                        elseif rand1 == 2   % distractor absent
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
                    
                    sac1LatMean = nanmean(fileRes(allData,sac1LatCol));
                    
                    % mean coordinates
                    coordRaw      = [nanmean([nanmean(xCoordRaw1,2),nanmean(xCoordRaw2,2),nanmean(xCoordRaw3,2),nanmean(xCoordRaw4,2)],2),...
                                     nanmean([nanmean(yCoordRaw1,2),nanmean(yCoordRaw2,2),nanmean(yCoordRaw3,2),nanmean(yCoordRaw1,2)],2)];
                    
                    curvMedian	  = nanmean([nanmean(curvMedianVal1,2),nanmean(curvMedianVal2,2),nanmean(curvMedianVal3,2),nanmean(curvMedianVal4,2)],2);
                    
                end
                sac2AfterSac1LatT{cond1,rand1,sac1Lat_t} = {tNum,coordRaw,curvMedian,sac1LatMean};
            end
        end
    end
    save(sprintf('%s/%s_sac2AfterSac1LatT%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2AfterSac1LatT');
    % sac2AfterSac1LatT
    % =================
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{1}  => numTrials
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{2}  => mean coord of sac
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{3}  => mean median curvature
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{4}  => mean 1st saccade latency 

    % Extract second saccade relatively to sac2 onset for pre-saccadic interval distractor (i.e. before)
    % --------------------------------------------------------------------------------------------------
    % Before for intra-hemifield trials
    index.memTrans = fileRes(:,memTransCol) == 1;
    
    for cond1 = 1:nb.cond1   % sensory modality
        index.cond1 = fileRes(:,cond1Col) == cond1;
        
        condTrials = index.preSac & index.cond1;
        sac1Lat_val = fileRes(condTrials,sac1LatCol);
        sac1Lat_t_val = prctile(sac1Lat_val,[0,50,100]);
        
        for sac1Lat_t = 1:3
            if sac1Lat_t == 1
                index.sac1Lat_t = fileRes(:,sac1LatCol) >= sac1Lat_t_val(1) & fileRes(:,sac1LatCol) <= sac1Lat_t_val(2);
            elseif sac1Lat_t == 2
                index.sac1Lat_t = fileRes(:,sac1LatCol) >= sac1Lat_t_val(2) & fileRes(:,sac1LatCol) <= sac1Lat_t_val(3);
            end
            
            for rand1 = 1:nb.rand1  % distractor presence
                index.rand1 = fileRes(:,rand1Col) == rand1;
                
                if rand1 == 1 % present
                    allData = find(index.memTrans & index.cond1 & index.rand1 & index.preSac & index.sac1Lat_t);
                elseif rand1 == 2 % absent
                    allData = find(index.rand1 & index.sac1Lat_t);
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
                        if rand1 == 1 % distractor present
                            rand2 = fileRes(allData(tNum),rand2Col);
                            switch rand2
                                case 1;multiVal = 1;  %cw
                                case 2;multiVal = -1; %ccw
                            end
                        elseif rand1 == 2   % distractor absent
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
                    sac1LatMean = nanmean(fileRes(allData,sac1LatCol));
                    coordRaw      = [nanmean([nanmean(xCoordRaw1,2),nanmean(xCoordRaw2,2),nanmean(xCoordRaw3,2),nanmean(xCoordRaw4,2)],2),...
                                     nanmean([nanmean(yCoordRaw1,2),nanmean(yCoordRaw2,2),nanmean(yCoordRaw3,2),nanmean(yCoordRaw1,2)],2)];
                    
                    curvMedian    = nanmean([nanmean(curvMedianVal1,2),nanmean(curvMedianVal2,2),nanmean(curvMedianVal3,2),nanmean(curvMedianVal4,2)],2);
                end
                sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t} = {tNum,coordRaw,curvMedian,sac1LatMean};
            end
        end
    end
    save(sprintf('%s/%s_sac2BeforeIntraSac1LatT%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeIntraSac1LatT');
    % sac2BeforeIntraSac1LatT
    % =======================
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{1}  => numTrials
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{2}  => mean coord of sac
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{3}  => mean median curvature
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{4}  => mean 1st saccade lantency
    
    % Before for inter-hemifield trials
    index.memTrans = fileRes(:,memTransCol) == 2;
    
    for cond1 = 1:nb.cond1   % sensory modality
        index.cond1 = fileRes(:,cond1Col) == cond1;
        
        condTrials = index.preSac & index.cond1;
        sac1Lat_val = fileRes(condTrials,sac1LatCol);
        sac1Lat_t_val = prctile(sac1Lat_val,[0,50,100]);
        
        for sac1Lat_t = 1:3
            if sac1Lat_t == 1
                index.sac1Lat_t = fileRes(:,sac1LatCol) >= sac1Lat_t_val(1) & fileRes(:,sac1LatCol) <= sac1Lat_t_val(2);
            elseif sac1Lat_t == 2
                index.sac1Lat_t = fileRes(:,sac1LatCol) >= sac1Lat_t_val(2) & fileRes(:,sac1LatCol) <= sac1Lat_t_val(3);
            end
            
            for rand1 = 1:nb.rand1  % distractor presence
                index.rand1 = fileRes(:,rand1Col) == rand1;
                
                if rand1 == 1 % present
                    allData = find(index.memTrans & index.cond1 & index.rand1 & index.preSac & index.sac1Lat_t);
                elseif rand1 == 2 % absent
                    allData = find(index.rand1 & index.sac1Lat_t);
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
                        if rand1 == 1 % distractor present
                            rand2 = fileRes(allData(tNum),rand2Col);
                            switch rand2
                                case 1;multiVal = 1;  %cw
                                case 2;multiVal = -1; %ccw
                            end
                        elseif rand1 == 2   % distractor absent
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
                    sac1LatMean = nanmean(fileRes(allData,sac1LatCol));
                    coordRaw      = [nanmean([nanmean(xCoordRaw1,2),nanmean(xCoordRaw2,2),nanmean(xCoordRaw3,2),nanmean(xCoordRaw4,2)],2),...
                        nanmean([nanmean(yCoordRaw1,2),nanmean(yCoordRaw2,2),nanmean(yCoordRaw3,2),nanmean(yCoordRaw1,2)],2)];
                    
                    curvMedian    = nanmean([nanmean(curvMedianVal1,2),nanmean(curvMedianVal2,2),nanmean(curvMedianVal3,2),nanmean(curvMedianVal4,2)],2);
                end
                sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t} = {tNum,coordRaw,curvMedian,sac1LatMean};
            end
        end
    end
    save(sprintf('%s/%s_sac2BeforeInterSac1LatT%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeInterSac1LatT');
    % sac2BeforeInterSac1LatT
    % =======================
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{1}  => numTrials
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{2}  => mean coord of sac
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{3}  => mean median curvature
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{4}  => mean 1st saccade latency
end


% Extract saccade latencies and inter-saccadic time
if normType == 1
    sac1LatCol = 44; % sac1 latency
    sac2LatCol = 61; % sac2 latency
    sac1OffCol = 42; % sac1 offset
    sac2OnCol  = 58; % sac2 onset

    for cond1 = 1:nb.cond1 % modality
        index.cond1 = fileRes(:,cond1Col) == cond1;
        
        for rand1 = 1:nb.rand1  % distractor presence
            index.rand1 = fileRes(:,rand1Col) == rand1;
            
            if rand1 == 1
                allData = fileRes(index.rand1 & index.cond1 & (index.preSac | index.interSac),:);
            elseif rand1 == 2 % absent
                allData = fileRes(index.rand1,:);
            end
            
            values1     =   allData(:,sac1LatCol);                          % 1st sac. latency
            values2     =   allData(:,sac2LatCol);                          % 2nd sac. latency
            values3     =   allData(:,sac2OnCol) - allData(:,sac1OffCol);   % inter-saccadic time
            
            numVal     =    size(values1,1);
            mean1Val    =   nanmean(values1);
            mean2Val    =   nanmean(values2);
            mean3Val    =   nanmean(values3);
            
            sacTimeMat{cond1,rand1} = {numVal,mean1Val,mean2Val,mean3Val};    
        end
        
    end
    save(sprintf('%s/%s_sacTimeMat.mat',sub.deriv_filedir,sub.ini),'sacTimeMat');
    % sacHistMat
    % ==========
    % sacTimeMat{cond1,rand1}{1}  => number of trials
    % sacTimeMat{cond1,rand1}{2}  => 1st saccade latency
    % sacTimeMat{cond1,rand1}{3}  => 2nd saccade latency
    % sacTimeMat{cond1,rand1}{4}  => intersaccadic duration
end

end