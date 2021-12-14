// Agent agentCollectorGold in project ia_submission

/* Initial beliefs and rules */
goldResources([]).
goldCollected(0).
goldAtResource(0).
numberOfTrips(0).
currentPos(0, 0).
currentPlan(0).

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
	.kill_agent(agentCollectorGoldExtra);
	.

@resourceFound[atomic]
+! resourceFound: true <-
	?goldResources(ResourceList);
	// get current resource
	.nth(0, ResourceList, CurrentResource);
	.print("Its go time!");
	// find quantity of gold and update goldAtResource
	.nth(1, CurrentResource, GoldAmount);
	-+goldAtResource(GoldAmount);
	// go to resource
	!moveToResource;
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
			!moveToResource;
		}
	}
	// remove resource from list
	.delete(0, ResourceList, NewResourceList);
	-+goldResources(NewResourceList);
	.
	
+! moveToResource: true <- 
	-+currentPlan(1);
	.print("Moving to resource");
	?currentPos(XPos, YPos);
	?goldResources(ResourceList);
	.nth(0, ResourceList, CurrentResource);
	.nth(2, CurrentResource, XDistance);
	.nth(3, CurrentResource, YDistance);
	// use A* search to find route to gold
	ia_submission.findRoute(XPos, YPos, XDistance, YDistance, MoveList);
	.print(MoveList);
	for (.member(CurrentMoveVector, MoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
		?currentPos(NewXPos, NewYPos);
		-+currentPos(NewXPos + XVector, NewYPos + YVector);
	}
	.
	
-! moveToResource: true <-
	.print("Error moving to resource");
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
	-+currentPlan(0);
	// use A* search to return to base
	?currentPos(XPos, YPos);
	ia_submission.findRoute(XPos, YPos, 0, 0, MoveList);
	.print(MoveList);
	for (.member(CurrentMoveVector, MoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
		?currentPos(NewXPos, NewYPos);
		-+currentPos(NewXPos + XVector, NewYPos + YVector);
	}
	.

-! returnToBase: true <-
	.print("Error returning to base");
	.
	
+! depositGold: true <-
	.print("Depositting gold");
	?goldCollected(GoldCollected);
	for(.range(X, 1, GoldCollected)) {
		deposit("Gold");
	}
	-+goldCollected(0);
	.
	
@obstructed[atomic]
+ obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	// if obstructed by another agent then continue with plan
	.print("Agent obstructed during movement plan.");
	?currentPos(XPos, YPos);
	-+currentPos(XPos + XTravelled, YPos + YTravelled);
	// wait to let other agent catch up before continuing with movement
	.wait(1000);
	// recall plan
	?currentPlan(PlanToDo);
	if (PlanToDo == 0) {
		!returnToBase;
	} elif (PlanToDo == 1) {
		!moveToResource;
	}
	.
	
	
- obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	.print("Obstructed plan failed");
	.

