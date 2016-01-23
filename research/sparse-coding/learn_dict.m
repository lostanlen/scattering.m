function [D,X,err]=learn_dict(Y,k,n,p)
%
% energy: Y-D*X, with target sparsity k, X is of w length
% Y: (d,m) with m patches of dim. d
% k: maximum sparsity
% n: n dims of 
% p: number of vectors that we want to use for the training (p with maximum
%    norm)

verbose = 1;

[d,m]=size(Y); %num. of vectors used for the training

if nargin<4
    p=m;
end 

%Only keep the patches with largest energy.
%[~,I] = sort(sum(Y.^2), 'descend'); %todo:randomly select on each it.
% I = randperm(m);
% Y = Y(:,I(1:p));

eps=1e-5;
ProjC = @(D)D ./ repmat( sqrt(sum(D.^2)+eps), [d 1]);% [w, 1] );

%select some subset of the data to initialize the dictionary
sel = randperm(p); sel = sel(1:n);
D =ProjC(sparse(double(Y(:,sel))));

%init
X = sparse(rand(size(D,2),size(Y,2)));

flat=@(x)x(:);
norm2=@(D)sqrt(sum(flat(abs(D).^2)));

niter=100;
for it=1:niter

    progressbar(it,niter,20);
    X = updateX(Y,D,k,X,verbose); 
    D = updateD(X,Y,D,verbose);

    err(it) = norm2(Y-D*X);
    if verbose
        subplot(1,3,3);plot(log10(err+eps));drawnow
    end 
    if err(it)<1e-4
        return;
    end 
   
end
if verbose
    subplot(1,3,3);plot(log10(err+eps));
end 
% hold on;

% [~,I] = sort(sum(X.^2,2), 'descend'); %todo:randomly select on each it.
% 
% X = X(I,:);
% D = D(:,I);

end     

function D = updateD(X,Y,D,verbose)

[d,~]=size(D);
epsilon = 1e-3;
t = 1.8/(norm(X*X')+epsilon);% + lambda*k+ epsilon);
ProjC = @(D)D ./ repmat( sqrt(sum(D.^2)), [d, 1] );
ProjP = @(D)max(D,0);

norm2=@(D)sqrt(sum((abs(D(:)).^2)));

it = 10000;

for j=1:it
    D = ProjP(ProjC(D-t*(D*X-Y)*X' ));
    
    %for debugging
    Err(j) = norm2(Y-D*X);
    if verbose
        if (j>1) 
            if Err(j-1)-Err(j) < 1e-8
                  subplot(1,3,1);plot(log10(Err),'-');drawnow;

                return;
            end 
        end
    end 
end
if verbose
    subplot(1,3,1);plot(log10(Err),'*-');drawnow;
end 
end 

function X = updateX(Y,D,k,X,verbose)

%Update of the Coefficients X
select = @(A,k)repmat(A(k,:), [size(A,1) 1]);
ProjX = @(X,k)X .* (abs(X) >= select(sort(abs(X), 'descend'),k));

epsilon = 1e-3;
flat=@(x)x(:);
t = 2/(norm(flat(D*D')) + epsilon);

norm2=@(D)sqrt(sum((abs(D(:)).^2)));

it = 10000; 
for j=1:it
    X = ProjX(X-t*D'*(D*X-Y),k);%soft thresholding on the grad desc
    
    %for debugging
    Err(j) = norm2(Y-D*X);
   if verbose
    if (j>1) 
        if Err(j-1)-Err(j) < 1e-8
            subplot(1,3,2);plot(log10(Err),'-');drawnow;
            return;
        end 
    end
   end
  
end
if verbose
   subplot(1,3,2);plot(log10(Err),'*-');drawnow;
end   

end 
