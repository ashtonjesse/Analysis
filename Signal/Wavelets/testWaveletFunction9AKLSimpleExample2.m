%function [FalseWave,rnear, rnear0, rnearhigh] = WaveletFunction(Virt)

x = -10:0.1:10;
%Virt = 2*sin(x) + x/10; 
Virt = sin(5*x) + sin(x); 
%Virt(1,1:10) = Virt(1,1);
%Virt(1,(end-9):end) = Virt(1,end-10);
[N,M] = size(Virt);
N = M;
%Virt = zeros(N+3,M);
%Virt(4:end, :) = Virt0;
%Virt(1:3, :) = cords;

%plot(1:(N-3),Virt(4:end,id));
%xlim([1 (N-3)]);

NeedPlot = 1;
t=1:(N);
y1=Virt;
 
nscales=15;
%nscales=30;
y1(isnan(y1))=0; 
m1=mean(y1(:));  y1=y1-m1; 
nscales=round(abs(nscales));
%c1=cwt(y1,1:nscales,'cmor1-1'); 
c1=cwt9(y1,1:nscales,'gaus1'); 
%c1 = c1(end:-1:1,:);
% Display results
y1=y1+m1; 
if NeedPlot == 1, 
   figure(1); clf;
   currfig=get(0,'CurrentFigure'); set(currfig,'numbertitle','off');
   set(currfig,'name','Wavelet Analysis'); 
   subplot(4,1,1); plot(t,y1,'linewidth', 1.5); axis tight; %title('Original Test Data'); 
   subplot(4,1,2); imagesc(real(c1)); colormap(hot); axis tight; %title('CWT'); ylabel('Wavelength');
   %figure,imagesc(real(c1)); colormap(hot); axis tight;
end;


%colormap(jet(256));
rnear = 0;
r0 = 0;
for i = 1:1:7,
       rnear = rnear + exp(-((i - 1)^2*0.061))*real(c1(i,:));
       r0 = r0 + exp(-((i - 1)^2*0.061));
end;
rnear = rnear/r0;
rfar = 0;
for i = 1:1:7,
       rfar = rfar + exp(-((i - 1)^2*0.061))*real(c1(end + 1 - i,:));
end;
rfar = rfar/r0;

if NeedPlot == 1,
   subplot(4,1,3); plot(t,real(rnear),'-r', 'linewidth', 1.5); axis tight; 
   %hold on;
   %plot(t,0.5,'--r', 'linewidth', 1.5, 'MarkerSize', 5); axis tight; 
   %hold off;
   subplot(4,1,4);  plot(t,real(rfar),'linewidth', 1.5); axis tight; 
   %figure, plot(t,real(rnear),'-b', 'linewidth', 3,'MarkerSize', 5); axis tight;
   %hold on;
   %plot(t,0.1,'--r', 'linewidth', 3, 'MarkerSize', 5); axis tight;
   %hold on;
   %plot(t,0.25,'--r', 'linewidth', 3, 'MarkerSize', 5); axis tight;
   %figure,plot(t,real(rfar),'-b', 'linewidth', 3,'MarkerSize', 5); axis tight;
end;

return;

%return
