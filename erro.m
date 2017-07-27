%
%	Algoritmo para a execução automatizada da comparação Layout vs Schematics
%	Desenvolvido por Jean C. Scheunemann (https://github.com/JCScheunemann) em julho de 2017
%	License:
%		Distribuido sob os termos da licenca BEER-WARE, Enquanto você retiver esta nota você
%		podera fazer o que quiser com esta coisa. Caso nos encontremos algum dia e você ache
% 		que esta coisa vale algo, você poderá me comprar uma cerveja(ou mais) em retribuição
%					Por Jean C. Scheunemann.
%
%	Descricao de funcionamento:
%		1-Carrega-se as imagens (projeto e layout ja normalizado);
%		2-Converte-se para um array de valores binários;
%		3-Executa-se a subtração do vetor original no vetor layout para obter-se as diferencas;
%		4-Realiza-se uma etapa inicial de filtragem para a eliminação do "pixelShaping";
%		5-Calula-se o tamanho das regiões de erro, utilizando-se a convolução da matriz diferença 
%			com uma matriz de centralização;
%		6-Classificação e plot dos erros encontrados;

close all;
clear all;

%Carregamendo das bibliotecas, apenas para octave
pkg load signal
pkg load image

%Parametros globais
borderSize=20;	%tamanho da ragião adicional na região de erro
pixelShape=1;	%tamanho da região de tolerancia no filtro "anti-pixelShaping"
residualError=5; %valor de tolerância admissivel para o erro residual apos os filtros na classificação

%Acumuladores 
rompimentos=0;	%acumulador de erros classificados como rompimentos
curtos=0;		%acumulador de erros classificados como curtos
desprezados=0;	%acumulador de erros classificados como despreziveis

%Etapa 1 e 2- Carregamento e conversão das imagens
a=imread("layout.png");		%carrega a imagem do projeto
A=im2bw(a, graythresh(a));	%converte para B&W
clear a;
b=imread("layout_m.png");	%carrega a imagem do layout
B=im2bw(b, graythresh(b));	%converte para B&W
clear b;
%Etapa 3 - Cálculo da diferenca
Dif=int8(B-A);
[y x]= size(Dif);
%verifica se existem erros na imagem
if(sum(sum(abs(Dif))))		
	disp("\n\n\nErros foram encontrados, iniciando deteccao de localizacao");
	%Etapa 4 - Filtro para a correcao do pixelsharping causado pelo "resize" utilizado na normalização das imagens 
	%cria uma regiao de tolerância de n pixels entorno dos contornos do projeto original
	tmp=bwboundaries(A);	%funcao que realiza a extração dos contornos
	for i=2:length(tmp)		%para cada contorno encontrado aplica-se o filtro
		for j=1:length(tmp{i})
			tmp1=tmp{i};
			y1=tmp1(j,1)+[-pixelShape:pixelShape];
			x1=tmp1(j,2)+[-pixelShape:pixelShape];
			if(tmp1(j,1)<pixelShape+1)
				y1=[1:pixelShape];
			elseif(tmp1(j,1)>y)
				y1=[y-pixelShape-1:y];
			end
			if(tmp1(j,2)<pixelShape+1)
				x1=[1:pixelShape];
			elseif(tmp1(j,2)>x)
				x1=[x-pixelShape-1:x];
			end
			Dif(y1,x1)=0;
		end
	end	
	figure; imshow(B);
	
	%Etapa 5 - Calculo das regiões de erro
	M=zeros(20,20);M(6:15,6:15)=1;	%criacao do kernel do filtro (matriz de centralização)
	tmp1=conv2(abs(Dif),M);			%convolucao da matriz diferenca com o filtro
	[b m]=bwboundaries(tmp1);		%detecção dos contornos formados pelas regiões de erro, agora agrupados por vizinhanca pelo filtro anterior
	disp(["Encontrados ",num2str(length(b))," erros, Inicinado analise..."]);
	
	%Etapa 6 - Classificação dos erros	
	for i =1:length(b)
		%pega os extremos do contorno de erro
		c1=max(b{i});	
		c2=min(b{i});
		t=c1-c2;
		if(t(1)>residualError & t(2)>residualError)
			%calcula as coordenadas das regiões de analise
			ya=(c2(1)-borderSize);	%y inferior
			yb=(c1(1)+borderSize);	%y superior
			xa=(c2(2)-borderSize);	%x inferior
			xb=(c1(2)+borderSize);	%x superior
			if(xb>x) 	%seta os limites superiores de X
				xb=x;
			end
			if(yb>y)	%seta os limites superiores de Y
				yb=y;
			end
			[tmp m]=bwlabel( A(ya:yb , xa:xb));	%calcula-se o numero de regiões fechadas no projeto original 
			[tmp n]=bwlabel( B(ya:yb , xa:xb));	%calcula-se o numero de regiões fechadas no layout
			[tmp p]=bwlabel(~A(ya:yb , xa:xb));	%calcula-se o numero de regiões fechadas no negativo do projeto original 
			[tmp q]=bwlabel(~B(ya:yb , xa:xb));	%calcula-se o numero de regiões fechadas no negativo do layout
			color='g';
			%Se a contagem do numero de corpos solidos(contornos fechados) em uma determinada região for diferente no projeto original e no layout, ocorrereu um erro "destrutivo", caso contrário, o erro não impepedirá o funcionamento do circuito  
			if(m>n)	%verifica-se se ocorreu a diminuição da contagem em uma região, erro classificado como rompimento de continuidade
				color='b';
				rompimentos=rompimentos+1;
			elseif(p>q)	%verifica-se se ocorreu a diminuição da contagem em uma região, utilizando o negativo das imagens, erro classificado como criação de continuidade (curto)
				color='r';
				curtos=curtos+1;
			end
			%plot para a demarcacao visual da região do erro
			p=[ (c2(2)-borderSize) (c2(1)-borderSize) ((c1(2)-c2(2))+borderSize) ((c1(1)-c2(1))+borderSize)];
			rectangle('Position',p,'EdgeColor',color);
		else
			desprezados=desprezados+1;
		end
	end
	%imprime resultados no prompt
	disp(["\t Rompimentos de trilhas(Azul):",num2str(rompimentos)]);
	disp(["\t Curtos(Vermelho):",num2str(curtos)]);
	disp(["\t Desprezados(Nao plotados):",num2str(desprezados)]);
	disp(["\t Erros nao destrutivos(Verde):",num2str(length(b)-rompimentos-curtos-desprezados)]);
	
else
	disp("Sem erros");
end
