clc;
close all;
clear all;

% Create the Thor robot
r = Thor( transl(1,1,1) );

hold on;

% Number of steps for the trajectory
t = 100;

for i = 1:9
    % Get current robot position
    robot_pos = r.model.getpos();

    % Generate a random joint configuration 
    random_joint_config = rand(1,5) * 2 * pi - pi;

    % Compute the joint trajectory from the current position to the random position
    qMatrix = jtraj(robot_pos, random_joint_config, t);

    % Animate the robot moving along the trajectory
    for j = 1:t
        r.model.animate(qMatrix(j,:));
        drawnow;
    end
end
