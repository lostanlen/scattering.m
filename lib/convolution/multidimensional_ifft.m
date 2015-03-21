function tensor = multidimensional_ifft(tensor,subscripts)
for subscript = subscripts
    tensor = ifft(tensor,[],subscript);
end
end
