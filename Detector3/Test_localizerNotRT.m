% create a DroneSystem object
load('Detector3\configSettings.mat')
system1 = DroneSystem(configSettings);

% define file names
channel1 = 'from1to2_01.wav';
channel2 = 'from1to2_01.wav';
% ... read in the rest

% bring in the audio data
[audio_01, Fs] = audioread(channel1);


% segment
audioFrameMatrix01 = frameSegment(audio_01,configSettings.constants.FRAME_SIZE);
% three more ...


system1.localizerTest(A1,A2,A3,A4);

% take the ave power for each channel and pass those to the localizerTest()
% function

