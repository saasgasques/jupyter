% Octave
% startxwin /bin/octave --force-gui
clear ; close all; clc;

function [dAPrev, dW, db] = fConvBackward(dZ, APrev, W, b, stride, pad) 
   [m, Ah, Aw, Ac] = size(APrev); % 10x4x4x3
   [f, f, Wc, nF] = size(W); % 2x2x3x8
   [Zm, Zh, Zw, Zc] = size(dZ); % 10x4x4x8
   % stride = 2
   % pad = 2   
   dAPrev = zeros(m, Ah, Aw, Ac); % 10x4x4x3
   dW = zeros(f, f, Wc, nF); % 2x2x3x8
   db = zeros(1, 1, 1, nF); % 1x1x1x8
   
   APrevPad = fZeroPad(APrev, pad); % 10x8x8x3
   dAPrevPad = fZeroPad(dAPrev, pad); % 10x8x8x3 all zeros
   
   for i = 1:Zm % 1:10
     aPrevPad = squeeze(APrevPad(i,:,:,:)); % 1x8x8x3 -> 8x8x3
     daPrevPad = squeeze(dAPrevPad(i,:,:,:)); % 1x8x8x3 -> 8x8x3
     for h = 0:Zh-1 % 0:3
	   for w = 0:Zw-1 % 0:3
	     for c = 1:Zc % 1:8
		   hs = h*stride + 1; 
		   he = hs+f - 1;
		   ws = w*stride + 1;
		   we = ws+f - 1; 
		   %fprintf(1,'i:%d hs:%d he:%d ws:%d we:%d c:%d\n',i,hs,he,ws,we,c);
		   ASlice = aPrevPad(hs:he, ws:we, :); % 2x2x3		   
		   daPrevPad(hs:he, ws:we, :) += W(:,:,:,c) * dZ(i, h+1, w+1, c); % 2x2x3 = 2x2x3x1 * 1x1x1x1 
		   dW(:,:,:,c) += ASlice * dZ(i, h+1, w+1, c); % 2x2x3 = 2x2x3 * 1x1x1x1
		   db(:,:,:,c) += dZ(i, h+1, w+1, c); % 1x1x1x1
		 end
	   end
	 end 
   end
end

function [dAPrev, dW, db] = fConvBackward2(dZ, APrev, W, b, stride, pad) 
   [m, Ah, Aw, Ac] = size(APrev); % 10x4x4x3
   [f, f, Wc, nF] = size(W); % 2x2x3x8
   [Zm, Zh, Zw, Zc] = size(dZ); % 10x4x4x8
   % stride = 2
   % pad = 2   
   dAPrev = zeros(m, Ah, Aw, Ac); % 10x4x4x3
   dW = zeros(f, f, Wc, nF); % 2x2x3x8
   db = zeros(1, 1, 1, nF); % 1x1x1x8
   
   APrevPad = fZeroPad(APrev, pad); % 10x8x8x3
   dAPrevPad = fZeroPad(dAPrev, pad); % 10x8x8x3 all zeros
   
   for i = 1:Zm % 1:10
     aPrevPad = squeeze(APrevPad(i,:,:,:)); % 1x8x8x3 -> 8x8x3
     daPrevPad = squeeze(dAPrevPad(i,:,:,:)); % 1x8x8x3 -> 8x8x3
     for h = 0:Zh-1 % 0:3
	   for w = 0:Zw-1 % 0:3
	   	 hs = h*stride + 1; 
		 he = hs+f - 1;
		 ws = w*stride + 1;
		 we = ws+f - 1; 
	     ASlice = aPrevPad(hs:he, ws:we, :); % 2x2x3
	     for c = 1:Zc % 1:8
		   %fprintf(1,'i:%d hs:%d he:%d ws:%d we:%d c:%d\n',i,hs,he,ws,we,c);		  
		   daPrevPad(hs:he, ws:we, :) += W(:,:,:,c) * dZ(i, h+1, w+1, c); % 2x2x3 = 2x2x3x1 * 1x1x1x1 
		   %dW(:,:,:,c) += ASlice * dZ(i, h+1, w+1, c); % 2x2x3 = 2x2x3 * 1x1x1x1
		   %db(:,:,:,c) += dZ(i, h+1, w+1, c); % 1x1x1x1
		 end
		 %dW(:,:,:,:) += bsxfun(@times, ASlice, dZ(i, h+1, w+1, :)); explicit broadcast
		 dW(:,:,:,:) += ASlice .* dZ(i, h+1, w+1, :); % 2x2x3x8 = 2x2x3 .* 1x1x1x8 implicit broadcast		 
		 db(:,:,:,:) += dZ(i, h+1, w+1, :); % 1x1x1x8
	   end
	 end 
   end
end

