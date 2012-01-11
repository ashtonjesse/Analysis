function fActivationTimeAnalysis

global DATA
global GEO
global F
global NUM


%main figure!


mainfig=figure('Visible','on',...
    'units','pixels','position',[438 7 1470 1102],'Color',[1 1 1],......
    'tag','GUIp','name','ManyPot',...
    'menubar','none','numbertitle','off','toolbar','figure');

numberofranges = size(DATA.Unemap.Analysis,2); runningstr = '';
for k = 1:numberofranges
    tempstr = sprintf('%d|',k);
    runningstr = strcat(runningstr,tempstr);
end
runningstr = substr(runningstr,0,-1);
rangepoph = uicontrol('style','popupmenu','units','pixels','position',[1400 1050 50 50],'tag','rangepop','BackgroundColor',[.9 1 1],...
    'string',runningstr,'fontsize',15,'fontweight','bold','callback',@doRange);
textrange = uicontrol('style','text','string','Chose Range','units','pixels','position',[1200 1061 200 39],'fontsize',18,'fontweight','bold',...
    'Background',[ .9 1 1]);
set(rangepoph,'units','normalized'); set(textrange,'units','normalized');

NUM = get(rangepoph,'Value');

F.ut(1) = DATA.Unemap.Analysis{NUM}.Range.Time(1);
F.ut(2) = DATA.Unemap.Analysis{NUM}.Range.Time(2);
if(size(DATA.Unemap.Analysis{NUM}.Range.Index,1))
    F.ui(1) = DATA.Unemap.Analysis{NUM}.Range.Index(1);
    F.ui(2) = DATA.Unemap.Analysis{NUM}.Range.Index(2);
else
    F.ui(1) = DATA.Unemap.Info.Frequency;
    F.ui(2) = DATA.Unemap.Info.Frequency*2;
end


%closeup of selected figure
zoomFig=figure('Visible','on',...
    'units','pixels','position',[6 400 460 600],...
    'tag','Zoomfig', 'name','Zoom Figure',...
    'menubar','none','numbertitle','on','toolbar','figure');
set(zoomFig,'units','normalized');

[zoomAs p s] = plotyy([1 1],[200 300],[1.2 1.4],[100 500]);
zoomA = zoomAs(1);
set(zoomA,'units','pixels','position',[30 80 400 400],'nextplot','replacechildren','Box','on');
set(zoomA,'tag','ZoomAxes','units','normalized');
set(zoomAs(2),'tag','ZoomAxes2');

%2D location of needles
needlocFig=figure('Visible','off',...
    'units','pixels','position',[6 48 420 500],...
    'tag','BigPot', 'name','BigPot',...
    'menubar','none','numbertitle','on');
needlocA = axes('units','pixels','position',[6 80 400 400],'nextplot','replacechildren','XTickLabel',[],'Xtick',[],'YTickLabel',[],'Box','on');
set(needlocA,'tag','BigAxes','units','normalized');
figure(mainfig);

hmenu=uimenu('Label','File');
uimenu(hmenu,'label','Open Exp','callback',@loadfile)
uimenu(hmenu,'label','Save New Activation Times','callback','GUIp loadfile')
uimenu(hmenu,'label','Exit','callback','closereq','separator','on');
hmenu=uimenu('Label','Geometry');
uimenu(hmenu,'label','Geometry Interface','callback',@geometryMother)
uimenu(hmenu,'label','Rendered Geometry Interface','callback',@geometryMother2)
hmenu=uimenu('Label','Ensite');
uimenu(hmenu,'label','Ensite Interface','callback',@doEnsiteonly)
hmenu=uimenu('Label','Global');
uimenu(hmenu,'label','Total Activation','callback',@doGlobalTotalAct)



