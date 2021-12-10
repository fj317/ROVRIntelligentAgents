// Agent agentCollectorDiamond in project ia_submission

/* Initial beliefs and rules */
diamondResources([]).
diamondCollected(0).
diamondAtResource(0).
numberOfTrips(0).
currentPos(0, 0).
currentPlan(0).

/* Initial goals */

!checkForDiamond.

/* Plans */

+!checkForDiamond : true <- 
	// check if resource found
	.wait({+diamondResources(DiamondResourceList)});
	// wait 10 sec before starting
	.wait(10000);
	// for each member of DiamondResourceList, run resourceFound
	for(.member(X, DiamondResourceList)) {
		!resourceFound;
	}
	// once finished, kill agent
	.kill_agent(agentCollectorDiamondExtra);
	.

@resourceFound[atomic]
+! resourceFound: true <-
	?diamondResources(ResourceList);
	// get current resource
	.nth(0, ResourceList, CurrentResource);
	.print("Its go time!");
	// find quantity of diamond and update diamondAtResource
	.nth(1, CurrentResource, DiamondAmount);
	-+diamondAtResource(DiamondAmount);
	// go to resource
	!moveToResource;
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
			!moveToResource;
		}
	}
	// remove resource from list
	.delete(0, ResourceList, NewResourceList);
	-+diamondResources(NewResourceList);
	.
	
+! moveToResource: true <- 
	-+currentPlan(1);
	.print("Moving to resource");
	?currentPos(XPos, YPos);
	?diamondResources(ResourceList);
	.nth(0, ResourceList, CurrentResource);
	.nth(2, CurrentResource, XDistance);
	.nth(3, CurrentResource, YDistance);
	// use A* search to find route to diamond
	ia_submission.findRoute(XPos, YPos, XDistance, YDistance, MoveList);
	.print(MoveList);
	for (.member(CurrentMoveVector, MoveList)) {
		.nth(0, CurrentMoveVector, XVector);
		.nth(1, CurrentMoveVector, YVector);
		move(XVector, YVector);
		?currentPos(NewXPos, NewYPos);
		-+currentPos(NewXPos + XVector, NewYPos + YVector);
		ia_submission.agentMovedUpdateMap(NewXPos + XVector, NewYPos + YVector, NewXPos, NewXPos)
	}
	.
	
-! moveToResource: true <-
	.print("Error moving to resource");
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
	
+! depositDiamond: true <-
	.print("Depositting diamond");
	?diamondCollected(DiamondCollected);
	for(.range(X, 1, DiamondCollected)) {
		deposit("Diamond");
	}
	-+diamondCollected(0);
	.
	
@obstructed[atomic]
+ obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	// if obstructed by another agent then continue with plan
	.print("Agent obstructed during movement plan.");
	?currentPos(XPos, YPos);
	-+currentPos(XPos + XTravelled, YPos + YTravelled);
	ia_submission.addTempObject(XPos + XTravelled, YPos + YTravelled, XPos, YPos)
	// wait to let other agent move 
	.wait(11000);
	// recall plan
	?currentPlan(PlanToDo);
	if (PlanToDo == 0) {
		!returnToBase;
	} elif (PlanToDo == 1) {
		!moveToResource;
	}
	ia_submission.removeTempObject(XPos + XTravelled, YPos + YTravelled)
	.
	
	
- obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	.print("Obstructed plan failed");
	.

