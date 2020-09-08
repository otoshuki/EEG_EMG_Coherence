function [out] = single_side(ft)

L = length(ft);
absolute = abs(ft/L);
out = absolute(1:floor(L/2) + 1);
out(2:end-1) = 2*out(2:end-1);

