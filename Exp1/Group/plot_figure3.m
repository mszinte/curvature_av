function plot_figure3(sub)
% ----------------------------------------------------------------------
% plot_figure3(sub)
% ----------------------------------------------------------------------
% Goal of the function :
% Draw Figure 3 as in manuscript
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
warning ('off','all');

% load data
load(sprintf('%s/%s_sac2BeforeInter_norm.mat',sub.deriv_filedir,sub.ini));
load(sprintf('%s/%s_sac2BeforeIntra_norm.mat',sub.deriv_filedir,sub.ini));

%% Plot settings
% figure
numRow = 4;
numCol = 3;
figSize_X = 240*numCol;
figSize_Y = 300*numRow;
start_X = 0;start_Y = 0;
paperSize = [figSize_X/30,figSize_Y/30];
paperPos = [0 0 paperSize(1) paperSize(2)];

% colors
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

nameFig = 'Figure3: Pre-saccadic trials'; 


f = figure;

set(f,'Name',nameFig,'PaperUnits','centimeters','PaperPosition',paperPos,'Color',[1 1 1],'PaperSize',paperSize);
set(f,'Position',[start_X,start_Y,figSize_X,figSize_Y]);
plot_file = sprintf('%s/Figure3.pdf',sub.deriv_filedir);

for tRow = 1:numRow
    switch tRow
        case 1;
            fig.xAxisTxt = 'Horizontal coordinates (deg)';
            fig.yAxisTxt = 'Vertical coordinates (deg)';
            matRes = sac2BeforeInter;
        case 2;
            fig.xAxisTxt = 'Curvature angle (deg)';
            fig.yAxisTxt = '';
            matRes = sac2BeforeInter;
        case 3;
            fig.xAxisTxt = 'Horizontal coordinates (deg)';
            fig.yAxisTxt = 'Vertical coordinates (deg)';
            matRes = sac2BeforeIntra;
        case 4;
            fig.xAxisTxt = 'Curvature angle (deg)';
            fig.yAxisTxt = '';
            matRes = sac2BeforeIntra;
    end
    for tCol = 1:numCol
        switch tCol
            case 1 % visual
                if tRow == 1 || tRow == 3;valStepX = 0.5/3;
                elseif tRow == 2 || tRow == 4;valStepX = 5/3;
                end
                txtCol = 'Visual';
                cond1 = 1;
                
            case 2 % auditory
                if tRow == 1 || tRow == 3;valStepX = 0.25/3;
                elseif tRow == 2 || tRow == 4;valStepX = 2.5/3;
                end
                txtCol = 'Auditory';
                cond1 = 2;
                
            case 3 % audiovisual
                if tRow == 1 || tRow == 3;valStepX = 0.5/3;
                elseif tRow == 2 || tRow == 4;valStepX = 5/3;
                end
                txtCol = 'Audiovisual';
                cond1 = 3;
                
        end
        fig.stepX           = valStepX;
        fig.xAxisTick       = -(valStepX*3):fig.stepX:(valStepX*3);
        fig.xAxisLim        = [fig.xAxisTick(1)-fig.stepX/2,fig.xAxisTick(end)+fig.stepX/2];
        fig.tickSizeX       = 0.2*fig.stepX;
        
        drawYet = 0;
        
        rand1       = 1;
        colPlot     = fig.orange;
        colPlotCI   = fig.orange_light;
        lineStyle   = '-';  
        
        
        if ~drawYet
            drawYet = 1;
            h_xstart = (tCol-1)/numCol;
            h_ystart = (numRow-tRow)/numRow;
            h_xsize  = 1/numCol;
            h_ysize  = 1/numRow;
            axes('position',[h_xstart,h_ystart,h_xsize,h_ysize]);
            
            % graph background
            if tRow == 1 || tRow == 3
                bg_CurvePath(fig)
                set(gca,'Xlim',[fig.xAxisLim(1)-3.5*fig.stepX,fig.xAxisLim(end)+0.5*fig.stepX],...
                    'Ylim',[fig.yAxisLim(1)-2.5*stepY,fig.yAxisLim(end)+3*stepY],...
                    'Box','off','XTick',[],'YTick',[],'XColor',fig.white,'YColor',fig.white);
                
            elseif tRow == 2 || tRow == 4
                bg_CurveAvg(fig);
                set(gca,'Xlim',[fig.xAxisLim(1)-3.5*fig.stepX,fig.xAxisLim(end)+0.5*fig.stepX],...
                    'Ylim',[fig.yAxisLim(1)-2.5*stepY,fig.yAxisLim(end)+3*stepY]-18,...
                    'Box','off','XTick',[],'YTick',[],'XColor',fig.white,'YColor',fig.white);
            end
            
        end
        
        % plot data
        if tRow == 1 || tRow == 3
            
%             for subNum = 1:sub.numSjct
%                 matPlot_sub = matRes{cond1,rand1}{5}(:,:,subNum);
%                 matPlot_sub = matPlot_sub(matPlot_sub(:,2)>=0 & matPlot_sub(:,2)<=15,:);
%                 plot(matPlot_sub(:,1),matPlot_sub(:,2),'Color',fig.black,'LineWidth',traceWidth/10,'LineStyle',lineStyle);
%             end
            
            matPlot = matRes{cond1,rand1}{2};
            matPlot_eb_down = matPlot(:,1:2) - matPlot(:,3:4);
            matPlot_eb_up = matPlot(:,1:2) + matPlot(:,3:4);
            matPlot_eb_down = matPlot_eb_down(matPlot_eb_down(:,2)>=0 & matPlot_eb_down(:,2)<=15,:);
            matPlot_eb_up = matPlot_eb_up(matPlot_eb_up(:,2)>=0 & matPlot_eb_up(:,2)<=15,:);
            x_eb = [matPlot_eb_down(:,1);flipud(matPlot_eb_up(:,1))]';
            y_eb = [matPlot_eb_down(:,2);flipud(matPlot_eb_up(:,2))]';
            fill(x_eb,y_eb,colPlotCI,'LineStyle','none');
            matPlot = matPlot(matPlot(:,2)>=0 & matPlot(:,2)<=15,:);
            plot(matPlot(:,1),matPlot(:,2),'Color',colPlot,'LineWidth',traceWidth,'LineStyle',lineStyle);
                
        elseif tRow == 2 || tRow == 4
            pos_bar = 2.25;
            valPlot = matRes{cond1,rand1}{3};
            valPlot_eb_down = valPlot(1)-valPlot(2);
            valPlot_eb_up = valPlot(1)+valPlot(2);
            barh(pos_bar,valPlot(1),'FaceColor',colPlotCI,'LineStyle','none','BarWidth',3);
             
            pos_indiv = 2.25;
            valPlotIndiv = matRes{cond1,rand1}{6};
            plot(valPlotIndiv,pos_indiv,'o','MarkerSize',4,'MarkerFaceColor',fig.black,'MarkerEdgeColor','none');
            
            x_eb = linspace(valPlot_eb_down,valPlot_eb_up,10);
            y_eb = x_eb*0 + pos_bar;
            plot(x_eb,y_eb,'Color',colPlot,'LineWidth',traceWidth,'LineStyle',lineStyle); 
            
        end
        
        % plot title
        if tRow == 1 || tRow == 3
            text(0,19,sprintf('%s',txtCol),...
                'HorizontalAlignment','center','VerticalAlignment','middle');
            text(0,17.5,'distractor','HorizontalAlignment','center','VerticalAlignment','middle');
        end

    end
end
saveas(f,sprintf('%s/Figure3.pdf',sub.deriv_filedir));      % classical save

end