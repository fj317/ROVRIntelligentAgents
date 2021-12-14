# Intelligent Agents

This work involves using agents called rovers to pickup resources around a map and return them to a base location. Each rover has a range of actions that it can take to help complete this objective: move, scan, pickup, deposit. Each rover also has an energy amount that decreases whenever an action is completed.
There are 6 different scenarios, ranging in difficulty from simply picking up gold and returning it to a base, to more complicated cases of picking up gold and diamonds while also navigating around obstacles and other agents. A description of each scenario is given below:

## Scenario 1
This scenario is very basic, with a single agent moving around a map picking up gold. This scenario has no specific agent made for it as it is so simple.

## Scenario 2
This scenario is slightly more complex. It uses a similar map to scenario 1, however the energy for the agents has been reduced. This scenario uses 2 agents - a scanner agent that moves across the whole map scanning finding any resources. The agent moves across the whole row, before moving down and repeating this process on the next row. Once it has travelled across the whole map, or runs out of energy, it sends the scanned resources to a collector agent. This agent then heads directly to each resource, picking it up, returning to the base and depositting it. This continues for every resource until all are collected.
![Scenario2](https://github.com/fj317/ROVRIntelligentAgents/blob/main/images/Scenario2.png?raw=true)

## Scenario 3
This scenario includes both gold and diamond now. The same method as scenario 2 is applied here, with a scanner agent finding all resources and sending them to two collector agents. There are two collector agents - one for gold and one for diamond. This means all resources can be picked up and collected. 
![Scenario3](https://github.com/fj317/ROVRIntelligentAgents/blob/main/images/Scenario3.png?raw=true)

## Scenario 4
This is similar to scenario 3, however obstacles have now been added to the map. To deal with these obstacles, the agents use an A* search algorithm to find the best route around each obstacle. Each obstacle is marked on an internal map that is used for navigation purposes. An additional scanner is used due to the larger map size.  
![Scenario4](https://github.com/fj317/ROVRIntelligentAgents/blob/main/images/Scenario4.png?raw=true)

## Scenario 5
This is a different scenario to all previous ones. This scenario uses obstacles to mimic a maze with the objective of each agent going through the maze and finding a resource before collecting it and finding the exit. An agent is provided for this scenario, however it does not function correctly and can break due to errors. 
![Scenario5](https://github.com/fj317/ROVRIntelligentAgents/blob/main/images/Scenario5.png?raw=true)

## Scenario 6
This scenario is similar to scenario 4, however is based upon competing with other agents. The idea is that 2 agents are used to compete against 18 other agents and the agents with the most resources collected are the winners. Unlike previous implementations, the agents for this scenario use a random movement system (rather than a linear one that covers all the map).
![Scenario6](https://github.com/fj317/ROVRIntelligentAgents/blob/main/images/Scenario6.png?raw=true)

## To Run
To run the project, one must download the Jason plugin. Follow the steps [here](http://jason.sourceforge.net/mini-tutorial/getting-started/) to install and run Jason.
