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
end

N = length(aOAP.Data(:,1));
aXDFT = zeros(N/2+1,size(aOAP.Data,2));
aPSDX = zeros(N/2+1,size(aOAP.Data,2));
for i = 1:size(aOAP.Data,2)
    xdft = fft(-aOAP.Data(:,i));
    xdft = xdft(1:floor(N/2+1));
    aXDFT(:,i) = xdft;
    psdx =(1/(780*N)).*abs(xdft).^2;%
    psdx(2:end-1) = 2*psdx(2:end-1);
    aPSDX(:,i) = psdx;
end
dNoisePower = mean(mean(aPSDX(6027:end,:),2));
MeanPSDX = mean(aPSDX,2)./dNoisePower;
freq = 0:780/N:780/2;
figure();
plot(freq,10*log10(MeanPSDX)); grid on;