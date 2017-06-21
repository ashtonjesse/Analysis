%load data
% close all;
% sOpticalFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat';
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
oFig = ans;
oOptical = oFig.oGuiHandle.oOptical;

%Create plot panel 
oFigure = figure();
dWidth = 24;
dHeight = 8;
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');
%set up panel
xrange = 1;
yrange = 3;
oSubplotPanel = panel(oFigure);
oSubplotPanel.pack();
oSubplotPanel(1).pack(xrange,yrange);
movegui(oFigure,'center');
oSubplotPanel.margin = [2 10 5 5];
oSubplotPanel(1).margin = [10 0 0 0];
oSubplotPanel(1).fontsize = 8;
oSubplotPanel(1).fontweight = 'normal';

aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);

%get potential
iBeat1 = 29;
iBeat2 = 30;
iTime1 = 32;
iTime2 = 21;
oPotential1 = oOptical.PreparePotentialMap(100,iBeat1,oFig.SelectedEventID,[]);
oPotential2 = oOptical.PreparePotentialMap(100,iBeat2,oFig.SelectedEventID,[]);

%define axes 
oAxes1 = oSubplotPanel(1,1,1).select();
Overlay(oAxes1,oOptical.oExperiment.Optical.SchematicFilePath);
aContourRange = [-0.1 1];
[aContours1, h] = contourf(oAxes1,oPotential1.x(1,:),oPotential1.y(:,1),oPotential1.Beats(iBeat1).Fields(iTime1).z,aContourRange(1):0.05:aContourRange(2));
axis(oAxes1,'equal');
set(oAxes1,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes1,'off');
caxis(oAxes1,[aContourRange(1) aContourRange(2)]);
colormap(oAxes1, colormap(jet));
% %get the peak contour
[aLevels1 aPoints1] = SplitContours(aContours1);
[SortedLevels1 IX1] = sort(aLevels1);
% %  get area of peak contour
if ~isnan(aPoints1{IX1(end)}(1,1))
    Area1 = polyarea(aPoints1{IX1(end)}(1,:),aPoints1{IX1(end)}(2,:));
    Centroid1 = transpose(polygonCentroid(aPoints1{IX1(end)}'));
    %     Inc1 = 3;
else
    Area1 = polyarea(aPoints1{IX1(end-1)}(1,:),aPoints1{IX1(end-1)}(2,:));
    Centroid1 = transpose(polygonCentroid(aPoints1{IX1(end-1)}'));
    %     Inc1 = 3;
end

%define axes
oAxes2 = oSubplotPanel(1,1,2).select();
Overlay(oAxes2,oOptical.oExperiment.Optical.SchematicFilePath);
[aContours2, h] = contourf(oAxes2,oPotential2.x(1,:),oPotential2.y(:,1),oPotential2.Beats(iBeat2).Fields(iTime2).z,aContourRange(1):0.05:aContourRange(2));
axis(oAxes2,'equal');
set(oAxes2,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes2,'off');
caxis(oAxes2,[aContourRange(1) aContourRange(2)]);
colormap(oAxes2, colormap(jet));
% %get the peak contour
[aLevels2 aPoints2] = SplitContours(aContours2);
[SortedLevels2 IX2] = sort(aLevels2);
% %  get area of peak contour
if ~isnan(aPoints2{IX2(end)}(1,1))
    Area2 = polyarea(aPoints2{IX2(end)}(1,:),aPoints2{IX2(end)}(2,:));
    Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end)}'));
    %     Inc2 = 3;
else
    Area2 = polyarea(aPoints2{IX2(end-1)}(1,:),aPoints2{IX2(end-1)}(2,:));
    Centroid2 = transpose(polygonCentroid(aPoints2{IX2(end-1)}'));
    %     Inc2 = 3;
end

if abs(SortedLevels1(end)-SortedLevels2(end)) < 0.001
    %the peak levels are the same so should check areas
else
    %subsample data from 1
    delVm = oPotential2.Beats(iBeat2).Fields(iTime2+1).Vm' - oPotential2.Beats(iBeat2).Fields(iTime2).Vm';
    delT = oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat2,1)+iTime2)-oOptical.TimeSeries(oOptical.Beats.Indexes(iBeat2,1)+iTime2-1);
    NSubSamples = 10;
    aNewFields = cell(NSubSamples,1);
    for ii = 1:NSubSamples
        newVm = delVm.*((ii*delT/NSubSamples)/delT) + oPotential2.Beats(iBeat2).Fields(iTime2).Vm';
        oInterpolant = TriScatteredInterp(oPotential2.DT,newVm);
        oInterpolatedField = oInterpolant(oPotential2.x,oPotential2.y);
        %rearrange to be able to apply boundary
        aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
        %apply boundary
        aQZArray(~oPotential2.Boundary) = NaN;
        %save result back in proper format
        aNewFields{ii}  = reshape(aQZArray,size(oPotential2.x,1),size(oPotential2.x,2));
        [aContours2, h] = contourf(oAxes2,oPotential2.x(1,:),oPotential2.y(:,1),aNewFields{ii},aContourRange(1):0.05:aContourRange(2));
        % %get the peak contour
        [aLevels2 aPoints2] = SplitContours(aContours2);
        [SortedLevels2 IX2] = sort(aLevels2);
        % %  get area of peak contour
        if ~isnan(aPoints2{IX2(end)}(1,1))
            if abs(SortedLevels1(end)-SortedLevels2(end)) < 0.001
                Area2 = polyarea(aPoints2{IX2(end)}(1,:),aPoints2{IX2(end)}(2,:));
                if Area2 > Area1
                    break;
                end
            end
        else
            if abs(SortedLevels1(end)-SortedLevels2(end-1)) < 0.001
                Area2 = polyarea(aPoints2{IX2(end-1)}(1,:),aPoints2{IX2(end-1)}(2,:));
                if Area2 > Area1
                    break;
                end
            end
        end
    end
end
aProfile11 = zeros(2,12); 
aProfile12 = zeros(2,12); 
aProfile21 = zeros(2,12); 
aProfile22 = zeros(2,12); 
%first point of the profile is the centre of mass of the peak contour
aProfile11(:,1) = Centroid1;
aProfile12(:,1) = Centroid2;
aProfile21(:,1) = Centroid1;
aProfile22(:,1) = Centroid2;
%initialise the variables that define the increment along each profile
multiplier = 0;
increment = 0.1;
EndPoint1 = [2.4;6];
EndPoint2 = [0.4;3.8];
Length11 = norm(EndPoint1-Centroid1);
Length12 = norm(EndPoint1-Centroid2);
Length21 = norm(EndPoint2-Centroid1);
Length22 = norm(EndPoint2-Centroid2);
theta11 = -(pi - asin((EndPoint1(1) - Centroid1(1)) / Length11));
theta12 = -(pi - asin((EndPoint1(1) - Centroid2(1)) / Length12));
theta21 = (pi - asin((EndPoint2(1) - Centroid1(1)) / Length21));
theta22 = (pi - asin((EndPoint2(1) - Centroid2(1)) / Length22));
for ii = 2:size(aProfile11,2);
    multiplier = multiplier + increment;
    aProfile11(:,ii) = Centroid1 - multiplier*Length11*[sin(theta11); cos(theta11)];
    aProfile12(:,ii) = Centroid2 - multiplier*Length12*[sin(theta12); cos(theta12)];
    aProfile21(:,ii) = Centroid1 + multiplier*Length21*[sin(theta21); cos(theta21)];
    aProfile22(:,ii) = Centroid2 + multiplier*Length22*[sin(theta22); cos(theta22)];
end

%plot these profiles
hold(oAxes1,'on');
plot(oAxes1,aProfile11(1,:),aProfile11(2,:),'ko','MarkerSize',2);
plot(oAxes1,aProfile21(1,:),aProfile21(2,:),'ro','MarkerSize',2);
% plotellipse(oAxes1,z, a, b, alpha,'r--');
set(get(oAxes1,'title'),'string',sprintf('Beat %d, frame %d',[iBeat1,iTime1]));
%evaluate the field at these points
aInterpLine1 = oPotential1.Beats(iBeat1).Fields(iTime1).Interpolant(aProfile11(1,:),aProfile11(2,:));
aInterpLine2 = oPotential1.Beats(iBeat1).Fields(iTime1).Interpolant(aProfile21(1,:),aProfile21(2,:));

oAxes3 = oSubplotPanel(1,1,3).select();
plot(oAxes3,[1:size(aProfile11,2)]*norm(aProfile11(:,1)-aProfile11(:,2)),aInterpLine1,'k-');
hold(oAxes3,'on');
plot(oAxes3,[1:size(aProfile21,2)]*norm(aProfile21(:,1)-aProfile21(:,2)),aInterpLine2,'r-');
% set(get(oAxes2,'title'),'string',sprintf('Beat %d, frame %d',[oFig.SelectedBeat,oFig.SelectedTimePoint]));
set(oAxes3,'ylim',[0 0.7]);

%% 

%plot these profiles
hold(oAxes2,'on');
plot(oAxes2,aProfile12(1,:),aProfile12(2,:),'ko','MarkerSize',2);
plot(oAxes2,aProfile22(1,:),aProfile22(2,:),'ro','MarkerSize',2);
% plotellipse(oAxes2,z, a, b, alpha,'r--');
set(get(oAxes2,'title'),'string',sprintf('Beat %d, frame %d + %6.6f s',[iBeat2,iTime2,ii*delT/NSubSamples]));
%evaluate the field at these points
aInterpLine1 = oInterpolant(aProfile12(1,:),aProfile12(2,:));
aInterpLine2 = oInterpolant(aProfile22(1,:),aProfile22(2,:));

plot(oAxes3,[1:size(aProfile12,2)]*norm(aProfile12(:,1)-aProfile12(:,2)),aInterpLine1,'k--');
hold(oAxes3,'on');
plot(oAxes3,[1:size(aProfile22,2)]*norm(aProfile22(:,1)-aProfile22(:,2)),aInterpLine2,'r--');
% set(get(oAxes2,'title'),'string',sprintf('Beat %d, frame %d',[oFig.SelectedBeat,oFig.SelectedTimePoint]));
set(oAxes3,'ylim',[0 0.7]);
set(get(oAxes3,'ylabel'),'string','Normalised F.I.');
set(get(oAxes3,'xlabel'),'string','Distance (mm)');
sFileSavePath = 'D:\Users\jash042\Documents\PhD\Thesis\Figures\CompareVm_2';
print(oFigure,'-dbmp','-r600',[sFileSavePath,'.bmp'])

%% fit ellipse to contour1
% [z, a, b, alpha] = fitellipse(aPoints1{IX1(end-Inc1)});
% %plot major and minor axes for profiles
% aProfile1 = zeros(2,15); %the major axis
% aProfile2 = zeros(2,15); %the minor axis
% %first point of the profile is the centre of mass of the ellipse
% aProfile1(:,1) = z;
% aProfile2(:,1) = z;
% %initialise the variables that define the increment along each profile
% multiplier = 0;
% increment = 0.1;
% for ii = 2:size(aProfile1,2);
%     multiplier = multiplier + increment;
%     if sign(alpha) > 0
%         aProfile1(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(-pi/2);multiplier*sin(-pi/2)];
%         aProfile2(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi);multiplier*sin(pi)];
%     else
%         aProfile1(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi);multiplier*sin(pi)];
%         aProfile2(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi/2);multiplier*sin(pi/2)];
%     end
% end