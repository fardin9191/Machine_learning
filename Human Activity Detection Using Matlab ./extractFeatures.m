function feature = extractFeatures (a, t, uniformSampleRate)

format longg
%% obtain magnitude data
y = a(:,2);
z = a(:,3);

% We don't use acceleration of x-axis (left and right), it detects if we
% make turns while we are moving.
mag = sqrt(y.^2+z.^2);

%% features in time domain
%compute mean
average = mean(mag);

%compute percentiles
p25 = prctile(mag, 25);
p75 = prctile(mag, 75);

%compute squared sum of data below certain percentile (25, 75)
sumsq25 = sum(mag(mag < p25) .^ 2);
sumsq75 = sum(mag(mag < p75) .^ 2);


%% feature in Freq domain
% Y-Axis data only
y = y - mean(y);

% apply fast fourier transformation to the signal
% Next power of 2 from length of averaged rms acceleration
NFFT = 2 ^ nextpow2(length(y)); 
freqAccel = fft(y, NFFT) / length(y);
f = uniformSampleRate / 2 * linspace(0, 1, NFFT / 2 + 1);

% amplitude of spectrum
amplitudeSpectrum = 2 * abs(freqAccel(1:NFFT / 2 + 1)); 

% Freq. feature 1, single sideed bandwidth is uniformSampleRate / 2, we are
% interested in 5Hz out of uniformSampleRate / 2.
sum5Hz = sum(amplitudeSpectrum(1:ceil(NFFT*5/(uniformSampleRate/2))));
[maxVal, maxIndx] = max(amplitudeSpectrum); % Find peak
maxFreq = f(maxIndx); %Freq. feature 2

% We are interested in single sided 0-5Hz data.
dataLength = ceil(length(f) * (5 / (uniformSampleRate / 2)));
dataOfInterest = amplitudeSpectrum(1:dataLength);
minDistance = ceil(length(f)/uniformSampleRate);
warning Off; % Idling might not have peaks, turn off warning.
[vals, loc] = findpeaks(2*abs(dataOfInterest), 'MINPEAKHEIGHT', 1,...
                    'MINPEAKDISTANCE', minDistance, 'SORTSTR', 'descend');
warning On;

numPeaks = length(vals); % Freq. feature 3, number of peaks


%%
feature = [average, sumsq25, sumsq75, maxFreq, sum5Hz, numPeaks];