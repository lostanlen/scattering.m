function tensor = multidimensional_fft(tensor,subscripts)
for subscript = subscripts
    tensor = fft(tensor,[],subscript);
end
end
