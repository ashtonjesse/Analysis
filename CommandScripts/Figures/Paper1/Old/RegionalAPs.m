close all;
% clear all;

sFolder = 'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003';

%load the optical file
[pathstr, name, ext, versn] = fileparts(sFolder);
[startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(sFolder, '\');
[startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(sFolder, splitStr{end-1});
sStimulationType = splitStr{end}(1:end-3);
listing = dir(sFolder); %names of files vary so just get all the files in dir
aFilesInFolder = {listing(:).name}; %convert to cell array
aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
aOpticalFileName = [sFolder,'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
% oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
% oPressure = GetPressureFromMATFile(Pressure,[sFolder,'\Pressure.mat'],'Optical');
fprintf('Loaded %s\n', aOpticalFileName);

dWidth = 17;
dHeight = 6;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

%set up panel
aSubplotPanel = panel(oFigure);
aSubplotPanel.pack('h',{0.1,0.9});
aSubplotPanel(2).pack('v',{0.3,0.1,0.3,0.3});
aSubplotPanel.margin = [14,2,2,2];
aSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]
aSubplotPanel(2).de.fontsize = 8;
aSubplotPanel(2).margin = [0 0 0 0];
aSubplotPanel(2).de.margin = [3 0 0 0];


dlabeloffset = 2.5;
XLim = [3 27];
movegui(oFigure,'center');
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2017\PacemakerUncoupling\Figures\RegionalAPs.png';

%% get electrodes
iBeats = [38,55,56,75,94];
aElectrodes = zeros(2,1);
aOrigins = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
aElectrodes(1) = find(aOrigins(56,:));
aElectrodes(2) = find(aOrigins(38,:));
% aExits = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'arsps','Exit');
% aElectrodes(3) = find(aExits(1,:));
%% plot full trace
oAxes = aSubplotPanel(2,1).select();
oElectrode1 = oOptical.Electrodes(aElectrodes(1));%596(0-2), 256(3-5),341(origin),1134(RAA)
aData = cell(1,2);
aData{1} = oElectrode1.Processed.Data;
aData{2} = oOptical.Beats.Indexes;
aTime = oOptical.TimeSeries + oPressure.oRecording.TimeSeries(1);
plot(oAxes,aTime,oOptical.RemoveLinearInterpolation(aData),'k-','linewidth',1);

%set axes limits
axis(oAxes,'tight');
xlim(oAxes,XLim);
set(oAxes,'box','off');
oYlabel = ylabel(oAxes,['dF/F0',10,'(%)']);
set(oYlabel,'fontsize',8);
set(oYlabel,'rotation',0);
oPosition = get(oYlabel,'position');
oPosition(1) = XLim(1) - dlabeloffset;
YLim = get(oAxes,'ylim');
oPosition(2) = YLim(1) + (YLim(2) - YLim(1)) / 4;
set(oYlabel,'position',oPosition);
%set axes colour
set(oAxes,'xcolor',[1 1 1]);
set(oAxes,'xtick',[]);
set(oAxes,'xticklabel',[]);

%% plot zoom ins
YLim = [-0.5,2.75];
SlopeYLim = [-0.25, 0.8];
iTimeLength = 80;
for ii = 1:2
    aSubplotPanel(2,ii+2).pack('h',{0.975 0.025});
    aSubplotPanel(2,ii+2,1).pack('h',5);
    for jj = 1:numel(iBeats)
        oAxes = aSubplotPanel(2,ii+2,1,jj).select();
        oElectrode = oOptical.Electrodes(aElectrodes(ii));%596(0-2), 256(3-5),341(origin),1134(RAA)
        aData = cell(1,2);
        aData{1} = oElectrode.Processed.Data;
        aData{2} = oOptical.Beats.Indexes;
        aTime = oOptical.TimeSeries + oPressure.oRecording.TimeSeries(1);
        aDataToPlot = oOptical.RemoveLinearInterpolation(aData);
        plot(oAxes,aTime(oOptical.Beats.Indexes(iBeats(jj),1):oOptical.Beats.Indexes(iBeats(jj),1)+iTimeLength), ...
            aDataToPlot(oOptical.Beats.Indexes(iBeats(jj),1):oOptical.Beats.Indexes(iBeats(jj),1)+iTimeLength), ...
            'k-','linewidth',1);
        axis(oAxes,'tight');
        set(oAxes,'ylim',YLim);
        set(oAxes,'box','off');
        axis(oAxes,'off');
        %plot slope
        oSlopeAxes = axes('parent',oFigure,'position',get(oAxes,'position'));
        plot(oSlopeAxes,aTime(oOptical.Beats.Indexes(iBeats(jj),1):oOptical.Beats.Indexes(iBeats(jj),1)+iTimeLength), ...
            oOptical.Electrodes(aElectrodes(ii)).Processed.Slope(oOptical.Beats.Indexes(iBeats(jj),1):oOptical.Beats.Indexes(iBeats(jj),1)+iTimeLength), ...
            'r-','linewidth',1);
        set(oSlopeAxes,'color','none','box','off');
        axis(oSlopeAxes,'tight');
        set(oSlopeAxes,'ylim',SlopeYLim);
        axis(oSlopeAxes,'off');
    end
end
%put scale bar on last axes
%plot time scale
hold(oSlopeAxes,'on');
XLim = get(oSlopeAxes,'xlim');
plot(oSlopeAxes,[XLim(2)-0.02; XLim(2)], [YLim(1)+0.3; YLim(1)+0.3], '-k','LineWidth', 2)
axis(oSlopeAxes,'off');
% %     print
export_fig(sSavePath,'-png','-r600','-nocrop');