clc;
close all;
clear all;

hold on;

surf([-5,-5;4,4],[-3,3;-3,3],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
r = Thor( transl(0 , 0 , 0.5) * trotz(-90,"deg"));
table1 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [-0.6,0, 0]);
table2 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [1.35,0, 0]);
fence = PlaceObject('fenceAssemblyGreenRectangle4x8x2.5m.ply', [0,1,-1]);
FireExt = PlaceObject('fireExtinguisherElevated.ply', [-3,1.2,0.5]);
EmergencyStop = PlaceObject('emergencyStopWallMounted.ply', [1,2.14,1.5]);
InductedWorker = PlaceObject('personMaleConstruction.ply', [-3,0, 0]);
UninductedWorker = PlaceObject('personMaleCasual.ply', [-2.5,-2, 0]);

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
