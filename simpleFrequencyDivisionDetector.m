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

har = dsp.AudioRecorder('NumChannels',NUM_CHANNELS,...
    'SamplesPerFrame',FRAME_SIZE,'SampleRate',SAMPLE_RATE_HZ);
har.ChannelMappingSource = 'Property';
har.DeviceName = 'ASIO4ALL v2';
hmfw = dsp.AudioFileWriter('myspeech.wav','FileFormat','WAV');
disp('Speak into microphone now');

tic;
loopCounter = 0;
timeseriesBuffer = zeros(WINDOW_SIZE,NUM_CHANNELS);
[r,c] = size(timeseriesBuffer);
chanNumber = 1;
while toc < 5
    singleAudioFrame = step(har);
    curFrame = singleAudioFrame(:,chanNumber);
    % push new data into the buffer
    timeseriesBuffer(:,chanNumber) = [curFrame; ...
        timeseriesBuffer(1:((NUM_FRAMES_HELD-1)*FRAME_SIZE),chanNumber)];
    % hit with a hamming window
    windowedData = timeseriesBuffer(:,chanNumber).*hamming(WINDOW_SIZE);
    % might want to play around with how fft is taken
    windowedDataF = 10*log10(abs(fft(windowedData.^2)));
    windowedDataF = windowedDataF(1:WINDOW_SIZE/2);
    % live plots
    % see: http://stackoverflow.com/questions/6681063/programming-in-matlab-how-to-process-in-real-time
    % for better figure handling techniques
    if(mod(loopCounter,2)==0)
        subplot(2,1,1)
        plot(timeseriesBuffer(:,chanNumber))
        axis([0 WINDOW_SIZE -1 1])
        subplot(2,1,2)
        plot(windowedDataF)
        axis([1 WINDOW_SIZE/2 -60 0])
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

% need to write a quick 
