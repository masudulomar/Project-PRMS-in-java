/***************************************************************
* Payroll Management System for BHBFC						   *
* @author   Md. Rubel Talukder & Mosharraf Hossain Talukder	   *
* @division ICT Operation									   *
* @version  1.0												   *
* @date     Feb 10, 2019 									   *
****************************************************************/

package prmsValidators;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import prmsUtilities.DBUtils;

public class PRMSValidator {
	Map<String, String> ResultMap = new HashMap<String, String>();
	public PRMSValidator() {
		ResultMap.clear();
	}
	public Map<String, String> BranchKeyPress(Map DataMap) throws Exception {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		String sql = "select * from PRMS_MBRANCH t where t.brn_code=?";
		Connection con = ob.GetConnection();
		ResultSet rs=null;
		PreparedStatement stmt = null;
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("branch_code").toString());
			 rs = stmt.executeQuery();
			if (!rs.next()) {
				ResultMap.put("ERROR_MSG", "Branch Code does not Exists!");
			} else {
				ResultMap.put("BRN_NAME", rs.getString("BRN_NAME"));
				ResultMap.put("BRN_ADDRESS", rs.getString("BRN_ADDRESS"));
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				con.close();
				rs.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;
	}
	
	public Map<String, String> EmployeeIdValidation(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		String sql = "SELECT E.EMP_NAME, S.EMP_BRN_CODE || ' - '|| ( SELECT M.BRN_NAME FROM PRMS_MBRANCH M WHERE M.BRN_CODE = S.EMP_BRN_CODE) AS EMP_BRN_CODE, S.NEW_BASIC, S.DESIG" + "  FROM PRMS_EMP_SAL S"
				+ "  JOIN PRMS_EMPLOYEE E" + "    ON (S.EMP_ID = E.EMP_ID)" + " WHERE E.EMP_ID = ?";
		Connection con = ob.GetConnection();
		ResultSet rs=null;
		PreparedStatement stmt = null;
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("EmployeeId").toString());
			 rs = stmt.executeQuery();
			if (!rs.next()) {
				ResultMap.put("ERROR_MSG", "Employee Id not Found!");
			} else {
				ResultMap.put("NAME", rs.getString("EMP_NAME"));
				ResultMap.put("BRANCH_CODE", rs.getString("EMP_BRN_CODE"));
				ResultMap.put("BASIC_SAL", rs.getString("NEW_BASIC"));
				ResultMap.put("DESIGNATION", rs.getString("DESIG"));

			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				con.close();
				stmt.close();
				rs.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ResultMap;
	}
}
