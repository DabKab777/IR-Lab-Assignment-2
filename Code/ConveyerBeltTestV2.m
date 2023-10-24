clc;
close all;
clear all;

hold on;

surf([-0.5,-0.5;2,2],[-1,1;-1,1],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
r = Thor( transl(0 , 0 , 0.5) * trotz(-90,"deg"));


% Initial position of the RedCan
RedCanPosition = [1 ,0, 0.55];
BlueCanPosition = [1.1 ,0, 0.55];
GreenCanPosition = [1.2 ,0, 0.55];
RedCan = PlaceObject('RedCan.ply', RedCanPosition);
BlueCan = PlaceObject('BlueCan.ply', BlueCanPosition);
GreenCan = PlaceObject('GreenCan.ply', GreenCanPosition);

% Function to move cans a specified distance
function moveCans(distance)
    global RedCanPosition BlueCanPosition GreenCanPosition;
    global RedCan BlueCan GreenCan;

    % Speed of the cans in m/s
    speed = 0.2;

    % Time step for visualization
    dt = 0.01; % You can change this to modify the smoothness of the movement

    % Calculate total time required based on speed and distance
    totalTime = distance / speed;

    % Current time
    currentTime = 0;

    while currentTime < totalTime
        % Move each can by a little bit
        RedCanPosition(1) = RedCanPosition(1) - speed*dt;
        BlueCanPosition(1) = BlueCanPosition(1) - speed*dt;
        GreenCanPosition(1) = GreenCanPosition(1) - speed*dt;

        % Delete the previous cans and draw at the new positions
        delete(RedCan);
        delete(BlueCan);
        delete(GreenCan);
        RedCan = PlaceObject('RedCan.ply', RedCanPosition);
        BlueCan = PlaceObject('BlueCan.ply', BlueCanPosition);
        GreenCan = PlaceObject('GreenCan.ply', GreenCanPosition);

        pause(dt);
        currentTime = currentTime + dt;
    end
end

% Listen for command to move the cans
while true
    cmd = input('Enter command: ', 's');
    if strcmpi(cmd, 'on')
        moveCans(0.1); % Moves the cans by 0.1 meters
    end
end