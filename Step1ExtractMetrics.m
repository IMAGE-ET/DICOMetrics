function MetricsMatrix = Step1ExtractMetrics(path, StudyType)
% NAStep1ExtractMetricsME - this main function extract all metrics from the path root directory and recursively explore any subsequent folders that contain all DICOM files.
%
% Syntax:  [output1,output2] = function_name(input1,input2,input3)
%
% Inputs:
%    	path 			- the root directory where all DICOM files are located.
%
% Outputs:
%    	MetricsMatrix			- aggregated matrix containing all metrics extracted in a 2D array for ML
%    	Output			- structure contain all indiviudal humanly readable metrics for data storage purposes.
%
% Example:
%    	Line 1 of example
%    	Line 2 of example
%    	Line 3 of example
%
% Other m-files required: 		RecursivelyLoadDICOM.m, LoadConfigVariables.m
% MAT-files required: 			   none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2
% Author: Yang Ding
% All works sponsored by Dr. Gregory Lodygensky and the Canadian Neonatal Brain Platform
% Saint. Justine Hospital, Montreal, Quebec,
% email address: it@cnbp.ca
% Website: http://cnbp.ca
% 2017; Last revision: 2017-08-14 22:45:37 Eastern Time

%------------- BEGIN CODE --------------

  % Read in the setting files
  Settings = LoadConfigVariables();

  % Get current path of current script.
  scriptName = mfilename('fullpath');
  [currentpath, filename, fileextension]= fileparts(scriptName);

  % Ensure dependencies are properly referred to
  addpath(currentpath);
  addpath(genpath([currentpath,'\Classification']));
  addpath(genpath([currentpath,'\Results']));
  addpath(genpath([currentpath '\Dependency_LiveLabMetrics']));
  addpath(genpath([currentpath '\Dependency_FocusMetrics']));
  addpath(genpath([currentpath '\Dependency_General']));
  addpath(genpath([currentpath '\Dependency_SNRMetrics']));
  addpath(genpath([currentpath '\Dependency_TextureMetrics']));
  addpath(genpath([currentpath '\Dependency_DICOM']));
  addpath(genpath([currentpath '\Dependency_General']));


  tic;

  % Use GUI to get path to the folder that contained all the DICOM files.
  % path = uigetdir;

  % Get output.
  Output = RecursivelyLoadDICOM(path);

  % Put everything in a gigantic matrix for further analyses.
  MetricsMatrix = cat (2, ...
    Output.FocusMetrics, ...
    Output.SNRMetrics, ...
    Output.TextureMetrics, ...
    Output.LiveLabMetrics, ...
    Output.DICOMMetrics ...
  );

  %Save EXTRA copy of the data in the final folder AS WELL as the regular output folder.
  cd(Settings.Folder.Result);
  if (exist(StudyType))
    if (StudyType == 'ASP')
      Output.Dir = Settings.Folder.ASPMetrics;
      % Enter the output folder
      mkdir (Output.Dir)
      cd (Output.Dir)
      % Save the various output
      save('MetricsDataStructure.mat','Output')
      save('MetricsMatrix.mat','MetricsMatrix')

    elseif (StudyType == 'BDP')
      Output.Dir = Settings.Folder.BDPMetrics;
      % Enter the output folder
      mkdir (Output.Dir)
      cd (Output.Dir)
      % Save the various output
      save('MetricsDataStructure.mat','Output')
      save('MetricsMatrix.mat','MetricsMatrix')
    end
  end

  %Regular saving process flow.

  %Enter Results directory, save the metrics computed.
  cd(Settings.Folder.Result);
  % Record and enter the specific directory
  Output.Dir = mkdirNowPrefix('MetricsComputation');

  % Enter the output folder
  cd (Output.Dir)
  % Save the various output
  save('MetricsDataStructure.mat','Output')
  save('MetricsMatrix.mat','MetricsMatrix')
  csvwrite('MetricsMatrix.mat',MetricsMatrix)

  % Return to root.
  cd(Settings.Folder.Root);
  disp('Step 1 Completed:')
  toc
%------------- END OF CODE --------------
end