leftS = 30; topS = 1000; hS = 68; wS = 230; %(left start, topstart, height, width)
for kk = 1:5
    for k = 1:15
        vectorIndex = (kk-1)*15+k;
        vectorIndexTag = sprintf('axes%d',vectorIndex);
        % = num2str(vectorIndex);
        axesHandle(kk,k)=axes('units','pixels','position',[leftS+((kk-1)*wS) topS-((k-1)*hS) wS hS],...
            'nextplot','replacechildren','ButtonDownFcn',@doZfig,'XTickLabel',[],'Xtick',[],'YTickLabel',[],'Box','on');
        set(axesHandle(kk,k),'tag',vectorIndexTag);
        set(axesHandle(kk,k),'units','normalized');
    end
end

plotManySignals(1,0)

% Move the GUI to the center of the screen.
movegui(mainfig,'northeast');

%Features to the right of Many Axes Group MAG
cliplisttext = uicontrol('style','text',...
    'units','pixels','pos',[1230 1150-180 200 50],...
    'string','Clip Select',...
    'tag','cliplisttext',...
    'background',[1 1 1],...
    'FontSize',16,'fontweight','bold');
cliplist = uicontrol('style','popupmenu',...
    'units','pixels','pos',[1230 1000-102 200 90],...
    'string',{'Clip 1','Clip 2','Clip 3','Clip 4','Clip 5'},...
    'tag','cliplist',...
    'background',[0 1 1],...
    'callback',@doclipplot,'FontSize',16);
set(cliplist,'units','normalized');

frameAct = uicontrol('style','frame','units','pixels','pos',[1190 850-800 280 140],...
    'Background',[0.2 0.6 0.7]);

slopeWlist = uicontrol('style','popupmenu',...
    'units','pixels','pos',[1200 875-800 120 80],'Background',[1 1 1],...
    'string',{'3','4','5','6','7','8','9','10','11'},...
    'tag','slopeWlist',...
    'FontSize',12);
slopeMlist = uicontrol('style','popupmenu',...
    'units','pixels','pos',[1345 875-800 120 80],'Background',[1 1 1],...
    'string',{'1','2','3','4','5'},...
    'tag','slopeMlist',...
    'FontSize',12);
slopelisttext = uicontrol('style','text',...
    'units','pixels','pos',[1200 960-800 120 25],'Background',[1 1 1],...
    'string','Slope Win',...
    'tag','slopelisttext',...
    'FontSize',12);
slopelisttext2 = uicontrol('style','text','Background',[1 1 1],...
    'units','pixels','pos',[1345 960-800 120 25],...
    'string','Win Degree',...
    'tag','slopelisttext2',...
    'FontSize',12);

autoslopePush = uicontrol('style','pushbutton','Background',[1 1 1],...
    'units','pixels','pos',[1200 855-800 265 50],...
    'string','Apply Slope',...
    'tag','autoslopePush','callback',@autoslope,...
    'FontSize',12);

set(slopeWlist,'units','normalized');set(autoslopePush,'units','normalized');
set(slopeMlist,'units','normalized'); set(slopelisttext,'units','normalized');
set(slopelisttext2,'units','normalized');set(frameAct,'units','normalized')

slopethresh = uicontrol('style','edit','Background',[1 1 1],...
    'units','pixels','pos',[1200 210 265 50],...
    'string','0.98',...
    'tag','slopethresh',...
    'FontSize',12);
markslope = uicontrol('style','pushbutton','Background',[0 .9 .7],...
    'units','pixels','pos',[1200 260 265 50],...
    'string','Mark Slope Threshold',...
    'tag','markslope','callback',@automarkslope,...
    'FontSize',12,'UserData',slopethresh);
set(slopethresh,'units','normalized'); set(markslope,'units','normalized');

if(size(DATA.Unemap.Analysis{NUM}.Slope.Parameters))
    slopepara = DATA.Unemap.Analysis{NUM}.Slope.Parameters
    set(slopeWlist,'Value',slopepara(1)-2);
    set(slopeMlist,'Value',slopepara(2));
end
end

function autoslope(handle,src,event)
global DATA

global NUM

