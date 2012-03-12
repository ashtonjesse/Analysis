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
        
    end
       
end

