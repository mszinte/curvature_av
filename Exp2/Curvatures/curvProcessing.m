function curvProcessing(sub,normType)
% ----------------------------------------------------------------------
% curvProcessing(sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Process all trajectories and metrics
% normType : normalization type
% ----------------------------------------------------------------------
% Input(s) :
% sub : subject and analysis configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

txtNormAna = {'raw data ','normalized data'};
txtNormType = {'','_norm'};

fprintf(1,'\n\tData processing: %s',txtNormAna{normType});
load(sprintf('%s.mat',sub.coord_deriv_filename_all));

if normType ~= 1  
    load(sprintf('%s/%s_sac2CondMat.mat',sub.deriv_filedir,sub.ini));
    fileDir= sprintf('%s.csv',sub.tab_deriv_filename_all);
    fileRes = csvread(fileDir);
    sac2CondCol = 101;
    distPres = 2;       % normalization to distractor absent trials
end

for tCorTrials = 1:size(partCoord_all,2)
    % fixation target position
    matTypeTrial        = partCoord_all{tCorTrials}{1};
    dat                 = partCoord_all{tCorTrials}{2};
    rand5               = partCoord_all{tCorTrials}{1}(1,8);
    accurateSac1Trial   = partCoord_all{tCorTrials}{1}(1,96);
    accurateSac2Trial   = partCoord_all{tCorTrials}{1}(1,99);
    sac2Onset           = partCoord_all{tCorTrials}{1}(1,64);
    sac2Offset          = partCoord_all{tCorTrials}{1}(1,65);
    
    if normType ~= 1
        sac2Cond = fileRes(tCorTrials,sac2CondCol);
    end
    
    % curvature pre-processing
    if accurateSac1Trial && accurateSac2Trial
        
        % Saccade 2 data
        % ==============
        idxSac2  = find(dat(:,1) >= sac2Onset & dat(:,1) <= sac2Offset);
        timeSac2 = dat(idxSac2,1);
        datSac2  = dat(idxSac2,2:3);
        
        % reset coord to display center, reverese Y axis and put in degrees
        datSac2(:,1) = datSac2(:,1) - sub.scr_sizeX/2;
        datSac2(:,2) = (datSac2(:,2) - sub.scr_sizeY/2).*-1;
        
        % raw data
        datSac2Raw = [timeSac2,datSac2./sub.PPD];
        
        % rotate raw data if function of condition
        if rand5 == 1
            rotAngleSac2Raw = 0;
        elseif rand5 == 2
            rotAngleSac2Raw = 180;
        end
        datSac2Raw(:,2) = cosd(rotAngleSac2Raw).*datSac2Raw(:,2) - sind(rotAngleSac2Raw).*datSac2Raw(:,3);
        datSac2Raw(:,3) = sind(rotAngleSac2Raw).*datSac2Raw(:,2) + cosd(rotAngleSac2Raw).*datSac2Raw(:,3);
        
        % apply histogram to have monotonic data of the mean
        [datSac2RawMat] = hist3(datSac2Raw(:,2:3),'edges',{sub.xMat_range,sub.yMat_range});
        for yCol = 1:size(datSac2RawMat,2)
            meanf(yCol) = histStats(datSac2RawMat(:,yCol),sub.xMat_range);
        end
        datSac2RawResize = [meanf',sub.yMat_range'];
        datSac2RawResize = datSac2RawResize(~isnan(datSac2RawResize(:,1)),:);
        datSac2RawResizeX = interp1(datSac2RawResize(:,2),datSac2RawResize(:,1),sub.yMat_range');
        datSac2RawResize = [datSac2RawResizeX,sub.yMat_range'];
        
        % Normalization of raw data with filtered raw mean
        if normType ~= 1
            datSac2RawResize = [datSac2RawResize(:,1) - sac2CondMat{sac2Cond,distPres}{2}(:,1),datSac2RawResize(:,2)];
            datSac2Raw = [datSac2RawResize(~isnan(datSac2RawResize(:,1)),1)*0-8,datSac2RawResize(~isnan(datSac2RawResize(:,1)),:)];% add -8 in time column
        end
        
        % #1: Median saccade curvature
        angleSac2OnOff = atand((datSac2Raw(end,2)-datSac2Raw(1,2))/(datSac2Raw(end,3)-datSac2Raw(1,3)));
        angleSac2_all = [];
        for tSac2Raw = 1:size(datSac2Raw,1)
            oppSideSac2 = datSac2Raw(tSac2Raw,2) - datSac2Raw(1,2);
            adjSideSac2 = datSac2Raw(tSac2Raw,3) - datSac2Raw(1,3);
            if adjSideSac2 == 0
                angleSac2 = 0-angleSac2OnOff;
            else
                angleSac2 = atand(oppSideSac2/adjSideSac2)-angleSac2OnOff;
            end
            angleSac2_all = [angleSac2_all;angleSac2];
        end
        curvMedianSac2 = median(angleSac2_all);
        
        % save all data
        coordSac{tCorTrials} = {matTypeTrial;datSac2Raw;datSac2RawResize;curvMedianSac2};
        
    end
end
save(sprintf('%s%s.mat',sub.curv_deriv_filename_all,txtNormType{normType}),'coordSac');

end