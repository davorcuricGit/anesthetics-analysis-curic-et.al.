%Sample code
%Davor Curic, 2023, Complexity Science Group, University of Calgary
%
%This calculates the hilbert transform/phasespace representation of the
%data

tic()
load("mask.mat")
corticalPixels = find(mask == 1); %these are the pixels corresponding to the cortical surface

%load the recording
load('SampleRecording_128x128_movementFramesRemoved.mat')
%

%reshape into raster form and take only pixels corresponding to cortical
%surface
ImgF2 = reshape(ImgF2, size(mask,1)*size(mask,2), []);
ImgF2 = ImgF2(corticalPixels, :);
globalSignal = sum(ImgF2); %calculate globalSignal before zscore to preserve zeros for segmentation step
ImgF2 = zscore(ImgF2,0,2);



%want to segment the recording according to exsessive movement periods
%(represented by zeros).
[~, segmentTimes] = segmentSeries(globalSignal);

%the good periods of the recording are all the even segments
goodSegments = {segmentTimes{2:2:end}};
clear segmentTimes
%
%take only the largest segement for the hilbert transform
L = cellfun(@length, goodSegments)
[~,L] = max(L);
seg = ImgF2(:,goodSegments{L}); clear L

%Hilbert transform the segments
H = hilbert(seg);
H = reshape(H, 1, []);

%plot the phase space histogram
edges = [-2.5:0.1:2.5];
histogram2(real(H),imag(H), edges, edges,'DisplayStyle','tile','ShowEmptyBins','on', 'Normalization', 'pdf', 'EdgeColor', 'none');
xlabel('Re(H[X(t)])')
ylabel('Im(H[X(t)])')

