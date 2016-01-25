function h=visualizing_dict(D,lambda2)

h=figure;

%show both, real and imaginary part
%sort per peak of maximum frequency 
d = D{lambda2};
[~,I] = sort(sum(abs(d).^2,2));

figure; 
subplot(121);
imagesc(real(d(:,I)));title(['Real part for ' num2str(lambda2)])

subplot(122);
imagesc(imag(d(:,I)));title(['Imaginary part for ' num2str(lambda2)]);