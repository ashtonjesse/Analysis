classdef DataHelper
    %DataHelper Summary: This is a value class that contains helper methods
    %for processing data. Methods associated with accessing data should be
    %in BaseDAL. 
    %  
        
    methods
        function oDataHelper = DataHelper()
            %         Constructor
            
        end
        
        function oEntity = ParseFileIntoEntity(oDataHelper,sPath)
%         Parses the file specified by sPath and creates an entity that
%         contains all fields specified in the file

%             Intitialise the entity
            oEntity = [];
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
%                 Check if the value string contains any numeric digits
                [matchstart] = regexp(oValue,'\d');
%                 If it does contain numeric digits then convert the
%                 strings to doubles
                if ~isempty(matchstart)
                    oValue = str2double(oValue);
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
                case 3
                    %Get the inputs
                    %The struct to index
                    aStruct = cell2mat(varargin(1,1));
                    %The first field, will not be indexed
                    sFirstField = char(varargin(1,2));
                    %The second fied, will be indexed
                    sSecondField = char(varargin(1,3));
                    %Get the size of the struct and index all of the
                    %elements
                    [a b] = size(aStruct);
                    aFirstLevel =  subsref([aStruct.(sFirstField)],struct('type','()','subs',{{1:b}}));
                    aSecondLevel = aFirstLevel.(sSecondField);
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
                case 4
                    %Get the inputs
                    %The struct to index
                    aStruct = cell2mat(varargin(1,1));
                    %The first field, will not be indexed
                    sFirstField = char(varargin(1,2));
                    %The second fied, will be indexed
                    sSecondField = char(varargin(1,3));
                    %The data to assign
                    aInData = cell2mat(varargin(1,4));
                    
                    %Get the size of the struct and index all of the
                    %elements
                    [a b] = size(aInData);
                    for i = 1:b;
                        aStruct(i).(sFirstField).(sSecondField)(:) = aInData(:,i);
                    end
                    aOutStruct = aStruct;
            end
                       
        end
    end
       
end

