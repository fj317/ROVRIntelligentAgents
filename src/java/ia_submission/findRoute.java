package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;
import java.util.*;


public class findRoute extends DefaultInternalAction {
	
    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
    		// getting args
        	int startX = (int)((NumberTerm)args[0]).solve();
        	int startY = (int)((NumberTerm)args[1]).solve();
        	int endX = (int)((NumberTerm)args[2]).solve();
        	int endY = (int)((NumberTerm)args[3]).solve();
        	//System.out.println("Start x, y: " + startX + ", " + startY + ". End x, y: " + endX + ", " + endY);
            List<int[]> returnCoords = new ArrayList<int[]>();
            returnCoords = Handler.getInstance().getRoute(startX, startY, endX, endY);
            ListTerm listValues = (ListTerm)new ListTermImpl();
            // turn return coords into numberTerms
            for( int[] coords : returnCoords ) {
                final ListTerm coordsValues = (ListTerm)new ListTermImpl();
                coordsValues.append((NumberTerm)new NumberTermImpl((double)coords[0]));
                coordsValues.append((NumberTerm)new NumberTermImpl((double)coords[1]));
                listValues.append(coordsValues);
            }  
            return un.unifies((ListTerm)listValues, args[4]);  
    	} catch (Exception e) {
    		System.out.println("Error finding route");
    		return false;
    	}
    }
}
