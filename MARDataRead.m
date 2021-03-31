%% Reading in the NetCDF for May 2020
% This script is to read in the MAR v 3.11 to determine the snow fall and
% surface temperatures for May 2020. The data was collected via:
% wget ftp://ftp.climato.be/fettweis/MARv3.11/Greenland/ERA5_1950-2020-10km/monthly_1km/MARv3.11-monthly-ERA5-2020.nc
% A helpful resource for working with NetCDF data is:
% https://oceanobservatories.org/knowledgebase/working-with-netcdf-files-in-matlab/
% and:
% https://www.mathworks.com/help/matlab/network-common-data-form.html?s_tid=CRUX_lftnav

clear
%% Reading in the data 2019
% Read in the previous year monthly snowfall in order to determine a
% cumulative snowfall. Using November as the start for a conservative
% estimate per Jason Briner.

netfile = 'MARv3.11-monthly-ERA5-2019.nc';  % Set the name of the file
% var = {'SF'};	% Surface Temp, Corrected Surface Temp, Snowfall
% info = ncinfo(netfile);
% SurfTemp = ncread(netfile,var{1});
% SurfTempCorr = ncread(netfile,var{2});
Snowfall19 = ncread(netfile,'SF');  % read in the data
% X = single(ncread(netfile,var{4}));
% Y = single(ncread(netfile,var{5}));

%% Reading in the data
% Reading in the most recent year snowfall and surface temperature
% corrected data. It was determined that the corrected data was generally
% identical to the regular temperature, so the regular temp was not used.

netfile = 'MARv3.11-monthly-ERA5-2020.nc';
var = {'T2M','T2Mcorr','SF','x','y'};	% Surface Temp, Corrected Surface Temp, Snowfall
% info = ncinfo(netfile);
% SurfTemp = ncread(netfile,var{1});
SurfTempCorr = ncread(netfile,var{2});
Snowfall = ncread(netfile,var{3});
X = single(ncread(netfile,var{4}));
Y = single(ncread(netfile,var{5}));

%% Locations of interest
% These are the original locations from Dr. Jason Briner. I converted these
% points to Decimal degrees by dividing the decimal minutes by 60. These
% were then input into var [site]. From there I converted the site
% locations from Lat/Long to Polar Stereographic North, which is the same
% coordinate system used for the X,Y grid the base NetCDF is projected on
% at 1 km resolution.  The transformed locations were rounded to the
% nearest km to allow for a direct match of the XY data and to find the
% index of those locations. A more robust alternative to is determine the
% values for of the four adjacent grid cells for the location with using
% ceil() and floor() rounding instead and then analyzing that data. Because
% this is reanalysis model data, it problem wouldn't make much difference
% at the northern latitudes. 

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
    78.459683 -67.5272
    78.5201 -67.6671
    81.4781 -43.4764
    81.5176 -44.3752
    76.9704 -25.6069
    76.9594 -25.4325];

[x,y] = ll2psn(site(:,1),site(:,2));
x = single(round(x,-3));
y = single(round(y,-3));

siteNum = (1:length(x))';

xi = zeros(length(x),1);
yi = zeros(length(y),1);

for i = 1:length(x)
    xi(i) = find(X==x(i));
    yi(i) = find(Y==y(i));
end

%% Set Months
% This selects the months of interest and returns the data to single format
% to minimize RAM usage. Rounding was done to effectively smooth the data
% and remove unnecessary significant figures. I mean, how needs degrees
% Celcius to .000001 'precision'...
% SurfTemp = round(single(SurfTemp(:,:,5)),2);	% degrees C
SurfTempCorr = round(single(SurfTempCorr(:,:,1:9)),2);	% degrees C
Snowfall = round(single(Snowfall(:,:,1:9)));	% mmWE/month Jan - May
Snowfall19 = round(single(Snowfall19(:,:,11:12)));	% mmWE/month Nov - Dec

%% Find the values
TempMonths = 4:7;   %These are the numerical months to see what the temperature is
data = zeros(length(x),length(TempMonths) + 1);
for j=1:length(x)
    data(j,1:length(TempMonths)) = SurfTempCorr(xi(j),yi(j),TempMonths);
    data(j,end) = sum(Snowfall19(xi(j),yi(j),:))+sum(Snowfall(xi(j),yi(j),:));
%     data(j,4) = sum(Snowfall19(xi(j),yi(j),:));
%     data(j,1) = SurfTemp(xi(j),yi(j));
end

AllData = [siteNum site data];
% This acts as a final output that is put into Excel, Calc, etc to package
% up the data. Because the choice in months and others stuff could easily
% change, I didn't build it to auto generate the file since it will depend
% on what the user wants.

%% Visualize the Data

% figure(1)
% imagesc(X,Y,SurfTemp')
% colorbar
% set(gca, 'YDir','normal');
% hold on
% scatter(x,y,'bo')
% hold off
% 
% figure(2)
% imagesc(X,Y,SurfTempCorr')
% colorbar
% set(gca, 'YDir','normal');
% hold on
% scatter(x,y,'bo')
% hold off
% 
% figure(3)
% clf
% imagesc(X,Y,Snowfall')
% colormap(hsv)
% set(gca, 'YDir','normal');
% colorbar
% hold on
% scatter(x,y,'bo')
% hold off
