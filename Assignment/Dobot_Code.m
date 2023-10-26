
init_ros();
status = set_safety_stat() ;

set_tool(0) ; % opens tool
move_to_joint_states([ 0 0 0 0 0]);% puts dobot in its neutral position
pause(2);
%current_end_effector_pos = get_current_end_effector_pos()
pos = set_end_effector_pos();
%%
move_to_end_effector(pos);
%%
pause(2);


function [] = init_ros() %shutsdown the current ROS and initiates it to the ip address of the raspberry pi
rosshutdown
rosinit('192.168.27.1');
rosnode list % displays list of rostopic to get visual confirmation that the dobot and realsense camera are connected properly
end 
 
function [status] = set_safety_stat()

safetyStatusSubscriber = rossubscriber('/dobot_magician/safety_status'); % returns current safety status
pause(2); %Allow some time for MATLAB to start the subscriber

[safetyStatePublisher,safetyStateMsg] = rospublisher('/dobot_magician/target_safety_status');
safetyStateMsg.Data = 4; % sets the current safety status to 4 (operational) 
send(safetyStatePublisher,safetyStateMsg);
status = true; 
pause(3);

return 
end 
%based off example code from https://github.com/gapaul/dobot_magician_driver/wiki/MATLAB-Example
function [] = move_to_joint_states(joint_states) % receives the desired joint states and moves the robot towards them
Qmatrix{1} = joint_states;
jointTarget = joint_states; %  Dobot has 5 joints by default.
safetyStatusSubscriber = rossubscriber('/dobot_magician/safety_status');
pause(2); %Allow some time for MATLAB to start the subscriber

% topic to send desired joint states to 
[targetJointTrajPub,targetJointTrajMsg] = rospublisher('/dobot_magician/target_joint_states');
trajectoryPoint = rosmessage("trajectory_msgs/JointTrajectoryPoint");
trajectoryPoint.Positions = jointTarget; % the position of what it needs to move to
targetJointTrajMsg.Points = trajectoryPoint;

send(targetJointTrajPub,targetJointTrajMsg);

pause(3);
end 

function[] = set_tool(state) % 0 opens gripper, 1 closes gripper
 [toolStatePub, toolStateMsg] = rospublisher('/dobot_magician/target_tool_state');
toolStateMsg.Data = [1 state];
send(toolStatePub,toolStateMsg);

pause(3);
end 


function[endEffectorPosition] = set_end_effector_pos()
current_end_effector_pos = get_current_end_effector_pos();
%determined through measureing hte calculated end effector position and the
%desired end effector position
X_calibrated_offset = 0;%TBD
Y_calibrated_offset = 0;%TBD
Z_calibrated_offset = 0;%TBD
% Current end effector position 
X = current_end_effector_pos(1,1);
Y =current_end_effector_pos(1,2);
Z = current_end_effector_pos(1,3);

[RED_COORD,GREEN_COORD,BLUE_COORD] = detectHSV() % see detect HSV function for details 
Z_offset = 0.040;%from the base of the arm to the ground
endEffectX= RED_COORD.at(1) + X +X_calibrated_offset; %adds calculated position of block, current end effector position and measured offset 
endEffectY = RED_COORD.at(2) + Y +Y_calibrated_offset;
endEffectZ=RED_COORD.at(3) + Z  +Z_calibrated_offset;
endEffectorPosition = [endEffectX,endEffectY,endEffectZ]; % final end effector position
endEffectorRotation = [0,0,0];
pause(3);
return 
end 

%based off example code from https://github.com/gapaul/dobot_magician_driver/wiki/MATLAB-Example
function[] = move_to_end_effector(end_effector_pos)

[targetEndEffectorPub,targetEndEffectorMsg] = rospublisher('/dobot_magician/target_end_effector_pose');

targetEndEffectorMsg.Position.X = end_effector_pos(1);
targetEndEffectorMsg.Position.Y = end_effector_pos(2);
targetEndEffectorMsg.Position.Z = end_effector_pos(3);

qua = eul2quat(endEffectorRotation);
targetEndEffectorMsg.Orientation.W = qua(1);
targetEndEffectorMsg.Orientation.X = qua(2);
targetEndEffectorMsg.Orientation.Y = qua(3);
targetEndEffectorMsg.Orientation.Z = qua(4);
send(targetEndEffectorPub,targetEndEffectorMsg);

end 

%based off example code from https://github.com/gapaul/dobot_magician_driver/wiki/MATLAB-Example
function[current_end_effector_pos] = get_current_end_effector_pos()
endEffectorPoseSubscriber = rossubscriber('/dobot_magician/end_effector_poses'); % Create a ROS Subscriber to the topic end_effector_poses
pause(2); %Allow some time for MATLAB to start the subscriber
%% Determines the desired end effector position based off the detected block and adding to the current end effector pose. 

endEffectorPoseSubscriber = receive(endEffectorPoseSubscriber);
X = endEffectorPoseSubscriber.Pose.Position.X;
Y = endEffectorPoseSubscriber.Pose.Position.Y;
Z = endEffectorPoseSubscriber.Pose.Position.Z;
current_end_effector_pos = [X,Y,Z];
return 
end 