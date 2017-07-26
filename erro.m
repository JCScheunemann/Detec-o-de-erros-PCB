close all;
clear all;

pkg load signal
pkg load image

plots=0;

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
	[y x]= size(Dif);
	nx=floor(x/64);
	ny=floor(y/64);
	for j=1:nx
		for k=1:ny
			if(sum(sum(abs(Dif((k-1)*64+1:k*64,(j-1)*64+1:j*64)))))
				[tmp m]=bwlabel(A((k-1)*64+1:k*64,(j-1)*64+1:j*64));
				[tmp n]=bwlabel(B((k-1)*64+1:k*64,(j-1)*64+1:j*64));
				[tmp p]=bwlabel(~A((k-1)*64+1:k*64,(j-1)*64+1:j*64));
				[tmp q]=bwlabel(~B((k-1)*64+1:k*64,(j-1)*64+1:j*64));
				color='g';
				if(m>n)
					color='b';
				elseif(p>q)
					color='r';
				end				
				rectangle('Position',[ ((j-1)*64+1) ((k-1)*64+1) (64) (64)],'EdgeColor',color);
			end
		end
		if(sum(sum(abs(Dif(y-64:y,(j-1)*64+1:j*64)))))
			rectangle('Position',[ ((j-1)*64+1) ((k-1)*64+1) (64) (64)],'EdgeColor','r');
		end
	end
else
	disp("Sem erros");
end

%figure;
%imshow(abw);