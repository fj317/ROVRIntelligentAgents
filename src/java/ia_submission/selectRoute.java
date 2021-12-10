// Internal action code for adding obstacle
package ia_submission;

import java.util.List;

import jason.*;
import jason.asSemantics.*;
import jason.asSyntax.*;

public class selectRoute extends DefaultInternalAction {

    @Override
    public Object execute(TransitionSystem ts, Unifier un, Term[] args) throws Exception {
    	try {
        	int x = (int)((NumberTerm)args[0]).solve();
        	int y = (int)((NumberTerm)args[1]).solve();
        	int direction = (int)((NumberTerm)args[2]).solve();
        	List<int[]> movementVector = Handler.getInstance().selectRoute(x, y, direction);
            ListTerm listMovementVector = (ListTerm)new ListTermImpl();
            for( int[] coords : movementVector ) {
                final ListTerm coordsValues = (ListTerm)new ListTermImpl();
                coordsValues.append((NumberTerm)new NumberTermImpl((double)coords[0]));
                coordsValues.append((NumberTerm)new NumberTermImpl((double)coords[1]));
                listMovementVector.append(coordsValues);
            }  
            return un.unifies((ListTerm)listMovementVector, args[3]);          	
    	} catch (Exception e) {
    		System.out.println("Error selecting maze route");
    		return false;
    	}
    }
}