answer = questdlg('This will remove existing slope information! Do you wish to continue?','','Yes','No','Yes');
if strcmp(answer,'Yes')

    % reset all fields associated with slope: slope vals, and all peak marking
    % information
    DATA.Unemap.Analysis{NUM}.Slope.Vals = [];
    DATA.Unemap.Analysis{NUM}.peaks.loc = [];
    DATA.Unemap.Analysis{NUM}.peaks.nopeaks = [];
    DATA.Unemap.Analysis{NUM}.peaks.val = [];
    DATA.Unemap.Analysis{NUM}.peaks.info = [];

    movingwindow = get(findobj('tag','slopeWlist'),'Value');
    movingwindow = movingwindow+2;
    modDegree = get(findobj('tag','slopeMlist'),'Value');

    if((min(10,movingwindow-modDegree) < 1) || (modDegree > min(10,movingwindow-1)))
        errordlg('Size of moving window does not the order of the fit. Changing order to one',...
            'Error in Order');
        set(findobj('tag','slopeMlist'),'Value','1');
        modDegree = 1;
    end
    DATA.Unemap.Analysis{NUM}.Slope.Parameters = [movingwindow modDegree];
    set(findobj('tag','slopeWlist'),'Value',movingwindow-2); %change value of slope doing options
    set(findobj('tag','slopeMlist'),'Value',modDegree);
    h = waitbar(0,'Please wait while calculating slopes...');
    for k = 1:DATA.Unemap.Info.numelectrodes
        slopes = ana_movingslope(DATA.Unemap.Pot.OrigBase(DATA.Unemap.Analysis{NUM}.Range.Index(1):...
            DATA.Unemap.Analysis{NUM}.Range.Index(2),k),movingwindow,modDegree);
        DATA.Unemap.Analysis{NUM}.Slope.Vals(:,k) = slopes;
        waitbar(k/DATA.Unemap.Info.numelectrodes,h);
    end
    close(h);
    clipnumtoplot = get(findobj('tag','cliplist'),'Value');
    plotManySignals(clipnumtoplot,handle);
else
end

end

function automarkslope(handle,src,event)
global DATA
global NUM
global F

%reset peak fields
DATA.Unemap.Analysis{NUM}.peaks.loc = [];
DATA.Unemap.Analysis{NUM}.peaks.val = [];
DATA.Unemap.Analysis{NUM}.peaks.nopeaks = [];
DATA.Unemap.Analysis{NUM}.peaks.info = [];

answer = questdlg('Really mark slope at THAT threshold? Existing DATA will be lost!','','Yes','No','Yes');
if strcmp(answer,'Yes')
    stringthresh = get(get(handle,'UserData'),'String');
    thresh = str2double(stringthresh);
    h = waitbar(0,'Please wait while marking the steeper slopes...');
    count = 1;
    for k = 1:DATA.Unemap.Info.numelectrodes
        slopes = DATA.Unemap.Analysis{NUM}.Slope.Vals(:,k).*-1 ; %negative one becuase this is Activation
        %         if k == 211
        %             disp 'hold';
        %         end
        %         if k == 212
        %             disp('hold');
        %         end

        if(find(DATA.Unemap.Info.BadElectrodes == k))
            DATA.Unemap.Analysis{NUM}.peaks.val(1:length(pks),k) = -1;
            DATA.Unemap.Analysis{NUM}.peaks.loc(1:length(loc),k) = -1;
            DATA.Unemap.Analysis{NUM}.peaks.nopeaks(count) = k;
        else

            [pks loc] = findpeaks(slopes,'minpeakheight',thresh,'sortstr','descend');
            %     [pks loc] = findpeaks(slopes,'minpeakheight',thresh,'sortstr','descend');
            if (size(pks) == 0)
                DATA.Unemap.Analysis{NUM}.peaks.val(1:length(pks),k) = -1;
                DATA.Unemap.Analysis{NUM}.peaks.loc(1:length(loc),k) = -1;
                DATA.Unemap.Analysis{NUM}.peaks.nopeaks(count) = k;
                count = count +1;
            elseif (ismember(k,DATA.Unemap.Info.BadElectrodes))
                DATA.Unemap.Analysis{NUM}.peaks.val(1:length(pks),k) = -1;
                DATA.Unemap.Analysis{NUM}.peaks.loc(1:length(loc),k) = -1;
                DATA.Unemap.Analysis{NUM}.peaks.nopeaks(count) = k;
                count = count +1;
            else
                DATA.Unemap.Analysis{NUM}.peaks.val(1:length(pks),k) = pks;
                DATA.Unemap.Analysis{NUM}.peaks.loc(1:length(loc),k) = loc;

            end

            waitbar(k/DATA.Unemap.Info.numelectrodes,h);
        end
    end


    count = 1;
    for k = 1:DATA.Unemap.Info.numelectrodes
        if(DATA.Unemap.Analysis{NUM}.peaks.loc(1,k))
            markedLoc(count,1) = DATA.Unemap.Analysis{NUM}.peaks.loc(1,k);
            count = count +1;
        end
    end
    [orderedIndexTime,orderedElectrodes] = sort(markedLoc,1,'ascend');
    orderedRankTime = orderedIndexTime;
    orderedRankTime = orderedRankTime-min(orderedRankTime)+1;



    close(h);
    DATA.Unemap.Analysis{NUM}.peaks.info = thresh;
    DATA.Unemap.Analysis{NUM}.peaks.main.indexTime = orderedIndexTime;
    DATA.Unemap.Analysis{NUM}.peaks.main.rankTime = orderedRankTime;
    DATA.Unemap.Analysis{NUM}.peaks.main.order = orderedElectrodes;
    clipnumtoplot = get(findobj('tag','cliplist'),'Value');
    plotManySignals(clipnumtoplot,handle);
