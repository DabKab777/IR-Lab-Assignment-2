clc;
close all;
clear all;
hold on;

% Initialize the scene
surf([-0.5,-0.5;2,2],[-1,1;-1,1],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
r = Thor(transl(0 , 0 , 0.5) * trotz(-90,"deg"));
% d = DobotMagician(transl(-0.7 , 0 , 0.5) * trotz(-90,"deg"));
Scene = initializeScene();

% Main processing loop
for i = 1:9 % For all cans
    % Thor picks up the can and places it behind
    % VARRR = r.model.getpos();
    % disp(VARRR);
    ThorPickupAndPlace(r, Scene, i);

    % Move the cans
    % moveCans(Scene, 0.2); % move other cans closer to Thor while Dobot is working

    % Dobot picks up the can placed by Thor and deposits it based on color
    % DobotPickupAndDeposit(Scene, i);
end

function Scene = initializeScene()
    % The starting position for the first can
    startPos = [0.27 ,0, 0.55];
    
    % Initialize empty cell arrays for the cans and their positions
    Scene.Cans = cell(1,9);
    Scene.CanPositions = cell(1,9);
    
    % Colors for the cans in order
    colors = {'Red', 'Green', 'Blue'};

    % Create the cans
    for i = 1:9
        % Determine the color based on the iteration number
        color = colors{mod(i-1,3)+1}; 
        plyFile = sprintf('%sCan.ply', color); % e.g., 'RedCan.ply'

        % Set the position for the can
        Scene.CanPositions{i} = startPos + [(i-1)*0.15, 0, 0]; 

        % Place the can at the specified position
        Scene.Cans{i} = PlaceObject(plyFile, Scene.CanPositions{i});
    end
end

function ThorPickupAndPlace(r, Scene, canNumber)
    % Get the current joint configuration as an initial guess
    Q0 = r.model.getpos();
    Q1 = deg2rad([90, 73.2, -171, 0, 0]);
    Q2 = deg2rad([-90, 73.2, -171, 0, 0]);

    % Sequence of positions for Thor's movements based on your cycle
    positions = {
        transl(0.25 ,0, 0.85) * trotx(pi),  % Above can
        transl(0.27 ,0, 0.75) * trotx(pi),  % Down to can
        transl(0.25 ,0, 0.85) * trotx(pi),  % Lift up from can
        transl(-0.25, 0, 0.8) * troty(pi),  % Above deposit
        transl(-0.28, 0, 0.7) * troty(pi),  % Go to deposit
        transl(-0.25, 0, 0.8) * troty(pi)   % Move up from deposit
    };
    
    % Initial guesses for each movement
    initial_guesses = {Q1, Q1, Q1, Q2, Q2, Q2};

    % Number of trajectory points
    t = 50;

    % Start with the robot's current position
    start_q = Q0;

    % Iterate through each position in the sequence
    for i = 1:length(positions)
        % Compute IK for the position with the respective initial guess
        end_q = r.model.ikcon(positions{i}, initial_guesses{i});

        % Calculate the trajectories from current position to the next position
        qMatrix = jtraj(start_q, end_q, t);

        % Animate the robot moving to the position
        for j = 1:t
            r.model.animate(qMatrix(j,:));
            drawnow;
            pause(0.05);
        end

        % Simulate a pause (e.g., for actions like magnet activation or deactivation)
        pause(0.5);
        
        % Update the start position for the next movement
        start_q = end_q;
    end
end





function DobotPickupAndDeposit(Scene, canNumber)
    % Here, you'll need to program DobotMagician's movements.
    % It will pick up the can placed behind by Thor.
    % Then, it will deposit it at one of three locations based on the can's color.
    % This function will also depend on the DobotMagician's toolbox functionalities.
end
