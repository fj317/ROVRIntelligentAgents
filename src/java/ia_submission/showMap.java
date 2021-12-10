// Internal action code for project ia_submission

package ia_submission;

import java.util.List;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class showMap extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
    		Handler.getInstance().printMap();  
            return true;          	
    	} catch (Exception e) {
    		System.out.println("Error printing map");
    		return false;
    	}
    }
}
