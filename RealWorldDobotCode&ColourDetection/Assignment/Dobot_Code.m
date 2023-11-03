
%%
%Pre-determined positions that the respective blocks to be placed. The End
%result should be that the blocks will build a 2-level pyramid with teh
%blue placed on top
green_place_position = [ 0.2338   -0.1481   -0.0399] 
red_place_position = [ 0.2531   -0.1557   -0.0486]
blue_place_position = [0.2444   -0.1542    0.018]
placing_positions = [green_place_position,red_place_position,blue_place_position]
%%
init_ros();
status = set_safety_stat() ;

%%
colours =[1,2,3] %green,red,blue
for i=1:length(colours)
    set_tool(0) ; % opens tool
    move_to_joint_states([ 0 0 0 0 0]);% puts dobot in its neutral position
    pause(2);
    colour = i ; % if colour is 1 then the red block's coordinate will be determined,if 2 green,if 3 blue
    pos = set_end_effector_pos(colour) % sets the desired end effector position
    pause(3);
    move_to_end_effector(pos); %moves the dobot to the determined end effector position
    pause(2);
    set_tool(1) ; % closes tool to grab the block
    move_to_joint_states([ 0 0 0 0 0]);% puts dobot in its neutral position
    pause(2);
    position = placing_positions(i) %places the dobot (Based on the colour) to the predetermind position
    move_to_end_effector(position); %moves end effector to the predetermined position
    pause(2);
    set_tool(0) ; % opens tool to place block
    move_to_end_effector([position(1) position(2) position(3)+0.04]); %moves the dobot up by 40mm in the z direction 
    % so that it doesn't hit the placed block when moving back to the
    % neutral position
    pause(2);
end 

move_to_joint_states([ 0 0 0 0 0]);% puts dobot in its neutral position to finish



%%


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
    jointTarget = joint_states; %  Dobot has 4 joints by default.
    pause(2);
    % topic to send desired joint states to 
    [targetJointTrajPub,targetJointTrajMsg] = rospublisher('/dobot_magician/target_joint_states');
    trajectoryPoint = rosmessage("trajectory_msgs/JointTrajectoryPoint");
    trajectoryPoint.Positions = jointTarget; % the position of what it needs to move to
    targetJointTrajMsg.Points = trajectoryPoint;
    send(targetJointTrajPub,targetJointTrajMsg);%sends the target joints to the dobot
    
    pause(3);
end 

function[] = set_tool(state) % 0 opens gripper, 1 closes gripper
     [toolStatePub, toolStateMsg] = rospublisher('/dobot_magician/target_tool_state');
     toolStateMsg.Data = [1 state];
     send(toolStatePub,toolStateMsg);
     pause(3);
end 


function[endEffectorPosition] = set_end_effector_pos(colour)
    current_end_effector_pos = get_current_end_effector_pos()
    COORD_CAM = detectHSV(colour) 
    % see detect  HSV function for details.
    
    % Current end effector position 
    X = current_end_effector_pos(1,1);
    Y = current_end_effector_pos(1,2);
    Z = current_end_effector_pos(1,3);
    %converts coordinates of the found block into the coordinates of the
    %dobot
    endEffectX=X+COORD_CAM(2)
    endEffectY=Y+COORD_CAM(1)
    endEffectZ=Z -COORD_CAM(3)
    
    endEffectorPosition = [endEffectX,endEffectY,endEffectZ] % function returns the coordiante of the found block which will be where the end effector is to move to.
    % 
    pause(3);
return 
end 

%based off example code from https://github.com/gapaul/dobot_magician_driver/wiki/MATLAB-Example
function[] = move_to_end_effector(end_effector_pos) %intakes the desired end effector position
    endEffectorRotation = [0,0,0];
    
    [targetEndEffectorPub,targetEndEffectorMsg] = rospublisher('/dobot_magician/target_end_effector_pose'); %rostopic for target end effector pose
    end_effector_pos(1)
    end_effector_pos(2)
    end_effector_pos(3)
    targetEndEffectorMsg.Position.X = end_effector_pos(1)
    targetEndEffectorMsg.Position.Y = end_effector_pos(2)
    targetEndEffectorMsg.Position.Z = end_effector_pos(3)
    qua = eul2quat(endEffectorRotation);
    targetEndEffectorMsg.Orientation.W = qua(1);
    targetEndEffectorMsg.Orientation.X = qua(2);
    targetEndEffectorMsg.Orientation.Y = qua(3);
    targetEndEffectorMsg.Orientation.Z = qua(4);
    send(targetEndEffectorPub,targetEndEffectorMsg);
    pause(3)

