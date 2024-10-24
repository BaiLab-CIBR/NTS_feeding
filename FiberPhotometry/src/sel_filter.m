function [out1, out2, out3, out4] = sel_filter(sel, arg1, arg2, arg3, arg4)
%UNTITLED2 此处提供此函数的摘要
%   此处提供详细说明
if nargin > 1
    out1 = arg1(sel);
end
if nargin > 2
    out2 = arg2(sel);
end
if nargin > 3
    out3 = arg3(sel);
end
if nargin > 4
    out4 = arg4(sel);
end
end