else

end
end

function plotManySignals(clipnum,event)
global DATA
global NUM
global F

if(size(DATA.Unemap.Analysis{NUM}.Slope.Vals,1))
    for kk = 1:5
        for k = 1:15
            vectorIndexA = (kk-1)*15+k;
            %plot signals

            vectorIndexTagA = sprintf('axes%d',vectorIndexA); %axes are lables 1-75 in their tag
            thisaxes=findobj(gcf,'tag',vectorIndexTagA);
            axes(thisaxes)

            cla  %clear anything on the axis (but keep axis settings)
            vectorIndex = (((clipnum-1)*(15*5))+(kk-1)*(15)+k); ...
                %assuming 15 electrodes per needle and 5 needles per clip

            potxtime = F.ui(1):1:F.ui(2);
            potxtime = potxtime.*(1/DATA.Unemap.Info.Frequency);

            %  slopextime = [0:1/DATA.Unemap.Info.Frequency:(size(DATA.Unemap.Analysis{NUM}.Slope.Vals(:,vectorIndex),1)...
            %      -(1/DATA.Unemap.Info.Frequency))/DATA.Unemap.Info.Frequency];

            tagname = sprintf('signal%d',vectorIndex); %signals are given the tag: signal###
            [ax aplot aslope] = plotyy(potxtime, DATA.Unemap.Pot.OrigBase(F.ui(1):F.ui(2),vectorIndex),...
                potxtime, DATA.Unemap.Analysis{NUM}.Slope.Vals(:,vectorIndex));

            axis(ax(1),[potxtime(1) potxtime(length(potxtime)) ...
                min(min(DATA.Unemap.Pot.OrigBase(F.ui(1):F.ui(2),:))) ...
                max(max(DATA.Unemap.Pot.OrigBase(F.ui(1):F.ui(2),:)))]);
            axis(ax(2),[potxtime(1) potxtime(length(potxtime))...
                min(min(DATA.Unemap.Analysis{NUM}.Slope.Vals(:,:))) ...
                max(max(DATA.Unemap.Analysis{NUM}.Slope.Vals(:,:)))]);

            tagname = sprintf('axes%d',vectorIndexA); set(ax(1),'tag',tagname,'YTickLabel',[],'XTickLabel',[],...
                'Ytick',[0],'ButtonDownFcn',@doZfig,'UserData',ax(2));
            tagname = sprintf('slopeA%d',vectorIndexA); set(ax(2),'tag',tagname,'YTickLabel',[],'XTickLabel',[],...
                'Ytick',[-1 0 1], 'ButtonDownFcn',@doZfig,'UserData',ax(1));
            tagname = sprintf('pot%d',vectorIndex); set(aplot,'tag',tagname);
            tagname = sprintf('slope%d',vectorIndex); set(aslope,'tag',tagname);



            if(size(DATA.Unemap.Analysis{NUM}.peaks.val,1))
                doMarkers(vectorIndex,ax(1),aplot);
            end
            tagname = sprintf('%d',vectorIndex);
            electrodenumberText=text(potxtime(1)+1/(DATA.Unemap.Info.Frequency),[max(max(DATA.Unemap.Pot.OrigBase(F.ui(1):F.ui(2),:)))-7],tagname);
            set(electrodenumberText,'FontWeight','bold','FontSize',13,'color','k')
        end
    end
