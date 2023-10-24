clc;
close all;
clear all;

hold on;

surf([-5,-5;4,4],[-3,3;-3,3],[0,0; 0,0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');
conveyer = PlaceObject('Conveyer.ply', [1, 0, 0.5]);
r = Thor( transl(0 , 0 , 0.5) * trotz(-90,"deg"));
m = DobotMagician( transl(-0.7 , 0 , 0.5) * trotz(-90,"deg"));
table1 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [-0.6,0, 0]);
table2 = PlaceObject('tableBrown2.1x1.4x0.5m.ply', [1.35,0, 0]);
fence = PlaceObject('fenceAssemblyGreenRectangle4x8x2.5m.ply', [0,1,-1]);
FireExt = PlaceObject('fireExtinguisherElevated.ply', [-3,1.2,0.5]);
EmergencyStop = PlaceObject('emergencyStopWallMounted.ply', [1,2.14,1.5]);
InductedWorker = PlaceObject('personMaleConstruction.ply', [-3,0, 0]);
UninductedWorker = PlaceObject('personMaleCasual.ply', [-2.5,-2, 0]);

RedCan = PlaceObject('RedCanV2.ply', [1 ,0, 0.6]);
% workspace = [-2 2  -2 2  0 5 ];

robot_pos = r.model.getpos();

TestMoveJoints(r);
% pause(5);
TestMoveJoints(m);

disp(robot_pos);
% 
% X = 0.3;
% Y = 0.3;
% Z = 0;

% workspace = [-2000,2000,-2000, 2000, -2000, 2000];

% h2 = PlaceObject('Conveyer.ply', [0, 0, 0]);
