function net = InitNet ( )
%% Network initialization
%% We initialize the network parameters according to the ADMM algorithm optimizing the baseline CS-MRI model.
%% Copyright (c) 2017 Yan Yang
%% All rights reserved.

%% network setting
config;
fN = nnconfig.FilterNumber;
fS = nnconfig.FilterSize;
WD = nnconfig.WeightDecay;
LL = nnconfig.LinearLabel;
stageN = nnconfig.Stage;
s = fS*fS;
%% network parameters
% Filter coefficients: \omega_{l,m}^{(n)} and \gamma_{l,m}^{(n)}
gamma = eye(s-1,fN);
% penalty parameters: \Rho
for i = 1:fN
    Rho(i) = (1e-2) * 20;
end
% update rate: \eta
for i=1:fN
    Eta(i) = 1.6;
end
% control points
r = (1 / 20);
linew = zeros(101 , fN , 'double');
for i=1:fN
    linew (: , i) = nnsoft (LL, r);
end

%% Network structure
net.layers = {};
%the first stage
net.layers{end+1} = struct('type','X_org',...
    'weights',{{ gamma , Rho}},...
    'learningRate', ones(1, 2, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0,0}});
net.layers{end+1} = struct('type', 'Convo',...
    'weights',{{ gamma }},...
    'learningRate', ones(1, 1, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0}});
net.layers{end+1} = struct('type', 'Non_linorg',...
    'weights',{{linew}},...
    'learningRate', ones(1, 1, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0}});
net.layers{end+1} = struct('type', 'Multi_org',...
    'weights',{{Eta}},...
    'learningRate', ones(1, 1, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0}});
%the middle stages
for i = 1:1:stageN-2
    net.layers{end+1} = struct('type', 'X_mid',...
        'weights',{{ gamma,Rho}},...
        'learningRate', ones(1, 2, 'double'), ...
        'weightDecay', WD, ...
        'momentum', {{0,0}});
    net.layers{end+1} = struct('type', 'Convo',...
        'weights',{{ gamma }},...
        'learningRate', ones(1, 1, 'double'), ...
        'weightDecay', WD, ...
        'momentum', {{0}});
    net.layers{end+1} = struct('type', 'Non_linmid',...
        'weights',{{linew}},...
        'learningRate', ones(1, 1, 'double'), ...
        'weightDecay', WD, ...
        'momentum', {{0}});
    net.layers{end+1} = struct('type', 'Multi_mid',...
        'weights',{{Eta}},...
        'learningRate', ones(1, 1, 'double'), ...
        'weightDecay', WD, ...
        'momentum', {{0}});
end
%the final stage
net.layers{end+1} = struct('type', 'X_mid',...
    'weights',{{ gamma,Rho}},...
    'learningRate', ones(1, 2, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0,0}});
net.layers{end+1} = struct('type', 'Convo',...
    'weights',{{ gamma }},...
    'learningRate', ones(1, 1, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0}});
net.layers{end+1} = struct('type', 'Non_linmid',...
    'weights',{{linew}},...
    'learningRate', ones(1, 1, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0}});
net.layers{end+1} = struct('type', 'Multi_final',...
    'weights',{{Eta}},...
    'learningRate', ones(1, 1, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0}});
net.layers{end+1} = struct('type', 'X_mid',...
    'weights',{{ gamma,Rho}},...
    'learningRate', ones(1, 2, 'double'), ...
    'weightDecay', WD, ...
    'momentum', {{0,0}});
% loss layer
net.layers{end+1}.type = 'loss';
end




