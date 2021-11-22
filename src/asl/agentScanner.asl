totalMovement(0, 0).
resources([]).
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
	?resources(ResourceList);
	.print("Resource List: ", ResourceList);
	.send(agentCollectorGold, tell, goldResources(ResourceList));
	.
	
	
@resource_found[atomic]
	+ resource_found(ResourceType, Quantity, XDist, YDist): true <-
	.print("Resource found");
	?totalMovement(TotalXDist, TotalYDist);
	// add resource coord to array
	?resources(ResourceList);
		rover.ia.get_map_size(Width, Height);
	GoldXDistance = TotalXDist + XDist;
	GoldYDistance = TotalYDist + YDist;
	if (GoldXDistance >= Width/2) { 
		// if the Y distance travelled is more than half the height, same as above
		if (GoldYDistance >= Height/2) {
			NewGoldXDistance = -(Width - GoldXDistance);
			NewGoldYDistance = -(Height - GoldYDistance);
		} else {
			NewGoldXDistance = -(Width - GoldXDistance);
			NewGoldYDistance = GoldYDistance;
		}
	} else {
		// if the Y distance travelled is more than half the height, same as above
		if (GoldYDistance >= Height/2) {
			NewGoldXDistance = GoldXDistance;
			NewGoldYDistance = -(Height - GoldYDistance);
		} else {
			// if the quickest route is the way we came, backtrack using this route
			NewGoldXDistance = GoldXDistance;
			NewGoldYDistance = GoldYDistance;
		}
	}	
	// if list is empty add to list
	if (.empty(ResourceList)) {
		-+resources([[ResourceType, Quantity, NewGoldXDistance, NewGoldYDistance]])
	} else {
		// check if gold already in list
		-+isDuplicate(false);
		for(.member(X, ResourceList)) {
			.nth(2, X, XDistance);
			.nth(3, X, YDistance);
			// compare XDistances and YDistances of each gold with the newGold
			// if repeated then it is a duplicate
			if (XDistance == NewGoldXDistance & YDistance == NewGoldYDistance) {
				-+isDuplicate(true);
			}
		}
		?isDuplicate(IsDuplicateVar);
		// if not duplicate add to list
		if (IsDuplicateVar == false) {
			.concat(ResourceList, [[ResourceType, Quantity,  NewGoldXDistance, NewGoldYDistance]], NewResourceList);
			-+resources(NewResourceList);
		}		
	}
	.
	
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid ", ActionName, " action because ", Reason);
	.
	
+ insufficient_energy(move) <-
	.print("No energy left to move");
	.
	
	
	