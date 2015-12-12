%loop through each experiment
%load the pressure data
%load the location data
%get all beats where change in coupling interval > 100 and group into shifts
%< 1mm vs shifts > 1mm 

close all;
clear all;
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro009\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro010\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro011\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140703\20140703baro012\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140715\20140715baro008\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro002\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat'...
    }};%,{

dWidth = 16;
dHeight = 18;
oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
% set(oFigure, 'WindowStyle', 'Docked');
aSubplotPanel = panel(oFigure);
aSubplotPanel.pack(4,3);
aSubplotPanel.margin = [20 10 10 10];
aSubplotPanel.de.margin = [15 20 15 15];
oSubplotPanel.de.fontsize = 6;

movegui(oFigure,'center');

m = 1;
n = 1;
aData = cell(1,numel(aControlFiles));
aAllData = cell(1,numel(aControlFiles));
for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    aData{i} = cell(numel(j),1);
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-16),'\BaroLocationData.mat']);
    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
        switch (i)
            case {7,10}
                if j == 1
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 8
                if j == 1 || j == 2
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 9
                aCouplingIntervals = 60000 ./ oPressure.oRecording(1).Electrodes.Processed.BeatRates';
                aTimes = [oPressure.oRecording(1).TimeSeries(...
                    oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes(1:end-1)) NaN];
            case 11
                aCouplingIntervals = 60000 ./ oPressure.oRecording(1).Electrodes.Processed.BeatRates';
                aTimes = oPressure.oRecording.TimeSeries(oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes);
            otherwise
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        end
        aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Increase.Range(1));        
        aLocs =  aDistance{j}(:,1);
        if size(aLocs,1) ~= numel(aCouplingIntervals);
            if i == 4
                switch (j)
                    case 9
                        aLocs = vertcat(aLocs(1:49),aLocs(49),aLocs(50:end));
                    case 8
                        aLocs = vertcat(aLocs(1:20),aLocs(20),aLocs(21:end));
                    case 6
                        aLocs = vertcat(aLocs(1:22),aLocs(22),aLocs(23:end));
                    case 7
                        aLocs = vertcat(aLocs(1:18),aLocs(18),aLocs(19:end));
                end
            else
                break; disp('broken');
            end
        end

        aTheseLocs = aLocs(aTimePoints);
        aData{i}{j} = aTheseLocs(aTheseLocs>1);
    end
    if i ==5
        x=1;
    end
    oAxes = aSubplotPanel(m,n).select();
    aAllData{i} = vertcat(aData{i}{:});
    hist(oAxes,aAllData{i},0:0.5:7);
    %     ylim(oAxes,[0 120]);
    %     xlim(oAxes,[0 7]);
    axis(oAxes,'tight');
    set(get(oAxes,'title'),'string',pathstr(end-14:end-7));
    set(get(oAxes,'title'),'fontweight','bold');
    if m == 1 && n == 1
        xlabel(oAxes,'Location (mm)');
        ylabel(oAxes,'Frequency');
    end
    n = n + 1;
    if n > 3
        n = 1;
        m = m + 1;
    end
end
oAxes = aSubplotPanel(m,n).select();
hist(oAxes,vertcat(aAllData{:}),0:0.5:7);
axis(oAxes,'tight');
set(get(oAxes,'title'),'string','All');
set(get(oAxes,'title'),'fontweight','bold');
% figure()
% oAxes = axes();
% hist(oAxes,horzcat(aLengthening{:}),-100:25:300);
% hold(oAxes,'on');
% bplot(horzcat(aIVBShortening{:},aIVBLengthening{:}),oAxes,2,'nolegend','tukey','linewidth',1);
% aIVBShortening = aIVBSmallShortening(aIVBLengthening>0);
% aIVBLengthening = aIVBLargeLengthening(aIVBLengthening>0);
% 
% oFigure = figure();
% oAxes = axes();
% bar(oAxes, [mean(aSmallShortening), mean(aSmallLengthening), mean(aIVBSmallShortening), mean(aIVBSmallLengthening)]);
% oFigure = figure();
% oAxes = axes();
% bar(oAxes, [mean(aLargeShortening), mean(aLargeLengthening), mean(aIVBLargeShortening), mean(aIVBLargeLengthening)]);