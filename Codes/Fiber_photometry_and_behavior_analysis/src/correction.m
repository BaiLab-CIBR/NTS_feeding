function [cal_corr] = correction(cal,control,offset)

t=1:length(cal);

t=t'/15;

p=polyfit(t,cal,1);

cal=cal-p(1)*t;

% cal_sm=smooth(cal,0.05,'lowess');

p=polyfit(control,cal,1);

y1=polyval(p,control);

cal_corr=100*(cal-y1)./(y1-offset);

%
t=1:length(cal_corr);

t=t'/15;

p=polyfit(t,cal_corr,1);

cal_corr=cal_corr-p(1)*t;

end