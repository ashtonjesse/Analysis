clear all

disp('loading unemap...');
oUnemap = ...
GetUnemapFromMATFile(Unemap,'D:\Users\jash042\Documents\PhD\Analysis\Database\20130221\barotest_1755\pbarotest_1755_unemap.mat');
disp('done loading');
Phi = oUnemap.Electrodes(45).Potential.Data(10000:20000);
PhiP = oUnemap.Electrodes(45).Processed.Data(10000:20000);
% Remove high frequency scales and plot
figure(1); clf; 
for s=5:9,
  FilteredSignal = DWTFilterRemoveScales(Phi,s);  
  subplot(5,1,s-4); plot(1:length(Phi),Phi,'g-',1:length(Phi),FilteredSignal,'r-'); axis tight; ylabel(sprintf('\\phi(mV) (sc=%d)',s));
  if s==0,
      title(sprintf('Remove Scales'));
  end;
end;
xlabel('Time (s)');
% figure(2); clf;
% plot(1:length(FilteredSignal),FilteredSignal,'g-');%,1:length(PhiP),PhiP,'r-'
% axis tight; ylabel(sprintf('\\phi(mV) (sc=%d)',9));
% Filter and plot for a sequence of retained scales
figure(3); clf; 
for s=0:9,
  FilteredSignal = DWTFilterKeepScales(Phi,s);  
  subplot(10,1,s+1); plot(1:length(Phi),FilteredSignal,'r-'); axis tight; ylabel(sprintf('\\phi(mV) (sc=%d)',s));
  if s==0,
      title(sprintf('Keep Scales'));
  end;
end;
xlabel('Time (s)');