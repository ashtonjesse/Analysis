%this script plots two baroreflex cycle length responses before and after
%ivabradine on a single graph to demonstrate the change in speed of onset
close all;
clear all;
sFiles = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\baro002a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\baro005a_3x3_1ms_g10_LP100Hz-waveEach.mat' ...
    };

dWidth = 8;
dHeight = 8;
sFileSavePath = 'D:\Users\jash042\Documents\PhD\Posters\2017\HRS\IVBData.png';

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
oSubplotPanel.fontsize = 24;
oSubplotPanel.pack();

%set up margins
movegui(oFigure,'center');
oSubplotPanel.margin = [15,10,5,5];
oSubplotPanel.de.margin = [6 0 0 0];%[left bottom right top]
oAxes = oSubplotPanel(1).select();
iNumFiles = numel(sFiles);
sColours = {'k','r'};
for i = 1:iNumFiles
        if iscell(sFiles{i})
            sThisFile = sFiles{i}{1};
        else
            sThisFile = sFiles{i};
        end
        [pathstr, name, ext, versn] = fileparts(sThisFile);
        sFileName = [pathstr,'\Pressure.mat'];
        oPressure = GetPressureFromMATFile(Pressure,sFileName,'Optical');
        
        aCouplingIntervals = (60000./[NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates])-60000/mean(oPressure.Baseline.BeatRates);
        aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        aAdjustedTimes = aTimes - oPressure.HeartRate.Decrease.BeatTimes(1);
        hold(oAxes,'on');
        plot(oAxes, aAdjustedTimes, aCouplingIntervals,sColours{i},'linewidth',2);
        scatter(oAxes, aAdjustedTimes, aCouplingIntervals,49,sColours{i},'filled');
        xlim([0 6]);
        ylim([-10 300]);
        
end
set(oAxes,'xtick',[0 2 4 6]);
set(oAxes,'linewidth',2,'ticklength',[0.05 0.05]);
export_fig(sFileSavePath,'-png','-r300','-nocrop');