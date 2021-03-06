clear
clc
% The main file for logistic regression detection. This starts up a new
% drone system and then runs it.
disp('Initializing system for use with 4 mic ASIO audio input')
load('configSettings_4ChannelScarlett.mat')
load('kNNConfig.mat')
b = NewDroneSystem4Channel(configSettings,kNNStuff);
if(~b.shutdown)
    b.start();
else
    disp('Shutting down');
end