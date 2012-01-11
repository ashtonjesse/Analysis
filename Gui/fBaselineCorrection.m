function fBaselineCorrection

global DATA

baseMean=figure('Visible','on',...
    'units','pixels','position',[360 50 1295 1000],...
    'tag','ssfig','name','SelectSingle',...
    'menubar','none','numbertitle','off',...
    'Color',[.95 .99 .95]);

origa = axes('units','pixels','position',[60 700 1000 250],'nextplot','replacechildren',...
    'tag','origa','Box','on'); title('Original Signal')
set(origa,'units','normalized');

baseMeanfix = axes('units','pixels','position',[60 375 1000 250],'nextplot','replacechildren',...
    'tag','baseMeanfix','Box','on'); title('Baseline and Mean of Original Signal');
set(baseMeanfix,'units','normalized');

correctedOrig = axes('units','pixels','position',[60 50 1000 250],'nextplot','replacechildren',...
    'tag','correctedOrig','Box','on');
set(correctedOrig,'units','normalized');title('Corrected Original');

popbaseline = uicontrol('style','popupmenu','units','pixels','position',[1080 300 200 200],...
    'string',{'1','2','3','4','5','6','7','8','9','10','11','12','13','14'},...
    'tag','popbaseline',...
    'callback',@baselinepoly,'FontSize',14);

applytoDATA = uicontrol('style','pushbutton','units','pixels','position',[1080 70 200 200],...
    'string','Apply to Data. ',...
    'tag','applytoDATA',...
    'callback',@applytodata,'FontSize',14);

h2menu=uimenu('Label','File');
uimenu(h2menu,'label','Exit','callback',@closeme,'separator','on');


set(origa,'UserData',[]);
singleval = 222;
set(origa,'UserData',singleval);

axes(origa)
plot(DATA.Unemap.Time,DATA.Unemap.Pot.Orig(:,singleval),'k')
oaxis = axis;
axes(baseMeanfix);
cla;
axis(oaxis);

if(DATA.Unemap.Pot.Orig)
    % plot(DATA.Unemap.Time,DATA.Unemap.Pot.Baseline(:,singleval),'r');
    tit = sprintf('Baseline Poly Order: %d',DATA.Unemap.Pot.DoBaseline);
    title(tit);
    hold on;
    plot(DATA.Unemap.Time,DATA.Unemap.Pot.Orig(:,singleval),'k')
else


end
axes(correctedOrig);
cla;
axis(oaxis);
if(DATA.Unemap.Pot.DoBaseline)
    plot(DATA.Unemap.Time,DATA.Unemap.Pot.OrigBase(:,singleval),'k');
    tit = sprintf('Existing Baseline Corrected Signal');
    title(tit);
end


function baselinepoly(handles,src,event)
global DATA
temph = findobj('tag','origa');
singlevalue = get(temph,'UserData');
order = get(handles,'Value');

origaxes = findobj('tag','origa');
axes(origaxes);
origaxis = axis;

[baseline] = ana_fitEval(order,singlevalue);


basefixaxes = findobj('tag','baseMeanfix');
axes(basefixaxes);
cla;
plot(DATA.Unemap.Time,baseline,'k'); hold on;
axes(basefixaxes); title('Wait for me to finish thinking');

correctedH = findobj('tag','correctedOrig');


nobaseline = DATA.Unemap.Pot.Orig(:,singlevalue)-baseline;
nomean = nobaseline - mean(nobaseline);
sprintf('Baseline Poly Order: %d',order);
axis(origaxis);
axes(correctedH); cla
plot(DATA.Unemap.Time,nomean,'k');
axis(origaxis);
title('Baseline Corrected Signal');

function applytodata(handles,src,event)
global DATA
h = waitbar(0,'Please wait...');
DATA.Unemap.Pot.OrigBase = zeros(size(DATA.Unemap.Pot.Orig,1),DATA.Unemap.Info.numelectrodes)
for k = 1:DATA.Unemap.Info.numelectrodes
    %   showme = sprintf('%d of %d', k,DATA.Unemap.Info.numelectrodes);
    %   set(handles,'String',showme);

    orderH = findobj('tag','popbaseline');
    order = get(orderH,'Value');
    baseline = ana_fitEval(order, k);
    nobaseline = DATA.Unemap.Pot.Orig(:,k)-baseline;
    nomean = nobaseline - mean(nobaseline);

    %   DATA.Unemap.Pot.Baseline(:,k) = baseline;
    DATA.Unemap.Pot.DoBaseline = order;
    DATA.Unemap.Pot.OrigBase(:,k) = nomean;
    waitbar(k/DATA.Unemap.Info.numelectrodes,h);
end
close(h)

DATA.Unemap.Pot.Orig = [];
DATA.Unemap.Pot.Baseline = date;

function closeme(handles,src,event)
DATA.Unemap.Pot.Orig = [];
DATA.Unemap.Pot.Baseline = date;
closereq;
























