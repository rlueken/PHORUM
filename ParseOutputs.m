% PHORUM (PJM Hourly Open-source Reduced-form Unit commitment Model) 
% Copyright (C) 2013  Roger Lueken
% ParseOutputs.m
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

function [totalResults, prevDayResults] = ParseOutputs(totalResults, PHORUMdata, day, dEnd, optWindow, totalRuntime,tic)

% This function parses the results from the GAMS run.  It pulls
% results from results.GDX, cleans the data, and saves it to the
% totalResults structure.  Cross-day variables are saved to the
% prevDayResults structure.
numGens = length(PHORUMdata.genData.gHeatRate);
numStors = length(PHORUMdata.storageData.sCapacity);

% Check if this is the last day of the range.  If so, save results for all 48 hours.
 hour = 24;
 lastDay = 0;
 if day == dEnd - 1
     hour = optWindow;
     lastDay = 1;
 end
 
% Save date and runtime
totalResults.date = [totalResults.date, day];
if lastDay == 1
    totalResults.date = [totalResults.date, day+1];
end    

runtime = toc;
totalRuntime = sum(totalResults.runtime) + runtime;
totalResults.runtime = [totalResults.runtime,runtime];
disp(['Day complete.  Runtime: ', num2str(runtime/60), ', Total runtime: ', num2str(totalRuntime/60)]);
 
%% If optimization did not execute correctly, set results = 0 and return
if toc < 20 || toc > 7200
    totalResults.loadTCR1 = [totalResults.loadTCR1, zeros(1,hour)];
    totalResults.loadTCR2 = [totalResults.loadTCR2, zeros(1,hour)];
    totalResults.loadTCR3 = [totalResults.loadTCR3, zeros(1,hour)];
    totalResults.loadTCR4 = [totalResults.loadTCR4, zeros(1,hour)];
    totalResults.loadTCR5 = [totalResults.loadTCR5, zeros(1,hour)];

    % Storage
    totalResults.sSOC = [totalResults.sSOC, zeros(numStors,hour)];

    % Transmission
    totalResults.tLevelTI12 = [totalResults.tLevelTI12, zeros(1,hour)];
    totalResults.tLevelTI13 = [totalResults.tLevelTI13, zeros(1,hour)];
    totalResults.tLevelTI15 = [totalResults.tLevelTI15, zeros(1,hour)];
    totalResults.tLevelTI52 = [totalResults.tLevelTI52, zeros(1,hour)];
    totalResults.tLevelTI23 = [totalResults.tLevelTI23, zeros(1,hour)];
    totalResults.tLevelTI34 = [totalResults.tLevelTI34, zeros(1,hour)];

    totalResults.tMaxTI12 = [totalResults.tMaxTI12, zeros(1,hour)];
    totalResults.tMaxTI13 = [totalResults.tMaxTI13, zeros(1,hour)];
    totalResults.tMaxTI15 = [totalResults.tMaxTI15, zeros(1,hour)];
    totalResults.tMaxTI52 = [totalResults.tMaxTI52, zeros(1,hour)];
    totalResults.tMaxTI23 = [totalResults.tMaxTI23, zeros(1,hour)];
    totalResults.tMaxTI34 = [totalResults.tMaxTI34, zeros(1,hour)];

    % LMPs
    totalResults.LMPTCR1 = [totalResults.LMPTCR1, zeros(1,hour)];
    totalResults.LMPTCR2 = [totalResults.LMPTCR2, zeros(1,hour)];
    totalResults.LMPTCR3 = [totalResults.LMPTCR3, zeros(1,hour)];
    totalResults.LMPTCR4 = [totalResults.LMPTCR4, zeros(1,hour)];
    totalResults.LMPTCR5 = [totalResults.LMPTCR5, zeros(1,hour)];
    totalResults.LMPTCR1actual = [totalResults.LMPTCR1actual, zeros(1,hour)];
    totalResults.LMPTCR2actual = [totalResults.LMPTCR2actual, zeros(1,hour)];
    totalResults.LMPTCR3actual = [totalResults.LMPTCR3actual, zeros(1,hour)];
    totalResults.LMPTCR4actual = [totalResults.LMPTCR4actual, zeros(1,hour)];
    totalResults.LMPTCR5actual = [totalResults.LMPTCR5actual, zeros(1,hour)];

    % System Cost
    totalResults.sysCost = [totalResults.sysCost, 0];
    totalResults.gLevel = [totalResults.gLevel, zeros(numGens,1)];
    totalResults.gRuntime = [totalResults.gRuntime, zeros(numGens,1)];
    totalResults.gStartup = [totalResults.gStartup, zeros(numGens,1)];
    totalResults.gGrossRevenue = [totalResults.gGrossRevenue, zeros(numGens,1)];
    totalResults.gVC = [totalResults.gVC, zeros(numGens,1)];
    totalResults.windTCR1 = [totalResults.windTCR1, 0];
    totalResults.windTCR2 = [totalResults.windTCR2, 0];
    totalResults.windTCR3 = [totalResults.windTCR3, 0];
    totalResults.windTCR4 = [totalResults.windTCR4, 0];
    totalResults.windTCR5 = [totalResults.windTCR5, 0];

    totalResults.sNetRevenue = [totalResults.sNetRevenue, zeros(numStors,1)];
    totalResults.sCharge = [totalResults.sCharge, zeros(numStors,1)];
    totalResults.sDischarge = [totalResults.sDischarge, zeros(numStors,1)];

