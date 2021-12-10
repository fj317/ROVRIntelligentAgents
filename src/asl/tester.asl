// Agent tester in project ia_submission

/* Initial beliefs and rules */

list([]).
/* Initial goals */

!start.

/* Plans */

+!start : true <- 
	move(0, 4);
	.append()
	.
