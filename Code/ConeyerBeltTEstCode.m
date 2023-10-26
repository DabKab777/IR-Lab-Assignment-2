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

% Speed of the can in m/s
speed = 0.2;

% Time step for visualization
dt = 0.01; % You can change this to modify the smoothness of the movement

while true
    % Check if the x value of RedCan is between 1.2 and 0.8
    if RedCanPosition(1) <= 1.2 && RedCanPosition(1) >= 0.3
        % Update position of RedCan
        RedCanPosition(1) = RedCanPosition(1) - speed*dt;
        
        
        % Delete previous RedCan and draw at the new position
        delete(RedCan);
        RedCan = PlaceObject('RedCan.ply', RedCanPosition);
    end
    
    % Pause for a while before updating again
    pause(dt);
    
    % Check if the x position of RedCan is less than 0.8 to exit the loop
    if RedCanPosition(1) < 0.3
        break;
    end
end
