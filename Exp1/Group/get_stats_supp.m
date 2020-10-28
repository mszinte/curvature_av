function get_stats_supp(sub)
% ----------------------------------------------------------------------
% get_stats_supp(sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Extract statistical value used in supplementary (review)
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

stats_file = sprintf('%s/%s_stats_supp.txt',sub.deriv_filedir,sub.ini);
fstats = fopen(stats_file,'w');

matRes = [];
for numSjct = 1:sub.numSjct
    
    sub.deriv_filedir_ini = sprintf('%s/OSF_deriv_data/%s',sub.dirF,sprintf('sub-0%i',numSjct));
    load(sprintf('%s/%s_sac2BeforeInterSac1LatT_norm.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
    load(sprintf('%s/%s_sac2BeforeIntraSac1LatT_norm.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
    load(sprintf('%s/%s_sac2AfterSac1LatT_norm.mat',sub.deriv_filedir_ini ,sprintf('sub-0%i',numSjct)));
    
    matRes(numSjct,:)  = [  sac2AfterSac1LatT{1,2,1}{3},...                 % distractor absent early sac1
                            sac2AfterSac1LatT{1,1,1}{3},...                 % inter-sac visual distractor present early sac1
                            sac2AfterSac1LatT{2,1,1}{3},...                 % inter-sac auditory distractor present early sac1
                            sac2AfterSac1LatT{3,1,1}{3},...                 % inter-sac audiovisual distractor present early sac1
                            sac2BeforeInterSac1LatT{1,1,1}{3},...           % pre-sac inter-hemifield distractor visual present early sac1
                            sac2BeforeInterSac1LatT{2,1,1}{3},...           % pre-sac inter-hemifield distractor auditory present early sac1
                            sac2BeforeInterSac1LatT{3,1,1}{3},...           % pre-sac inter-hemifield distractor audiovisual present early sac1
                            sac2BeforeIntraSac1LatT{1,1,1}{3},...           % pre-sac intra-hemifield distractor visual present early sac1
                            sac2BeforeIntraSac1LatT{2,1,1}{3},...           % pre-sac intra-hemifield distractor auditory present early sac1
                            sac2BeforeIntraSac1LatT{3,1,1}{3},...           % pre-sac intra-hemifield distractor audiovisual present early sac1
                            sac2AfterSac1LatT{1,2,2}{3},...                 % distractor absent late sac1
                            sac2AfterSac1LatT{1,1,2}{3},...                 % inter-sac visual distractor present late sac1
                            sac2AfterSac1LatT{2,1,2}{3},...                 % inter-sac auditory distractor present late sac1
                            sac2AfterSac1LatT{3,1,2}{3},...                 % inter-sac audiovisual distractor present late sac1
                            sac2BeforeInterSac1LatT{1,1,2}{3},...           % pre-sac inter-hemifield distractor visual present late sac1
                            sac2BeforeInterSac1LatT{2,1,2}{3},...           % pre-sac inter-hemifield distractor auditory present late sac1
                            sac2BeforeInterSac1LatT{3,1,2}{3},...           % pre-sac inter-hemifield distractor audiovisual present late sac1
                            sac2BeforeIntraSac1LatT{1,1,2}{3},...           % pre-sac intra-hemifield distractor visual present late sac1
                            sac2BeforeIntraSac1LatT{2,1,2}{3},...           % pre-sac intra-hemifield distractor auditory present late sac1
                            sac2BeforeIntraSac1LatT{3,1,2}{3}];             % pre-sac intra-hemifield distractor audiovisual present late sac1
end

bootMat     = bootstrap(matRes,sub.numBoot);
meanCond    = nanmean(matRes,1);
seCond      = nanstd(matRes,0,1)/sqrt(sub.numSjct);

% First set of comparisons
compMat1    = [ 1,2;...     % absent vs. inter-sac visual distractor present + early sac1
                1,3;...     % absent vs. inter-sac auditory distractor present + early sac1
                1,4;...     % absent vs. inter-sac audiovisual distractor present + early sac1
                1,5;...     % absent vs. inter-hemifield distractor visual present + early sac1
                1,6;...     % absent vs. inter-hemifield distractor auditory present + early sac1
                1,7;...     % absent vs. inter-hemifield distractor audiovisual present + early sac1
                1,8;...     % absent vs. intra-hemifield distractor visual present + early sac1
                1,9;...     % absent vs. intra-hemifield distractor auditory present + early sac1
                1,10;...	% absent vs. intra-hemifield distractor audiovisual present + early sac1
                11,12;      % absent vs. inter-sac visual distractor present + late sac1
                11,13;      % absent vs. inter-sac auditory distractor present + late sac1
                11,14;      % absent vs. inter-sac audiovisual distractor present + late sac1
                11,15;      % absent vs. inter-hemifield distractor visual present + late sac1
                11,16;      % absent vs. inter-hemifield distractor auditory present + late sac1
                11,17;      % absent vs. inter-hemifield distractor audiovisual present + late sac1
                11,18;      % absent vs. intra-hemifield distractor visual present + late sac1
                11,19;      % absent vs. intra-hemifield distractor auditory present + late sac1
                11,20];     % absent vs. intra-hemifield distractor audiovisual present + late sac1

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

fprintf(fstats,[   'Early saccade: \n',...
                   'Distrator absent (%1.2f +/- %1.2f deg -mean +/- SEM-) vs. \n',...
                   'Inter-sac. visual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Inter-sac. auditory distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Inter-sac. audiovisual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Pre-sac. inter-hemifield visual distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. inter-hemifield auditory distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. inter-hemifield audiovisual distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. intra-hemifield visual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Pre-sac. intra-hemifield auditory distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. intra-hemifield audiovisual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n'],...
                   mat_stats1(1,1), mat_stats1(2,1),...
                   mat_stats1(3,1), mat_stats1(4,1), mat_stats1(5,1),...
                   mat_stats1(3,2), mat_stats1(4,2), mat_stats1(5,2),...
                   mat_stats1(3,3), mat_stats1(4,3), mat_stats1(5,3),...
                   mat_stats1(3,4), mat_stats1(4,4), mat_stats1(5,4),...
                   mat_stats1(3,5), mat_stats1(4,5), mat_stats1(5,5),...
                   mat_stats1(3,6), mat_stats1(4,6), mat_stats1(5,6),...
                   mat_stats1(3,7), mat_stats1(4,7), mat_stats1(5,7),...
                   mat_stats1(3,8), mat_stats1(4,8), mat_stats1(5,8),...
                   mat_stats1(3,9), mat_stats1(4,9), mat_stats1(5,9));
               
fprintf(fstats,[   'Late saccade: \n',...
                   'Distrator absent (%1.2f +/- %1.2f deg -mean +/- SEM-) vs. \n',...
                   'Inter-sac. visual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Inter-sac. auditory distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Inter-sac. audiovisual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Pre-sac. inter-hemifield visual distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. inter-hemifield auditory distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. inter-hemifield audiovisual distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. intra-hemifield visual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n',...
                   'Pre-sac. intra-hemifield auditory distractor present (%1.2f +/- %1.2f, p = %1.4f)\n',...
                   'Pre-sac. intra-hemifield audiovisual distractor present (%1.2f +/- %1.2f, p < %1.4f)\n'],...
                   mat_stats1(1,10), mat_stats1(2,10),...
                   mat_stats1(3,10), mat_stats1(4,10), mat_stats1(5,10),...
                   mat_stats1(3,11), mat_stats1(4,11), mat_stats1(5,11),...
                   mat_stats1(3,12), mat_stats1(4,12), mat_stats1(5,12),...
                   mat_stats1(3,13), mat_stats1(4,13), mat_stats1(5,13),...
                   mat_stats1(3,14), mat_stats1(4,14), mat_stats1(5,14),...
                   mat_stats1(3,15), mat_stats1(4,15), mat_stats1(5,15),...
                   mat_stats1(3,16), mat_stats1(4,16), mat_stats1(5,16),...
                   mat_stats1(3,17), mat_stats1(4,17), mat_stats1(5,17),...
                   mat_stats1(3,18), mat_stats1(4,18), mat_stats1(5,18));

end