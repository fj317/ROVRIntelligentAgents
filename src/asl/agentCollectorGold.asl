// Agent agentCollectorGold in project ia_submission

/* Initial beliefs and rules */
distanceToGold(0, 0).
goldResources([]).
goldCollected(0).
goldAtResource(0).
numberOfTrips(0).

/* Initial goals */

!checkForGold.

/* Plans */

+!checkForGold : true <- 
	// check if resource found
	.wait({+goldResources(GoldResourceList)});
	// for each member of GoldResourceList, run resourceFound
	for(.member(X, GoldResourceList)) {
		!resourceFound;
	}
	// once finished, kill agent
	.kill_agent(agentCollectorGold);
	.
	
@resourceFound[atomic]
+! resourceFound: true <-
	?goldResources(ResourceList);
	// get current resource
	.nth(0, ResourceList, CurrentResource);
	// find distance to gold and update distance to gold
	.nth(2, CurrentResource, XDistance);
	.nth(3, CurrentResource, YDistance);
	-+distanceToGold(XDistance, YDistance);
	.print("Its go time! Going to (", XDistance, ", ", YDistance, ")");
	// find quantity of gold and update goldAtResource
	.nth(1, CurrentResource, GoldAmount);
	-+goldAtResource(GoldAmount);
	// go to resource
	move(XDistance, YDistance);
	
	
	// work out how many trips to do
	// round up
	rover.ia.check_config(Capacity, Scanrange, Resourcetype);
	if (math.round(GoldAmount / Capacity) < (GoldAmount / Capacity)) {
		-+numberOfTrips(math.round(GoldAmount / Capacity) + 1);
	} else {
		-+numberOfTrips(math.round(GoldAmount / Capacity));
	}
	?numberOfTrips(TotalTrips);
	
	// collect resources, return to base & deposit and return to resource again
	for(.range(X, 1, TotalTrips)) {
		!collectGold;
		!returnToBase;
		!depositGold;
		// if last trip dont return to gold
		?goldAtResource(GoldLeft);
		if (GoldLeft > 0) {
			!returnToGold;
		}
	}
	// remove resource from list
	.delete(0, ResourceList, NewResourceList);
	-+goldResources(NewResourceList);
	.
	
+! collectGold: true <-
	.print("Collecting resource");
	?goldAtResource(AmountOfGold);
	rover.ia.check_config(Capacity, Scanrange, Resourcetype);
	// if more gold left capacity then collect to max of capacity
	if (AmountOfGold > Capacity) {
		for(.range(X, 1, Capacity)) {
			collect("Gold");
			.print("Collected gold: ", X);
		}
		-+goldAtResource(AmountOfGold - Capacity);
		-+goldCollected(Capacity);
	// if less gold than capacity then collect all leftover gold
	} else {
		for(.range(X, 1, AmountOfGold)) {
			collect("Gold");
			.print("Collected gold: ", X);
		}
		-+goldCollected(AmountOfGold);
		-+goldAtResource(0);
	}
	.
	
-! collectGold: true <-
	.print("Error collecting gold, returning to base");
	!returnToBase;
	.
		
+! returnToBase: true <-
	.print("Returning to base");
	?distanceToGold(XDist, YDist);
	move(-XDist, -YDist);
	.
	
+! depositGold: true <-
	.print("Depositting gold");
	?goldCollected(GoldCollected);
	for(.range(X, 1, GoldCollected)) {
		deposit("Gold");
	}
	-+goldCollected(0);
	.

+! returnToGold: true <-
	.print("Returning to gold");
	?distanceToGold(XDist, YDist);
	move(XDist, YDist);
	.	

