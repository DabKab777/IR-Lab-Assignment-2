clc;
close all;
clear all;

hold on;

r = LinearUR3;

workspace = [-2000,2000,-2000, 2000, -2000, 2000];

h2 = PlaceObject('Conveyer.ply', [0, 0, 0]);
