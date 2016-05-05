%read data in from CSV
close all;
clear all;

[aHeader aData] = ReadCSV('F:\Data\Week3\Monday\CaData.csv');
aTime = aData(:,1);
oFigure=figure();
oAxes = axes();

% Dvec = fCalculateMovingSlope(aData(:,2),5,3,0.047);
% Dvec = fCalculateMovingSlope(Dvec,5,3,0.047);
plot(aTime,aData(:,2));
% hold(oAxes,'on');
% plot(aTime,Dvec);
% [pks,locs] = findpeaks(Dvec,'THRESHOLD',500);
% hold(oAxes,'on');
% plot(aTime(locs),pks,'g+');
