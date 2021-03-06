function p = ellipsoidfit_LLS_W(x,y,z,w)
%%%%%%%%%%  w=size(x,1);
% Fit an ellipsoid to a set of 3D data points.
%
% Input arguments:
% x, y, z
%    cartesian coordinates of noisy data points
%
% Output arguments:
% p:
%    the 10 parameters describing the ellipsoid algebraically
%    fit ellipsoid in the form Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz = 1
%    where norm([A,B,C,D,E,F,G,H,I,J]) == 1
%
% Examples:
% p = ellipsoid_leastsquares(x,y,z)

% Copyright 2011 Levente Hunyadi

narginchk(4, 4);  % check input arguments
validateattributes(x, {'numeric'}, {'real','nonempty','vector'});
validateattributes(y, {'numeric'}, {'real','nonempty','vector'});
validateattributes(z, {'numeric'}, {'real','nonempty','vector'});
x = x(:);
y = y(:);
z = z(:);

assert(numel(x) >= 9, ...
    'At least 9 points are required to fit a unique ellipsoid.');

% normalize data by canceling mean to improve numerical accuracy
mx = mean(x);
my = mean(y);
mz = mean(z);
x = x - mx;
y = y - my;
z = z - mz;


% use singular value decomposition (unconstrained problem)
D = [ x .* x, ...  % size = (number of data points) x (9 ellipsoid parameters + 1 constant term)
      y .* y, ...
      z .* z, ...
      x .* y, ...
      x .* z, ...
      y .* z, ...
      x, ...
      y, ... 
      z, ...
      ones(size(x)) ];
 for i=1:1:size(D,1)
       D(i,:)=w(i)*D(i,:);
 end;

[~,~,V] = svd(D,0);
p = V(:,end);  % smallest singular value

% unnormalize
p(:) = ...
[ p(1) ...
; p(2) ...
; p(3) ...
; p(4) ...
; p(5) ...
; p(6) ...
; p(7) - 2*p(1)*mx - p(4)*my - p(5)*mz ...
; p(8) - 2*p(2)*my - p(4)*mx - p(6)*mz ...
; p(9) - 2*p(3)*mz - p(5)*mx - p(6)*my ...
; p(10) + p(1)*mx*mx + p(2)*my*my + p(3)*mz*mz + p(4)*mx*my + p(5)*mx*mz + p(6)*my*mz - p(7)*mx - p(8)*my - p(9)*mz ...
];
p(4)=p(4)/2;
p(5)=p(5)/2;
p(6)=p(6)/2;
p(7)=p(7)/2;
p(8)=p(8)/2;
p(9)=p(9)/2;
p = p / norm(p);
if p(1)<0
    p=-p;
end
