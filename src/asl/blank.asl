// Agent blank in project ia_submission

/* Initial beliefs and rules */
goldCollected(0).
capacity(3).
distanceToBase(0, 0).
totalDistanceTravelled(0, 0).
numberOfTrips(0).


/* Initial goals */

! move_around.

/* Plans */

+! move_around: totalDistanceTravelled(TotalX, TotalY) <-
	scan(3);
	.print("Moving");
	rover.ia.get_map_size(Width, Height);
	// if moved all width and all height then return to base and chill
	if (Width <= TotalX + 3 & Height <= TotalY + 5) {
		!return_to_base;
	} 
	.print("TotalX: ", TotalX, ". TotalY: ", TotalY);
	// if moved all the width, then return to base and move up and repeat
	if (Width <= TotalX + 3) {
		!return_to_base;
		move(0, 5);
		rover.ia.log_movement(0, 5);
		-+totalDistanceTravelled(0, TotalY + 5);
	// move 3 right
	} else {
		move(3, 0);
		rover.ia.log_movement(3, 0);
		-+totalDistanceTravelled(TotalX + 3, TotalY);
	}
	!move_around;
	.

+! return_to_base: totalDistanceTravelled(TotalX, TotalY) <-
	.print("I am returning home");
	rover.ia.get_map_size(Width, Height);
	rover.ia.get_distance_from_base(XDist, YDist);
	if (TotalX > Width/2) {
		if (TotalY > Height/2) {
			move(Width - TotalX, Height - TotalY);
			-+distanceToGold(-(Width - TotalX), -(Height - TotalY));
		} else {
			move(Width - TotalX, YDist);
			-+distanceToGold(-(Width - TotalX), -YDist);
		}
	} else {
		if (TotalY > Height/2) {
			move(XDist, Height - TotalY);
			-+distanceToGold(-XDist, -(Height - TotalY));
		} else {
			move(XDist, YDist);
			-+distanceToGold(-XDist, -YDist);
		}
	}
	rover.ia.clear_movement_log;
	.

// if no resource found, do a print
+ resource_not_found: true <-
	.print("I found nothing, moving again");
	.
	
@resource_found[atomic]
+ resource_found(ResourceType, Quantity, XDist, YDist): capacity(TotalCapacity) <-
	.print("Resource found!");
	move(XDist, YDist);
	?totalDistanceTravelled(XDistance, YDistance);
	-+totalDistanceTravelled(XDistance + XDist, YDistance + YDist);
	rover.ia.log_movement(XDist, YDist);
	// round up quantity / capacity
	-+numberOfTrips(math.round(Quantity / TotalCapacity));
	?numberOfTrips(TotalTrips);
	if (TotalTrips < (Quantity / TotalCapacity)) {
		-+numberOfTrips(math.round(Quantity / TotalCapacity) + 1);
	}
	?numberOfTrips(TotalTrips2);
	for(.range(X, 1, TotalTrips2)) {
		// collect gold
		!goldCollect;
		// deposit gold and return
		!goldDeposit;
	}
	// if no gold found then move back to scan point and let movement continue
	move(-XDist, -YDist);
	-+totalDistanceTravelled(XDistance - XDist, YDistance - YDist);
	rover.ia.log_movement(-XDist, -YDist);
	.
	
+! goldCollect: true <-
	.print("Collecting gold now...");
	?capacity(TotalCapacity)
	for(.range(X, 1, TotalCapacity)) {
		collect("Gold");
		-+goldCollected(X);
		.print("Collected gold: ", X);
	}
	.
	
-! goldCollect: true <-
	.print("No more gold to collect");
	.
	
	// fix gold deposit/collect so if it wont try to collect/deposit 3 gold when there is only 1.
+! goldDeposit: true <-
	.print("Moving to base to deposit");
	!return_to_base;
	// deposit gold
	?goldCollected(TotalGoldCollected);
	for(.range(X, 1, TotalGoldCollected)) {
		deposit("Gold");
		.print("Depositted gold");
	}
	-+goldCollected(0);
	// return to gold
	.print("Returning to gold area");
	!return_to_gold;
	.
	
+! return_to_gold: distanceToGold(XDist, YDist) <-
	.print("Moving back to the gold");
	move(XDist, YDist);
	rover.ia.log_movement(XDist, YDist);
	.
	
+ invalid_action(ActionName, Reason) <-
	.print("Invalid action because ", Reason);
	.
	

	
	