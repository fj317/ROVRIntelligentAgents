// Internal action code for project ia_submission

package ia_submission;

import java.util.ArrayList;
import java.util.List;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class agentMovedUpdateMap extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
    		// getting args
        	int XPos = (int)((NumberTerm)args[0]).solve();
        	int YPos = (int)((NumberTerm)args[1]).solve();
        	int previousXPos = (int)((NumberTerm)args[0]).solve();
        	int previousYPos = (int)((NumberTerm)args[1]).solve();
        	Handler.getInstance().updateAgentLocation(XPos, YPos, previousXPos, previousYPos);
            return true;  
    	} catch (Exception e) {
    		System.out.println("Error updating map with agent position");
    		return false;
    	}
    }
}