else
    % f = errordlg('You must calculate the slopes before viewing anything!', 'Calc Slopes Error');
end

end

function doMarkers(electNum,axes1,plotData1)
global DATA
global NUM
global F

fontsizes = [12 9 8 7 6 5];
widthsizes = [1.8 1 0.8 0.7 0.6 0.5 0.4 0.3 0.2];
colorz = ['r','m','k','k','k','k'];
freq = DATA.Unemap.Info.Frequency;

%get the minimum position for standardizing the activation times. This
%might change if you update/change stuff might consider making into its own
%function that can be recalled if something in the data changes.

minval = min(min(DATA.Unemap.Analysis{NUM}.peaks.loc(1,DATA.Unemap.Analysis{NUM}.peaks.loc(1,:)>0)));


if(ismember(electNum,DATA.Unemap.Analysis{NUM}.peaks.nopeaks)) %true if there were no peaks, so skip this!
else

    locations = DATA.Unemap.Analysis{NUM}.peaks.loc(:,electNum); %index#
    numloc = size(locations,1);

    for k = 1:numloc %go through each marked slope
        if(k<5)
            markerIndexPos = DATA.Unemap.Analysis{NUM}.peaks.loc(k,electNum);
            markerIndexPos = markerIndexPos+F.ui(1);
            if(markerIndexPos)
                lineh = line([markerIndexPos*(1/freq) markerIndexPos*(1/freq)],...
                    [DATA.Unemap.Pot.OrigBase(markerIndexPos,electNum)-6 DATA.Unemap.Pot.OrigBase(markerIndexPos,electNum)+6]);
                set(lineh,'LineWidth',widthsizes(k),'color',colorz(k));
                if(k <= 3)
                    texth = text(markerIndexPos*(1/freq),DATA.Unemap.Pot.OrigBase(markerIndexPos,electNum)+6+4,...
                        num2str(round((markerIndexPos-F.ui(1))*(1000/DATA.Unemap.Info.Frequency))));
                    if(k == 1)
                        set(texth,'FontWeight','bold');
                    end
                    set(texth,'fontsize',fontsizes(k),'color',colorz(k));
                    if(k >= 4)
                        texth = text(markerIndexPos*(1/freq),Unemap.Pot.OrigBase(markerIndexPos,electNum)+6+4,...
                            num2str(round(markerIndexPos-F.ui(1))*(1000/DATA.Unemap.Info.Frequency)));
                        set(texth,'fontsize',fontsizes(k),'color',colorz(k));
                        set(texth,'Visible','on')
                    end

                end
            end
        end
    end
end
end


function doZfig(handle,event,src)
global NUM

zoomFig = findobj('tag','Zoomfig');
if(zoomFig)
    figure(zoomFig);
else
    zoomFig=figure('Visible','on',...
        'units','pixels','position',[6 400 460 600],...
        'tag','Zoomfig', 'name','Zoom Figure',...
        'menubar','none','numbertitle','on','toolbar','figure'); set(zoomFig,'units','normalized');
    [zoomAs p s] = plotyy([1 1],[200 300],[1.2 1.4],[100 500]);
    zoomA = zoomAs(1); set(zoomA,'units','pixels','position',[30 80 400 400],'nextplot','replacechildren','Box','on');
    set(zoomA,'tag','ZoomAxes','units','normalized'); set(zoomAs(2),'tag','ZoomAxes2');
