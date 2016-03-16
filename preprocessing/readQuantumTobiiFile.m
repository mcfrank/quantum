function [pdata, target] = readTobiiFile (filename)

% Michael C. Frank
% 5/22/06
% mod 2/18/08 to read from .tsv from Tobii Studio
% mod 3/15/09 to read quantum files specifically

fprintf('reading data from file and converting to bETk format.\n');

delim = '\t';
header_lines = 24;

%% get actual data
format_string = '%f%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%f%f%s%f%f%f%s%s%f%f%f%f%f%s%s%s%f%s%s%f%f%f';

[Timestamp	DateTimeStamp	DateTimeStampStartOffset	Number	GazePointXLeft	...
 GazePointYLeft	CamXLeft	CamYLeft	DistanceLeft	PupilLeft	ValidityLeft	...
  GazePointXRight	GazePointYRight	CamXRight	CamYRight	DistanceRight	...
  PupilRight	ValidityRight	FixationIndex	GazePointX	GazePointY	...
  Event	EventKey	Data1	Data2	Descriptor	StimuliName	StimuliID	...
  MediaWidth	MediaHeight	MediaPosX	MediaPosY	MappedFixationPointX ...
  MappedFixationPointY	FixationDuration	AoiIds	AoiNames	WebGroupImage	...
  MappedGazeDataPointX	MappedGazeDataPointY	MicroSecondTimestamp] = ...
  textread(filename,format_string,'delimiter',delim,'emptyvalue',...
  NaN,'headerlines',header_lines);

%%
pdata.validL = ValidityLeft;
pdata.validR = ValidityRight;
pdata.t = Timestamp;
pdata.L = [GazePointXLeft GazePointYLeft];
pdata.R = [GazePointXRight GazePointYRight];

target = StimuliName;