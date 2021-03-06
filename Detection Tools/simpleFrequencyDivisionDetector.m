% this will:
% take FFT
% divide into sections
% extract features from each section
% make decisions based on those features

% I'VE NOTICED:
% Low freqs have distinct "peaks"
% High freqs have more broadband "bumps"

% CONSTANTS
FRAME_SIZE = 1024;
NUM_CHANNELS = 2;
NUM_SPECTRUM_SLICES = 20;
SAMPLE_RATE_HZ = 44100;
NUM_FRAMES_HELD = 4;
WINDOW_SIZE = NUM_FRAMES_HELD*FRAME_SIZE;
% for drones
% COREL_KERNAL = [-55 -44 -34 -33 -34 -44 -55];

har = dsp.AudioRecorder('NumChannels',NUM_CHANNELS,...
    'SamplesPerFrame',FRAME_SIZE,'SampleRate',SAMPLE_RATE_HZ);
har.ChannelMappingSource = 'Property';
% har.DeviceName = 'ASIO4ALL v2';
hmfw = dsp.AudioFileWriter('myspeech.wav','FileFormat','WAV');
disp('Speak into microphone now');

tic;
loopCounter = 0;
timeseriesBuffer = zeros(WINDOW_SIZE,NUM_CHANNELS);
% lastSpectrum will be used to see if corellation is useful
% spectraBuffer = zeros(FRAME_SIZE,NUM_CHANNELS);
lastSpectrum = zeros(WINDOW_SIZE/2,NUM_CHANNELS);
[r,c] = size(timeseriesBuffer);
% set chanNumber to 1 for now so that only channel one is active; this will
% change when we need to collect data on several channels
chanNumber = 1;
while toc < 10
    singleAudioFrame = step(har);
    curFrame = singleAudioFrame(:,chanNumber);
    % load the current frame into timeseriesBuffer and push the last frame
    % out (each column holds NUM_FRAMES_HELD frames)
    timeseriesBuffer(:,chanNumber) = [curFrame; ...
        timeseriesBuffer(1:((NUM_FRAMES_HELD-1)*FRAME_SIZE),chanNumber)];
    % hit with a hamming window
    windowedData = timeseriesBuffer(:,chanNumber).*hamming(WINDOW_SIZE);
    % might want to play around with how fft is taken
    windowedDataF = 10*log10(abs(fft(windowedData.^2)));
    % make the spectrum one-sided
    windowedDataF = windowedDataF(1:WINDOW_SIZE/2);
    
    % lo_snippet = windowedDataF(1:floor(WINDOW_SIZE/2*0.2),chanNumber);
    
    xcorrelation = filter2(1/20*ones(20,1),windowedDataF);
    xcorrelation2 = filter2([-0.5; 0.0; 0.5], xcorrelation);
    
    lastSpectrum(:,chanNumber) = windowedDataF;
    
    % LIVE PLOTS
    % for better figure handling techniques see:
    % http://stackoverflow.com/questions/6681063/programming-in-matlab-how-to-process-in-real-time
    if(mod(loopCounter,2)==0)
%         subplot(4,1,1)
%         plot(timeseriesBuffer(:,chanNumber))
%         axis([0 WINDOW_SIZE -1 1])
%         subplot(4,1,2)
%         plot(windowedDataF)
%         axis([1 WINDOW_SIZE/2 -60 0])
%         subplot(4,1,3)
%         plot(xcorrelation)
%         axis([1 WINDOW_SIZE/2 -60 0])
%         subplot(4,1,4)
%         plot(xcorrelation2)
%         % axis([1 WINDOW_SIZE/2  0])
%         drawnow;
        spectrogram(timeseriesBuffer(:,chanNumber));
        axis([0 0.2 0 550])
        drawnow;
    end
%     for chanNum = 1:NUM_CHANNELS
%         window = singleAudioFrame(:,chanNum);
%         % slices = segment(abs(fft(window)), NUM_SPECTRUM_SLICES);
%         % var and mean calculated along the columns
%         % var(slices);
%         % mean(slices);
%     end
    loopCounter = loopCounter+1;
end

release(har);
release(hmfw);
disp('Recording complete');