% Set prevDayResults to null
     prevDayResults.gOntime = [];
     prevDayResults.gDowntime = [];
     prevDayResults.gInitState = [];
     prevDayResults.gInitGen = [];
     prevDayResults.sInitSOC = [];
     save('totalResults', 'totalResults');
    return;
end


%% Pull outputs from GAMS

GAMSoutput.form = 'full';
GAMSoutput.compress = 'false';

% Wind
GAMSoutput.name = 'windTCR1';
output = rgdx('results.gdx',GAMSoutput);
windTCR1 = output.val;
GAMSoutput.name = 'windTCR2';
output = rgdx('results.gdx',GAMSoutput);
windTCR2 = output.val;
GAMSoutput.name = 'windTCR3';
output = rgdx('results.gdx',GAMSoutput);
windTCR3 = output.val;
GAMSoutput.name = 'windTCR4';
output = rgdx('results.gdx',GAMSoutput);
windTCR4 = output.val;
GAMSoutput.name = 'windTCR5';
output = rgdx('results.gdx',GAMSoutput);
windTCR5 = output.val;

% Generation
GAMSoutput.name = 'gLevel';
output = rgdx('results.gdx', GAMSoutput);
gLevel = output.val;

% Variable costs
GAMSoutput.name = 'gVC';
output = rgdx('results.gdx', GAMSoutput);
gVC = output.val;

% Load
GAMSoutput.name = 'loadTCR1';
output = rgdx('results.gdx', GAMSoutput);
loadTCR1 = output.val;
GAMSoutput.name = 'loadTCR2';
output = rgdx('results.gdx', GAMSoutput);
loadTCR2 = output.val;
GAMSoutput.name = 'loadTCR3';
output = rgdx('results.gdx', GAMSoutput);
loadTCR3 = output.val;
GAMSoutput.name = 'loadTCR4';
output = rgdx('results.gdx', GAMSoutput);
loadTCR4 = output.val;
GAMSoutput.name = 'loadTCR5';
output = rgdx('results.gdx', GAMSoutput);
loadTCR5 = output.val;

% Transmission constraints
GAMSoutput.name = 'TI12max';
output = rgdx('results.gdx', GAMSoutput);
tMaxTI12 = output.val;
GAMSoutput.name = 'TI13max';
output = rgdx('results.gdx', GAMSoutput);
tMaxTI13 = output.val;
GAMSoutput.name = 'TI15max';
output = rgdx('results.gdx', GAMSoutput);
tMaxTI15 = output.val;
GAMSoutput.name = 'TI52max';
output = rgdx('results.gdx', GAMSoutput);
tMaxTI52 = output.val;
GAMSoutput.name = 'TI23max';
output = rgdx('results.gdx', GAMSoutput);
tMaxTI23 = output.val;
GAMSoutput.name = 'TI34max';
output = rgdx('results.gdx', GAMSoutput);
tMaxTI34 = output.val;