function [dAPrev, dW, db] = fConvBackward3(dZ, APrev, W, b, stride, pad) 
   [m, Ah, Aw, Ac] = size(APrev); % 10x4x4x3
   [f, f, Wc, nF] = size(W); % 2x2x3x8
   [Zm, Zh, Zw, Zc] = size(dZ); % 10x4x4x8
   % stride = 2
   % pad = 2   
   dAPrev = zeros(m, Ah, Aw, Ac); % 10x4x4x3
   dW = zeros(f, f, Wc, nF); % 2x2x3x8
   db = zeros(1, 1, 1, nF); % 1x1x1x8
   
   APrevPad = fZeroPad(APrev, pad); % 10x8x8x3
   dAPrevPad = fZeroPad(dAPrev, pad); % 10x8x8x3 all zeros
   
   for i = 1:Zm % 1:10
     aPrevPad = squeeze(APrevPad(i,:,:,:)); % 1x8x8x3 -> 8x8x3
     daPrevPad = squeeze(dAPrevPad(i,:,:,:)); % 1x8x8x3 -> 8x8x3
     for h = 0:Zh-1 % 0:3
	   for w = 0:Zw-1 % 0:3
	   	 hs = h*stride + 1; 
		 he = hs+f - 1;
		 ws = w*stride + 1;
		 we = ws+f - 1; 
	     ASlice = aPrevPad(hs:he, ws:we, :); % 2x2x3
	     for c = 1:Zc % 1:8
		   %fprintf(1,'i:%d hs:%d he:%d ws:%d we:%d c:%d\n',i,hs,he,ws,we,c);		  
		   %daPrevPad(hs:he, ws:we, :) += W(:,:,:,c) * dZ(i, h+1, w+1, c); % 2x2x3 = 2x2x3x1 * 1x1x1x1 
		   %dW(:,:,:,c) += ASlice * dZ(i, h+1, w+1, c); % 2x2x3 = 2x2x3 * 1x1x1x1
		   %db(:,:,:,c) += dZ(i, h+1, w+1, c); % 1x1x1x1
		 end
		 size(dZ(i, h+1, w+1, :)) % 1x1x1x8
		 size(squeeze(dZ(i, h+1, w+1, :))) % 8x1
		 size(repmat(squeeze(dZ(i, h+1, w+1, :)), 1, 12)) % repetir la columna 12 cops 8x12
		 size(repmat(squeeze(dZ(i, h+1, w+1, :)), 1, 12)') % trasposar 12x8 
		 size(reshape(repmat(squeeze(dZ(i, h+1, w+1, :)), 1, 12)', 2, 2, 3 , 8))
		 %size(reshape()) %
		 reshape(repmat(squeeze(dZ(i, h+1, w+1, :)), 1, 12)', 2, 2, 3 , 8)(:,:,:,2)
		 
		 daPrevPad(hs:he, ws:we, :) += bsxfun(@times,  W(:,:,:,:), dZ(i, h+1, w+1, :)); 
		 %daPrevPad(hs:he, ws:we, :) += W(:,:,:,:) .* squeeze(dZ(i, h+1, w+1, :))'; % 2x2x3 = 2x2x3x8 * 1x8 implicit broadcast 		  
		 %dW(:,:,:,:) += bsxfun(@times, ASlice, dZ(i, h+1, w+1, :)); explicit broadcast
		 dW(:,:,:,:) += ASlice .* dZ(i, h+1, w+1, :); % 2x2x3x8 = 2x2x3 .* 1x1x1x8 implicit broadcast		 
		 db(:,:,:,:) += dZ(i, h+1, w+1, :); % 1x1x1x8
	   end
	 end 
   end
end

% Fer el padding que s'indica [nimatge, height, width, colors]
function xpad = fZeroPad(x, pad)
  xpad = zeros(size(x,1), 2*pad+size(x,2), 2*pad+size(x,3), size(x,4));
  xpad(:, pad+1:pad+size(x,2), pad+1:pad+size(x,3), :) = x;
end

% Convolució de tota una imatge
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

A = rand(10,4,4,3);
W = rand(2,2,3,8);
b = rand(1,1,1,8);
stride = 2;
pad = 2;

Z = fConvForward6(A, W, b, stride, pad);
dZ = Z;
APrev = A;

tic
[dAprev, dW, db] = fConvBackward(dZ, APrev, W, b, stride, pad);
toc

tic
[dAprev2, dW2, db2] = fConvBackward2(dZ, APrev, W, b, stride, pad);
toc

tic
[dAprev3, dW3, db3] = fConvBackward3(dZ, APrev, W, b, stride, pad);
toc

sum((dAprev-dAprev2)(:))
sum((dW-dW2)(:))
sum((db-db2)(:))

sum((dAprev-dAprev3)(:))
sum((dW-dW3)(:))
sum((db-db3)(:))
