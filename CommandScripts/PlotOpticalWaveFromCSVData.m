%Plots the rate change from a signal optical recording
clear all;
sFilePath = 'G:\PhD\Experiments\Bordeaux\Data\20131201\RA1201-122_refd_spatial3x3_cubic3x3_ROI1-wave.csv';

%open the file
fid = fopen(sFilePath,'r');
%scan the header information in
for i = 1:10;
    tline = fgets(fid);
     [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    switch (splitstring{1})
        case 'frm num'
            iNumFrames = str2double(splitstring{2});
    end
end
aData = zeros(iNumFrames,2);
%Get activation times
for i = 1:iNumFrames;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    aData(i,1) = str2double(splitstring{1});
    aData(i,2) = str2double(splitstring{2});
end
fclose(fid);
%Initialise a basesignal entity
oBaseSignal = BaseSignal();
aGradient = CalculateSlope(oBaseSignal,aData(:,2),5,3);
dThreshold = 0.1;
[aPeaks, aLocs] = GetPeaks(oBaseSignal,aGradient,dThreshold);
aPeaks = [aPeaks(1:end-1) ; aPeaks(2:end)];
aLocs = [aLocs(1:end-1) ; aLocs(2:end)];
aIntervals = aLocs(2,:) - aLocs(1,:);
aIdx = find(aIntervals > 150);
aIntervals = aIntervals(aIdx);
aPeaks = aPeaks(:,aIdx);
aLocs = aLocs(:,aIdx);
aIntervals = aIntervals / 1000;
aRates  = 60 ./aIntervals;
aRateData = NaN(1,size(aData,1));
%Loop through the peaks and insert into aRateTrace
for i = 1:size(aPeaks,2)
    aRateData(aLocs(1,i):aLocs(2,i)-2) = aRates(i);
end

figure();
oMainAxes = axes();
aTime = aData(:,1)/1000;
[oMainAxes oLine1 oLine2] = plotyy(oMainAxes,aTime,aData(:,2),aTime,aRateData);
set(get(oMainAxes(2),'Ylabel'),'String','Activation rate (bpm)');
set(oMainAxes(2),'ycolor','r','yminortick','on');
set(oLine2,'color','r','linewidth',4);
set(get(oMainAxes(1),'xlabel'),'string','Time (s)');
axis(oMainAxes(1),'tight');
axis(oMainAxes(2),'tight');
oYLim = get(oMainAxes(1),'ylim');
set(oMainAxes(1),'ylim',[oYLim(1) - 1, oYLim(2) + 1])
oYLim = get(oMainAxes(2),'ylim');
set(oMainAxes(2),'ylim',[oYLim(1) - 20, oYLim(2) + 20])
for k = 1:size(aLocs,2)
    oBeatLabel = text(aTime(aLocs(1,k),1),aRates(k)+10, num2str(k));
    set(oBeatLabel,'color','r','FontWeight','bold','FontUnits','normalized');
    set(oBeatLabel,'FontSize',0.02);
    set(oBeatLabel,'parent',oMainAxes(2));
end
