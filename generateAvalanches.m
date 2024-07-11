%Sample code
%Davor Curic, 2023, Complexity Science Group, University of Calgary
%
%This code generates avalanches with respect to a network. In this case the
%network is generated from pixels within a specified radius.
%
%This code generates avalanches with respect to a network for a sample recording. In this case the
%network is generated from pixels within a specified radius.
%
%IMPORTANT: the sample recording was too large to fit into github
%repository and has been provided in a seperate Zenodo directory. 
% Avalanches (size and durations) for all recordings with a threshold of 1 have been saved
% seperately. Both can be found at the following: 10.5281/zenodo.12725849 (DOI)

%The avalanches obtained from the recording were stored as
%samplerecording_avalanches.mat and are used in the subsequent codes. The
%sample recording can be provided upon reasonable request. 



load("mask.mat")
corticalPixels = find(mask == 1); %these are the pixels corresponding to the cortical surface

%co-activated pixels within this radius will be clustered together
%This radius was calculated from the zero crossing of the partial
%correlation function
clustering_radius = 8;
FR = 50; %sampling rate


%generate the network corresponding to the clustering_radius
[ix,iy] = ind2sub([256 256], corticalPixels);
Z = single([ix,iy]);
adjmat = pdist2(Z,Z);
'gen network'
adjmat(adjmat > clustering_radius) = 0;
adjmat(adjmat ~= 0) = 1;
clear network Z ix iy
for i = 1:size(adjmat,1)
    network{i} = find(adjmat(i,:) == 1);
    network{i} = [network{i} i];
end
clear i

%load the recording
load('SampleRecording_128x128_movementFramesRemoved.mat')


%reshape into raster form and take only pixels corresponding to cortical
%surface
ImgF2 = reshape(ImgF2, size(mask,1)*size(mask,2), []);
ImgF2 = ImgF2(corticalPixels, :);
globalSignal = (sum(ImgF2)); %calculate globalSignal before zscore to preserve zeros for segmentation step
ImgF2 = zscore(ImgF2,0,2);




%want to segment the recording according to exsessive movement periods
%(represented by zeros).
[~, segmentTimes] = segmentSeries(globalSignal);

%the good periods of the recording are all the even segments
goodSegments = {segmentTimes{2:2:end}};
clear segmentTimes

thresh = 3; %in standard deviations

%go through each segment and calculate avalanches.
%in theory one could throw the entire recording as is without segmenting
%but it would run slower as it would need to backpropagate farther in time
%to merge avalanches
count = 1; %used for storing avalanches
clear avSize avTime roots rootTimes
for i = 1:length(goodSegments)
            seg = ImgF2(:,goodSegments{i});
         
            seg(seg < thresh) = 0;
            seg(seg~= 0) = 1; %binarization is optional, algorithm does not require it

             if sum(sum(seg)) == 0; continue; end %if the threshold has removed all events continue
             
             

            %thresholding may have introduced new periods of zeros, if we
            %further segment the recording our code will run even faster
            %get rid of any zero activity periods
            trace = (sum(seg));
            trace(1) = 0; trace(end) = 0;
            if sum(trace) == 0; continue; end
            [~, subsegTimes] = segmentSeries(trace);
            subsegTimes = {subsegTimes{2:2:end}};

            for j = 1:length(subsegTimes)
                [i/length(goodSegments) j/length(subsegTimes)]
                
                T0 = subsegTimes{j}(1); %initial time of the segment to keep track of time
                
                %depending on the threshold this code can take a while to
                %run. A couple of print statements are placed as a sanity
                %check to make sure the code is actually running. 
                [avSize{count} avTime{count}, roots{count}, rootTimes{count}] = calculateAvalanches(seg(:, subsegTimes{j}), network, adjmat, T0);
                count = count + 1;
            end
end    



avalanches = {avSize,avTime, roots, rootTimes};
save('samplerecording_avalanches.mat', 'avalanches')





