clc;
close all;
clear all;
hold on;
%Helo

% Initialize the scene
surf([-1,-1;2.5,2.5],[-1,1;-1,1],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [0.9, 0, 0.5]);
r = Thor(transl(0 , 0 , 0.5) * trotz(-90,"deg"));
d = DobotMagician(transl(-0.55 , 0 , 0.5) * trotz(-90,"deg"));
table1 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [0.4,0, 0]);
table2 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [1.35,0, 0]);
% fence = PlaceObject('fenceAssemblyGreenRectangle4x8x2.5m.ply', [0,1,-1]);
% FireExt = PlaceObject('fireExtinguisherElevated.ply', [-3,1.2,0.5]);
% EmergencyStop = PlaceObject('emergencyStopWallMounted.ply', [1,2.14,1.5]);
% InductedWorker = PlaceObject('personMaleConstruction.ply', [-3,0, 0]);
% UninductedWorker = PlaceObject('personMaleCasual.ply', [-2.5,-2, 0]);

Redbin = PlaceObject('RedBin.ply', [-0.8, 0.18, 0.45]);
Bluebin = PlaceObject('BlueBin.ply', [-0.8, 0, 0.45]);
Greenbin = PlaceObject('GreenBin.ply', [-0.8, -0.18, 0.45]);

Scene = initializeScene();
% Main processing loop
for i = 1:9 % For all cans
    Scene = ThorPickupAndPlace(r, Scene, i);

    % Dobot picks up the can placed by Thor and deposits it based on color
    Scene = DobotPickupAndDeposit(d, Scene, i);
    
    Scene = cans_falling(Scene, i);

    % Move the cans
    Scene = moveCans(Scene, 0.15, i); % move other cans closer to Thor while Dobot is working

    % Scene = cans_falling(Scene, i);
end

function Scene = initializeScene()
    % The starting position for the first can
    startPos = [0.27 ,0, 0.55];
    
    % Initialize empty cell arrays for the cans and their positions
    Scene.Cans = cell(1,9);
    Scene.CanPositions = cell(1,9);
    Scene.CanVertices = cell(1,9);
    Scene.MovedByThor = cell(1,9); % 0 means not moved by Thor, 1 means moved


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

        % Scene.CanVertices{i} = get(Scene.Cans{i}, 'Vertices');
        Scene.CanObjects{i} = Scene.Cans{i}; % Store the handle to the graphic object
        Scene.CanVertices{i} = get(Scene.Cans{i}, 'Vertices'); % If you still need to store vertices separately
        Scene.MovedByThor{i} = 0;

    end
end

