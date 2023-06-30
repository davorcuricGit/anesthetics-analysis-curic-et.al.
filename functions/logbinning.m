
function [md, fq] = logbinning(X,a, type)

%logarithmic binning
%From "Complexity and Criticality" -- Christensen and Moloney, 2005
%X is the data to be binned
%a > 1 is the binning factor - bins are made from [a^i a^(i+1)].
%type = disc for discrete avalanches, cont for continous. %note discrete
%avalanches need to be converted to be integer valued first. 

if strcmp(type, 'disc')
md = [];
fq = [];
    
    smin = min(X);
    smax = max(X);
    
    N = length(X);
    
    j = 0;
    
    while a^j < smax%length(X) > 10%~isempty(X);
      
        idx = find(X >= a^j & X < a^(j+1));
        
        if isempty(idx); 
           
            j = j + 1;
            continue; 
        end
        
        ssmin = min(X(idx));
        ssmax = max(X(idx));
        
        D = ssmax - ssmin  + 1;
        fq = [fq length(idx)/(D*N)];
        md = [md sqrt(ssmin*ssmax)];
        j = j + 1;
        
    end

elseif strcmp(type, 'cont')
    md = [];
    fq = [];
    
    smin = min(X);
    smax = max(X);
    
    N = length(X);
    
    j = 0;
    
    while a^j*smin < smax%length(X) > 10%~isempty(X);
      
        idx = find(X >= a^j*smin & X < a^(j+1)*smin);
        
        if isempty(idx); 
           
            j = j + 1;
            continue; 
        end
        
        ssmin = min(X(idx));
        ssmax = max(X(idx));
        
        D = a^(j+1)*smin - a^j*smin; 
        fq = [fq length(idx)/(D*N)];
        md = [md sqrt(ssmin*ssmax)];
        j = j + 1;
        
    end
end



end