package ia_submission;

import java.util.*;

public class Handler {
	private static Handler instance = null;
	char[][] map;
	private int baseCoord[] = new int[2];
	
	private Handler() {
		// Exists only to defeat instantiation.
		//initialiseMap();
	}
	
	public static Handler getInstance() {
	      if(instance == null) {
	          instance = new Handler();
	       }
	       return instance;
	}
	
	// updates map with obstacle in correct location
	public void addObstacle(int obstacleX, int obstacleY) {
		// swap as the way coords are done by agent is different
		int actualObstacleCoordX = this.baseCoord[0] + obstacleY;
		int actualObstacleCoordY = this.baseCoord[1] + obstacleX;

		// base cords + obstacle cords = location 
		this.map[actualObstacleCoordX][actualObstacleCoordY] = 'O';
		printMap();
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