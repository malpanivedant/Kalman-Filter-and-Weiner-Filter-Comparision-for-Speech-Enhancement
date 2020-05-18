close all;

% [file,path] = uigetfile('Laughter-16-8-mono-4secs.wav','Pick an Audio Wave File'); 
% handles.filename=file;
% % Open standard dialog box for retrieving files
% % To browse the file from the coding folder 
% if isequal(file,0) || isequal(path,0)      
%     % If you not selecting file or click the cancel button 
%     warndlg('You should Have to Select a File First'); 
%     % Open warning dialog box with message "You should Have to Select an file First"
%     % Means it display the dialog box
% else
%     % Else
   [y,fs]=audioread('Laughter-16-8-mono-4secs.wav');        
    % Read the wave file using waveread; function and store in 'y' 
  
  [actual, Fs] = audioread('Laughter-16-8-mono-4secs.wav');   
% end

x=actual;
fs=Fs;

%% Initialization
    
    IS = 0.2;   
    % window length
    window_length = 0.01;                    
    wnd_length = fix(window_length*fs);
    % hamming window calculations
    wnd = hamming(wnd_length);
    inc = fix(wnd_length / 2); 
    [f,t] = cut_frame(x,wnd,inc);          
    silentFrameNo=fix((IS*fs-wnd_length)/(0.5*wnd_length) +1);         
    f=f';
    Y = fft(f);
    [m,n] = size(Y);
    YPhase = angle(Y((1:(fix(m/2)+1)),:));
    YY = abs(Y(1:(fix(m/2)+1),:));
    noise_est = mean(YY(:,1:silentFrameNo)'.^2)';
    X=zeros(size(YY));
    % transferring command to wiener filter
    X = wienerfilter(YY,silentFrameNo,noise_est);      

    XX = X.*exp(1i*YPhase);
    if mod(size(f,1),2)
        XX=[XX;flipud(conj(XX(2:end,:)))];
    else
        XX=[XX;flipud(conj(XX(2:end-1,:)))];
    end
        s_out = real(ifft(XX));
        Output = add_overlap(s_out',wnd,inc);
        y = Output;
a = 0;
for i=1:length(y)
    er(i) = x(i) - y(i);
    a = a + er(i);
end
a = a.*a;
MSE_weiner = a./(length(er))
    
figure(1);
subplot(2,1,1);
plot(x)
title('Input Signal');
subplot(2,1,2);
plot(y)
title('Output Signal');
figure(2);
plot(er);
title('Error');

