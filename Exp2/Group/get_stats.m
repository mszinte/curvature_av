function get_stats(sub)
% ----------------------------------------------------------------------
% get_stats(sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Extract statistical value used in manuscript
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

stats_file = sprintf('%s/%s_stats.txt',sub.deriv_filedir,sub.ini);
fstats = fopen(stats_file,'w');

matRes = [];
for numSjct = 1:sub.numSjct
    
    sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
    load(sprintf('%s/%s_sac2BeforeInter_norm.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
    load(sprintf('%s/%s_sac2BeforeIntra_norm.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
    load(sprintf('%s/%s_sac2After_norm.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
    
    matRes(numSjct,:)  = [  sac2After{1,2}{3},...                 % distractor absent
                            sac2After{1,1}{3},...                 % inter-sac visual distractor present
                            sac2After{2,1}{3},...                 % inter-sac auditory distractor present
                            sac2BeforeInter{1,1}{3},...           % pre-sac inter-hemifield distractor visual present
                            sac2BeforeInter{2,1}{3},...           % pre-sac inter-hemifield distractor auditory present
                            ];
end

bootMat     = bootstrap(matRes,sub.numBoot);
meanCond    = nanmean(matRes,1);
seCond      = nanstd(matRes,0,1)/sqrt(sub.numSjct);

% First set of comparisons
compMat1    = [ 1,2;     % absent vs. inter-sac visual distractor present
                1,3;     % absent vs. inter-sac auditory distractor present
                1,4;     % absent vs. inter-hemifield distractor visual present
                1,5;];   % absent vs. inter-hemifield distractor auditory present

for tComp1 = 1:size(compMat1,1)
    
    diff_bt = bootMat(:,compMat1(tComp1,1)) - bootMat(:,compMat1(tComp1,2));
    diff_mean = meanCond(compMat1(tComp1,1)) - meanCond(compMat1(tComp1,2));

    mat_stats1(1,tComp1) =  meanCond(compMat1(tComp1,1));
    mat_stats1(2,tComp1) =  seCond(compMat1(tComp1,1));
    mat_stats1(3,tComp1) =  meanCond(compMat1(tComp1,2));
    mat_stats1(4,tComp1) =  seCond(compMat1(tComp1,2));
    
    if ~isnan(diff_mean)
        if diff_mean < 0
            pVal_comp = sum(diff_bt>0)/sub.numBoot;
        elseif diff_mean > 0
            pVal_comp = 1-sum(diff_bt>0)/sub.numBoot;
        end
        pVal_comp = pVal_comp*2;
        if pVal_comp == 0;
            pVal_comp = 1/sub.numBoot;
        end
        mat_stats1(5,tComp1) = pVal_comp;
    else
        mat_stats1(5,tComp1) = NaN;
    end
end

fprintf(fstats,[   'Distrator absent (%1.2f +/- %1.2f deg -mean +/- SEM-) vs. \n',...
                   'Inter-sac. visual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Inter-sac. auditory distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Pre-sac. inter-hemifield visual distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. inter-hemifield auditory distractor present (%1.2f +/- %1.2f, p = %1.4f)\n'],...
                   mat_stats1(1,1), mat_stats1(2,1),...
                   mat_stats1(3,1), mat_stats1(4,1), mat_stats1(5,1),...
                   mat_stats1(3,2), mat_stats1(4,2), mat_stats1(5,2),...
                   mat_stats1(3,3), mat_stats1(4,3), mat_stats1(5,3),...
                   mat_stats1(3,4), mat_stats1(4,4), mat_stats1(5,4));
              
compMat2    = [ 2,4;     % inter-sac visual distractor present vs. inter-hemifield distractor visual present
                3,5];    % inter-sac auditory distractor present vs. inter-hemifield distractor auditory present

for tComp2 = 1:size(compMat2,1)
    
    diff_bt = bootMat(:,compMat2(tComp2,1)) - bootMat(:,compMat2(tComp2,2));
    diff_mean = meanCond(compMat2(tComp2,1)) - meanCond(compMat2(tComp2,2));
        
    mat_stats2(1,tComp2) =  meanCond(compMat2(tComp2,1));
    mat_stats2(2,tComp2) =  seCond(compMat2(tComp2,1));
    mat_stats2(3,tComp2) =  meanCond(compMat2(tComp2,2));
    mat_stats2(4,tComp2) =  seCond(compMat2(tComp2,2));
    
    if ~isnan(diff_mean)
        if diff_mean < 0
            pVal_comp = sum(diff_bt>0)/sub.numBoot;
        elseif diff_mean > 0
            pVal_comp = 1-sum(diff_bt>0)/sub.numBoot;
        end
        pVal_comp = pVal_comp*2;
        if pVal_comp == 0;
            pVal_comp = 1/sub.numBoot;
        end
        mat_stats2(5,tComp2) = pVal_comp;
    else
        mat_stats2(5,tComp2) = NaN;
    end
end

fprintf(fstats,['\nInter-sac. visual distractor present vs. inter-hemifield distractor visual present (p < %1.4f)\n',...
                  'Inter-sac. auditory distractor present vs. inter-hemifield distractor auditory present (p = %1.4f)\n'],...
                   mat_stats2(5,1),...
                   mat_stats2(5,2));
           
load(sprintf('%s/%s_sacTimeMat.mat',sub.deriv_filedir,sub.ini));
fprintf(fstats,['\nVisual distractors: 1st saccade latency: %1.2f +/- %1.2f ms\n',...
                  'Visual distractors: 2nd saccade latency: %1.2f +/- %1.2f ms\n',...
                  'Auditory distractors: 1st saccade latency: %1.2f +/- %1.2f ms\n',...
                  'Auditory distractors: 2nd saccade latency: %1.2f +/- %1.2f ms\n',...
                  'Distractor absent: 1st saccade latency: %1.2f +/- %1.2f ms\n',...
                  'Distractor absent: 2nd saccade latency: %1.2f +/- %1.2f ms\n'],...
                   sacTimeMat{1,1}{2}(1),sacTimeMat{1,1}{2}(2),...
                   sacTimeMat{1,1}{3}(1),sacTimeMat{1,1}{3}(2),...
                   sacTimeMat{2,1}{2}(1),sacTimeMat{2,1}{2}(2),...
                   sacTimeMat{2,1}{3}(1),sacTimeMat{2,1}{3}(2),...
                   sacTimeMat{1,2}{2}(1),sacTimeMat{1,2}{2}(2),...
                   sacTimeMat{1,2}{3}(1),sacTimeMat{1,2}{3}(2));

load(sprintf('%s/%s_sac2After_norm.mat',sub.deriv_filedir,sub.ini));
load(sprintf('%s/%s_sac2BeforeInter_norm.mat',sub.deriv_filedir,sub.ini));

fprintf(fstats,['\nPre-saccadic inter-hemifield visual distractor trials: %1.2f +/- %1.2f\n',...
                  'Pre-saccadic inter-hemifield auditory distractor trials: %1.2f +/- %1.2f\n',...
                  'Inter-saccadic visual distractor trials: %1.2f +/- %1.2f\n',...
                  'Inter-saccadic auditory distractor trials: %1.2f +/- %1.2f\n',...
                  'Distractor absent trials: %1.2f +/- %1.2f\n'],...
                  sac2BeforeInter{1,1}{1}(1),sac2BeforeInter{1,1}{1}(2),...
                  sac2BeforeInter{2,1}{1}(1),sac2BeforeInter{2,1}{1}(2),...
                  sac2After{1,1}{1}(1),sac2After{1,1}{1}(2),...
                  sac2After{2,1}{1}(1),sac2After{2,1}{1}(2),...
                  sac2After{1,2}{1}(1),sac2After{1,2}{1}(2));
fclose('all');

end