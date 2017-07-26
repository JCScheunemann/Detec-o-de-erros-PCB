close all;
clear all;

pkg load signal
pkg load image

plots=0;
WSize=64; %tamanho da janela de analise
borderSize=20

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
%
figure; imshow(B)
rompimentos=0;
curtos=0;
if(sum(sum(abs(B-A))))
	disp("\n\n\nErros foram encontrados, iniciando deteccao de localizacao");
	Dif=B-A;
	[y x]= size(Dif);
	#tentativa de encontrar a regiao dos erros
	M=zeros(20,20);
	M(6:15,6:15)=1;
	tmp1=conv2(abs(Dif),M);
	[b m]=bwboundaries(tmp1);
	disp(["Encontrados ",num2str(length(b))," erros, Inicinado analise..."]);	
	for i =1:length(b)
		c1=max(b{i});
		c2=min(b{i});
		ya=(c2(1)-borderSize);
		yb=(c1(1)+borderSize);
		xa=(c2(2)-borderSize);
		xb=(c1(2)+borderSize);
		if(xb>x)
			xb=x;
		end
		[tmp m]=bwlabel( A(ya:yb , xa:xb));
		[tmp n]=bwlabel( B(ya:yb , xa:xb));
		[tmp p]=bwlabel(~A(ya:yb , xa:xb));
		[tmp q]=bwlabel(~B(ya:yb , xa:xb));
		color='g';
		if(m>n)
			color='b';
			rompimentos=rompimentos+1;
		elseif(p>q)
			color='r';
			curtos=curtos+1;
		end
		p=[ (c2(2)-borderSize) (c2(1)-borderSize) ((c1(2)-c2(2))+borderSize) ((c1(1)-c2(1))+borderSize)];
		rectangle('Position',p,'EdgeColor',color);
	end
	disp(["\t Rompimentos de trilhas:",num2str(rompimentos)]);
	disp(["\t Curtos:",num2str(curtos)]);
	disp(["\t Erros nao destrutivos:",num2str(length(b)-rompimentos-curtos)]);
else
	disp("Sem erros");
end

%figure;
%imshow(abw);