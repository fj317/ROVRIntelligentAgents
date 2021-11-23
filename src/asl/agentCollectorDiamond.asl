// Agent agentCollectorDiamond in project ia_submission

/* Initial beliefs and rules */
distanceToDiamond(0, 0).
diamondResources([]).
diamondCollected(0).
diamondAtResource(0).
numberOfTrips(0).

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
	.nth(2, CurrentResource, XDistance);
	.nth(3, CurrentResource, YDistance);
	-+distanceToDiamond(XDistance, YDistance);
	.print("Its go time! Going to (", XDistance, ", ", YDistance, ")");
	// find quantity of diamond and update diamondAtResource
	.nth(1, CurrentResource, DiamondAmount);
	-+diamondAtResource(DiamondAmount);
	// go to resource
	move(XDistance, YDistance);
	
	
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
	?distanceToDiamond(XDist, YDist);
	move(-XDist, -YDist);
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
	?distanceToDiamond(XDist, YDist);
	move(XDist, YDist);
	.	

