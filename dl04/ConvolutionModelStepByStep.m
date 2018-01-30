% Octave
% startxwin /bin/octave --force-gui
clear ; close all; clc;

% Fer el padding que s'indica [nimatge, height, width, colors]
function xpad = fZeroPad(x, pad)
  xpad = zeros(size(x,1), 2*pad+size(x,2), 2*pad+size(x,3), size(x,4));
  xpad(:, pad+1:pad+size(x,2), pad+1:pad+size(x,3), :) = x;
end
X = rand(4, 3, 3, 2); % 4x3x3x2
XPAD = fZeroPad(X, 2); % 4x7x7x2
%XPAD(1,:,:,1)
%spy(XPAD(1,:,:,1))
%plotmatrix(XPAD(1,:,:,1))

% Convolució d'un troç de la imatge
function z = fConvSingleStep(ASlice, W, b)
  s = W.*ASlice; % 4x4x3
  z = sum(s(:)); % 1
  z = z + b;
end
ASlice = rand(4, 4, 3);
W = rand(4, 4, 3);
b = rand(1, 1, 1);
Z = fConvSingleStep(ASlice, W, b);
%Z

% Convolució de tota una imatge
function Z = fConvForward(A, W, b, stride, pad)
  [m, Ah, Aw, Ac] = size(A); % 10x4x4x3
  [f, f, Wc, nF] = size(W); % 2x2x3x8
  % Ac and Wc have to have the same size
  Oh = (Ah-f+2*pad)/stride + 1; % 4
  Ow = (Aw-f+2*pad)/stride + 1; % 4
  Z = zeros(m, Oh, Ow, nF); % 10x4x4x8    Output
  APadded = fZeroPad(A, pad); % 10x8x8x3  Input padded
   
  for i = 1:m % 1:10
	aPadded = squeeze(APadded(i,:,:,:)); % 8x8x3
    for h = 0:Oh-1 % 0:3
	  for w = 0:Ow-1 % 0:3
	    for c = 1:nF % 1:8
	      hs = h*stride + 1;  
		  he = hs+f - 1;
		  ws = w*stride + 1;
		  we = ws+f - 1;
		  %fprintf(1,'hs:%d he:%d ws:%d we:%d c:%d\n',hs,he,ws,we,c); 
		  aSlice = aPadded(hs:he, ws:we, :); % 2x2x3 Fem els strides al convolucionar		  		  		  
		  Z(i,h+1,w+1,c) = sum((W(:,:,:,c).*aSlice)(:)) + b(1,1,1,c); % A scalar
		  %printf('----------------------------------------------- \n')
		end  
	  end
    end	  
  end
end
% Convolució de tota una imatge. Passar la suma a un inner product
function Z = fConvForward2(A, W, b, stride, pad)
  [m, Ah, Aw, Ac] = size(A); % 10x4x4x3
  [f, f, Wc, nF] = size(W); % 2x2x3x8
  % Ac and Wc have to have the same size
  Oh = (Ah-f+2*pad)/stride + 1; % 4
  Ow = (Aw-f+2*pad)/stride + 1; % 4
  Z = zeros(m, Oh, Ow, nF); % 10x4x4x8    Output
  APadded = fZeroPad(A, pad); % 10x8x8x3  Input padded
  
  for i = 1:m % 1:10
	aPadded = squeeze(APadded(i,:,:,:)); % 8x8x3
    for h = 0:Oh-1 % 0:3 Alçada del output
	  for w = 0:Ow-1 % 0:3 Amplada del output
	    for c = 1:nF % 1:8 Filtres
	      hs = h*stride + 1;  
		  he = hs+f - 1;
		  ws = w*stride + 1;
		  we = ws+f - 1;
		  %fprintf(1,'hs:%d he:%d ws:%d we:%d c:%d\n',hs,he,ws,we,c); 
		  aSlice = aPadded(hs:he, ws:we, :); % 2x2x3 Fem els strides al convolucionar		  		  		  
		  %Z(i,h+1,w+1,c) = sum((W(:,:,:,c).*aSlice)(:)) + b(1,1,1,c); % A scalar
		  Z(i,h+1,w+1,c) = W(:,:,:,c)(:)'*aSlice(:) + b(1,1,1,c); % A scalar
		  %Z(i,h+1,w+1,c) = WV(c,:)*aSlice(:) + b(1,1,1,c); % A scalar
		  %printf('----------------------------------------------- \n')
		end  
	  end
    end	  
  end
