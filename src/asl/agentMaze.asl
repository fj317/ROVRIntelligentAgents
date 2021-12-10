// Agent agentMaze in project ia_submission
multipleRouteList([]).
totalMovement(0, 0).
previousDirection(0).

!initialise.

+!initialise: true <-
	.print("Initialising stuff");
	rover.ia.get_map_size(Width, Height);
	ia_submission.mapSetup(Width, Height);
	scan(6);
	!scan_movement
	.

+!scan_movement: true <-
	.print("Scanning and stuff");
	?totalMovement(TotalX, TotalY);
	?previousDirection(PrevDir);
	.print("Finding route");
	// find empty square and go to
	ia_submission.selectRoute(TotalX, TotalY, PrevDir, MoveVector);
	.print(MoveVector);
	// loop through MoveList, doing each move in turn
	for (.member(CurrentMoveVector, MoveVector)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
		?totalMovement(CurrXDistance, CurrYDistance);
		-+totalMovement(CurrXDistance + XVector, CurrYDistance + YVector);
		// check what previous direction was
		if (XVector == 1) {
			-+previousDirection(3);
		} elif (XVector == -1) {
			-+previousDirection(4);
		} elif (YVector == 1) {
			-+previousDirection(2);
		} elif (YVector == -1) {
			-+previousDirection(1);
		} else {
			// if both 0 then error occured
		}
	}	
	!scan_movement;
	.
	
-! scan_movement: true <-
	.print("Error with scan_movement plan");
	.

@resource_found[atomic]
+ resource_found(ResourceType, Quantity, XDistToResource, YDistToResource): true <-
	//.print("Object found...");
	?totalMovement(TotalXDist, TotalYDist);
	rover.ia.get_map_size(Width, Height);
	XDistance = TotalXDist + XDistToResource;
	YDistance = TotalYDist + YDistToResource;
	if (XDistance >= Width/2) { 
		// if the Y distance travelled is more than half the height, same as above
		if (YDistance >= Height/2) {
			NewXDistance = -(Width - XDistance);
			NewYDistance = -(Height - YDistance);
		} else {
			NewXDistance = -(Width - XDistance);
			NewYDistance = YDistance;
		}
	} else {
		// if the Y distance travelled is more than half the height, same as above
		if (YDistance >= Height/2) {
			NewXDistance = XDistance;
			NewYDistance = -(Height - YDistance);
		} else {
			// if the quickest route is the way we came, backtrack using this route
			NewXDistance = XDistance;
			NewYDistance = YDistance;
		}
	}	
	if (ResourceType == "Obstacle") {
		// add obstacle to map
		ia_submission.addObstacle(NewXDistance, NewYDistance);
	}
	.
	
+ obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	.print("Obstructed");
	ia_submission.showMap;
	scan(6);
	.
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy left to move");
	.
	
	
// scan
// move into space
// if two routes available, add coords to list and go down one route
// continue until route finished
// if resource found at any point, add it to resource list
// once all maze explored, go to exit and escape
// send resource list to agents
// let them go out and collect resources
// beuno
