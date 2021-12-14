// Internal action code for project ia_submission

package ia_submission;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class modFunction extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
        	int x = (int)((NumberTerm)args[0]).solve();
        	int y = (int)((NumberTerm)args[1]).solve();
        	int result = x % y;
        	return un.unifies(new NumberTermImpl(result), args[2]);
    	} catch (Exception e) {
    		System.out.println("Error modding");
    		return false;
    	}
    }
}
