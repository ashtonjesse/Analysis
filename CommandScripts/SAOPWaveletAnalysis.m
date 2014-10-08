% This script loads optical mapping data and then uses wavelet analysis to
% correct for low frequency variations in baseline fluorescence.
close all;
% clear all;
% %% load the signal data
% [sFileName,sPathName]=uigetfile('*.*','Select file(s) that contain optical transmembrane recordings');
% 
% % % Make sure the dialogs return char objects
% if (~ischar(sFileName) && ~ischar(sPathName))
%     break
% end
% aOAP = [];
% sLongDataFileName=strcat(sPathName,sFileName);
% %check the extension
% [pathstr, name, ext, versn] = fileparts(sLongDataFileName);
% if strcmpi(ext,'.csv')
%     %read the data and save
%     aThisOAP = ReadOpticalTimeDataCSVFile(sLongDataFileName,6);
%     aOAP = [aOAP aThisOAP];
%     save(fullfile(pathstr,strcat(name,'.mat')),'aThisOAP');
%     fprintf('Opened and saved %s\n',sLongDataFileName);
% elseif strcmpi(ext,'.mat')
%     %load the .mat file
%     load(sLongDataFileName);
%     aOAP = [aOAP aThisOAP];
%     fprintf('Loaded %s\n',sLongDataFileName);
% elseif strcmpi(ext,'.tif');
%     info = imfinfo(sLongDataFileName);
%     num_images = numel(info);
%     aOAP.Data = zeros(42,42,num_images,'uint16');
%     for k = 1:num_images
%         aOAP.Data(:,:,k) = imread(sLongDataFileName, k, 'Info', info);
%     end
% end
% 
% 
% %% Build subplot and plot the unprocessed data
% %this sets the number of wavelet scales we will compute
% iNumberOfScales = 8;
% %create figure to plot on
% oFigure = figure();
% %create subplot panel 
% oSubPlotPanel = panel(oFigure);
% %populate with subplot axes enough to plot all wavelet scales and the
% %unprocessed data
% oSubPlotPanel.pack(5,1);
% oSubPlotPanel.de.margin = 0.2;
% % %select data from specific location
% dXLoc = 21;
% dYLoc = 33;
% % aFirstIndices = find(aOAP.Locations(1,:) == dXLoc);
% % aSecondIndices = find(aOAP.Locations(2,aFirstIndices) == dYLoc);
% % aThisOAP = -aOAP.Data(:,aFirstIndices(aSecondIndices));
% aThisOAP = aOAP.Data(dYLoc,dXLoc,2:end);
% aThisOAP = squeeze(aThisOAP);
% %plot the datak
% oOriginalAxes = oSubPlotPanel(1,1).select();
% plot(oOriginalAxes, aThisOAP);
% set(oOriginalAxes,'xticklabel',[]);
% set(oOriginalAxes,'ytick',[]);
% axis(oOriginalAxes,'auto');
% % compute the wavelet scales
% oSignal = BaseSignal();
% aFilteredSignals = oSignal.ComputeDWTFilteredSignalsKeepingScales(aThisOAP, 0:iNumberOfScales);
% %plot results
% iCount = 2;
% for i = iNumberOfScales-1:iNumberOfScales
%     oAxes = oSubPlotPanel(iCount,1).select();
%     plot(oAxes, aFilteredSignals(:,i),'-r');
%     set(oAxes,'xticklabel',[]);
%     set(oAxes,'ytick',[]);
%     axis(oAxes,'auto');
%     iCount = iCount + 1;
% end
% aNewData = zeros(size(aFilteredSignals),class(aFilteredSignals));
% for i = 1:iNumberOfScales+1
%     aNewData(:,i) = aFilteredSignals(:,i) + abs(min(aFilteredSignals(:,i)));
% end
% aNewImageData = cast(aNewData,'uint16');
% %plot results
% for i = iNumberOfScales-1:iNumberOfScales
%     oAxes = oSubPlotPanel(iCount,1).select();
%     plot(oAxes, aNewImageData(:,i),'-r');
%     set(oAxes,'xticklabel',[]);
%     set(oAxes,'ytick',[]);
%     axis(oAxes,'auto');
%     iCount = iCount + 1;
% end
% 
% % %% loop through all signals and apply correction
% %initialise variables
% aNewOAPData = zeros(size(aOAP.Data,1),size(aOAP.Data,2),size(aOAP.Data,3)-1,'uint16');
% for i = 1:size(aOAP.Data,1)
%     for j = 1:size(aOAP.Data,2)
%         %get data
%         aThisData = aOAP.Data(i,j,2:end);
%         %compute signal keeping scales
%         aFilteredSignal = oSignal.ComputeDWTFilteredSignalsKeepingScales(squeeze(aThisData), iNumberOfScales);
%         %adjust so that all values are >= 0
%         aNewData = aFilteredSignal + abs(min(aFilteredSignal));
%         aNewOAPData(i,j,:) = cast(aNewData,'uint16');
%     end
% end

%% loop through all time points and save to tiff file
%export to a new tiff file
%build tag structs array

aPageNumber = num2cell([0:size(aOAP.Data,3)-2 ; ones(1,size(aOAP.Data,3)-1)*(size(aOAP.Data,3)-1)],1);
tagstruct = struct('PageNumber',aPageNumber);
%set tags
[tagstruct(:).PlanarConfiguration]  = deal(1);
[tagstruct(:).Photometric]  = deal(1);
[tagstruct(:).Compression]  = deal(1);
[tagstruct(:).SamplesPerPixel]  = deal(1);
[tagstruct(:).BitsPerSample]  = deal(16);
[tagstruct(:).Orientation]  = deal(1);
[tagstruct(:).FillOrder]  = deal(1);
[tagstruct(:).SampleFormat]  = deal(1);
[tagstruct(:).ImageLength]  = deal(42);
[tagstruct(:).ImageWidth]  = deal(42);
%create new tif
tic;
sTiffFile = 'G:\PhD\Experiments\Auckland\InSituPrep\20140821\Test.tif';
t = Tiff(sTiffFile,'w');
for m = 1:size(aNewOAPData,3)
    %build tags for this time point
    t.setTag(tagstruct(m));
    %set tag values
    t.write(aNewOAPData(:,:,m));
    t.writeDirectory();
end
t.close();
toc;




















