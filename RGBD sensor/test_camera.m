
rosshutdown
rosinit('192.168.27.1')

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