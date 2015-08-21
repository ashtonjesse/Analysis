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
        
        function oMapData = PrepareActivationMap(oOptical, dInterpDim, sPlotType, iEventID, iSupportPoints, iBeatIndex, oActivationData)
            %Get the inputs for a mapping call for activation times,
            %returning a struct containing the x and y locations of the
            %electrodes and the activation times for each. dInterpDim is
            %the number of interpolation points in each direction
                        
            %If no eventID has been specified then default to 1
            if isempty(iEventID)
                iEventID = 1;
            end
            
            switch (sPlotType)
                case 'Scatter'
                    oWaitbar = waitbar(0,'Please wait...');
                    close(oWaitbar);
                case 'Contour'
                    %get the accepted channels
                    aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
                    aElectrodes = oOptical.Electrodes(logical(aAcceptedChannels));
                    aFullCoords = cell2mat({oOptical.Electrodes(:).Coords});
                    aFullCoords = aFullCoords';
                    aCoords = cell2mat({aElectrodes(:).Coords});
                    aCoords = aCoords';
                    rowlocs = aCoords(:,1);
                    collocs = aCoords(:,2);
                    %Get the interpolated points array
                    [xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs),...
                        min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
                    aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
                    aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
                    aMeshPoints = [aXArray,aYArray];
                    %Find which points lie within the area of the array
                    [V,ConcaveTri] = alphavol(aCoords,1);
                    [FF BoundaryLocs] = freeBoundary(TriRep(ConcaveTri.tri,aCoords));
                    aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),BoundaryLocs(:,1),BoundaryLocs(:,2));
                    %do delaunay triangulation
                    DT = DelaunayTri(aCoords);
                    if isempty(oActivationData)
                         %Initialise the map data struct
                        oMapData = struct('x', xlin(1,:)', 'y', ylin(:,1), 'Boundary', aInBoundaryPoints, 'r2', [],'CVx',aFullCoords(:,1),'CVy',aFullCoords(:,2));
                        %Initialise the Beats struct
                        aData = struct('FullActivationTimes',zeros(1, numel(oOptical.Electrodes)),'ActivationTimes',...
                            [],'z',NaN(size(xlin)),'CVApprox',zeros(1, numel(oOptical.Electrodes)),...
                            'CVVectors',zeros(1, numel(oOptical.Electrodes)),'ATgrad',zeros(1, numel(oOptical.Electrodes)));
                        oMapData.Beats = repmat(aData,1,size(oOptical.Electrodes(1).Processed.BeatIndexes,1));
                    else
                        oMapData = oActivationData;
                    end
                    
                    %Get the activation indexes
                    aActivationIndexes = zeros(numel(aElectrodes),1);
                    aFullActivationIndexes = zeros(numel(oOptical.Electrodes),1);
                    FullActivationTimes = zeros(numel(oOptical.Electrodes),1);
                    %track the number of accepted electrodes
                    m = 0;
                    oWaitbar = waitbar(0,'Please wait...');
                    iLength = numel(oOptical.Electrodes);
                    for p = 1:numel(oOptical.Electrodes)
                        if oOptical.Electrodes(p).Accepted
                            m = m + 1;
                            if aElectrodes(m).SignalEvent(iEventID).Index(iBeatIndex) > 1
                            else
                                oOptical.MarkEvent(p, iEventID, iBeatIndex);
                                aElectrodes(m).SignalEvent(iEventID).Index(iBeatIndex) = oOptical.Electrodes(p).SignalEvent(iEventID).Index(iBeatIndex);
                            end
                            aActivationIndexes(m) = aElectrodes(m).SignalEvent(iEventID).Index(iBeatIndex) - 1 + oOptical.Electrodes(p).Processed.BeatIndexes(iBeatIndex,1);
                            aFullActivationIndexes(p) =  aElectrodes(m).SignalEvent(iEventID).Index(iBeatIndex) - 1 + oOptical.Electrodes(p).Processed.BeatIndexes(iBeatIndex,1);
                            aFullActivationTimes(p) = oOptical.TimeSeries(aFullActivationIndexes(p));
                        else
                            %hold the unaccepted electrode places with inf
                            oMapData.Beats(iBeatIndex).FullActivationTimes(p) =  Inf;
                        end
                        waitbar(p/iLength,oWaitbar,sprintf('Please wait... Processing Electrode %d',p));
                    end
                    close(oWaitbar);
                    %Get the activation time fields for all time points during this
                    %beat
                    aActivationTimes = oOptical.TimeSeries(aActivationIndexes)';
                    aFullActivationTimes = aFullActivationTimes';
                    %convert to ms
                    oMapData.Beats(iBeatIndex).ActivationTimes = 1000*(aActivationTimes - min(aActivationTimes));
                    oMapData.Beats(iBeatIndex).FullActivationTimes = 1000*(aFullActivationTimes - min(aFullActivationTimes));                    
                    %do interpolation
                    %calculate interpolant
                    oInterpolant = TriScatteredInterp(DT,oMapData.Beats(iBeatIndex).ActivationTimes);
                    %evaluate interpolant
                    oInterpolatedField = oInterpolant(xlin,ylin);
                    %rearrange to be able to apply boundary
                    aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
                    %apply boundary
                    aQZArray(~aInBoundaryPoints) = NaN;
                    %save result back in proper format
                    oMapData.Beats(iBeatIndex).z  = reshape(aQZArray,size(xlin,1),size(xlin,2));
                    
                    %Calculate the CV and save the results
                    [CVApprox,CVVectors,ATgrad]=ReComputeCV([aFullCoords(:,1),aFullCoords(:,2)],oMapData.Beats(iBeatIndex).FullActivationTimes,iSupportPoints,0.1);
                    oMapData.Beats(iBeatIndex).CVApprox = CVApprox;
                    oMapData.Beats(iBeatIndex).CVVectors = CVVectors;
                    oMapData.Beats(iBeatIndex).ATgrad = ATgrad;
            end
        end
        
        function oMapData = PreparePotentialMap(oOptical, dInterpDim, iBeatIndex, oPotentialData, oActivationData)
            %get the accepted channels
            aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
            aElectrodes = oOptical.Electrodes(logical(aAcceptedChannels));
            aFullCoords = cell2mat({oOptical.Electrodes(:).Coords});
            aFullCoords = aFullCoords';
            aCoords = cell2mat({aElectrodes(:).Coords});
            aCoords = aCoords';
            rowlocs = aCoords(:,1);
            collocs = aCoords(:,2);
            %Get the interpolated points array
            [xlin ylin] = meshgrid(min(rowlocs):(max(rowlocs) - min(rowlocs))/dInterpDim:max(rowlocs),...
                min(collocs):(max(collocs)-min(collocs))/dInterpDim:max(collocs));
            aXArray = reshape(xlin,size(xlin,1)*size(xlin,2),1);
            aYArray = reshape(ylin,size(ylin,1)*size(ylin,2),1);
            aMeshPoints = [aXArray,aYArray];
            %Find which points lie within the area of the array
            [V,ConcaveTri] = alphavol(aCoords,1);
            [FF BoundaryLocs] = freeBoundary(TriRep(ConcaveTri.tri,aCoords));
            aInBoundaryPoints = inpolygon(aMeshPoints(:,1),aMeshPoints(:,2),BoundaryLocs(:,1),BoundaryLocs(:,2));
            %do delaunay triangulation
            DT = DelaunayTri(aCoords);
            
            if isempty(oPotentialData)
                %Initialise the map data struct
                oMapData = struct('x', xlin(1,:)', 'y', ylin(:,1), 'Boundary', aInBoundaryPoints);
                %Initialise the Beats struct
                aData = struct('Fields',[]);
                oMapData.Beats = repmat(aData,1,size(aElectrodes(1).Processed.BeatIndexes,1));
            else
                %use what was previously created
                oMapData = oPotentialData;
            end
            %get data for this beat
            aAllBeatPotentials = MultiLevelSubsRef(oOptical.oDAL.oHelper,aElectrodes,'Processed','Data');
            aSingleBeatPotentials = aAllBeatPotentials(aElectrodes(1).Processed.BeatIndexes(iBeatIndex,1):aElectrodes(1).Processed.BeatIndexes(iBeatIndex,2),:);
            %initialise array to hold normalised data
            aNormalisedData = zeros(size(aSingleBeatPotentials));
            %Loop through electrodes and normalise data
            for i = 1:size(aSingleBeatPotentials,2)
                %get the baseline and peak values
                dBaseLine = mean(aSingleBeatPotentials(1:25,i));
                aNormalisedData(:,i) = (aSingleBeatPotentials(:,i)+sign(dBaseLine)*(-1)*abs(dBaseLine));
                dPeak = max(aNormalisedData(:,i));
                aNormalisedData(:,i) = aNormalisedData(:,i)./dPeak;
            end
            
            %initialise the struct to hold all the interpolated fields
            oFields = struct('z',NaN(size(xlin)));
            oMapData.Beats(iBeatIndex).Fields = repmat(oFields,size(aNormalisedData,1),1);
            %set up wait bar
            oWaitbar = waitbar(0,'Please wait...');
            %loop through time points and do interpolation
            for j = 1:size(aNormalisedData,1)
                waitbar(j/size(aNormalisedData,1),oWaitbar,sprintf('Please wait... Processing Time Point %d',j));
                %do interpolation
                %calculate interpolant
                oInterpolant = TriScatteredInterp(DT,aNormalisedData(j,:)');
                %evaluate interpolant
                oInterpolatedField = oInterpolant(xlin,ylin);
                %rearrange to be able to apply boundary
                aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
                %apply boundary
                aQZArray(~aInBoundaryPoints) = NaN;
                %save result back in proper format
                oMapData.Beats(iBeatIndex).Fields(j).z  = reshape(aQZArray,size(xlin,1),size(xlin,2));
            end
            close(oWaitbar);
        end
    end
    
end