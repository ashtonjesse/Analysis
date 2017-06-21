function Overlay(oAxes,sPath)
%put on overlay image
oOverlay = axes('position',get(oAxes,'position'));
sSchematicPath = strrep(sPath, '.bmp', '_highres.bmp');
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
end