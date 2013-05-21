% PHORUM (PJM Hourly Open-source Reduced-form Unit commitment Model) 
% Copyright (C) 2013  Roger Lueken
% CreateGDX.m
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% You can contact the author at rlueken@gmail.com, or mail to:
% Roger Lueken
% Department of Engineering and Public Policy
% Carnegie Mellon University
% Baker Hall 129
% 5000 Forbes Avenue
% Pittsburgh, PA 15213

function [results] = CreateGDX(day, PHORUMdata, settings, prevDayResults, optWindow)
%% Settings
EAFderating = 0.5;

%% Load data from PHORUMdata structure
genData = PHORUMdata.genData;
loadData = PHORUMdata.loadData;
storageData = PHORUMdata.storageData;
windData = PHORUMdata.windData;

%% Load needed genData to memory

% Set range of modeled hours based on starting day
tStart = day * 24 + 1 - 24;
tEnd = tStart + (optWindow - 1);

% Assign summer/winter capacity based on start date
if tStart > 2900 && tStart < 6588
    gCapacity = genData.gCapacitySummer;
else
    gCapacity = genData.gCapacityWinter;
end
gHeatRate = genData.gHeatRate;
gVarOM = genData.gVarOM;
gRampRate = genData.gRampRate;
gMinUp = genData.gMinUp;
gMinDown = genData.gMinDown;
gNLC = genData.gNLC;
gTCR = genData.gTCR;

% Emission rates (lb/MWh)
gNOX = genData.gNOX;
gSO2 = genData.gSO2;
gN2O = genData.gN2O;
gCO2 = genData.gCO2;
gCO2eqv = genData.gCO2eqv;
gCO = genData.gCO;
gNH3 = genData.gNH3;
gPM10 = genData.gPM10;
gPM25 = genData.gPM25;
gVOC = genData.gVOC;

% Startup emissions (tons)
gStartupNOX = genData.gStartupNOX;
gStartupCO2 = genData.gStartupCO2;
gStartupSO2 = genData.gStartupSO2;


% Marginal Damages ($2010/MWh)
gMDNH3 = genData.gMDNH3;
gMDSO2 = genData.gMDSO2;
gMDVOC = genData.gMDVOC;
gMDNOX = genData.gMDNOX;
gMDPM25 = genData.gMDPM25;
gMDPM10 = genData.gMDPM10;
gStartupMDNOX = genData.gStartupMDNOX;
gStartupMDSO2 = genData.gStartupMDSO2;

% Assign fuel costs and EAF based on start date
if (tStart >=1 && tStart < 745)        % Jan
    gFuelPrice = genData.gFuelPrice(:,1); 
    gEAF = genData.gEAF(:,1);
end
if (tStart >=745 && tStart < 1417)     % Feb
    gFuelPrice = genData.gFuelPrice(:,2); 
    gEAF = genData.gEAF(:,2);
end
if (tStart >=1417 && tStart < 2161)    % Mar 
    gFuelPrice = genData.gFuelPrice(:,3); 
    gEAF = genData.gEAF(:,3);
end
if (tStart >=2161 && tStart < 2881)    % Apr
    gFuelPrice = genData.gFuelPrice(:,4); 
    gEAF = genData.gEAF(:,4);
end
if (tStart >=2881 && tStart < 3625)    % May
    gFuelPrice = genData.gFuelPrice(:,5); 
    gEAF = genData.gEAF(:,5);
end
if (tStart >=3625 && tStart < 4345)    % June
    gFuelPrice = genData.gFuelPrice(:,6); 
    gEAF = genData.gEAF(:,6);
end
if (tStart >=4345 && tStart < 5089)    % July
    gFuelPrice = genData.gFuelPrice(:,7); 
    gEAF = genData.gEAF(:,7);
end
if (tStart >=5089 && tStart < 5833)    % Aug
    gFuelPrice = genData.gFuelPrice(:,8); 
    gEAF = genData.gEAF(:,8);
end
if (tStart >=5833 && tStart < 6553)    % Sept
    gFuelPrice = genData.gFuelPrice(:,9); 
    gEAF = genData.gEAF(:,9);
end
if (tStart >=6553 && tStart < 7297)    % Oct
    gFuelPrice = genData.gFuelPrice(:,10); 
    gEAF = genData.gEAF(:,10);
