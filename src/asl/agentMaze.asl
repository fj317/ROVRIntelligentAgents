// Agent agentMaze in project ia_submission

!initialise.

+!initialise: true <-
	.print("Initialising stuff");
	rover.ia.get_map_size(Width, Height);
	ia_submission.mapSetup(Width, Height);
	!scan_movement
	.

+!scan_movement: true <-
	.print("Scanning and stuff");
	.

	
// scan
// move into space
// if two routes available, add coords to list and go down one route
// continue until route finished
// if resource found at any point, add it to resource list
// once all maze explored, go to exit and escape
// send resource list to agents
// let them go out and collect resources
// beuno
