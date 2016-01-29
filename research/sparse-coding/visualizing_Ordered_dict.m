function visualizing_Ordered_dict(D)


Onepeak=[];
ZeroSum2p=[];
NonZeroSum2p=[];

ZeroSum3p=[];
NonZeroSum3p=[];

ZeroSumOtherpeaks=[];
NonZeroSumOtherpeaks=[];


epsilon = 0.1;
diffPeaks = [];
for i=1:size(D,2)
    % Do the blur.
   [abspeaks,abslocs] = findpeaks(abs(D(:,i)),'MinPeakHeight',0.2,'MinPeakDistance',3); 
   diffPeaks = cat(1,diffPeaks(:),diff(abslocs));

   sumpeaks = sum(D(abslocs,i));
 
   switch length(abspeaks)
        case 1 
            Onepeak(:,end+1) = D(:,i);
        case 2
            if abs(sumpeaks)< epsilon 
                ZeroSum2p(:,end+1)=D(:,i);
            else 
                NonZeroSum2p(:,end+1)=D(:,i);
            end 
        case 3
            if abs(sumpeaks)< epsilon 
                ZeroSum3p(:,end+1)=D(:,i);
            else 
                NonZeroSum3p(:,end+1)=D(:,i);
            end 
        otherwise
             if abs(sumpeaks)< epsilon 
                ZeroSumOtherpeaks(:,end+1)=D(:,i);
            else 
                NonZeroSumOtherpeaks(:,end+1)=D(:,i);
            end 
    end 
end 



figure; 
subplot(421);imagesc(order_filters(Onepeak));title('One peak'); 
subplot(422);hist(diffPeaks,1:size(D,1)/2);title('Histogram of the differences between peaks')
subplot(423);imagesc(order_filters(ZeroSum2p));title('Two peaks zero sum')
subplot(424);imagesc(order_filters(NonZeroSum2p));title('Two peaks non-zero sum')
subplot(425);imagesc(order_filters(ZeroSum3p));title('Three peaks zero sum')
subplot(426);imagesc(order_filters(NonZeroSum3p));title('Three peaks non-zero sum')
subplot(427);imagesc(order_filters(ZeroSumOtherpeaks));title('More peaks zero sum')
subplot(428);imagesc(order_filters(NonZeroSumOtherpeaks));title('More peaks non-zero sum')

end

function sortedd=order_filters(d)

[~, peak_lambda1s] = max(real(d), [], 1);
[~, sorting_indices] = sort(peak_lambda1s);
sortedd=d(:,sorting_indices);
end