end
if (tStart >=7297 && tStart < 8017)    % Nov
    gFuelPrice = genData.gFuelPrice(:,11); 
    gEAF = genData.gEAF(:,11);
end
if (tStart >=8017)                     % Dec
    gFuelPrice = genData.gFuelPrice(:,12);      
    gEAF = genData.gEAF(:,12);
end               

% Apply EAF derating
gEAF = gEAF + (1 - gEAF).*EAFderating;
gCapacity = gCapacity .* gEAF;
gMin = genData.gMin.*gCapacity;

% Calculate variable cost.  Include emission prices and marginal damages as 
% specified by settings. Also include 10% cost adder on fuel price and 
% variable O&M as allowed by PJM.
gEmissionPrice = (gNOX*settings.priceNOX + gSO2*settings.priceSO2 + gN2O*settings.priceN2O + gCO2*settings.priceCO2 + gCO2eqv*settings.priceCO2eqv + gCO*settings.priceCO + gNH3*settings.priceNH3 + gPM10*settings.pricePM10 + gPM25*settings.pricePM25 + gVOC*settings.priceVOC)/2000;
gMDPrice = gMDNH3*settings.isMDNH3 + gMDSO2*settings.isMDSO2 + gMDVOC*settings.isMDVOC + gMDNOX*settings.isMDNOX + gMDPM25*settings.isMDPM25 + gMDPM10*settings.isMDPM10;

gVC = 1.1*(gHeatRate.*gFuelPrice + gVarOM) + gEmissionPrice + gMDPrice;

% Calculate startup costs.  Include emission prices and marginal damages as
% specified by settings.

gStartupEmissionPrice = (gStartupNOX*settings.priceNOX + gStartupSO2*settings.priceSO2 + gStartupCO2*settings.priceCO2);
gStartupMDPrice = gStartupMDNOX*settings.isMDNOX + gStartupMDSO2*settings.isMDSO2;
gStartupCost = genData.gStartupCost + gStartupEmissionPrice + gStartupMDPrice;

%% Create generator GDX files

% Set up GAMS subsets of generators for each TCR
gens = [];
gensTCR1 = [];
gensTCR2 = [];
gensTCR3 = [];
gensTCR4 = [];
gensTCR5 = [];
countTCR1 = 1;
countTCR2 = 1;
countTCR3 = 1;
countTCR4 = 1;
countTCR5 = 1;
for g = 1 : size(gTCR,1)
    gens{g} = strcat('g',num2str(g));
    if gTCR(g) == 1 
        gensTCR1{countTCR1} = strcat('g',num2str(g));
        countTCR1 = countTCR1+1;
    elseif gTCR(g) == 2 
        gensTCR2{countTCR2} = strcat('g',num2str(g));
        countTCR2 = countTCR2+1;
    elseif gTCR(g) == 3 
        gensTCR3{countTCR3} = strcat('g',num2str(g));
        countTCR3 = countTCR3+1;
    elseif gTCR(g) == 4 
        gensTCR4{countTCR4} = strcat('g',num2str(g));
        countTCR4 = countTCR4+1;
    elseif gTCR(g) == 5 
        gensTCR5{countTCR5} = strcat('g',num2str(g));
        countTCR5 = countTCR5+1;
    end
end

% Create GDX structures
gensGDX.name = 'g';
gensGDX.type = 'set';
gensGDX.uels = gens;

gensTCR1GDX.name = 'gTCR1';
gensTCR1GDX.type = 'set';
gensTCR1GDX.uels = gensTCR1;

gensTCR2GDX.name = 'gTCR2';
gensTCR2GDX.type = 'set';
gensTCR2GDX.uels = gensTCR2;

gensTCR3GDX.name = 'gTCR3';
gensTCR3GDX.type = 'set';
gensTCR3GDX.uels = gensTCR3;

gensTCR4GDX.name = 'gTCR4';
gensTCR4GDX.type = 'set';
gensTCR4GDX.uels = gensTCR4;

gensTCR5GDX.name = 'gTCR5';
gensTCR5GDX.type = 'set';
gensTCR5GDX.uels = gensTCR5;

