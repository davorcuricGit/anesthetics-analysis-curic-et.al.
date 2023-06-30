

function  [labeledFrame avCount Av] = updateLabels(Av, labeledFrame, currentTime, currentClusters, prevActive, network, avCount )

t = currentTime;


for i = 1:length(currentClusters)
    
    c = [currentClusters{i}];
        %
    

    %first get the active parents
    parentcluster = getActiveParentCluster(c,  prevActive, network);

    
    
    %these are the avalanche labels of the parents.
    %parentLabels = sort(unique(labeledFrame(parentcluster,t-1)));
    parentLabels = unique(labeledFrame(parentcluster,t-1));
    
    if prod(parentLabels) == 0
        stop
    end
    
    if isempty(parentcluster)
        %no parents, this is the start of a new avalanche
            

%     
             labeledFrame(c,t) = avCount;
             Av{avCount} = startAvalanche(avCount, c, t);
             avCount = avCount + 1;
        %now we need to know if the parents came from one avalanche or more
    elseif length(parentLabels) == 1
        %only one parent
        %apply the parents label to the current cluster
        labeledFrame(c,t) = parentLabels;
        
        Av{parentLabels} = updateAvalanche(Av{parentLabels}, t, length(c));
        
        
    elseif length(parentLabels) > 1
        %more than one parent
        %the avalanche with the smallest label will provide the new labels
        %a minus sign will indicate merging
        newLabel = floor(parentLabels(1));
        
        %Av{newLabel} = updateAvalanche(Av{newLabel}, t, c);
        Av{newLabel} = updateAvalanche(Av{newLabel}, t, length(c));
        Av{newLabel}.merged = true;
        %go back and relabel all the parents
        for parlab = 2:length(parentLabels)
            
           
            
            count = 1;
            
            pastframe = labeledFrame(:,t-count);
            idx = find(pastframe == parentLabels(parlab));
            Av{newLabel} = updateAvalanche(Av{newLabel}, t-count, length(idx));
            
            clear Z
           
            %go backwards and label
            while ~isempty(idx)
                labeledFrame(idx,t-count) = newLabel;
                
                count = count + 1;
                if t - count <= 0; break; end
                pastframe = labeledFrame(:,t-count);
                idx = find(pastframe == parentLabels(parlab));
                Av{newLabel} = updateAvalanche(Av{newLabel}, t-count, length(idx));
            end
            
           %now check the current frame for any missed children nodes 
           pastframe = labeledFrame(:,t);
           idx = find(pastframe == parentLabels(parlab));
           labeledFrame(idx,t) = newLabel; 
           Av{newLabel} = updateAvalanche(Av{newLabel}, t, length(idx));
           
           %The roots of the parent avalanches need to be joined
           Av{newLabel}.roots = [Av{newLabel}.roots Av{parentLabels(parlab)}.roots];
           
           AvLabel{parentLabels(parlab)} = [];
           
        end
        
        %finally apply the label to the current cluster
        labeledFrame(c,t) = newLabel;
    else
        %this is just debugging
        'something unexpected happened but idk what'
        stop
    end
end
end
