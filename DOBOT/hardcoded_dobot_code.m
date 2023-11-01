%d = DobotMagician
%d.model.qlim
%d.model.getpos()

init_ros()
status = set_safety_stat() 

move_to_pos([0 0 0 0 0]) % in put joint position for home 

%%

jointStateSubscriber = rossubscriber('/dobot_magician/joint_states'); % Create a ROS Subscriber to the topic joint_states
pause(2); % Allow some time for a message to appear
currentJointState = jointStateSubscriber.LatestMessage.Position % Get the latest message


%% block 1

set_tool(0) ; % opens tool

move_to_pos( [0 deg2rad(70)  deg2rad(35)  deg2rad(74) ] % imove robot to block 1

set_tool(1) ; % closes tool

move_to_pos([0 0 0 0 deg2rad(74) ]) % move arm up 

move_to_pos([ deg2rad(90) 0 0 deg2rad(74)  ]) % rotate arm while up 

move_to_pos( [ deg2rad(90) deg2rad(70) deg2rad(35) deg2rad(74) ]) % put arm down and release block

set_tool(0) ; % opens tool

move_to_pos([ deg2rad(90) 0 0 deg2rad(74)])

move_to_pos([ 0 0 0 deg2rad(74)])


%% block 2 

move_to_pos([ deg2rad(0) 0 deg2rad(90) deg2rad(90) 0])

move_to_pos( [deg2rad(5.4) deg2rad(80)  deg2rad(35)  deg2rad(65) deg2rad(-5.1)] % imove robot to block 2

set_tool(1) ; % closes tool

move_to_pos([deg2rad(5.4) 0 deg2rad(90) deg2rad(90) deg2rad(-5.1)]) % move arm up 

move_to_pos([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0]) % rotate arm while up 

move_to_pos( [ deg2rad(90+5.4) deg2rad(80) deg2rad(35) deg2rad(65)  deg2rad(-5.4)]) % put arm down and release block

set_tool(0) ; % opens tool

pause(5)

move_to_pos([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0])



%% blok 3 
move_to_pos([ deg2rad(0) 0 deg2rad(90) deg2rad(90) 0])

move_to_pos( [deg2rad(-5.4) deg2rad(80)  deg2rad(35)  deg2rad(65) deg2rad(5.1)] % imove robot to block 2

set_tool(1) ; % closes tool

move_to_pos([deg2rad(-5.4) 0 deg2rad(90) deg2rad(90) deg2rad(5.1)]) % move arm up 

move_to_pos([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0]) % rotate arm while up 

move_to_pos( [ deg2rad(90-5.4) deg2rad(80) deg2rad(35) deg2rad(65)  deg2rad(5.4)]) % put arm down and release block

set_tool(0) ; % opens tool

pause(5)

move_to_pos([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0])

%% 
% Make sure to replace 'yourImageTopic' with the actual ROS topic name for the camera image
imageTopic = '/camera/color/image_raw';


% Subscribe to the ROS topic
sub = rossubscriber(imageTopic);

% Create a figure for displaying the image
figure;

% Loop to continuously receive and display the images
while true
    % Receive the ROS message
    imageData = receive(sub);
    
    % Convert the ROS image message to MATLAB format
    img = readImage(imageData);
    
    % Display the image
    imshow(img);
    
    % Add a small delay to control the rate of image display
    pause(0.1);
end

%%

%set_tool(1) ; % opens tool

function [] = init_ros() %fileName
rosshutdown
rosinit('192.168.27.1');
rosnode list
end 
 
function [status] = set_safety_stat()

safetyStatusSubscriber = rossubscriber('/dobot_magician/safety_status');
pause(2); %Allow some time for MATLAB to start the subscriber

[safetyStatePublisher,safetyStateMsg] = rospublisher('/dobot_magician/target_safety_status');
safetyStateMsg.Data = 4;
send(safetyStatePublisher,safetyStateMsg);
status = true; 
pause(3)

return 
end 

function [] = move_to_pos(position) % in put joint position for the robot
Qmatrix{1} = position;
jointTarget = position; % Remember that the Dobot has 4 joints by default.
safetyStatusSubscriber = rossubscriber('/dobot_magician/safety_status');
pause(2); %Allow some time for MATLAB to start the subscriber

[targetJointTrajPub,targetJointTrajMsg] = rospublisher('/dobot_magician/target_joint_states');
trajectoryPoint = rosmessage("trajectory_msgs/JointTrajectoryPoint")
trajectoryPoint.Positions = jointTarget % the position of what it needs to move to
targetJointTrajMsg.Points = trajectoryPoint;

send(targetJointTrajPub,targetJointTrajMsg);

pause(3)
end 

function[] = set_tool(state) % 0 opens gripper, 1 closes gripper
 [toolStatePub, toolStateMsg] = rospublisher('/dobot_magician/target_tool_state');
toolStateMsg.Data = [1 state];
send(toolStatePub,toolStateMsg);

pause(3)
end 

 