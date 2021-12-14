package ia_submission;

import java.util.*;

public class Handler {
	private static Handler instance = null;
	char[][] map;
	private int baseCoord[] = new int[2];
	private a_star AStarObj;
	// stack items are array in format (x, y, directionValue)
	private List<int[]> routes;
	
	private Handler() {
		// Exists only to defeat instantiation.
		AStarObj = new a_star();
		routes = new ArrayList<int[]>();
	}
	
	// synchronised to avoid parallel issues
	public synchronized static Handler getInstance() {
	      if(instance == null) {
	          instance = new Handler();
	       }
	       return instance;
	}
	
	// gets the maps height
	public int getHeight() {
		return this.map.length;
	}
	
	// get maps width
	public int getWidth() {
		return this.map[0].length;
	}
	
	public List<int[]> selectRoute(int XPos, int YPos, int direction) {
		// add base coord to offset
		// modulo to allow agent to wrap around to beginning of array
		// add width & height to avoid weird wrapping coord bugs
		XPos = (XPos + baseCoord[0] + getWidth()) % getWidth();
		YPos = (YPos + baseCoord[1] + getHeight()) % getHeight();
		
		// directions:
		// 1 = up
		// 2 = down
		// 3 = right
		// 4 = left
		// 0 = null
		System.out.println("selectRoute - current pos x, y: " + XPos + ", " + YPos);
		// check if more than 2 _'s (if so then there are multiple routes)
		int routeCount = 0;
		boolean leftEmpty = false;
		boolean rightEmpty = false;
		boolean upEmpty = false;
		boolean downEmpty = false;
		
		List<int[]> movementVector = new ArrayList<int[]>();
		// add 0, 0 movement so list.set command works 
		movementVector.add(new int[] {0, 0});
		
		// look left for empty
		// modulo again as adding/minusing might mess up
		// when minusing, add width/height to avoid negative numbers
		if (this.map[YPos % getWidth()][(XPos-1+getWidth()) % getHeight()] == '_') {
			leftEmpty = true;
			routeCount++;
		// look right for empty
		} if (this.map[YPos % getWidth()][(XPos+1) % getHeight()] == '_') {
			rightEmpty = true;
			routeCount++;
		// look up for empty
		} if (this.map[(YPos-1+getHeight()) % getWidth()][XPos % getHeight()] == '_') {
			upEmpty = true;
			routeCount++;
		// look down for empty
		} if (this.map[(YPos+1) % getWidth()][XPos % getHeight()] == '_') {
			downEmpty = true;
			routeCount++;
		} 
		// if more than 2 routes
		if (routeCount > 2 || (XPos == this.baseCoord[0] && YPos == this.baseCoord[1])) {
			System.out.println("Multiple routes to choose");
			// find opposite direction
			int oppositePreviousDirection = 0;
			if (direction == 1) {
				oppositePreviousDirection = 2;
			} else if (direction == 2) {
				oppositePreviousDirection = 1;
			} else if (direction == 3) {
				oppositePreviousDirection = 4;
			} else if (direction == 4) {
				oppositePreviousDirection = 3;
			}
			for (int i = 1; i < 5; i++) {
				// check if route already in stack
				//System.out.println("Checking route stack for current pos");
				if (this.routes.contains(new int[] {XPos, YPos, i})) {
					// if already present in route stack, remove both routes from stack
					this.routes.remove(new int[] {XPos, YPos, i});
					this.routes.remove(new int[] {XPos, YPos, oppositePreviousDirection});
					// use a* search to go to previous coords
					AStarObj.init();
					List<int[]> moveCoords =  AStarObj.get_route(this.map, XPos, YPos, this.routes.get(this.routes.size() -1)[0], this.routes.get(this.routes.size() -1)[1]);
					// a* search returns coords of where to move, now translate to movement vectors
					movementVector.add(new int[] {moveCoords.get(0)[0] - XPos, moveCoords.get(0)[1] - YPos});
					for (int j = 1; j < moveCoords.size(); j++) {
						movementVector.add(new int[] {moveCoords.get(j)[0] - moveCoords.get(j-1)[0], moveCoords.get(j)[1] - moveCoords.get(j-1)[1]});
					}
					// return movementVector that is used to backtrack to previous (coords, direction) in stack
					printRoutes();
					return movementVector;
				}
			}
			System.out.println("Adding routes to stack");
			// otherwise add (coords, direction) tuples to stack
			if (leftEmpty && direction != 3) {
				this.routes.add(new int[] {XPos, YPos, 4});
				movementVector.set(0, new int[] {-1 ,0});
			} if (rightEmpty && direction != 4) {
				this.routes.add(new int[] {XPos, YPos, 3});
				movementVector.set(0, new int[] {1 ,0});
			} if (upEmpty && direction != 2) {
				this.routes.add(new int[] {XPos, YPos, 1});
				movementVector.set(0, new int[] {0 ,-1});
			} if (downEmpty && direction != 1) {
				this.routes.add(new int[] {XPos, YPos, 2});
				movementVector.set(0, new int[] {0, 1});
			}
			// choose whatever the last route added
			//printRoutes();
			return movementVector;
		}
		System.out.println("Choosing direction");
		// if agent previously went one direction, then dont go undo progress
		if (direction == 1) {
			// look left for empty
			if (leftEmpty) {
				movementVector.add(new int[] {-1, 0});
			// look right for empty
			} else if (rightEmpty) {
				movementVector.add(new int[] {1, 0});
			// look up for empty
			} else if (upEmpty) {
				movementVector.add(new int[] {0, -1});
			} else {
				// if hit dead end
				movementVector = hitDeadend(movementVector, XPos, YPos);
			}
		} else if (direction == 2) {
			if (leftEmpty) {
				movementVector.add(new int[] {-1, 0});
			} else if (rightEmpty) {
				movementVector.add(new int[] {1, 0});
			} else if (downEmpty) {
				movementVector.add(new int[] {0, 1});
			} else {
				// if hit dead end
				movementVector = hitDeadend(movementVector, XPos, YPos);
			}
		} else if (direction == 3) {
			if (rightEmpty) {
				movementVector.add(new int[] {1, 0});
			} else if (downEmpty) {
				movementVector.add(new int[] {0, 1});
			} else if (upEmpty) {
				movementVector.add(new int[] {0, -1});
			} else {
				// if hit dead end
				movementVector = hitDeadend(movementVector, XPos, YPos);
			}
		} else if (direction == 4) {
			if (downEmpty) {
				movementVector.add(new int[] {0, 1});
			} else if (leftEmpty) {
				movementVector.add(new int[] {-1, 0});
			} else if (upEmpty) {
				movementVector.add(new int[] {0, -1});
			} else {
				// if hit dead end
				movementVector = hitDeadend(movementVector, XPos, YPos);
			}
		// if no direction taken yet, then look at map and go any space
		} else if (direction == 0) {
			// look left for empty
			if (leftEmpty) {
				movementVector.add(new int[] {-1, 0});
			// look right for empty
			} else if (rightEmpty) {
				movementVector.add(new int[] {1, 0});
			// look up for empty
			} else if (upEmpty) {
				movementVector.add(new int[] {0, -1});
			// look down for empty
			} else if (downEmpty) {
				movementVector.add(new int[] {0, 1});
			}
		}
		// in case error return nothing
		return movementVector;
	}
	
