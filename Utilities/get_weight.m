function [W,DC,mesh_size,drv_mesh_cord] = get_weight(A,elec,nodes,mesh_nodes)


data_cord=dlmread(elec);
for i = 1:3
    DC(:,i)=data_cord(:,i+1);
end
data_cord=DC;

fid=fopen(nodes,'r');
junk = fgets(fid);



k = 1;
for i = 1:mesh_nodes;
   [AA,count]=fscanf(fid, '%f');
   
   drv_mesh_cord(i,:)=AA(1:count);
   
   mesh_cord(i,1)=AA(1);
   mesh_cord(i,2)=AA(5);
   mesh_cord(i,3)=AA(9);
   
   junk = fgets(fid);
end

% Modifying data points 
n=1;
for i = 1:length(data_cord);
    if i ~=A(:,1);
        nn=1;
    else
        MC(n,:)=data_cord(i,:);
        n=n+1;
    end
    
end
data_cord=MC;
clear  MC n AA;

%Finding the distance between  data points 
l=1;
for i = 1:size(data_cord,1);
    n=size(data_cord,1)-i;
    for j =1:n;
        %varr(l)=(((DD(i)-DD(i+j)))^2)/2;
        dist(l)=sqrt(((data_cord(i,1)-data_cord(i+j,1))^2)+((data_cord(i,2)-data_cord(i+j,2))^2)+((data_cord(i,3)-data_cord(i+j,3))^2));
        l=l+1;
    end
end

%Finding the distance between sensor points and mesh coordinates
for i =1:size(mesh_cord,1);
   for j = 1:size(data_cord,1);
      krdist_M_S(i,j)= sqrt(((data_cord(j,1)-mesh_cord(i,1))^2)+((data_cord(j,2)-mesh_cord(i,2))^2)+((data_cord(j,3)-mesh_cord(i,3))^2));
   end
end

%Finding Distance and the matrix to solve weights
for j = 1:size(data_cord,1);
   for k = j:size(data_cord,1); 
       if j==k;
           matV(j,k)=0;
       else
           matV(j,k)=(sqrt(((data_cord(j,1)-data_cord(k,1))^2)+((data_cord(j,2)-data_cord(k,2))^2)+((data_cord(j,3)-data_cord(k,3))^2)));
           matV(k,j)=matV(j,k);
       end
   end
end

%Ordinary Kriging where weight add to 1 - w1+w2+..+wn=1;
matV(size(data_cord,1)+1,:)=1;
matV(:,size(data_cord,1)+1)=1;
matV(size(data_cord,1)+1,size(data_cord,1)+1)=0;

for i =1:size(mesh_cord,1)
    matVS=(krdist_M_S(i,:));
    matVS(size(data_cord,1)+1)=1;
    W(i,:)=(matVS)*inv(matV);
%    W(:,i)=(matVS)*inv(matV);

end

mesh_size = size(mesh_cord,1);

fclose(fid);
