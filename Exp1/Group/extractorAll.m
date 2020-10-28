function extractorAll(sub,normType)
% ----------------------------------------------------------------------
% extractorAll(sub,normType)
% ----------------------------------------------------------------------
% Goal of the function :
% Extract results and make averages across subjects
% ----------------------------------------------------------------------
% Input(s) :
% sub : subject configuration
% normType : normalization type
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

txtNormType = {'','_norm'};
txtNormAna = {'raw data ','normalized data'};
fprintf(1,'\n\tData extraction: %s',txtNormAna{normType});

numSub = sub.numSjct;

nb.cond1  = 3;
% 1 = visual
% 2 = auditory
% 3 = audio-visual

nb.rand1 = 2;
% 1 = present
% 2 = absent

nb.rand2 = 2;
% 1 = cw
% 2 = ccw

nb.rand3 = 2;
% 1 = saccade right 
% 2 = saccade left

nb.rand4 = 2;
% 1 = saccade up
% 2 = saccade down

nb.sac2Cond = 4;
% sac2CondNum
% 1 = up of right-up
% 2 = down of right-down
% 3 = up of left-up
% 4 = down of left-down

nb.memTrans = 3;
% Memory transfert across first saccade
% 1 = Inter-hemifield
% 2 = Intra-hemifield
% 3 = None (distractor absent)

% Extract saccades path of different saccade 2 type
% -------------------------------------------------
for sac2Cond = 1:nb.sac2Cond
    for rand1 = 1:nb.rand1
        
        tNum            = [];
        coordRaw        = [];
        
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2CondMat%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2CondMat{sac2Cond,rand1}{1};
            if tNum(numSjct,:) ~= 0
                coordRaw(:,:,numSjct)       = sac2CondMat{sac2Cond,rand1}{2};
            else
                coordRaw(:,:,numSjct)       = nan(588,2);
            end
        end
        
        mean_tNum       =   nanmean(tNum,1);
        se_tNum         =   nanstd(tNum,0,1)/sqrt(numSub);
        tNum            =   [mean_tNum,se_tNum];
        mean_coordRaw   =   nanmean(coordRaw,3);
        se_coordRaw     =   nanstd(coordRaw,0,3)/sqrt(numSub);
        coordRaw        =   [mean_coordRaw,se_coordRaw];
        sac2CondMatBis{sac2Cond,rand1} = {tNum,coordRaw};
    end
