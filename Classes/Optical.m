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
                            zeros(1, numel(aElectrodes)),'z',NaN(size(xlin)),'CVApprox',zeros(1, numel(oOptical.Electrodes)),...
                            'CVVectors',zeros(1, numel(oOptical.Electrodes)),'ATgrad',zeros(1, numel(oOptical.Electrodes)));
                        oMapData.Beats = repmat(aData,1,size(oOptical.Electrodes(1).SignalEvent(iEventID).Index,1));
                        %Get the activation indexes
                        aActivationIndexes = zeros(size(oOptical.Electrodes(1).SignalEvent(iEventID).Index,1), numel(aElectrodes));
                        aFullActivationIndexes = zeros(size(oOptical.Electrodes(1).SignalEvent(iEventID).Index,1), numel(oOptical.Electrodes));
                        aFullActivationTimes = zeros(size(aFullActivationIndexes));
                        %track the number of accepted electrodes
                        m = 0;
                        for p = 1:numel(oOptical.Electrodes)
                            if oOptical.Electrodes(p).Accepted
                                m = m + 1;
                                aActivationIndexes(:,m) = aElectrodes(m).SignalEvent(iEventID).Index;
                                aFullActivationIndexes(:,p) =  aElectrodes(m).SignalEvent(iEventID).Index + oOptical.Electrodes(p).Processed.BeatIndexes(:,1);
                                aFullActivationTimes(:,p) = oOptical.TimeSeries(aFullActivationIndexes(:,p));
                            else
                                %hold the unaccepted electrode places with inf
                                aFullActivationTimes(:,p) =  Inf;
                            end
                        end
                        %initialise the activation times array
                        aActivationTimes = zeros(size(aActivationIndexes));
                        %set up wait bar
                        oWaitbar = waitbar(0,'Please wait...');
                        %Loop through the beats
                        for k = 1:size(aActivationIndexes,1)
                            %Get the activation time fields for all time points during this
                            %beat
                            waitbar(k/size(aActivationIndexes,1),oWaitbar,sprintf('Please wait... Processing Beat %d',k));
                            aActivationIndexes(k,:) = aActivationIndexes(k,:) + oOptical.Electrodes(1).Processed.BeatIndexes(k,1);
                            aTimesToUse = oOptical.TimeSeries(aActivationIndexes(k,:));
                            aActivationTimes(k,:) = aTimesToUse;
                            %convert to ms
                            aActivationTimes(k,:) = 1000*(oOptical.TimeSeries(aActivationIndexes(k,:)) - min(aTimesToUse));
                            aFullActivationTimes(k,:) = 1000*(aFullActivationTimes(k,:) - min(aFullActivationTimes(k,:)));
                            
                            %save to struct
                            oMapData.Beats(k).FullActivationTimes = aFullActivationTimes(k,:).';
                            oMapData.Beats(k).ActivationTimes = aActivationTimes(k,:).';
                            
                            %do interpolation
                            %calculate interpolant
                            oInterpolant = TriScatteredInterp(DT,oMapData.Beats(k).ActivationTimes);
                            %evaluate interpolant
                            oInterpolatedField = oInterpolant(xlin,ylin);
                            %rearrange to be able to apply boundary
                            aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
                            %apply boundary
                            aQZArray(~aInBoundaryPoints) = NaN;
                            %save result back in proper format
                            oMapData.Beats(k).z  = reshape(aQZArray,size(xlin,1),size(xlin,2));
                            
                            %Calculate the CV and save the results
                            [CVApprox,CVVectors,ATgrad]=ReComputeCV([aFullCoords(:,1),aFullCoords(:,2)],oMapData.Beats(k).FullActivationTimes,iSupportPoints,0.1);
                            oMapData.Beats(k).CVApprox = CVApprox;
                            oMapData.Beats(k).CVVectors = CVVectors;
                            oMapData.Beats(k).ATgrad = ATgrad;
                        end
                        close(oWaitbar);
                    end
                    
                    if ~isempty(oActivationData) && ~isempty(iBeatIndex)
                        %Activation data is not empty and a beat index has
                        %been supplied so only refresh the map for this
                        %beat
                        aTempData = oOptical.oDAL.oHelper.MultiLevelSubsRef(aElectrodes,'SignalEvent','Index',iEventID);
                        aActivationIndexes = aTempData(iBeatIndex,:) + oOptical.Electrodes(1).Processed.BeatIndexes(iBeatIndex,1);
                        aTempData = oOptical.oDAL.oHelper.MultiLevelSubsRef(oOptical.Electrodes,'SignalEvent','Index',iEventID);
                        aOutActivationIndexes = aTempData(iBeatIndex,:) + oOptical.Electrodes(1).Processed.BeatIndexes(iBeatIndex,1);
                        clear aTempData;
                        aOutActivationTimes = oOptical.TimeSeries(aOutActivationIndexes);
                        aOutActivationTimes(~logical(aAcceptedChannels)) = Inf;
                        aAcceptedTimes = oOptical.TimeSeries(aActivationIndexes);
                        %Convert to ms
                        aActivationTimes = 1000*(oOptical.TimeSeries(aActivationIndexes) - min(aAcceptedTimes));
                        aOutActivationTimes = 1000*(aOutActivationTimes - min(aOutActivationTimes));

                        %reinitialise z array
                        oActivationData.Beats(iBeatIndex).z = [];
                        oActivationData.Beats(iBeatIndex).z = NaN(size(xlin));
                        oActivationData.Beats(iBeatIndex).FullActivationTimes = aOutActivationTimes.';
                        oActivationData.Beats(iBeatIndex).ActivationTimes = aActivationTimes.';
                        
                        %do interpolation
                        %calculate interpolant
                        oInterpolant = TriScatteredInterp(DT,oActivationData.Beats(iBeatIndex).ActivationTimes);
                        %evaluate interpolant
                        oInterpolatedField = oInterpolant(xlin,ylin);
                        %rearrange to be able to apply boundary
                        aQZArray = reshape(oInterpolatedField,size(oInterpolatedField,1)*size(oInterpolatedField,2),1);
                        %apply boundary
                        aQZArray(~aInBoundaryPoints) = NaN;
                        %save result back in proper format
                        oActivationData.Beats(iBeatIndex).z  = reshape(aQZArray,size(xlin,1),size(xlin,2));
                        
                        %Calculate the CV and save the results
                        [CVApprox,CVVectors,ATgrad]=ReComputeCV([aFullCoords(:,1),aFullCoords(:,2)],oActivationData.Beats(iBeatIndex).FullActivationTimes,iSupportPoints,0.1);
                        oActivationData.Beats(iBeatIndex).CVApprox = CVApprox;
                        oActivationData.Beats(iBeatIndex).CVVectors = CVVectors;
                        oActivationData.Beats(iBeatIndex).ATgrad = ATgrad;
                        oMapData = oActivationData;
                        clear oActivationData;
                    else
                        oWaitbar = waitbar(0,'Please wait...');
                        %neither a beatindex or activationdata has been
                        %specified so refresh for all
                        %Loop through the beats
                        for k = 1:size(aActivationIndexes,1)
                            
                        end
                        close(oWaitbar);
                    end
            end
        end
    end
    
end