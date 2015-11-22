classdef Optical < BasePotential
    %   Optical is a subclass of type BasePotential that is associated
    %   with an optical transmembrane potential recording from an Experiment.
    %   OpticalPotential inherits all properties and methods from BaseSignal.
    
    properties
        ReferencePoints;
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
                if ~oOptical.IsProp('Beats')
                    oOptical.Beats.Indexes = oOptical.Electrodes(1).Processed.BeatIndexes;
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
            if oData.oEntity.IsProp('Beats')
                oOptical.Beats = oData.oEntity.Beats;
            end
            if oData.oEntity.IsProp('ReferencePoints')
                oOptical.ReferencePoints = oData.oEntity.ReferencePoints;
            end
        end
        
        function oOptical = GetOpticalRecordingFromCSVFile(oOptical, sFileName, oExperiment)
            %   Get an entity by loading data from a CSV file 
            
            % Load the experiment
            %   If the experiment is empty
            [sPath,sName,ext,ver] = fileparts(sFileName);
            if isempty(oExperiment)
                %   Look for a metadata file in next directory up that will
                %   contain the Experiment data
                aResult = regexp(sPath,'\');
                sExperimentPath = sPath(1:aResult(end)-1);
                aFileFull = fGetFileNamesOnly(sExperimentPath,'*_experiment.txt');
                %   There should be one experiment file and no more
                if ~(size(aFileFull,1) == 1)
                    error('VerifyInput:TooManyInputFiles', 'There is the wrong number of experimental metadata files in the directory %s',sExperimentPath);
                end
                %   Get the Experiment entity
                oOptical.oExperiment= GetExperimentFromTxtFile(Experiment, char(aFileFull(1)));
            else
                oOptical.oExperiment = oExperiment;
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
        
        function oOptical = GetArrayBeats(oOptical,aPeaks,dThreshold)
            %get the beat information and put it into the electrode struct
            
            aInData = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,oOptical.Electrodes(1).Status,'Data');
            if ~isfield(oOptical.Electrodes(1),'Processed')
                oOptical.Electrodes = MultiLevelSubsAsgn(oOptical.oDAL.oHelper,oOptical.Electrodes,'Processed','Data',aInData);
            end
            [aOutData dMaxPeaks] =  oOptical.GetSinusBeats(aInData, aPeaks);
            %Split again into the Electrodes
            oOptical.Electrodes = MultiLevelSubsAsgn(oOptical.oDAL.oHelper,oOptical.Electrodes,'Processed','Beats',cell2mat(aOutData(1)));
            oOptical.Beats.Indexes = cell2mat(aOutData(2));
            oOptical.Beats.Threshold = dThreshold;
            %loop through beats and calculate sinus rates
            oOptical.FinishProcessing();
            oOptical.CalculateSinusRate();
        end
        
        function oMapData = PrepareActivationMap(oOptical, dInterpDim, sPlotType, sEventID, iSupportPoints, iBeatIndex, oActivationData)
            %Get the inputs for a mapping call for activation times,
            %returning a struct containing the x and y locations of the
            %electrodes and the activation times for each. dInterpDim is
            %the number of interpolation points in each direction
                        
            switch (sPlotType)
                case 'Scatter'
                    oWaitbar = waitbar(0,'Please wait...');
                    close(oWaitbar);
                case 'Contour'
                    %get the accepted channels
                    aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
                    aElectrodes = oOptical.Electrodes(logical(aAcceptedChannels));
                    if isempty(oActivationData)
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
                        
                        %Initialise the map data struct
                        oMapData = struct('x', xlin, 'y', ylin, 'Boundary', aInBoundaryPoints, 'r2', [],'CVx',aFullCoords(:,1),'CVy',aFullCoords(:,2),'DT',DT);
                        %Initialise the Beats struct
                        aData = struct('FullActivationTimes',zeros(1, numel(oOptical.Electrodes)),'ActivationTimes',...
                            [],'z',NaN(size(xlin)),'CVApprox',zeros(1, numel(oOptical.Electrodes)),...
                            'CVVectors',zeros(1, numel(oOptical.Electrodes)),'ATgrad',zeros(1, numel(oOptical.Electrodes)));
                        oMapData.Beats = repmat(aData,1,size(oOptical.Beats.Indexes,1));
                    else
                        oMapData = oActivationData;
                    end
                    
                    %Get the activation indexes
                    aActivationIndexes = zeros(numel(aElectrodes),1);
                    aFullActivationIndexes = zeros(numel(oOptical.Electrodes),1);
                    aFullActivationTimes = zeros(numel(oOptical.Electrodes),1);
                    %track the number of accepted electrodes
                    m = 0;
                    for p = 1:numel(oOptical.Electrodes)
                        if oOptical.Electrodes(p).Accepted
                            m = m + 1;
                            if aElectrodes(m).(sEventID).Index(iBeatIndex) > 1
                            else
                                oOptical.MarkEvent(sEventID, iBeatIndex, p);
                                aElectrodes(m).(sEventID).Index(iBeatIndex) = oOptical.Electrodes(p).(sEventID).Index(iBeatIndex);
                            end
                            aActivationIndexes(m) = aElectrodes(m).(sEventID).Index(iBeatIndex) - 1 + oOptical.Beats.Indexes(iBeatIndex,1);
                            aFullActivationIndexes(p) =  aElectrodes(m).(sEventID).Index(iBeatIndex) - 1 + oOptical.Beats.Indexes(iBeatIndex,1);
                            aFullActivationTimes(p) = oOptical.TimeSeries(aFullActivationIndexes(p));
                        else
                            %hold the unaccepted electrode places with inf
                            aFullActivationTimes(p) = Inf;
                        end
                    end
                    
                    %Get the activation time fields for all time points during this
                    %beat
                    aActivationTimes = oOptical.TimeSeries(aActivationIndexes)';
                    %                     aFullActivationTimes =
                    %                     aFullActivationTimes';
                    %convert to ms
                    oMapData.Beats(iBeatIndex).ActivationTimes = 1000*(aActivationTimes - min(aActivationTimes));
                    oMapData.Beats(iBeatIndex).FullActivationTimes = 1000*(aFullActivationTimes - min(aFullActivationTimes));                    
                    %do interpolation
                    %calculate interpolant
                    oInterpolant = TriScatteredInterp(oMapData.DT,oMapData.Beats(iBeatIndex).ActivationTimes);
                    %evaluate interpolant
                    oInterpolatedField = oInterpolant(oMapData.x,oMapData.y);
                    %rearrange to be able to apply boundary
                    aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
                    %apply boundary
                    aQZArray(~oMapData.Boundary) = NaN;
                    %save result back in proper format
                    oMapData.Beats(iBeatIndex).z  = reshape(aQZArray,size(oMapData.x,1),size(oMapData.x,2));
                    
                    %Calculate the CV and save the results
                    [CVApprox,CVVectors,ATgrad]=ReComputeCV([oMapData.CVx,oMapData.CVy],oMapData.Beats(iBeatIndex).FullActivationTimes,iSupportPoints,0.1);
                    oMapData.Beats(iBeatIndex).CVApprox = CVApprox;
                    oMapData.Beats(iBeatIndex).CVVectors = CVVectors;
                    oMapData.Beats(iBeatIndex).ATgrad = ATgrad;
            end
        end
        
        function oMapData = PreparePotentialMap(oOptical, dInterpDim, iBeatIndex, oPotentialData)
            %get the accepted channels
            aAcceptedChannels = MultiLevelSubsRef(oOptical.oDAL.oHelper,oOptical.Electrodes,'Accepted');
            aElectrodes = oOptical.Electrodes(logical(aAcceptedChannels));
            if isempty(oPotentialData) || size(oPotentialData.DT,1) ~= length(aElectrodes)
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
                
                %Initialise the map data struct
                oMapData = struct('x', xlin, 'y', ylin, 'Boundary', aInBoundaryPoints,'DT',DT);
                %Initialise the Beats struct
                aData = struct('Fields',[]);
                oMapData.Beats = repmat(aData,1,size(oOptical.Beats.Indexes,1));
            else
                %use what was previously created
                oMapData = oPotentialData;
            end
            %get data for this beat
            aAllBeatPotentials = MultiLevelSubsRef(oOptical.oDAL.oHelper,aElectrodes,'Processed','Data');
            aSingleBeatPotentials = aAllBeatPotentials(oOptical.Beats.Indexes(iBeatIndex,1):oOptical.Beats.Indexes(iBeatIndex,2),:);
            %initialise array to hold normalised data
            aNormalisedData = zeros(size(aSingleBeatPotentials));
            %Loop through electrodes and normalise data
            for i = 1:size(aSingleBeatPotentials,2)
                %get the baseline and peak values
                dBaseLine = mean(aSingleBeatPotentials(1:15,i));
                aNormalisedData(:,i) = (aSingleBeatPotentials(:,i)+sign(dBaseLine)*(-1)*abs(dBaseLine));
                %                 dPeak = max(aNormalisedData(:,i));
                %                 aNormalisedData(:,i) = aNormalisedData(:,i)./dPeak;
            end
            
            %initialise the struct to hold all the interpolated fields
            oFields = struct('z',NaN(size(oMapData.x)));
            oMapData.Beats(iBeatIndex).Fields = repmat(oFields,size(aNormalisedData,1),1);
            %loop through time points and do interpolation
            for j = 1:size(aNormalisedData,1)
                %do interpolation
                %calculate interpolant
                oInterpolant = TriScatteredInterp(oMapData.DT,aNormalisedData(j,:)');
                %evaluate interpolant
                oInterpolatedField = oInterpolant(oMapData.x,oMapData.y);
                %rearrange to be able to apply boundary
                aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
                %apply boundary
                aQZArray(~oMapData.Boundary) = NaN;
                %save result back in proper format
                oMapData.Beats(iBeatIndex).Fields(j).z  = reshape(aQZArray,size(oMapData.x,1),size(oMapData.x,2));
            end
        end
        
        function GetReferencePointLocations(oOptical,aFiles)
            % % % This function reads the locations of needle points saved from a
            % optical mapping file in format of two columns (x location, y location) in
            % a csv file
            
            %create an array of structs to hold the locations
            oPoint = struct('Line1',[0 0 0 0],'Line2',[0 0 0 0]);
            oOptical.ReferencePoints = repmat(oPoint,numel(aFiles)*2,1);
            %loop through files to get data
            iCount = 1;
            for i = 1:numel(aFiles)
                aPointData = dlmread(aFiles{i}, ',', 1, 0);
                %loop through the points
                oOptical.ReferencePoints(iCount).Line1 = [aPointData(1,2), aPointData(2,2), aPointData(1,1), aPointData(2,1)];
                oOptical.ReferencePoints(iCount).Line2 = [aPointData(3,2), aPointData(4,2), aPointData(3,1), aPointData(4,1)];
                iCount = iCount + 1;
            end
        end
    end
    
end