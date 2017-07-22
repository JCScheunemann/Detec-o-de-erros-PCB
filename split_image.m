function sp_image=split_image(A)
	[x y]=size(A);
	sp_image=cat(3, A(1:floor(x/2),1:floor(y/2)), A(1:floor(x/2),1+floor(y/2):2*floor(y/2)), A(1+floor(x/2):2*floor(x/2),1:floor(y/2)), A(1+floor(x/2):2*floor(x/2),1+floor(y/2):2*floor(y/2))); 
