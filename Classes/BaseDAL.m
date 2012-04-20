classdef BaseDAL 
    %   BaseDAL is the data access layer super class
    %   This class should contain all methods associated with loading or
    %   saving data. Any methods that also involve manipulating or
    %   interpreting data may be in the DataHelper class
        
    methods

        function oBaseDAL = BaseDAL()
            %%  Constructor

        end
    end
    
    methods (Access = public)
        %% Public Methods
        function oData = GetEntityFromFile(oBaseDAL,sFile)
            %   Loads struct from file and should be called by an Entity
            
            oData = load(sFile);
        end
        
        function oData = LoadFromFile(oBaseDAL,sFile)
            %   Loads data from file
            
            oData = load(sFile);
        end
        
        function oEntity = CreateEntityFromFile(oBaseDAL,sFile)
            %   Create an entity from a file. Note all fields to be parsed from
            %   the file should be separated by a full stop and the value
            %   should be preceeded by an equals  sign
            
            %   Create the new entity by using a DataHelper method
            oEntity = ParseFileIntoEntity(DataHelper, sFile);
        end
        
        function SaveThisEntity(oBaseDAL,oEntity,sPath)
            %   Save the specificed entity
            save(sPath, 'oEntity');
        end
        
        
    end
    
end

