package prmsValidators;

import java.io.File;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

//import javax.mail.MessagingException;
//import javax.mail.internet.AddressException;

import net.sf.jasperreports.engine.JasperRunManager;
import prmsInfos.CommonInfo;
import prmsUtilities.AESEncrypt;
import prmsUtilities.BulkMailService;
import prmsUtilities.DBUtils;
import prmsUtilities.AESEncrypt;


public class SuperOperation {
	Map<String, String> ResultMap = new HashMap<String, String>();
	private static String secretKey = "DarkHorse";
	
	public SuperOperation() {
		ResultMap.clear();
	}
	public Map<String, String> CreateUser(Map DataMap) throws Exception {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		String UserId = DataMap.get("UserRole").toString() + DataMap.get("branch_code").toString();
		String sql = "INSERT INTO PRMS_USER (USER_ID ,USER_NAME,USER_PASSWORD,USER_BRANCH,USER_ROLE,ENTD_BY)  VALUES(?,?,?,?,?,?) ";
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, UserId);
			stmt.setString(2, DataMap.get("Branch_name").toString());
			stmt.setString(3, AESEncrypt.encrypt(DataMap.get("Password").toString(), secretKey));
			stmt.setString(4, DataMap.get("branch_code").toString());
			stmt.setString(5, DataMap.get("UserRole").toString());
			stmt.setString(6, "BHBFC");
			int res = stmt.executeUpdate();
			if (res == 1) {
				ResultMap.put("SUCCESS", " User Id : " + UserId + "\n Data Sucessfully Updated");
			} else {
				ResultMap.put("ERROR_MSG", "Data Not Updated");
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				con.close();
				stmt.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;
	}

	public Map<String, String> InitProcess(Map DataMap) throws Exception {
		DBUtils ob = new DBUtils();
		Connection con = null;
		CallableStatement cstmt = null;
		ResultMap.put("ERROR_MSG", "");
		try {
			con = ob.GetConnection();
			cstmt = con.prepareCall("CALL PKG_PRMS.SP_INIT_VALUES(?)");
			cstmt.registerOutParameter(1, java.sql.Types.VARCHAR);
			cstmt.execute();
			String msg = cstmt.getString(1);
			if (msg.equalsIgnoreCase("EXPIRED")) {
				ResultMap.put("ERROR_MSG", "Can't Initialize! \n Date Expired!!");
			} else if (msg.equalsIgnoreCase("SUCCESS")) {
				ResultMap.put("SUCCESS", "Initialization Successfully Completed!");
			} else
				ResultMap.put("ERROR_MSG", "");
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				con.close();
				cstmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ResultMap;
	}

	public Map<String, String> RunProcess(Map DataMap) throws Exception {
		DBUtils ob = new DBUtils();
		Connection con = null;
		CallableStatement cstmt = null;
		ResultMap.put("ERROR_MSG", "");
		try {

			con = ob.GetConnection();
			cstmt = con.prepareCall("CALL PKG_PRMS.SP_SALARY_CALCULATION_NEW(?,?,?,?)");
			cstmt.setInt(1, 1);
			cstmt.setString(2, DataMap.get("User_Id").toString());
			cstmt.setString(3, DataMap.get("SalaryCode").toString());
			cstmt.registerOutParameter(4, java.sql.Types.VARCHAR);
			cstmt.execute();
			String error = cstmt.getString(4);
			if (error != null) {
				ResultMap.put("ERROR_MSG", "Error in  RunProcess!");
			} else
				ResultMap.put("SUCCESS", "Process Successfully Completed!");
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				con.close();
				cstmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ResultMap;
	}

	public Map<String, String> BonusProcess(Map DataMap) throws Exception {
		DBUtils ob = new DBUtils();
		Connection con = null;
		CallableStatement cstmt = null;
		ResultMap.put("ERROR_MSG", "");
		try {
			con = ob.GetConnection();
			cstmt = con.prepareCall("CALL PKG_PRMS.SP_BONUS_CAL(?,?,?,?,?,?,?,?)");
			cstmt.setInt(1, 1);
			cstmt.setString(2, DataMap.get("User_Id").toString());
			cstmt.setString(3, DataMap.get("Year").toString());
			cstmt.setString(4, DataMap.get("MonthCode").toString());
			cstmt.setString(5, DataMap.get("bonusType").toString());
			cstmt.setString(6, DataMap.get("bonusPct").toString());
			cstmt.setString(7, DataMap.get("orderNo").toString());
			cstmt.registerOutParameter(8, java.sql.Types.VARCHAR);
			cstmt.execute();
			String error = cstmt.getString(8);
			if (error != null) {
				ResultMap.put("ERROR_MSG", "Error in  Bonus Process!\n" + error);
			} else
				ResultMap.put("SUCCESS", "Process Successfully Completed!");
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				con.close();
				cstmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ResultMap;
	}
	
	String GetMonthName(String monthcode) {
		Map<String, String> parameter = new HashMap<String, String>();
		parameter.put("1", "JAN");
		parameter.put("2", "FEB");
		parameter.put("3", "MAR");
		parameter.put("4", "APR");
		parameter.put("5", "MAY");
		parameter.put("6", "JUN");
		parameter.put("7", "JUL");
		parameter.put("8", "AUG");
		parameter.put("9", "SEP");
		parameter.put("10", "OCT");
		parameter.put("11", "NOV");
		parameter.put("12", "DEC");
		return parameter.get(monthcode);
	}
	
	
}
