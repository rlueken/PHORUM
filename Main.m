% PHORUM (PJM Hourly Open-source Reduced-form Unit commitment Model) 
% Copyright (C) 2013  Roger Lueken
% Main.m
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

% This is the primary PHORUM Matlab function.  The function makes 
% several sub-function calls, and is responsible for calling GAMS. 
% The function loads data from the database file and settings file.

function Main()

%% Load settings
load('settings');
%saddpath(settings.GAMSpath);

% Optimization window - number of hours in each optimization
optWindow = 48;

%% Load input data
load(settings.dataFileName);

% Initialize all results structures
[totalResults, prevDayResults] = InitializeResultsStruct(settings);

%% Daily GAMS loop
totalRuntime = 0;
for rangeIndex = 1 : settings.numDateRanges
    for day = settings.dStart(rangeIndex) : 1: settings.dEnd(rangeIndex) - 1
        
        % Status
        tic;
        disp(['Running GAMS, day: ', num2str(day)]);
        
        % Create GDX files
        CreateGDX(day, PHORUMdata, settings, prevDayResults, optWindow);
        % Run GAMS
        system(settings.callGAMS);

        % Parse daily results
         [totalResults, prevDayResults] = ParseOutputs(totalResults, PHORUMdata, day, settings.dEnd(rangeIndex), optWindow, totalRuntime, tic);
         
    end
end
disp(['Saving results to ', settings.outputFileName, '...']);
% Create all outputs as specified by settings
outputs = SaveResults(totalResults, settings, PHORUMdata);



end
