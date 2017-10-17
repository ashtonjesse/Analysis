aCVDataStacked = vertcat(aCVData{:});
aCVDataCombined = vertcat(aCVDataStacked{:});
aDataToWrite = zeros(size(aCVDataCombined,2)*5,size(aCVDataStacked,1));
iRowsPerExperiment = size(aCVDataCombined,2);
for ii = 1:5
    iStartRow = (ii-1)*iRowsPerExperiment+1;
    aDataToWrite(iStartRow:(iStartRow+iRowsPerExperiment-1),:) = aCVDataCombined(ii:5:end,:)';
end