	private List<int[]> hitDeadend(List<int[]> movementVector, int XPos, int YPos) {
		System.out.println("Deadend hit.");
		// pop route
		this.routes.remove(this.routes.size() - 1);
		// use A* search to go back to stack point in stack
		AStarObj.init();
		List<int[]> moveCoords =  AStarObj.get_route(this.map, XPos, YPos, this.routes.get(this.routes.size() -1)[0], this.routes.get(this.routes.size() -1)[1]);
		// mod by width to avoid weird errors due to map wrapping
		movementVector.add(new int[] {(moveCoords.get(0)[0] - XPos) % getWidth(), (moveCoords.get(0)[1] - YPos) % getHeight()});
		for (int j = 1; j < moveCoords.size(); j++) {
			movementVector.add(new int[] {moveCoords.get(j)[0] - moveCoords.get(j-1)[0], moveCoords.get(j)[1] - moveCoords.get(j-1)[1]});
		}
		// choose next route in stack
		// if next route is up add to movementVector
		if (this.routes.get(this.routes.size() -1)[2] == 1) {
			movementVector.add(new int[] {0, -1});
		} else if (this.routes.get(this.routes.size() -1)[2] == 2) {
			movementVector.add(new int[] {0, 1});
		} else if (this.routes.get(this.routes.size() -1)[2] == 3) {
			movementVector.add(new int[] {1, 0});
		} else if (this.routes.get(this.routes.size() -1)[2] == 4) {
			movementVector.add(new int[] {-1, 0});
		}
		return movementVector;
	}

	
	// updates map with obstacle in correct location
	public synchronized void addObstacle(int obstacleX, int obstacleY) {
		// swap as the way coords are done by agent is different
		int actualObstacleCoordX = convertCoords(obstacleX, 0);
		int actualObstacleCoordY = convertCoords(obstacleY, 1);
		System.out.println("Obstacle @ x, y: " + actualObstacleCoordX + ", " + actualObstacleCoordY);
		// base cords + obstacle cords = location 
		this.map[actualObstacleCoordY][actualObstacleCoordX] = 'O';
		//printMap();
	}
	
