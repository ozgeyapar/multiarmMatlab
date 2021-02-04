function [H] = SherWood(A,u,v)
%SherWood
% PURPOSE: Computes inv(A + uv'), the inverse of a matrix obtained
% by rank-one change in a matrix A, using the Sherman-Morrison
% formula.
%
% INPUTS: 
% A: Matrix
% u,v: column vectors 
%
% OUTPUTS: 
% H: matrix, inv(A + uv')
%
%%
	[m,n] = size(A);
        if m~=n
        	disp('matrix A  is not square');
        	return;
        end
	ainv = inv(A);
	alpha = 1/(1+v'*ainv*u);
	H = ainv - alpha*ainv*u*v'*ainv;
end