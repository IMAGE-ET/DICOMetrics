function [Name, Count] = AlgoSNR(Index)
% NAME - DESCRIPTION
%
% Syntax:  []] = AlgoTemplater(1,0)
%
% Inputs:
%    	TypeIndex 			- Input about the type of algorithms in general.
%    	AlgoIndex 			- Input about the algorithm in general. (if 0, return count of the typeindex)
%    	input3 			- Description
%
% Outputs:
%    	output1			- Description
%    	output2			- Description
%
% Example:
%    	Line 1 of example
%    	Line 2 of example
%    	Line 3 of example
%
% Other m-files required: 		none
% Subfunctions: 				none
% MAT-files required: 			none
%
% See also: OTHER_FUNCTION_NAME1,  OTHER_FUNCTION_NAME2

% Author: Yang Ding
% All works sponsored by Dr. Gregory Lodygensky and the Canadian Neonatal Brain Platform
% Saint. Justine Hospital, Montreal, Quebec,
% email address: it@cnbp.ca
% Website: http://cnbp.ca
% 2017; Last revision: 2017-10-03 11:49:02 Eastern Time
%TODO: better rename AJANE 1 to 4.
%TODO: add note about the default Bin Number. 

AlgoSNR{ 1} = 'AjaNE1';
AlgoSNR{ 2} = 'AjaNE2';
AlgoSNR{ 3} = 'AjaNE3';
AlgoSNR{ 4} = 'AjaNE4';
AlgoSNR{ 5} = 'Brummer';
AlgoSNR{ 6} = 'Chang';
AlgoSNR{ 7} = 'noise_M1';
AlgoSNR{ 8} = 'noise_M2';
AlgoSNR{ 9} = 'MRI_lmmse';
AlgoSNR{10} = 'MeanImage';
AlgoSNR{11} = 'MeanC50x50';
AlgoSNR{12} = 'MeanC100x100';
AlgoSNR{13} = 'LogImage';
AlgoSNR{14} = 'LogC50x50';
AlgoSNR{15} = 'LogC100x100';

%Store Count!
[column Count] = size(AlgoFocus);

%If valid index, store name as well.
if (0 < index && index < Count && isinteger(index)){
  Name = AlgoFocus{Index}
} else {
  Name = 'Invalid'
}
%------------- END OF CODE --------------
end
