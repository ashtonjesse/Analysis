%loop through pressure files to get coupling intervals and load distance
%data for each 
%plot on axes and hold on
% close all;
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
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro008\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140722\20140722baro009\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro007\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro008\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140723\20140723baro009\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro003\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro004\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro006\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140813\20140813baro007\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814baro006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140821\20140821baro006\Pressure.mat' ...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140826\20140826baro004\Pressure.mat'...
    },{...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro001\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro002\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro003\Pressure.mat'...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro004\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro005\Pressure.mat' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140828\20140828baro006\Pressure.mat'...
    }};
% },{
%     'G:\PhD\Experiments\Bordeaux\Data\20131129\20131129baro003\Pressure.mat'...
sSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\';
%set up figure
dWidth = 12;
dHeight = 12;

oMainFigure = figure();

set(oMainFigure,'color','white')
set(oMainFigure,'inverthardcopy','off')
set(oMainFigure,'PaperUnits','centimeters');
set(oMainFigure,'PaperPositionMode','auto');
set(oMainFigure,'Units','centimeters');
set(oMainFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oMainFigure,'Resize','off');

aSubplotPanel = panel(oMainFigure,'no-manage-font');
aSubplotPanel.pack(1,1);
oMainAxes = aSubplotPanel(1,1).select();

iScatterSize = 16;
ylim = [0 900];
xlim = [0 7];

% oPatch = patch([-1 1 1 -1], [ylim(1) ylim(1) ylim(2) ylim(2)],[0 0 0],'parent',oMainAxes);
% set(oPatch, 'LineStyle', 'none')
% hh1 = hatchfill(oPatch, 'single', -45, 10,[0.9 0.9 0.9]);
hold(oMainAxes, 'on');
% plot(oMainAxes,[xlim(1) xlim(2)],[0 0],'--','color','k');
% plot(oMainAxes,[0 0],[ylim(1) ylim(2)],'--','color','k');
aBaselinePressures = cell(numel(aControlFiles),1);
aPlateauPressures = cell(numel(aControlFiles),1);
for i = 1:numel(aControlFiles)
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
%     
%     oPatch = patch([-1 1 1 -1], [ylim(1) ylim(1) ylim(2) ylim(2)],[0 0 0],'parent',oAxes);
%     set(oPatch, 'LineStyle', 'none')
%     hh1 = hatchfill(oPatch, 'single', -45, 10,[0.9 0.9 0.9]);
    hold(oAxes, 'on');
%     plot(oAxes,[xlim(1) xlim(2)],[0 0],'--','color','k');
%     plot(oAxes,[0 0],[ylim(1) ylim(2)],'--','color','k');
    aFiles = aControlFiles{i};
    [pathstr, name, ext, versn] = fileparts(char(aFiles{1}));
    load([pathstr(1:end-16),'\BaroLocationData.mat']);
    sThisSavePath = [sSavePath,'BaroCIVsShift_initial_',pathstr(end-23:end-16),'.eps'];
    aBaselinePressures{i} = zeros(1,numel(aFiles));
    aPlateauPressures{i} = zeros(1,numel(aFiles));
    for j = 1:numel(aFiles)
        oPressure = GetPressureFromMATFile(Pressure,char(aFiles{j}),'Optical');
        fprintf('Got file %s\n',char(aFiles{j}));
        aBaselinePressures{i}(j) = mean(oPressure.Baseline.BeatPressures);
        aPlateauPressures{i}(j) = mean(oPressure.Plateau.BeatPressures);
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
        %                 aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Increase.Range(1)) & ...
        %                     aTimes < oPressure.TimeSeries.Original(oPressure.Plateau.Range(2));
        if oPressure.HeartRate.Plateau.Range > 0
            %             aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2));
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Increase.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.HeartRate.Plateau.Range(2));
        else
            %             aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Plateau.Range(2));
            aTimePoints = aTimes > oPressure.TimeSeries.Original(oPressure.Increase.Range(1)) & ...
                aTimes < oPressure.TimeSeries.Original(oPressure.Plateau.Range(2));
        end
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
        if i == 9
            dBaseline = mean(oPressure.Baseline.BeatRates(2:end));
        else
            dBaseline = mean(oPressure.Baseline.BeatRates);
        end
%         delT = [NaN diff(aCouplingIntervals)] ./ (60000/dBaseline)*100;
%         delX = vertcat(NaN, -diff(aLocs));
        delT = aCouplingIntervals;
        delX = aLocs;
        switch (i)
            case 6
                switch (j)
                    case {1,2}
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');%oColors(p,:)
                        scatter(oMainAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');%oColors(p,:)
%                     case {3,4,5}
%                         scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'r','filled');%oColors(p,:)
%                         scatter(oMainAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'r','filled');%oColors(p,:)
                end
            case {7,8,9,10}
                switch (j)
                    case {1,2,3}
                        scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');%oColors(p,:)
                        scatter(oMainAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');%oColors(p,:)
%                     case {4,5,6}
%                         scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'r','filled');%oColors(p,:)
%                         scatter(oMainAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'r','filled');%oColors(p,:)
                end
            otherwise
                scatter(oAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');
                scatter(oMainAxes, delX(aTimePoints), delT(aTimePoints),iScatterSize,'k','filled');
        end
    end
    hold(oAxes, 'off');
    set(oAxes,'xlim',xlim);
    set(oAxes,'ylim',ylim);
    movegui(oFigure,'center');
    set(oFigure,'resizefcn',[]);
    set(get(oAxes,'xlabel'),'string','Inferior            Shift (mm)     Superior');
    set(get(oAxes,'ylabel'),'string','% \Delta Cycle Length');
%     print(oFigure,'-dpsc','-r600',sThisSavePath)
end
sThisSavePath = [sSavePath,'BaroCIVsShift_initial_all.eps'];
hold(oMainAxes, 'off');
set(oMainAxes,'xlim',xlim);
set(oMainAxes,'ylim',ylim);
movegui(oMainFigure,'center');
set(oMainFigure,'resizefcn',[]);
set(get(oMainAxes,'xlabel'),'string','Inferior            Shift (mm)     Superior');
set(get(oMainAxes,'ylabel'),'string','% \Delta Cycle Length');
% print(oMainFigure,'-dpsc','-r600',sThisSavePath)


