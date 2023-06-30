function volume = embeddIntoFOV(data, validPixels, FOVsize, varargin)
%takes 2D array of Npixels x Time (e.g., a raster) and embedds in a 3d
%array of X x Y x Time

%input - the 2D array Npixels x Time
%        - validPixels Npixels x 1 - list of pixels that correspond to the
%        cortical area in XY space
%       -FOVsize [X Y] - the spatial size
%         -  


p = inputParser;
addRequired(p,'data');
addRequired(p,'validPixels');
addRequired(p,'FOVsize');

parse(p,data,validPixels, FOVsize,varargin{:});

volume = zeros(prod(FOVsize), size(data,2));
volume(validPixels,:) = data;
volume = reshape(volume, FOVsize(1), FOVsize(2), size(data,2));


end