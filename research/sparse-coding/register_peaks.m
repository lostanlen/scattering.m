function d = register_peaks(D,Q)

d = zeros(Q,size(D,1));
center = Q/2;
for i=1:size(D,2)
     [abspeaks,abslocs] = findpeaks(abs(D(:,i)),'MinPeakHeight',0.2,'MinPeakDistance',3); 
     
     %get the greatest peak
     [~,Mpi] = max(abspeaks);
     loc = abslocs(Mpi)
     m = max(loc-(Q/2),1);
     M = min(loc+(Q/2)-1,size(D,1)-1);
     sigma = round((M-m)/2);
     m= round(m+sigma);
     d(center-sigma+1:center+sigma,i)=D((m-sigma+1):(m+sigma),i);
    
end 