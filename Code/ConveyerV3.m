clc;
close all;
clear all;
hold on;
% Initialize the scene

surf([-0.5,-0.5;2,2],[-1,1;-1,1],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
r = Thor( transl(0 , 0 , 0.5) * trotz(-90,"deg"));
d = DobotMagician( transl(-0.7 , 0 , 0.5) * trotz(-90,"deg"));
Scene = initializeScene();


% Move the cans (example)
moveCans(Scene, 0.2); % You can replace '1' with the desired distance

function Scene = initializeScene()
     
    % Initial position of the cans
    Scene.RedCanPosition = [1 ,0, 0.55];
    Scene.BlueCanPosition = [1.1 ,0, 0.55];
    Scene.GreenCanPosition = [1.2 ,0, 0.55];

    Scene.RedCan = PlaceObject('RedCan.ply', Scene.RedCanPosition);
    Scene.BlueCan = PlaceObject('BlueCan.ply', Scene.BlueCanPosition);
    Scene.GreenCan = PlaceObject('GreenCan.ply', Scene.GreenCanPosition);
end

function moveCans(Scene, distance)
    speed = 0.2;
    dt = 0.01;
    totalTime = distance / speed;
    currentTime = 0;

    while currentTime < totalTime
        % Move each can by a little bit
        Scene.RedCanPosition(1) = Scene.RedCanPosition(1) - speed*dt;
        Scene.BlueCanPosition(1) = Scene.BlueCanPosition(1) - speed*dt;
        Scene.GreenCanPosition(1) = Scene.GreenCanPosition(1) - speed*dt;

        % Delete the previous cans and draw at the new positions
        delete(Scene.RedCan);
        delete(Scene.BlueCan);
        delete(Scene.GreenCan);

        Scene.RedCan = PlaceObject('RedCan.ply', Scene.RedCanPosition);
        Scene.BlueCan = PlaceObject('BlueCan.ply', Scene.BlueCanPosition);
        Scene.GreenCan = PlaceObject('GreenCan.ply', Scene.GreenCanPosition);

        pause(dt);
        currentTime = currentTime + dt;
    end
end
