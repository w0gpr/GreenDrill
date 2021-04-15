%% MARFirnDataRead
% This is a follow up of MARDataRead.m to read in a Firn thickness dataset
% to determine the firn thickness at the points of interest. The dataset
% has a spatial resolution of 12.5 km. Because of this high spatial
% resolution, I'm looking to see what the spatial derivative is in the
% areas of interest, and to see if it needs to be interpolated. I also
% don't know if the coordinates of the raster points are for a corner
% (usually upper left?) or the center of the pixel.

clear

netfile = 'gsfcfdmv11firnDepthgris.nc';
% info = ncinfo(netfile);
data = single(ncread(netfile,'time'));
X = single(ncread(netfile,'x'));
Y = single(ncread(netfile,'y'));

data(isnan(data)) = 0;
% data(data>50) = 0;


%% Locations of interest
% These are the original locations from Dr. Jason Briner. I converted these
% points to Decimal degrees by dividing the decimal minutes by 60. These
% were then input into var [site]. From there I converted the site
% locations from Lat/Long to Polar Stereographic North, which is the same
% coordinate system used for the X,Y grid the base NetCDF is projected on
% at 12.5 km resolution.  The transformed locations were then matched to
% the nearest grid center by finding the XY location that minimized the
% difference between the grid and the site locations. A perimeter search
% was also done to find the adjacent cell with the thickest firn.

% 78° 6.162’N  -70° 52.091'W
% 78° 19.728'N  -70° 29.640'W
% 78° 27.581'N  -67° 31.632'W
% 78° 31.207'N  -67° 40.026'W
% 81° 28.685'N -43° 28.583'W
% 81° 31.055'N  -44° 22.510'W
% 76° 58.226'N  -25° 36.412'W
% 76° 57.562'N  -25° 25.951’W

site = [78.1027 -70.68183
    78.3288 -70.4940
    78.4597 -67.5272
    78.5201 -67.6671
    81.4781 -43.4764
    81.5176 -44.3752
    76.9704 -25.6069
    76.9594 -25.4325];

[x,y] = ll2psn(site(:,1),site(:,2));    % transform coordinates
x = single(x);
y = single(y);

[~,xi] = min(abs(X-x'));    % find the matching indices
[~,yi] = min(abs(Y-y'));

xi = xi'; yi = yi';

FirnT = data(sub2ind(size(data),yi,xi)); % Firn thickness (m) for the sites

FirnTMax = zeros(length(x),1);
FirnTMin = FirnTMax;

% Loop to search around the site locations for the thickest firn location
for i = 1:length(x)
    m = 1;
    for j = -1:1
        for k = -1:1
             temp(m) = data(yi(i)-j,xi(i)-k);
             m = m+1;
        end
    end
%     disp(temp)
    FirnTMax(i) = max(temp);
    FirnTMin(i) = min(temp);
end
Xloc = X(xi);
Yloc = Y(yi);

output = [site FirnT FirnTMax FirnTMin]

%% Visualize the data
% figure(1)
% clf
% imagesc(X,Y,data)
% set(gca,'YDir','normal');
% hold on
% colormap('jet')
% colorbar
% xlim([-1e6,1e6])
% ylim([-1.5e6, -0.5e6])
% zlim([0 50])
% scatter(Xloc,Yloc,'ro')
% scatter(x,y,'r*')