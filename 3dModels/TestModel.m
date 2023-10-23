clc;
close all;
clear all;

hold on;

r = Thor;

robot_pos = r.model.getpos();

disp(robot_pos);

X = 0.3;
Y = 0.3;
Z = 0;

% workspace = [-2000,2000,-2000, 2000, -2000, 2000];

% h2 = PlaceObject('Conveyer.ply', [0, 0, 0]);
