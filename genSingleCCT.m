function [CCT,varargout] = ...
    genSingleCCT(XTrain,YTrain,bReg,options,XTest,iFeatureNum,bOrdinal)
%genSingleCCT Generate a single canonical correlation tree
%
% CCT = genSingleCCT(XTrain,YTrain)
%
% Creates a single canonical correlation tree (CCT) which use splits based
% on a CCA analysis between the input data and labels.
%
% Required Inputs:
%         XTrain = Array giving training features.  Each row should be a
%                  seperate data point and each column a seperate feature.
%                  Must be numerical array with missing values marked as
%                  NaN if iFeatureNum is provided, otherwise can be any
%                  format accepted by processInputData function
%         YTrain = Class data.  Three formats are accepted: a binary
%                  represenetation where each row is a seperate data point
%                  and contains only a single non zero term the column of
%                  which indicates the class, a numeric vector with unique
%                  values taken as seperate class labels or a cell array of
%                  strings giving the name.
%
% Advanced usage:
%
% [CCT,forestPredictsTest,forestProbsTest] = ...
%    genSingleCCT(XTrain,YTrain,bReg,options,XTest,iFeatureNum,bOrdinal)
%
% Options Inputs:
%           bReg = Whether to perform regression instead of classification.
%                  Default = false (i.e. classification).
%        options = Options object created by optionsClassCCF.  If left
%                  blank then a default set of options corresponding to the
%                  method detailed in the paper is used.
%          XTest = Test data to make predictions for.  If the input
%                  features for the test data are known at test time then
%                  using this input with the option bKeepTrees = false can
%                  significantly reduce the memory requirement.
%    iFeatureNum = Vector for grouping of categorical variables as
%                  generated by processInputData function.  If left blank
%                  then the data is processed using processInputData.
%       bOrdinal = If the data is to be processed, this allows
%                  specification of ordinal variables.  For default
%                  behaviour see processInputData.m
%
% Outputs:
%            CCT = Single canonical correlation tree
%   predictsTest = Tree predictions for XTest
%      probsTest = Tree probabilities for XTest
%       treePred = Individual tree predictiosn for XTest
%     cumForPred = Predictions of forest for XTest cumulative in the
%                  individual trees.  cumForPred(:,end)==forPred
%
% Tom Rainforth 09/10/15

if ~exist('bReg','var')
    bReg = [];
end

if ~exist('XTest','var')
    XTest = [];
end

if ~exist('options','var')
    options = optionsClassCCF.defaultOptionsForSingleCCTUsage;
end

if ~exist('iFeatureNum','var')
    iFeatureNum = [];
end

if ~exist('bOrdinal','var')
    bOrdinal = [];
end

options.bUseParallel = false;

% Strange naming it to avoid wasting space by storing two instances
[CCT,varargout{1:nargout}] = deal(genCCF(1,XTrain,YTrain,bReg,options,XTest,true,iFeatureNum,bOrdinal));

% This is a bit weird to avoid duplicating the tree for reduced memory
other_outs = rmfield(CCT,'Trees');
CCT = CCT.Trees{1};
other_fields = fields(other_outs);
for n=1:numel(other_fields)
    CCT.(other_fields{n}) = other_outs.(other_fields{n});
end

end
