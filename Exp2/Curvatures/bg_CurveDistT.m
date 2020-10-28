function bg_CurveDistT(fig)

hold on
%% X axis
% plot xAxis line
x_Xaxis = fig.xAxisLim(1):0.01:fig.xAxisLim(end);
y_Xaxis = 0*x_Xaxis + fig.yAxisLim(1)*1.2;
plot(x_Xaxis,y_Xaxis,'Color',fig.black,'LineWidth',fig.axisWidth);

% plot xTick
x_Xaxis_tick = fig.xAxisTick;
y_Xaxis_tick = fig.yAxisLim(1)*1.2:-0.01:(fig.yAxisLim(1)*1.2)-fig.tickSizeY;
for t_XaxisTick = 1:size(fig.xAxisTick,2)
    plot(0*y_Xaxis_tick+x_Xaxis_tick(t_XaxisTick),y_Xaxis_tick,'Color',fig.black,'LineWidth',fig.axisWidth)
    if t_XaxisTick == 1 || t_XaxisTick == 6
        text(x_Xaxis_tick(t_XaxisTick),fig.yAxisLim(1)*1.45,sprintf('%1.0f',fig.xAxisTick(t_XaxisTick)),'HorizontalAlignment','center')
    end
end

% xlabel
text(mean(fig.xAxisLim),fig.yAxisLim(1)*1.65,fig.xAxisTxt,'HorizontalAlignment','center')

%% Y axis

% plot yAxis
y_Yaxis = fig.yAxisLim(1):0.05:fig.yAxisLim(end);
x_Yaxis = 0*y_Yaxis + fig.xAxisLim(1)*1.08;

plot(x_Yaxis,y_Yaxis,'Color',fig.black,'LineWidth',fig.axisWidth);

% plot yTick
y_Yaxis_tick = fig.yAxisTick;
x_Xaxis_tick = fig.xAxisLim(1)*1.08:-0.01:(fig.xAxisLim(1)*1.08)-fig.tickSizeX;

for t_YaxisTick = 1:size(fig.yAxisTick,2)
    plot(x_Xaxis_tick,0*x_Xaxis_tick+y_Yaxis_tick(t_YaxisTick),'Color',fig.black,'LineWidth',fig.axisWidth)
    if t_YaxisTick == 1 || t_YaxisTick == 4 || t_YaxisTick == 7
        text(fig.xAxisLim(1)*1.2,y_Yaxis_tick(t_YaxisTick),sprintf('%1.2g',fig.yAxisTick(t_YaxisTick)),'HorizontalAlignment','center')
    end
end

% ylabel
text(fig.xAxisLim(1)*1.35,0,fig.yAxisTxt,'HorizontalAlignment','center','Rotation',90)


%% stim areas
fill([fig.xAxisLim(1),fig.xAxisLim(2),fig.xAxisLim(2),fig.xAxisLim(1)],...
     [0,0,fig.yAxisLim(1),fig.yAxisLim(1)],fig.area_lftCol,'LineStyle','none');
 
 fill([fig.xAxisLim(1),fig.xAxisLim(2),fig.xAxisLim(2),fig.xAxisLim(1)],...
     [0,0,fig.yAxisLim(2),fig.yAxisLim(2)],fig.area_rgtCol,'LineStyle','none');

text(fig.xAxisLim(2)-50,fig.yAxisLim(2)/2,fig.txtRgt,'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',10,'FontAngle','italic','Rotation',90)
text(fig.xAxisLim(2)-50,fig.yAxisLim(1)/2,fig.txtLft,'VerticalAlignment','middle','HorizontalAlignment','center','FontSize',10,'FontAngle','italic','Rotation',90)


end

