% Octave
% startxwin /bin/octave --force-gui
clear ; close all; clc;

function Z = fPoolForward(Aprev, f, stride, mode)
  [m, Ah, Aw, Ac] = size(Aprev); % 2x4x4x3
  % f=3 stride=2 mode='max'
  % Output dimensions
  Oh = floor((Ah-f)/stride + 1); % 1
  Ow = floor((Aw-f)/stride + 1); % 1
  Z = zeros(m, Oh, Ow, Ac); % 2x1x1x3
  
  for i = 1:m % 1:2
	for h = 0:Oh-1 % 0:0
	  for w = 0:Ow-1 % 0:0
	    for c = 1:Ac % 1:3
		  hs = h*stride + 1; % 1
		  he = hs+f - 1; % 3
		  ws = w*stride + 1; % 1
		  we = ws+f - 1; % 3
		  fprintf(1,'hs:%d he:%d ws:%d we:%d c:%d\n',hs,he,ws,we,c);
		  aSlice = Aprev(i, hs:he, ws:we, c); % 1x3x3x3
		  if strcmp(mode, 'max')
			Z(i,h+1,w+1,c) = max(aSlice(:));
		  elseif strcmp(mode, 'avg')
		    Z(i,h+1,w+1,c) = mean(aSlice(:));
		  end
		end
	  end
	end
  end	
end

rand("seed", 1)
A = rand(2,4,4,3);
stride = 2;
f = 3; 
mode = 'max';

tic
Z = fPoolForward(A, f, stride, mode); % 2x1x1x3
toc
%for i=1:2
%  for c=1:3
%    squeeze(A(i,:,:,c))
%	squeeze(Z(i,:,:,c))
%  end
%end
