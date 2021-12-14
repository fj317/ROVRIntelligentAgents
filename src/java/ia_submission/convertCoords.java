// Internal action code for project ia_submission

package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class convertCoords extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
        	int number = (int)((NumberTerm)args[0]).solve();
        	int XorY = (int)((NumberTerm)args[1]).solve();
        	number = Handler.getInstance().convertCoords(number, XorY);
        	return un.unifies(new NumberTermImpl(number), args[2]);
    	} catch (Exception e) {
    		System.out.println("Error converting coord");
    		return false;
    	}
    }
}
