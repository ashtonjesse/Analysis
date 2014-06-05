%this script reads in heart rate data calculated from RMS voltage data and
%fits curves to the ascending part of the baroreflex rate trajectory

%%get the estimates of pressure event timings
%%Load the data from the txt file
iCount = countLines('G:\PhD\Experiments\Auckland\InSituPrep\PressureSummary.txt');
oEntry = struct('Name','string','Start',0,'Peak',0);
oPressureEvents = repmat(oEntry,1,iCount);
fid = fopen('G:\PhD\Experiments\Auckland\InSituPrep\PressureSummary.txt','r');
tline = fgetl(fid);
for i = 1:iCount;
    tline = fgetl(fid);
    aLine = regexp(tline,'\t','split');
    oPressureEvents(i).Name = char(aLine{1});
    oPressureEvents(i).Start = str2double(char(aLine{2}));
    oPressureEvents(i).Peak = str2double(char(aLine{3}));
end
fclose(fid);
%Loop through the files and read in the RMS data
aFiles = {'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro001\pabaro001_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro002\pabaro002_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro003\pabaro003_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro004\pabaro004_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro005\pabaro005_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130904\0904baro006\pabaro006_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130619\0619baro001\pabaro001_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130619\0619baro002\pabaro002_unemap.mat', ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20130221\0221baro001\pabaro001_unemap.mat'};
% % aLastSlowBeat = [46,17,48,42,46,39,39,48,47];
% % oEntry = struct('Peaks',zeros(2,1000),'Rates',zeros(1,1000),'Times',zeros(1,70000));
% % oData = repmat(oEntry,length(aFiles),1);
sColours = ['r','g','b','c','k','m'];
iColourIndex = 6;
oFigure = figure(); oAxes = axes();
% aUnemaps = repmat(Unemap,1,length(aFiles));
for i = 1:length(aFiles)
% % %     read in the file
%     aUnemaps(i) = GetUnemapFromMATFile(aUnemaps(i),char(aFiles{i}));
%     fprintf('Got file %s\n', char(aFiles{i}));
% % %     %get the peak locations, time arrays and rate data
%     oData(i).Peaks = aUnemaps(i).RMS.HeartRate.Peaks;
%     oData(i).Rates =  aUnemaps(i).RMS.HeartRate.Rates;
%     oData(i).Times = aUnemaps(i).TimeSeries;
%     aPathFolder = regexp(char(aFiles{i}),'\\','split');
%     oData(i).Name = char(aPathFolder{end-1});
%     aIndex = strcmp(oData(i).Name,{oPressureEvents(:).Name});
%     oData(i).StartTime = oPressureEvents(aIndex).Start;
%     oData(i).PeakTime = oPressureEvents(aIndex).Peak;
% % %     %Get the pre challenge average rate
%     if ~isnan(oData(i).StartTime)
%          aIndices = oData(i).Times(oData(i).Peaks(1,:)) < oData(i).StartTime;
%     else
%         aIndices = false(1,length(oData(i).Rates));
%         aIndices(end-10:end) = true;
%     end
%     oData(i).PreChallengeAvgRate = mean(oData(i).Rates(aIndices));
% %     %normalise all beats to this
    oData(i).NormalisedRates = round(((oData(i).Rates - oData(i).PreChallengeAvgRate) / oData(i).PreChallengeAvgRate)*100);
% %     %select the tail beats that are greater than 5% different to control
% %     %level
    aTailBeats = false(1,length(oData(i).Rates));
    aTailBeats(aLastSlowBeat(i):end) = true;
    aBaroBeats = abs(oData(i).NormalisedRates) >= 5;
    aTailBeats = aTailBeats & aBaroBeats;
    iNewColourIndex = ceil((length(sColours)/length(aFiles))*i);
    if iColourIndex == iNewColourIndex
        strSymbol = '-';
    else
        strSymbol = '--';
    end
    plot(oAxes, oData(i).Times(oData(i).Peaks(1,aTailBeats))-oData(i).PeakTime, oData(i).NormalisedRates(aTailBeats), ...
        [sprintf('%s',sColours(iNewColourIndex)),sprintf('%s',strSymbol)], 'DisplayName', oData(i).Name);
    iColourIndex = iNewColourIndex;
    hold(oAxes, 'on');
    drawnow;
end
hold(oAxes, 'off');




