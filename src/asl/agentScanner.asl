totalMovement(0, 0).
goldResources([]).
diamondResources([]).
isDuplicate(true).

!initialise.

+!initialise: true <-
	.print("Initialising stuff");
	rover.ia.get_map_size(Width, Height);
	ia_submission.mapSetup(Width, Height);
	!scan_movement
	.

+! scan_movement: true <-
	.print("Scanning...");
	scan(6);
	?totalMovement(TotalXDist, TotalYDist);
	rover.ia.get_map_size(Width, Height);
	// check if moved all across map
	if (Width <= TotalXDist + 8 & Height <= TotalYDist + 9) {
		// if true, return to base and kill agent
		move(Width - TotalXDist, Height - TotalYDist);
		// send list
		!sendResourceList;
		.kill_agent(agentScanner);
	// check if moved all of map width
	} elif (Width <= TotalXDist + 8) {
		// move back to X coord 0 
		move(Width - TotalXDist, 0);
		// move 9 vertically
		move(0, 9);
		// update totalMovement
		-+totalMovement(0, TotalYDist + 9);
	// if neither of ifs are true, then continue movement on X axis
	} else {
		// move 8 right
		move(8, 0);
		// update totalMovement
		-+totalMovement(TotalXDist + 8, TotalYDist);
	}
	// recursively call scan_movement plan
	!scan_movement;
	.
	
-! scan_movement: true <-
	.print("Error doing movement & scanning");
	.
	
+! sendResourceList: true <-
	.print("Sending resource list");
	?goldResources(GoldResourceList);
	?diamondResources(DiamondResourceList);
	.print("Gold resource List: ", GoldResourceList);
	.print("Diamond resource List: ", DiamondResourceList);
	.send(agentCollectorGold, tell, goldResources(GoldResourceList));
	.send(agentCollectorDiamond, tell, diamondResources(DiamondResourceList));
	.
	
-! sendResourceList: true <-
	.print("Error sending resource lists");
	.
	
+ obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	.print("Agent obstructed");
	// work out correct X & Y distance from base
	?totalMovement(TotalXDist, TotalYDist);
	rover.ia.get_map_size(Width, Height);
	XDistance = TotalXDist + XTravelled;
	YDistance = TotalYDist + YTravelled;
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
	if (XLeft > 0) { // if XLeft > 0 
		// then obstacle is to the right
		// add obstacle to map
		ia_submission.addObstacle(NewXDistance + 1, NewYDistance);
		
		
	} elif (YLeft > 0) { // else if YLeft > 0
		// then obstacle is below
		// add obstacle to map
		ia_submission.addObstacle(NewXDistance, NewYDistance + 1);
	}
	// update TotalX and TotalY
	-+totalMovement(XDistance, YDistance);
	// scan to see surrounding environment
	scan(6);
	// use A* search to find quickest route around it
	// goal is (TotalX + XTravelled + XLeft, TotalY + YTravelled + YLeft)
	// current (x, y) is (base+Total+Travelled)
	// goal (x, y) is (base+Total+Travelled+Left)
	// base is added in Handler java class
	ia_submission.findRoute(NewXDistance, NewYDistance, NewXDistance + XLeft, NewYDistance + YLeft, MoveList);
	.print(MoveList);
	// do moves
	// loop through MoveList, doing each move in turn
	for (.member(CurrentMoveVector, MoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
		?totalMovement(CurrXDistance, CurrYDistance);
		-+totalMovement(CurrXDistance + XVector, CurrYDistance + YVector);
	}	
	// once at goal, call scan_movement plan
	!scan_movement;
	.
	
	
@resource_found[atomic]
+ resource_found(ResourceType, Quantity, XDistToResource, YDistToResource): true <-
	.print("Object found");
	?totalMovement(TotalXDist, TotalYDist);
	// add resource coord to array
	?goldResources(GoldResourceList);
	?diamondResources(DiamondResourceList);
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
	-+isDuplicate(false);
	// if gold:
	if (ResourceType = "Gold") {
		// if list is empty add to list
		if (.empty(GoldResourceList)) {
			-+goldResources([[ResourceType, Quantity, NewXDistance, NewYDistance]])
		} else {
			// check if gold already in list
			for(.member(X, GoldResourceList)) {
				.nth(2, X, XDistanceList);
				.nth(3, X, YDistanceList);
				// compare XDistances and YDistances of each gold with the newGold
				// if repeated then it is a duplicate
				if (XDistanceList == NewXDistance & YDistanceList == NewYDistance) {
					-+isDuplicate(true);
				}
			}
			?isDuplicate(IsDuplicateVar);
			// if not duplicate add to list
			if (IsDuplicateVar == false) {
				.concat(GoldResourceList, [[ResourceType, Quantity,  NewXDistance, NewYDistance]], NewGoldResourceList);
				-+goldResources(NewGoldResourceList);
			}		
		}
	} elif (ResourceType == "Diamond") {
		// else if diamond:
		if (.empty(DiamondResourceList)) {
			-+diamondResources([[ResourceType, Quantity, NewXDistance, NewYDistance]])
		} else {
			// check if gold already in list
			for(.member(Y, DiamondResourceList)) {
				.nth(2, Y, XDistanceList);
				.nth(3, Y, YDistanceList);
				// compare XDistances and YDistances of each gold with the newGold
				// if repeated then it is a duplicate
				if (XDistanceList == NewXDistance & YDistanceList == NewYDistance) {
					-+isDuplicate(true);
				}
			}
			?isDuplicate(IsDuplicateVar);
			// if not duplicate add to list
			if (IsDuplicateVar == false) {
				.concat(DiamondResourceList, [[ResourceType, Quantity, NewXDistance, NewYDistance]], NewDiamondResourceList);
				-+diamondResources(NewDiamondResourceList);
			}		
		}
			
	} elif (ResourceType == "Obstacle") {
		// else if obstacle
		// add obstacle to map
		ia_submission.addObstacle(NewXDistance, NewYDistance);
	}
	.
	
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy left to move");
	!sendResourceList;
	.
	
	
	