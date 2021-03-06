classdef DataHelper
    %DataHelper Summary: This is a value class that contains helper methods
    %for processing data. Methods associated with accessing data should be
    %in BaseDAL. 
    %  
        
    methods
        function oDataHelper = DataHelper()
            %         Constructor
            
        end
        
        function oEntity = ParseFileIntoEntity(oDataHelper,oEntity,sPath)
            %         Parses the file specified by sPath and creates an entity that
            %         contains all fields specified in the file
            
            
            %             Open the file and put into fid handle
            fid = fopen(sPath);
            %             Get the first line
            tline = fgets(fid);
            %             Loop while there are new lines
            while ischar(tline)
                %                 Split the current line on the =
                [~,~,~,~,~,~,splitstring] = regexpi(tline,'=');
                %                 Trim any white space off the split strings
                sField = strtrim(char(splitstring(1,1)));
                oValue  = strtrim(char(splitstring(1,2)));
                %                 Check if the value string contains
                %                 backslashes
                [matchstart] = regexp(oValue,'\\');
                if isempty(matchstart)
                    %                 Check if the value string contains any numeric digits
                    [matchstart] = regexp(oValue,'\d');
                    %                 If it does contain numeric digits then convert the
                    %                 strings to doubles
                    if ~isempty(matchstart)
                        %Check if it is an array variable (assumes only a 2 x 2
                        %structure)
                        [matchstart,~,~,~,~,~,splitstring] = regexp(oValue,'[');
                        if ~isempty(matchstart)
                            % Get the array contents
                            oValue  = strtrim(char(splitstring(1,2)));
                            % Split the rows
                            [~,~,~,~,~,~,splitstring] = regexp(oValue,';');
                            aFirstRow = strtrim(char(splitstring(1,1)));
                            aSecondRow = strtrim(char(splitstring(1,2)));
                            %Remove the last bracket
                            [~,~,~,~,~,~,splitstring] = regexp(aSecondRow,']');
                            aSecondRow = strtrim(char(splitstring(1,1)));
                            %Split the contents of each row
                            [~,~,~,~,~,~,splitstring] = regexp(aFirstRow,',');
                            dOneOne = strtrim(char(splitstring(1,1)));
                            dOneTwo = strtrim(char(splitstring(1,2)));
                            [~,~,~,~,~,~,splitstring] = regexp(aSecondRow,',');
                            dTwoOne = strtrim(char(splitstring(1,1)));
                            dTwoTwo = strtrim(char(splitstring(1,2)));
                            %Reconstruct the array
                            oValue = [str2double(dOneOne), str2double(dOneTwo); ...
                                str2double(dTwoOne), str2double(dTwoTwo)];
                        else
                            %Is just a numeric digit
                            oValue = str2double(oValue);
                        end
                    end
                end
                %                 See if this string contains more than one level of
                %                 structured array
                [matchstart] = regexpi(sField,'\.');
                if isempty(matchstart)
                    %                     If only one level then just add this to the entity
                    oEntity.(sField) = oValue;
                else
                    %                     If more than one level then create a temporary
                    %                     structured array that has two fields - type and
                    %                     subs where subs contains the names of the fields
                    %                     to add to the structured array
                    temp = struct('type','.','subs',regexp(sField,'\.','split'));
                    %                      Assign these fields to the entity structured array
                    %                      and set the value
                    subsasgn(oEntity, temp, oValue);
                end
                %                 Get the next line
                tline = fgets(fid);
            end
            %           Close the file
            fclose(fid);
        end
        
        function aData = MultiLevelSubsRef(oDataHelper,varargin)
            %Carries out a subsref method on multilevel
            %struct
                       
            switch size(varargin,2);
                case 2
                    %Get the inputs of which there should be a structure
                    %and one field
                    %Suits a situation where there is an array of structs
                    %that have a field which is an array and you want to get
                    %an array of all these arrays together
                    aStruct = cell2mat(varargin(1,1));
                    %The field to be indexed
                    sFirstField = char(varargin(1,2));
                    %Get the size of the struct and index all of the
                    %elements
                    [a b] = size(aStruct);
                    %Get the size of the first level arrays
                    [u v] = size([aStruct.(sFirstField)]);
                    aData =  subsref([aStruct.(sFirstField)],struct('type','()','subs',{{1:u 1:b}}));
                case {3,4}
                    %Get the inputs of which there should be a structure
                    %and then two fields
                    %Suits a situation where there is an array of structs
                    %that have a field which is a struct that in turn has a
                    %field that is an array and you want all these arrays
                    %together (columns put side by side)
                    
                    %The struct to index
                    aStruct = cell2mat(varargin(1,1));
                    %The first field, will not be indexed
                    sFirstField = char(varargin(1,2));
                    %The second fied, will be indexed
                    sSecondField = char(varargin(1,3));
                    if size(varargin,2) == 4
                        iIndex = cell2mat(varargin(1,4));
                    else
                        iIndex = 1;
                    end
                    %Get the size of the struct and index all of the
                    %elements
                    [a b] = size(aStruct);
                    %try to access the specified fields
                    try 
                        aFirstLevel =  subsref([aStruct.(sFirstField)],struct('type','()','subs',{{iIndex 1:b}}));
                    catch ex
                        aData = [];
                        return
                    end
                    try
                        aSecondLevel = aFirstLevel.(sSecondField);
                    catch ex
                        aData = [];
                        return
                    end
                    %Get the size of the second level array and index all
                    %of the elements
                    [i j] = size(aSecondLevel);
                    aData = subsref([aFirstLevel.(sSecondField)],struct('type','()','subs',{{1:i 1:b}}));
            end
                       
        end
        
        function aOutStruct = MultiLevelSubsAsgn(oDataHelper,varargin)
            %Carries out a subsasgn method on multilevel
            %struct
                        
            switch size(varargin,2);
                case 3
                    %Get the inputs
                    %The struct to index
                    aStruct = cell2mat(varargin(1,1));
                    %The first field, will not be indexed
                    sFirstField = char(varargin(1,2));
                    %The data to assign
                    aInData = cell2mat(varargin(1,3));
                    
                    %Get the size of the struct and index all of the
                    %elements
                    [a b] = size(aInData);
                    [x y] = size(aStruct);
                    if b == y
                        for i = 1:b;
                            aStruct(i).(sFirstField) = aInData(:,i);
                        end
                        aOutStruct = aStruct;
                    end
                case {4,5}
                    %Get the inputs
                    %The struct to index
                    aStruct = cell2mat(varargin(1,1));
                    %The first field, will not be indexed
                    sFirstField = char(varargin(1,2));
                    %The second fied, will be indexed
                    sSecondField = char(varargin(1,3));
                    %The data to assign
                    aInData = cell2mat(varargin(1,4));
                    if size(varargin,2) == 5
                        iIndex = cell2mat(varargin(1,5));
                    else
                        iIndex = 1;
                    end
                    %Get the size of the struct and index all of the
                    %elements
                    [a b] = size(aInData);
                    [x y] = size(aStruct);
                    if b == y
                        for i = 1:b;
                            aStruct(i).(sFirstField)(iIndex).(sSecondField) = aInData(:,i);
                        end
                    else
                        for i = 1:y;
                            aStruct(i).(sFirstField)(iIndex).(sSecondField) = aInData;
                        end
                    end
                    aOutStruct = aStruct;
            end
                       
        end
        
        function oHandle = GetHandle(oDataHelper,oParent,sNeededTag)
            %Needs expanding to allow for a range of inputs but at the
            %moment it checks through a list of handles and finds the
            %handle to the object that has the tag requested
            tags = get(oParent,'tag');
            %Initialise oHandle
            oHandle = -1;
            for i = 1:length(tags)
                if strcmpi(char(tags(i)), char(sNeededTag))
                    oHandle = oParent(i);
                    return 
                end
            end
        end
        
        function iMinIndex = ConvertTimeToSeriesIndex(oDataHelper,aTimeSeries,dTime)
            %Return the index of the time point closest to the time
            %specified in dTime
            
            %Find the abs difference of all times vs the dTime
            aDiff = abs(aTimeSeries - dTime);
            [dMin, iMinIndex] = min(aDiff);
            iMinIndex = iMinIndex;
        end
        
        function out = StringIsNumeric(oDataHelper,oString)
            % Is string numeric?
            if ~ischar(oString)
                %error('str_isnumeric:NonCharacterArray','not a string input');
                out = 0;
            end
            
            Nd = sum(isstrprop(oString,'digit'));
            Nc = length(oString);
            
            dN = Nc - Nd;
            
            switch dN
                case 0
                    out = 1;
                otherwise
                    out = 0;
            end
        end
                
    end
    
    methods (Static)
        function aOutData = ColToArray(aInData,iXDim,iYDim)
            %Reshape the column vector into an array. iXDim is the number
            %of rows in the basic grouping block of the array multiplied by
            %the number of grouping blocks and iYDim is the number of
            %columns in the grouping block.
            
            %Reshape the array into iXDim x iYDim
            aHalfWay = transpose(reshape(aInData,iYDim,iXDim));
            [iMaxRows, iMaxColumns] = size(aHalfWay);
            %Reshape the array so that the grouping blocks are arranged
            %correctly
            aOutData = [aHalfWay(1:(iMaxRows/2),1:iMaxColumns) , aHalfWay((iMaxRows/2)+1:iMaxRows,1:iMaxColumns)];
        end
        
        function aOutData = ArrayToCol(aInData)
            %Reshape an array in to a column vector. iXDim is the number
            %of rows in the basic grouping block of the array multiplied by
            %the number of grouping blocks and iYDim is the number of
            %columns in the grouping block.
            [iMaxRows, iMaxColumns] = size(aInData);
            aHalfWay = [aInData(1:iMaxRows,1:(iMaxColumns/2)) ; aInData(1:iMaxRows,((iMaxColumns/2)+1):iMaxColumns)];
            aHalfWay = transpose(aHalfWay);
            aOutData = reshape(aHalfWay,iMaxRows*iMaxColumns,1);
        end
        
        function dOutput = GetDoubleFromString(sInString)
            %Read the string and extract the number
              [~,~,~,matchstring,~,~,~] = regexp(sInString,'\d');
             if ~isempty(matchstring)
                 sCombined = '';
                 for i = 1:length(matchstring)
                     sCombined = strcat(sCombined,matchstring(i));
                 end
                 dOutput = str2double(sCombined);
             end
        end
       
        function fid = ExportDataToTextFile(sfilename, aRowIDs, aRowData, sFormat, bCommaDelimit)
            %This function writes out the input data to a text file
            %open a new text file for writing
            %loop through the rows and write out the data with the
            %row id first
            fid = fopen(sfilename,'w','n','US-ASCII');
            fprintf(fid,'%s,',aRowIDs{1:end-1});
            fprintf(fid,'%s',aRowIDs{end});
            fprintf(fid,'%s\n','');
            for i = 1:size(aRowData,1)
                if bCommaDelimit
                    fprintf(fid,strcat(sFormat,','),aRowData(i,1:end-1));
                    fprintf(fid,sFormat,aRowData(i,end));
                else
                    fprintf(fid,sFormat,aRowData(i,1:end));
                end
                fprintf(fid,'%s\n','');
            end
            fclose(fid);
        end
        
        function aOutData = ReadDataFromTextFile(sFilename,sFormat)
            %This function reads data from a text file and saves the data
            %to the output variable
            %it assumes that the first row is a header
            %loop through the rows and read in the data
            fid = fopen(sFilename,'r');
            %get the header
            sHeader = fgetl(fid);
            aHeader = regexp(sHeader,',','split');
            %get the body
            sBody = fscanf(fid,sFormat);
            aBody = regexp(sBody,',','split');
            %remove the last element as this will be empty
            aBody= aBody(1:end-1);
            %get the number of rows
            nRows = length(aBody)/length(aHeader);
            %reshape the body data
            aBodyData = reshape(aBody,length(aHeader),nRows);
            aBodyData = aBodyData';
            aOutData = struct('Header',[],'Body',[]);
            aOutData.Header = aHeader;
            aOutData.Body = aBodyData;
            fclose(fid);
        end
        
        function aFilePath = GetFiles()
            [sDataFileName,sDataPathName]=uigetfile('*.*','Select file(s)','multiselect','on');
            if ~iscell(sDataFileName)
                sDataFileName = {sDataFileName};
            end
            if (~ischar(sDataFileName{1}) && ~ischar(sDataPathName))
                aFilePath = [];
                return;
            end
            aFilePath = cell(numel(sDataFileName),1);
            for i = 1:numel(sDataFileName)
                aFilePath{i}=strcat(sDataPathName,char(sDataFileName{i}));
            end
        end
    end
end
