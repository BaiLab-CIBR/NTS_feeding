function [psth,psth_mean, sem] = psth_wave2(trigger_times,interval,values, ...
    pre_time,post_time,control_from,control_to,offset,z_score)
N = length(values);
times = 0:interval:(N-1)*interval;
times = times';
%     val1 = cell(1,length(trigger_times));
% interval_rate=1/interval;
% if   interval_rate>=1&&interval_rate<=10
%     trigger_times=roundn(trigger_times,-1);
% elseif interval_rate>10&&interval_rate<=100
%     trigger_times=roundn(trigger_times,-2);
% elseif interval_rate>100&&interval_rate<=1000;
%     trigger_times=roundn(trigger_times,-3);
% end
% trigger_times=round(trigger_times/interval)*interval;
% trigger_times1=trigger_times;
% trigger_times=uint16(round(trigger_times/interval))*interval;
% trigger_times=round(trigger_times);
val2 = cell(1,length(trigger_times));

for i=1:length(trigger_times)
   % k1 = times > trigger_times(i) + control_from & times < trigger_times(i) + control_to;
    b = round((trigger_times(i) - pre_time)/interval)*interval;
    c = round((trigger_times(i) + post_time)/interval)*interval;
%     c=c+0.0001;
%     k = times >= b & times <= c;
    k=find(times(:)>=b-0.05*interval & times(:)<=c+0.05*interval);
%       k=find(times(:)>=b & times(:)<=c);
%     if sum(k) > (pre_time+post_time)/interval
%         m = find(k == 1,1,'first');
%         k(m) = [];
%     end
%     if sum(k) < (pre_time+post_time)/interval
%         m = find(k == 1,1,'first');
%         k(m-1)=1;
%     end
    %     val1{1,i} = values(k1)-offset;
   
   % val2{1,i} = values(k)-offset;
    val2{1,i} = values(k);
   % average = mean(values(k1));
   % stdev = std(values(k1));
   % if z_score==1
   %     pre = (values(k) - average)/stdev;
   % else
   %     pre = 100*(values(k) - average)/(average-offset);
   % end
   % val2{1,i} = pre;
end

psth = cell2mat(val2)';
sem = std(psth)/(length(trigger_times)-1)^0.5;
psth_mean = mean(psth,1);