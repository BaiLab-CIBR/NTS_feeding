function ret = date_format(date)
%UNTITLED 此处提供此函数的摘要
%   此处提供详细说明
% year = extractBetween(date, 1, 4);
% month = extractBetween(date, 6, 7);
% day = extractBetween(date, 9, 10);
% ret = year+'.'+month+'.'+day;
% end

year = date(1:4);
month = date(6:7);
day = date(9:10);
ret = [year,'.',month,'.',day];
end