gCapacityGDX.name = 'gCapacity';
gCapacityGDX.type = 'parameter';
gCapacityGDX.uels = gens;
gCapacityGDX.form = 'full';
gCapacityGDX.dim = 2;
gCapacityGDX.val = gCapacity;

gRampRateGDX.name = 'gRampRate';
gRampRateGDX.type = 'parameter';
gRampRateGDX.uels = gens;
gRampRateGDX.form = 'full';
gRampRateGDX.dim = 1;
gRampRateGDX.val = gRampRate;

gMinCapacityGDX.name = 'gMinCapacity';
gMinCapacityGDX.type = 'parameter';
gMinCapacityGDX.uels = gens;
gMinCapacityGDX.form = 'full';
gMinCapacityGDX.dim = 2;
gMinCapacityGDX.val = gMin;

gMinUpGDX.name = 'gMinUp';
gMinUpGDX.type = 'parameter';
gMinUpGDX.uels = gens;
gMinUpGDX.form = 'full';
gMinUpGDX.dim = 2;
gMinUpGDX.val = gMinUp;

gMinDownGDX.name = 'gMinDown';
gMinDownGDX.type = 'parameter';
gMinDownGDX.uels = gens;
gMinDownGDX.form = 'full';
gMinDownGDX.dim = 2;
gMinDownGDX.val = gMinDown;

gStartupCostGDX.name = 'gStartupC';
gStartupCostGDX.type = 'parameter';
gStartupCostGDX.uels = gens;
gStartupCostGDX.form = 'full';
gStartupCostGDX.dim = 2;
gStartupCostGDX.val = gStartupCost;

gVCGDX.name = 'gVC';
gVCGDX.type = 'parameter';
gVCGDX.uels = gens;
gVCGDX.form = 'full';
gVCGDX.dim = 2;
gVCGDX.val = gVC;

gNLCGDX.name = 'gNLC';
gNLCGDX.type = 'parameter';
gNLCGDX.uels = gens;
gNLCGDX.form = 'full';
gNLCGDX.dim = 2;
gNLCGDX.val = gNLC;

% Calculate initial state and runtime/offtime from previous run.  Load to
% GDX.
gOntime = prevDayResults.gOntime;
gDowntime = prevDayResults.gDowntime;
gInitGen = prevDayResults.gInitGen;
gInitState = prevDayResults.gInitState;

if isempty(gOntime)
    gOntime = zeros(length(gCapacity),1);
else
    for index = 1 : length(gOntime)
        if gOntime(index) ~= 0
            gOntime(index) = gMinUp(index) - gOntime(index);
            if gOntime(index) < 0
                gOntime(index) = 0;
            end
        end
    end
end
if isempty(gDowntime)
    gDowntime = zeros(length(gCapacity),1);
else
    for index = 1 : length(gDowntime)
        if gDowntime(index) ~= 0
            gDowntime(index) = gMinDown(index) - gDowntime(index);
            if gDowntime(index) < 0
                gDowntime(index) = 0;
            end
        end
    end
end

gOntimeGDX.name = 'gOntime';
gOntimeGDX.type = 'parameter';
gOntimeGDX.uels = gens;
gOntimeGDX.form = 'full';
gOntimeGDX.dim = 2;
gOntimeGDX.val = gOntime;

gDowntimeGDX.name = 'gDowntime';
gDowntimeGDX.type = 'parameter';
gDowntimeGDX.uels = gens;
gDowntimeGDX.form = 'full';
gDowntimeGDX.dim = 2;
gDowntimeGDX.val = gDowntime;

if isempty(gInitState)
    gInitState = zeros(size(gens,2),1);
end
gInitStateGDX.name = 'gInitState';
gInitStateGDX.type = 'parameter';
gInitStateGDX.uels = gens;
gInitStateGDX.form = 'full';
gInitStateGDX.dim = 2;
gInitStateGDX.val = gInitState;

if isempty(gInitGen)
    gInitGen = zeros(1,size(gens,2));
end

% If the init gen is larger than max gen, due to offline gen issues, set
% init gen equal to max gen
for index = 1 : size(gInitGen, 2)
    if gInitGen(1,index) > gCapacity(index,1)
        gInitGen(1,index) = gCapacity(index,1);
    end
    if gInitGen(1,index) > 0 && gInitGen(1,index) < gMin(index,1)
        gInitGen(1,index) = gMin(index,1);
    end
