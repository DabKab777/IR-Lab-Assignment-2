
init_ros()
status = set_safety_stat() 

set_tool(0) ; % opens tool
move_to_joint_states([ deg2rad(0) 0 deg2rad(0) deg2rad(0) 0]) % rotate arm while up 
pause(2)

pos = set_end_effector_pos()
%%
move_to_end_effector(pos)
%%
pause(2)


%{
%% block 1

move_to_joint_states( [0.0037    0.0174   -0.0292    1.2915 ]) %resetr

set_tool(0) ; % opens tool

move_to_joint_states( [ 0.0166    0.8326    0.8978    1.2915]) % imove robot to block 1


set_tool(1) ; % closes tool

move_to_joint_states( [0.0037    0.0174   -0.0292    1.2915 ]) % move arm up 

move_to_joint_states( [ 1.4604    0.3815    0.0690    1.2915 ])

move_to_joint_states( [ 1.3837    0.8824    0.9380    1.2915 ])

pause(2)

set_tool(0);

move_to_joint_states( [1.3246    0.3950    0.0458    1.2915 ])

move_to_joint_states( [ -0.0984    0.3661    0.0139    1.2915])

set_tool(0)
%%
move_to_joint_states( [0.0037    0.0174   -0.0292    1.2915 ]) %resetr

set_tool(0) ; % opens tool

move_to_joint_states( [ -0.3266    0.6997    1.1059    1.2915]) % imove robot to block 1


set_tool(1) ; % closes tool

move_to_joint_states( [ ]) % move arm up 

move_to_joint_states( [ 1.4604    0.3815    0.0690    1.2915 ])

move_to_joint_states( [ 1.3837    0.8824    0.9380    1.2915 ])

pause(2)

set_tool(0)

move_to_joint_states( [1.3246    0.3950    0.0458    1.2915 ])

move_to_joint_states( [ -0.0984    0.3661    0.0139    1.2915])

set_tool(0)

%% block 2 

move_to_joint_states([ deg2rad(0) 0 deg2rad(90) deg2rad(90) 0])

move_to_joint_states( [deg2rad(5.4) deg2rad(80)  deg2rad(35)  deg2rad(65) deg2rad(-5.1)]) % imove robot to block 2

set_tool(1) ; % closes tool

move_to_joint_states([deg2rad(5.4) 0 deg2rad(90) deg2rad(90) deg2rad(-5.1)]) % move arm up 

move_to_joint_states([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0]) % rotate arm while up 

move_to_joint_states( [ deg2rad(90+5.4) deg2rad(80) deg2rad(35) deg2rad(65)  deg2rad(-5.4)]) % put arm down and release block

set_tool(0) ; % opens tool

pause(5)

move_to_joint_states([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0])



%% blok 3 
move_to_joint_states([ deg2rad(0) 0 deg2rad(90) deg2rad(90) 0])

move_to_joint_states( [deg2rad(-5.4) deg2rad(80)  deg2rad(35)  deg2rad(65) deg2rad(5.1)]) % imove robot to block 2

set_tool(1) ; % closes tool

move_to_joint_states([deg2rad(-5.4) 0 deg2rad(90) deg2rad(90) deg2rad(5.1)]) % move arm up 

move_to_joint_states([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0]) % rotate arm while up 

move_to_joint_states( [ deg2rad(90-5.4) deg2rad(80) deg2rad(35) deg2rad(65)  deg2rad(5.4)]) % put arm down and release block

set_tool(0) ; % opens tool

pause(5)

move_to_joint_states([ deg2rad(90) 0 deg2rad(90) deg2rad(90) 0])

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
%}
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

function [] = move_to_joint_states(joint_states) % in put joint position for the robot
Qmatrix{1} = joint_states;
jointTarget = joint_states; % Remember that the Dobot has 4 joints by default.
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

function[endEffectorPosition] = set_end_effector_pos()
endEffectorPoseSubscriber = rossubscriber('/dobot_magician/end_effector_poses'); % Create a ROS Subscriber to the topic end_effector_poses
pause(2); %Allow some time for MATLAB to start the subscriber
%% Determines the desired end effector position based off the detected block and adding to the current end effector pose. 
X_calibrated_offset = 0;%TBD
Y_calibrated_offset = 0;%TBD
Z_calibrated_offset = 0;%TBD

endEffectorPoseSubscriber = receive(endEffectorPoseSubscriber)
X = endEffectorPoseSubscriber.Pose.Position.X
Y = endEffectorPoseSubscriber.Pose.Position.Y
Z = endEffectorPoseSubscriber.Pose.Position.Z

[RED_COORD,GREEN_COORD,BLUE_COORD] = detectHSV()
Z_offset = 0.040 %from the base of the arm to the ground
endEffectX= RED_COORD.at(1) + X +X_calibrated_offset;
endEffectY = RED_COORD.at(2) + Y +Y_calibrated_offset;
endEffectZ=RED_COORD.at(3) + Z  +Z_calibrated_offset;
endEffectorPosition = [endEffectX,endEffectY,endEffectZ]
endEffectorRotation = [0,0,0];
pause(3);
return 
end 
 
function[] = move_to_end_effector(end_effector_pos)

[targetEndEffectorPub,targetEndEffectorMsg] = rospublisher('/dobot_magician/target_end_effector_pose');

targetEndEffectorMsg.Position.X = endEffectorPosition(1);
targetEndEffectorMsg.Position.Y = endEffectorPosition(2);
targetEndEffectorMsg.Position.Z = endEffectorPosition(3);

qua = eul2quat(endEffectorRotation);
targetEndEffectorMsg.Orientation.W = qua(1);
targetEndEffectorMsg.Orientation.X = qua(2);
targetEndEffectorMsg.Orientation.Y = qua(3);
targetEndEffectorMsg.Orientation.Z = qua(4);

send(targetEndEffectorPub,targetEndEffectorMsg);

end 