% function [ V ] = JointOrtho( epsilon, M )
%Joint orthogonalize Mc
%   M is N*m; we need to find an rotation V such that M*D concentrate on
%   one entry in very row

% get dimensions
[N,m] = size(M);
% cancel rows which are not effective
rowNorm = sqrt(sum(M.^2,2));
indineff = (rowNorm<0.5);
M(indineff,:) = [];

% get dimensions
[N,m] = size(M);

% initialize V; M' is of size m*N
[V,~] = qr(M');
M = M*V;

% locations of maximum value for each row
[~, MaxPos] = max(abs(M),[],2);
IndPos = cell(1,m);
for i = 1 : m
    IndPos{1,i} = (MaxPos==i);
end

% Jacobi iteration
[yoff, ytotal] = Moff ( M, N, m, MaxPos );
while (yoff > epsilon*ytotal)
    yoff/ytotal
    pause;
    for p = 1 : m
        alpha1 = M(IndPos{1,p},p);
        for q = p+1 : m
            alpha2 = M(IndPos{1,p},q);
            beta1 = M(IndPos{1,q},p);
            beta2 = M(IndPos{1,q},q);
            L = [alpha2, -alpha1; beta1, beta2];
            if ~isempty(L)
                [~,~,W] = svd(L);
                w = W(:,2);
                if w(1) < 0
                    w = -w;
                end
                c = w(1);
                s = w(2);
                R = [c, -s; s, c];
                V(:,[p,q]) = V(:,[p,q])*R;
                M(:,[p,q]) = M(:,[p,q])*R;
            end
        end
    end
    % update the estimate of maximum positions
    [~, MaxPos] = max(abs(M),[],2);
    for i = 1 : m
        IndPos{1,i} = (MaxPos==i);
    end
    [yoff, ytotal] = Moff ( M, N, m, MaxPos );
end
