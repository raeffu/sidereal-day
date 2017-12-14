function siderealday() 
    clear all; close all; clc; %clear matrices, close figures & clear cmd wnd.

    files = dir('./new-star-images/selection/*.jpg');
%     files = dir('./star-images/*.jpg');
    files = files(~ismember({files.name}, {'.', '..'}));
    
    % Start with first image
    prev = files(1);
    
    % Load, convert to grayscale and binarize
    gray = rgb2gray(imread(sprintf('%s/%s', prev.folder, prev.name)));
    gauss_prev = imgaussfilt(gray, 4);
    previous = imbinarize(gauss_prev, 'adaptive');
    imshow(previous);
    pause(1);
    
    numFiles = 7; % the first 8 pictures return good results with SURF
    
    % Initialize angles vector
    angles = 0:0:numFiles;

    for i = 2:numFiles
        % Print progress
        sprintf('%3.2f%%\n', ((i-1)/numFiles)*100)

        file = files(i);
        filename = sprintf('%s/%s', file.folder, file.name);
        
        % Load, convert to grayscale and binarize
        gray = rgb2gray(imread(filename));
        gauss_current = imgaussfilt(gray, 4);
        current = imbinarize(gauss_current, 'adaptive');
        figure;
        imshow(current);
        pause(1);

        % Find rotation
        angles(i-1) = imrotatefind(previous, current);

%         previous = current;
    end

%     curve = cumsum(angles);
    curve = angles;
    
    timeStep = 10; % time between image capture in minutes
    timeElapsed = timeStep * (numFiles-1);
    time = 0:timeStep:((numFiles - 2) * timeStep);
    sprintf('Time elapsed: %d min', timeElapsed)
    
    angularVelocity = ((curve(numFiles-1)/360) * 2 * pi) / (timeElapsed*60);
    actualAngularVelocity = 7.2921e-05;
    sprintf('Angular velocity: %d rad/s', angularVelocity)
    sprintf('Actual angular velocity: %d rad/s', actualAngularVelocity)
    relativeErrorVelocity = abs(actualAngularVelocity - angularVelocity) / actualAngularVelocity;
    sprintf('Relative error angular velocity: %d%%', relativeErrorVelocity)
    
    P = polyfit(time, curve, 1);
    
    f = polyval(P,time);
    plot(time,curve,'-o',time,f,'-')
    legend('data','linear fit');
    pause(1);
    
    minutesPerDay = 360/P(1);
    sprintf('Minutes per day: %d', minutesPerDay)
    secondsPerDay = minutesPerDay * 60;
    sprintf('Seconds per day: %d', secondsPerDay)

    siderealDaySeconds = 86164.099;
    sprintf('# Seconds Sidereal Day: %d', siderealDaySeconds)

    diff = abs(secondsPerDay - siderealDaySeconds);
    sprintf('Diff: %3.2f seconds', diff)
    sprintf('Diff: %3.2f minutes', diff/60)
    relativeError = diff / siderealDaySeconds;
    sprintf('Relative error: %3.3f%%', relativeError * 100)

end