end 

%based off example code from https://github.com/gapaul/dobot_magician_driver/wiki/MATLAB-Example
function[current_end_effector_pos] = get_current_end_effector_pos()
    endEffectorPoseSubscriber = rossubscriber('/dobot_magician/end_effector_poses'); % Create a ROS Subscriber to the topic end_effector_poses
    pause(2); %Allow some time for MATLAB to start the subscriber
    %the end effector position return from the rostopic
    %/dobot_magician/end_effector_poses doesn't return the end point on the
    %gripper but the end point of where the gripper is attacched. because
    %of this, x and z offsets need to be added to the return end effector
    %position
    endEffectorPoseSubscriber = receive(endEffectorPoseSubscriber);
    X_end_effector_offset = 0.03;% NOTE these values change based on the type of end effector used 
    % as well as the dobot (this 2nd point was determined based off
    % testing)
    Z_end_effector_offset = -0.09; 
    X = endEffectorPoseSubscriber.Pose.Position.X +X_end_effector_offset ;
    Y = endEffectorPoseSubscriber.Pose.Position.Y;
    Z = endEffectorPoseSubscriber.Pose.Position.Z+Z_end_effector_offset;
    current_end_effector_pos = [X,Y,Z]; %returns the end effector position with the added offsets
return 
end 

function [CAM_COORDS] = detectHSV( colour)
% created function which does :
% 1. filters out the 3 blocks of colours green, red and blue
% 2. returns the pixel coordinates of the centre of the blocks 
%3. returns the 3D coordinate of one of the blocks in the dobot's coordinate frame (the coordinate is based
%of the input colour variable.
    %These values were determined through trial and error
    SAT_TOL = [0.2,1] ;%saturation threshold values. pixel must have saturations values between these
    BLUE = [0.5, 0.75]; % pixel must have blue between these HUE values
    GREEN = [0.25,0.5]; %pixel must have green between these HUE values
    RED = [0.03,0.97]; % pixel must have red colour >=0.95 or =< 0.05 
    %rosshutdown
    %rosinit('192.168.27.1');
    %rosnode list % displays list of rostopics
    
    imageTopic = '/camera/color/image_raw'; % topic from which the rgb image is received 
    img_depth = '/camera/aligned_depth_to_color/image_raw';    % topic from which the depth image is received
    cam_info = '/camera/aligned_depth_to_color/camera_info'; % topic from which camera parameters like principal points and focal length is received
    
    sub_1 = rossubscriber(imageTopic);% subscribe to topics
    sub_2  = rossubscriber(img_depth); 
    sub_3 = rossubscriber(cam_info);
    
    imageData = receive(sub_1); % receive topics
    DepthData = receive(sub_2);
    %%
    img_color = readImage(imageData);
    img_depth = readImage(DepthData);
    RGB = img_color;
    dim = size(img_color);
    dim = size(img_depth);
    
    HSV = rgb2hsv(RGB); % converts the rgb image to hsv for better detection accuracy of colours
    HUE = HSV(:,:,1); % slices the pixel dimensions into HUE,SATURATION AND BLUR
    SAT = HSV(:,:,2);
    VAL = HSV(:,:,3);
    
    % obtains the red,green and blue masks of the hsv image based on bitmasking
    % with the respective hue and saturation values
    redMask = (HUE >= RED(1,2)) | (HUE <= RED(1,1)) & (SAT >=SAT_TOL(1,1) & SAT <=SAT_TOL(1,2));
    blueMask = (HUE <= BLUE(1,2)) & (HUE >= BLUE(1,1))& (SAT >=SAT_TOL(1,1)&  SAT <=SAT_TOL(1,2)) ;
    greenMask = (HUE <= GREEN(1,2)) & (HUE >= GREEN(1,1)) & (SAT >=SAT_TOL(1,1)&  SAT <=SAT_TOL(1,2));
    structuringElement = strel('square', 5); % a kernel with which we can perfrom morphological operations to remove nosie from the image
    smallestAcceptableArea = 1000; % smallest area of pixels which won't be filtered out. 
    redMask = cleanHSV(redMask,smallestAcceptableArea,structuringElement); % see cleanHSV Function
    blueMask = cleanHSV(blueMask,smallestAcceptableArea,structuringElement);
    greenMask = cleanHSV(greenMask,smallestAcceptableArea,structuringElement);
    
    masks = [redMask,greenMask,blueMask];
    centroids = getCentroids(masks,dim) %obtains the pixel coordiantes of red green and blue blocks
    plotOutput(centroids,masks,img_color,dim);
    
            if colour==1%green
                 depth = img_depth(centroids(2,1),centroids(2,1)) ;   %finds the depth measurement of the green block
                    CAM_COORDS = get_3D_coords(centroids(2,1),centroids(2,1), depth) % converts gets the X,Y,Z of the green block in the Camera's coordinate 
    
            elseif colour==2 %red
              depth = img_depth(centroids(1,1),centroids(2,1))    %finds the depth measurement of the red block
               CAM_COORDS = get_3D_coords(centroids(1,1),centroids(2,1), depth) % converts gets the X,Y,Z of the red block in the Camera's coordinate fr
    
      
            elseif colour==3  %blue
                centroids(1,3)
                centroids(2,3)
               depth = img_depth(centroids(1,1),centroids(2,1))    %finds the depth measurement of the blue block
               CAM_COORDS = get_3D_coords(centroids(1,1),centroids(2,1), depth) % converts gets the X,Y,Z of the blue block in the Camera's coordinate fr
      
            end 

