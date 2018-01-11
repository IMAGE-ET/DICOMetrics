function Output = ParRecursivelyLoadDICOM(path)
%RecursivelyLoadDICOM - Main initailizer of the function to load all DICOM files.
%
% Syntax:   Output = RecursivelyLoadDICOM()
%
% Inputs:
%
% Outputs:
%    	Output			- the matrix array that contains ALL results.
%		Dimension 1: File Number
% 		Dimension 2: Algo Index
%		Dimension 3: Algo Type
%
%
% Other m-files required: 		dirrec.m; ProcessSingleDICOMInput;
% Subfunctions: 				none
% MAT-files required: 			none
%
% Author: Yang Ding
% All works sponsored by Dr. Gregory Lodygensky and the Canadian Neonatal Brain Platform
% Saint. Justine Hospital, Montreal, Quebec,
% email address: it@cnbp.ca
% Website: http://cnbp.ca
% 2017-03; Last revision: 2017-10-03 13:42:56 Eastern Time

%------------- BEGIN CODE --------------

%Null reject return.
Output = [];

tic

% The structure that will be used to contain all output.

% Read in the setting files
Settings = LoadConfigVariables();
%This is the entry function to load all things such as the following:

% % Define algorithm types:
% FileRecords 	= 1;
% FocusMetrics 	= 2;
% SNRMetrics 		= 3;
% TextureMetrics 	= 4;
% NSSMetrics 	= 5;
% % Elaborate on the specific numbers of metrics loop that are required to calculated these metrics
% NbFocusMetrics 		= 28;
% NbSNRMetrics 		= 15;
% NbTextureMetrics 	= 5;
% NbNSSMetrics 	= 2;
% NbMetrics(FileRecords)      = 1;
% NbMetrics(FocusMetrics) 	= NbFocusMetrics;
% NbMetrics(SNRMetrics) 		= NbSNRMetrics;
% NbMetrics(TextureMetrics) 	= NbTextureMetrics;
% NbMetrics(NSSMetrics) 	= NbNSSMetrics;

% Get current path of current script.
scriptName = mfilename('fullpath');
[currentpath, filename, fileextension]= fileparts(scriptName);

% Ensure dependencies are properly referred to
addpath(Settings.Folder.General);
addpath(Settings.Folder.Algos);


% Rejection criteria when the path is invalid.
if exist(path) ~= 7
	error('Path provided is not valid');
end


% Recursively obtain all files using dirrec.m
files = dirrec(path);

if isempty(files)
	error('No files found');;
end

%Preallocate Results
Results = cell(length(files),99,99);


%============
%AlgoType: 1
%============
%Record all FILES:
for fileIndex = 1:length(files)
	% Check if the file is dicom.
	if isdicom(files{fileIndex})
		Results{fileIndex, Settings.NbMetrics(Settings.IndexFileRecords),Settings.IndexFileRecords} = files{fileIndex};
	end
end


%===================
% Parallel Version of the Algo Processing: 2 to 6
%===================


% Type: 2 to 6
% Index: per type has several index.
% Store these to a matrix. Read from the matrix.



% Section for aggregate the labels into an index that can be parallel processed.
% Initialized algorithms label tracking;
labelIndex = 0;
%Loop at the algorithm TYPE level
for algoType = 2 : Settings.NbMetricTypes

	algoCount = Settings.NbMetrics(algoType);
	%Loop at per algorithm level  % Do Focus Measure
	for algoIndex = 1:algoCount
		%Record Algo Information:
		labelIndex = labelIndex+1;
		LabelAggregate{labelIndex} = AlgoIdentify(algoType,algoIndex);
		AlgoAggregate{labelIndex} = {algoType, algoIndex};
	end
end

ParResults = cell(size(AlgoAggregate,2));

% AlgoAggregate{AggregateIndex}{2} = algoIndex
%AlgoAggregate{AggregateIndex}{1} = algoType

fileCount = length(files); % This must be constant OUTSIDE parfor so inside parfor won't cause issue.

AlgoAggregateCount = size(AlgoAggregate,2);

parfor AggregateIndex = 1 : AlgoAggregateCount
	PalgoIndex = AlgoAggregate{AggregateIndex}{2};
	PalgoType = AlgoAggregate{AggregateIndex}{1};

	% v is vector recoridng results for ALL FILEs after it has been analyzed by the particular algorithm combo
	PerAggregateResults = cell(fileCount);

	%Loop at the per file level
	for fileIndex = 1:fileCount
		% At per file level, check if the file is dicom.
		if isdicom(files{fileIndex})

			%Calculate the focus metrics score
			%Result = ProcessSingleDICOMInput(files{fileIndex}, PalgoIndex, PalgoType);
			Result =  PalgoIndex * 10 + PalgoType;
			PerAggregateResults {fileIndex} = Result;

    end
    %fprintf(['File %i.\n', fileIndex, ' out of %i ', length(files), ' in Algo %i ', algoIndex, 'of AlgoType %i ', AlgoAggregate{AggregateIndex}{1}, 'finished. \n\l'])
	end
	%End Per file level loop

	%record the focus metric score
	ParResults{AggregateIndex} = PerAggregateResults;

  %Update UI:
  printcat('Algo', PalgoIndex,'/', Settings.NbMetrics(PalgoType), 'in Algorithm Type', PalgoType, '/', Settings.NbMetricTypes, 'finished.')
end

%Reconstitute the proper results format.
for AggregateIndex = 1 : size(AlgoAggregate,2)
	RalgoIndex = AlgoAggregate{AggregateIndex}{2};
	RalgoType = AlgoAggregate{AggregateIndex}{1};
	Results(:,RalgoIndex,RalgoType ) = ParResults(AggregateIndex);
end

disp('WOOHOO');
disp(size(Results));
save('SNAPSHOT_Results','Results');
save('SNAPSHOT_Result','Result');


% Update the output struct and it's relevant file structure to store the proper information.
Output.FileRecords 		     = 				  Results (:,1:Settings.NbMetrics(Settings.IndexFileRecords), Settings.IndexFileRecords 	);
Output.FocusMetrics 	     = cell2mat(Results (:,1:Settings.NbMetrics(Settings.IndexFocusMetrics), Settings.IndexFocusMetrics ));
Output.SNRMetrics 		     = cell2mat(Results (:,1:Settings.NbMetrics(Settings.IndexSNRMetrics),		Settings.IndexSNRMetrics 	));
Output.TextureMetrics      = cell2mat(Results (:,1:Settings.NbMetrics(Settings.IndexTextureMetrics),	Settings.IndexTextureMetrics));
Output.NSSMetrics      		 = cell2mat(Results (:,1:Settings.NbMetrics(Settings.IndexNSSMetrics),	Settings.IndexNSSMetrics));
Output.DICOMMetrics 	     = cell2mat(Results (:,1:Settings.NbMetrics(Settings.IndexDICOMMetrics),	Settings.IndexDICOMMetrics));

% Update the label of the outputs.
Output.LabelAggregate 	 	= LabelAggregate;

toc
%------------- END OF CODE --------------
end