end




zoomA2 = findobj('tag','ZoomAxes2');
zoomA = findobj('tag','ZoomAxes');

%change color of last selected plot back to white.
if(size(get(zoomA,'UserData'),1))
    set(get(zoomA,'UserData'),'color',[1 1 1]);
end



zoomA2dataH = get(zoomA2,'children'); %get origslopedataHandle
zoomAdataH = get(zoomA,'children'); %get originalpotential children... potential DATA will be indexed last
totalAchildren = length(zoomAdataH);

slopeI= get(handle,'children');
sX = get(slopeI,'Xdata'); sY = get(slopeI,'Ydata');
sXlim = get(handle,'Xlim'); sYlim = get(handle,'Ylim');

manyPotAxesHandle = get(handle,'UserData');
manyPotChildren = get(manyPotAxesHandle,'Children'); %first == Electrode Number, last == Potential Vals
pX = get(manyPotChildren(length(manyPotChildren)),'Xdata'); pY = get(manyPotChildren(length(manyPotChildren)),'Ydata');
pXlim = get(manyPotAxesHandle,'Xlim'); pYlim = get(manyPotAxesHandle,'Ylim');

%change color of current plot in MANY to light cyan.
set(manyPotAxesHandle,'color',[.6 .9 1]);
set(zoomA,'UserData',manyPotAxesHandle); %save the name of the last one

needleShowFig = findobj('tag','NeedleFig');
if(needleShowFig)
    t = get(needleShowFig,'UserData');
    highlightSelectedNeedle(manyPotChildren(1),t,needleShowFig);
end


tit = sprintf('Electrode %s',get(manyPotChildren(1),'String'));
titleH = title(tit);
set(titleH,'FontWeight','Bold','FontSize',16);

axis(zoomA,[pXlim(1) pXlim(2) pYlim(1) pYlim(2)])
axis(zoomA2,[sXlim(1) sXlim(2) sYlim(1) sYlim(2)])


set(zoomA,'Ytick',[(pYlim(1)):(((pYlim(2))-(pYlim(1)))/7):(pYlim(2))]);
set(zoomA2,'Ytick',[(sYlim(1)):(((sYlim(2))-(sYlim(1)))/7):(sYlim(2))]);
set(zoomA,'YtickLabel',[round(pYlim(1)):round(((pYlim(2))-(pYlim(1)))/7):round(pYlim(2))]);
set(zoomA2,'YtickLabel',[round(sYlim(1)):round(((sYlim(2))-(sYlim(1)))/7):round(sYlim(2))]);

set(zoomA2dataH(1),'Xdata',sX,'Ydata',sY,'LineWidth',1);
set(zoomAdataH(totalAchildren),'Xdata',pX,'Ydata',pY,'LineWidth',2);
for k = 1:totalAchildren-1
    delete(zoomAdataH(k));
end


if(length(manyPotChildren)>2)
    for(k = 2:(length(manyPotChildren)-1))
        typeChild = get(manyPotChildren(k),'type');
        if(strcmp(typeChild,'line'))
            xl = get(manyPotChildren(k),'Xdata');
            yl = get(manyPotChildren(k),'Ydata');
            coll = get(manyPotChildren(k),'Color');
            lw = get(manyPotChildren(k),'LineWidth');
            hold on; lh = line([xl(1) xl(2)],[yl(1) yl(2)]);
            set(lh,'linewidth',lw*2);
            set(lh,'color',coll,'Visible','on');
        elseif(strcmp(typeChild,'text'))
            st = get(manyPotChildren(k),'string');
            fs = get(manyPotChildren(k),'FontSize');
            coll = get(manyPotChildren(k),'color');
            fw = get(manyPotChildren(k),'fontweight');
            pos = get(manyPotChildren(k),'position');
            th = text(pos(1),pos(2),st); hold off;
            set(th,'FontSize',fs+2,'color',coll,'fontweight',fw,'Visible','on');
        else
            errordlg('Trying to plot some unrecognizable in the zoom figure (~line 400).', 'Error Zoom Plot');
        end

    end
