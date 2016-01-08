%% fingerprint feature extraction
% The purpose of this file is to justify using an audio fingerprinting
% method for detecting drones.

% In theory, the fingerprinting system here will take an audio signal as
% the input, and output amplitude and frequency information regarding
% slowly varying peaks in frequency. If this testing shows that the
% fingerprint of drones is consistantly distinct from the fingerprint of
% similar sounding noise sources (e.g. a fan), then the we should continue
% down this path.  Otherwise, a new method of information extraction should
% be devised.

% Test this file with several noise sources.  A few potential options:
% lawnmower, fan, music, cars. Highly non-stationary signals (such as
% speech) can wait until later.
%% INITIAL
clear;

%% CONSTANTS
NUM_CHANNELS = 2;
FRAME_SIZE = 1024;
WINDOW_SIZE = 4096;
SLICE_NUMBER = 2;
SAMPLE_FREQUENCY_HZ = 44100;
SPECTROGRAM_OVERLAP = WINDOW_SIZE/2;
BACKGROUND_CALIBRATION_TIME = 3;
F_AXIS = linspace(0,SAMPLE_FREQUENCY_HZ/2,WINDOW_SIZE/2+1);
MEAN_REMOVAL_LENGTH = 7;

%% BACKGROUND STUFF
% aveSpec = backgroundSpectrum(BACKGROUND_CALIBRATION_TIME, ...
%     SAMPLE_FREQUENCY_HZ, WINDOW_SIZE, SPECTROGRAM_OVERLAP);

%% RECORD AUDIO
har = dsp.AudioRecorder('NumChannels',NUM_CHANNELS,'SamplesPerFrame',FRAME_SIZE);
hmfw = dsp.AudioFileWriter('fingerprintAudio.wav','FileFormat','WAV');
disp('Speak into microphone now');
tic;
while toc < 2
    singleFrame = step(har);
    step(hmfw, step(har));
end

%% GENERATE SPECTROGRAM
[x, Fs] = audioread('fingerprintAudio.wav');
S = spectrogram(x(:,1),WINDOW_SIZE);
% subplot(3,1,1)
% surf(10.*log10(abs(S)),'EdgeColor','none');
view(0,90)
set(gca,'YScale','log');

%% SMOOTH SPECTRUM
S_smooth = smoothSpectrogram(S);
% subplot(3,1,2)
% surf(10.*log10(abs(S)),'EdgeColor','none');
view(0,90)
set(gca,'YScale','log');
% TODO : Add a constructor to paramatrize the smoothing lengths in this function

%% EXTRACT SIGNLE SPECTRUM
spectrum = S_smooth(:,SLICE_NUMBER);
subplot(3,1,1)
plot(F_AXIS,spectrum)
set(gca, 'XScale', 'log')

%% SPECTRUM CONDITIONING
%Frequency-wise smoothing currently being done in smoothSpectrogram, should
%change this for efficiency
% add mean removal filter here
conditionedSpectrum = meanRemovalFilter1(spectrum, MEAN_REMOVAL_LENGTH);
conditionedSpectrum(conditionedSpectrum<0) = 0;

%% SPECTRUM SEGMENTATION


%% EXTRACT PEAK INFO
% take a look at dsp.PeakFinder
[pks, locs] = findpeaks(conditionedSpectrum, 'MINPEAKHEIGHT', 0.5);
subplot(3,1,2)
plot(F_AXIS,conditionedSpectrum)
set(gca, 'XScale', 'log'), hold on
plot(F_AXIS(locs),pks+0.05,'k^','markerfacecolor',[1 0 0]), hold off


%% NOTES
% I immediately notice that the spectrogram looks a loooot uglier than
% what's shown by a single spectrum