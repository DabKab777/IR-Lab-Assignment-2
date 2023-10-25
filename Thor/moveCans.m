function moveCans(Scene, distance)
    speed = 0.2;
    dt = 0.01;
    totalTime = distance / speed;
    currentTime = 0;

    while currentTime < totalTime
        % Move each can by a little bit
        Scene.RedCanPosition(1) = Scene.RedCanPosition(1) - speed*dt;
        Scene.BlueCanPosition(1) = Scene.BlueCanPosition(1) - speed*dt;
        Scene.GreenCanPosition(1) = Scene.GreenCanPosition(1) - speed*dt;

        % Delete the previous cans and draw at the new positions
        delete(Scene.RedCan);
        delete(Scene.BlueCan);
        delete(Scene.GreenCan);

        Scene.RedCan = PlaceObject('RedCan.ply', Scene.RedCanPosition);
        Scene.BlueCan = PlaceObject('BlueCan.ply', Scene.BlueCanPosition);
        Scene.GreenCan = PlaceObject('GreenCan.ply', Scene.GreenCanPosition);

        pause(dt);
        currentTime = currentTime + dt;
    end
end