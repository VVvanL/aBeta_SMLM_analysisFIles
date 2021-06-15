function stats = parameterStats(data)
    stats = cell(2,3); stats(1,:) = {'mean','stdev','skew'};
    stats{2,1} = mean(data);
    stats{2,2} = std(data);
    stats{2,3} = skewness(data);
end