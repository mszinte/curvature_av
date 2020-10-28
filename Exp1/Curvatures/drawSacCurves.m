function drawSacCurves(sub,normType)
% ----------------------------------------------------------------------
% drawSacCurves(sub,normType)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw mean saccade path for the different kind of normalization
% ----------------------------------------------------------------------
% Input(s) :
% sub : subject informations
% normType : normalization type
% ----------------------------------------------------------------------
% Output(s):
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

close all

txtNormType       = {'','_norm'};
% txtTypeRes = {'','Same','Cross'};

% load data
load(sprintf('%s/%s_sac2After%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}));
load(sprintf('%s/%s_sac2BeforeInter%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}));
load(sprintf('%s/%s_sac2BeforeIntra%s.mat',sub.deriv_filedir,sub.ini,txtNormType{normType}));

%% Plot settings
% figure
numRow = 2;
numCol = 3;
figSize_X = 240*numCol;
figSize_Y = 300*numRow;
start_X = 0;start_Y = 0;
paperSize = [figSize_X/30,figSize_Y/30];
paperPos = [0 0 paperSize(1) paperSize(2)];

% colors
fig.beige               = [245,241,237]/255;
fig.gray_light          = [.9 .9 .9];
fig.gray_dark           = [.7 .7 .7];
fig.black               = [0 0 0];
fig.black_light         = [.3 .3 .3];
fig.white               = [1 1 1];
fig.orange              = [248,149, 32]/255;
fig.orange_light        = [250,191,120]/255;

% background details
fig.axisWidth = 1;
fig.area_lftCol     = fig.gray_light;
fig.area_rgtCol     = fig.gray_dark;
fig.txtArea         = 1;
fig.txtLft          = 'away';
fig.txtRgt          = 'toward';
stepY               = 2.5;
fig.yAxisTick       = 0:stepY:15;
fig.yAxisLim        = [fig.yAxisTick(1)-stepY/2,fig.yAxisTick(end)+stepY/2];
fig.tickSizeY       = 0.25*stepY;

% width
fig.axisWidth = 1;
traceWidth = 2;
resCol = 2;

tFig = 0;
for typeRes = 1:3
    switch typeRes
        case 1;
            nameFig = 'Inter-saccadic trials'; 
            nameSaveFig = '_After';
            matRes = sac2After;
        case 2;
            nameFig = 'Inter-hemifield pre-saccadic trials';
            matRes = sac2BeforeInter;
            nameSaveFig = '_BeforeInter';
        case 3;
            nameFig = 'Intra-hemifield pre-saccadic trials';
            matRes = sac2BeforeIntra;
            nameSaveFig = '_BeforeIntra';
    end
    tFig = tFig+1;
    f(tFig) = figure;

    set(f(tFig),'Name',nameFig,'PaperUnits','centimeters','PaperPosition',paperPos,'Color',[1 1 1],'PaperSize',paperSize);
    set(f(tFig),'Position',[start_X,start_Y,figSize_X,figSize_Y]);
    plot_file = sprintf('%s/%s_res%s%s.pdf',sub.deriv_filedir,sub.ini,nameSaveFig,txtNormType{normType});

    for tRow = 1:numRow
        switch tRow
            case 1;
                fig.xAxisTxt = 'Horizontal coordinates (deg)';
                fig.yAxisTxt = 'Vertical coordinates (deg)';
            case 2;
                fig.xAxisTxt = 'Curvature angle (deg)';
                fig.yAxisTxt = '';
        end
        for tCol = 1:numCol
            switch tCol
                case 1 % visual
                    if tRow == 1;valStepX = 0.2;
                    elseif tRow == 2;valStepX = 2;
                    end
                        
                    txtCol = 'Visual';
                    cond1 = 1;
                            
                case 2 % auditory
                    if tRow == 1;valStepX = 0.1;
                    elseif tRow == 2;valStepX = 1;
                    end
                    txtCol = 'Auditory';
                    cond1 = 2;
                    
                case 3 % audiovisual
                    if tRow == 1;valStepX = 0.2;
                    elseif tRow == 2;valStepX = 2;
                    end
                    txtCol = 'Audiovisual';
                    cond1 = 3;
                    
            end
            fig.stepX           = valStepX;
            fig.xAxisTick       = -(valStepX*3):fig.stepX:(valStepX*3);
            fig.xAxisLim        = [fig.xAxisTick(1)-fig.stepX/2,fig.xAxisTick(end)+fig.stepX/2];
            fig.tickSizeX       = 0.2*fig.stepX;
                
            drawYet = 0;
            for tPlot = 1:2
                switch tPlot
                    case 1 % distractor present
                        rand1       = 1;
                        colPlot     = fig.orange;
                        colPlotCI   = fig.orange_light;
                        lineStyle   = '-';
                    case 2 % distractor absent
                        rand1       = 2;
                        colPlot     = fig.black;
                        colPlotCI   = fig.black_light;
                        lineStyle   = '--';
                end
                    
                
                    
                if ~drawYet
                    drawYet = 1;
                    h_xstart = (tCol-1)/numCol;
                    h_ystart = (numRow-tRow)/numRow;
                    h_xsize  = 1/numCol;
                    h_ysize  = 1/numRow;
                    axes('position',[h_xstart,h_ystart,h_xsize,h_ysize]);
                        
                    % graph background
                    if tRow == 1;       
                        bg_CurvePath(fig)
                        set(gca,'Xlim',[fig.xAxisLim(1)-3.5*fig.stepX,fig.xAxisLim(end)+0.5*fig.stepX],...
                            'Ylim',[fig.yAxisLim(1)-2.5*stepY,fig.yAxisLim(end)+3*stepY],...
                            'Box','off','XTick',[],'YTick',[],'XColor',fig.white,'YColor',fig.white);
                        
                    elseif tRow == 2;   
                        bg_CurveAvg(fig);
                        set(gca,'Xlim',[fig.xAxisLim(1)-3.5*fig.stepX,fig.xAxisLim(end)+0.5*fig.stepX],...
                            'Ylim',[fig.yAxisLim(1)-2.5*stepY,fig.yAxisLim(end)+3*stepY]-18,...
                            'Box','off','XTick',[],'YTick',[],'XColor',fig.white,'YColor',fig.white);
                    end
                    
                    
                end
                
                % plot data    
                if tRow == 1
                    
                    matPlot = matRes{cond1,rand1}{2};
                    
%                     % plot ci areas
%                     if strcmp(sub.ini,'sub-00')
%                         
%                         matRes = matRes(matRes(:,2)>=0 & matRes(:,2)<=15 & ...
%                             matRes(:,4)>=0 & matRes(:,4)<=15 & ...
%                             matRes(:,6)>=0 & matRes(:,6)<=15,:);
%                         xFill = [matRes(:,3);flipud(matRes(:,5))]';
%                         yFill = [matRes(:,4);flipud(matRes(:,6))]';
%                         fill(xFill,yFill,colPlotCI,'LineStyle','none');
%                         
%                     end
                    
                    matPlot = matPlot(matPlot(:,2)>=0 & matPlot(:,2)<=15,:);
                    plot(matPlot(:,1),matPlot(:,2),'Color',colPlot,'LineWidth',traceWidth,'LineStyle',lineStyle);
                
                elseif tRow ==2
                    valPlot = matRes{cond1,rand1}{3}(1);
                    barh(2.25,valPlot,'FaceColor',colPlot,'LineStyle','none','BarWidth',1.25);
                    
                end

                % plot title
                if tRow == 1
                    text(0,19,sprintf('%s',txtCol),...
                        'HorizontalAlignment','center','VerticalAlignment','middle');
                    text(0,17.5,'distractor','HorizontalAlignment','center','VerticalAlignment','middle');
                
                
                    
                    xLegStart           = fig.xAxisTick(1) + 0*fig.stepX;
                    xLegEnd             = fig.xAxisTick(1) + 1/2*fig.stepX;
                    xLegTxt             = fig.xAxisTick(1) + 0.75*fig.stepX;
                    yLeg1               = 15;
                    yLeg2               = 14;
                    legMulti            = 0.7;
                    xLegLine            = xLegStart:0.01:xLegEnd;
                    yLegLine_1          = 0*xLegLine + yLeg1;
                    yLegLine_2          = 0*xLegLine + yLeg2;
                    yLegLine            = [yLegLine_1;yLegLine_2];
                    
                    % plot legend
                    plot(xLegLine,yLegLine(tPlot,:),'Color',colPlot,'LineWidth',traceWidth*legMulti);
                    numT = matRes{cond1,rand1}{1}(1);
                    if tPlot == 1;txtLeg      = 'distractor present';
                    else txtLeg      = 'distractor absent';
                    end
                    
                    text(xLegTxt,yLegLine(tPlot,1)+0.2,[txtLeg,sprintf(' (%3.0f)',numT(1))],...
                            'FontSize',8,'HorizontalAlignment','left','VerticalAlignment','middle');
                    
                    
                end
                
                
            end
        end
    end
    saveas(f(tFig),plot_file);
end

end