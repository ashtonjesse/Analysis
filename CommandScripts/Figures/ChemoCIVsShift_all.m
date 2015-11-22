%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
close all;
clear all;
aControlFiles = {{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813chemo003\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814chemo005\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821chemo006\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826chemo006\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828chemo006\Pressure.mat'...
    }};

%set up figure
dWidth = 12;
dHeight = 12;
oFigure = figure();

set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','auto');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

aSubplotPanel = panel(oFigure,'no-manage-font');
aSubplotPanel.pack(1,1);
oAxes = aSubplotPanel(1,1).select();
aPosition = get(oAxes,'position');
iScatterSize = 16;
ylim = [-600 600];
xlim = [-7 7];

oPatch = patch([-1 1 1 -1], [ylim(1) ylim(1) ylim(2) ylim(2)],[0 0 0],'parent',oAxes);
set(oPatch, 'LineStyle', 'none')
hh1 = hatchfill(oPatch, 'single', -45, 10,[0.9 0.9 0.9]);
hold(oAxes, 'on'); 
plot(oAxes,[xlim(1) xlim(2)],[0 0],'--','color','k');
plot(oAxes,[0 0],[ylim(1) ylim(2)],'--','color','k');

% sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\chemoCIVsShift_return_all_postIVB.eps';
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\ChemoCIVsShift_initial_all_postIVB.eps';

for i = 1:numel(aControlFiles)
    aFiles = aControlFiles{i};
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-16),'\ChemoLocationData.mat']);
    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
        switch (i)
            case 2
                if j == 5
                    iRecordingIndex = 2;
                else
                    iRecordingIndex = 1;
                end
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(iRecordingIndex).Electrodes.Processed.BeatRateTimes;
            case 4
                aCouplingIntervals = 60000 ./ oPressure.oRecording(1).Electrodes.Processed.BeatRates';
                aTimes = oPressure.oRecording(1).TimeSeries(oPressure.oRecording(1).Electrodes.Processed.BeatRateIndexes);
            case 5
                if j == 2
                    aCouplingIntervals = 60000 ./ [oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes(2:end);
                else
                    aCouplingIntervals = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                    aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
                end
            otherwise
                aCouplingIntervals  = 60000 ./ [NaN oPressure.oRecording(1).Electrodes.Processed.BeatRates];
                aTimes = oPressure.oRecording(1).Electrodes.Processed.BeatRateTimes;
        end
        if i == 3 && j == 1
            %The data used for location detection is a subset missing the
            %first 10 beats
            aCouplingIntervals = aCouplingIntervals(11:end);
            aTimes = aTimes(11:end);
        end
        aTimePoints = aTimes >= oPressure.HeartRate.Decrease.BeatTimes(1) & ...
            aTimes <= oPressure.HeartRate.Decrease.BeatTimes(end);
        try
            aThisDistance =  aDistance{j};
            aLocs = aThisDistance{1}(:,1);
        catch ex
            aLocs =  aDistance{j}(:,1);
        end
        if size(aLocs,1) ~= numel(aCouplingIntervals);
            break; disp('broken');
        end
        delT = [NaN diff(aCouplingIntervals)];
        delX = vertcat(NaN, -diff(aLocs));
        
        switch (i)
            case 1
                switch (j)
                    case 1
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');%oColors(p,:)
                    case 2
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'r','filled');%oColors(p,:)
                end
            case 2
                switch (j)
                    case {1,2}
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');%oColors(p,:)
                    case {3,4,5}
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'r','filled');%oColors(p,:)
                end
            otherwise
                switch (j)
                    case {1,2,3}
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');%oColors(p,:)
                    case {4,5,6}
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'r','filled');%oColors(p,:)
                end
        end
    end
end

hold(oAxes, 'off'); 
set(oAxes,'xlim',xlim);
set(oAxes,'ylim',ylim);
movegui(oFigure,'center');
set(oFigure,'resizefcn',[]);
set(get(oAxes,'xlabel'),'string','Inferior            Shift (mm)     Superior');
set(get(oAxes,'ylabel'),'string','\Delta Coupling Interval (ms)');
print(oFigure,'-dpsc','-r600',sSavePath)