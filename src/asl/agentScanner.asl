totalMovement(0, 0).
goldResources([]).
diamondResources([]).
goldResourcesv2([]).
diamondResourcesv2([]).
isDuplicate(true).
goalCoords([]).
rowComplete(false).

!initialise.

+!initialise: true <-
	.print("Initialising stuff");
	rover.ia.get_map_size(Width, Height);
	ia_submission.mapSetup(Width, Height);
	!scan_movement
	.
	
+! generalMove: true <-
	.drop_all_intentions;
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
		.print("(x, y): ", CurrXPos, ", ", CurrYPos);
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
	if (Width <= TotalXDist + 8 & (Height/2) <= TotalYDist + 9) {
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
	.print("Preparing to send resource list");
	// check if second scanner has sent their list yet
	?goldResourcesv2(GoldList2);
	?diamondResourcesv2(DiamondList2);
	// if so concat (use union to avoid duplciates)
	if (GoldList2 == [] & DiamondList2 == []) {
		// if empty, wait until sent
		.wait({+goldResourcesv2(GoldResourceListv2)});
		.wait({+diamondResourcesv2(DiamondResourceListv2)});
	} else {
		GoldResourceListv2 = GoldList2;
		DiamondResourceListv2 = DiamondList2;
	}
	?goldResources(GoldResourceList);
	?diamondResources(DiamondResourceList);
	// concat lists
	.union(GoldResourceList, GoldResourceListv2, NewGoldResourceList);
	.union(DiamondResourceList, DiamondResourceListv2, NewDiamondResourceList);

	.print("Complete gold resource List: ", NewGoldResourceList);
	.print("Complete diamond resource List: ", NewDiamondResourceList);
	.send(agentCollectorGoldExtra, tell, goldResources(NewGoldResourceList));
	.send(agentCollectorDiamondExtra, tell, diamondResources(NewDiamondResourceList));
	ia_submission.showMap;
	.kill_agent(agentScanner);
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
	
	
	