function bsData = bootstrap(data,ni)
% ----------------------------------------------------------------------
% bsData = bootstrap(data,ni)
% ----------------------------------------------------------------------
% Goal of the function :
% Bootstrap data by sampling with replacement from the rows in data. 
% ----------------------------------------------------------------------
% Input(s) :
% data : matrix to bootstrap
% ni: number of bootstrat iteration
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

if nargin<2
    ni = 100;
end

nc = size(data,1);

for i = 1:ni
    bsSample = randsample(1:nc,nc,1);    
    bsData(i,:) = mean(data(bsSample,:));
end