% Actual LMPs
GAMSoutput.name = 'LMPTCR1actual';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR1actual = output.val;
GAMSoutput.name = 'LMPTCR2actual';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR2actual = output.val;
GAMSoutput.name = 'LMPTCR3actual';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR3actual = output.val;
GAMSoutput.name = 'LMPTCR4actual';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR4actual = output.val;
GAMSoutput.name = 'LMPTCR5actual';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR5actual = output.val;

% Storage
GAMSoutput.compress='true';
GAMSoutput.name = 'sSOC';
output  = rgdx('results.gdx',GAMSoutput);
sSOC = output.val;
GAMSoutput.compress='false';

%GAMSoutput.name = 'sDischarge';
%output = rgdx('results.gdx',GAMSoutput);
%sDischarge = output.val;
%GAMSoutput.name = 'sCharge';
%output = rgdx('results.gdx',GAMSoutput);
%sCharge = output.val;


% Transmission
GAMSoutput.name = 'TI12';
output = rgdx('results.gdx', GAMSoutput);
tLevelTI12 = output.val;
GAMSoutput.name = 'TI13';
output = rgdx('results.gdx', GAMSoutput);
tLevelTI13 = output.val;
GAMSoutput.name = 'TI15';
output = rgdx('results.gdx', GAMSoutput);
tLevelTI15 = output.val;
GAMSoutput.name = 'TI52';
output = rgdx('results.gdx', GAMSoutput);
tLevelTI52 = output.val;
GAMSoutput.name = 'TI23';
output = rgdx('results.gdx', GAMSoutput);
tLevelTI23 = output.val;
GAMSoutput.name = 'TI34';
output = rgdx('results.gdx', GAMSoutput);
tLevelTI34 = output.val;

% Hourly system cost
GAMSoutput.name = 'HourlyCost';
output = rgdx('results.gdx', GAMSoutput);
sysCost = output.val;

% LMPs
GAMSoutput.compress = 'false';
GAMSoutput.field = 'm';
GAMSoutput.name = 'SUPPLYTCR1c';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR1 = -output.val;
GAMSoutput.name = 'SUPPLYTCR2c';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR2 = -output.val;
GAMSoutput.name = 'SUPPLYTCR3c';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR3 = -output.val;
GAMSoutput.name = 'SUPPLYTCR4c';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR4 = -output.val;
GAMSoutput.name = 'SUPPLYTCR5c';
output = rgdx('results.gdx', GAMSoutput);
LMPTCR5 = -output.val;



%% Clean result structures


% Remove extraneous values returned by GAMS which are not needed
numStorageUnits = size(PHORUMdata.storageData.sTCR,1);
numGens = size(PHORUMdata.genData.gTCR,1);
numResults = size(gLevel,1);

% Storage - calculate sCharge & sDischarge
%sDischarge = sDischarge(numResults-(numStorageUnits-1):numResults, 2:hour+1);
%sDischarge = sDischarge(numGens+1: numGens+6, 2:hour+1);
%sCharge = sCharge(numResults-(numStorageUnits-1):numResults, 2:hour+1);
%sSOC = sSOC(numResults-(numStorageUnits-1):numResults, 2:hour+1);

 if toc > 20 && toc < 7200 % If the day converged
    sDiff = diff(sSOC,1,2);
    sSOC = sSOC(:,2:hour+1);
 else
    sSOC = zeros(numStorageUnits,hour);
    sDiff = zeros(numStorageUnits,hour);
 end

sCharge = [];
sDischarge = [];
for y = 1 : size(sSOC,1)
    for i = 1 : hour
        if sDiff(y,i) >= 0
            sCharge(y,i) = sDiff(y,i);
            sDischarge(y,i) = 0;
        else
            sCharge(y,i) = 0;
            sDischarge(y,i) = -sDiff(y,i);
        end
    end
end
        

% Sys Cost
sysCost = sysCost(2:hour+1);

% Generators
gLevel = gLevel(numResults - (numStorageUnits) - (numGens)+1 : numResults - numStorageUnits, 2:hour+1);
gVC = gVC(numResults - (numStorageUnits) - (numGens)+1 : numResults - numStorageUnits, 1);

% Load
loadTCR1 = loadTCR1(2:hour+1);
loadTCR2 = loadTCR2(2:hour+1);
loadTCR3 = loadTCR3(2:hour+1);
loadTCR4 = loadTCR4(2:hour+1);
loadTCR5 = loadTCR5(2:hour+1);

