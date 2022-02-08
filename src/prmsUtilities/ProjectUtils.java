/***************************************************************
* Payroll Management System for BHBFC						   *
* @author   Md. Rubel Talukder & Mosharraf Hossain Talukder	   *
* @division ICT Operation									   *
* @version  1.0												   *
* @date     Feb 10, 2019 									   *
****************************************************************/

package prmsUtilities;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

public class ProjectUtils {	
	public static Map  DataTokenizer(String DataStream)
    {
    	StringTokenizer st = new StringTokenizer(DataStream, "$");
    	Map<String, String> map = new HashMap<String, String>();
    	while ( st.hasMoreElements() ) {

    	    String actualElement = st.nextToken();
    	    StringTokenizer et = new StringTokenizer(actualElement, "*");
    	    if ( et.countTokens() != 2 ) {
    	        throw new RuntimeException("Unexpeced format");
    	    }
    	    String key = et.nextToken();
    	    String value = et.nextToken();
    	    map.put(key, value);
    	}
    	return map;
    }  
}