end

gInitGenGDX.name = 'gInitGen';
gInitGenGDX.type = 'parameter';
gInitGenGDX.uels = gens;
gInitGenGDX.form = 'full';
gInitGenGDX.dim = 2;
gInitGenGDX.val = gInitGen;

% Write GDX file
wgdx('GenData', gensGDX, gensTCR1GDX, gensTCR2GDX, gensTCR3GDX, gensTCR4GDX, gensTCR5GDX, gInitStateGDX, gInitGenGDX, gOntimeGDX, gDowntimeGDX, gCapacityGDX, gVCGDX, gRampRateGDX, gMinCapacityGDX, gMinUpGDX, gMinDownGDX, gStartupCostGDX, gNLCGDX);
%% Load needed loadData to memory

% load
PSEG = loadData.PSEG(tStart:tEnd);
PECO = loadData.PECO(tStart:tEnd);
PPL = loadData.PPL(tStart:tEnd);
BGE = loadData.BGE(tStart:tEnd);
PEPCO = loadData.PEPCO(tStart:tEnd);
RECO = loadData.RECO(tStart:tEnd);
APS = loadData.APS(tStart:tEnd);
COMED = loadData.COMED(tStart:tEnd);
AEP = loadData.AEP(tStart:tEnd);
DAY = loadData.DAY(tStart:tEnd);
DUQ = loadData.DUQ(tStart:tEnd);
DOM = loadData.DOM(tStart:tEnd);
JCPL = loadData.JCPL(tStart:tEnd);
METED = loadData.METED(tStart:tEnd);
PENELEC = loadData.PENELEC(tStart:tEnd);
AECO = loadData.AECO(tStart:tEnd);
DPL = loadData.DPL(tStart:tEnd);

% Imports / exports
ALTE = loadData.ALTE(tStart:tEnd);
ALTW = loadData.ALTW(tStart:tEnd);
AMIL = loadData.AMIL(tStart:tEnd);
CIN = loadData.CIN(tStart:tEnd);
CPLE = loadData.CPLE(tStart:tEnd);
CPLW = loadData.CPLW(tStart:tEnd);
CWLP = loadData.CWLP(tStart:tEnd);
DUK = loadData.DUK(tStart:tEnd);
EKPC = loadData.EKPC(tStart:tEnd);
FE = loadData.FE(tStart:tEnd);
IPL = loadData.IPL(tStart:tEnd);
LGEE = loadData.LGEE(tStart:tEnd);
LIND = loadData.LIND(tStart:tEnd);
MEC = loadData.MEC(tStart:tEnd);
MECS = loadData.MECS(tStart:tEnd);
NEPT = loadData.NEPT(tStart:tEnd);
NIPS = loadData.NIPS(tStart:tEnd);
NYIS = loadData.NYIS(tStart:tEnd);
OVEC = loadData.OVEC(tStart:tEnd);
TVA = loadData.TVA(tStart:tEnd);
WEC = loadData.WEC(tStart:tEnd);

% Select appropriate wind scenario
if settings.isWindBase2010 == 1
    windMaxTCR1 = windData.windBaseCase2010(tStart:tEnd, 1);
    windMaxTCR2 = windData.windBaseCase2010(tStart:tEnd, 2);
    windMaxTCR3 = windData.windBaseCase2010(tStart:tEnd, 3);
    windMaxTCR4 = windData.windBaseCase2010(tStart:tEnd, 4);
    windMaxTCR5 = windData.windBaseCase2010(tStart:tEnd, 5);
elseif settings.isWind10INIL == 1
    windMaxTCR1 = windData.windData10INIL(tStart:tEnd, 1);
    windMaxTCR2 = windData.windData10INIL(tStart:tEnd, 2);
    windMaxTCR3 = windData.windData10INIL(tStart:tEnd, 3);
    windMaxTCR4 = windData.windData10INIL(tStart:tEnd, 4);
    windMaxTCR5 = windData.windData10INIL(tStart:tEnd, 5);
