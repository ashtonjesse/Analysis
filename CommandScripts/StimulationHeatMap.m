%This scipt obtains the x and y coordinates of all pacemaker locations
%across all recordings and all experiments for baroreflex, chemoreflex and
%CCh
%It then interpolates all of these coordinates on to a specified grid 
%A binary image is created for each recording and white pixels set for each
%point
%The binary images are combined and a distance heat map is created for the
%result.
% clear all;
close all;
aFolders = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140715' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140718' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140722' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140723'...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140813' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140814' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140821' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140826' ...
%     'G:\PhD\Experiments\Auckland\InSituPrep\20140828' ...
    };
                        
%loop through folders 

%open baro location data
X1Data = cell(1,numel(aFolders));
Y1Data = cell(1,numel(aFolders));
for n = 1:numel(aFolders)
    load([char(aFolders{n}),'\BaroLocationData_20170419.mat']);
    ThisX1Data = {DPSites(1:4).X1};
    X1Data{n} = vertcat(ThisX1Data{1:4});
    ThisY1Data = {DPSites(1:4).Y1};
    Y1Data{n} = vertcat(ThisY1Data{1:4});
end
X1Data = vertcat(X1Data{:});
Y1Data = vertcat(Y1Data{:});
cell(1,numel(DPSites));

aCoords = horzcat(X1Data,Y1Data);
aCoords = aCoords(~isnan(aCoords(:,1)),:);
aNewCoords = zeros(size(aCoords));
aDistances = zeros(size(aCoords,1),1);
for m = 1:size(aCoords,1)
    %compute distance transform
    RelativeDistVectors = aCoords-repmat([aCoords(m,1),aCoords(m,2)],[size(aCoords,1),1]);
    [Dist,SupportPoints] = sort(sqrt(sum(RelativeDistVectors.^2,2)),1,'ascend');
    ind = find(Dist,1,'first');
    aDistances(m) = Dist(ind);
    %convert back to original coordinate system
    CoordToSave = TransformCoordinates([2.1736;5.8613],[0.6446;-0.7645],aCoords(m,:)');
    aNewCoords(m,:) = CoordToSave';
end

aDistances = aDistances(~isnan(aDistances(:,1)),:);
aDistances(aDistances<0.001,:) = 0;
aNewCoords = aNewCoords(aDistances>0.001,:);
% aCoords(112,1) = 0;
aDistances= aDistances(aDistances>0.001,:);


% % % % % %Read in the file containing all the optical data
oOpticalEntities{1} = GetOpticalFromMATFile(Optical,'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\baro006_3x3_1ms_7x_g10_LP100Hz-waveEach.mat');

%set variables
dWidth = 9;
dHeight = 9;
sFileSavePath = 'C:\Users\jash042.UOA\Dropbox\Conferences\2017\HRS\DPHeatMap.png';

%set up figure
oFigure = figure();
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

%set up panel
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack('h',{0.05,0.92});
oSubplotPanel(1).pack('v',{0.1,0.8,0.1});
oSubplotPanel(2).pack();
movegui(oFigure,'center');
oSubplotPanel.margin = [0,0,0,0];
oSubplotPanel.de.margin = [5 0 0 0];%[left bottom right top]


oOptical = oOpticalEntities{1};
aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);

oAxes = oSubplotPanel(2,1).select();
%plot the schematic
oOverlay = axes('position',get(oAxes,'position'));
colormap(oOverlay,flipud(jet));
set(oOverlay,'box','off','color','none');
oImage = imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140703\20140703Schematic_highres.bmp','Parent', oOverlay, 'Border', 'tight');

%         %make it transparent in the right places
aCData = get(oImage,'cdata');
aBlueData = aCData(:,:,3);
aAlphaData = aCData(:,:,3);
aAlphaData(aBlueData < 100) = 1;
aAlphaData(aBlueData > 100) = 1;
aAlphaData(aBlueData == 100) = 0;
aAlphaData = double(aAlphaData);
set(oImage,'alphadata',aAlphaData);
axis(oOverlay,'tight');
axis(oOverlay,'off');

%% compute distance map
%create image array
aDistanceMap = false(500,500);%size(get(oImage,'AlphaData'))
%align image with coordinate system
aFrameSize = [sum(abs(aXlim)), sum(abs(aYlim))];
aCoordsForMap = floor([(aNewCoords(:,1)+abs(aXlim(1))) * size(aDistanceMap,1)/ aFrameSize(1), (aNewCoords(:,2)+abs(aYlim(1))) * size(aDistanceMap,2)/ aFrameSize(2)]);
idx = sub2ind(size(aDistanceMap),aCoordsForMap(:,2),aCoordsForMap(:,1));%size(aDistanceMap,2)-
aDistanceMap(idx) = 1;
% imshow(aDistanceMap);

D = bwdist(aDistanceMap);
aAlphaData = zeros(size(D));
aAlphaData(D<40) = 1;
Im = imagesc(D,'parent',oAxes,[10 40]);
set(Im,'alphadata',aAlphaData);
% image(mat2gray(D));
% scatter(oAxes,aNewCoords(:,1),aNewCoords(:,2),36,aDistances,'filled');
% colormap(flipud(colormap(jet)));
axis(oAxes,'equal');
set(oAxes,'box','off','color','none');
axis(oAxes,'off');

% % % put on colour bar
oAxes = oSubplotPanel(1,2).select();
aCRange = [0 50];
aContours = 0:10:50;
cbarf_edit(aCRange, aContours,'vertical','nonlinear',oAxes,'AT',18);

export_fig(sFileSavePath,'-png','-r300','-nocrop')