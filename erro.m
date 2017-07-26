close all;
clear all;

pkg load signal
pkg load image

plots=0;
WSize=64; %tamanho da janela de analise

a=imread("layout.png");	%load img alvo
abw=rgb2gray(a);  %converte para B&W
A=im2bw(abw,0.8);

b=imread("layout_m.png");	%load img alvo
bbw=rgb2gray(b);  %converte para B&W
B=im2bw(bbw,0.8);

%plot initial result
if(plots)
	subplot(3,1,1);imshow(A);title("Projeto original");
	subplot(3,1,2);imshow(B);title("Layout produzido");
	subplot(3,1,3);imshow(((B-A)+1)./2);title("Erros detectados"); hold on;
end
%%
figure; imshow(B)
n_deep=4;
if(sum(sum(abs(B-A))))
	disp("Erros foram encontrados, iniciando deteccao de localizacao");
	Dif=B-A;
	#tentativa de encontrar a regiao dos erros
	M=zeros(20,20);
	M(6:15,6:15)=1;
	tmp=conv2(abs(Dif),M);
	[tmp m]=bwlabel(tmp);
	disp(["Encontrados ",num2str(m)," erros"]);
	
	[y x]= size(Dif);
	nx=floor(x/WSize);
	ny=floor(y/WSize);
	for j=1:nx
		for k=1:ny
			if(sum(sum(abs(Dif((k-1)*WSize+1:k*WSize,(j-1)*WSize+1:j*WSize)))))
				[tmp m]=bwlabel(A((k-1)*WSize+1:k*WSize,(j-1)*WSize+1:j*WSize));
				[tmp n]=bwlabel(B((k-1)*WSize+1:k*WSize,(j-1)*WSize+1:j*WSize));
				[tmp p]=bwlabel(~A((k-1)*WSize+1:k*WSize,(j-1)*WSize+1:j*WSize));
				[tmp q]=bwlabel(~B((k-1)*WSize+1:k*WSize,(j-1)*WSize+1:j*WSize));
				color='g';
				if(m>n)
					color='b';
				elseif(p>q)
					color='r';
				end				
				rectangle('Position',[ ((j-1)*WSize+1) ((k-1)*WSize+1) (WSize) (WSize)],'EdgeColor',color);
			end
		end
		if(sum(sum(abs(Dif(y-WSize:y,(j-1)*WSize+1:j*WSize)))))
			rectangle('Position',[ ((j-1)*WSize+1) ((k-1)*WSize+1) (WSize) (WSize)],'EdgeColor','r');
		end
	end
else
	disp("Sem erros");
end

%figure;
%imshow(abw);