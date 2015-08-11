classdef Optical < BasePotential
    %   Optical is a subclass of type BasePotential that is associated
    %   with an optical transmembrane potential recording from an Experiment.
    %   OpticalPotential inherits all properties and methods from BaseSignal.
    
    properties
        oExperiment;
        Electrodes = [];
        TimeSeries = [];
        Name;
    end
    
    methods
        function oOptical = Optical(varargin)
            %% Constructor
            oOptical = oOptical@BasePotential();
            if nargin == 1
                if isstruct(varargin{1}) || isa(varargin{1},'Optical')
                    oOpticalStruct = varargin{1};
                    %get the fields
                    sFields = fields(oOpticalStruct);
                    %loop through and load these fields
                    for i = 1:length(sFields)
                        if strcmp(char(sFields{i}),'oExperiment')
                            %this requires constructing a class
                            oOptical.oExperiment = Experiment(oOpticalStruct.oExperiment);
                        else
                            oOptical.(char(sFields{i})) = oOpticalStruct.(char(sFields{i}));
                        end
                    end
                end
            end
        end
        
        function oOptical = GetOpticalFromMATFile(oOptical, sFile)
            %   Get an entity by loading a mat file that has been saved
            %   previously
            
            %   Load the mat file into the workspace
            oData = oOptical.oDAL.GetEntityFromFile(sFile);
            %   Reload all the properties
            oOptical.oExperiment = Experiment(oData.oEntity.oExperiment);
            oOptical.Electrodes = oData.oEntity.Electrodes;
            oOptical.TimeSeries = oData.oEntity.TimeSeries;
            oOptical.Name = oData.oEntity.Name;
        end
    end
    
    methods (Access = protected)
        %% Inherited protected methods
        function SaveEntity(oOptical,sPath)
            SaveEntity@BaseEntity(oOptical,sPath);
        end
    end
    
    methods (Access = public)
        %% Public methods
        function Save(oOptical,sPath)
            SaveEntity(oOptical,sPath);
        end
        
        function oOptical = GetOpticalRecordingFromCSVFile(oOptical, sFileName, oExperiment)
            %   Get an entity by loading data from a CSV file 
            
            % Load the experiment
            %   If the experiment is empty
            if isempty(oExperiment)
                %   Look for a metadata file in next directory up that will
                %   contain the Experiment data
                [sPath,sName,ext,ver] = fileparts(sFileName);
                aResult = regexp(sPath,'\');
                sExperimentPath = sPath(1:aResult(end)-1);
                aFileFull = fGetFileNamesOnly(sExperimentPath,'*_experiment.txt');
                %   There should be one experiment file and no more
                if ~(size(aFileFull,1) == 1)
                    error('VerifyInput:TooManyInputFiles', 'There is the wrong number of experimental metadata files in the directory %s',sExperimentPath);
                end
                %   Get the Experiment entity
                oOptical.oExperiment= GetExperimentFromTxtFile(Experiment, char(aFileFull(1)));
            end
            %Initialise the Electrodes struct
            oOptical.Electrodes = struct('Name','','Location',[0;0],'Coords',[0;0],'Status','Potential','Accepted',1); 
            %get the data from the file
            oOptical.oDAL.GetOpticalDataFromCSVFile(oOptical, sFileName);
            sResult = regexp(sPath,'\\','split');
            oOptical.Name = char(sResult{end});
        end
        
        function oOptical = GetArrayBeats(oOptical,aPeaks)
            %get the beat information and put it into the electrode struct
            aInData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,oOptical.Electrodes(1).Status,'Data');
            [aOutData dMaxPeaks] =  oOptical.GetSinusBeats(aInData, aPeaks);
            if ~isfield(oOptical.Electrodes(1),'Processed')
                oOptical.Electrodes = MultiLevelSubsAsgn(oOptical.oDAL.oHelper,oOptical.Electrodes,'Processed','Data',aInData);
            end
            %Split again into the Electrodes
            oOptical.Electrodes = MultiLevelSubsAsgn(oOptical.oDAL.oHelper,oOptical.Electrodes,'Processed','Beats',cell2mat(aOutData(1)));
            oOptical.Electrodes = MultiLevelSubsAsgn(oOptical.oDAL.oHelper,oOptical.Electrodes,'Processed','BeatIndexes',cell2mat(aOutData(2)));
            %loop through electrodes and calculate sinus rates
            for i = 1:numel(oOptical.Electrodes)
                oOptical.FinishProcessing(i);
                oOptical.CalculateSinusRate(i);
            end
        end
    end
    
end