classdef localizer < handle
    %LOCALIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        locHistory;
        curInd;
        loc_timer;
        hIm;
    end
    
    methods
        function L = localizer()
            % locHistory is meant to keep a timestamped history of drone
            % location. It is meant for testing purposes.
            L.locHistory = zeros(10000,2); % [timestamp, location]
            L.curInd = 1;
            L.loc_timer = tic;
            disp('Localization timer started')
        end
        function [location, A_copy] = direction(L,A1,A2,A3,A4)
            location=0;%initialize
            %Input 4 amplitudes (representing the peak magnitude recieved at each mic)
            %  Output: Text describing the direction of the source
            A = [A1 A2 A3 A4];
            A_copy=A;
            if (A1==0&&A2==0&&A3==0&&A4==0)
                %fprintf('No drone detected\n')
                location = 0;
                if(L.curInd == length(L.locHistory))
                    L.curInd = 1;
                end
                L.locHistory(L.curInd,:) = [toc(L.loc_timer) location];
                L.curInd = L.curInd+1;
                return;
            end
            [max1, I1] = max(A);
            A(I1) = [-50];
            [max2, I2] = max(A);
            A(I2) = [-50];
            [max3, I3] = max(A);
            A(I3) = [-50];
            [max4, I4] = max(A);
            A(I4) = [-50];
            if (((max2*.90 <= max1) && (max1 <= max2*1.1)) && ((max3*.90 <= max1) && (max1 <= max3*1.1)) && ((max4*.9 <= max1) && (max1 <= max4*1.1)))
                location=9;
                % fprintf('Source is located directly above in the center\n');
%             elseif (I1 == 1 && I2 == 3)
%                 fprintf('There are two sources in quadrant 1 and 3\n');
%             elseif (I1 == 2 && I2 == 4)
%                 fprintf('There are two sources in quadrant 2 and 4\n');
%             elseif (I1 == 3 && I2 == 1)
%                 fprintf('There are two sources in quadrant 1 and 3\n');
%             elseif (I1 == 4 && I2 == 2)
%                 fprintf('There are two sources in quadrant 2 and 4\n');
            else
                if (I1 == 1 && I2 == 2) && (max1 == max2)
                   % fprintf('It is located N from the center\n');
                   
                elseif I1 == 1 && I2 == 2
                   % fprintf('It is located NNE from the center\n');
                   location = 2;
                end
                if (I1 == 1 && I2 == 4) && (max1 == max2)
                   % fprintf('It is located E from the center\n');
                  
                elseif I1 == 1 && I2 == 4
                   % fprintf('It is located ENE from the center\n');
                   location = 1;
                end
                if (I1 == 2 && I2 == 1) && (max1 == max2)
                   % fprintf('It is located N from the center\n');
                   
                elseif I1 == 2 && I2 == 1
                   % fprintf('It is located NNW from the center\n');
                   location = 3;
                end
                if (I1 == 2 && I2 == 3) && (max1 == max2)
                   % fprintf('It is located W from the center\n');
                   
                elseif I1 == 2 && I2 == 3
                  %  fprintf('It is located WNW from the center\n');
                  location = 4;
                end
                if (I1 == 3 && I2 == 2) && (max1 == max2)
                  %  fprintf('It is located W from the center\n');
                  
                elseif I1 == 3 && I2 == 2
                  %  fprintf('It is located WSW from the center\n');
                  location = 5;
                end
                if (I1 == 3 && I2 == 4) && (max1 == max2)
                   % fprintf('It is located S from the center\n');
                   
                elseif I1 == 3 && I2 == 4
                   % fprintf('It is located SSW from the center\n');
                   location = 6;
                end
                if (I1 == 4 && I2 == 3) && (max1 == max2)
                   % fprintf('It is located S from the center\n');
                   
                elseif I1 == 4 && I2 == 3
                   % fprintf('It is located SSE from the center\n');
                   location = 7;
                end
                if (I1 == 4 && I2 == 1) && (max1 == max2)
                   % fprintf('It is located E from the center\n');
                   
                elseif I1 == 4 && I2 == 1
                   % fprintf('It is located ESE from the center\n');
                   location = 8;
                end
                
            end
            
            % need to test the history code
            % the history will wrap around
            if(L.curInd == length(L.locHistory))
                L.curInd = 1;
            end
            L.locHistory(L.curInd,:) = [toc(L.loc_timer) location];
            L.curInd = L.curInd+1;
            
            
            %fprintf('It is located %s from the center\n',string);
            %string = ['Q' num2str(I1)];
            %fprintf('Max = %f\nIndice: %i\n',max1,I1);
        end
        
        function [] = display2(L,locations,amplitudes,background,C,...
                NNE,ENE,ESE,SSE,SSW,WSW,WNW,NNW,nodrone)
            %This function outputs the location of the drone relative to
            %the display, relative to the system. If no drone is detected,
            %this is output to the display. It uses the average-filtered
            %input locations to emulate a phosphor display.
            %locations: average-filtered input locations vector
            %amplitudes: vector of current amplitude detected on mics
            %background, C, NNe, ENE, ESE, SSE, SSW, SSW, WSW, WNW, NNW,
            %nodrone are image configuration files from image_config.mat
            %Note that current amplitudes are not currently output to the
            %display.
            zonecount=zeros(1,10);%stores number of detection in each zone
            len=length(locations);
            for i=1:len%determine number of detections in each zone
                n=locations(i);
                switch n
                    case 0 %no drone
                        zonecount(9)=zonecount(9)+1;
                    case 1 %ENE
                        zonecount(1)=zonecount(1)+1;
                    case 2 %NNE
                        zonecount(2)=zonecount(2)+1;
                    case 3 %NNW
                        zonecount(3)=zonecount(3)+1;
                    case 4 %WNW
                        zonecount(4)=zonecount(4)+1;
                    case 5 %WSW
                        zonecount(5)=zonecount(5)+1;
                    case 6 %SSW
                        zonecount(6)=zonecount(6)+1;
                    case 7 %SSE
                        zonecount(7)=zonecount(7)+1;
                    case 8 %ESE
                        zonecount(8)=zonecount(8)+1;
                    case 9 %center
                        zonecount(10)=zonecount(10)+1;
                end
            end
            
            if zonecount(9) == len%if no drone is detected
                im=nodrone;%output no drone detected image
