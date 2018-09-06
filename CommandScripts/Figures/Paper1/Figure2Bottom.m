close all;
% clear all;

sFolder = 'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004';
%load the optical file
[pathstr, name, ext, versn] = fileparts(sFolder);
[startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(sFolder, '\');
[startIndex, endIndex, tokIndex, matchStr, tokenStr, exprNames, splitStr] = regexp(sFolder, splitStr{end-1});
sStimulationType = splitStr{end}(1:end-3);
listing = dir(sFolder); %names of files vary so just get all the files in dir
aFilesInFolder = {listing(:).name}; %convert to cell array
aFileIndex = regexp(aFilesInFolder, [sStimulationType,'\d*a?_\w*g10_LP100Hz-waveEach.mat']); %find index of right file
aOpticalFileName = [sFolder,'\',aFilesInFolder{find(~cellfun('isempty', aFileIndex))}]; %build file name
oOptical = GetOpticalFromMATFile(Optical,char(aOpticalFileName)); %get optical file
oPressure = GetPressureFromMATFile(Pressure,[sFolder,'\Pressure.mat'],'Optical');
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
aSubplotPanel(2).pack('v',4);
aSubplotPanel.margin = [14,2,2,2];
aSubplotPanel.de.margin = [0 0 0 0];%[left bottom right top]
aSubplotPanel(2).de.fontsize = 8;
aSubplotPanel(2).margin = [0 0 0 0];
aSubplotPanel(2).de.margin = [3 1 0 0];


dlabeloffset = 2.5;
XLim = [3.5 31.4];
movegui(oFigure,'center');
sSavePath = 'C:\Users\jash042.UOA\Dropbox\Publications\2018\SinoAtrialNode\Figures\Figure2\Figure2_bottompanel.eps';

%% get electrodes
aElectrodes = zeros(2,1);
aOrigins = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'aghsm','Origin');
aElectrodes(1) = 554;
aElectrodes(2) = 279;
% aExits = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'arsps','Exit');
% aElectrodes(3) = find(aExits(1,:));
%% plots
for ii = 1:2
    oAxes = aSubplotPanel(2,2*(ii-1)+1).select();
    oElectrode = oOptical.Electrodes(aElectrodes(ii));%596(0-2), 256(3-5),341(origin),1134(RAA)
    aData = cell(1,2);
    aData{1} = oElectrode.Processed.Data;
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
    set(oAxes,'ylim',[-0.2, 2.6]);
    YLim = get(oAxes,'ylim');
    oPosition(2) = YLim(1) + (YLim(2) - YLim(1)) / 4;
    set(oYlabel,'position',oPosition);
    %set axes colour
    set(oAxes,'xcolor',[1 1 1]);
    set(oAxes,'xtick',[]);
    set(oAxes,'xticklabel',[]);
    
    %% plot gradient
    oAxes = aSubplotPanel(2,2*ii).select();
    %     oAxes = axes('parent',oFigure,'position',get(oAxes,'position'));
    plot(oAxes,aTime,oOptical.Electrodes(aElectrodes(ii)).Processed.Slope,'r-','linewidth',1);
    %set axes limits
    axis(oAxes,'tight');
    xlim(oAxes,XLim);
    set(oAxes,'ylim',[-0.2, 0.8]);
    set(oAxes,'box','off');
    oYlabel = ylabel(oAxes,'dF/dt');
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
    set(oAxes,'ytick',[0 0.2 0.4 0.6]);
    set(oAxes,'yticklabel',{'0','','','0.6'});
end

%put scale bar on last axes
%plot time scale
% hold(oSlopeAxes,'on');
% XLim = get(oSlopeAxes,'xlim');
% oScaleAxes = axes('parent',oFigure,'position',get(oSlopeAxes,'position')-[0 0.01 0 0]);
% plot(oScaleAxes,[XLim(2)-0.02; XLim(2)], [YLim(1)+0.3; YLim(1)+0.3], '-k','LineWidth', 2)
% set(oScaleAxes,'ylim',get(oSlopeAxes,'ylim'),'xlim',XLim);
% axis(oScaleAxes,'off');
% %     print
set(oFigure,'resizefcn',[]);
print(sSavePath,'-dpsc2','-r600','-painters');