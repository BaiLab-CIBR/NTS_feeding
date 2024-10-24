function sel = IG_bout_select(frameRate, signal, boutStart, boutEnd, window, threshold)
numBout = length(boutStart);
%size(boutStart)
sel = false([numBout 1]);
for iter = 1:numBout
    % left = round((boutStart(iter)-window) * frameRate);
    % right = round(boutStart(iter) * frameRate);
    % if mean(signal(left:right)) < threshold
        %left
        %signal(left:right)
    %    sel(iter) = 1;
    % end
    if iter > 1 && boutStart(iter) - boutEnd(iter-1) > threshold
        sel(iter) = 1;
    end
end
% sum(sel)
end