function [oATFigure oATAxes] = PlotActivation(aActivationTimes,sBeatFileName,aPaceSettersToPlot,aLocationsToPlot,aPoints)
iMontageX = 1;
iMontageY = 1;
aActivationTimes = aActivationTimes(:,1:end-1);
[rowIndices colIndices] = find(aActivationTimes > 0);
aATPoints = aActivationTimes > 0;
AT = aActivationTimes(aATPoints);
AT(AT < 1) = NaN;
%normalise the ATs to first activation
[C I] = min(AT);
AT = single(AT - AT(I));
AT = double(AT);
dRes = 0.190;
dInterpDim = dRes/4;
x = dRes .* rowIndices;
y = dRes .* colIndices;
iMaxContour = 4;
%% Plot ATs
% %calculate the grid for plotting
[xx,yy]=meshgrid(min(x):dInterpDim:max(x),min(y):dInterpDim:max(y));
% % calculate the interpolation so as to produce the reshaped mesh vectors
F=TriScatteredInterp(x,y,AT);
QAT = F(xx,yy);
rQAT = reshape(QAT,[prod(size(QAT)),1]);
cbarmin = max(floor(min(rQAT)),0);
cbarmax = iMaxContour;
oATFigure = figure(); oATAxes = axes();
set(oATFigure,'paperunits','inches');
%Set figure size

dMontageWidth = 8.27 - 2; %in inches, with borders 
dMontageHeight = 11.69 - 2.5 - 1; %in inches, with borders and two lines for caption and space for the colour bar
dWidth = dMontageWidth/(iMontageX); %in inches
dHeight = dMontageHeight/iMontageY; %in inches
set(oATFigure,'paperposition',[0 0 dWidth dHeight])
set(oATFigure,'papersize',[dWidth dHeight])
set(oATAxes,'units','normalized');
set(oATAxes,'outerposition',[0 0 1 1]);
aTightInset = get(oATAxes, 'TightInset');
aPosition(1) = aTightInset(1)+0.05;
aPosition(2) = aTightInset(2);
aPosition(3) = 1-aTightInset(1)-aTightInset(3)-0.05;
aPosition(4) = 1 - aTightInset(2) - aTightInset(4)-0.05;
set(oATAxes, 'Position', aPosition);
cbarRange = floor(cbarmin):1:ceil(cbarmax);
contourf(oATAxes, xx,yy,QAT,1:iMaxContour);%cbarRange
caxis(oATAxes,[cbarmin cbarmax]);
colormap(oATAxes, colormap(flipud(colormap(jet))));
cbarf([cbarmin cbarmax], floor(cbarmin):1:ceil(cbarmax));
axis(oATAxes, 'equal');
set(oATAxes,'FontUnits','points');
set(oATAxes,'FontSize',6);
aYticks = str2num(get(oATAxes,'yticklabel'));
aYticks = aYticks - aYticks(1);
aYtickstring = cellstr(num2str(aYticks));
for i=1:length(aYticks)
    %Check if the label has a decimal place and hide this label
    if ~isempty(strfind(char(aYtickstring{i}),'.'))
        aYtickstring{i} = '';
    end
end
set(oATAxes,'xticklabel',[]);
set(oATAxes,'xtickmode','manual');
set(oATAxes,'yticklabel', char(aYtickstring));
set(oATAxes,'ytickmode','manual');
set(oATAxes,'Box','off');

%create beat label
%get beat number from name
[~, ~, ~, ~, ~, ~, splitStr] = regexp(sBeatFileName, '_');
[~, ~, ~, ~, ~, ~, splitStr] = regexp(char(splitStr{2}), '\.');
iLabelStartBeat = char(splitStr{1});
%aLabelPosition = [min(min(xx))+0.2, max(max(yy))-0.5];%for top left
aLabelPosition = [min(min(xx))+0.2, min(min(yy))+0.5];%for bottom left
oBeatLabel = text(aLabelPosition(1), aLabelPosition(2), iLabelStartBeat);
set(oBeatLabel,'units','normalized');
set(oBeatLabel,'fontsize',14,'fontweight','bold');
set(oBeatLabel,'parent',oATAxes);

%set axes title
[pathstr, name, ext, versn] = fileparts(sBeatFileName);
set(get(oATAxes,'title'),'string',strrep(name,'_','\_'));

%%overlay a plot with the updated points
oOverlayAxes = axes('parent',oATFigure);
xLocs = dRes .* aLocationsToPlot(1,:);
yLocs = dRes .* aLocationsToPlot(2,:);
xPaceLocs = dRes .* aPaceSettersToPlot(1,:);
yPaceLocs = dRes .* aPaceSettersToPlot(2,:);
% [row col] = find(aScatterPointsToPlot);
set(oOverlayAxes,'units','normalized');
set(oOverlayAxes,'outerposition',[0 0 1 1]);
set(oOverlayAxes, 'Position', get(oATAxes,'position'));
scatter(oOverlayAxes, xLocs, yLocs,'Marker','o','MarkerEdgeColor','k','MarkerFaceColor','k');
hold(oOverlayAxes,'on');
scatter(oOverlayAxes, xPaceLocs, yPaceLocs,'Marker','o','MarkerEdgeColor','r','MarkerFaceColor','r');
axis(oOverlayAxes, 'equal');axis(oOverlayAxes,[get(oATAxes,'xlim'),get(oATAxes,'ylim')]);
set(oOverlayAxes,'xticklabel',[]);
set(oOverlayAxes,'yticklabel', []);
set(oOverlayAxes,'Box','off');
set(oOverlayAxes,'color','none');
iPointIndices = find(aLocationsToPlot(3,:));
for i = 1:length(iPointIndices)
    oLabel = text(xLocs(iPointIndices(i)) - 0.2, yLocs(iPointIndices(i)) + 0.1, ...
        sprintf('%d%d',aLocationsToPlot(2,iPointIndices(i))-1,aLocationsToPlot(1,iPointIndices(i))-1));
    set(oLabel,'FontWeight','bold','FontUnits','normalized');
    set(oLabel,'FontSize',0.012);
    set(oLabel,'parent',oOverlayAxes);
end
end