% PHORUM (PJM Hourly Open-source Reduced-form Unit commitment Model) 
% Copyright (C) 2013  Roger Lueken
% InitializeResultsStruct.m
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

function [totalResults, prevDayResults] = InitializeResultsStruct(settings)

% Structure to store results from all days
totalResults.gLevel = [];
totalResults.gVC = [];
totalResults.gRuntime = [];
totalResults.gStartup = [];
totalResults.gGrossRevenue = [];
totalResults.sysCost = [];
totalResults.tLevelTI12 = [];
totalResults.tLevelTI13 = [];
totalResults.tLevelTI15 = [];
totalResults.tLevelTI52 = [];
totalResults.tLevelTI23 = [];
totalResults.tLevelTI34 = [];
totalResults.tMaxTI12 = [];
totalResults.tMaxTI13 = [];
totalResults.tMaxTI15 = [];
totalResults.tMaxTI52 = [];
totalResults.tMaxTI23 = [];
totalResults.tMaxTI34 = [];
totalResults.LMPTCR1 = [];
totalResults.LMPTCR2 = [];
totalResults.LMPTCR3 = [];
totalResults.LMPTCR4 = [];
totalResults.LMPTCR5 = [];
totalResults.LMPTCR1actual = [];
totalResults.LMPTCR2actual = [];
totalResults.LMPTCR3actual = [];
totalResults.LMPTCR4actual = [];
totalResults.LMPTCR5actual = [];
totalResults.sCharge = [];
totalResults.sDischarge = [];
totalResults.sSOC = [];
totalResults.sNetRevenue = [];
totalResults.date = [];
totalResults.runtime = [];
totalResults.loadTCR1 = [];
totalResults.loadTCR2 = [];
totalResults.loadTCR3 = [];
totalResults.loadTCR4 = [];
totalResults.loadTCR5 = [];
totalResults.windTCR1 = [];
totalResults.windTCR2 = [];
totalResults.windTCR3 = [];
totalResults.windTCR4 = [];
totalResults.windTCR5 = [];
% Structure to track cross-day variables
prevDayResults.gOntime = [];            % All gens are off for first hour of first day
prevDayResults.gDowntime = [];
prevDayResults.gInitState = [];
prevDayResults.gInitGen = [];
prevDayResults.sInitSOC = [];
    
