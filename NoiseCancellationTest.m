[y,fs] = audioread('Iris+ Hover Max Gain.wav');
[y1,f1] = audioread('12-7 Cook Field Noise Max Gain.wav');
sampleLength = 44100;
cutoffFrequency = 1000;
yNoise1 = y1(1:sampleLength);
yNoise2 = y1(sampleLength+1:2*sampleLength);
ySignal = y(1:sampleLength);
data = [yNoise1 yNoise2 ySignal];
mf_n = 2;
ss = 0.2;
%in_fismat=genfis1(data, mf_n);
%out_fismat = anfis(data, in_fismat, [nan nan ss]);
%estimatedNoise = evalfis(data(:,1:2),out_fismat);
%estimatedSignal = ySignal - estimatedNoise;
a = 1;
b = [0.5 0.5];
Wn = (cutoffFrequency/(44100/2));
[bButterworth, aButterworth] = butter(3,Wn,'high');
highPassSignal = filter(bButterworth,aButterworth,ySignal);
estimatedSignal1 = filter(b,a,ySignal);
estimatedSignal2 = filter(b,a,highPassSignal);
T = 1/fs;
t = linspace(1,length(ySignal)/44100,length(ySignal));
L = length(ySignal);
f = fs*((-L/2):(L/2)-1)/L;
figure();
signalTransform = abs(fftshift(fft(ySignal(:,1))));
subplot(2,2,1);
plot(f/1000,signalTransform);
%plot((ySignal(:,1)));
%plot(ySignal);
xlabel('Frequency (kHz)');
ylim([0 60]);
xlim([0 22]);
title('Original Signal');
subplot(2,2,2);
noiseTransform = abs(fftshift(fft(yNoise1(:,1))));
plot(f/1000,(abs(fftshift(fft(highPassSignal(:,1))))));
%plot(yNoise);
title('Signal After Highpass Filter');
xlabel('Frequency (kHz)');
ylim([0 60]);
xlim([0 22]);
subplot(2,2,3);
plot(f/1000,(abs(fftshift(fft(estimatedSignal1(:,1))))));
%plot(yNoise);
title('Signal After Moving Average Filter');
xlabel('Frequency (kHz)');
ylim([0 60]);
xlim([0 22]);
subplot(2,2,4);
plot(f/1000,(abs(fftshift(fft(estimatedSignal2(:,1))))));
%plot(yNoise);
title('Signal After Highpass and Moving Average Filters');
xlabel('Frequency (kHz)');
ylim([0 60]);
xlim([0 22]);
%figure();
%plot((estimatedSignal(:,1)));
%plot(estimatedSignal);
%xlim([0 22]);