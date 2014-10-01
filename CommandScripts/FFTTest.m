clear all;

% % % %Read in the file containing all the optical data 
[sFileName,sPathName]=uigetfile('*.*','Select a file that contain optical transmembrane recordings');
sFileName = strcat(sPathName,sFileName);
% % Make sure the dialogs return char objects
if (isempty(sFileName) && ~ischar(sFileName))
    break
end
%check the extension
[pathstr, name, ext, versn] = fileparts(sFileName);
if strcmpi(ext,'.csv')
    aOAP = ReadOpticalTimeDataCSVFile(sFileName,6);
elseif strcmpi(ext,'.mat')
    load(sFileName);
    aOAP = aThisOAP;
end

N = length(aOAP.Data(1:end-1,1));
aPSDX = zeros(N/2+1,size(aOAP.Data,2));
aPSDXTukey = zeros(N/2+1,size(aOAP.Data,2));
for i = 1:size(aOAP.Data,2)
    [aPSDX(:,i) Fxx] = periodogram(-aOAP.Data(1:end-1,i),rectwin(N),N,780);
    [aPSDXTukey(:,i) Fxx] = periodogram(-aOAP.Data(1:end-1,i),tukeywin(N,0.5),N,780);
end
MeanPSDX = mean(aPSDX,2);
MeanPSDXTukey = mean(aPSDXTukey,2);
figure();
plot(Fxx,10*log10(MeanPSDX),'k'); 
grid on; hold on;
plot(Fxx,10*log10(MeanPSDXTukey),'r'); 
hold off;