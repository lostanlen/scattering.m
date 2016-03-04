function path =  fetch_plain(S2, gamma1, gamma2)
    gamma2_start = S2.ranges{1+1}(1,1);
    gamma2_index = gamma2 - gamma2_start + 1;
    
    if ( (gamma2_index>length(S2.ranges{1+0})) || (gamma2_index < 1))
        path=0;
    else 
        gamma1_start = S2.ranges{1+0}{gamma2_index}(1,2);
        gamma1_index = gamma1 - gamma1_start + 1;
        
        if ( (gamma1_index > size(S2.data{gamma2_index},2)) || ...
             (gamma1_index < 1) )
         path= 0; 
        else 
            path = S2.data{gamma2_index}(:, gamma1_index);
        end 
    end 
end