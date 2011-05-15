package parser;

import java.io.*;
import java.util.List;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.Tree;

public class testhql {
    public static void main(String[] args) throws Exception {
        // create a CharStream that reads from standard input
        ANTLRInputStream input = new ANTLRInputStream(System.in);

        // create a lexer that feeds off of input CharStream
        HQLLexer lexer = new HQLLexer(input);

        // create a buffer of tokens pulled from the lexer
        CommonTokenStream tokens = new CommonTokenStream(lexer);

        // create a parser that feeds off the tokens buffer
        HQLParser parser = new HQLParser(tokens);
        
        HQLParser.start_rule_return r = parser.start_rule();
        
        CommonTree t = ((CommonTree)r.getTree());
        
        //System.out.println(t.toStringTree());
        testhql tTest = new testhql();
        
        PrintStream stdout = System.out;
        // overwrite file
        OutputStream output = new FileOutputStream("C:\\Users\\mikem\\workspace\\HQL\\src\\out.txt", false);
        PrintStream printOut = new PrintStream(output);
        
        boolean bFileOut = false;
        if(bFileOut)
        {
	        System.setOut(printOut);
              
	        System.out.println(tTest.toStringTree(t));
	        
	        System.out.flush();
	        output.close();
	        System.setOut(stdout);

	        System.out.println("End of file output");
        }
        else
	        System.out.println(tTest.toStringTree(t));
    }

	public String toStringTree(CommonTree tTree) {
		List<Tree> children = tTree.getChildren(); 
		if ( children==null || children.size()==0 ) {
		         return tTree.toString();
		 }
		 StringBuffer buf = new StringBuffer();
		 if ( !tTree.isNil() ) {
		         buf.append("(");
		         buf.append(tTree.toString());
		         buf.append(' ');
		 }
		 for (int i = 0; children!=null && i < children.size(); i++) {
		         Tree t = children.get(i);
		         if ( i>0 ) {
		                 buf.append(' ');
		         }
		         buf.append(t.toStringTree());
		 }
		 if ( !tTree.isNil() ) {
		         buf.append(")");
		 }
		 return buf.toString();
	}

}
