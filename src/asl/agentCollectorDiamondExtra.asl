// Agent agentCollectorDiamond in project ia_submission

/* Initial beliefs and rules */
diamondResources([]).
diamondCollected(0).
diamondAtResource(0).
numberOfTrips(0).
moveList([]).

/* Initial goals */

!checkForDiamond.

/* Plans */

+!checkForDiamond : true <- 
	// check if resource found
	.wait({+diamondResources(DiamondResourceList)});
	// for each member of GoldResourceList, run resourceFound
	for(.member(X, DiamondResourceList)) {
		!resourceFound;
	}
	// once finished, kill agent
	.kill_agent(agentCollectorDiamond);
	.

@resourceFound[atomic]
+! resourceFound: true <-
	?diamondResources(ResourceList);
	// get current resource
	.nth(0, ResourceList, CurrentResource);
	// find distance to diamond and update distance to diamond
	// start is baseCoords
	// goal is XDistance + baseCoords
	.nth(2, CurrentResource, XDistance);
	.nth(3, CurrentResource, YDistance);
	.print("Its go time!");
	// find quantity of diamond and update diamondAtResource
	.nth(1, CurrentResource, DiamondAmount);
	-+diamondAtResource(DiamondAmount);
	// use A* search to find route to diamond
	rover.ia.get_map_size(Width, Height);
	ia_submission.findRoute(0, 0, XDistance, YDistance, MoveList);
	-+moveList(MoveList);
	for (.member(CurrentMoveVector, MoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
	}
	// work out how many trips to do
	// round up
	rover.ia.check_config(Capacity, Scanrange, Resourcetype);
	if (math.round(DiamondAmount / Capacity) < (DiamondAmount / Capacity)) {
		-+numberOfTrips(math.round(DiamondAmount / Capacity) + 1);
	} else {
		-+numberOfTrips(math.round(DiamondAmount / Capacity));
	}
	?numberOfTrips(TotalTrips);
	
	// collect resources, return to base & deposit and return to resource again
	for(.range(X, 1, TotalTrips)) {
		!collectDiamond;
		!returnToBase;
		!depositDiamond;
		// if last trip dont return to diamond
		?diamondAtResource(DiamondLeft);
		if (DiamondLeft > 0) {
			!returnToDiamond;
		}
	}
	// remove resource from list
	.delete(0, ResourceList, NewResourceList);
	-+diamondResources(NewResourceList);
	.
	
+! collectDiamond: true <-
	.print("Collecting resource");
	?diamondAtResource(AmountOfDiamond);
	rover.ia.check_config(Capacity, Scanrange, Resourcetype);
	// if more diamond left capacity then collect to max of capacity
	if (AmountOfDiamond > Capacity) {
		for(.range(X, 1, Capacity)) {
			collect("Diamond");
			.print("Collected diamond: ", X);
		}
		-+diamondAtResource(AmountOfDiamond - Capacity);
		-+diamondCollected(Capacity);
	// if less diamond than capacity then collect all leftover diamond
	} else {
		for(.range(X, 1, AmountOfDiamond)) {
			collect("Diamond");
			.print("Collected diamond: ", X);
		}
		-+diamondCollected(AmountOfDiamond);
		-+diamondAtResource(0);
	}
	.
	
-! collectDiamond: true <-
	.print("Error collecting diamond, returning to base");
	!returnToBase;
	.
		
+! returnToBase: true <-
	.print("Returning to base");
	?moveList(MoveList);
	.reverse(MoveList, ReversedMoveList);
	for (.member(CurrentMoveVector, ReversedMoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(-XVector, -YVector);
	}
	.
	
+! depositDiamond: true <-
	.print("Depositting diamond");
	?diamondCollected(DiamondCollected);
	for(.range(X, 1, DiamondCollected)) {
		deposit("Diamond");
	}
	-+diamondCollected(0);
	.

+! returnToDiamond: true <-
	.print("Returning to diamond");
	?moveList(MoveList);
	for (.member(CurrentMoveVector, MoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
	}
	.	

