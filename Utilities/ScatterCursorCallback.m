function output_txt = ScatterCursorCallback(obj,event_obj)
% Display the position of the data cursor
% obj          Currently not used (empty)
% event_obj    Handle to event object
% output_txt   Data cursor text string (string or cell array of strings).

pos = get(event_obj,'Position');
dataindex = get(event_obj,'DataIndex');
if isprop(event_obj.Target,'CData') && size(get(event_obj.Target,'CData'),2) ~= 3
    cdata = get(event_obj.Target,'CData');
    output_txt = {['X: ',num2str(pos(1),6)],...
        ['Y: ',num2str(pos(2),6)],...
        ['Location: ', sprintf('%4.2f',cdata(dataindex))],...
        ['Beat: ',num2str(dataindex)]};
    
else
    output_txt = {['X: ',num2str(pos(1),6)],...
        ['Y: ',num2str(pos(2),6)],...
        ['Index: ',num2str(dataindex)]};
end

