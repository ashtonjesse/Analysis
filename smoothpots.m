function slop = smoothpots
global DATA

sw = size(DATA.Unemap.Pot.OrigBase);
st = zeros(sw(1),sw(2));
slop = zeros(sw(1),sw(2));

tic
for k = 1:sw(2)
    if(~mod(k,25))
        fprintf('%03d ',k);
    end
    st(1:sw(1),k) = smoothn(DATA.Unemap.Pot.OrigBase(:,k),5,'MaxIter',500);
    slop(1:sw(1),k) = ana_movingslope(st(:,k),5,3);
end
slop = slop.*-1;
fprintf('\n',k);
toc