% Transmission
tLevelTI12 = tLevelTI12(2:hour+1);
tLevelTI13 = tLevelTI13(2:hour+1);
tLevelTI15 = tLevelTI15(2:hour+1);
tLevelTI52 = tLevelTI52(2:hour+1);
tLevelTI23 = tLevelTI23(2:hour+1);
tLevelTI34 = tLevelTI34(2:hour+1);

tMaxTI12 = tMaxTI12(2:hour+1);
tMaxTI13 = tMaxTI13(2:hour+1);
tMaxTI15 = tMaxTI15(2:hour+1);
tMaxTI52 = tMaxTI52(2:hour+1);
tMaxTI23 = tMaxTI23(2:hour+1);
tMaxTI34 = tMaxTI34(2:hour+1);

% LMPs
LMPTCR1 = LMPTCR1(2:hour+1);
LMPTCR2 = LMPTCR2(2:hour+1);
LMPTCR3 = LMPTCR3(2:hour+1);
LMPTCR4 = LMPTCR4(2:hour+1);
LMPTCR5 = LMPTCR5(2:hour+1);

LMPTCR1actual = LMPTCR1actual(2:hour+1);
LMPTCR2actual = LMPTCR2actual(2:hour+1);
LMPTCR3actual = LMPTCR3actual(2:hour+1);
LMPTCR4actual = LMPTCR4actual(2:hour+1);
LMPTCR5actual = LMPTCR5actual(2:hour+1);

windTCR1 = windTCR1(2:hour+1);
windTCR2 = windTCR2(2:hour+1);
windTCR3 = windTCR3(2:hour+1);
windTCR4 = windTCR4(2:hour+1);
windTCR5 = windTCR5(2:hour+1);

%% Load prevDayResults

% How long generators have been on / off
for index = 1 : size(gLevel,1)
    hourCounter = 0;
    prevDayResults.gOntime(index) = 0;
    prevDayResults.gDowntime(index) = 0;
    if gLevel(index, hour) > 0
        while gLevel(index, hour - hourCounter) > 0 && hourCounter < hour - 1
            prevDayResults.gOntime(index) = prevDayResults.gOntime(index) + 1;
            hourCounter = hourCounter + 1;
        end
    end
    if gLevel(index, hour) == 0
        while gLevel(index, hour - hourCounter) == 0 && hourCounter < hour - 1
            prevDayResults.gDowntime(index) = prevDayResults.gDowntime(index) + 1;
            hourCounter = hourCounter + 1;
        end
    end        
end

% Generator level and state (on/off)
for index = 1 : size(gLevel,1)
    prevDayResults.gInitGen(index) = gLevel(index,hour);
    if gLevel(index,hour) > 0
        prevDayResults.gInitState(index) = 1;
    else
        prevDayResults.gInitState(index) = 0;
    end
end

% Storage state of charge
for index = 1 : size(sSOC,1)
    prevDayResults.sInitSOC(index) = sSOC(index,hour);
end

 %% Add the day's results to totalResults

% First, hourly results.