	public synchronized List<int[]> getRoute(int startX, int startY, int endX, int endY) {
		AStarObj.init();
    	//System.out.println("Start (x, y): (" + startX + ", " + startY + "). End (x, y): (" + endX + ", " + endY + ").");
		// add base offset to start and end coords
		int actualStartCoordX = convertCoords(startX, 0);
		int actualStartCoordY = convertCoords(startY, 1);
		int actualEndCoordX = convertCoords(endX, 0);
		int actualEndCoordY = convertCoords(endY, 1);
    	System.out.println("Start (x, y): (" + actualStartCoordX + ", " + actualStartCoordY + "). End (x, y): (" + actualEndCoordX + ", " + actualEndCoordY + ").");
		List<int[]> moveCoords =  AStarObj.get_route(this.map, actualStartCoordX, actualStartCoordY, actualEndCoordX, actualEndCoordY);
		List<int[]> movementVector = new ArrayList<int[]>();
		//printList(moveCoords);
		// set start coords to width/height if they are 0 & next coord is greater than half of map, deal with wrapping issues
		if (actualStartCoordX == 0 && moveCoords.get(0)[0] > this.baseCoord[0]) {
			actualStartCoordX = getWidth();
		} if (actualStartCoordY == 0 && moveCoords.get(0)[1] > this.baseCoord[1]) {
			actualStartCoordY = getHeight();
		}
		// a* search returns coords of where to move, now translate to movement vectors
		int xValue = moveCoords.get(0)[0] - actualStartCoordX;
		int yValue = moveCoords.get(0)[1] - actualStartCoordY;
		if (xValue > this.baseCoord[0]) {
			xValue -= getWidth();
		} else if (xValue < -this.baseCoord[0]) {
			xValue += getWidth();
		} if (yValue > this.baseCoord[1]) {
			yValue -= getHeight();
		} else if (yValue < -this.baseCoord[1]) {
			yValue += getHeight();
		}
		movementVector.add(new int[] {xValue, yValue});
		for (int i = 1; i < moveCoords.size(); i++) {
			xValue = moveCoords.get(i)[0] - moveCoords.get(i-1)[0];
			yValue = moveCoords.get(i)[1] - moveCoords.get(i-1)[1];
			if (xValue > this.baseCoord[0]) {
				xValue -= getWidth();
			} else if (xValue < -this.baseCoord[0]) {
				xValue += getWidth();
			} if (yValue > this.baseCoord[1]) {
				yValue -= getHeight();
			} else if (yValue < -this.baseCoord[1]) {
				yValue += getHeight();
			}
			movementVector.add(new int[] {xValue, yValue});
		}
		return movementVector;
	}
	
	// initialises the map to empty squares
	// _ = empty
	// O = obstacle
	// D = diamond
	// G = gold
	// A = agent
	// B = base
	public synchronized void initialiseMap(int width, int height) {
		this.map = new char[width][height];
		for (char[] row: map)
		    Arrays.fill(row, '_');
		this.baseCoord[0] = Math.round(width / 2);
		this.baseCoord[1] = Math.round(height / 2);
		this.map[this.baseCoord[0]][this.baseCoord[1]] = 'B';
	}
	
	public void addTempObject(int XPos, int YPos) {
		XPos = convertCoords(XPos, 0);
		YPos = convertCoords(YPos, 1);
		this.map[XPos][YPos] = 'O';
	}
	
	public void removeTempObject(int XPos, int YPos) {
		XPos = convertCoords(XPos, 0);
		YPos = convertCoords(YPos, 1);
		this.map[XPos][YPos] = '_';
	}
	
	public int convertCoords(int coord, int XOrY) {
		int finalCoord = coord;
		// 0 is x coord, 1 is y coord
		if (XOrY == 0) {
			finalCoord = (this.baseCoord[0] + coord) % getWidth();
			// if negative add width
			if (finalCoord < 0) {
				finalCoord += getWidth();
			}
		} else if (XOrY == 1) {
			finalCoord = (this.baseCoord[1] + coord) % getHeight();
			if (finalCoord < 0) {
				finalCoord += getHeight();
			}
		}
		return finalCoord;
	}
	
	public void printMap() {
		for (char[] x : this.map)
		{
		   for (char y : x)
		   {
		        System.out.print(y + " ");
		   }
		   System.out.println();
		}	
		System.out.println();
		System.out.println();
	}
	
	
	private void printRoutes() {
		for (int i = 0; i < this.routes.size(); i++ ) {
			System.out.println("x, y: " + this.routes.get(i)[0] + ", " + this.routes.get(i)[1] + ". Direction: " + this.routes.get(i)[2]);
		}
	}
	
	private void printList(List<int[]> list) {
		for (int[] x : list)
		{
		   for (int y : x)
		   {
		        System.out.print(y + ", ");
		   }
		   System.out.println();
		}	
		
	}

	
}