end

%[ax2 p s] = plotyy(pX,pY,sX,sY);


end
function doRange(handle,src,event)
global DATA
global F
global NUM

NUM = get(handle,'Value');
F.ut(1) = DATA.Unemap.Analysis{NUM}.Range.Time(1);
F.ut(2) = DATA.Unemap.Analysis{NUM}.Range.Time(2);
F.ui(1) = DATA.Unemap.Analysis{NUM}.Range.Index(1);
F.ui(2) = DATA.Unemap.Analysis{NUM}.Range.Index(2);

plotManySignals(1,handle)

end
function doclipplot(handle,event)
clipnum = get(handle,'Value');
plotManySignals(clipnum,handle);
end

function doEnsiteonly(handle, event)

Ensiteonly

end


function highlightSelectedNeedle(elecNameH,lastone,needFig)
global DATA
global ELEC

electrodenumber = str2double(get(elecNameH,'String'));


%t = sprintf('ET%d',electrodenumber);
%electtext = findobj('tag',t);
set(ELEC.ttext(electrodenumber),'Visible','on','color','r','fontsize',18,'fontweight','bold');
%t = sprintf('ES%d',electrodenumber);
%electsphere = findobj('tag',t);
%  C = ones(21,21); C=C.*.95;
set(ELEC.glyph(electrodenumber),'marker','^','MarkerSize',10,'linewidth',6);

if(lastone)
    top = 1:15:DATA.Unemap.Info.numelectrodes; bot = 15:15:DATA.Unemap.Info.numelectrodes;
    lastone;
    whattodowithtext = get(ELEC.ttext(lastone),'UserData');
    if(whattodowithtext)
    else
        set(ELEC.ttext(lastone),'Visible','off','color','k','fontsize',12,'fontweight','normal');
    end

    set(ELEC.glyph(lastone),'marker','*','MarkerSize',8,'linewidth',5);


    % st = sprintf('ET%d',lastelect); oldtext = findobj('tag',st);
    % st = sprintf('ES%d',lastelect); oldsphere = findobj('tag',st);

    % changes last electrode to 'default' values... this should be changed
    % so that the electrode settings revert back to previous values.

    %        set(oldtext,'fontsize',12,'Visible','off','fontweight','normal','visible','off');

end

set(needFig,'UserData',electrodenumber);

end

function doGlobalTotalAct(handle,src,event)
global GEO
global DATA
global NUM 

if(DATA.Exp.Info.PacingType(1) == 'e')
    figure;
    plot(GEO.MRI.Block.Anatomy.orderedElectrodesDistances{DATA.Exp.Info.PacingSite},...
        DATA.Unemap.Analysis{NUM}.peaks.loc(1,:)*(1000/DATA.Unemap.Info.Frequency),'*');
    title(num2str(DATA.Exp.Info.PacingSite));
    xlabel('Distance (mm)');
    ylabel('Time of Primary (ms)');
    figure;
    plot(GEO.MRI.Block.Anatomy.orderedElectrodesDistances{DATA.Exp.Info.PacingSite},...
        GEO.MRI.Block.Anatomy.orderedElectrodesDistances{DATA.Exp.Info.PacingSite}./DATA.Unemap.Analysis{NUM}.peaks.loc(1,:)*(1000/DATA.Unemap.Info.Frequency),'*');
    title(num2str(DATA.Exp.Info.PacingSite));
    xlabel('Distance (mm)');
    ylabel('Time of Primary (ms)');


else
    figure;
    plot(GEO.MRI.Block.Anatomy.orderedElectrodesDistances{187},...
        DATA.Unemap.Analysis{NUM}.peaks.loc(1,:)*(1000/DATA.Unemap.Info.Frequency),'*');
    title(num2str(DATA.Exp.Info.PacingSite));
    xlabel('Distance From Centre of Array, Electrode 187 (mm)');
    ylabel('Time of Primary (ms)');

end
end

function geometryMother(handle,event)

geoMother(0)

end

function geometryMother2(handle,event)

geoMother(1)

end



