function fSignalAnalysis
%This will load the entire traces from DATA (either just Unemap, Ensite or both
%if they are both present.
%the user can then select the range for the activation portion of a particular beat.
%Data needs to have been previously baseline corrected and the mean zeroed in the
%'preprocessing' step.
%global RMS should be shown.
%zoomed portions of beats should be shown with option to change electrode
%
global DATA
global NUM

ssfig=figure('Visible','on',...
    'units','pixels','position',[360 220 1500 850],...
    'tag','ssfig','name','SelectSingle',...
    'menubar','none','numbertitle','off',...
    'Color',[.95 .99 .95]);

numberofranges = size(DATA.Unemap.Analysis,2)+1;
runningstr = '';
for k = 1:numberofranges
    tempstr = sprintf('%d|',k);
    runningstr = strcat(runningstr,tempstr);
end
runningstr = substr(runningstr,0,-1);

rangepoph = uicontrol('style','popupmenu','units','pixels','position',[1075 680 350 50],'tag','rangepop','BackgroundColor',[0 .99 .95],...
    'string',runningstr,'fontsize',14,'callback',@dorange);
textrange = uicontrol('style','text','string','Chose Range (last = new range)','units','pixels','position',[1070 750 360 50],'fontsize',14,'fontweight','bold',...
    'Background',[0 .99 .95]);

DATA.Ensite.Time.timedelayAl
set(rangepoph,'units','normalized'); set(textrange,'units','normalized');

set(ssfig,'units','normalized','toolbar','figure');


sliderleftposition = uicontrol('style','text','tag','sliderleftposition','units','pixel','position'...
    ,[50 25 300 25],'BackGround','g','foreground',[1 1 1],'FontWeight','bold','FontSize',14,'string','Leftside in ms');
sliderrightposition = uicontrol('style','text','tag','sliderrightposition','units','pixel','position'...
    ,[700 25 300 25],'BackGround','r','foreground',[1 1 1],'FontWeight','bold','FontSize',14,'string','Rightside in ms');
pickpacing = uicontrol('style','pushbutton','tag','pickpacing','units','pixel','position'...
    ,[1100 185+225+175 300 50],'string','Pick Pacing','BackGround',[.2 .2 1],'FontSize',14,'callback',@pickpace);

frame = uicontrol('style','frame','units','pixel','position',[1075 35+225-25 300+50 250],'background','w');
set(frame,'units','normalized');
applySelect1 = uicontrol('style','pushbutton','tag','applySelect','units','pixel','position'...
    ,[1100 185+225 300 50],'string','Save','BackGround','m','FontSize',14,'callback',@saveonly);
applySelect2 = uicontrol('style','pushbutton','tag','applySelect','units','pixel','position'...
    ,[1100 110+225 300 50],'string','Save and Exit','BackGround','g','FontSize',14,'callback',@saveandexit);
applySelect3 = uicontrol('style','pushbutton','tag','applySelect','units','pixel','position'...
    ,[1100 35+225 300 50],'string','Do Not Save and Exit','BackGround','r','FontSize',14,'callback','closereq');

set(sliderleftposition,'units','normalized'); set(sliderrightposition,'units','normalized'); set(pickpacing,'units','normalized');
set(applySelect1,'units','normalized'); set(applySelect2,'units','normalized'); set(applySelect3,'units','normalized');

bigselectaxes = axes('units','pixels','position',[30 100 1000 700],'nextplot','replacechildren','Box','on'...
    ,'tag','bigaxe','YTickLabel',[]);

a = get(gca, 'position'); xa = a(1); ya = a(2); wa = a(3); ha = a(4);
set(bigselectaxes,'units','normalized');

alignementALtext = sprintf('Alignment: %d',DATA.Ensite.Time.timedelayAl);
altextH = uicontrol('style','text','string',alignementALtext,'units','pixels','position',[1100 50 300 50],'fontsize',14,'fontweight','bold',...
    'Background','w');
set(altextH,'units','normalized');








dorange;

    function dorange(handle,src,event)
        cla;
        numberofranges = size(DATA.Unemap.Analysis,2)+1;
        NUM = get(rangepoph,'Value');
        tit = sprintf('Range %d',NUM);
        b  = title(tit); set(b,'fontweight','bold','fontsize',14);
        b = xlabel('Seconds (s)'); set(b,'fontweight','bold','fontsize',14);



        %% Both Unemap and Ensite data are present
        if(DATA.Unemap.Info.Exist && DATA.Ensite.Info.Exist)


            %% Only Unemap Data exists.
            %elseif(DATA.Unemap.Info.Exist)
            ttp = DATA.Unemap.Info.NumNeedles + 1;
            ttpo = 2;
            set(bigselectaxes,'UserData',ttp);
            %axis([0 size(DATA.Unemap.Time,1) 0
            %(max(max(DATA.Unemap.Pot.OrigBase))+10+ttp*ttpo)]);
            count = 1;
            for nn = 1:DATA.Unemap.Info.NumNeedles
                unemapindexFirst = (nn-1)*15+1;
                unemapindexLast = (nn-1)*15+15;
                temp = sqrt(mean(DATA.Unemap.Pot.OrigBase(:,unemapindexFirst:unemapindexLast),2).^2);

                plot(DATA.Unemap.Time,temp*.5+80+((ttp-count+1)*ttpo-(nn*.5)),'b'); hold on;
                count = count+1;
                %(DATA.Unemap.Pot.OrigBase(:,unemapindex))*.01+10+(ttp-count+1)*ttpo-(nn*.2)
            end
            count = 1;
            for nn = 1:20:200
                plot(DATA.Ensite.Time.Standard+DATA.Ensite.Time.timedelay,DATA.Ensite.Virt.Pot.Orig(:,nn)*.5+...
                    5+((ttp-count+1)*ttpo-(count*.8)),'g');
                count = count+1;
            end
            axis tight

            xlims = get(bigselectaxes,'XLim');
            ylims = get(bigselectaxes,'YLim');
            ylims(1) = -5;
            totaltime = xlims(2);

            %draw left and right lines
            if(numberofranges == NUM)
                leftrange = 1;
                rightrange = 2;
            elseif(DATA.Unemap.Analysis{NUM}.Range.Time)
                leftrange = DATA.Unemap.Analysis{NUM}.Range.Time(1);
                rightrange = DATA.Unemap.Analysis{NUM}.Range.Time(2);
            else
                leftrange = 1;
                rightrange = 2;
            end

            leftline = line([leftrange leftrange],...
                [ylims(1) ylims(2)]); set(leftline,'color','g','LineWidth',2,'tag','leftline');

            rightline = line([rightrange rightrange],...
                [ylims(1) ylims(2)]); set(rightline,'color','r','LineWidth',2,'tag','rightline');


            timeofslider = sprintf('%4g ms', leftrange*1000);
            set(sliderleftposition,'string',timeofslider);

            timeofslider = sprintf('%4g ms', rightrange*1000);
            set(sliderrightposition,'string',timeofslider);


            %plot global RMS

            gRMS = sqrt(mean(DATA.Unemap.Pot.OrigBase(:,:),2).^2);
            globalrms = plot(DATA.Unemap.Time,gRMS,'r');


            xxx = get(gca,'XLim'); xmin = xxx(1); xlimit = xxx(2);
            yyy = get(gca,'YLim'); ymin = yyy(1); ylimit = yyy(2);
            set(ssfig,'WindowButtonMotionFcn', @showHand);



            %% Only Ensite data exists
        elseif(DATA.Ensite.Info.Exist)
        elseif(DATA.Unemap.Info.Exist)
            %% Only Unemap Data exists.

            ttp = DATA.Unemap.Info.NumNeedles + 1;
            ttpo = 2;
            set(bigselectaxes,'UserData',ttp);
            %axis([0 size(DATA.Unemap.Time,1) 0
            %(max(max(DATA.Unemap.Pot.OrigBase))+10+ttp*ttpo)]);
            count = 1;
            for nn = 1:DATA.Unemap.Info.NumNeedles
                unemapindexFirst = (nn-1)*15+1;
                unemapindexLast = (nn-1)*15+15;
                temp = sqrt(mean(DATA.Unemap.Pot.OrigBase(:,unemapindexFirst:unemapindexLast),2).^2);

                plot(DATA.Unemap.Time,temp*.5+80+((ttp-count+1)*ttpo-(nn*.5)),'b'); hold on;
                count = count+1;
                %(DATA.Unemap.Pot.OrigBase(:,unemapindex))*.01+10+(ttp-count+1)*ttpo-(nn*.2)
            end

            axis tight

            xlims = get(bigselectaxes,'XLim');
            ylims = get(bigselectaxes,'YLim');
            ylims(1) = -5;
            totaltime = xlims(2);

            %draw left and right lines
            if(numberofranges == NUM)
                leftrange = 1;
                rightrange = 2;
            elseif(DATA.Unemap.Analysis{NUM}.Range.Time)
                leftrange = DATA.Unemap.Analysis{NUM}.Range.Time(1);
                rightrange = DATA.Unemap.Analysis{NUM}.Range.Time(2);
            else
                leftrange = 1;
                rightrange = 2;
            end

            leftline = line([leftrange leftrange],...
                [ylims(1) ylims(2)]); set(leftline,'color','g','LineWidth',2,'tag','leftline');

            rightline = line([rightrange rightrange],...
                [ylims(1) ylims(2)]); set(rightline,'color','r','LineWidth',2,'tag','rightline');


            timeofslider = sprintf('%4g ms', leftrange*1000);
            set(sliderleftposition,'string',timeofslider);

            timeofslider = sprintf('%4g ms', rightrange*1000);
            set(sliderrightposition,'string',timeofslider);


            %plot global RMS

            gRMS = sqrt(mean(DATA.Unemap.Pot.OrigBase(:,:),2).^2);
            globalrms = plot(DATA.Unemap.Time,gRMS,'r');


            xxx = get(gca,'XLim'); xmin = xxx(1); xlimit = xxx(2);
            yyy = get(gca,'YLim'); ymin = yyy(1); ylimit = yyy(2);
            set(ssfig,'WindowButtonMotionFcn', @showHand);


        else
            errordlg('Your DATA.mat file contains neither Unemap nor Ensite data. Did you remember to update the Exist variable?', 'Select Single Exist Error');
            closereq;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end here?
        leftline = findobj('tag','leftline');
        rightline = findobj('tag','rightline');
        llxvals = get(leftline,'Xdata'); llxval = llxvals(1);
        rlxvals = get(rightline,'Xdata'); rlxval = rlxvals(1);


        %%
        function showHand(fig_handle, eventdata) % define hot spots
            ah = bigselectaxes;


            cp = get(ah, 'currentpoint');    % Get the locations of the cursor with respect to the axes
            xinit = cp(1,1);yinit = cp(1,2);

            range = 0.1;

            update_pointer = false;

            if( abs(xinit - llxval) < range   && abs( yinit ) <  ylimit - range )
                src = 'leftline' ;
                update_pointer = true;
            elseif ( abs(xinit - rlxval) < range   && abs( yinit ) <  ylimit - range )
                src = 'rightline' ;
                update_pointer = true;
            end

            if update_pointer
                setfigptr('hand', fig_handle);
                set(fig_handle,'WindowButtonDownFcn', @showClosedHand);
            else
                setfigptr('default', fig_handle);
                set(fig_handle,'WindowButtonDownFcn', '');
            end

            function showClosedHand(fig_handle, eventdata)
                setfigptr('closedhand', fig_handle);
                set(fig_handle,'WindowButtonMotionFcn', @doMove);
                set(fig_handle,'WindowButtonUpFcn',@doRelease);

                function doMove(fig_handle, eventdata)
                    cp = get(ah, 'currentpoint');
                    xinit = cp(1,1);yinit = cp(1,2); % values in the axes, has to conver to pixel

                    if strcmp(src,'leftline')
                        if abs(xinit) <= xlimit
                            set(leftline, 'XData', xinit*ones(1,2));
                            timeofslider = sprintf('%4g ms', xinit*1000);
                            set(sliderleftposition,'string',timeofslider);
                        else
                            set(leftline, 'xData', xlimit *  sign(xinit)*ones(1,2));
                            timeofslider = sprintf('%4g ms', xlimit*1000);
                            set(sliderleftposition,'string',timeofslider);
                        end
                    elseif strcmp(src,'rightline')
                        if abs(xinit) <= xlimit
                            set(rightline, 'xData', xinit*ones(1,2));
                            timeofslider = sprintf('%4g ms', xinit*1000);
                            set(sliderrightposition,'string',timeofslider);
                        else
                            set(rightline, 'xData', xlimit *  sign(xinit)*ones(1,2));
                            timeofslider = sprintf('%4g ms', xlimit*1000);
                            set(sliderrightposition,'string',timeofslider);
                        end
                    end

                end

                function doRelease(fig_handle, eventdata)
                    cp = get(ah, 'currentpoint');
                    xinit = cp(1,1);yinit = cp(1,2); % values in the axes, has to conver to pixel
                    if abs(yinit) > ylimit;
                        yinit = ylimiy * sign(yinit);
                    end

                    if abs(xinit) > xlimit
                        xinit = xlimit * sign(xinit);
                    end

                    if strcmp(src,'leftline')
                        llxval = xinit;
                    elseif strcmp(src,'rightline')
                        rlxval = xinit;
                    end

                    setfigptr('default', fig_handle);
                    set(gcf,'WindowButtonUpFcn', '');
                    set(gcf,'WindowButtonDownFcn', '');
                    set(gcf,'WindowButtonMotionFcn', @showHand);
                end


            end
        end

        function pixel_out = get_pixel(value_in)
            pixel_out = (value_in - (ylimit))/(ylimit* 2) * ha + ya - 1.5;
        end

    end
end

function pickpace(handle,src,event)
global DATA
global NUM

[X,Y] = ginput(2);

[a,left] = min(abs(DATA.Unemap.Time - X(1)));
[a,right] = min(abs(DATA.Unemap.Time - X(2)));
DATA.Unemap.Analysis{NUM}.pace(1) = left;
DATA.Unemap.Analysis{NUM}.pace(2) = right;

end


%% save only
function saveonly(handle,src,event)
global DATA
global NUM

leftH = findobj('tag','leftline');
leftXs = get(leftH,'Xdata'); leftX = leftXs(1);
rightH = findobj('tag','rightline');
rightXs = get(rightH,'Xdata'); rightX = rightXs(1);


rangepopH = findobj('tag','rangepop');
popstring = get(rangepopH,'String');

if(NUM == size(DATA.Unemap.Analysis,2)+1)
    popstring(size(popstring,1)+1) = num2str(size(popstring,1)+1);
    set(rangepopH,'String',popstring);
end

%   f2(1:2) = [DATA.Unemap.Analysis{n}.Range(1) DATA.Unemap.Analysis{n}.Range(2)]; %FRAME.t
f(1:2) = [find(DATA.Unemap.Time < leftX, 1, 'last' )...
    find(DATA.Unemap.Time < rightX-1, 1, 'last' )]; %FRAME.i

if (DATA.Unemap.Info.Exist)
    [a,leftUI] = min(abs(DATA.Unemap.Time - leftX));
    [a,rightUI] = min(abs(DATA.Unemap.Time - rightX));
    DATA.Unemap.Analysis{NUM}.Range.Time = [];
    DATA.Unemap.Analysis{NUM}.Range.Index = [];
    DATA.Unemap.Analysis{NUM}.Slope.Vals = [];
    DATA.Unemap.Analysis{NUM}.peaks.loc = [];
    DATA.Unemap.Analysis{NUM}.peaks.nopeaks = [];
    DATA.Unemap.Analysis{NUM}.peaks.val = [];
    DATA.Unemap.Analysis{NUM}.peaks.info = [];

    DATA.Unemap.Analysis{NUM}.Range.Time(1) = leftX;
    DATA.Unemap.Analysis{NUM}.Range.Time(2) = rightX;
    DATA.Unemap.Analysis{NUM}.Range.Index(1) = leftUI;
    DATA.Unemap.Analysis{NUM}.Range.Index(2) = rightUI;


end
if (DATA.Ensite.Info.Exist)
    [a,leftEI] = min(abs(DATA.Ensite.Time.Standard - (leftX - DATA.Ensite.Time.timedelay)));
    [a,rightEI] = min(abs(DATA.Ensite.Time.Standard - (rightX - DATA.Ensite.Time.timedelay)));
    DATA.Ensite.Virt.Analysis{NUM}.Range.Time = [];
    DATA.Ensite.Virt.Analysis{NUM}.Range.Index = [];
    DATA.Ensite.Virt.Analysis{NUM}.Slope.Vals = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.loc = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.nopeaks = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.val = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.info = [];
    DATA.Ensite.Virt.Analysis{NUM}.Range.Time(1) = leftX - DATA.Ensite.Time.timedelay;
    DATA.Ensite.Virt.Analysis{NUM}.Range.Time(2) = rightX - DATA.Ensite.Time.timedelay;
    DATA.Ensite.Virt.Analysis{NUM}.Range.Index(1) = leftEI;
    DATA.Ensite.Virt.Analysis{NUM}.Range.Index(2) = rightEI;
end
end



%%
function saveandexit(handle,src,event)
global DATA
global NUM

leftH = findobj('tag','leftline');
leftXs = get(leftH,'Xdata'); leftX = leftXs(1);
rightH = findobj('tag','rightline');
rightXs = get(rightH,'Xdata'); rightX = rightXs(1);


rangepopH = findobj('tag','rangepop');
popstring = get(rangepopH,'String');

if(NUM == size(DATA.Unemap.Analysis,2)+1)
    popstring(size(popstring,1)+1) = num2str(size(popstring,1)+1);
    set(rangepopH,'String',popstring);
end

%   f2(1:2) = [DATA.Unemap.Analysis{n}.Range(1) DATA.Unemap.Analysis{n}.Range(2)]; %FRAME.t
f(1:2) = [find(DATA.Unemap.Time < leftX, 1, 'last' )...
    find(DATA.Unemap.Time < rightX-1, 1, 'last' )]; %FRAME.i

if (DATA.Unemap.Info.Exist)
    [a,leftUI] = min(abs(DATA.Unemap.Time - leftX));
    [a,rightUI] = min(abs(DATA.Unemap.Time - rightX));
    DATA.Unemap.Analysis{NUM}.Range.Time = [];
    DATA.Unemap.Analysis{NUM}.Range.Index = [];
    DATA.Unemap.Analysis{NUM}.Slope.Vals = [];
    DATA.Unemap.Analysis{NUM}.peaks.loc = [];
    DATA.Unemap.Analysis{NUM}.peaks.nopeaks = [];
    DATA.Unemap.Analysis{NUM}.peaks.val = [];
    DATA.Unemap.Analysis{NUM}.peaks.info = [];
    DATA.Unemap.Analysis{NUM}.Range.Time(1) = leftX;
    DATA.Unemap.Analysis{NUM}.Range.Time(2) = rightX;
    DATA.Unemap.Analysis{NUM}.Range.Index(1) = leftUI;
    DATA.Unemap.Analysis{NUM}.Range.Index(2) = rightUI;
end
if (DATA.Ensite.Info.Exist)
    [a,leftEI] = min(abs(DATA.Ensite.Time.Standard - (leftX - DATA.Ensite.Time.timedelay)));
    [a,rightEI] = min(abs(DATA.Ensite.Time.Standard - (rightX - DATA.Ensite.Time.timedelay)));
    DATA.Ensite.Virt.Analysis{NUM}.Range.Time = [];
    DATA.Ensite.Virt.Analysis{NUM}.Range.Index = [];
    DATA.Ensite.Virt.Analysis{NUM}.Slope.Vals = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.loc = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.nopeaks = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.val = [];
    DATA.Ensite.Virt.Analysis{NUM}.peaks.info = [];
    DATA.Ensite.Virt.Analysis{NUM}.Range.Time(1) = leftX - DATA.Ensite.Time.timedelay;
    DATA.Ensite.Virt.Analysis{NUM}.Range.Time(2) = rightX - DATA.Ensite.Time.timedelay;
    DATA.Ensite.Virt.Analysis{NUM}.Range.Index(1) = leftEI;
    DATA.Ensite.Virt.Analysis{NUM}.Range.Index(2) = rightEI;
end
closereq;
end