elseif settings.isWind20INIL == 1
    windMaxTCR1 = windData.windData20INIL(tStart:tEnd, 1);
    windMaxTCR2 = windData.windData20INIL(tStart:tEnd, 2);
    windMaxTCR3 = windData.windData20INIL(tStart:tEnd, 3);
    windMaxTCR4 = windData.windData20INIL(tStart:tEnd, 4);
    windMaxTCR5 = windData.windData20INIL(tStart:tEnd, 5);
elseif settings.isWind10 == 1
    windMaxTCR1 = windData.windData10(tStart:tEnd, 1);
    windMaxTCR2 = windData.windData10(tStart:tEnd, 2);
    windMaxTCR3 = windData.windData10(tStart:tEnd, 3);
    windMaxTCR4 = windData.windData10(tStart:tEnd, 4);
    windMaxTCR5 = windData.windData10(tStart:tEnd, 5);    
end
    

% Assign imports to zones
AEP = AEP - (ALTE + ALTW + AMIL + CPLW + CWLP + DUK + EKPC + IPL + LGEE + MEC + MECS + NIPS + OVEC + TVA + WEC);
PENELEC = PENELEC - FE;
PSEG = PSEG - (NEPT + NYIS + LIND);
DOM = DOM - CPLE;
DAY = DAY - CIN;
 
% Assign zones to TCRs
%loadTCR1 = AEP + APS + COMED + DAY + DUQ + PENELEC - windMaxTCR1;
loadTCR1 = AEP + APS + COMED + DAY + DUQ + PENELEC;
loadTCR2 = BGE + PEPCO;
loadTCR3 = METED + PPL;
%loadTCR4 = JCPL + PECO + PSEG + AECO + DPL + RECO - windMaxTCR3;
loadTCR4 = JCPL + PECO + PSEG + AECO + DPL + RECO;
loadTCR5 = DOM;

% Allocate synchronized reserve.  Reserve requirements equal to largest 
% single generator in TCR1, TCRs2-4,and TCR5
loadTCR1 = loadTCR1 + 1300;
loadTCR2 = loadTCR2 + 1170*loadTCR2./(loadTCR2 + loadTCR3 + loadTCR4);
loadTCR3 = loadTCR3 + 1170*loadTCR3./(loadTCR2 + loadTCR3 + loadTCR4);
loadTCR4 = loadTCR4 + 1170*loadTCR4./(loadTCR2 + loadTCR3 + loadTCR4);
loadTCR5 = loadTCR5 + 1170;

% TEMP set loadTCR1 to 1
%loadTCR1 = loadTCR1*0+1000;


% Transmission constraints
EImax = loadData.EImax(tStart:tEnd);
CImax = loadData.CImax(tStart:tEnd);
WImax = loadData.WImax(tStart:tEnd);
DOMImax = loadData.DOMImax(tStart:tEnd);

% Actual LMPs
 LMPTCR1actual = loadData.LMPTCR1actual(tStart:tEnd);
 LMPTCR2actual = loadData.LMPTCR2actual(tStart:tEnd);
 LMPTCR3actual = loadData.LMPTCR3actual(tStart:tEnd);
 LMPTCR4actual = loadData.LMPTCR4actual(tStart:tEnd);
 LMPTCR5actual = loadData.LMPTCR5actual(tStart:tEnd);

% Setup for initial run - 
% Add time period 0, which is hour 24 from the previous optimization.
% Because ramping and supply/demand constraints don't hold for this hour,
% set load equal to t=1
loadTCR1 = [loadTCR1(1); loadTCR1];
loadTCR2 = [loadTCR2(1); loadTCR2];
loadTCR3 = [loadTCR3(1); loadTCR3];
loadTCR4 = [loadTCR4(1); loadTCR4];
loadTCR5 = [loadTCR5(1); loadTCR5];
DOMImax = [DOMImax(1); DOMImax];
WImax = [WImax(1); WImax];
CImax = [CImax(1); CImax];
EImax = [EImax(1); EImax];
windMaxTCR1 = [windMaxTCR1(1); windMaxTCR1];
windMaxTCR2 = [windMaxTCR2(1); windMaxTCR2];
windMaxTCR3 = [windMaxTCR3(1); windMaxTCR3];
windMaxTCR4 = [windMaxTCR4(1); windMaxTCR4];
windMaxTCR5 = [windMaxTCR5(1); windMaxTCR5];

