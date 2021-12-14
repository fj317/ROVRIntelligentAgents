totalMovement(0, 0).
goldResources([]).
diamondResources([]).
isDuplicate(true).
goalCoords([]).
rowComplete(false).

!initialise.

+!initialise: true <-
	.print("Initialising stuff");
	rover.ia.get_map_size(Width, Height);
	ia_submission.mapSetup(Width, Height);
	!scan_movement;
	.
	
+! generalMove: true <-
	.drop_all_events;
	// use A* search to find route to goal coords
	?goalCoords(GoalCoords);
	rover.ia.get_map_size(Width, Height);
	?totalMovement(XPos, YPos);
	.length(GoalCoords, GoalCoordsLength);
	.nth(GoalCoordsLength-1, GoalCoords, CurrentGoalCoords);
	.nth(0, CurrentGoalCoords, GoalCoordsX);
	.nth(1, CurrentGoalCoords, GoalCoordsY);
	ia_submission.findRoute(XPos, YPos, GoalCoordsX, GoalCoordsY, MoveList);
	//.print(MoveList);
	for (.member(CurrentMoveVector, MoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
		?totalMovement(CurrXPos, CurrYPos);
		-+totalMovement(CurrXPos + XVector,  CurrYPos + YVector);
	}
	// check if completed whole row
	?rowComplete(CompletedRow)
	?totalMovement(NewXPos, NewYPos);
	if (CompletedRow) {
		-+totalMovement(NewXPos-Width, NewYPos);
		-+rowComplete(false);
	}
	// remove goal coord from list
	.delete(GoalCoordsLength-1, GoalCoords, NewGoalCoords);
	-+goalCoords(NewGoalCoords);
	!scan_movement;
	.

+! scan_movement: true <-
	.print("Scanning...");
	scan(6);
	?totalMovement(TempTotalXDist, TempTotalYDist);
	?goalCoords(GoalCoords);
	rover.ia.get_map_size(Width, Height);
	?totalMovement(TotalXDist, TotalYDist);
	// check if moved half across map (other half done by other scanner)
	if (Width <= TotalXDist + 8 & Height <= TotalYDist + 9) {
		// if true, return to base and kill agent
		ia_submission.findRoute(TotalXDist, TotalYDist, 0, 0, MoveList);
		// do moves
		// loop through MoveList, doing each move in turn
		for (.member(CurrentMoveVector, MoveList)) {
			.nth(0, CurrentMoveVector, XVector);
			.nth(1, CurrentMoveVector, YVector);
			move(XVector, YVector);
		}
		// send list
		!sendResourceList;
	// check if moved all of map width
	} elif (Width <= TotalXDist + 8) {
		// move 9 down
		.concat(GoalCoords, [[0, TotalYDist + 9]], NewGoalCoords);
		-+rowComplete(true);
	// if neither of ifs are true, then continue movement on X axis
	} else {
		// move 8 right
		.concat(GoalCoords, [[TotalXDist + 8, TotalYDist]], NewGoalCoords);
	}
	-+goalCoords(NewGoalCoords);
	!generalMove;
	.
	
-! scan_movement: true <-
	.print("Error doing movement & scanning");
	// check if error is caused by lack of energy
	rover.ia.check_status(EnergyLevel);
	if (EnergyLevel <= 50) {
		!sendResourceList
	}
	.
	
+! sendResourceList: true <-
	.print("Sending resource list");
	?goldResources(GoldResourceList);
	.print("Scanner gold resource List: ", GoldResourceList);
	.send(agentCollectorGoldExtra, tell, goldResources(GoldResourceList));
	// after sent, kill agent
	.kill_agent(agentScannerv3);
	.

	
-! sendResourceList: true <-
	.print("Error sending resource lists");
	.
	
+ obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	.print("Agent obstructed");
	// work out correct X & Y distance from base
	?totalMovement(TotalXDist, TotalYDist);
	XDistance = TotalXDist + XTravelled;
	YDistance = TotalYDist + YTravelled;
	// update TotalX and TotalY
	-+totalMovement(XDistance, YDistance);
	// do a scan to see surroundings
	scan(6);
	!generalMove;
	.
	
	
@resource_found[atomic]
+ resource_found(ResourceType, Quantity, XDistToResource, YDistToResource): true <-
	?totalMovement(TotalXDist, TotalYDist);
	// add resource coord to array
	?goldResources(GoldResourceList);
	?diamondResources(DiamondResourceList);
	rover.ia.get_map_size(Width, Height);
	XDistance = TotalXDist + XDistToResource;
	YDistance = TotalYDist + YDistToResource;
	-+isDuplicate(false);
	// if gold:
	if (ResourceType = "Gold") {
		// if list is empty add to list
		if (.empty(GoldResourceList)) {
			-+goldResources([[ResourceType, Quantity, XDistance, YDistance]])
		} else {
			// check if gold already in list
			for(.member(X, GoldResourceList)) {
				.nth(2, X, XDistanceList);
				.nth(3, X, YDistanceList);
				// compare XDistances and YDistances of each gold with the newGold
				// if repeated then it is a duplicate
				
				// normalise coords to compare 
				ia_submission.convertCoords(XDistanceList, 0, NewXDistanceList);
				ia_submission.convertCoords(YDistanceList, 1, NewYDistanceList);
				ia_submission.convertCoords(XDistance, 0, NewXDistance);
				ia_submission.convertCoords(YDistance, 1, NewYDistance);
				
				if (NewXDistanceList == NewXDistance & NewYDistanceList == NewYDistance) {
					-+isDuplicate(true);
				}
			}
			?isDuplicate(IsDuplicateVar);
			// if not duplicate add to list
			if (IsDuplicateVar == false) {
				.concat(GoldResourceList, [[ResourceType, Quantity,  XDistance, YDistance]], NewGoldResourceList);
				-+goldResources(NewGoldResourceList);
			}		
		}
	} elif (ResourceType == "Diamond") {
		// else if diamond:
		if (.empty(DiamondResourceList)) {
			-+diamondResources([[ResourceType, Quantity, XDistance, YDistance]])
		} else {
			// check if gold already in list
			for(.member(Y, DiamondResourceList)) {
				.nth(2, Y, XDistanceList);
				.nth(3, Y, YDistanceList);
				// compare XDistances and YDistances of each gold with the newGold
				// if repeated then it is a duplicate
				
				// normalise coords to compare 
				ia_submission.convertCoords(XDistanceList, 0, NewXDistanceList);
				ia_submission.convertCoords(YDistanceList, 1, NewYDistanceList);
				ia_submission.convertCoords(XDistance, 0, NewXDistance);
				ia_submission.convertCoords(YDistance, 1, NewYDistance);
				
				if (NewXDistanceList == NewXDistance & NewYDistanceList == NewYDistance) {
					-+isDuplicate(true);
				}
			}
			?isDuplicate(IsDuplicateVar);
			// if not duplicate add to list
			if (IsDuplicateVar == false) {
				.concat(DiamondResourceList, [[ResourceType, Quantity, XDistance, YDistance]], NewDiamondResourceList);
				-+diamondResources(NewDiamondResourceList);
			}		
		}
			
	} elif (ResourceType == "Obstacle") {
		// else if obstacle
		// add obstacle to map
		ia_submission.addObstacle(XDistance, YDistance);
	}
	.
	
-! generalMove: true <-
	.print("General move plan error");
	.
	
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy left to move");
	!sendResourceList;
	.
	
	
	