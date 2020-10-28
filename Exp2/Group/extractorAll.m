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

nb.sensMod  = 2;
% 1 = visual
% 2 = auditory

nb.distPres = 2;
% 1 = present
% 2 = absent

nb.sac2Cond = 4;
% sac2CondNum
% 1 = up of right-up
% 2 = down of right-down
% 3 = up of left-up
% 4 = down of left-down

nb.memTrans = 3;
% Memory transfert across first saccade
% 1 = Intra-hemifield
% 2 = Inter-hemifield
% 3 = None (distractor absent)

% Extract saccades path of different saccade 2 type
% -------------------------------------------------
for sac2Cond = 1:nb.sac2Cond
    for distPres = 1:nb.distPres
        
        tNum            = [];
        coordRaw        = [];
        
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2CondMat%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2CondMat{sac2Cond,distPres}{1};
            if tNum(numSjct,:) ~= 0
                coordRaw(:,:,numSjct)       = sac2CondMat{sac2Cond,distPres}{2};
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
        sac2CondMatBis{sac2Cond,distPres} = {tNum,coordRaw};
    end
end
sac2CondMat = sac2CondMatBis;
save(sprintf('%s/%s_sac2CondMat%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2CondMat');

% sac2CondMat
% ===========
% sac2CondMat{sac2Cond,distPres}{1}  => mean numTrials + se
% sac2CondMat{sac2Cond,distPres}{2}  => mean coord of sac + se

% Extract second saccade relatively to sac2 onset for inter-saccadic interval distractor (i.e. after)
% ---------------------------------------------------------------------------------------------------

for sensMod = 1:nb.sensMod   % sensory modality
    for distPres = 1:nb.distPres  % distractor presence
        
        tNum            = [];
        coordRaw        = [];
        curvMedian      = [];
        
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2After%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2After{sensMod,distPres}{1};
            curvMedian(numSjct,:)           = sac2After{sensMod,distPres}{3};
            
            if tNum(numSjct,:) ~= 0
                coordRaw(:,:,numSjct)       = sac2After{sensMod,distPres}{2};
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
        
        sac2AfterBis{sensMod,distPres} = {tNum_all,coordRaw_all,curvMedian_all,tNum,coordRaw,curvMedian};
    end
end
sac2After = sac2AfterBis;
save(sprintf('%s/%s_sac2After%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2After');
% sac2After
% =========
% sac2After{sensMod,distPres}{1}  => mean numTrials + se
% sac2After{sensMod,distPres}{2}  => mean coord of sac + se
% sac2After{sensMod,distPres}{3}  => mean median curvature + se
% sac2After{sensMod,distPres}{4}  => individual numTrials
% sac2After{sensMod,distPres}{5}  => individual mean coord of sac
% sac2After{sensMod,distPres}{6}  => individual median curvature

% Extract second saccade relatively to sac2 onset for pre-saccadic interval distractor (i.e. before)
% --------------------------------------------------------------------------------------------------

% Before for intra-hemifield trials
for sensMod = 1:nb.sensMod   % sensory modality
    for distPres = 1:nb.distPres  % distractor presence
        tNum            = [];
        coordRaw        = [];
        curvMedian      = [];
        
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2BeforeIntra%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2BeforeIntra{sensMod,distPres}{1};
            
            
            if tNum(numSjct,:) >= 20
                curvMedian(numSjct,:)           = sac2BeforeIntra{sensMod,distPres}{3};
                coordRaw(:,:,numSjct)       = sac2BeforeIntra{sensMod,distPres}{2};
            else
                curvMedian(numSjct,:)       = NaN;
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
        
        sac2BeforeIntraBis{sensMod,distPres} = {tNum_all,coordRaw_all,curvMedian_all,tNum,coordRaw,curvMedian};
    end
end
sac2BeforeIntra = sac2BeforeIntraBis;
save(sprintf('%s/%s_sac2BeforeIntra%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeIntra');
% sac2BeforeIntra
% ===============
% sac2BeforeIntra{sensMod,distPres}{1}  => mean numTrials + se
% sac2BeforeIntra{sensMod,distPres}{2}  => mean coord of sac + se
% sac2BeforeIntra{sensMod,distPres}{3}  => mean median curvature + se
% sac2BeforeIntra{sensMod,distPres}{4}  => individual numTrials
% sac2BeforeIntra{sensMod,distPres}{5}  => individual mean coord of sac
% sac2BeforeIntra{sensMod,distPres}{6}  => individual median curvature


% Before for inter-hemifield trials
for sensMod = 1:nb.sensMod   % sensory modality
    for distPres = 1:nb.distPres  % distractor presence
        tNum            = [];
        coordRaw        = [];
        curvMedian      = [];
                    
        for numSjct = 1:numSub
            
            sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
            load(sprintf('%s/%s_sac2BeforeInter%s.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct),txtNormType{normType}));
            
            tNum(numSjct,:)                 = sac2BeforeInter{sensMod,distPres}{1};
            curvMedian(numSjct,:)           = sac2BeforeInter{sensMod,distPres}{3};
            
            if tNum(numSjct,:) ~= 0
                coordRaw(:,:,numSjct)       = sac2BeforeInter{sensMod,distPres}{2};
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
        
        sac2BeforeInterBis{sensMod,distPres} = {tNum_all,coordRaw_all,curvMedian_all,tNum,coordRaw,curvMedian};
    end
end
sac2BeforeInter = sac2BeforeInterBis;
save(sprintf('%s/%s_sac2BeforeInter%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}),'sac2BeforeInter');
% sac2BeforeInter
% ===============
% sac2BeforeInter{sensMod,distPres}{1}  => mean numTrials + se
% sac2BeforeInter{sensMod,distPres}{2}  => mean coord of sac + se
% sac2BeforeInter{sensMod,distPres}{3}  => mean median curvature + se
% sac2BeforeInter{sensMod,distPres}{4}  => individual numTrials
% sac2BeforeInter{sensMod,distPres}{5}  => individual mean coord of sac
% sac2BeforeInter{sensMod,distPres}{6}  => individual median curvature



% Extract saccade latencies and inter-saccadic time
if normType == 1
    for sensMod = 1:nb.sensMod   % sensory modality
        for distPres = 1:nb.distPres  % distractor presence
            
            tNum            = [];
            coordRaw        = [];
            curvMedian      = [];
            
            for numSjct = 1:numSub
                
                sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
                load(sprintf('%s/%s_sacTimeMat.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
                
                
                numVal(numSjct,:)       =   sacTimeMat{sensMod,distPres}{1};
                mean1Val(numSjct,:)     =   sacTimeMat{sensMod,distPres}{2};
                mean2Val(numSjct,:)     =   sacTimeMat{sensMod,distPres}{3};
                mean3Val(numSjct,:)     =   sacTimeMat{sensMod,distPres}{4};
                            
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
            
            sacTimeMatBis{sensMod,distPres} = {numVal_all,mean1Val_all,mean2Val_all,mean3Val_all,numVal,mean1Val,mean2Val,mean3Val};
        end
    end
    sacTimeMat = sacTimeMatBis;
    save(sprintf('%s/%s_sacTimeMat.mat',sub.deriv_filedir,sub.ini),'sacTimeMat');
    % sacTimeMat
    % ==========
    % sacTimeMat{sensMod,distPres}{1}  => mean number of trials + se
    % sacTimeMat{sensMod,distPres}{2}  => mean 1st saccade latency + se
    % sacTimeMat{sensMod,distPres}{3}  => mean 2nd saccade latency + se
    % sacTimeMat{sensMod,distPres}{4}  => mean intersaccadic duration + se
    % sacTimeMat{sensMod,distPres}{5}  => individual number of trials
    % sacTimeMat{sensMod,distPres}{6}  => individual 1st saccade latency
    % sacTimeMat{sensMod,distPres}{7}  => individual 2nd saccade latency
    % sacTimeMat{sensMod,distPres}{8}  => individual intersaccadic duration
end
end