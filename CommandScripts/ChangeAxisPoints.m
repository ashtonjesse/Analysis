%this script reads optical mapping files and changes the axis point
%locations to that of a reference files

oOpticalRef = GetOpticalFromMATFile(Optical, 'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004\CCh004a_g10_LP100Hz-waveEach.mat');
%get the axis points
aRefAxisData = cell2mat({oOpticalRef.Electrodes(:).AxisPoint});
%list files
aFolders = {...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh004' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh005' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh006' ...
    'G:\PhD\Experiments\Auckland\InSituPrep\20140814\20140814CCh007' ...
    };

%loop through the files
for i = 1:numel(aFolders)
    sFolder = aFolders{i};
    sRoot = sFolder(end-2:end);
    sType = 'CCh';
    switch (i)
        case 1
            sEachFileName = {...
                [aFolders{i},'\',sType,sRoot,'b_g10_LP100Hz-waveEach.mat'] ...
                [aFolders{i},'\',sType,sRoot,'c_g10_LP100Hz-waveEach.mat'] ...
                [aFolders{i},'\',sType,sRoot,'d_g10_LP100Hz-waveEach.mat'] ...
                };
        otherwise
            sEachFileName = {...
                [aFolders{i},'\',sType,sRoot,'a_g10_LP100Hz-waveEach.mat'] ...
                [aFolders{i},'\',sType,sRoot,'b_g10_LP100Hz-waveEach.mat'] ...
                [aFolders{i},'\',sType,sRoot,'c_g10_LP100Hz-waveEach.mat'] ...
                };
    end
    for j = 1:numel(sEachFileName)
        %get the optical file
        oThisOptical = GetOpticalFromMATFile(Optical, sEachFileName{j});
        %get existing axis points
        aThisAxisData = cell2mat({oThisOptical.Electrodes(:).AxisPoint});
        if numel(aThisAxisData) ~= numel(aRefAxisData)
            disp('problem');
            break;
        end
        %clear existing axis points
        oThisOptical.ClearAxisPoint(aThisAxisData);
        %mark new axis points
        oThisOptical.MarkAxisPoint(aRefAxisData);
        %save the file
        oThisOptical.Save(sEachFileName{j});
        fprintf('Saved file %s\n',sEachFileName{j});
    end
end
    