return 
    





end 

function[mask] = cleanHSV(mask,smallestAcceptableArea,structuringElement)
    mask = bwareaopen(mask, smallestAcceptableArea); % function removes areas smaller than smallest acceptable area
    mask  = imclose(mask, structuringElement);
    mask = imfill(mask, 'holes'); % if an area has non red ,green or blue inside then those are converted to that resepective colour to obtain a opaque and 
    % full shape
    
    return
end 

%function takes in the determined red , green and blue masks.
% for each mask , the x,y coordinate of the centre of the block are found
% by getting the mean pixel coordinate of the pixels for each colour.
% this mean results in returning the centre of the blocks
function[centroids] = getCentroids(masks,dim)
        centroids = zeros(2,3);
        lower = 1;
        upper = dim(1,2);
    for i = 1:3
        masks(1:dim(1,1),lower:upper)
        [y, x] = find( masks(1:dim(1,1),lower:upper)); % find function return the row and column value (pixel coordinates)
        centroids(1,i) = round(mean(x)); 
        centroids(2,i) = round(mean(y));
        lower = upper;
        upper = upper+ dim(1,2);
    end 
    return 
end 
 % optional function to include shows the original image captured by the
 % camera.
 % plots the centre of each blocks.
 % plots the masks of each block in black and white for each mask
 % (red,green then blue) 
 
function[] = plotOutput(centroids, masks,RGB,dim)
    
    subplot(2,2,1)
    imshow(RGB); 
    title('Original Image');
    axis on 
    hold on 
    
    plot(centroids(1,:),centroids(2,:),'w*',MarkerSize=10);
    hold off;
    subplot(2,2,2),imshow(masks(1:dim(1,1),1:dim(1,2)) ); title('Red block');
    subplot(2,2,3),imshow(masks(1:dim(1,1),dim(1,2):dim(1,2)*2)); title('Green block');
    subplot(2,2,4),imshow(masks(1:dim(1,1),dim(1,2)*2:dim(1,2)*3) ); title('Blue block');
end 

function[] = plotBoundaries(masks)
    [B,L] = bwboundaries(redMask,'noholes');
    
    imshow(label2rgb(L, @jet, [.5 .5 .5]))
    
    for k = 1:length(B)
       boundary = B{k};
       plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
    end   
     [B,L] = bwboundaries(blueMask,'noholes');
      imshow(label2rgb(L, @jet, [.5 .5 .5]))

end 

function[coords]  = get_3D_coords(x_pixel, y_pixel, depth_measurement)
    % These measuredments are based a custom camera mount and the dimensions of the realsense D435 camera
    % for a different camera mount and camera these values will need to
    %changed.
    X_effector_to_cam_offset=+ 0.02; 
    Y_effector_to_cam_offset=0.065;
    Z_effector_to_cam_offset=-0.055;
    
    %these values were taken from the rostopic /camera/aligned_depth_to_color/camera_info
    u = 650.2572021484375 %Principal point X 
    v = 370.2181091308594 % Principal point Y 
    f_x = 927.1157836914062/1000 % focal length X 
    f_y = 925.2620239257812/1000 % focal length Y\

    Z = double(depth_measurement)/1000 % depth measureement 
    X =  ((u-x_pixel)/f_x)*Z % from tutorial 2 of sensors and control to obtain X & Y coordinatoes
    Y =  ((v-y_pixel)/f_y)*Z %
    
    coords = [X/1000+X_effector_to_cam_offset, Y/1000+Y_effector_to_cam_offset, Z+Z_effector_to_cam_offset ]

return 
end 
