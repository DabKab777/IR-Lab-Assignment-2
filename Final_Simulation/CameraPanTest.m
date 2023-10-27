clc;
close all;
clear all;
hold on;

% Initialize the scene
surf([-5,-5;4,4],[-3,3;-3,3],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [0.9, 0, 0.5]);
r = Thor(transl(0 , 0 , 0.5) * trotz(-90,"deg"));
d = DobotMagician(transl(-0.55 , 0 , 0.5) * trotz(-90,"deg"));
table1 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [-0.6,0, 0]);
table2 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [1.35,0, 0]);
fence = PlaceObject('fenceAssemblyGreenRectangle4x8x2.5m.ply', [0,1,-1]);
FireExt = PlaceObject('fireExtinguisherElevated.ply', [-3,1.2,0.5]);
EmergencyStop = PlaceObject('emergencyStopWallMounted.ply', [1,2.14,1.5]);
InductedWorker = PlaceObject('personMaleConstruction.ply', [-3,0, 0]);
UninductedWorker = PlaceObject('personMaleCasual.ply', [-2.5,-2, 0]);
Scene = initializeScene();
ax = gca; % Get current axis handle
% Pan the camera
startView = [60, 30]; % Starting azimuth and elevation [az, el]
endView = [-60, 30]; % Ending azimuth and elevation
v = VideoWriter('pannedScene2.avi');
open(v);

panCamera(ax, startView, endView, 250, v); % 250 steps for the transition
close(v);


% d.model.teach();
% Main processing loop
for i = 1:9 % For all cans
    % ThorPickupAndPlace(r, Scene, i);

    % Dobot picks up the can placed by Thor and deposits it based on color
    % DobotPickupAndDeposit(d, Scene, i);

    % Move the cans
    % moveCans(Scene, 0.15, i); % move other cans closer to Thor while Dobot is working
end

function Scene = initializeScene()
    % The starting position for the first can
    startPos = [0.27 ,0, 0.55];
    
    % Initialize empty cell arrays for the cans and their positions
    Scene.Cans = cell(1,9);
    Scene.CanPositions = cell(1,9);
    Scene.CanVertices = cell(1,9);
    
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
        transl(-0.29, 0, 0.7) * troty(pi),  % Go to deposit
        transl(-0.25, 0, 0.8) * troty(pi),   % Move up from deposit
        transl(0.25 ,0, 0.9) * trotx(pi)
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
                trVerts = [Scene.CanVertices{canNumber},ones(size(Scene.CanVertices{canNumber},1),1)] * (T.T * transl(-0.5,0,0.27) * troty(pi/2))';
                % set(Scene.CanVertices{canNumber},'Vertices',trVerts(:,1:3));
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
    end
end

function DobotPickupAndDeposit(d, Scene, canNumber)

    % Get the current joint configuration as an initial guess
    Q0 = d.model.getpos();
    Q1 = deg2rad([90, 73.2, -171, 0, 0]);
    Q2 = deg2rad([-90, 73.2, -171, 0, 0]);

    % Sequence of positions for Thor's movements based on your cycle
    positions = {
        transl(-0.25, 0, 0.75) * trotz(pi),   % Above Pickup
        transl(-0.29, 0, 0.7) * trotz(pi),   % Go to Pickup
        transl(-0.25, 0, 0.75) * trotz(pi),   % Move up from pickup
        transl(-0.9 , 0, 0.75),   % Move to Deposit 
        transl(-0.9 , 0, 0.7),   % Move Down to deposit
        transl(-0.9 , 0, 0.75)    % move to above deposit
    };
    
    % Initial guesses for each movement
    initial_guesses = {Q1, Q1, Q1, Q2, Q2, Q2};

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
                trVerts = [Scene.CanVertices{canNumber},ones(size(Scene.CanVertices{canNumber},1),1)] * (T.T * transl(-0.27,0,-0.75) )';
                % set(Scene.CanVertices{canNumber},'Vertices',trVerts(:,1:3));
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

function moveCans(Scene, distance, canNumber)
    speed = 0.5;
    dt = 0.01;
    totalTime = distance / speed;
    currentTime = 0;
    
    while currentTime < totalTime
        % Move each can by a little bit, except the can being moved by the robot
        for i = 1:length(Scene.CanPositions)
            if i ~= canNumber  % Skip the can being picked up
                % Store old position
                oldPosition = Scene.CanPositions{i};
                
                % Update the position
                Scene.CanPositions{i}(1) = Scene.CanPositions{i}(1) - speed*dt;
                
                % Delete the can at the old position
                delete(Scene.CanObjects{i});
                
                % Draw the can at the new position
                color = mod(i-1,3)+1;
                switch color
                    case 1
                        plyFile = 'RedCan.ply';
                    case 2
                        plyFile = 'GreenCan.ply';
                    case 3
                        plyFile = 'BlueCan.ply';
                end
                Scene.CanObjects{i} = PlaceObject(plyFile, Scene.CanPositions{i});
            end
        end

        pause(dt);
        currentTime = currentTime + dt;
    end
end

function panCamera(ax, startView, endView, steps, v)
    % ax: axis handle, startView: [azimuth, elevation] of start view,
    % endView: [azimuth, elevation] of end view, steps: number of steps for transition

    azRange = linspace(startView(1), endView(1), steps);
    elRange = linspace(startView(2), endView(2), steps);
    
    for i = 1:steps
        view(ax, azRange(i), elRange(i));
        drawnow;
        frame = getframe(gcf);
        writeVideo(v, frame);

        pause(0.02); % Adjust this for speed
    end
end
