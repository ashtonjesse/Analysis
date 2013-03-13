function mesh_value = kriging(W,DC,mesh_size,A)
  
n=1;
for i = 1:length(DC);
    if i ~=A(:,1);
        nn=1;
    else
        data_cord(n,:)=DC(i,:);
        DD(n)=A(n,2);
        n=n+1;
    end
    
end

%Solving for weights - matV*W=matVS
for i =1:mesh_size 
    nn=0;
    for j = 1:size(data_cord,1);
        
        nn=nn+ W(i,j)*DD(j);    
    
    end
    mesh_value(i)=nn;
end
