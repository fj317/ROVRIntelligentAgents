totalMovement(0, 0).
goldResources([]).
diamondResources([]).
isDuplicate(true).

!scan_movement.

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
	
	
@resource_found[atomic]
	+ resource_found(ResourceType, Quantity, XDistToResource, YDistToResource): true <-
	.print("Resource found");
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
	} else {
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
	}
	.
	
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy left to move");
	!sendResourceList;
	.
	
	
	