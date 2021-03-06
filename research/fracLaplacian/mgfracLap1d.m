function [u,errH1,err,node,elem] = mgfracLap1d(pde,square,h,s,option)

%% Generate matrices in each level
global mA
level = -log2(h);
mA = cell(level,1);

option.solver = 'none';
mh =2^(level-2)*h;
for i = 2:level
    [u,eqn,info,node,elem,Neumann] = fracLap1d(square,mh,pde,option);
    mA{i} = eqn.A;
    mh = mh/2;
end
A = mA{level};
b = eqn.b;
freeNode = eqn.freeNode;

%% Iterative method
tol = option.tol;
k = 1;
maxIt = 200;
err = zeros(maxIt,1);
err(1) = 1;
u = zeros(length(b),1);
nb = norm(b(freeNode));
% r = zeros(length(b),1);
% u = rand(length(b),1);
while err(k) > tol && k < maxIt
    r = b - A*u;
    e = mgVcyclefracLap1d(A,r,pde,square,h,s,option);
    u(freeNode) = u(freeNode) + e(freeNode);
    err(k+1) = norm(r(freeNode))/nb;
%     fprintf('%d th-iteration with error %e \n',k,err(k+1));
    k = k + 1;
end
err = err(1:k);

%% Compute the error
errH1 = getH1errorbd(node,Neumann,pde,u,eqn.A,5);
% uI = pde.exactu(node); % nodal interpolation
% errH1 = sqrt((u-uI)'*eqn.A*(u-uI));
% errH1 = getH1errorQ1(node,elem,pde.Du,u,pde.d);   