% This function parses the input data file and 
% stores it to a .mat output file, which is used 
% by and required for the Main function.  

function loadFromXLS(inputFileName, outputFileName)

disp(['Loading data from ', inputFileName, '.xlsx', '...']);
inputFileName = strcat(pwd,'\',inputFileName,'.xlsx');

%% Load and Clean genData
disp('Loading generator data...');
[~, ~, tempGenData] = xlsread(inputFileName, 'genData');
% Remove header row
tempGenData(1,:) = [];

% Remove unwanted generators, identified by a '0' in column A
index = 1;
while index <= size(tempGenData,1)
    if cell2mat(tempGenData(index,1)) == 0
        tempGenData(index,:) = [];
    else
        index = index + 1;
    end
end

genData.gPlantCode = tempGenData(:,4);
genData.gHeatRate = cell2mat(tempGenData(:, 16))*1000/1000000;  %convert from btu/kWh -> MMbtu/MWh
genData.gCapacitySummer = cell2mat(tempGenData(:, 49));
genData.gCapacityWinter = cell2mat(tempGenData(:, 50));
genData.gVarOM = cell2mat(tempGenData(:, 51));
genData.gFuelPrice = cell2mat(tempGenData(:,52:63));
genData.gRampRate = cell2mat(tempGenData(:,64));
genData.gMinUp = round(cell2mat(tempGenData(:,65)));    % Need hours in integers
genData.gMinDown = round(cell2mat(tempGenData(:,66)));  % Need hours in integers
genData.gStartupCost = cell2mat(tempGenData(:,67));
genData.gMin = cell2mat(tempGenData(:, 68));
genData.gEAF = cell2mat(tempGenData(:,69:80))./100;
genData.gZone = tempGenData(:,81);

% Emission rates (lb/MWh)
genData.gNOX = cell2mat(tempGenData(:,85));
genData.gSO2 = cell2mat(tempGenData(:,86));
genData.gN2O = cell2mat(tempGenData(:,87));
genData.gCO2 = cell2mat(tempGenData(:,88));
genData.gCO2eqv = cell2mat(tempGenData(:,90));
genData.gCO = cell2mat(tempGenData(:,91));
genData.gNH3 = cell2mat(tempGenData(:,92));
genData.gPM10 = cell2mat(tempGenData(:,93));
genData.gPM25 = cell2mat(tempGenData(:,94));
genData.gVOC = cell2mat(tempGenData(:,95));

% Marginal Damages ($1999/MWh)
genData.gMDNH3 = cell2mat(tempGenData(:,103));
genData.gMDSO2 = cell2mat(tempGenData(:,104));
genData.gMDVOC = cell2mat(tempGenData(:,105));
genData.gMDNOX = cell2mat(tempGenData(:,106));
genData.gMDPM25 = cell2mat(tempGenData(:,107));
genData.gMDPM10 = cell2mat(tempGenData(:,108));

% No load costs
genData.gNLC = cell2mat(tempGenData(:,110));

% Assign generator to a Transmission Constrained Region (TCR) based on zone
for index = 1 : size(genData.gZone,1)
    if(strcmp(genData.gZone(index),'AEP')) | (strcmp(genData.gZone(index),'COMED')) | (strcmp(genData.gZone(index),'APS')) | (strcmp(genData.gZone(index),'DUQ')) | (strcmp(genData.gZone(index),'DAY')) | (strcmp(genData.gZone(index),'PENELEC'))
        genData.gTCR(index,1) = 1;
    elseif(strcmp(genData.gZone(index),'BGE')) | (strcmp(genData.gZone(index),'PEPCO'))
        genData.gTCR(index,1) = 2;
    elseif(strcmp(genData.gZone(index),'PPL')) | (strcmp(genData.gZone(index),'METED'))
        genData.gTCR(index,1) = 3;
    elseif(strcmp(genData.gZone(index),'JCPL')) | (strcmp(genData.gZone(index),'PECO')) | (strcmp(genData.gZone(index),'PSEG')) | (strcmp(genData.gZone(index),'AECO')) | (strcmp(genData.gZone(index),'DPL')) | (strcmp(genData.gZone(index),'RECO'))
        genData.gTCR(index,1) = 4;
    elseif(strcmp(genData.gZone(index),'DOM'))
        genData.gTCR(index,1) = 5;
    end
end
clear tempGenData

%% Load & Clean load
disp('Loading load data...');

% load from xls
[~,~,load] = xlsread(inputFileName, 'Load');
[~,~,imports] = xlsread(inputFileName, 'Imports');
[~,~,LMPs] = xlsread(inputFileName, 'LMPs');
[~,~,transmissionConstraints] = xlsread(inputFileName, 'Transmission Constraints');
[~,~,wind] = xlsread(inputFileName, 'Wind');

% delete headers
load(1,:) = [];
imports(1,:) = [];
LMPs(1,:) = [];
transmissionConstraints(1,:) = [];
wind(1,:) = [];

% load
loadData.PSEG = cell2mat(load(:,4));
loadData.PECO = cell2mat(load(:,5));
loadData.PPL = cell2mat(load(:,6));
loadData.BGE = cell2mat(load(:,7));
loadData.PEPCO = cell2mat(load(:,8));
loadData.RECO = cell2mat(load(:,9));
loadData.APS = cell2mat(load(:,10));
loadData.COMED = cell2mat(load(:,11));
loadData.AEP = cell2mat(load(:,12));
loadData.DAY = cell2mat(load(:,13));
loadData.DUQ = cell2mat(load(:,14));
loadData.DOM = cell2mat(load(:,15));
loadData.JCPL = cell2mat(load(:,16));
loadData.METED = cell2mat(load(:,17));
loadData.PENELEC = cell2mat(load(:,18));
loadData.AECO = cell2mat(load(:,19));
loadData.DPL = cell2mat(load(:,20));

% Imports / exports
loadData.ALTE = cell2mat(imports(:,4));
loadData.ALTW = cell2mat(imports(:,5));
loadData.AMIL = cell2mat(imports(:,6));
loadData.CIN = cell2mat(imports(:,7));
loadData.CPLE = cell2mat(imports(:,8));
loadData.CPLW = cell2mat(imports(:,9));
loadData.CWLP = cell2mat(imports(:,10));
loadData.DUK = cell2mat(imports(:,11));
loadData.EKPC = cell2mat(imports(:,12));
loadData.FE = cell2mat(imports(:,13));
loadData.IPL = cell2mat(imports(:,14));
loadData.LGEE = cell2mat(imports(:,15));
loadData.LIND = cell2mat(imports(:,16));
loadData.MEC = cell2mat(imports(:,17));
loadData.MECS = cell2mat(imports(:,18));
loadData.NEPT = cell2mat(imports(:,19));
loadData.NIPS = cell2mat(imports(:,20));
loadData.NYIS = cell2mat(imports(:,21));
loadData.OVEC = cell2mat(imports(:,22));
loadData.TVA = cell2mat(imports(:,23));
loadData.WEC = cell2mat(imports(:,24));

% Wind gen
loadData.windTCR1 = cell2mat(wind(:,4));
loadData.windTCR3 = cell2mat(wind(:,5));

% Transmission constraints
loadData.EImax = cell2mat(transmissionConstraints(:,4));
loadData.CImax = cell2mat(transmissionConstraints(:,5));
loadData.WImax = cell2mat(transmissionConstraints(:,6));
loadData.DOMImax = cell2mat(transmissionConstraints(:,7));

% Actual LMPs
loadData.LMPTCR1actual = cell2mat(LMPs(:,4));
loadData.LMPTCR2actual = cell2mat(LMPs(:,5));
loadData.LMPTCR3actual = cell2mat(LMPs(:,6));
loadData.LMPTCR4actual = cell2mat(LMPs(:,7));
loadData.LMPTCR5actual = cell2mat(LMPs(:,8));

clear load imports LMPs transmissionConstraints wind
%% Load & Clean Storage
disp('Loading storage data...');

% load from xls
[~,~,tempStorageData] = xlsread(inputFileName, 'storageData');

% delete headers
tempStorageData(1,:) = [];

storageData.sTCR = cell2mat(tempStorageData(:,3));
storageData.sCapacity = cell2mat(tempStorageData(:,4));
storageData.sChargeEff = cell2mat(tempStorageData(:,5));
storageData.sDischargeEff = cell2mat(tempStorageData(:,6));
storageData.sDuration = cell2mat(tempStorageData(:,7));
storageData.sVC = cell2mat(tempStorageData(:,8));

clear tempStorageData

%% Save data to disk
PHORUMdata.genData = genData;
PHORUMdata.loadData = loadData;
PHORUMdata.storageData = storageData;
save(outputFileName,'PHORUMdata');

end