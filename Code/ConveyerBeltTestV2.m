clc;
close all;
clear all;

hold on;

surf([-0.5,-0.5;2,2],[-1,1;-1,1],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
r = Thor( transl(0 , 0 , 0.5) * trotz(-90,"deg"));
% global RedCan BlueCan GreenCan;
global RedCanPosition BlueCanPosition GreenCanPosition; % Declare them as global here
% Initial position of the RedCan
RedCanPosition = [0.4 ,0, 0.55];
BlueCanPosition = [1.1 ,0, 0.55];
GreenCanPosition = [1.2 ,0, 0.55];

RedCan = PlaceObject('RedCan.ply', RedCanPosition);
BlueCan = PlaceObject('BlueCan.ply', BlueCanPosition);
GreenCan = PlaceObject('GreenCan.ply', GreenCanPosition);

