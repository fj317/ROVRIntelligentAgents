// Internal action code for project ia_submission

package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class removeTempObject extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
    		// getting args
        	int XPos = (int)((NumberTerm)args[0]).solve();
        	int YPos = (int)((NumberTerm)args[1]).solve();
        	Handler.getInstance().removeTempObject(XPos, YPos);
            return true;  
    	} catch (Exception e) {
    		System.out.println("Error removing temp object");
    		return false;
    	}
    }
}
