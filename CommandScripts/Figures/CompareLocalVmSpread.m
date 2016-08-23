%load data
% close all;
% sOpticalFileName = 'G:\PhD\Experiments\Auckland\InSituPrep\20140718\20140718baro001\baro001_3x3_1ms_7x_g10_LP100Hz-waveEach.mat';
% oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
oFig = ans;
oOptical = oFig.oGuiHandle.oOptical;

%% Fit an ellipse to first n contours
%get potential
oPotential = oOptical.PreparePotentialMap(100,oFig.SelectedBeat,oFig.SelectedEventID,[]);
%Create plot panel 
oFigure = figure();

aXlim = oOptical.oExperiment.Optical.AxisOffsets(1,1:2);
aYlim = oOptical.oExperiment.Optical.AxisOffsets(2,1:2);

%define axes 
oAxes = axes('parent',oFigure);

%put on overlay image
oOverlay = axes('position',get(oAxes,'position'));
sSchematicPath = strrep(oOptical.oExperiment.Optical.SchematicFilePath, '.bmp', '_highres.bmp');
oImage = imshow(sSchematicPath,'Parent', oOverlay, 'Border', 'tight');
aCData = get(oImage,'cdata');
aBlueData = aCData(:,:,3);
aAlphaData = aCData(:,:,3);
aAlphaData(aBlueData < 100) = 1;
aAlphaData(aBlueData > 100) = 1;
aAlphaData(aBlueData == 100) = 0;
aAlphaData = double(aAlphaData);
set(oImage,'alphadata',aAlphaData);
set(oOverlay,'box','off','color','none');
axis(oOverlay,'tight');
axis(oOverlay,'off');

aContourRange = [-0.1 1];
[aContours, h] = contourf(oAxes,oPotential.x(1,:),oPotential.y(:,1),oPotential.Beats(oFig.SelectedBeat).Fields(oFig.SelectedTimePoint).z,aContourRange(1):0.05:aContourRange(2));
axis(oAxes,'equal');
set(oAxes,'xlim',aXlim,'ylim',aYlim,'box','off','color','none');
axis(oAxes,'off');
caxis(oAxes,[aContourRange(1) aContourRange(2)]);
colormap(oAxes, colormap(jet));

%get the peak contour
[aLevels aPoints] = SplitContours(aContours);
[SortedLevels IX] = sort(aLevels);
%fit ellipse to contour
[z, a, b, alpha] = fitellipse(aPoints{IX(end-1)});
%plot major and minor axes for profiles
aProfile1 = zeros(2,15); %the major axis
aProfile2 = zeros(2,15); %the minor axis
%first point of the profile is the centre of mass of the ellipse
aProfile1(:,1) = z;
aProfile2(:,1) = z;
%initialise the variables that define the increment along each profile
multiplier = 0;
increment = 0.1;
for ii = 2:size(aProfile1,2);
    multiplier = multiplier + increment;
    if sign(alpha) > 0
        aProfile1(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(-pi/2);multiplier*sin(-pi/2)];
        aProfile2(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi);multiplier*sin(pi)];
    else
        aProfile1(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi);multiplier*sin(pi)];
        aProfile2(:,ii) = z+[cos(alpha),-sin(alpha);sin(alpha),cos(alpha)]*[multiplier*cos(pi/2);multiplier*sin(pi/2)];
    end
end
%plot these profiles
hold(oAxes,'on');
plot(oAxes,aProfile1(1,:),aProfile1(2,:),'k+');
plot(oAxes,aProfile2(1,:),aProfile2(2,:),'r+');
plotellipse(oAxes,z, a, b, alpha,'r--');
set(get(oAxes,'title'),'string',sprintf('Beat %d, frame %d',[oFig.SelectedBeat,oFig.SelectedTimePoint]));
%evaluate the field at these points
aInterpLine1 = oPotential.Beats(oFig.SelectedBeat).Fields(oFig.SelectedTimePoint).Interpolant(aProfile1(1,:),aProfile1(2,:));
aInterpLine2 = oPotential.Beats(oFig.SelectedBeat).Fields(oFig.SelectedTimePoint).Interpolant(aProfile2(1,:),aProfile2(2,:));
oFigure2 = figure();
oAxes2 = axes('parent',oFigure2);
plot(oAxes2,[1:size(aProfile1,2)]*norm(aProfile1(:,1)-aProfile1(:,2)),aInterpLine1,'k-');
hold(oAxes2,'on');
plot(oAxes2,[1:size(aProfile2,2)]*norm(aProfile2(:,1)-aProfile2(:,2)),aInterpLine2,'r-');
set(get(oAxes2,'title'),'string',sprintf('Beat %d, frame %d',[oFig.SelectedBeat,oFig.SelectedTimePoint]));
set(oAxes2,'ylim',[0 0.5]);




