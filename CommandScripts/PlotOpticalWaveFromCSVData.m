function PlotOpticalWaveFormFromCSV()
%Plots the rate change from a signal optical recording
clear all;
close all;
sFilePath = 'G:\PhD\Experiments\Auckland\InSituPrep\20140526\test001-wave.csv';

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
aData1 = zeros(iNumFrames,2);
%Get activation times
for i = 1:iNumFrames;
    tline = fgets(fid);
    [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
    aData1(i,1) = str2double(splitstring{1});
    aData1(i,2) = str2double(splitstring{2});
end
fclose(fid);

figure();
oMainAxes = axes();
aTime = aData(:,1)/1000;
plot(oMainAxes,aTime,aData(:,2));
set(get(oMainAxes,'xlabel'),'string','Time (s)');
axis(oMainAxes,'tight');

oYLim = get(oMainAxes,'ylim');
set(oMainAxes,'ylim',[oYLim(1) - 1, oYLim(2) + 1])

function aData = ReadData(sFilePath)

