// Internal action code for adding obstacle
package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class addObstacle extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
        	int x = (int)((NumberTerm)args[0]).solve();
        	int y = (int)((NumberTerm)args[1]).solve();
        	Handler.getInstance().addObstacle(x, y);
        	return true;
    	} catch (Exception e) {
    		System.out.println("Error adding obstacle");
    		return false;
    	}
    }
}