end
sac2CondMat = sac2CondMatBis;
save(sprintf('%s/%s_sac2CondMat%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2CondMat');

% sac2CondMat
% ===========
% sac2CondMat{sac2Cond,rand1}{1}  => mean numTrials + se
% sac2CondMat{sac2Cond,rand1}{2}  => mean coord of sac + se

% Extract second saccade relatively to sac2 onset for inter-saccadic interval distractor (i.e. after)
% ---------------------------------------------------------------------------------------------------

for cond1 = 1:nb.cond1   % sensory modality
    for rand1 = 1:nb.rand1  % distractor presence
        
        tNum            = [];
        coordRaw        = [];
        curvMedian      = [];
        
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2After%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2After{cond1,rand1}{1};
            curvMedian(numSjct,:)           = sac2After{cond1,rand1}{3};
            
            if tNum(numSjct,:) ~= 0
                coordRaw(:,:,numSjct)       = sac2After{cond1,rand1}{2};
            else
                coordRaw(:,:,numSjct)       = nan(588,2);
            end
        end
        
        mean_tNum       =   nanmean(tNum,1);
        se_tNum         =   nanstd(tNum,0,1)/sqrt(numSub);
        tNum_all        =   [mean_tNum,se_tNum];
        mean_coordRaw   =   nanmean(coordRaw,3);
        se_coordRaw     =   nanstd(coordRaw,0,3)/sqrt(numSub);
        coordRaw_all    =   [mean_coordRaw,se_coordRaw];
        mean_curvMedian =   nanmean(curvMedian,1);
        se_curvMedian   =   nanstd(curvMedian,0,1)/sqrt(numSub);
        curvMedian_all  =   [mean_curvMedian,se_curvMedian];
        
        sac2AfterBis{cond1,rand1} = {tNum_all,coordRaw_all,curvMedian_all,tNum,coordRaw,curvMedian};
    end
end
sac2After = sac2AfterBis;
save(sprintf('%s/%s_sac2After%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2After');
% sac2After
% =========
% sac2After{cond1,rand1}{1}  => mean numTrials + se
% sac2After{cond1,rand1}{2}  => mean coord of sac + se
% sac2After{cond1,rand1}{3}  => mean median curvature + se
% sac2After{cond1,rand1}{4}  => individual numTrials
% sac2After{cond1,rand1}{5}  => individual mean coord of sac
% sac2After{cond1,rand1}{6}  => individual median curvature

% Extract second saccade relatively to sac2 onset for pre-saccadic interval distractor (i.e. before)
% --------------------------------------------------------------------------------------------------

% Before for intra-hemifield trials
for cond1 = 1:nb.cond1   % sensory modality
    for rand1 = 1:nb.rand1  % distractor presence
        tNum            = [];
        coordRaw        = [];
        curvMedian      = [];
                    
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2BeforeIntra%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2BeforeIntra{cond1,rand1}{1};
            curvMedian(numSjct,:)           = sac2BeforeIntra{cond1,rand1}{3};
            
            if tNum(numSjct,:) ~= 0
                coordRaw(:,:,numSjct)       = sac2BeforeIntra{cond1,rand1}{2};
            else
                coordRaw(:,:,numSjct)       = nan(588,2);
            end
        end
        mean_tNum       =   nanmean(tNum,1);
        se_tNum         =   nanstd(tNum,0,1)/sqrt(numSub);
        tNum_all        =   [mean_tNum,se_tNum];
        mean_coordRaw   =   nanmean(coordRaw,3);
        se_coordRaw     =   nanstd(coordRaw,0,3)/sqrt(numSub);
        coordRaw_all    =   [mean_coordRaw,se_coordRaw];
        mean_curvMedian =   nanmean(curvMedian,1);
        se_curvMedian   =   nanstd(curvMedian,0,1)/sqrt(numSub);
        curvMedian_all  =   [mean_curvMedian,se_curvMedian];
        
        sac2BeforeIntraBis{cond1,rand1} = {tNum_all,coordRaw_all,curvMedian_all,tNum,coordRaw,curvMedian};
    end
end
sac2BeforeIntra = sac2BeforeIntraBis;
save(sprintf('%s/%s_sac2BeforeIntra%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeIntra');
% sac2BeforeIntra
% ===============
% sac2BeforeIntra{cond1,rand1}{1}  => mean numTrials + se
% sac2BeforeIntra{cond1,rand1}{2}  => mean coord of sac + se
% sac2BeforeIntra{cond1,rand1}{3}  => mean median curvature + se
% sac2BeforeIntra{cond1,rand1}{4}  => individual numTrials
% sac2BeforeIntra{cond1,rand1}{5}  => individual mean coord of sac
% sac2BeforeIntra{cond1,rand1}{6}  => individual median curvature


% Before for inter-hemifield trials
for cond1 = 1:nb.cond1   % sensory modality
    for rand1 = 1:nb.rand1  % distractor presence
        tNum            = [];
        coordRaw        = [];
        curvMedian      = [];
                    
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2BeforeInter%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2BeforeInter{cond1,rand1}{1};
            curvMedian(numSjct,:)           = sac2BeforeInter{cond1,rand1}{3};
            
            if tNum(numSjct,:) ~= 0
                coordRaw(:,:,numSjct)       = sac2BeforeInter{cond1,rand1}{2};
            else
                coordRaw(:,:,numSjct)       = nan(588,2);
            end
        end
        mean_tNum       =   nanmean(tNum,1);
        se_tNum         =   nanstd(tNum,0,1)/sqrt(numSub);
        tNum_all        =   [mean_tNum,se_tNum];
        mean_coordRaw   =   nanmean(coordRaw,3);
        se_coordRaw     =   nanstd(coordRaw,0,3)/sqrt(numSub);
        coordRaw_all    =   [mean_coordRaw,se_coordRaw];
        mean_curvMedian =   nanmean(curvMedian,1);
        se_curvMedian   =   nanstd(curvMedian,0,1)/sqrt(numSub);
        curvMedian_all  =   [mean_curvMedian,se_curvMedian];
        
        sac2BeforeInterBis{cond1,rand1} = {tNum_all,coordRaw_all,curvMedian_all,tNum,coordRaw,curvMedian};
    end
end
sac2BeforeInter = sac2BeforeInterBis;
save(sprintf('%s/%s_sac2BeforeInter%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeInter');
% sac2BeforeInter
% ===============
% sac2BeforeInter{cond1,rand1}{1}  => mean numTrials + se
% sac2BeforeInter{cond1,rand1}{2}  => mean coord of sac + se
% sac2BeforeInter{cond1,rand1}{3}  => mean median curvature + se
% sac2BeforeInter{cond1,rand1}{4}  => individual numTrials
% sac2BeforeInter{cond1,rand1}{5}  => individual mean coord of sac
% sac2BeforeInter{cond1,rand1}{6}  => individual median curvature

% Analysis of curvature as a function of 1st saccade latency
if normType == 2
    for cond1 = 1:nb.cond1   % sensory modality
        for sac1Lat_t = 1:2 % saccade latency group
            for rand1 = 1:nb.rand1  % distractor presence
                
                tNum            = [];
                coordRaw        = [];
                curvMedian      = [];
                
                for numSjct = 1:numSub
                    
                    sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
                    load(sprintf('%s/%s_sac2AfterSac1LatT%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
                    
                    tNum(numSjct,:)                 = sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{1};
                    curvMedian(numSjct,:)           = sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{3};
                    sac1LatMean(numSjct,:)          = sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{4};
                    
                    if tNum(numSjct,:) ~= 0
                        coordRaw(:,:,numSjct)       = sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{2};
                    else
                        coordRaw(:,:,numSjct)       = nan(588,2);
                    end
                end
                
                mean_tNum               =   nanmean(tNum,1);
                se_tNum                 =   nanstd(tNum,0,1)/sqrt(numSub);
                tNum_all                =   [mean_tNum,se_tNum];
                mean_coordRaw           =   nanmean(coordRaw,3);
                se_coordRaw             =   nanstd(coordRaw,0,3)/sqrt(numSub);
                coordRaw_all            =   [mean_coordRaw,se_coordRaw];
                mean_curvMedian         =   nanmean(curvMedian,1);
                se_curvMedian           =   nanstd(curvMedian,0,1)/sqrt(numSub);
                curvMedian_all          =   [mean_curvMedian,se_curvMedian];
                mean_sac1LatMean        =   nanmean(sac1LatMean,1);
                se_sac1LatOnMean        =   nanstd(sac1LatMean,0,1)/sqrt(numSub);
                sac1LatMean_all         =   [mean_sac1LatMean,se_sac1LatOnMean];
                
                sac2AfterSac1LatTBis{cond1,rand1,sac1Lat_t} = {tNum_all,coordRaw_all,curvMedian_all,sac1LatMean_all,tNum,coordRaw,curvMedian,sac1LatMean};
            end
        end
    end
    sac2AfterSac1LatT = sac2AfterSac1LatTBis;
    save(sprintf('%s/%s_sac2AfterSac1LatT%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2AfterSac1LatT');
    % sac2AfterSac1LatT
    % =================
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{1}  => mean numTrials + se
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{2}  => mean coord of sac + se
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{3}  => mean median curvature + se
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{4}  => mean 1st saccade latency + se
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{5}  => individual numTrials
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{6}  => individual mean coord of sac
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{7}  => individual median curvature
    % sac2AfterSac1LatT{cond1,rand1,sac1Lat_t}{8}  => individual 1st saccade latency mean
    
    % Before for intra-hemifield trials
    for cond1 = 1:nb.cond1   % sensory modality
        for sac1Lat_t = 1:2 % saccade latency group
            for rand1 = 1:nb.rand1  % distractor presence
                tNum            = [];
                coordRaw        = [];
                curvMedian      = [];
                
                for numSjct = 1:numSub
                    
                    sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
                    load(sprintf('%s/%s_sac2BeforeIntraSac1LatT%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
                    
                    tNum(numSjct,:)                 = sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{1};
                    curvMedian(numSjct,:)           = sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{3};
                    sac1LatMean(numSjct,:)          = sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{4};
                    
                    if tNum(numSjct,:) ~= 0
                        coordRaw(:,:,numSjct)       = sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{2};
                    else
                        coordRaw(:,:,numSjct)       = nan(588,2);
                    end
                end
                mean_tNum               =   nanmean(tNum,1);
                se_tNum                 =   nanstd(tNum,0,1)/sqrt(numSub);
                tNum_all                =   [mean_tNum,se_tNum];
                mean_coordRaw           =   nanmean(coordRaw,3);
                se_coordRaw             =   nanstd(coordRaw,0,3)/sqrt(numSub);
                coordRaw_all            =   [mean_coordRaw,se_coordRaw];
                mean_curvMedian         =   nanmean(curvMedian,1);
                se_curvMedian           =   nanstd(curvMedian,0,1)/sqrt(numSub);
                curvMedian_all          =   [mean_curvMedian,se_curvMedian];
                mean_sac1LatMean        =   nanmean(sac1LatMean,1);
                se_sac1LatMean          =   nanstd(sac1LatMean,0,1)/sqrt(numSub);
                sac1LatMean_all         =   [mean_sac1LatMean,se_sac1LatMean];
                
                sac2BeforeIntraSac1LatTBis{cond1,rand1,sac1Lat_t} = {tNum_all,coordRaw_all,curvMedian_all,sac1LatMean_all,tNum,coordRaw,curvMedian,sac1LatMean};
            end
        end
    end
    sac2BeforeIntraSac1LatT = sac2BeforeIntraSac1LatTBis;
    save(sprintf('%s/%s_sac2BeforeIntraSac1LatT%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeIntraSac1LatT');
    % sac2BeforeIntraSac1LatT
    % =======================
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{1}  => mean numTrials + se
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{2}  => mean coord of sac + se
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{3}  => mean median curvature + se
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{4}  => mean first saccade latency + se
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{5}  => individual numTrials
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{6}  => individual mean coord of sac
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{7}  => individual median curvature
    % sac2BeforeIntraSac1LatT{cond1,rand1,sac1Lat_t}{8}  => individual 1st saccade latency mean

    % Before for inter-hemifield trials
    for cond1 = 1:nb.cond1   % sensory modality
        for sac1Lat_t = 1:2 % saccade latency group
            for rand1 = 1:nb.rand1  % distractor presence
                tNum            = [];
                coordRaw        = [];
                curvMedian      = [];
                
                for numSjct = 1:numSub
                    
                    sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
                    load(sprintf('%s/%s_sac2BeforeInterSac1LatT%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
                    
                    tNum(numSjct,:)                 = sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{1};
                    curvMedian(numSjct,:)           = sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{3};
                    sac1LatMean(numSjct,:)          = sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{4};
                    
                    if tNum(numSjct,:) ~= 0
                        coordRaw(:,:,numSjct)       = sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{2};
                    else
                        coordRaw(:,:,numSjct)       = nan(588,2);
                    end
                end
                mean_tNum           =   nanmean(tNum,1);
                se_tNum             =   nanstd(tNum,0,1)/sqrt(numSub);
                tNum_all            =   [mean_tNum,se_tNum];
                mean_coordRaw       =   nanmean(coordRaw,3);
                se_coordRaw         =   nanstd(coordRaw,0,3)/sqrt(numSub);
                coordRaw_all        =   [mean_coordRaw,se_coordRaw];
                mean_curvMedian     =   nanmean(curvMedian,1);
                se_curvMedian       =   nanstd(curvMedian,0,1)/sqrt(numSub);
                curvMedian_all      =   [mean_curvMedian,se_curvMedian];
                mean_sac1LatMean    =   nanmean(sac1LatMean,1);
                se_sac1LatMean      =   nanstd(sac1LatMean,0,1)/sqrt(numSub);
                sac1LatMean_all     =   [mean_sac1LatMean,se_sac1LatMean];
                
                sac2BeforeInterSac1LatTBis{cond1,rand1,sac1Lat_t} = {tNum_all,coordRaw_all,curvMedian_all,sac1LatMean_all,tNum,coordRaw,curvMedian,sac1LatMean};
            end
        end
    end
    sac2BeforeInterSac1LatT = sac2BeforeInterSac1LatTBis;
    save(sprintf('%s/%s_sac2BeforeInterSac1LatT%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeInterSac1LatT');
    % sac2BeforeInterSac1LatT
    % =======================
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{1}  => mean numTrials + se
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{2}  => mean coord of sac + se
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{3}  => mean median curvature + se
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{4}  => mean 1st saccde lantency + se
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{5}  => individual numTrials
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{6}  => individual mean coord of sac
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{7}  => individual median curvature
    % sac2BeforeInterSac1LatT{cond1,rand1,sac1Lat_t}{8}  => individual 1st saccde lantency
end

% Extract saccade latencies and inter-saccadic time
if normType == 1
    for cond1 = 1:nb.cond1   % sensory modality
        for rand1 = 1:nb.rand1  % distractor presence
            
            tNum            = [];
            coordRaw        = [];
            curvMedian      = [];
            
            for numSjct = 1:numSub
                
                sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
                load(sprintf('%s/%s_sacTimeMat.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
                
                
                numVal(numSjct,:)       =   sacTimeMat{cond1,rand1}{1};
                mean1Val(numSjct,:)     =   sacTimeMat{cond1,rand1}{2};
                mean2Val(numSjct,:)     =   sacTimeMat{cond1,rand1}{3};
                mean3Val(numSjct,:)     =   sacTimeMat{cond1,rand1}{4};
                            
            end
            
            mean_numVal     =   nanmean(numVal,1);
            se_numVal       =   nanstd(numVal,0,1)/sqrt(numSub);
            numVal_all      =   [mean_numVal,se_numVal];
            
            mean_mean1Val   =   nanmean(mean1Val,1);
            se_mean1Val     =   nanstd(mean1Val,0,1)/sqrt(numSub);
            mean1Val_all    =   [mean_mean1Val,se_mean1Val];
            
            mean_mean2Val   =   nanmean(mean2Val,1);
            se_mean2Val     =   nanstd(mean2Val,0,1)/sqrt(numSub);
            mean2Val_all    =   [mean_mean2Val,se_mean2Val];
            
            mean_mean3Val   =   nanmean(mean3Val,1);
            se_mean3Val     =   nanstd(mean3Val,0,1)/sqrt(numSub);
            mean3Val_all    =   [mean_mean3Val,se_mean3Val];
            
            sacTimeMatBis{cond1,rand1} = {numVal_all,mean1Val_all,mean2Val_all,mean3Val_all,numVal,mean1Val,mean2Val,mean3Val};
        end
    end
    sacTimeMat = sacTimeMatBis;
    save(sprintf('%s/%s_sacTimeMat.mat',sub.deriv_filedir,sub.ini),'sacTimeMat');
    % sacTimeMat
    % ==========
    % sacTimeMat{cond1,rand1}{1}  => mean number of trials + se
    % sacTimeMat{cond1,rand1}{2}  => mean 1st saccade latency + se
    % sacTimeMat{cond1,rand1}{3}  => mena 2nd saccade latency + se
    % sacTimeMat{cond1,rand1}{4}  => mean intersaccadic duration + se
    % sacTimeMat{cond1,rand1}{5}  => individual number of trials
    % sacTimeMat{cond1,rand1}{6}  => individual 1st saccade latency
    % sacTimeMat{cond1,rand1}{7}  => individual 2nd saccade latency
    % sacTimeMat{cond1,rand1}{8}  => individual intersaccadic duration
end
end