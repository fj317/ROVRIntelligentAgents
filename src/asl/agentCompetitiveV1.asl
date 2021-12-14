totalMovement(0, 0).
goalCoords([]).
amountAtResource(0).
typeOfResource("NA").
resourceCollected(0).
atResource(false).
resources([]).



!initialise.

+!initialise: true <-
	.print("Initialising stuff");
	rover.ia.get_map_size(Width, Height);
	ia_submission.mapSetup(Width, Height);
	!scanMovement
	.
	
+!generalMovement: true <-
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
	// remove goal coord from list
	.delete(GoalCoordsLength-1, GoalCoords, NewGoalCoords);
	-+goalCoords(NewGoalCoords);
	!scanMovement
	.
	
-! generalMovement: true <-
	.print("General move plan error");
	.
	
+!scanMovement: true <-
	?resourceCollected(AmountOfResource);	
	?totalMovement(XPos, YPos);
	?atResource(AtResource);
	?goalCoords(GoalCoords);
	?resources(ResourceList);
	if (AtResource) {
		// if at the resource, collect and queue return to base action
		!collectResource;
		.concat(GoalCoords, [[0, 0]], NewGoalCoords);
		-+atResource(false);
	} elif (not(.empty(ResourceList))) {
		// if resource in resource list
		.nth(0, ResourceList, ResourceXPos)
		.nth(1, ResourceList, ResourceYPos)
		.nth(2, ResourceList, Quantity)	
		.concat(GoalCoords, [[ResourceXPos, ResourceYPos]], NewGoalCoords);
		-+amountAtResource(Quantity);
		-+atResource(true);
		// reset list
		-+resources([]);
	} else {
		rover.ia.get_map_size(Width, Height);
		ia_submission.modFunction(XPos, Width, NewXPos);
		ia_submission.modFunction(YPos, Height, NewYPos);		
		if (AmountOfResource > 0 & NewXPos == 0 & NewYPos == 0) {
		// if at base and carrying resources, deposit resources
			!depositResources;
		} else {
			// do scan
			scan(3);
		}
		// choose random direction to go and head towards it (-10 to 10)
		RandomX = math.round(math.random(10));
		RandomY = math.round(math.random(10));
		.print("Random coords chosen (x, y): ", RandomX, ", ", RandomY);
		// goal is currentPos + randomPos
		.concat(GoalCoords, [[XPos + RandomX, YPos + RandomY]], NewGoalCoords);
	}
	-+goalCoords(NewGoalCoords);
	!generalMovement;
	.
	
-!scanMovement: true <-
	.print("ScanMovement plan error");
	!scanMovement;
	.
	

+ obstructed(XTravelled, YTravelled, XLeft, YLeft): true <-
	.print("Agent obstructed");
	// work out correct X & Y distance from base
	?totalMovement(TotalXDist, TotalYDist);
	XDistance = TotalXDist + XTravelled;
	YDistance = TotalYDist + YTravelled;
	// update TotalX and TotalY
	-+totalMovement(XDistance, YDistance);
	
	// move a random direction away 
	RandomX = math.round(math.random(3));
	RandomY = math.round(math.random(3));
	?goalCoords(GoalCoords);
	.concat(GoalCoords, [[XPos + RandomX, YPos + RandomY]], NewGoalCoords);
	-+goalCoords(NewGoalCoords);
	
	// do a scan to see surroundings
	scan(3);
	!generalMovement;
	.
	
@resource_found[atomic]
+ resource_found(ResourceType, Quantity, XDistToResource, YDistToResource): true <-
	?totalMovement(XPos, YPos);
	if (ResourceType == "Obstacle") {
		.print("Obstacle found");
		// add obstacle to map
		ia_submission.addObstacle(XPos + XDistToResource, YPos + YDistToResource);
	} else {
		.print("Resource found")
		?goalCoords(GoalCoords);
		// queue movement to resource
		-+amountAtResource(Quantity);
		?typeOfResource(AgentResourceType);
		// if agent unassigned
		if (AgentResourceType = "NA") {
			-+typeOfResource(ResourceType);
			// send other agent opposite resourceType
			if (ResourceType == "Gold") {
				.send(agentCompetitiveV2, tell, typeOfResource("Diamond"));
			} elif (ResourceType == "Diamond") {
				.send(agentCompetitiveV2, tell, typeOfResource("Gold"));
			}
		}
		?typeOfResource(NewAgentResourceType)
		if (ResourceType == NewAgentResourceType) {
			.concat(GoalCoords, [[XPos + XDistToResource, YPos + YDistToResource]], NewGoalCoords);
			-+atResource(true);
			-+goalCoords(NewGoalCoords);
			.drop_all_intentions;		
			!generalMovement;
		} else {
			.print("Different resource type to current agent, sending to other agent");
			// tell other agent the coords and quantity of resource
			.send(agentCompetitiveV2, tell, resources([XPos + XDistToResource, YPos + YDistToResource, Quantity]));
		}
	}
	.
	
+! collectResource: true <-
	.print("Collecting resource");
	?amountAtResource(AmountOfResource);
	?typeOfResource(ResourceType);
	rover.ia.check_config(Capacity, Scanrange, Resourcetype);
	// if more gold left capacity then collect to max of capacity
	if (AmountOfResource > Capacity) {
		for(.range(X, 1, Capacity)) {
			collect(ResourceType);
		}
		-+amountAtResource(AmountOfResource - Capacity);
		-+resourceCollected(Capacity);
	// if less gold than capacity then collect all leftover gold
	} else {
		for(.range(X, 1, AmountOfResource)) {
			collect(ResourceType);
		}
		-+resourceCollected(AmountOfResource);
		-+amountAtResource(0);
	}
	.

+! depositResources: true <-
	.print("Depositting resources");
	?typeOfResource(ResourceType);
	?resourceCollected(AmountOfResource);
	for(.range(X, 1, AmountOfResource)) {
		deposit(ResourceType);
	}
	-+resourceCollected(0);
	.
	
	
	
	
	
	
	
	
	
	
	