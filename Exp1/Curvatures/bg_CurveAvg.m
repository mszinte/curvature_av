function bg_CurveAvg(fig)

hold on
%% X axis
% plot xAxis line
x_Xaxis = fig.xAxisLim(1):0.01:fig.xAxisLim(end);
y_Xaxis = 0*x_Xaxis + fig.yAxisLim(1)*1.6;
plot(x_Xaxis,y_Xaxis,'Color',fig.black,'LineWidth',fig.axisWidth);

% plot xTick
x_Xaxis_tick = fig.xAxisTick;
y_Xaxis_tick = fig.yAxisLim(1)*1.6:-0.01:(fig.yAxisLim(1)*1.5)-fig.tickSizeY;
for t_XaxisTick = 1:size(fig.xAxisTick,2)
    plot(0*y_Xaxis_tick+x_Xaxis_tick(t_XaxisTick),y_Xaxis_tick,'Color',fig.black,'LineWidth',fig.axisWidth)
    if t_XaxisTick == 1 || t_XaxisTick == 4 || t_XaxisTick == 7
        text(x_Xaxis_tick(t_XaxisTick),fig.yAxisLim(1)*2.9,sprintf('%1.2g',fig.xAxisTick(t_XaxisTick)),'HorizontalAlignment','center')
    end
end

% xlabel
text(0,fig.yAxisLim(1)*4.2,fig.xAxisTxt,'HorizontalAlignment','center')

%% stim areas
fill([fig.xAxisLim(1),0,0,fig.xAxisLim(1)],...
    [fig.yAxisLim(1),fig.yAxisLim(1),fig.yAxisLim(end)/2,fig.yAxisLim(end)/2],fig.area_lftCol,'LineStyle','none');

fill([0,fig.xAxisLim(2),fig.xAxisLim(2),0],...
    [fig.yAxisLim(1),fig.yAxisLim(1),fig.yAxisLim(end)/2,fig.yAxisLim(end)/2],fig.area_rgtCol,'LineStyle','none');

%% back title
text(fig.xAxisLim(2)/2,fig.yAxisTick(1),fig.txtRgt,'HorizontalAlignment','center','FontSize',10,'FontAngle','italic')
text(fig.xAxisLim(1)/2,fig.yAxisTick(1),fig.txtLft,'HorizontalAlignment','center','FontSize',10,'FontAngle','italic')

end
