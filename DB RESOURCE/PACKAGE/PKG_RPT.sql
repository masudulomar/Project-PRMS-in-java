CREATE OR REPLACE PACKAGE PKG_RPT IS

  TYPE DED_DATA IS RECORD(
    BRANCH_CODE    VARCHAR2(5),
    EMP_ID         PRMS_EMP_SAL.EMP_ID%TYPE,
    EMP_NAME       PRMS_EMPLOYEE.EMP_NAME%TYPE,
    DESIGNATION    PRMS_EMP_SAL.DESIG%TYPE,
    MONTH          PRMS_TRANSACTION.SAL_MONTH%TYPE,
    TIN_NO         PRMS_EMPLOYEE.TIN_NO%TYPE,
    DESIG_CODE     NUMBER(4),
    MONTH_YEAR     VARCHAR(10),
    MONTH_CODE     NUMBER(2),
    DEDUCTION_TYPE VARCHAR2(3),
    DEDUCTION_AMT  NUMBER(11, 2),
    COMPUTER_AMT  NUMBER(11, 2));
  TYPE V_DATA IS TABLE OF DED_DATA;
  FUNCTION FN_DED_DATA(P_ENTITY_NUMBER  IN NUMBER,
                       P_BRANCH_CODE    IN VARCHAR2,
                       P_YEAR           IN NUMBER,
                       P_MONTH_CODE     IN NUMBER,
                       P_DEDUCTION_TYPE IN VARCHAR2) RETURN V_DATA
    PIPELINED;
END PKG_RPT;
/
CREATE OR REPLACE PACKAGE BODY PKG_RPT IS

  FUNCTION FN_DED_DATA(P_ENTITY_NUMBER  IN NUMBER,
                       P_BRANCH_CODE    IN VARCHAR2,
                       P_YEAR           IN NUMBER,
                       P_MONTH_CODE     IN NUMBER,
                       P_DEDUCTION_TYPE IN VARCHAR2) RETURN V_DATA
    PIPELINED IS
    V_DED_DATA DED_DATA;
  
  BEGIN
    IF P_DEDUCTION_TYPE = 'PFC' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND PF_DEDUCTION > 0) LOOP
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
      
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.PF_DEDUCTION;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'PFA' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND PFADV_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
      
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.PFADV_DEDUC;
      
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'HBL' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND HBADV_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.HBADV_DEDUC;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'MOT' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND MCYCLE_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.MCYCLE_DEDUC;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'COM' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND COMP_DEDUC > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.COMP_DEDUC;
        PIPE ROW(V_DED_DATA);
      END LOOP;
     ELSIF P_DEDUCTION_TYPE = 'INC' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.income_tax > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name,e.tin_no
          into V_DED_DATA.EMP_NAME,V_DED_DATA.TIN_NO
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.income_tax;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    ELSIF P_DEDUCTION_TYPE = 'WEL' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.Welfare_Deduc > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.Welfare_Deduc;
        V_DED_DATA.ComPuter_AMT:=nvl(id.news_paper_deduc,0);
        PIPE ROW(V_DED_DATA);
      END LOOP;
    
    ELSIF P_DEDUCTION_TYPE = 'GEN' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.gen_insurence > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.gen_insurence;
        PIPE ROW(V_DED_DATA);
      END LOOP;
     ELSIF P_DEDUCTION_TYPE = 'PEN' THEN
      FOR ID IN (SELECT *
                   FROM PRMS_TRANSACTION t
                  WHERE ENTITY_NUMBER = P_ENTITY_NUMBER
                    AND BRANCH_CODE = P_BRANCH_CODE
                    AND SAL_YEAR = P_YEAR
                    AND MONTH_CODE = P_MONTH_CODE
                    AND t.pension_deduc > 0) LOOP
      
        SELECT D.DESIGNATION_DESC, D.DESIGNATION_CODE
          INTO V_DED_DATA.DESIGNATION, V_DED_DATA.DESIG_CODE
          FROM PRMS_DESIGNATION D
         WHERE D.DESIGNATION_CODE =
               (SELECT H.DESIG_CODE
                  FROM PRMS_EMP_SAL H
                 WHERE H.EMP_ID = ID.EMP_ID);
        select e.emp_name
          into V_DED_DATA.EMP_NAME
          from prms_employee e
         where e.emp_id = id.emp_id;
        V_DED_DATA.MONTH          := ID.SAL_MONTH;
        V_DED_DATA.BRANCH_CODE    := ID.BRANCH_CODE;
        V_DED_DATA.EMP_ID         := ID.EMP_ID;
        V_DED_DATA.MONTH_YEAR     := ID.SAL_YEAR;
        V_DED_DATA.MONTH_CODE     := ID.MONTH_CODE;
        V_DED_DATA.DEDUCTION_TYPE := P_DEDUCTION_TYPE;
        V_DED_DATA.DEDUCTION_AMT  := ID.pension_deduc;
        PIPE ROW(V_DED_DATA);
      END LOOP;
    END IF;
    
  END FN_DED_DATA;

BEGIN
  NULL;
END PKG_RPT;
/
