function sac = saccpar(sac)
% ----------------------------------------------------------------------
% sac = saccpar(sac)
% ----------------------------------------------------------------------
% Goal of the function :
% Parse saccade parameters
% ----------------------------------------------------------------------
% Input(s) :
% sac(:,1:7): monocular microsaccades (from microsacc.m)
%-------------------------------------------------------------------
% Output(s) :
% sac(:,1:8): Parameters 
%---------------------------------------------------------------------
% Function created by Martin Rolfs
%          adapted by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------

if size(sac,1)>0
    % 1. Onset
    a = sac(:,1);

    % 2. Offset
    b = sac(:,2);

    % 3. Duration
    D = ((b-a));

    % 4. Peak velocity
    vpeak = sac(:,3);

    % 6. Saccade distance
    dist = sqrt(sac(:,4).^2+sac(:,5).^2);
    angd = atan2(sac(:,5),sac(:,4));

    % 7. Saccade amplitude
    ampl = sqrt(sac(:,6).^2+sac(:,7).^2);
    anga = atan2(sac(:,7),sac(:,6));

    sac = [a b D vpeak dist angd ampl anga];
else
    sac = [];
end