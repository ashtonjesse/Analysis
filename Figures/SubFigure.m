classdef SubFigure < BaseFigure
    % BaseFigure Summary 
    % This is the figure base class that other figure classes inherit from.
    % It contains methods and properties that are common to all custom 
    % figure classes.
    
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
        function delete(oFigure)
            delete@BaseFigure(oFigure);
            oFigure.oParentFigure = [];
        end
        
        function oFigure = Close_fcn(oFigure, src, event)
            Close_fcn@BaseFigure(oFigure, src, event);
        end
    end
    
end

