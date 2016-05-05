close all;
sFiles = {...
'G:\PhD\Experiments\Auckland\InSituPrep\20140526\test001-wave.csv' ...    
'G:\PhD\Experiments\Auckland\InSituPrep\20140526\test002-wave.csv' ...
};
figure();
oMainAxes = axes();
oOverlay = axes();
% aData = cell(numel(sFiles),1);
aRange = [0.7591 0.9606; 1.568 1.748];
for i = 1:numel(sFiles)
%     %open the file
%     fid = fopen(sFiles{i},'r');
%     %scan the header information in
%     for j = 1:10;
%         tline = fgets(fid);
%         [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
%         switch (splitstring{1})
%             case 'frm num'
%                 iNumFrames = str2double(splitstring{2});
%         end
%     end
%     aData{i} = zeros(iNumFrames,2);
%     %Get activation times
%     for j = 1:iNumFrames;
%         tline = fgets(fid);
%         [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
%         aData{i}(j,1) = str2double(splitstring{1});
%         aData{i}(j,2) = str2double(splitstring{2});
%     end
%     fclose(fid);
    
    aTime = aData{i}(:,1)/466.37;
    aPoints = aTime > aRange(i,1) & aTime < aRange(i,2);
    plot(oMainAxes,aTime(aPoints)-aTime(find(aPoints,1,'first')),aData{i}(aPoints,2));
    set(get(oMainAxes,'xlabel'),'string','Time (s)');
    axis(oMainAxes,'tight');
    
    oYLim = get(oMainAxes,'ylim');
    set(oMainAxes,'ylim',[oYLim(1) - 1, oYLim(2) + 1])
hold(oMainAxes,'on');
end




