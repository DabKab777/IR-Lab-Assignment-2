clc;
close all;
clear all;
hold on;

% Initialize the scene
surf([-0.5,-0.5;2,2],[-1,1;-1,1],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
d = UR3; %(transl(0 , 0 , 0.5) * trotz(-90,"deg"));
% d = DobotMagician(transl(-0.7 , 0 , 0.5) * trotz(-90,"deg"));
Scene = initializeScene();

% Main processing loop
for i = 1:12 % For all cans
    % Thor picks up the can and places it behind
    ThorPickupAndPlace(Scene, i);

    % Move the cans
    % moveCans(Scene, 0.2); % move other cans closer to Thor while Dobot is working

    % Dobot picks up the can placed by Thor and deposits it based on color
    % DobotPickupAndDeposit(Scene, i);
end

function Scene = initializeScene()
    % The starting position for the first can
    startPos = [0.4 ,0, 0.55];
    
    % Initialize empty cell arrays for the cans and their positions
    Scene.Cans = cell(1,12);
    Scene.CanPositions = cell(1,12);
    
    % Colors for the cans in order
    colors = {'Red', 'Green', 'Blue'};

    % Create the cans
    for i = 1:12
        % Determine the color based on the iteration number
        color = colors{mod(i-1,3)+1}; 
        plyFile = sprintf('%sCan.ply', color); % e.g., 'RedCan.ply'

        % Set the position for the can
        Scene.CanPositions{i} = startPos + [(i-1)*0.1, 0, 0]; 

        % Place the can at the specified position
        Scene.Cans{i} = PlaceObject(plyFile, Scene.CanPositions{i});
    end
end

function ThorPickupAndPlace(Scene, canNumber)
    % Get the current joint configuration as an initial guess
    Q0 = r.model.getpos();

    % Determine the pickup position of the can
    canPickupPos = transl(Scene.CanPositions{canNumber}) * trotx(pi);
    
    % Determine the position to deposit the can behind
    canDepositPos = transl(-0.4, 0, 0.55) * trotx(pi);
    
    % Compute IK for pickup position using r.model.ikcon with initial guess Q0
    pick_q = r.model.ikcon(canPickupPos, Q0);
    
    % Move to above the can first, then move down to grip the can
    r.model.animate(pick_q);
    
    % Simulate pause (to account for any action like magnet activation)
    pause(0.5); % Wait for half a second
    
    % Compute IK for deposit position with the last joint configuration as the new initial guess
    deposit_q = r.model.ikcon(canDepositPos, pick_q);
    
    % Move to deposit the can
    r.model.animate(deposit_q);
    
    % Simulate pause (to account for any action like magnet deactivation)
    pause(0.5); % Wait for half a second
    
    % Move back to an initial/neutral position if needed
    % neutral_q = [desired joint angles];
    % r.model.animate(neutral_q);
end



function DobotPickupAndDeposit(Scene, canNumber)
    % Here, you'll need to program DobotMagician's movements.
    % It will pick up the can placed behind by Thor.
    % Then, it will deposit it at one of three locations based on the can's color.
    % This function will also depend on the DobotMagician's toolbox functionalities.
end