function Scene = ThorPickupAndPlace(r, Scene, canNumber)
    % Get the current joint configuration as an initial guess
    Q0 = r.model.getpos();
    Q1 = deg2rad([90, 73.2, -171, 0, 0]);
    Q2 = deg2rad([-90, 73.2, -171, 0, 0]);

    canPosition = Scene.CanPositions{canNumber};
    positions = {
    transl(canPosition(1) - 0.02, 0, 0.85) * trotx(pi),  % Above can
    transl(canPosition(1), 0, 0.75) * trotx(pi),        % Down to can
    transl(canPosition(1) - 0.02, 0, 0.85) * trotx(pi),  % Lift up from can
    transl(-0.25, 0, 0.8) * troty(pi),                  % Above deposit
    transl(-0.29, 0, 0.7) * troty(pi),                  % Go to deposit
    transl(-0.25, 0, 0.8) * troty(pi),                  % Move up from deposit
    transl(canPosition(1) - 0.02, 0, 0.9) * trotx(pi)
};
    
    % Initial guesses for each movement
    initial_guesses = {Q1, Q1, Q1, Q2, Q2, Q2, Q1};

    % Number of trajectory points
    t = 15;

    % Start with the robot's current position
    start_q = Q0;

    % Variable to allow for a single call of moving cans
    CansMovingAlready = 0;
    

    % Iterate through each position in the sequence
    for i = 1:length(positions)
        % Compute IK for the position with the respective initial guess
        end_q = r.model.ikcon(positions{i}, initial_guesses{i});

        % Calculate the trajectories from current position to the next position
        qMatrix = jtraj(start_q, end_q, t);

        % Animate the robot moving to the position
        if i == 1 || i == 2 || i == 6 || i == 7
            for j = 1:t
                r.model.animate(qMatrix(j,:));
                drawnow;
                pause(0.05);
            end
            
        else        
            for j = 1:t
                r.model.animate(qMatrix(j,:));
                CurrentPos = r.model.getpos;
                T = r.model.fkine(CurrentPos);

                zOffsetIncrement = 0.15;
                zBaseOffset = 0.27; % This is your initial z-offset
                adjustedZOffset = zBaseOffset + (canNumber - 1) * zOffsetIncrement;
                trVerts = [Scene.CanVertices{canNumber}, ones(size(Scene.CanVertices{canNumber}, 1), 1)] * (T.T * transl(-0.5, 0, adjustedZOffset) * troty(pi/2))';

                set(Scene.CanObjects{canNumber},'Vertices',trVerts(:,1:3));
                drawnow;
                pause(0.05);
            end 
            
        end
      
        % Simulate a pause (e.g., for actions like magnet activation or deactivation)
        pause(0.5);
        CansMovingAlready = 0;
        
        % Update the start position for the next movement
        start_q = end_q;
         % After the robot places the can
        Scene.MovedByThor{canNumber} = 1;
    end
end

function Scene = moveCans(Scene, distance, canNumber)
    speed = 0.5;
    dt = 0.01;
    totalTime = distance / speed;
    currentTime = 0;

    while currentTime < totalTime
        % Move each can by a little bit, except the can being moved by the robot
        for i = 1:length(Scene.CanPositions)
            % Check if the can has been moved by Thor
            if Scene.MovedByThor{i} == 0 && i ~= canNumber 
                 % Debugging print statement
                fprintf('Moving can %d\n', i);
                % Update the position
                Scene.CanPositions{i}(1) = Scene.CanPositions{i}(1) - speed*dt;

                % Get the current can object vertices
                canVertices = get(Scene.CanObjects{i}, 'Vertices');

                % Translate the vertices
                trVerts = canVertices - repmat([speed*dt, 0, 0], size(canVertices, 1), 1);

                % Update the can's position in the scene using the translated vertices
                set(Scene.CanObjects{i}, 'Vertices', trVerts);
            else

                fprintf('NOT moving can %d. MovedByThor status: %d\n', i, Scene.MovedByThor{i});

            end

        end

        pause(dt);
        currentTime = currentTime + dt;
    end
end