% Load
totalResults.loadTCR1 = [totalResults.loadTCR1, loadTCR1'];
totalResults.loadTCR2 = [totalResults.loadTCR2, loadTCR2'];
totalResults.loadTCR3 = [totalResults.loadTCR3, loadTCR3'];
totalResults.loadTCR4 = [totalResults.loadTCR4, loadTCR4'];
totalResults.loadTCR5 = [totalResults.loadTCR5, loadTCR5'];

% Storage
totalResults.sSOC = [totalResults.sSOC, sSOC(1:numStorageUnits,:)];

% Transmission
totalResults.tLevelTI12 = [totalResults.tLevelTI12, tLevelTI12'];
totalResults.tLevelTI13 = [totalResults.tLevelTI13, tLevelTI13'];
totalResults.tLevelTI15 = [totalResults.tLevelTI15, tLevelTI15'];
totalResults.tLevelTI52 = [totalResults.tLevelTI52, tLevelTI52'];
totalResults.tLevelTI23 = [totalResults.tLevelTI23, tLevelTI23'];
totalResults.tLevelTI34 = [totalResults.tLevelTI34, tLevelTI34'];

totalResults.tMaxTI12 = [totalResults.tMaxTI12, tMaxTI12'];
totalResults.tMaxTI13 = [totalResults.tMaxTI13, tMaxTI13'];
totalResults.tMaxTI15 = [totalResults.tMaxTI15, tMaxTI15'];
totalResults.tMaxTI52 = [totalResults.tMaxTI52, tMaxTI52'];
totalResults.tMaxTI23 = [totalResults.tMaxTI23, tMaxTI23'];
totalResults.tMaxTI34 = [totalResults.tMaxTI34, tMaxTI34'];

% LMPs
totalResults.LMPTCR1 = [totalResults.LMPTCR1, LMPTCR1'];
totalResults.LMPTCR2 = [totalResults.LMPTCR2, LMPTCR2'];
totalResults.LMPTCR3 = [totalResults.LMPTCR3, LMPTCR3'];
totalResults.LMPTCR4 = [totalResults.LMPTCR4, LMPTCR4'];
totalResults.LMPTCR5 = [totalResults.LMPTCR5, LMPTCR5'];

totalResults.LMPTCR1actual = [totalResults.LMPTCR1actual, LMPTCR1actual'];
totalResults.LMPTCR2actual = [totalResults.LMPTCR2actual, LMPTCR2actual'];
totalResults.LMPTCR3actual = [totalResults.LMPTCR3actual, LMPTCR3actual'];
totalResults.LMPTCR4actual = [totalResults.LMPTCR4actual, LMPTCR4actual'];
totalResults.LMPTCR5actual = [totalResults.LMPTCR5actual, LMPTCR5actual'];

% Next, daily outputs
% System Cost
totalResults.sysCost = [totalResults.sysCost, sum(sysCost)'];

% Generation
gRuntime = zeros(size(gLevel,1),size(gLevel,2));
gStartup = zeros(size(gLevel,1),size(gLevel,2));
gGrossRevenue = zeros(size(gLevel,1),size(gLevel,2));

gTCR = PHORUMdata.genData.gTCR;

for rowIndex = 1 : size(gLevel,1)
    for colIndex = 1 : size(gLevel,2)
        % Generator runtime
        if gLevel(rowIndex,colIndex) > 0
            gRuntime(rowIndex,colIndex) = 1;
            % Generator startup
            if colIndex > 1 
                if gLevel(rowIndex,colIndex - 1) == 0
                    gStartup(rowIndex,colIndex) = 1;
                end
            end
        end
        % Generator gross revenue
        if (gTCR(rowIndex) == 1) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR1(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 2) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR2(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 3) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR3(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 4) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR4(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 5) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR5(colIndex)*gLevel(rowIndex,colIndex);
        end    
    end
end
totalResults.gLevel = [totalResults.gLevel, sum(gLevel,2)];
totalResults.gRuntime = [totalResults.gRuntime, sum(gRuntime,2)];
totalResults.gStartup = [totalResults.gStartup, sum(gStartup,2)];
totalResults.gGrossRevenue = [totalResults.gGrossRevenue, sum(gGrossRevenue,2)];
totalResults.gVC = [totalResults.gVC, gVC];
totalResults.windTCR1 = [totalResults.windTCR1,sum(windTCR1)];
totalResults.windTCR2 = [totalResults.windTCR2,sum(windTCR2)];
totalResults.windTCR3 = [totalResults.windTCR3,sum(windTCR3)];
totalResults.windTCR4 = [totalResults.windTCR4,sum(windTCR4)];
totalResults.windTCR5 = [totalResults.windTCR5,sum(windTCR5)];

% Storage gross revenue
sTCR = PHORUMdata.storageData.sTCR;
sNetRevenue = zeros(size(sSOC,1),size(sSOC,2));
for rowIndex = 1 : size(sSOC,1)
    for colIndex = 1 : size(sSOC,2)
        if (sTCR(rowIndex) == 1) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR1(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 2) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR2(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 3) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR3(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 4) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR4(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 5) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR5(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        end
    end
end

totalResults.sNetRevenue = [totalResults.sNetRevenue, sum(sNetRevenue,2)];
totalResults.sCharge = [totalResults.sCharge, sum(sCharge,2)];
totalResults.sDischarge = [totalResults.sDischarge, sum(sDischarge,2)];

save('totalResults', 'totalResults');

end
