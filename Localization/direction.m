function [] = direction(A1,A2,A3,A4)
%Input 4 amplitudes (representing the peak magnitude recieved at each mic)
%  Output: Text describing the direction of the source
A = [A1 A2 A3 A4]
[max1, I1] = max(A)
A(I1) = [-50];
[max2, I2] = max(A)
A(I2) = [-50];
[max3, I3] = max(A);
A(I3) = [-50];
[max4, I4] = max(A);
A(I4) = [];
if (I1 == 1 && I2 == 2) && (max1 == max2);
    fprintf('It is located N from the center\n');
elseif I1 == 1 && I2 == 2;
    fprintf('It is located NE from the center\n');
end
if (I1 == 1 && I2 == 4) && (max1 == max2);
    fprintf('It is located E from the center\n');
elseif I1 == 1 && I2 == 4;
    fprintf('It is located NE from the center\n');
end
if (I1 == 2 && I2 == 1) && (max1 == max2);
    fprintf('It is located N from the center\n');
elseif I1 == 2 && I2 == 1;
    fprintf('It is located NW from the center\n');
end
if (I1 == 2 && I2 == 3) && (max1 == max2);
    fprintf('It is located W from the center\n');
elseif I1 == 2 && I2 == 3;
    fprintf('It is located NW from the center\n');
end
if (I1 == 3 && I2 == 2) && (max1 == max2);
    fprintf('It is located W from the center\n');
elseif I1 == 3 && I2 == 2;
    fprintf('It is located SW from the center\n');
end
if (I1 == 3 && I2 == 4) && (max1 == max2);
    fprintf('It is located S from the center\n');
elseif I1 == 3 && I2 == 4;
    fprintf('It is located SW from the center\n');
end
if (I1 == 4 && I2 == 3) && (max1 == max2);
    fprintf('It is located S from the center\n');
elseif I1 == 4 && I2 == 3;
    fprintf('It is located SE from the center\n');
end
if (I1 == 4 && I2 == 1) && (max1 == max2);
    fprintf('It is located E from the center\n');
elseif I1 == 4 && I2 == 1;
    fprintf('It is located SE from the center\n');
end
if (I1 == 1 && I2 == 3) || (I1 == 2 && I2 == 4) || (I1 == 3 && I2 == 1) || (I1 == 4 && I2 == 2);
    fprintf('It is located Directly above or there are two sources in the area\n');
end

%fprintf('It is located %s from the center\n',string);
%string = ['Q' num2str(I1)];
%fprintf('Max = %f\nIndice: %i\n',max1,I1);
end

