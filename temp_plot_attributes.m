% working script to plot localizations attributes 

figure; hold on
for c = 1:2
    histogram(data.(['ch',num2str(c)]).localizations(:,7),'BinWidth',2,'Normalization','Probability')
end
xlim([0 50]); title('Precision'); legend('Ch1','Ch2');

figure; hold on
for c = 1:2
    histogram(data.(['ch',num2str(c)]).localizations(:,5),'BinWidth',100,'Normalization','Probability')
    % histogram(data.(['ch',num2str(c)]).localizations(:,5),'Normalization','Probability')
end
xlim([0 5e3]); title('Photons'); legend('Ch1','Ch2');

figure; hold on
for c = 1:2
    histogram(data.(['ch',num2str(c)]).localizations(:,4),'BinWidth',10,'Normalization','Probability')
    % histogram(data.(['ch',num2str(c)]).localizations(:,4),'Normalization','Probability')
end
xlim([0 500]); title('Sigma'); legend('Ch1','Ch2');