function Scene = DobotPickupAndDeposit(d, Scene, canNumber)

    % % Get the current joint configuration as an initial guess
    % Q0 = d.model.getpos();
    % Q1 = deg2rad([90, 73.2, -171, 0, 0]);
    % Q2 = deg2rad([-90, 73.2, -171, 0, 0]);
    % 
    % % Sequence of positions for Thor's movements based on your cycle
    % positions = {
    %     transl(-0.25, 0, 0.75) * trotz(pi),   % Above Pickup
    %     transl(-0.29, 0, 0.7) * trotz(pi),   % Go to Pickup
    %     transl(-0.25, 0, 0.75) * trotz(pi),   % Move up from pickup
    %     transl(-0.9 , 0, 0.75),   % Move to Deposit 
    %     transl(-0.9 , 0, 0.7),   % Move Down to deposit
    %     transl(-0.9 , 0, 0.75)    % move to above deposit
    % };
    
        % Get the current joint configuration as an initial guess
    Q0 = d.model.getpos();
    Q1 = deg2rad([90, 73.2, -171, 0, 0]);
    Q2 = deg2rad([-90, 73.2, -171, 0, 0]);
    
    % Get the color of the can for deposition decision
    color = mod(canNumber-1, 3) + 1; % 1 for Red, 2 for Green, 3 for Blue

    % Define deposit locations based on the can's color
    if color == 1 % Red
        depositLocation = transl(-0.8, 0.18, 0.7);
    elseif color == 2 % Green
        depositLocation = transl(-0.8, -0.18, 0.7);
    else % Blue
        depositLocation = transl(-0.8, 0, 0.7);
    end

    % Sequence of positions for Dobot's movements
    positions = {
        transl(-0.25, 0, 0.75) * trotz(pi),   % Above Pickup
        transl(-0.29, 0, 0.7) * trotz(pi),   % Go to Pickup
        transl(-0.25, 0, 0.75) * trotz(pi),   % Move up from pickup
        depositLocation * transl(0, 0, 0.05),   % Move to above Deposit
        depositLocation   % Move Down to deposit
        % depositLocation * transl(0, 0, 0.05)    % Move up from deposit
    };
    
    % Initial guesses for each movement
    initial_guesses = {Q1, Q1, Q1, Q2, Q2};

    % Number of trajectory points
    t = 15;

    % Start with the robot's current position
    start_q = Q0;
    

    % Iterate through each position in the sequence
    for i = 1:length(positions)
        % Compute IK for the position with the respective initial guess
        end_q = d.model.ikcon(positions{i}, initial_guesses{i});

        % Calculate the trajectories from current position to the next position
        qMatrix = jtraj(start_q, end_q, t);

        % Animate the robot moving to the position
        if i == 1 || i == 2 || i == 6
            for j = 1:t
                d.model.animate(qMatrix(j,:));
                drawnow;
                pause(0.05);
            end
            
        else        
            for j = 1:t
                d.model.animate(qMatrix(j,:));
                CurrentPos = d.model.getpos;
                T = d.model.fkine(CurrentPos);

                xOffsetIncrement = -0.15;
                xBaseOffset = -0.27; % This is your initial x-offset
                adjustedXOffset = xBaseOffset + (canNumber - 1) * xOffsetIncrement;
                trVerts = [Scene.CanVertices{canNumber}, ones(size(Scene.CanVertices{canNumber}, 1), 1)] * (T.T * transl(adjustedXOffset, 0, -0.75))';

                set(Scene.CanObjects{canNumber},'Vertices',trVerts(:,1:3));
                drawnow;
                pause(0.05);
            end 
            
        end
      
        % Simulate a pause (e.g., for actions like magnet activation or deactivation)
        pause(0.5);
        
        % Update the start position for the next movement
        start_q = end_q;
    end

end


function Scene = cans_falling(Scene, canNumber)
    speed = 0.9;      % Speed at which the can falls
    dt = 0.01;        % Time step for simulation
    distance = -0.5;  % The can will fall by 0.5 units in the Z direction
    totalTime = abs(distance) / speed;  % Total time taken to fall the given distance
    currentTime = 0;

    if Scene.MovedByThor{canNumber} == 1
        while currentTime < totalTime
            % Debugging print statement
            % fprintf('Falling can %d\n', canNumber);
            % Update the position
            Scene.CanPositions{canNumber}(3) = Scene.CanPositions{canNumber}(3) - speed*dt;

            % Get the current can object vertices
            canVertices = get(Scene.CanObjects{canNumber}, 'Vertices');

            % Translate the vertices in the Z direction
            trVerts = canVertices - repmat([0, 0, speed*dt], size(canVertices, 1), 1);

            % Update the can's position in the scene using the translated vertices
            set(Scene.CanObjects{canNumber}, 'Vertices', trVerts);
            
            pause(dt);
            currentTime = currentTime + dt;
        end
        % After the can has fallen, set its status to 2
        Scene.MovedByThor{canNumber} = 2;
    else
        % fprintf('NOT falling can %d. MovedByThor status: %d\n', canNumber, Scene.MovedByThor{canNumber});
    end
end
