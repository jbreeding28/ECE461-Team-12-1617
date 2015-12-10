a1=80;a2=60;a3=60;a4=20;%initalize amplitudes
a=[a1 a2 a3 a4];%vector of amplitudes for quadrants 1,2,3,4
a=abs(a);%get the magnitude
ra=[a1 a2 a3 a4]./max(a);%relative amplitudes (range from 0 to 1)
    %above step is probably unnecessary in optimized code
    
%sound intensity proportional to the inverse of distance squared
%therefore take inverse square root of relative amplitudes
rd=ra.^(-0.5);%relative distance
rd=rd./max(rd);%rd now ranges from 0 to 1