// Internal action code for adding obstacle
package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class mapSetup extends DefaultInternalAction {
	

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
        	int width = (int)((NumberTerm)args[0]).solve();
        	int height = (int)((NumberTerm)args[1]).solve();
        	Handler.getInstance().initialiseMap(width, height);
        	return true;
    	} catch (Exception e) {
    		System.out.println("Error creating map");
    		return false;
    	}
    }
}