end
% Convolució de tota una imatge. Aplanar els pesos nomes un cop fora del bucle
function Z = fConvForward3(A, W, b, stride, pad)
  [m, Ah, Aw, Ac] = size(A); % 10x4x4x3
  [f, f, Wc, nF] = size(W); % 2x2x3x8
  % Ac and Wc have to have the same size
  Oh = (Ah-f+2*pad)/stride + 1; % 4
  Ow = (Aw-f+2*pad)/stride + 1; % 4
  Z = zeros(m, Oh, Ow, nF); % 10x4x4x8    Output
  APadded = fZeroPad(A, pad); % 10x8x8x3  Input padded
  
  for i = 1:nF
	WV(i,:) = W(:,:,:,i)(:)'; % 12x1 -> 1x12 // 8x12
  end  
  
  for i = 1:m % 1:10
	aPadded = squeeze(APadded(i,:,:,:)); % 8x8x3
    for h = 0:Oh-1 % 0:3 Alçada del output
	  for w = 0:Ow-1 % 0:3 Amplada del output
	    for c = 1:nF % 1:8 Filtres
	      hs = h*stride + 1;  
		  he = hs+f - 1;
		  ws = w*stride + 1;
		  we = ws+f - 1;
		  %fprintf(1,'hs:%d he:%d ws:%d we:%d c:%d\n',hs,he,ws,we,c); 
		  aSlice = aPadded(hs:he, ws:we, :); % 2x2x3 Fem els strides al convolucionar		  		  		  
		  %Z(i,h+1,w+1,c) = sum((W(:,:,:,c).*aSlice)(:)) + b(1,1,1,c); % A scalar
		  %Z(i,h+1,w+1,c) = W(:,:,:,c)(:)'*aSlice(:) + b(1,1,1,c); % A scalar
		  Z(i,h+1,w+1,c) = WV(c,:)*aSlice(:) + b(1,1,1,c); % A scalar
		  %printf('----------------------------------------------- \n')
		end  
	  end
    end	  
  end
end
% Convolució de tota una imatge. Multiplicar de cop per tots el canals
function Z = fConvForward4(A, W, b, stride, pad)
  [m, Ah, Aw, Ac] = size(A); % 10x4x4x3
  [f, f, Wc, nF] = size(W); % 2x2x3x8
  % Ac and Wc have to have the same size
  Oh = (Ah-f+2*pad)/stride + 1; % 4
  Ow = (Aw-f+2*pad)/stride + 1; % 4
  Z = zeros(m, Oh, Ow, nF); % 10x4x4x8    Output
  TMP = zeros(m, Oh, Ow, nF); % TODO REMOVE
  APadded = fZeroPad(A, pad); % 10x8x8x3  Input padded
  
  for i = 1:nF
	WV(i,:) = W(:,:,:,i)(:)'; % 12x1 -> 1x12 // 8x12
  end  
  
  for i = 1:m % 1:10
	aPadded = squeeze(APadded(i,:,:,:)); % 8x8x3
    for h = 0:Oh-1 % 0:3 Alçada del output
	  for w = 0:Ow-1 % 0:3 Amplada del output
	    hs = h*stride + 1;  
		he = hs+f - 1;
		ws = w*stride + 1;
		we = ws+f - 1;
		%fprintf(1,'hs:%d he:%d ws:%d we:%d c:%d\n',hs,he,ws,we,c); 
		aSlice = aPadded(hs:he, ws:we, :); % 2x2x3 Fem els strides al convolucionar		  		  		  				
		Z(i,h+1,w+1,:) = WV*aSlice(:) + squeeze(b); % 8x12 .* 12x1 + 1x1x1x8
		%printf('----------------------------------------------- \n')
	  end
    end	  
  end
