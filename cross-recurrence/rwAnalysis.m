clear all;

load /groups/saxelab/QUANTUM/analysis/processed_data/quantum_data_all.mat;
reorderBabies;

info = sub_info{1};
threshold = 100;
eta = 10; % this is a timestep threshold.  i have no idea what the units are.

% we want to plot age versus average rw value. we'll divide age into
% nDaysPerAgeBucket day increments.
nDaysPerAgeBucket = 15;
% the oldest age we expect to see, in days
oldestAgeDays = 480;

% we look at babies 1 through n. set n to length(babies) to do the full
% analysis; this will take a long time.
n = 5;
nDataPoints = (n.*n - n) ./ 2;
ageDiffs = zeros(nDataPoints, 1);
rws = zeros(nDataPoints, 1);
rwsByBaby = zeros(n, n);

nBuckets = int32(oldestAgeDays ./ nDaysPerAgeBucket)+1;
ageIndices = zeros(nBuckets, n);
nextOpenColumn = ones(nBuckets, 1);

dp = 1;
for a = 1:n
    bucket = int32(baby_info(a).age ./ nDaysPerAgeBucket);
    index = nextOpenColumn(bucket,1);
    ageIndices(bucket, index) = a;
    nextOpenColumn(bucket,1) = index + 1;
    ageIndices(bucket, :)
    for b = (a+1):n
        cond = 1; % Faces_Pure
        inst = 1; % I don't know what this means
        tic
        [rr rw] = eucrp(babies{a}{cond}{inst}, babies{b}{cond}{inst}, ...
            info, threshold, eta);
        toc
        ageDiffs(dp,1) = abs(baby_info(a).age - baby_info(b).age);
        rws(dp, 1) = rw;
        rwsByBaby(a,b) = rw;
        dp = dp + 1;
    end
end

% % save rws, rwsByBaby, ageDiffs
% save('rw_analysis_data', 'rws', 'rwsByBaby', 'ageIndices');

% meanRWs = zeros(nBuckets, 1);
% for b = 1:nBuckets
%     bucket = b
%     row = ageIndices(b, :)
%     % figure out the largest index in the row that corresponds to
%     % a valid baby number
%     maxRowIndex = 0;
%     for i = 1:n
%         if ageIndices(b, i) > 0
%             maxRowIndex = i
%         else
%             break
%         end
%     end
% 
%     % add up all the rw values for pairs of babies in that bucket
%     sum = 0;
%     for baby1 = 1:maxRowIndex
%         for baby2 = (baby1+1):maxRowIndex
%             rw = rwsByBaby(baby1,baby2);
%             sum = sum + rw;
%         end
%     end
%     
%     % the max row index in the row is the number of babies with that age
%     % bucket, so this is the average
%     meanRWs(b, 1) = sum ./ maxRowIndex;
% end
% 
diffs = ageDiffs(:, 1);
dubs = rws(:, 1);
plot(diffs, dubs, 'bd'); 
xlabel('age difference');
ylabel('RW value');
hold on
% plot(1:nBuckets, meanRWs(:, 1), 'rd');
% xlabel('age in days / 15');
% ylabel('mean pairwise RW value');
% hold on
