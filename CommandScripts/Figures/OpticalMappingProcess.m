%This figure has four panels. Top left is an image of the right atrium with
%superimposed schematic and locations of recording points for panel B, as
%well as location of SAN activation map. Panel B shows recordings from
%central SAN and exit site superimposed. Bottom two panels show activation
%maps for SAN and atrial components.

close all;
clear all;
% % %open data
sBaseDir = 'G:\PhD\Experiments\Auckland\InSituPrep\20140723\';
sRecording = 'baro001';
sSubDir = [sBaseDir,sBaseDir(end-8:end-1),sRecording,'\'];

% % %% read in the optical entities
sAvOpticalFileName = [sSubDir,sRecording,'_3x3_1ms_7x_g10_LP100Hz-wave.mat'];
oAvOptical = GetOpticalFromMATFile(Optical,sAvOpticalFileName);
sOpticalFileName = [sSubDir,sRecording,'_3x3_1ms_7x_g10_LP100Hz-waveEach.mat'];
oOptical = GetOpticalFromMATFile(Optical,sOpticalFileName);
% % % read in the pressure entity
oPressure = GetPressureFromMATFile(Pressure,[sSubDir,'Pressure.mat'],'Optical');

dWidth = 12;
dHeight = 12;
sSavePath = 'D:\Users\jash042\Documents\PhD\Publications\2015\Paper1\Figures\OpticalMappingProcess.eps';

oFigure = figure();

%set up figure
set(oFigure,'color','white')
set(oFigure,'inverthardcopy','off')
set(oFigure,'PaperUnits','centimeters');
set(oFigure,'PaperPositionMode','manual');
set(oFigure,'Units','centimeters');
set(oFigure,'PaperSize',[dWidth dHeight],'PaperPosition',[0,0,dWidth,dHeight],'Position',[1,10,dWidth,dHeight]);
set(oFigure,'Resize','off');

%set up panel
oSubplotPanel = panel(oFigure,'no-manage-font');
oSubplotPanel.pack(2,2);

oSubplotPanel.margin = [2 2 2 2]; %left bottom right top
oSubplotPanel(1,1).margin = [0 0 0 0];
oSubplotPanel(1,2).margin = [0 0 0 0];
oSubplotPanel(2,1).margin = [0 0 0 0];
oSubplotPanel(2,2).margin = [0 0 0 0];
movegui(oFigure,'center');

%plot schematic
oAxes = oSubplotPanel(1,1).select();
imshow('D:\Users\jash042\Documents\DataLocal\Imaging\Prep\20140723\SchematicForFigure.png','Parent', oAxes, 'Border', 'tight');
set(oAxes,'box','off','color','none');
axis(oAxes,'tight');
axis(oAxes,'off');

%plot optical action potentials
oAxes = oSubplotPanel(1,2).select();
oAxes = oSubplotPanel(2,1).select();
oAxes = oSubplotPanel(2,2).select();

print(oFigure,'-dpsc','-r600',sSavePath)