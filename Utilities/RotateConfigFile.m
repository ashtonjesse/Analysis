%Read in electrode details from config file
%get the location of the corresponding new position
%switch the positions and locations
%write out and save to new file
clear all;
%get a unemap entity
oUnemap = Unemap();
%get the electrodes from this config file
sFileName = 'D:\Users\jash042\Documents\PhD\Analysis\Database\Array_20130429_layout_locations.cnfg';
oElectrodes = oUnemap.oDAL.GetElectrodesFromConfigFile(288, sFileName, 0);
% % % %get coords and locations
aCoords = cell2mat({oElectrodes(:).Coords});
aLocations = cell2mat({oElectrodes(:).Location});
%Carry out first transpose so now 16 rows and 18 columns
aNewCoords = [aCoords(2,:) ; aCoords(1,:)]';
aNewLocs = [aLocations(2,:) ; aLocations(1,:)]';
aCoords = aCoords';
aLocations = aLocations';
iMaxIndex = max(aNewLocs(:,2));
%Loop through the array rows
for i = 1:iMaxIndex
    %switch the rows so 1st row = last row etc
    aThisCol = find(aNewLocs(:,2) == i);
    aNewLocs(aThisCol,:) = flipud(aNewLocs(aThisCol,:));
    aNewCoords(aThisCol,:) = flipud(aNewCoords(aThisCol,:));
end
aNewCoords = aNewCoords';
aNewLocs = aNewLocs';
%switch the x and y coords and locations
aNewCoords = num2cell([aNewCoords(1,:) ; aNewCoords(2,:)]',2);
aNewLocs = num2cell([aNewLocs(1,:) ; aNewLocs(2,:)]',2);


[oElectrodes(:).Coords] = deal(aNewCoords{:});
[oElectrodes(:).Location] = deal(aNewLocs{:});




%Make sure the current figure is MapElectrodes
oFigure = figure(); oAxes = axes();

%Get the number of channels
[i NumChannels] = size(oElectrodes);
%Loop through the electrodes plotting their locations
%              oWaitbar = waitbar(0,'Please wait...');
hold(oAxes,'on');
for i = 1:NumChannels;
    %Plot the electrode point
    %Just plotting the electrodes so add a text label
    plot(oAxes, oElectrodes(i).Coords(1), oElectrodes(i).Coords(2), 'k.', ...
        'MarkerSize',12);
    %Label the point with the channel name
    oLabel = text(oElectrodes(i).Coords(1) - 0.1, oElectrodes(i).Coords(2) + 0.07, ...
        oElectrodes(i).Name);
    set(oLabel,'FontWeight','bold','FontUnits','normalized');
    set(oLabel,'FontSize',0.015);
    set(oLabel,'parent',oAxes);
end
axis(oAxes,'tight');axis(oAxes,'equal');
hold(oAxes,'off');
