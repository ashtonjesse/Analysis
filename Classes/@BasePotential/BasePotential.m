classdef BasePotential < BaseSignal
    %   BasePotential 
    %   This is the base class for all entities that hold experimental data
    %   of the potential type. 
    
    properties
    end
    
    methods
        %% Constructor
        function oBasePotential = BasePotential()
            oBasePotential = oBasePotential@BaseSignal();
            oBasePotential.oDAL = PotentialDAL();
        end
    end
        
    methods (Access = public)
        function OutData = RemoveLinearInterpolation(oBasePotential, aInData, iOrder)
            %       *RemoveInterpolation - Using linear
            %       interpolation between isoelectric points to remove this
            %       variation between beats
            
            %Split the input cell array into data and beats
            aElectrodeData = cell2mat(aInData(1,1));
            aBeats = cell2mat(aInData(1,2));
            %Loop through each row find the first non-NaN numbers in
            %aBeats.
            [x y] = size(aBeats);
            aAverages = zeros(1,y+1);
            OutData = zeros(x,y);
            iBeatFound = 0;
            for i = 1:x;
                if ~isnan(aBeats(i,1)) && ~iBeatFound && i>30
                    %Take the previous 30 values of
                    %ElectrodeData before the current beat
                    aAverages = [aAverages ; i, mean(aElectrodeData((i-30):i,:))];
                    iBeatFound = 1;
                    %Could get an error if the first beat is within
                    %10 values of the start of the recording
                    %elseif ~isnan(aBeats(i,1)) && i <= 10
                    %%If the beat is within 10 of the beginning
                    %%of the data then take average of as many values as
                    %%there are before the current record.
                    %Averages = [aAverages ; mean(aElectrodeData(1:i,:))];
                elseif isnan(aBeats(i,1))
                    iBeatFound = 0;
                end
            end
            if ~iBeatFound
                aAverages = [aAverages ; i, aElectrodeData(i,:)];
            end
            %Remove zero in first place
            %aAverages(1,:) = aAverages(size(aAverages,1),:);
            aAverages = aAverages(2:size(aAverages,1),:);
            %Initialise the output array and Loop through channels
            OutData = zeros(size(aInData,1),size(aInData,2));
            for j = 1:y;
                %Pass in a cell array with the first element being
                %an array of the indexes of averages and the second
                %being the actual averages them selves.
                OutData(:,j) = fInterpolate({aAverages(:,1),aAverages(:,j+1)},iOrder,x);
            end
        end
      
        function DeleteBeat(oBasePotential, iBeat)
            %Check if there is an electrodes field
            if strcmpi(class(oBasePotential),'Unemap')
                %Loop through the electrodes and delete the beat number
                %iBeat
                for i = 1:length(oBasePotential.Electrodes)
                    oBasePotential.Electrodes(i).Processed.Beats(oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat,1): ...
                        oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat,2)) = NaN;
                    oBasePotential.Electrodes(i).Processed.BeatIndexes = vertcat(oBasePotential.Electrodes(i).Processed.BeatIndexes(1:iBeat-1,:), ...
                        oBasePotential.Electrodes(i).Processed.BeatIndexes(iBeat+1:end,:));
                end
            else
                %Just delete the beat and beatindexes
                oBasePotential.Processed.Beats(oBasePotential.Processed.BeatIndexes(iBeat,1): ...
                    oBasePotential.Processed.BeatIndexes(iBeat,2)) = NaN;
                oBasePotential.Processed.BeatIndexes = vertcat(oBasePotential.Processed.BeatIndexes(1:iBeat-1,:), ...
                    oBasePotential.Processed.BeatIndexes(iBeat+1:end,:));
            end
            
        end
    end
    
end

