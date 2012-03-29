classdef SubFigure < BaseFigure
    % BaseFigure Summary 
    % This is the base class for figures that are opened from another
    % figure so have a parent. 
        
    properties
        oParentFigure;
    end
    
    methods
        %% Constructor
        function oFigure = SubFigure(oParent,sGuiFileName,OpeningFcn)
            oFigure = oFigure@BaseFigure(sGuiFileName,OpeningFcn);
            oFigure.oParentFigure = oParent;
        end
    end
    
    methods (Access = protected)
        %% Delete and exit methods
        function deleteme(oFigure)
            deleteme@BaseFigure(oFigure);
            oFigure.oParentFigure = [];
        end
        
        function nValue = GetPopUpSelectionDouble(oFigure,sPopUpMenuTag)
            nValue = GetPopUpSelectionDouble@BaseFigure(oFigure,sPopUpMenuTag);
        end
    end
    
end

