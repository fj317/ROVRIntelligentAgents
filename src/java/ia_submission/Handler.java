package ia_submission;

import java.util.*;

public class Handler {
	private static Handler instance = null;
	char[][] map;
	private int baseCoord[] = new int[2];
	private a_star AStarObj;
	
	private Handler() {
		// Exists only to defeat instantiation.
		//initialiseMap();
		AStarObj = new a_star();
	}
	
	public static Handler getInstance() {
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
	
	// updates map with obstacle in correct location
	public void addObstacle(int obstacleX, int obstacleY) {
		// swap as the way coords are done by agent is different
		int actualObstacleCoordX = this.baseCoord[0] + obstacleX;
		int actualObstacleCoordY = this.baseCoord[1] + obstacleY;
		
		// deal with funny scan bug where it says distance is far away
		if (actualObstacleCoordX < 0) {
			actualObstacleCoordX += (this.baseCoord[0] * 2);
		}
		if (actualObstacleCoordY < 0) {
			actualObstacleCoordY += (this.baseCoord[1] * 2);
		}
		System.out.println("x, y: " + actualObstacleCoordX + ", " + actualObstacleCoordY);
		// base cords + obstacle cords = location 
		this.map[actualObstacleCoordY][actualObstacleCoordX] = 'O';
		printMap();
	}
	
	public List<int[]> getRoute(int startX, int startY, int endX, int endY) {
		AStarObj.init();
		// add base offset to start and end coords
		int actualStartCoordX = this.baseCoord[0] + startX;
		int actualStartCoordY = this.baseCoord[1] + startY;
		int actualEndCoordX = this.baseCoord[0] + endX;
		int actualEndCoordY = this.baseCoord[1] + endY;
    	System.out.println("Start (x, y): (" + actualStartCoordX + ", " + actualStartCoordY + "). End (x, y): (" + actualEndCoordX + ", " + actualEndCoordY + ").");
		List<int[]> moveCoords =  AStarObj.get_route(this.map, actualStartCoordX, actualStartCoordY, actualEndCoordX, actualEndCoordY);
		List<int[]> movementVector = new ArrayList<int[]>();
		// a* search returns coords of where to move, now translate to movement vectors
		movementVector.add(new int[] {moveCoords.get(0)[0] - actualStartCoordX, moveCoords.get(0)[1] - actualStartCoordY});
		for (int i = 1; i < moveCoords.size(); i++) {
			movementVector.add(new int[] {moveCoords.get(i)[0] - moveCoords.get(i-1)[0], moveCoords.get(i)[1] - moveCoords.get(i-1)[1]});
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
	public void initialiseMap(int width, int height) {
		this.map = new char[width][height];
		for (char[] row: map)
		    Arrays.fill(row, '_');
		this.baseCoord[0] = Math.round(width / 2);
		this.baseCoord[1] = Math.round(height / 2);
		this.map[this.baseCoord[0]][this.baseCoord[1]] = 'B';
	}
	
	private void printMap() {
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
	

	
}