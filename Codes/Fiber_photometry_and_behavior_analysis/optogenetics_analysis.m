%% please run Readtdms.m at first
%licking analysis in the optogenetics exp
clc;
clear all;
File=load('230527_new_2_1_exp.mat'); % example
%%
Fs=1000;
%cumulative time window
window=ones(40000,1);
%recording from the first point
t_expstart=0.001;
t_waterstart=0.001;
t_waterend=7200;
% Please choice right col
x=3;
%Divide bout by time interval and bout duration(p.s.Second parameter is the number of licks contained in the bout in some article)
threshold_method2=3;
tbout=1;
%threshold of interval one bout
threshold_interval=3;
%%  dif and cum
event=File.Data(t_waterstart*Fs:t_waterend*Fs,:);
t=(1:length(event(:,1)))/Fs;
dif_event=diff(event(:,x));
dif_event(dif_event<0)=0;
dif_event(dif_event>0)=1;
cum_event=cumsum(dif_event);
figure;
plot(t(2:end),cum_event);
xlabel('Time (s)');
ylabel('Lick number');
figure;
plot(t(2:end),dif_event);
%% opto
optotime=length(find(event(t_expstart*Fs:end,x)==3))/Fs;
%% lick and consumption time analysis
consumptiontime=length(find(event(t_waterstart*Fs:end,x)==3))/Fs;
consumption_segment=[length(find(event(t_waterstart*Fs:900*Fs,x)))/Fs;length(find(event(900*Fs:1800*Fs,x)))/Fs;length(find(event(1800*Fs:2700*Fs,x)))/Fs;length(find(event(2700*Fs:3600*Fs,x)))/Fs;length(find(event(3600.00*Fs:4500*Fs,x)))/Fs;length(find(event(4500*Fs:5400*Fs,x)))/Fs;length(find(event(5400*Fs:6300*Fs,x)))/Fs;length(find(event(6300*Fs:t_waterend*Fs,x)))/Fs];
lick_start=find(dif_event(:,1)==1);
lick_segment=[size(find(lick_start>t_waterstart*Fs&lick_start<=900*Fs),1);size(find(lick_start>900*Fs&lick_start<=1800*Fs),1);size(find(lick_start>1800*Fs&lick_start<=2700*Fs),1);size(find(lick_start>2700*Fs&lick_start<=3600*Fs),1);size(find(lick_start>3600*Fs&lick_start<=4500*Fs),1);size(find(lick_start>4500*Fs&lick_start<=5400*Fs),1);size(find(lick_start>5400*Fs&lick_start<=6300*Fs),1);size(find(lick_start>6300*Fs&lick_start<=t_waterend*Fs),1)];
lick_number_total=sum(lick_segment);
lick_interval=diff(lick_start);
lick_intervalfit=zeros(size(lick_interval));
lick_intervalfit=lick_interval(lick_interval<Fs*threshold_interval);
mean_lick_interval=mean(lick_intervalfit)/Fs;
% lick rate
hts=zeros(size(event));
hts(2:end,1)=conv(dif_event(:,1),window,'same');
%cumulative distribution curve of licking
%cumulative_lick=cumsum(dif_event(:,x),1);
%cumulative distribution curve of lick interval

%% lick bout identify and analysis
bout_start0=zeros(size(lick_start));
bout_end0=zeros(size(lick_start));
bout_start0(1,1)=lick_start(1,1);
m=2;
for k=1:1:length(lick_interval)
    if lick_interval(k,1)>=threshold_method2*1000
        bout_start0(m,1)=lick_start(k+1,1);
        bout_end0(m-1,1)=lick_start(k,1);
        m=m+1;
    end
end
bout_start1=bout_start0(bout_start0~=0);
bout_end1=bout_end0(bout_end0~=0);
bout_duration0=bout_end1-bout_start1(1:end-1,1);
bout_start1(find(bout_duration0<tbout*1000))=[];
bout_end1(find(bout_duration0<tbout*1000))=[];
bout_duration1=(bout_end1-bout_start1(1:end-1,1))/Fs;
bout_segment=[size(find(bout_start1>t_waterstart*Fs&bout_start1<=900*Fs),1);size(find(bout_start1>900*Fs&bout_start1<=1800*Fs),1);size(find(bout_start1>1800*Fs&bout_start1<=2700*Fs),1);size(find(bout_start1>2700*Fs&bout_start1<=3600*Fs),1);size(find(bout_start1>3600*Fs&bout_start1<=4500*Fs),1);size(find(bout_start1>4500*Fs&bout_start1<=5400*Fs),1);size(find(bout_start1>5400*Fs&bout_start1<=6300*Fs),1);size(find(bout_start1>6300*Fs&bout_start1<=t_waterend*Fs),1)];
lick_bout_number_total=sum(bout_segment);
bout_averagelick_segment=lick_segment./bout_segment;
lick_perbout=zeros(size(bout_end1));
lickrate_perbout=zeros(size(bout_end1));
for m=1:length(bout_end1)
lick_perbout(m)=sum(dif_event(bout_start1(m):bout_end1(m),1));
end
lickrate_perbout=lick_perbout./bout_duration1;
%This indicator is comparable in different animals only when the standard for delimiting bout is certain
mean_bout_duration=mean(bout_duration1);
bout_interval=diff(bout_start1)/Fs;
mean_bout_interval=mean(bout_interval);
mean_lick_perbout=mean(lick_perbout);
mean_lickrate_perbout=mean(lickrate_perbout);




        
    
        
        
    
 


