clc;
close all;
clear all;

in_message_string = 'potato';
in_message_binary = reshape((dec2bin(in_message_string) - 48).',[],1);

qpskmod = comm.QPSKModulator('BitInput',true);
modData = qpskmod(in_message_binary);   
chan = comm.RayleighChannel(...
     'SampleRate',          1e3,...
     'NormalizePathGains',  true,...
     'MaximumDopplerShift', 10,...
     'RandomStream',        'mt19937ar with seed',...
     'Seed',                73,...
     'PathGainsOutputPort', true,...
     'FadingTechnique',     'Sum of sinusoids',...
     'InitialTimeSource',   'Property');
   
 % Filter an input signal through a channel. The fading process starts
 % at InitialTime = 0.
 [~,pathGains1] = chan(modData);
     
 % The input signal is converted into frames and each frame is
 % independently filtered through the same channel. The frames are
 % transmitted consecutively. The transmission time of successive
 % frames is controlled by the initialTime.
 
 release(chan);
 frameSpacing = 100;        % The spacing between frames in samples                    
 frameSize = 10;            % Frame size in samples
 pathGains2 = zeros(length(pathGains1),1);
 chan.InitialTimeSource = 'Input port';
    
 for i=1:(length(modData)/frameSpacing)
    inIdx = frameSpacing*(i-1) + (1:frameSize);
    initialTime = (inIdx(1)-1) * (1/chan.SampleRate);
    [~, pathGains2(inIdx,:)] = chan(modData(inIdx,:), initialTime);  
 end
 
 % Plot fading samples
 plot(abs(pathGains1),'o-b'); hold on;
 plot(abs(pathGains2),'*-r');  grid on; axis square;
 legend('InitialTimeSource : Property', 'InitialTimeSource : Input port');
 xlabel('Time (s)'); ylabel('|Output|');

 
 
 