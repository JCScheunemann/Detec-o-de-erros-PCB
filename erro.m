%
%	Algoritmo para a execucao automatizada da comparacao Layout vs Schematics
%	Desenvolvido por Jean C. Scheunemann (https://github.com/JCScheunemann) em julho de 2017
%	License:
%		Distribuido sob os termos da Open Software fundation, sendo permitida a distribuicao, 
%		copia e alteracao, desde que as devidas fontes sejam citadas(https://github.com/JCScheunemann/Detec-o-de-erros-PCB).
%
%	Descricao de funcionamento:
%		1-Carrega-se as imagens (projeto e layout ja normalizado);
%		2-Converte-se para um array de valores binarios;
%		3-Executa-se a subtracao do vetor original no vetor layout para obter-se as diferencas;
%		4-Realiza-se uma etapa inicial de filtragem para a eliminacao do "pixelShaping";
%		5-Calula-se o tamanho das regioes de erro, utilizando-se a convolucao da matriz diferenca 
%			com uma matriz de centralizacao;
%		6-Classificacao e plot dos erros encontrados;

close all;
clear all;

%Carregamendo das bibliotecas, apenas para octave
pkg load signal
pkg load image

%Parametros globais
borderSize=20;	%tamanho da ragiao adicional na regiao de erro
pixelShape=2;	%tamanho da regiao de tolerancia no filtro "anti-pixelShaping"

%Acumuladores 
rompimentos=0;	%acumulador de erros classificados como rompimentos
curtos=0;		%acumulador de erros classificados como curtos

%Etapa 1 e 2- Carregamento e conversao das imagens
a=imread("layout.png");		%carrega a imagem do projeto
A=im2bw(a, graythresh(a));	%converte para B&W

b=imread("layout_m.png");	%carrega a imagem do layout
B=im2bw(b, graythresh(b));	%converte para B&W

if(sum(sum(abs(B-A))))		%verifica se existem erros na imagem
	disp("\n\n\nErros foram encontrados, iniciando deteccao de localizacao");
	
	%Etapa 3 - Calculo da diferenca
	Dif=B-A;
	[y x]= size(Dif);
	
	%Etapa 4 - Filtro para a correcao do pixelshaping causado pelo "resize" utilizado na normalizacao das imagens 
	%cria uma regiao de tolerancia de n pixels entorno dos contornos do projeto original
	tmp=bwboundaries(A);	%funcao que realiza a extracao dos contornos
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
	
	%Etapa 5 - Calculo das regioes de erro
	M=zeros(20,20);M(6:15,6:15)=1;	%criacao do kernel do filtro (matriz de centralizacao)
	tmp1=conv2(abs(Dif),M);			%convolucao da matriz diferenca com o filtro
	[b m]=bwboundaries(tmp1);		%deteccao dos contornos formados pelas regioes de erro, agora agrupados por vizinhanca pelo filtro anterior
	disp(["Encontrados ",num2str(length(b))," erros, Inicinado analise..."]);
	
	%Etapa 6 - Classificacao dos erros	
	for i =1:length(b)
		%pega os extremos do ccontorno de erro
		c1=max(b{i});	
		c2=min(b{i});
		%calcula as coordenadas das regioes de analise
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
		[tmp m]=bwlabel( A(ya:yb , xa:xb));	%calcula-se o numero de regioes fechadas no projeto original 
		[tmp n]=bwlabel( B(ya:yb , xa:xb));	%calcula-se o numero de regioes fechadas no layout
		[tmp p]=bwlabel(~A(ya:yb , xa:xb));	%calcula-se o numero de regioes fechadas no negativo do projeto original 
		[tmp q]=bwlabel(~B(ya:yb , xa:xb));	%calcula-se o numero de regioes fechadas no negativo do layout
		color='g';
		%Se a contagem do numero de corpos solidos(contornos fechados) em uma determinada regiao for diferente no projeto original e no layout, ocorrereu um erro "destrutivo", caso contrario, o erro nao impepedira o funcionamento do circuito  
		if(m>n)	%verivica-se se ocorreu a diminuicao da contagem em uma regiao, erro classificado como rompimento de continuidade
			color='b';
			rompimentos=rompimentos+1;
		elseif(p>q)	%verivica-se se ocorreu a diminuicao da contagem em uma regiao, utilizando o negativo das imagens, erro classificado como criacao de continuidade (curto)
			color='r';
			curtos=curtos+1;
		end
		%plot para a demarcacao visal da regiao do erro
		p=[ (c2(2)-borderSize) (c2(1)-borderSize) ((c1(2)-c2(2))+borderSize) ((c1(1)-c2(1))+borderSize)];
		rectangle('Position',p,'EdgeColor',color);
	end
	%imprime resultados no prompt
	disp(["\t Rompimentos de trilhas(Azul):",num2str(rompimentos)]);
	disp(["\t Curtos(Vermelho):",num2str(curtos)]);
	disp(["\t Erros nao destrutivos(Verde):",num2str(length(b)-rompimentos-curtos)]);
else
	disp("Sem erros");
end

%figure;
%imshow(abw);