%                 textpos=[87 130]; boxcolor={'white'};
%                 text={'NO DRONE DETECTED'}; textcolor={'red'};
%                 im=insertText(background,textpos,text,'FontSize',30,'BoxColor',...
%                     boxcolor,'BoxOpacity',0,'TextColor',textcolor);
%                 textpos=[327 180; 185 180; 185 322; 327 322];
%                 text={num2str(amplitudes(1)),num2str(amplitudes(2)),...
%                     num2str(amplitudes(3)),num2str(amplitudes(4))};
%                 boxcolor={'white','white','white','white'};
%                 im=insertText(im,textpos,text,'FontSize',12,'BoxColor',...
%                     boxcolor,'BoxOpacity',0);
            else %if a droen is detected
                im=(zonecount(1).*ENE+zonecount(2).*NNE + ...
                    zonecount(3).*NNW + zonecount(4).*WNW + zonecount(5).*WSW + ...
                    zonecount(6).*SSW + zonecount(7).*SSE + zonecount(8).*ESE + ...
                    zonecount(10).*C)./len;%create phosphor display image
                im=imsubtract(background,im);
%                 textpos=[327 180; 185 180; 185 322; 327 322];
%                 text={num2str(amplitudes(1)),num2str(amplitudes(2)),...
%                     num2str(amplitudes(3)),num2str(amplitudes(4))};
%                 boxcolor={'white','white','white','white'};
%                 im=insertText(im,textpos,text,'FontSize',12,'BoxColor',...
%                     boxcolor,'BoxOpacity',0);
            end
            set(L.hIm,'CData',im);%store image for display
            %imshow(im);
        end
        
        function [zone_val] = averager(L,sublocations)
            %This function uses averages the current drone location and a
            %few previous locations to create a jitter free display.
            %sublocations: vector of locations containing desired number
            %locations to average
            len=length(sublocations);%number of points being averaged
            angles=[];%contains the angles of the zone where the drone is detected.
                      %does not include center zone and no drone deteced.
            C_count=0;%number of detections over the center of the system
            for i=1:len
                temp=sublocations(i);
                if  temp == 9%if the drone is in the center zone
                    C_count=C_count+1;%increment
                elseif temp ~= 0 %otherwise if a drone is a detected
                    angles(end+1)=temp; %insert into angles vector
                end
            end
            
            len=length(angles);
            if (C_count == 0) && (len == 0)%if no drone is detected 
                zone_val = 0;
                return;
            elseif C_count >= len%if the drone is in or near the center of the system 
                zone_val = 9;
                return;
            end
            
            theta_offset=-22.5;%offset in degrees (for center of each zone
            angles=angles.*45+theta_offset;%convert angles to degrees
            
            avg_angle = L.meanangle(angles);%average the angles. dim=2
            if avg_angle < 0 %convert negative angle to positive
                avg_angle = avg_angle+360;
            end
            zone_val=(avg_angle-theta_offset)./45;%convert angle to zone
            zone_val=round(zone_val);%round to integer
            % if zone_val == 0
            %     zone_val=8;
            % end
            
        end
        
        function [out] = meanangle(L,in,dim,sens)            
            % MEANANGLE will calculate the mean of a set of angles (in degrees) based
            % on polar considerations.
            %
            % Usage: [out] = meanangle(in,dim)
            %
            % in is a vector or matrix of angles (in degrees)
            % out is the mean of these angles along the dimension dim
            %
            % If dim is not specified, the first non-singleton dimension is used.
            %
            % A sensitivity factor is used to determine oppositeness, and is how close
            % the mean of the complex representations of the angles can be to zero
            % before being called zero.  For nearly all cases, this parameter is fine
            % at its default (1e-12), but it can be readjusted as a third parameter if
            % necessary:
            %
            % [out] = meanangle(in,dim,sensitivity)
            %
            % Written by J.A. Dunne, 10-20-05
            %
            
            if nargin<3
                sens = 1e-12;
                dim = 2;
            end
            
            if nargin<2
                ind = find(size(in)>1,1);
                if isempty(ind)
                    %This is a scalar
                    out = in;
                    return
                end
                dim = ind;
            end
            
            in = in * pi/180;
            
            in = exp(1i*in);
            mid = mean(in,dim);
            out = atan2(imag(mid),real(mid))*180/pi;
            out(abs(mid)<sens) = nan;
        end
        
        function configImViewer(L,hImage)
            L.hIm = hImage;
        end
        
        function historyToWorkspace(L)
            assignin('base', 'localization_history', L.locHistory);
            assignin('base', 'localization_history_lastIndex', L.curInd);
        end
    end   
end

