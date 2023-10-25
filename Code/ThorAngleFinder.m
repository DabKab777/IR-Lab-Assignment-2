clc;
close all;
clear all;
hold on;

% Initialize the scene
surf([-0.5,-0.5;2,2],[-1,1;-1,1],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
r = Thor(transl(0 , 0 , 0.5) * trotz(-90,"deg"));
r.model.teach();
% d = DobotMagician(transl(-0.7 , 0 , 0.5) * trotz(-90,"deg"));
Scene = initializeScene();

% Main processing loop
for i = 1:12 % For all cans
    % Thor picks up the can and places it behind
    % VARRR = r.model.getpos();
    % disp(VARRR);
    % ThorPickupAndPlace(r, Scene, i);

    % Move the cans
    % moveCans(Scene, 0.2); % move other cans closer to Thor while Dobot is working

    % Dobot picks up the can placed by Thor and deposits it based on color
    % DobotPickupAndDeposit(Scene, i);
end

function Scene = initializeScene()
    % The starting position for the first can
    startPos = [0.3 ,0, 0.55];
    
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

function ThorPickupAndPlace(r, Scene, canNumber)
    % Get the current joint configuration as an initial guess
    Q0 = r.model.getpos();
    Q1 = deg2rad([90, 22, -147, 0, 36]);
    % disp(Q0);

    % Determine the pickup position of the can
    canPickupPos = transl(0.3 ,0, 0.55);
    % disp(canPickupPos);

    % Determine the position to deposit the can behind
    canDepositPos = transl(-0.3, 0, 0.55);
    % disp(canDepositPos);

    % Compute IK for pickup position using r.model.ikcon with initial guess Q0
    pick_q = r.model.ikcon(canPickupPos, Q1);
    
    % Compute IK for deposit position with the last joint configuration as the new initial guess
    deposit_q = r.model.ikcon(canDepositPos);
    
    % Number of trajectory points
    t = 200;
    
    % Calculate the trajectories from current position to pickup and from pickup to deposit
    qMatrix_pick = jtraj(Q0, pick_q, t);
    qMatrix_deposit = jtraj(pick_q, deposit_q, t);

    % Animate the robot moving to pick up the can
    for j = 1:t
        r.model.animate(qMatrix_pick(j,:));
        drawnow;
        pause(0.05);
    end
    
    % Simulate pause (to account for any action like magnet activation)
    pause(1);
    
    % Animate the robot moving to deposit the can
    for j = 1:t
        r.model.animate(qMatrix_deposit(j,:));
        drawnow;
        pause(0.05);
    end
    
    % Simulate pause (to account for any action like magnet deactivation)
    pause(1);
end



function DobotPickupAndDeposit(Scene, canNumber)
    % Here, you'll need to program DobotMagician's movements.
    % It will pick up the can placed behind by Thor.
    % Then, it will deposit it at one of three locations based on the can's color.
    % This function will also depend on the DobotMagician's toolbox functionalities.
end
