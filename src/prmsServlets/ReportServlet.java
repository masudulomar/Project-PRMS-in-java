/***************************************************************
* Payroll Management System for BHBFC						   *
* @author   Md. Rubel Talukder & Mosharraf Hossain Talukder	   *
* @division ICT Operation									   *
* @version  1.0												   *
* @date     Feb 10, 2019 									   *
****************************************************************/


package prmsServlets;

import java.io.File;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import net.sf.jasperreports.engine.JasperRunManager;
import prmsInfos.CommonInfo;
import prmsUtilities.DBUtils;
import prmsValidators.PRMSValidator;

/**
 * Servlet implementation class ReportServlet
 */
@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;


	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public ReportServlet() {
		super();
		// TODO Auto-generated constructor stub
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	protected void doGet(HttpServletRequest request,
			HttpServletResponse response) throws ServletException {
		// TODO Auto-generated method stub
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse
	 *      response)
	 */
	private String GetReportPath(String ReportType,String branch_code){
		String ReportPath="";
		if(ReportType.equalsIgnoreCase("details_rpt")){
			ReportPath= CommonInfo._REPORT_DIR + "Salary_Report_All.jasper";
		}
		else if(ReportType.equalsIgnoreCase("bank_adv_rpt")){
			ReportPath= CommonInfo._REPORT_DIR + "Bank_Advice_All.jasper";
		}
		else if(ReportType.equalsIgnoreCase("indvidual_pay_slip")){
			ReportPath= CommonInfo._REPORT_DIR + "Individual_Pay_Slip.jasper";
		}
		else if(ReportType.equalsIgnoreCase("summary_rpt")){
			ReportPath= CommonInfo._REPORT_DIR + "Salary_Summary_Report.jasper";
		}
		else if(ReportType.equalsIgnoreCase("bonus_dtl_rpt")){
			ReportPath= CommonInfo._REPORT_DIR + "Bonus_Report_All.jasper";
		}
		else if(ReportType.equalsIgnoreCase("_bonus_bank_adv_rpt")){
			ReportPath= CommonInfo._REPORT_DIR + "Bank_Advice_Bonus.jasper";
		}
		else if(ReportType.equalsIgnoreCase("monthly_salary_summary")){
			if (branch_code.equalsIgnoreCase("NA")) {
				ReportPath= CommonInfo._REPORT_DIR + "Salary_Summary_Report_All.jasper";
			}
			else
			{
				ReportPath= CommonInfo._REPORT_DIR + "Salary_Summary_Report.jasper";
			}
			
		}
		else if(ReportType.equalsIgnoreCase("monthly_others_All")){
			ReportPath= CommonInfo._REPORT_DIR + "Other_Allowance.jasper";
		}
		else if(ReportType.equalsIgnoreCase("monthly_others_Ded")){
			ReportPath= CommonInfo._REPORT_DIR + "Other_Deduction.jasper";
		}
		
		else if(ReportType.equalsIgnoreCase("INC")){
			ReportPath= CommonInfo._REPORT_DIR + "Deduction_report_incomeTax.jasper";
		}
		else if(ReportType.equalsIgnoreCase("WEL")){
			ReportPath= CommonInfo._REPORT_DIR + "Deduction_report_welfare.jasper";
		}
		else if(ReportType.equalsIgnoreCase("ITR")){
			ReportPath= CommonInfo._REPORT_DIR + "Salary_Statement_Tax.jasper";
		}
		else
		{
			ReportPath= CommonInfo._REPORT_DIR + "Deduction_report.jasper";
		}
		
		return ReportPath;
		
	}
	protected void doPost(HttpServletRequest request,
			HttpServletResponse response) throws ServletException {
			Connection con = null;
			DBUtils dbUtils = new DBUtils();
			Map<String, Object> parameter = new HashMap<String, Object>();			
			String ReportType = request.getParameter("ReportType");			
			String branchCode = request.getParameter("Branch_Code");
			String year = request.getParameter("Year");
			String monthCode = request.getParameter("MonthCode");			
			String report_path=GetReportPath(ReportType,branchCode);
			
			String bonusType = "";
			if(request.getParameter("bonusType")!=""){
				bonusType = request.getParameter("bonusType");
				parameter.put("P_BONUS_TYPE", bonusType);
			}
			if(request.getParameter("ReportType")!=""){				
				
			}
			
			/*parameter.put("BRANCH_NAME", "Head Office");
			parameter.put("BRANCH_ADDRESS", "22 Purana Paltan , Dhaka-100");*/
			
			Map<String, String> brn_info = new HashMap<String, String>();
			brn_info.put("branch_code", branchCode);
			PRMSValidator prmsValidator = new PRMSValidator();
			try {
				brn_info = prmsValidator.BranchKeyPress(brn_info);
				parameter.put("BRANCH_NAME", brn_info.get("BRN_NAME"));
				parameter.put("BRANCH_ADDRESS", brn_info.get("BRN_ADDRESS"));
			} catch (Exception e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
			
			parameter.put("LOGO_PATH", CommonInfo._LOGO_PATH);
			parameter.put("M_LOGO", CommonInfo._LOGO_PATH_2);
			
			parameter.put("SUBREPORT_DIR", CommonInfo._SUB_REPORT_DIR);
			
			if(branchCode.equals("NA")) {
				//parameter.put("P_BRANCH", branchCode);
				branchCode="";
			}

			if(ReportType.equalsIgnoreCase("ITR")){
				if(request.getParameter("empID").equalsIgnoreCase("N/A")) {
					parameter.put("P_EMP_ID", null);
				}else {
					parameter.put("P_EMP_ID", request.getParameter("empID"));
				}
				parameter.put("P_FIN_YEAR", request.getParameter("financialYear").substring(0, 4));
				parameter.put("P_FIN_YEAR2", request.getParameter("financialYear").substring(5, 9));
				
			}
			parameter.put("P_BRANCH", branchCode);
			parameter.put("P_YEAR", year);
			parameter.put("P_MONTH", monthCode);
			parameter.put("P_DEDUCTION_TYPE", ReportType);
			try {
				File file = new File(report_path);
				//System.out.println(file.getCanonicalPath());
				con = dbUtils.GetConnection();
				byte[] bytes = JasperRunManager.runReportToPdf(file.getCanonicalPath(), parameter, con);
				response.setContentType("application/pdf");
				response.setContentLength(bytes.length);
				ServletOutputStream outputStream = response.getOutputStream();
				outputStream.write(bytes, 0, bytes.length);
				outputStream.flush();
				outputStream.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			finally {
				try {
					con.close();
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
	}
}
