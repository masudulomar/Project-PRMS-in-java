package prmsValidators;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import org.apache.commons.lang.StringUtils;

import prmsUtilities.DBUtils;

public class FinanceOperation {
	Map<String, String> ResultMap = new HashMap<String, String>();

	public FinanceOperation() {
		ResultMap.clear();
	}

	public Map<String, String> UpdateInitProfile(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			String sql1 = "UPDATE PRMS_EMP_SAL E SET E.NEW_BASIC=?,E.PF_DEDUCTION_PCT=?,E.BANK_ACC=?,ACC_NO_ACTIVE='Y' WHERE E.EMP_ID=?";
			stmt = con.prepareStatement(sql1);
			stmt.setString(1, DataMap.get("basicPay").toString());
			stmt.setString(2, DataMap.get("PFDeduct").toString());
			stmt.setString(3, DataMap.get("bankACNo").toString());
			stmt.setString(4, DataMap.get("EmployeeId").toString());
			stmt.executeUpdate();

			String sql2 = "UPDATE PRMS_EMP_SAL_HIST E SET E.NEW_BASIC=?, E.PF_DEDUCTION_PCT=?, E.BANK_ACC=?,ACC_NO_ACTIVE='Y' WHERE E.EMP_ID=?"
					+ " AND E.EFT_SERIAL=(SELECT MAX(E.EFT_SERIAL) FROM PRMS_EMP_SAL_HIST E WHERE E.EMP_ID=?)";
			stmt = con.prepareStatement(sql2);
			stmt.setString(1, DataMap.get("basicPay").toString());
			stmt.setString(2, DataMap.get("PFDeduct").toString());
			stmt.setString(3, DataMap.get("bankACNo").toString());
			stmt.setString(4, DataMap.get("EmployeeId").toString());
			stmt.setString(5, DataMap.get("EmployeeId").toString());
			stmt.executeUpdate();

			String sql3 = "UPDATE PRMS_DEDUC D  SET D.INCOME_TAX=?,REVENUE=? WHERE D.EMP_ID=?";
			stmt = con.prepareStatement(sql3);
			stmt.setString(1, DataMap.get("taxDeduct").toString());
			stmt.setString(2, "10");
			stmt.setString(3, DataMap.get("EmployeeId").toString());
			stmt.executeUpdate();
			ResultMap.put("SUCCESS", "Data Sucessfully Updated");
			stmt.close();
		} catch (SQLException e) {
			ResultMap.put("ERROR_MSG", "Error in Updating Employee's Profile");
			e.printStackTrace();
		} finally {
			try {
				con.close();
				
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;
	}

	public Map<String, String> UpdateAllowance(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			String query = "UPDATE PRMS_ALLOWANCE" + "   SET TEL_ALLOWANCE       = ?,"
					+ "       TRANS_ALLOWANCE     = ?," + "       EDU_ALLOWANCE       = ?,"
					+ "       WASH_ALLOWANCE      = ?," + "       ENTERTAIN_ALLOWANCE = ?,"
					+ "       DOMES_ALLOWANCE     = ?," + "       OTHER_ALLOWANCE     = ?,"
					+ "       HILL_ALLWNC         = ?," + "       ARREAR              = ?,"
					+ "       REMARKS             = ?," + "		  HR_AREAR_ALW		  = ?"
					+ " WHERE EMP_ID = ?";
			stmt = con.prepareStatement(query);
			stmt.setString(1, DataMap.get("telephone").toString());
			stmt.setString(2, DataMap.get("transport").toString());
			stmt.setString(3, DataMap.get("education").toString());
			stmt.setString(4, DataMap.get("wash").toString());
			stmt.setString(5, DataMap.get("entertainment").toString());
			stmt.setString(6, DataMap.get("domestic").toString());
			stmt.setString(7, DataMap.get("others").toString());
			stmt.setString(8, DataMap.get("hillAllwnc").toString());
			stmt.setString(9, DataMap.get("arrear").toString());
			stmt.setString(10, DataMap.get("remarksOthers").toString());
			stmt.setString(11, DataMap.get("arrearHR").toString());
			stmt.setString(12, DataMap.get("EmployeeId").toString());
			stmt.executeUpdate();

			String SQL = "UPDATE PRMS_EMP_SAL " + "   SET ARREAR_BASIC= ?" + " WHERE EMP_ID = ?";
			stmt = con.prepareStatement(SQL);
			stmt.setString(1, DataMap.get("arrearBasic").toString());
			stmt.setString(2, DataMap.get("EmployeeId").toString());
			stmt.executeUpdate();

			ResultMap.put("SUCCESS", "Data Sucessfully Updated");
			stmt.close();
		} catch (SQLException e) {
			ResultMap.put("ERROR_MSG", "Error in Updating Employee's Allowance");
			e.printStackTrace();
		} finally {
			try {
				con.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;
	}

	public Map<String, String> UpdateDeduction(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		String sql = "UPDATE PRMS_DEDUC" + "   SET CAR_FARE            = ?," + "       CAR_USE             = ?,"
				+ "       GAS_BILL            = ?," + "       WATER_BILL          = ?,"
				+ "       ELECT_BILL          = ?," + "       NEWS_PAPER          = ?,"
				+ "       COMP_DEDUC          = ?," + "       MCYCLE_DEDUC        = ?,"
				+ "       TEL_EXCESS_BILL     = ?," + "       HBADV_DEDUC_PERCENT = ?,"
				+ "		  HB_ADV_DEDUC		  = ?," + " 	  PFADV_DEDUC		  = ?,"
				+ "       OTHER_DEDUC         = ?," + "       REMARKS             = ?" + ",HR_AREAR_DED=?  WHERE EMP_ID = ? ";
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("carFare").toString());
			stmt.setString(2, DataMap.get("carUse").toString());
			stmt.setString(3, DataMap.get("gasBill").toString());
			stmt.setString(4, DataMap.get("waterBill").toString());
			stmt.setString(5, DataMap.get("electricBill").toString());
			stmt.setString(6, DataMap.get("newspaper").toString());
			stmt.setString(7, DataMap.get("computer").toString());
			stmt.setString(8, DataMap.get("motorcycle").toString());
			stmt.setString(9, DataMap.get("telephoneExcess").toString());
			stmt.setString(10, DataMap.get("hbAdvPct").toString());			
			stmt.setString(11, DataMap.get("hbAdvManual").toString());
			stmt.setString(12, DataMap.get("pfAdvance").toString());			
			stmt.setString(13, DataMap.get("others").toString());
			stmt.setString(14, DataMap.get("remarksOthers").toString());
			stmt.setString(15, DataMap.get("arearHR").toString());
			stmt.setString(16, DataMap.get("EmployeeId").toString());
			stmt.executeUpdate();
			ResultMap.put("SUCCESS", "Data Sucessfully Updated");
			stmt.close();
		} catch (SQLException e) {
			ResultMap.put("ERROR_MSG", "Error in Updating Employee's Deduction");
			e.printStackTrace();
		} finally {
			try {
				con.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ResultMap;
	}


	public Map<String, String> FetchEmpInitData(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		String sql = "SELECT (SELECT EM.EMP_NAME FROM PRMS_EMPLOYEE EM WHERE EM.EMP_ID = E.EMP_ID) EMP_NAME, E.NEW_BASIC,"
				+ " (SELECT S.EMP_BRN_CODE FROM PRMS_EMP_SAL S WHERE S.EMP_ID = E.EMP_ID) EMP_BRN_CODE,"
				+ " (SELECT NVL(D.INCOME_TAX, 0) FROM PRMS_DEDUC D WHERE D.EMP_ID = E.EMP_ID) TAX,"
				+ " NVL(E.PF_DEDUCTION_PCT, 0) PF_DEDUCTION_PCT," + " E.BANK_ACC" + " FROM PRMS_EMP_SAL E"
				+ " WHERE E.EMP_ID = ?";
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		ResultSet rs=null;
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("EmployeeId").toString());
			 rs = stmt.executeQuery();
			if (!rs.next()) {
				ResultMap.put("ERROR_MSG", "Employee Id not Found!");
			} else {
				if (rs.getString("EMP_BRN_CODE").equals(DataMap.get("UserBranchCode").toString()) || DataMap.get("UserBranchCode").toString().equals("9999")) {
					ResultSetMetaData rsmd = rs.getMetaData();
					for (int i = 1; i <= rsmd.getColumnCount(); i++) {
						try {
							ResultMap.put(rsmd.getColumnName(i),
									StringUtils.isBlank(rs.getObject(i).toString()) ? "" : rs.getObject(i).toString());
						} catch (Exception e) {
							System.out.println(rsmd.getColumnName(i) + "--" + e.getMessage());
						}
					}
				} else {
					ResultMap.put("ERROR_MSG", "Employee doesn't belong to this Branch!");
				}
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
	
	public Map<String, String> FetchPersonalInitData(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		
		
		String sql = "Select * from personal_info where PF_NUM=? ";
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		ResultSet rs=null;
		
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("PFId").toString());
			//System.out.println("Hello");
			rs = stmt.executeQuery();
			
			if (!rs.next()) {
				ResultMap.put("ERROR_MSG", "Personal Information not Found!");
			} else {
				if (rs.getString("PF_NUM").equals(DataMap.get("PFId").toString())) {
					ResultSetMetaData rsmd = rs.getMetaData();
					for (int i = 1; i <= rsmd.getColumnCount(); i++) {
						try {
							ResultMap.put(rsmd.getColumnName(i),
									StringUtils.isBlank(rs.getObject(i).toString()) ? "" : rs.getObject(i).toString());
						} catch (Exception e) {
							System.out.println(rsmd.getColumnName(i) + "--" + e.getMessage());
						}
					}
				} else {
					ResultMap.put("ERROR_MSG", "Employee doesn't belong to this Branch!");
				}
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
	
	

	public Map<String, String> FetchAllowanceData(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		ResultSet rs =null;
		ResultSetMetaData rsmd=null;
		String sql = "SELECT (SELECT EM.EMP_NAME FROM PRMS_EMPLOYEE EM WHERE EM.EMP_ID = D.EMP_ID) EMP_NAME,"
				+ " (SELECT S.EMP_BRN_CODE FROM PRMS_EMP_SAL S WHERE S.EMP_ID = D.EMP_ID) EMP_BRN_CODE,"
				+ "NVL(TEL_ALLOWANCE, 0) TEL_ALLOWANCE,NVL(TRANS_ALLOWANCE, 0) TRANS_ALLOWANCE, NVL(EDU_ALLOWANCE, 0) EDU_ALLOWANCE,"
				+ "NVL(WASH_ALLOWANCE, 0) WASH_ALLOWANCE,NVL(PENSION_ALLOWANCE, 0) PENSION_ALLOWANCE,"
				+ "NVL(ENTERTAIN_ALLOWANCE, 0) ENTERTAIN_ALLOWANCE,NVL(DOMES_ALLOWANCE, 0) DOMES_ALLOWANCE,NVL(HILL_ALLWNC,0) HILL_ALLWNC,"
				+ "NVL(OTHER_ALLOWANCE, 0) OTHER_ALLOWANCE,NVL(ARREAR, 0) ARREAR,REMARKS,(SELECT NVL(S.ARREAR_BASIC,0) FROM PRMS_EMP_SAL S WHERE S.EMP_ID=D.EMP_ID) ARREAR_BASIC "
				+ ",NVL(HR_AREAR_ALW,0) HR_AREAR_ALW FROM PRMS_ALLOWANCE D" + " WHERE D.EMP_ID = ?";
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("EmployeeId").toString());
			 rs = stmt.executeQuery();
			if (!rs.next()) {
				ResultMap.put("ERROR_MSG", "Employee Id not Found!");
			} else {
				if (rs.getString("EMP_BRN_CODE").equals(DataMap.get("UserBranchCode").toString()) || DataMap.get("UserBranchCode").toString().equals("9999")) {
					 rsmd = rs.getMetaData();
					for (int i = 1; i <= rsmd.getColumnCount(); i++) {
						try {
							ResultMap.put(rsmd.getColumnName(i),
									StringUtils.isBlank(rs.getObject(i).toString()) ? "" : rs.getObject(i).toString());
						} catch (Exception e) {
							System.out.println(rsmd.getColumnName(i) + "--" + e.getMessage());
						}
					}
				} else {
					ResultMap.put("ERROR_MSG", "Employee doesn't belong to this Branch!");
				}
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

	public Map<String, String> FetchDeductionData(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		String sql = "SELECT (SELECT EMP_NAME FROM PRMS_EMPLOYEE WHERE EMP_ID = D.EMP_ID) EMP_NAME,"
				+ "		  NVL(CAR_FARE, 0) CAR_FARE," + "       NVL(CAR_USE, 0) CAR_USE,"
				+ "       NVL(GAS_BILL, 0) GAS_BILL," + "       NVL(WATER_BILL, 0) WATER_BILL,"
				+ "       NVL(ELECT_BILL, 0) ELECT_BILL," + "       NVL(NEWS_PAPER, 0) NEWS_PAPER,"
				+ "       NVL(COMP_DEDUC, 0) COMP_DEDUC," + "       NVL(MCYCLE_DEDUC, 0) MCYCLE_DEDUC,"
				+ "		  NVL(HB_ADV_DEDUC,0)	HB_ADV_DEDUC, NVL(PFADV_DEDUC	,0)	 PFADV_DEDUC,"
				+ "       NVL(TEL_EXCESS_BILL, 0) TEL_EXCESS_BILL,"
				+ "       NVL(HBADV_DEDUC_PERCENT, 0) HBADV_DEDUC_PERCENT," + "       NVL(OTHER_DEDUC, 0) OTHER_DEDUC,"
				+ "       REMARKS,"
				+ "		  (SELECT S.EMP_BRN_CODE FROM PRMS_EMP_SAL S WHERE S.EMP_ID = D.EMP_ID) EMP_BRN_CODE"
				+ ", NVL(HR_AREAR_DED,0) HR_AREAR_DED  FROM PRMS_DEDUC D" + " WHERE EMP_ID = ?";
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("EmployeeId").toString());
			ResultSet rs = stmt.executeQuery();
			if (!rs.next()) {
				ResultMap.put("ERROR_MSG", "Employee Id not Found!");
			} else {
				if (rs.getString("EMP_BRN_CODE").equals(DataMap.get("UserBranchCode").toString())|| DataMap.get("UserBranchCode").toString().equals("9999")) {
					ResultSetMetaData rsmd = rs.getMetaData();
					for (int i = 1; i <= rsmd.getColumnCount(); i++) {
						try {
							ResultMap.put(rsmd.getColumnName(i),
									StringUtils.isBlank(rs.getObject(i).toString()) ? "" : rs.getObject(i).toString());
						} catch (Exception e) {
							System.out.println(rsmd.getColumnName(i) + "--" + e.getMessage());
						}
					}
				} else {
					ResultMap.put("ERROR_MSG", "Employee doesn't belong to this Branch!");
				}
			}
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			try {
				con.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ResultMap;
	}
	
	public Map<String, String> UpdateUserFeedback(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			String sql = "INSERT INTO PRMS_FEEDBACK VALUES(?,?,?,?,?,?,?,?)";
			stmt = con.prepareStatement(sql);
			stmt.setString(1, DataMap.get("entityNum").toString());
			stmt.setString(2, DataMap.get("branchCode").toString());
			stmt.setString(3, DataMap.get("year").toString());
			stmt.setString(4, DataMap.get("monthCode").toString());
			stmt.setString(5, DataMap.get("feedbackType").toString());
			stmt.setString(6, DataMap.get("userID").toString());
			stmt.setString(7, DataMap.get("entd_on").toString());
			stmt.setString(8, DataMap.get("remarks").toString());
			stmt.executeQuery();

			ResultMap.put("SUCCESS", "Data Sucessfully Updated");
			stmt.close();
		} catch (SQLException e) {
			ResultMap.put("ERROR_MSG", "Error in UpdateUserFeedback! \nMay be you've already given feedback for this month!");
			e.printStackTrace();
		} finally {
			try {
				con.close();
				
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;
	}

	 /*public Map<String, String> UpdatePersonal_info(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		try {
			String query = "UPDATE PERSONAL_INFO" + "   SET UNIVERSITY       = ?,"
					+ "       SUBJECT     = ?"
					+ " WHERE PF_NUM = ?";
			stmt = con.prepareStatement(query);
			stmt.setString(1, DataMap.get("University").toString());
			stmt.setString(2, DataMap.get("Subject").toString());
			stmt.setString(12, DataMap.get("PFId").toString());
			stmt.executeUpdate();

			stmt.setString(2, DataMap.get("PFId").toString());
			stmt.executeUpdate();

			ResultMap.put("SUCCESS", "Data Sucessfully Updated");
			stmt.close();
		} catch (SQLException e) {
			ResultMap.put("ERROR_MSG", "Error in Updating Employee's Personal Info");
			e.printStackTrace();
		} finally {
			try {
				con.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;
	}
	
}*/
	
	public Map<String, String> UpdatePersonal_info(Map DataMap) {
		//System.out.println("Hello");

		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		ResultSet rs=null;
		try {

			String sql1="select * from personal_info where PF_NUM=?";
			stmt = con.prepareStatement(sql1);
			stmt.setString(1, DataMap.get("PFId").toString());
			rs = stmt.executeQuery();

			if (!rs.next()) {
					String sql="insert into personal_info values(?,?,?,?)";
					stmt = con.prepareStatement(sql);
					stmt.setString(1, DataMap.get("PFId").toString());
					stmt.setString(2, DataMap.get("EmpName").toString());
					stmt.setString(3, DataMap.get("University").toString());
					stmt.setString(4, DataMap.get("Subject").toString());
					stmt.executeUpdate();
					ResultMap.put("SUCCESS", "Data Sucessfully Inserted.");
					stmt.close();
			} 
			else 
			{
				String sql = "UPDATE PERSONAL_INFO P SET P.UNAME=?, P.UNIVERSITY=?, P.SUBJECT=? WHERE P.PF_NUM=?";
				stmt = con.prepareStatement(sql);
				stmt.setString(1, DataMap.get("EmpName").toString());
				stmt.setString(2, DataMap.get("University").toString());
				stmt.setString(3, DataMap.get("Subject").toString());
				stmt.setString(4, DataMap.get("PFId").toString());
				stmt.executeUpdate();
				ResultMap.put("SUCCESS", "Data Sucessfully Updated");
				stmt.close();
			}
			stmt.close();
		} catch (SQLException e) {
			ResultMap.put("ERROR_MSG", "Error in Updating Employee's Profile");
			e.printStackTrace();
		} finally {
			try {
				con.close();
				//stmt.close();
				
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;
	}


	public Map<String, String> FetchLoanData(Map DataMap) {
		ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		String sql = "select LOAN_CODE, NAME1, NAME2, F_NAME, H_NAME, M_NAME,\r\n"
				+ "       M_ADD1||M_ADD2||M_ADD3 M_ADD, PHONE_RES, PHONE_OFF, CELL_NO,\r\n"
				+ "       S_ADD1||S_ADD2||S_ADD3 S_ADD, EMAIL, PROJ_CODE, NID1, S_DIST_CODE,\r\n"
				+ "       NID2, S_THANA_CODE from table(pkg_lms_entry.fn_get_loan_info(?,?))";
		Connection con = ob.GetConnection();
		PreparedStatement cstmt = null;
		ResultSet rs=null;
		
		try 
		{
			cstmt = con.prepareStatement(sql);
			cstmt.setString(1, DataMap.get("BranchCode").toString());
			cstmt.setString(2, DataMap.get("LoanCode").toString());
			
			
			rs = cstmt.executeQuery();
			
			if (!rs.next()) 
			{
				ResultMap.put("ERROR_MSG", "Personal Information not Found!");
			} 
			
			else 
			{
				ResultSetMetaData rsmd = rs.getMetaData();
				for (int i = 1; i <= rsmd.getColumnCount(); i++) 
				{
					try 
					{
						ResultMap.put(rsmd.getColumnName(i),StringUtils.isBlank(rs.getObject(i).toString()) ? "" : rs.getObject(i).toString());
					} 
					catch (Exception e) 
					{
						System.out.println(rsmd.getColumnName(i) + "--" + e.getMessage());
					}
				}
			}
		} 
		catch (SQLException e) 
		{
			e.printStackTrace();
		}
		finally {
			try {
				con.close();
				cstmt.close();
				rs.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return ResultMap;
	}
	
	public Map<String, String> InsertUpdateLoanData(Map DataMap) 
	{
		DBUtils ob = new DBUtils();
		Connection con = null;
		CallableStatement cstmt = null;
		ResultMap.put("ERROR_MSG", "");
		
		
		try {
			con = ob.GetConnection();
			cstmt = con.prepareCall("CALL PKG_LMS_ENTRY.sp_loan_personal_data(?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?,?,?, ?)");

			cstmt.setString(1, DataMap.get("BranchCode").toString());
			// cstmt.setString(2, DataMap.get("BranchName").toString());
			cstmt.setString(2, DataMap.get("LoanCode").toString());
			// cstmt.setString(4, DataMap.get("LoanName").toString());
			cstmt.setString(3, DataMap.get("BorrowerName").toString());
			cstmt.setString(4, DataMap.get("JointBorrower").toString());
			cstmt.setString(5, DataMap.get("FatherName").toString());
			cstmt.setString(6, DataMap.get("HusbandName").toString());
			cstmt.setString(7, DataMap.get("MotherName").toString());
			cstmt.setString(8, DataMap.get("MailingAddress").toString()); 
			cstmt.setString(9, DataMap.get("PhoneRes").toString());
			cstmt.setString(10, DataMap.get("PhoneOff").toString());
			cstmt.setString(11, DataMap.get("MobileNo").toString());
			cstmt.setString(12, DataMap.get("SiteAddress").toString());
			cstmt.setString(13, DataMap.get("Email").toString());
			cstmt.setString(14, DataMap.get("ProjCode").toString());
			cstmt.setString(15, DataMap.get("NID1").toString());
			cstmt.setString(16, DataMap.get("DistrictCode").toString());
			cstmt.setString(17, DataMap.get("NID2").toString());
			cstmt.setString(18, DataMap.get("ThanaCode").toString());

			cstmt.registerOutParameter(19, java.sql.Types.VARCHAR);

			cstmt.execute();
			String error = cstmt.getString(19);
			if (error != null) {
				ResultMap.put("ERROR_MSG", error);
			} else
				ResultMap.put("SUCCESS", "Data Successfully Insert/Updated!");
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

		/*ResultMap.put("ERROR_MSG", "");
		DBUtils ob = new DBUtils();
		Connection con = ob.GetConnection();
		PreparedStatement stmt = null;
		ResultSet rs = null;
		try 
		{
			
			

			String sql1 = "select * from LOAN_MAS where LOAN_CODE=?";
			stmt = con.prepareStatement(sql1);
			stmt.setString(1, DataMap.get("LoanCode").toString());
			rs = stmt.executeQuery();

			if (!rs.next()) 
			{
				String sql = "insert into LOAN_MAS (LOC_CODE, LOAN_CODE, NAME1, NAME2, F_NAME, H_NAME, M_NAME, M_ADD1, PHONE_RES, PHONE_OFF, CELL_NO, S_ADD1, EMAIL, PROJ_CODE, NID1, S_DIST_CODE, NID2, S_THANA_CODE, LOAN_ACC, LOAN_CAT) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,'NA','NA')";
				stmt = con.prepareStatement(sql);
				stmt.setString(1, DataMap.get("BranchCode").toString());
				// stmt.setString(2, DataMap.get("BranchName").toString());
				stmt.setString(2, DataMap.get("LoanCode").toString());
				// stmt.setString(4, DataMap.get("LoanName").toString());
				stmt.setString(3, DataMap.get("BorrowerName").toString());
				stmt.setString(4, DataMap.get("JointBorrower").toString());
				stmt.setString(5, DataMap.get("FatherName").toString());
				stmt.setString(6, DataMap.get("HusbandName").toString());
				stmt.setString(7, DataMap.get("MotherName").toString());
				stmt.setString(8, DataMap.get("MailingAddress").toString());
				stmt.setString(9, DataMap.get("PhoneRes").toString());
				stmt.setString(10, DataMap.get("PhoneOff").toString());
				stmt.setString(11, DataMap.get("MobileNo").toString());
				stmt.setString(12, DataMap.get("SiteAddress").toString());
				stmt.setString(13, DataMap.get("Email").toString());
				// stmt.setString(16, DataMap.get("ProjName").toString());
				stmt.setString(14, DataMap.get("ProjCode").toString());
				stmt.setString(15, DataMap.get("NID1").toString());
				// stmt.setString(19, DataMap.get("DistrictName").toString());
				stmt.setString(16, DataMap.get("DistrictCode").toString());
				stmt.setString(17, DataMap.get("NID2").toString());
				// stmt.setString(22, DataMap.get("ThanaName").toString());
				stmt.setString(18, DataMap.get("ThanaCode").toString());

				stmt.executeUpdate();
				ResultMap.put("SUCCESS", "Data Sucessfully Inserted.");
				stmt.close();
			} 
			else 
			{
				stmt.close();
				String sql = "UPDATE LOAN_MAS P SET P.LOC_CODE=?,P.NAME1=?,P.NAME2=?,P.F_NAME=?,P.H_NAME=?,P.M_NAME=?,P.M_ADD1=?,P.PHONE_RES=?,P.PHONE_OFF=?,P.CELL_NO=?,P.S_ADD1=?,P.EMAIL=?,P.PROJ_CODE=?,P.NID1=?,P.S_DIST_CODE=?,P.NID2=?,P.S_THANA_CODE=? where P.LOAN_CODE=?";
				stmt = con.prepareStatement(sql);
				stmt.setString(1, DataMap.get("BranchCode").toString());
				// stmt.setString(2, DataMap.get("BranchName").toString());
				stmt.setString(2, DataMap.get("LoanCode").toString());
				// stmt.setString(4, DataMap.get("LoanName").toString());
				stmt.setString(3, DataMap.get("BorrowerName").toString());
				stmt.setString(4, DataMap.get("JointBorrower").toString());
				stmt.setString(5, DataMap.get("FatherName").toString());
				stmt.setString(6, DataMap.get("HusbandName").toString());
				stmt.setString(7, DataMap.get("MotherName").toString());
				stmt.setString(8, DataMap.get("MailingAddress").toString());
				stmt.setString(9, DataMap.get("PhoneRes").toString());
				stmt.setString(10, DataMap.get("PhoneOff").toString());
				stmt.setString(11, DataMap.get("MobileNo").toString());
				stmt.setString(12, DataMap.get("SiteAddress").toString());
				stmt.setString(13, DataMap.get("Email").toString());
				// stmt.setString(16, DataMap.get("ProjName").toString());
				stmt.setString(14, DataMap.get("ProjCode").toString());
				stmt.setString(15, DataMap.get("NID1").toString());
				// stmt.setString(19, DataMap.get("DistrictName").toString());
				stmt.setString(16, DataMap.get("DistrictCode").toString());
				stmt.setString(17, DataMap.get("NID2").toString());
				// stmt.setString(22, DataMap.get("ThanaName").toString());
				stmt.setString(18, DataMap.get("ThanaCode").toString());
				stmt.executeUpdate();
				ResultMap.put("SUCCESS", "Data Sucessfully Updated");
				stmt.close();
			}
			stmt.close();
		}
		catch (SQLException e) 
		{
			ResultMap.put("ERROR_MSG", "Error in Updating Employee's Profile");
			e.printStackTrace();
		} 
		finally 
		{
			try {
				con.close();
				// stmt.close();

			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		return ResultMap;*/
	}
}