%% Create load GDX files

% Create GDX structures
timeVars = {};
for t = 1 : length(loadTCR1)
    timeVars{t} = strcat('t',num2str(t));
end
time.name = 't';
time.type = 'set';
time.uels = timeVars;

loadTCR1GDX.name = 'loadTCR1';
loadTCR1GDX.val = loadTCR1;
loadTCR1GDX.type = 'parameter';
loadTCR1GDX.uels = timeVars;
loadTCR1GDX.form = 'full';
loadTCR1GDX.dim = 1;

loadTCR2GDX.name = 'loadTCR2';
loadTCR2GDX.val = loadTCR2;
loadTCR2GDX.type = 'parameter';
loadTCR2GDX.uels = timeVars;
loadTCR2GDX.form = 'full';
loadTCR2GDX.dim = 1;

loadTCR3GDX.name = 'loadTCR3';
loadTCR3GDX.val = loadTCR3;
loadTCR3GDX.type = 'parameter';
loadTCR3GDX.uels = timeVars;
loadTCR3GDX.form = 'full';
loadTCR3GDX.dim = 1;

loadTCR4GDX.name = 'loadTCR4';
loadTCR4GDX.val = loadTCR4;
loadTCR4GDX.type = 'parameter';
loadTCR4GDX.uels = timeVars;
loadTCR4GDX.form = 'full';
loadTCR4GDX.dim = 1;

loadTCR5GDX.name = 'loadTCR5';
loadTCR5GDX.val = loadTCR5;
loadTCR5GDX.type = 'parameter';
loadTCR5GDX.uels = timeVars;
loadTCR5GDX.form = 'full';
loadTCR5GDX.dim = 1;

TI12maxGDX.name = 'TI12max';
TI12maxGDX.val = WImax/4;
TI12maxGDX.type = 'parameter';
TI12maxGDX.uels = timeVars;
TI12maxGDX.form = 'full';
TI12maxGDX.dim = 1;

TI13maxGDX.name = 'TI13max';
TI13maxGDX.val = WImax/2;
TI13maxGDX.type = 'parameter';
TI13maxGDX.uels = timeVars;
TI13maxGDX.form = 'full';
TI13maxGDX.dim = 1;

TI15maxGDX.name = 'TI15max';
TI15maxGDX.val = DOMImax;
TI15maxGDX.type = 'parameter';
TI15maxGDX.uels = timeVars;
TI15maxGDX.form = 'full';
TI15maxGDX.dim = 1;

TI52maxGDX.name = 'TI52max';
TI52maxGDX.val = WImax/4;
TI52maxGDX.type = 'parameter';
TI52maxGDX.uels = timeVars;
TI52maxGDX.form = 'full';
TI52maxGDX.dim = 1;

TI23maxGDX.name = 'TI23max';
TI23maxGDX.val = CImax;
TI23maxGDX.type = 'parameter';
TI23maxGDX.uels = timeVars;
TI23maxGDX.form = 'full';
TI23maxGDX.dim = 1;

TI34maxGDX.name = 'TI34max';
TI34maxGDX.val = EImax;
TI34maxGDX.type = 'parameter';
TI34maxGDX.uels = timeVars;
TI34maxGDX.form = 'full';
TI34maxGDX.dim = 1;

LMPTCR1actualGDX.name = 'LMPTCR1actual';
LMPTCR1actualGDX.val = LMPTCR1actual;
LMPTCR1actualGDX.type = 'parameter';
LMPTCR1actualGDX.uels = timeVars;
LMPTCR1actualGDX.form = 'full';
LMPTCR1actualGDX.dim = 1;

LMPTCR2actualGDX.name = 'LMPTCR2actual';
LMPTCR2actualGDX.val = LMPTCR2actual;
LMPTCR2actualGDX.type = 'parameter';
LMPTCR2actualGDX.uels = timeVars;
LMPTCR2actualGDX.form = 'full';
LMPTCR2actualGDX.dim = 1;

LMPTCR3actualGDX.name = 'LMPTCR3actual';
LMPTCR3actualGDX.val = LMPTCR3actual;
LMPTCR3actualGDX.type = 'parameter';
LMPTCR3actualGDX.uels = timeVars;
LMPTCR3actualGDX.form = 'full';
LMPTCR3actualGDX.dim = 1;

