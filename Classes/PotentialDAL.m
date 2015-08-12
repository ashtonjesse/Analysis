classdef PotentialDAL < BaseDAL
    % PotentialDAL is the DAL class for entities that inherit from the
    % BasePotential class
    
    methods
        function oPotentialDAL = PotentialDAL()
            %%  Constructor
            oPotentialDAL = oPotentialDAL@BaseDAL();
        end
    end
    
    methods (Access = public)
        %% Public Inherited Methods
        function oData = GetEntityFromFile(oPotentialDAL,sFile)
            oData = GetEntityFromFile@BaseDAL(oPotentialDAL,sFile);
        end
        
        function oData = LoadFromFile(oPotentialDAL,sFile)
            oData = LoadFromFile@BaseDAL(oPotentialDAL,sFile);
        end
        
        function oEntity = CreateEntityFromFile(oPotentialDAL,sFile)
            oEntity = CreateEntityFromFile@BaseDAL(oPotentialDAL,sFile);
        end
        
        function SaveThisEntity(oPotentialDAL,oEntity,sPath)
            SaveThisEntity@BaseDAL(oPotentialDAL,oEntity,sPath);
        end
    end
    
    methods (Access = public)
        function oElectrodes = GetElectrodesFromConfigFile(oPotentialDAL,iNumberOfElectrodes,sFile,iSpecificElectrode)
            %Parses the file specified by sFile and populates an oElectrodes
            %struct.
            %If you want a number of electrodes then specify
            %iNumberOfElectrodes > 0 and iSpecificElectrode = 0
            %If you want just a specific electrode then specify
            %iSpecificElectrode > 0
                      
            %Intitialise the struct
            oElectrodes = struct('Name', zeros(iNumberOfElectrodes,1));
            iElectrodeCount = 0;
            %Open the file and put into fid handle
            fid = fopen(sFile);
            %Get and discard the first 2 lines
            tline1 = fgets(fid);
            tline2 = fgets(fid);
            tline = fgets(fid);
            %Loop while there are new lines
            while ischar(tline) 
                %Split the current line on the :
                [~,~,~,~,~,~,splitstring] = regexpi(tline,':');
                %Trim any white space off the split strings
                sField = strtrim(char(splitstring(1,1)));
                oValue  = strtrim(char(splitstring(1,2)));
                switch (sField)
                    case 'electrode'
                        %Increment the electrode count
                        iElectrodeCount = iElectrodeCount + 1;
                        if iSpecificElectrode > 0
                            %Check to see if the electrode count has reached
                            %the specific electrode
                            if iElectrodeCount == iSpecificElectrode
                                %Initialise the electrode struct
                                oElectrodes.Name = oValue;
                                oElectrodes.Accepted = 1;
                                oElectrodes.Activation = [];
                                oElectrodes.Potential = [];
                                oElectrodes.Processed = [];
                                oElectrodes.Status = 'Potential';
                                break
                            end
                        else
                            %Check to see if the electrode count has reached
                            %the maximum
                            if iElectrodeCount > iNumberOfElectrodes
                                break
                            end
                            %Initialise the electrode struct
                            oElectrodes(iElectrodeCount).Name = oValue;
                            oElectrodes(iElectrodeCount).Accepted = 1;
                            oElectrodes(iElectrodeCount).Activation = [];
                            oElectrodes(iElectrodeCount).Potential = [];
                            oElectrodes(iElectrodeCount).Processed = [];
                            oElectrodes(iElectrodeCount).Status = 'Potential';
                        end
                    case 'position'
                        if iSpecificElectrode == 0
                            %Split the oValue on the ,
                            [~,~,~,~,~,~,splitstring] = regexpi(oValue,',');
                            sXInfo = strtrim(char(splitstring(1,1)));
                            sYInfo  = strtrim(char(splitstring(1,2)));
                            %Split the sXInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sXInfo,'=');
                            dXPos = str2double(strtrim(char(splitstring(1,2))));
                            %Split the sYInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sYInfo,'=');
                            dYPos = str2double(strtrim(char(splitstring(1,2))));
                            %Get the appropriate position for this
                            %electrode in terms of a row and column index
                            oElectrodes(iElectrodeCount).Coords = [dXPos ; dYPos];
                        end
                    case 'location'
                        if iSpecificElectrode == 0
                            %Split the oValue on the ,
                            [~,~,~,~,~,~,splitstring] = regexpi(oValue,',');
                            sXInfo = strtrim(char(splitstring(1,1)));
                            sYInfo  = strtrim(char(splitstring(1,2)));
                            %Split the sXInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sXInfo,'=');
                            iXLoc = str2double(strtrim(char(splitstring(1,2))));
                            %Split the sYInfo on the =
                            [~,~,~,~,~,~,splitstring] = regexpi(sYInfo,'=');
                            iYLoc = str2double(strtrim(char(splitstring(1,2))));
                            oElectrodes(iElectrodeCount).Location = [iYLoc ; iXLoc];
                        end
                    case 'channel'
                        if iSpecificElectrode == 0
                            oElectrodes(iElectrodeCount).Channel = str2double(oValue);
                        end
                end
                tline = fgets(fid);
            end
            if iSpecificElectrode == 0
                %Trim extra zeros
                oElectrodes = oElectrodes(1:iElectrodeCount-1);
            end
            fclose(fid);
        end
        
        function GetDataFromSignalFile(oPotentialDAL,oUnemap,sFile)
            %Get the potential data from a signal file and puts into the
            %correct field of the Electrodes struct
            
            %Load the potential data from the txt file
            aFileContents = oPotentialDAL.LoadFromFile(sFile);
            %Get the electrode list by reading the first line from the file
            fid = fopen(sFile,'r');
            headline = fgets(fid);
            fclose(fid);
            %split the string into the channel names
            aChannelNames = regexp(headline, '\s+', 'split');
            %drop the first character which should be a comment character
            aChannelNames = aChannelNames(1,2:end); 
            
            %check if the channels of this data need to be rearranged
            [pathstr, name, ext, versn] = fileparts(sFile);
            aPath = regexp(pathstr,'\\','split');
            if str2double(char(aPath(end))) < 20130428
                %this file was  created before the config file was adjusted
                %so some channels are incorrectly labelled
                %open the file that describes the updated mapping
                fid = fopen('D:\Users\jash042\Documents\PhD\Experiments\ElectrodeArray\UpdatedMapping.cnfg','r');
                tline = fgetl(fid);
                while tline > 0
                    aLine = regexp(tline,'\:','split');
                    %find this electrode in the names
                    bInd = strcmp(char(aLine(1)), aChannelNames);
                    %update it to the new name
                    iInd = find(bInd);
                    if length(iInd) > 1
                        %this must be the last mapping
                        aChannelNames(iInd(1)) = {strtrim(char(aLine(2)))};
                    else
                        aChannelNames(bInd) = {strtrim(char(aLine(2)))};
                    end
                    %get the new line
                    tline = fgetl(fid);
                end
                fclose(fid);
            end
            
            %get the list of channel names loaded
            aElectrodeNames = {oUnemap.Electrodes(:).Name};
            %Get the potential data and initialise processed.data
            for i = 1:length(aElectrodeNames)
                %Find the index of this electrode 
                bIndices = strcmp(aElectrodeNames(i), aChannelNames);
                %save the correct data to this electrode
                oUnemap.Electrodes(i).Potential.Data = aFileContents(:,bIndices);
                oUnemap.Electrodes(i).Processed.Data = NaN(size(aFileContents,1),1);
            end
            %Get the Timeseries data
            oUnemap.TimeSeries = [1:1:size(aFileContents,1)]*(1/oUnemap.oExperiment.Unemap.ADConversion.SamplingRate);
        end
        
        function GetElectrodeFromSignalFile(oPotentialDAL, oUnemap, iElectrodeNumber, sFile)
            %Get the potential data for a given channel from the input
            %signal (txt) file.
            
             %Load the potential data from the txt file
            aFileContents = oPotentialDAL.LoadFromFile(sFile);
            %Get the potential data and initialise processed.data
            oUnemap.Electrodes.Potential.Data = aFileContents(:,iElectrodeNumber+1);
            oUnemap.Electrodes.Processed.Data = NaN(size(aFileContents,1),1);
            %Get the Timeseries data
            oUnemap.TimeSeries = [1:1:size(aFileContents,1)]*(1/oUnemap.oExperiment.Unemap.ADConversion.SamplingRate);
        end
        
        function GetOpticalDataFromCSVFile(oPotentialDAL, oOptical, sFilePath)
            %Get the potential data for a given channel from the input
            %signal (csv) file.
            
             %Load the potential data from the txt file
             fid = fopen(sFilePath,'r');
             %scan the header information in
             bStillHeader = true;
             iLineCount = 0;
             while bStillHeader
                 tline = fgets(fid);
                 iLineCount = iLineCount + 1;
                 [~,~,~,~,~,~,splitstring] = regexpi(tline,',');
                 if isnan(str2double(splitstring{1}))
                     %splitstring is not a number 
                     switch (splitstring{1})
                         case {'frm num','frm_num'}
                             iNumFrames = str2double(splitstring{2});
                         case 'position'
                             [xLoc yLoc] = strread(splitstring{2},'[%d][%d]');
                             oOptical.Electrodes.Name = strcat(sprintf('%d',xLoc),'_',sprintf('%d',yLoc));
                             oOptical.Electrodes.Location = [xLoc yLoc];
                         case 'time(msec)'
                             if numel(splitstring) > 3
                                 %this file contains data from a full set
                                 %of electrodes
                                 oOptical.Electrodes = repmat(oOptical.Electrodes,1,numel(splitstring)-2);
                                 iElectrodeCount = 1;
                                 %get the electrode location data
                                 for i = 2:numel(splitstring)-1
                                     sPixel = regexprep(char(splitstring{i}),'[','');
                                     [~,~,~,~,~,~,sPixel] = regexpi(sPixel,']');
                                     oOptical.Electrodes(iElectrodeCount).Location(1,1) = str2double(sPixel{2});%row, 0-based 
                                     oOptical.Electrodes(iElectrodeCount).Location(2,1) = str2double(sPixel{1}); %col, 0-based 
                                     oOptical.Electrodes(iElectrodeCount).Coords(1,1) = oOptical.Electrodes(iElectrodeCount).Location(1,1) * ...
                                         oOptical.oExperiment.Optical.SpatialResolution;
                                     oOptical.Electrodes(iElectrodeCount).Coords(2,1) = oOptical.Electrodes(iElectrodeCount).Location(2,1) * ...
                                         oOptical.oExperiment.Optical.SpatialResolution;
                                     oOptical.Electrodes(iElectrodeCount).Name = [sPixel{1},'-',sPixel{2}]; %keep the name so that it matches the source (bvana)
                                     iElectrodeCount = iElectrodeCount + 1;
                                 end
                             end
                     end
                 else
                     %splitstring is a number so stop looping
                     bStillHeader = false;
                 end
             end
             %close the file
             fclose(fid);
             %Read the data (including last column which is empty)
             aData = dlmread(sFilePath, ',', iLineCount, 1);
             %check if the data needs to be inverted
             if max(aData(:,1)) < 0
                 aData = -aData;
             end
             %deal data except for last column
             oOptical.Electrodes = oOptical.oDAL.oHelper.MultiLevelSubsAsgn(oOptical.Electrodes,'Potential','Data',aData(:,1:end-1));
             %create time series array
             oOptical.TimeSeries = [0:1:size(aData,1)-1]*(1/oOptical.oExperiment.Optical.SamplingRate);
        end
        
        function GetSignalEventInformationFromTextFile(oPotentialDAL, oBasePotential, iSignalEventID, sFilePath)
            %Read the data from the specified file and put in the
            %appropriate places for signal event indexes and range
            
            %load data from file
            aOutData = oPotentialDAL.oHelper.ReadDataFromTextFile(sFilePath,'%s');
            aEventData = cellfun(@str2num,aOutData.Body);
            %assumes that the last two columns are range information
            oBasePotential.Electrodes = oBasePotential.oDAL.oHelper.MultiLevelSubsAsgn(oBasePotential.Electrodes,'SignalEvent','Index',aEventData(:,1:end-2),iSignalEventID);
            oBasePotential.Electrodes = oBasePotential.oDAL.oHelper.MultiLevelSubsAsgn(oBasePotential.Electrodes,'SignalEvent','Range',aEventData(:,end-1:end),iSignalEventID);
        end
    end
end