end
% Convolució de tota una imatge. Treure el bucle de les imatges i aplanar-lo
function Z = fConvForward5(A, W, b, stride, pad)
  [m, Ah, Aw, Ac] = size(A); % 10x4x4x3
  [f, f, Wc, nF] = size(W); % 2x2x3x8
  % Ac and Wc have to have the same size
  Oh = (Ah-f+2*pad)/stride + 1; % 4
  Ow = (Aw-f+2*pad)/stride + 1; % 4
  Z = zeros(m, Oh, Ow, nF); % 10x4x4x8    Output
  TMP = zeros(m, Oh, Ow, nF); % TODO REMOVE
  APadded = fZeroPad(A, pad); % 10x8x8x3  Input padded
  
  for i = 1:nF
	WV(i,:) = W(:,:,:,i)(:)'; % 12x1 -> 1x12 // 8x12
  end  
  
  %for i = 1:m % 1:10
	%aPadded = squeeze(APadded(i,:,:,:)); % 8x8x3 -> 10x8x8x3	
    for h = 0:Oh-1 % 0:3 Alçada del output
	  for w = 0:Ow-1 % 0:3 Amplada del output
	    hs = h*stride + 1;  
		he = hs+f - 1;
		ws = w*stride + 1;
		we = ws+f - 1;
		%fprintf(1,'hs:%d he:%d ws:%d we:%d c:%d\n',hs,he,ws,we,c); 
		ASlice = APadded(:, hs:he, ws:we, :); % 2x2x3 Fem els strides al convolucionar-> 10x2x2x3
        aSlice = reshape(ASlice,size(ASlice,1),[]); % ? 10x12
        %tmp = aSlice*WV';
		%size(tmp)
        Z(:,h+1,w+1,:) = bsxfun(@plus, aSlice*WV', squeeze(b)'); % 10x12 * 12x8 
		%Z(i,h+1,w+1,:) = WV*aSlice(:) + squeeze(b); % 8x12 .* 12x1 + 1x1x1x8 -> 10x1x1x8
		%printf('----------------------------------------------- \n')
	  end
    end	  
  %end
end
% Convolució de tota una imatge. Aplanar els pesos sense bucle
function Z = fConvForward6(A, W, b, stride, pad)
  [m, Ah, Aw, Ac] = size(A); % 10x4x4x3
  [f, f, Wc, nF] = size(W); % 2x2x3x8
  % Ac and Wc have to have the same size
  Oh = (Ah-f+2*pad)/stride + 1; % 4
  Ow = (Aw-f+2*pad)/stride + 1; % 4
  Z = zeros(m, Oh, Ow, nF); % 10x4x4x8    Output
  APadded = fZeroPad(A, pad); % 10x8x8x3  Input padded
   
  WV = reshape(W,[],nF); % 12x8
  bV = squeeze(b)'; % 1x8  
  for h = 0:Oh-1 % 0:3 Alçada del output
    for w = 0:Ow-1 % 0:3 Amplada del output
	  hs = h*stride + 1;  
	  he = hs+f - 1;
	  ws = w*stride + 1;
	  we = ws+f - 1;
	  %fprintf(1,'hs:%d he:%d ws:%d we:%d \n',hs,he,ws,we);     
	  ASlice = reshape(APadded(:, hs:he, ws:we, :), m,[]); % ? 10x12     
	  Z(:,h+1,w+1,:) = bsxfun(@plus, ASlice*WV, bV); % 10x12 * 12x8 + broadcast 1x8
	  %printf('----------------------------------------------- \n')
	  end
    end	  
end



rand("seed", 1)
%A = rand(10,4,4,3);
%W = rand(2,2,3,8);
%b = rand(1,1,1,8);

%A = rand(100,40,40,3);
%W = rand(20,20,3,80);
%b = rand(1,1,1,80);

%A = rand(50,4,4,3);
%W = rand(2,2,3,16);
%b = rand(1,1,1,16);

%A = rand(75,8,8,3);
%W = rand(4,4,3,40);
%b = rand(1,1,1,40);

A = rand(75,12,12,3);
W = rand(6,6,3,40);
b = rand(1,1,1,40);


stride = 2;
pad = 2;
tic
Z = fConvForward(A, W, b, stride, pad);
toc
tic
Z2 = fConvForward2(A, W, b, stride, pad);
toc
tic
Z3 = fConvForward3(A, W, b, stride, pad);
toc
tic
Z4 = fConvForward4(A, W, b, stride, pad);
toc
tic
Z5 = fConvForward5(A, W, b, stride, pad);
toc
tic
Z6 = fConvForward6(A, W, b, stride, pad);
toc
printf('----------------------------------------------- \n')
%size(Z)
%Z(1,:,:,1)
%Z2(1,:,:,1)
%Z3(1,:,:,1)
sum((Z-Z2)(:))
sum((Z-Z3)(:))
sum((Z-Z4)(:))
sum((Z-Z5)(:))
sum((Z-Z6)(:))