LMPTCR4actualGDX.name = 'LMPTCR4actual';
LMPTCR4actualGDX.val = LMPTCR4actual;
LMPTCR4actualGDX.type = 'parameter';
LMPTCR4actualGDX.uels = timeVars;
LMPTCR4actualGDX.form = 'full';
LMPTCR4actualGDX.dim = 1;

LMPTCR5actualGDX.name = 'LMPTCR5actual';
LMPTCR5actualGDX.val = LMPTCR5actual;
LMPTCR5actualGDX.type = 'parameter';
LMPTCR5actualGDX.uels = timeVars;
LMPTCR5actualGDX.form = 'full';
LMPTCR5actualGDX.dim = 1;

windMaxTCR1GDX.name = 'windMaxTCR1';
windMaxTCR1GDX.val = windMaxTCR1;
windMaxTCR1GDX.type = 'parameter';
windMaxTCR1GDX.uels = timeVars;
windMaxTCR1GDX.form = 'full';
windMaxTCR1GDX.dim = 1;

windMaxTCR2GDX.name = 'windMaxTCR2';
windMaxTCR2GDX.val = windMaxTCR2;
windMaxTCR2GDX.type = 'parameter';
windMaxTCR2GDX.uels = timeVars;
windMaxTCR2GDX.form = 'full';
windMaxTCR2GDX.dim = 1;

windMaxTCR3GDX.name = 'windMaxTCR3';
windMaxTCR3GDX.val = windMaxTCR3;
windMaxTCR3GDX.type = 'parameter';
windMaxTCR3GDX.uels = timeVars;
windMaxTCR3GDX.form = 'full';
windMaxTCR3GDX.dim = 1;

windMaxTCR4GDX.name = 'windMaxTCR4';
windMaxTCR4GDX.val = windMaxTCR4;
windMaxTCR4GDX.type = 'parameter';
windMaxTCR4GDX.uels = timeVars;
windMaxTCR4GDX.form = 'full';
windMaxTCR4GDX.dim = 1;

windMaxTCR5GDX.name = 'windMaxTCR5';
windMaxTCR5GDX.val = windMaxTCR5;
windMaxTCR5GDX.type = 'parameter';
windMaxTCR5GDX.uels = timeVars;
windMaxTCR5GDX.form = 'full';
windMaxTCR5GDX.dim = 1;

% Create load GDX file
wgdx('LoadData', time, loadTCR1GDX, loadTCR2GDX, loadTCR3GDX, loadTCR4GDX, loadTCR5GDX, TI12maxGDX, TI13maxGDX, TI15maxGDX, TI52maxGDX, TI23maxGDX, TI34maxGDX, LMPTCR1actualGDX, LMPTCR2actualGDX, LMPTCR3actualGDX, LMPTCR4actualGDX, LMPTCR5actualGDX, windMaxTCR1GDX, windMaxTCR2GDX, windMaxTCR3GDX, windMaxTCR4GDX, windMaxTCR5GDX);

% This function loads storage data into GAMS.

%% Load needed storageData to memory

sTCR = storageData.sTCR;
sCapacity = storageData.sCapacity;
sChargeEff = storageData.sChargeEff;
sDischargeEff = storageData.sDischargeEff;
sDuration = storageData.sDuration;
sVC = storageData.sVC;

% Set initial SOC.  If this is the first day, set equal to 1/2 capacity.
% If this is not the first day, use results from the previous day.
if isempty(prevDayResults.sInitSOC)
    sInitSOC = sCapacity.*sDuration/2;
else
    sInitSOC = prevDayResults.sInitSOC;
end

% Set the max SOC (capacity in MWh)
sSOCmax = sCapacity.*sDuration;

% Set up GAMS subsets of generators for each TCR.  If a TCR does not
% contain any storage, direct it to the 'blank' entry in the storage
% database.

