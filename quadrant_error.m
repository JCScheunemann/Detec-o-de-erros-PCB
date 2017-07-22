
function Qerro= quadrant_error(B)
	erros=zeros([2,2]);
	for k=1:2
		for j=1:2
			Btmp=B((j-1)*floor(length(B(:,1))/2)+1 :j*floor(length(B(:,1))/2),(k-1)*floor(length(B(1,:))/2)+1 :k*floor(length(B(1,:))/2));
			erros(k,j)=sum(sum(abs(Btmp)));
		end
	end
	Qerro=erros;