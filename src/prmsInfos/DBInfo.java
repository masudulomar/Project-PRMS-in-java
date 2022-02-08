/***************************************************************
* Payroll Management System for BHBFC						   *
* @author   Md. Rubel Talukder & Mosharraf Hossain Talukder	   *
* @division ICT Operation									   *
* @version  1.0												   *
* @date     Feb 10, 2019 									   *
****************************************************************/

package prmsInfos;

public class DBInfo {
	public static final String _DBUSER="prmsbhbfc";
	public static final String _DBPASS="prmsbhbfc";
	public static final String _DBURL="jdbc:oracle:thin:@127.0.0.1:1521:PRMS";
	public static final String _DBCLASS="oracle.jdbc.OracleDriver";		
	/*
	  Class.forName("oracle.jdbc.driver.OracleDriver");  
      Class.forName(DBInfo._DBCLASS);
      con = DriverManager.getConnection( DBInfo._DBURL, DBInfo._DBUSER,DBInfo._DBPASS);	           	          

	*/
}