stors = [];
storsTCR1 = [];
storsTCR2 = [];
storsTCR3 = [];
storsTCR4 = [];
storsTCR5 = [];
countTCR1 = 1;
countTCR2 = 1;
countTCR3 = 1;
countTCR4 = 1;
countTCR5 = 1;
for s = 1 : size(sTCR,1)
    stors{s} = strcat('s',num2str(s));
    if sTCR(s) == 1 
        storsTCR1{countTCR1} = strcat('s',num2str(s));
        countTCR1 = countTCR1+1;
    elseif sTCR(s) == 2 
        storsTCR2{countTCR2} = strcat('s',num2str(s));
        countTCR2 = countTCR2+1;
    elseif sTCR(s) == 3 
        storsTCR3{countTCR3} = strcat('s',num2str(s));
        countTCR3 = countTCR3+1;
    elseif sTCR(s) == 4 
        storsTCR4{countTCR4} = strcat('s',num2str(s));
        countTCR4 = countTCR4+1;
    elseif sTCR(s) == 5 
        storsTCR5{countTCR5} = strcat('s',num2str(s));
        countTCR5 = countTCR5+1;
    end
end

storsGDX.name = 's';
storsGDX.type = 'set';
storsGDX.uels = stors;

storsTCR1GDX.name = 'sTCR1';
storsTCR1GDX.type = 'set';
if isempty(storsTCR1) == 0
    storsTCR1GDX.uels = storsTCR1;   
else
    storsTCR1GDX.uels = {'s1'};
end
storsTCR2GDX.name = 'sTCR2';
storsTCR2GDX.type = 'set';
if isempty(storsTCR2) == 0
    storsTCR2GDX.uels = storsTCR2;
else
    storsTCR2GDX.uels = {'s1'};
end
storsTCR3GDX.name = 'sTCR3';
storsTCR3GDX.type = 'set';
if isempty(storsTCR3) == 0
    storsTCR3GDX.uels = storsTCR3;
else
    storsTCR3GDX.uels = {'s1'};
end
storsTCR4GDX.name = 'sTCR4';
storsTCR4GDX.type = 'set';
if isempty(storsTCR4) == 0
    storsTCR4GDX.uels = storsTCR4;
else
    storsTCR4GDX.uels = {'s1'};
end
storsTCR5GDX.name = 'sTCR5';
storsTCR5GDX.type = 'set';
if isempty(storsTCR5) == 0
    storsTCR5GDX.uels = storsTCR5;
else
    storsTCR5GDX.uels = {'s1'};
end

sRampRateGDX.name = 'sRampRate';
sRampRateGDX.type = 'parameter';
sRampRateGDX.val = sCapacity;
sRampRateGDX.uels = stors;
sRampRateGDX.form = 'full';
sRampRateGDX.dim = 2;

sSOCmaxGDX.name = 'sSOCmax';
sSOCmaxGDX.type = 'parameter';
sSOCmaxGDX.val = sSOCmax;
sSOCmaxGDX.uels = stors;
sSOCmaxGDX.form = 'full';
sSOCmaxGDX.dim = 2;

sChargeEffGDX.name = 'sChargeEff';
sChargeEffGDX.type = 'parameter';
sChargeEffGDX.val = sChargeEff;
sChargeEffGDX.uels = stors;
sChargeEffGDX.form = 'full';
sChargeEffGDX.dim = 2;

sDischargeEffGDX.name = 'sDischargeEff';
sDischargeEffGDX.type = 'parameter';
sDischargeEffGDX.val = sDischargeEff;
sDischargeEffGDX.uels = stors;
sDischargeEffGDX.form = 'full';
sDischargeEffGDX.dim = 2;

sVCGDX.name = 'sMargCost';
sVCGDX.type = 'parameter';
sVCGDX.val = sVC;
sVCGDX.uels = stors;
sVCGDX.form = 'full';
sVCGDX.dim = 2;

sInitSOCGDX.name = 'sInitSOC';
sInitSOCGDX.type = 'parameter';
sInitSOCGDX.val = sInitSOC;
sInitSOCGDX.uels = stors;
sInitSOCGDX.form = 'full';
sInitSOCGDX.dim = 2;

wgdx('StorageData', storsGDX, storsTCR1GDX, storsTCR2GDX, storsTCR3GDX, storsTCR4GDX, storsTCR5GDX, sRampRateGDX, sSOCmaxGDX, sChargeEffGDX, sDischargeEffGDX, sVCGDX, sInitSOCGDX);

end
    
