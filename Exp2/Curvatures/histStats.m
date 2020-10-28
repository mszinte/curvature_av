function [meanf] = histStats(freq,bins)
% ----------------------------------------------------------------------
% [meanf] = histStats(freq,bins)
% ----------------------------------------------------------------------
% Goal of the function :
% Compute 2D histogram mean
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing a lot of constant configuration
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing a lot of constant configuration
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

q1=find(freq);

q2=[];
for i = 1:length(q1)
    q2 = [q2 repmat(bins(q1(i)),1,freq(q1(i)))];
end

meanf=mean(q2);

end