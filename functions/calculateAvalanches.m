
function [S,D, roots, rootTimes] = calculateAvalanches(raster, network, adjmat, t0)
%calculates avalanches according to a provided network
%the algorithm is similar to hoshen-koppelman. For a active unit i at time t
%there are three possible outcomes
%1 - no neighbour of i is active at time t-1 so i is the start of a new
%avalanche and is given an available index as a label
%2 - if all the neighbours of i active at time t-1 share the same label
%then i is a continuation of an existing avalanche and inhereits the
%existing label
%3 - if the neighbours of i active at time t-1 do not all share the same
%label, then i is a merging of the multiple avalanches. Each avalanche is
%merged and relabeled to have the smallest index amongst those labels. The
%other labels are discarded and become available for a new avalanche. This
%also flags an avalanche as a multiroot avalanche (single-root otherwise). 


%input:
       %raster - 2D array, Npixels x Ntime points
       %network -Cell Npixel x 1 - ith cell contains the adjacency list of the
       %        ith pixel
       %adjmat - 2D array Npixels x Npixels - the same as network but in adjacency matrix form.
       %t0 - starting frame of the raster, useful if running code over
       %    multiple segments to keep track of time.

%output:
        %S - list of avalanche sizes
        %D - list of avalanche durations
        %roots - cell - for each avalanche the set of pixels that initiated
            %the evalanche
        %rootTimes - cell - the time at whcih each root happened. Useful
        %for avalanche initiation maps




Ncells = size(raster, 1);
Tmax = size(raster, 2);

labeledFrame = single(zeros(Ncells, Tmax));

%first label all the avalanches in frame 1
t = 1;
active{1} = [];
active{1} = find(raster(:,t) == 1);
avCount = 1;

%activeAdjmat is the sub-graph of the currently active pixels
activeAdjmat = getActiveAdj([active{1}], adjmat, Ncells);


cluster{t} = getCurrentClusters(active{1}, activeAdjmat, true);
labeledFrame(:,t) = single(labelSingleFrame(cluster{t}, Ncells));
for i = 1:length(cluster{t})
    %in the first frame no event has a pre-cursor event so they
    %automatically start a new avalanche. 
    Av{i} = startAvalanche(i, cluster{t}{i}, t);
end


for t = 2:Tmax;
    
    %just a printing statement for feedback
    if mod(t, 500) == 0;
        [t t/Tmax]
    end
    
    active{2} = find(raster(:,t) == 1);
    
    
    if isempty([active{2}]);
        %if the current frame has no active events
        continue
    end
    
    activeAdjmat = getActiveAdj([active{2}], adjmat, Ncells);
    cluster{t} = (getCurrentClusters(active{2}, activeAdjmat, true));
    
    
    %go through an update the existing labels (e.g., merge, avalanche
    %continuations)
    testlabel = ceil(max(labeledFrame(:,t-1),[], 'all')+1);
    avCount = max(avCount, testlabel);
    [labeledFrame avCount Av] = updateLabels(Av, labeledFrame, t, cluster{t}, active{1}, network, avCount);
    
    
    active{1} = active{2};
end

% bring all the labels together to get the avalanche sizes and durations
labeledAvalanches = labeledFrame;
labeledFrame(labeledFrame == 0) = [];
if ~isrow(labeledFrame); labeledFrame = labeledFrame'; end
[S,GR] = groupcounts(labeledFrame');
idx = 1:length(Av);
setdiff(idx, GR)
Av(setdiff(idx, GR)) = [];

for i = 1:length(Av);
    D(i) = Av{i}.duration;
    merged(i) = Av{i}.merged;

    %these are the initiating events of each avalanche
    roots{i} = Av{i}.roots;
    rootTimes{i} = Av{i}.rootTime + t0-1;
end


end

