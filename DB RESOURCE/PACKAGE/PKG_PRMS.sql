CREATE OR REPLACE PACKAGE PKG_PRMS IS

  -- AUTHOR  : MOSHARRAF & RUBEL
  -- SUPERVISED BY MD. ROKUNUZZAMAN
  -- CREATED : 17-FEB-19 11:15:51 AM
  -- PURPOSE : SALARY GENERATION.

  PROCEDURE SP_SALARY_CALCULATION(P_ENTITY_NUM IN NUMBER,
                                  P_USER_ID    IN VARCHAR2,
                                  P_SALCODE    IN VARCHAR2,
                                  P_ERROR_MSG  OUT VARCHAR2);

  PROCEDURE SP_INIT_VALUES(P_MSG OUT VARCHAR2);
  PROCEDURE SP_SALARY_CALCULATION_NEW(P_ENTITY_NUM IN NUMBER,
                                      P_USER_ID    IN VARCHAR2,
                                      P_SALCODE    IN VARCHAR2,
                                      P_ERROR_MSG  OUT VARCHAR2);

  /*  PROCEDURE SP_SAL_CALC_INCRMNT(P_ENTITY_NUM IN NUMBER,
  P_ERROR_MSG  OUT VARCHAR2);*/

  PROCEDURE SP_EMPLOYEE_UPDATION(P_EMP_ID         IN VARCHAR2,
                                 P_NEW_BRN_CODE   IN VARCHAR2,
                                 P_NEW_BASIC      IN NUMBER,
                                 P_NEW_DESIG_CODE IN VARCHAR2,
                                 P_EFFECTIVE_DATE IN VARCHAR2,
                                 P_MSG            OUT VARCHAR2);

  PROCEDURE SP_NEW_EMPLOYEE_INSERTION(P_EMPLOYEE_ID    IN VARCHAR2,
                                      P_EMPLOYEE_NAME  IN VARCHAR2,
                                      P_BRANCH_CODE    IN VARCHAR2,
                                      P_DESIGNATION    IN VARCHAR2,
                                      P_JOINING_DATE   IN VARCHAR2,
                                      P_DEPT_CODE      IN VARCHAR2,
                                      P_GENDER_TYPE    IN VARCHAR2,
                                      P_BLOOD_GRP      IN VARCHAR2,
                                      P_RHFACTOR       IN VARCHAR2,
                                      P_DOB            IN VARCHAR2,
                                      P_CONTACT_NO     IN VARCHAR2,
                                      P_TIN            IN VARCHAR2,
                                      P_EMAIL          IN VARCHAR2,
                                      P_SENIORITY_CODE IN VARCHAR2,
                                      P_ADDRESS        IN VARCHAR2,
                                      P_ENTD_BY        IN VARCHAR2,
                                      P_RELIGION       IN CHAR,
                                      P_DEGREE         IN VARCHAR2,
                                      P_HOME_DIST      IN VARCHAR2,
                                      P_NID_NO         IN VARCHAR2,
                                      P_MSG            OUT VARCHAR2);

  PROCEDURE SP_BONUS_CAL(P_ENTITY         IN NUMBER,
                         P_USER_ID        IN VARCHAR2,
                         P_BASIC_YEAR     IN NUMBER,
                         P_BASIC_MON_CODE IN NUMBER,
                         P_BONUS_TYPE     IN VARCHAR2,
                         P_BON_PCT        IN NUMBER,
                         P_BON_ORDER_NO   IN VARCHAR2,
                         P_MSG            OUT VARCHAR2);

  TYPE TAX_DATA IS RECORD(
    BRANCH_CODE    VARCHAR2(5),
    EMP_ID         PRMS_EMP_SAL.EMP_ID%TYPE,
    DESIGNATION    PRMS_EMP_SAL.DESIG%TYPE,
    EMP_NAME       PRMS_EMPLOYEE.EMP_NAME%TYPE,
    MONTH_YEAR     VARCHAR(10),
    SAL_YEAR       PRMS_TRANSACTION.SAL_YEAR%TYPE,
    MONTH_CODE     NUMBER(2),
    BASIC_PAY      NUMBER(9, 2),
    DOM_ALLOWANCE  NUMBER(9, 2),
    ENTERTAINMENT  NUMBER(9, 2),
    MED_ALLOWANCE  NUMBER(9, 2),
    HR_ALLOWANCE   NUMBER(9, 2),
    EDU_ALLOWANCE  NUMBER(9, 2),
    PF_DEDUCTION   NUMBER(9, 2),
    WELFARE_DEDUC  NUMBER(9, 2),
    INCOME_TAX     NUMBER(9, 2),
    TEL_ALLOWANCE  NUMBER(9, 2),
    DRNS_ALLOWANCE NUMBER(9, 2),
    GEN_INSURENCE  NUMBER(9, 2),
    FESTIVAL_BONUS NUMBER(9, 2));
  TYPE V_DATA IS TABLE OF TAX_DATA;
  FUNCTION FN_TAX_STMt_DATA(P_ENTITY_NUMBER IN NUMBER,
                            P_BRANCH_CODE   IN VARCHAR2,
                            P_YEAR1         IN VARCHAR2,
                            P_YEAR2         IN VARCHAR2) RETURN V_DATA
    PIPELINED;

END PKG_PRMS;
/
CREATE OR REPLACE PACKAGE BODY PKG_PRMS IS
  FUNCTION GET_HR_AMT(P_HR_ALWN1 IN NUMBER, P_HR_ALWN2 IN NUMBER)
    RETURN NUMBER IS
  BEGIN
    IF P_HR_ALWN1 > P_HR_ALWN2 THEN
      RETURN P_HR_ALWN1;
    ELSE
      RETURN P_HR_ALWN2;
    END IF;
  END GET_HR_AMT;

  FUNCTION GET_MIN_AMT(P_ALWN1 IN NUMBER, P_ALWN2 IN NUMBER) RETURN NUMBER IS
  BEGIN
    IF P_ALWN1 < P_ALWN2 THEN
      RETURN P_ALWN1;
    ELSE
      RETURN P_ALWN2;
    END IF;
  END GET_MIN_AMT;

  FUNCTION FN_GET_HR_ALWNC(P_TYPE             IN NUMBER,
                           P_BASIC_AMT        IN NUMBER,
                           P_ACTUAL_BASIC_AMT IN NUMBER) RETURN NUMBER IS
    V_HR_ALWNC     NUMBER(9, 2) := 0;
    V_MIN_HR_ALWNC NUMBER(9, 2) := 0;
  BEGIN
  
    SELECT H.HOUSE_RENT_PCT * P_ACTUAL_BASIC_AMT, H.MIN_HR_AMT
      INTO V_HR_ALWNC, V_MIN_HR_ALWNC
      FROM PRMS_HOUSE_RENT_MASTER H
     WHERE H.BRN_TYPE = P_TYPE
       AND H.BASIC_MIN_AMT <= P_BASIC_AMT
       AND H.BASIC_MAX_AMT >= P_BASIC_AMT;
    IF P_BASIC_AMT <> P_ACTUAL_BASIC_AMT THEN
      RETURN V_HR_ALWNC;
    ELSE
      RETURN GET_HR_AMT(V_HR_ALWNC, V_MIN_HR_ALWNC);
    END IF;
  
  END FN_GET_HR_ALWNC;

  PROCEDURE SP_SALARY_CALCULATION(P_ENTITY_NUM IN NUMBER,
                                  P_USER_ID    IN VARCHAR2,
                                  P_SALCODE    IN VARCHAR2,
                                  P_ERROR_MSG  OUT VARCHAR2) IS
  
    V_BASIC_AMT           NUMBER(9, 2) := 0;
    V_HR_ALWNC_AMT        NUMBER(9, 2) := 0;
    V_PENSION_ALLOWANCE   NUMBER(9, 2) := 0;
    V_HBADV_DEDUC         NUMBER(9, 2) := 0;
    V_PF_DED_AMT          NUMBER(9, 2) := 0;
    V_DESIG_CATAGORY      NUMBER(2);
    V_MIN_WELFARE_DED_AMT NUMBER(9, 2) := 0;
    V_MIN_INS_DED_AMT     NUMBER(9, 2) := 0;
    V_CBD_LAST_DATE       DATE;
    V_CBD_LAST_DAY        NUMBER(2) := 0;
    T_LPR_DATE            DATE;
    T_LPR_DAY             NUMBER(2) := 0;
    V_EXCEPTION EXCEPTION;
    V_MONTH_CODE NUMBER(2);
    V_SAL_YEAR   NUMBER(4);
    V_SAL_MONTH  VARCHAR2(10) := '';
  
    V_MED_ALWNC_AMT      NUMBER(9, 2) := 0;
    V_TEL_ALWNC_AMT      NUMBER(9, 2) := 0;
    V_TRANS_ALLOWANCE    NUMBER(9, 2) := 0;
    V_EDU_ALLOWANCE      NUMBER(9, 2) := 0;
    V_WASH_ALLOWANCE     NUMBER(9, 2) := 0;
    V_ENTERTAINMENT      NUMBER(9, 2) := 0;
    V_DOMESTIC_ALLOWANCE NUMBER(9, 2) := 0;
    V_OTHER_ALLOWANCE    NUMBER(9, 2) := 0;
    V_DREANESS_ALLWNC    NUMBER(9, 2) := 0;
    V_HILL_ALLWNC        NUMBER(9, 2) := 0;
  
    V_MCYCLE_DEDUC        NUMBER(9, 2) := 0;
    V_BICYCLE_DEDUC       NUMBER(9, 2) := 0;
    V_PFADV_DEDUC         NUMBER(9, 2) := 0;
    V_HBADV_ARREAR_DEDUC  NUMBER(9, 2) := 0;
    V_PFADV_ARREAR_DEDUC  NUMBER(9, 2) := 0;
    V_TEL_EXCESS_BILL     NUMBER(9, 2) := 0;
    V_OTHER_DEDUC         NUMBER(9, 2) := 0;
    V_COMP_DEDUC          NUMBER(9, 2) := 0;
    V_PENSION_DEDUC       NUMBER(9, 2) := 0;
    V_REVENUE_DEDUC       NUMBER(9, 2) := 0;
    V_CARFARE_DEDUC       NUMBER(9, 2) := 0;
    V_CARUSE_DEDUC        NUMBER(9, 2) := 0;
    V_HBADV_DEDUC_PERCENT NUMBER(9, 2) := 0;
    V_GAS_BILL            NUMBER(9, 2) := 0;
    V_WATER_BILL          NUMBER(9, 2) := 0;
    V_ELECTRICITY_BILL    NUMBER(9, 2) := 0;
    V_HOUSE_RENT_DEDUC    NUMBER(9, 2) := 0;
    V_NEWS_PAPER_DEDUC    NUMBER(9, 2) := 0;
    V_WELFARE_DED_AMT     NUMBER(9, 2) := 0;
    V_INS_DED_AMT         NUMBER(9, 2) := 0;
    V_INCOME_TAX          NUMBER(9, 2) := 0;
    V_INCOME_TAX_ARR      NUMBER(9, 2) := 0;
    V_TOT_SAL_ALLOWANCE   NUMBER(9, 2) := 0;
    V_GROSS_PAY_AMT       NUMBER(9, 2) := 0;
    V_NET_PAY_AMT         NUMBER(9, 2) := 0;
    V_NET_DED_AMT         NUMBER(9, 2) := 0;
    V_ASON_DATE           DATE := TRUNC(SYSDATE);
    V_REMARKS_ALLOWANCE   VARCHAR2(100) := '';
    V_REMARKS_DEDUCTION   VARCHAR2(100) := '';
    PROCEDURE SP_SAL_CALC_INCRMNT(P_EMP_ID    IN VARCHAR2,
                                  P_BRN_TYPE  IN NUMBER,
                                  P_PRL_DAYS  IN NUMBER,
                                  P_ERROR_MSG OUT VARCHAR2) IS
    
      V_PREV_BASIC_TOTAL NUMBER(9, 2) := 0;
      V_PREV_BASIC_AMT   NUMBER(9, 2) := 0;
      V_CURR_BASIC_AMT   NUMBER(9, 2) := 0;
      V_DAYS_COUNT1      NUMBER(2) := 0;
      V_DAYS_COUNT2      NUMBER(2) := 0;
      V_DAYS_COUNT       NUMBER(2) := 0;
      V_HR_AMT1          NUMBER(9, 2) := 0;
      V_HR_AMT2          NUMBER(9, 2) := 0;
      V_BRN_TYPE         PRMS_MBRANCH.BRN_TYPE%TYPE;
      V_SQ_RESIDENCE     VARCHAR2(1) := '';
      V_PF_DED_AMT1      NUMBER(9, 2) := 0;
      V_PF_DED_AMT2      NUMBER(9, 2) := 0;
      V_PD_DED_PCT       NUMBER(9, 2) := 0;
      V_PF_LIEN          PRMS_EMP_SAL.PF_LIEN%TYPE;
      V_HBADV_DED        NUMBER(9, 2) := 0;
      V_PENSION_ALLN     NUMBER(9, 2) := 0;
      V_MONTH_CODE       NUMBER(2);
      V_SAL_YEAR         NUMBER(4);
      V_ASON_DATE        DATE := TRUNC(SYSDATE);
    BEGIN
      FOR IDX IN (SELECT * FROM PRMS_EMP_SAL S WHERE S.EMP_ID = P_EMP_ID) LOOP
      
        IF TO_DATE(LAST_DAY(IDX.TRANSFER_DATE)) =
           LAST_DAY(TRUNC(V_ASON_DATE)) THEN
          --TRANSFER OCCURED THIS MONTH
          SELECT EXTRACT(DAY FROM IDX.TRANSFER_DATE) - 1
            INTO V_DAYS_COUNT1
            FROM DUAL;
        
          SELECT EXTRACT(DAY FROM LAST_DAY(TRUNC(V_ASON_DATE)))
            INTO V_DAYS_COUNT
            FROM DUAL;
        
          IF P_PRL_DAYS > V_DAYS_COUNT1 THEN
            V_DAYS_COUNT2 := P_PRL_DAYS - V_DAYS_COUNT1;
          ELSE
            V_DAYS_COUNT2 := V_DAYS_COUNT - V_DAYS_COUNT1;
          END IF;
        
          SELECT NVL(H.NEW_BASIC, 0) + NVL(H.ARREAR_BASIC, 0),
                 SQ_RESIDENCE,
                 (SELECT M.BRN_TYPE
                    FROM PRMS_MBRANCH M
                   WHERE M.BRN_CODE = H.EMP_BRN_CODE) AS BRN_TYPE,
                 H.PF_LIEN,
                 H.PF_DEDUCTION_PCT
            INTO V_PREV_BASIC_TOTAL,
                 V_SQ_RESIDENCE,
                 V_BRN_TYPE,
                 V_PF_LIEN,
                 V_PD_DED_PCT
            FROM PRMS_EMP_SAL_HIST H
           WHERE H.EMP_ID = IDX.EMP_ID
             AND H.EFT_SERIAL =
                 (SELECT MAX(H.EFT_SERIAL) - 1
                    FROM PRMS_EMP_SAL_HIST H
                   WHERE H.EMP_ID = IDX.EMP_ID);
        
          V_PREV_BASIC_AMT := (V_PREV_BASIC_TOTAL * V_DAYS_COUNT1) /
                              V_DAYS_COUNT;
          V_CURR_BASIC_AMT := ((IDX.NEW_BASIC + IDX.ARREAR_BASIC) *
                              V_DAYS_COUNT2) / V_DAYS_COUNT;
        
          V_HR_AMT2 := FN_GET_HR_ALWNC(P_BRN_TYPE,
                                       (NVL(IDX.NEW_BASIC, 0) +
                                       NVL(IDX.ARREAR_BASIC, 0)),
                                       V_CURR_BASIC_AMT);
          V_HR_AMT1 := FN_GET_HR_ALWNC(V_BRN_TYPE,
                                       V_PREV_BASIC_TOTAL,
                                       V_PREV_BASIC_AMT);
        
          SELECT ROUND(((D.HBADV_DEDUC_PERCENT * (V_HR_AMT1 + V_HR_AMT2)) / 100),
                       2) + NVL(D.HB_ADV_DEDUC, 0)
            INTO V_HBADV_DED
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
        
          IF IDX.SQ_RESIDENCE = 'Y' THEN
            V_HR_AMT2 := 0;
          END IF;
        
          IF V_SQ_RESIDENCE = 'Y' THEN
            V_HR_AMT1 := 0;
          END IF;
        
          IF V_PF_LIEN = 'N' THEN
            V_PF_DED_AMT1 := 0;
          ELSE
            V_PF_DED_AMT1 := ROUND(V_PREV_BASIC_AMT * NVL(V_PD_DED_PCT, 0) / 100,
                                   2);
          END IF;
        
          IF IDX.PF_LIEN = 'N' THEN
            V_PF_DED_AMT2 := 0;
          ELSE
            V_PF_DED_AMT2 := ROUND(V_CURR_BASIC_AMT *
                                   NVL(IDX.PF_DEDUCTION_PCT, 0) / 100,
                                   2);
          END IF;
        
          V_PENSION_ALLN := NVL(ROUND((IDX.PEN_PCT *
                                      (V_CURR_BASIC_AMT + V_PREV_BASIC_AMT)) / 100,
                                      2),
                                0);
        
          SELECT TO_NUMBER(TO_CHAR(TO_DATE(V_ASON_DATE, 'dd-mon-yy'), 'mm'))
            INTO V_MONTH_CODE
            FROM DUAL;
          SELECT TO_NUMBER(TO_CHAR(V_ASON_DATE, 'YYYY'))
            INTO V_SAL_YEAR
            FROM DUAL;
        
          V_BASIC_AMT         := V_PREV_BASIC_AMT + V_CURR_BASIC_AMT;
          V_HR_ALWNC_AMT      := V_HR_AMT1 + V_HR_AMT2;
          V_PENSION_ALLOWANCE := V_PENSION_ALLN;
          V_PENSION_DEDUC     := V_PENSION_ALLOWANCE;
          V_HBADV_DEDUC       := V_HBADV_DED;
          V_PF_DED_AMT        := ROUND(V_PF_DED_AMT1 + V_PF_DED_AMT2);
        
          IF IDX.DESIG_CODE = '0' THEN
            V_HR_ALWNC_AMT      := 0;
            V_PENSION_ALLOWANCE := 0;
            V_PENSION_DEDUC     := 0;
          END IF;
        
        ELSE
          --NO TRANSFER OCCURED--
          V_BASIC_AMT := NVL(IDX.NEW_BASIC, 0) + NVL(IDX.ARREAR_BASIC, 0);
        
          V_HR_ALWNC_AMT := FN_GET_HR_ALWNC(P_BRN_TYPE,
                                            IDX.NEW_BASIC,
                                            V_BASIC_AMT);
          SELECT ROUND(((D.HBADV_DEDUC_PERCENT * V_HR_ALWNC_AMT) / 100), 2) +
                 NVL(D.HB_ADV_DEDUC, 0)
            INTO V_HBADV_DEDUC
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
        
          IF IDX.SQ_RESIDENCE <> 'Y' THEN
            NULL;
          ELSE
            V_HR_ALWNC_AMT := 0;
          END IF;
        
          BEGIN
            SELECT NVL(ROUND((PEN_PCT * V_BASIC_AMT) / 100, 2), 0)
              INTO V_PENSION_ALLOWANCE
              FROM PRMS_EMP_SAL
             WHERE EMP_ID = IDX.EMP_ID;
            V_PENSION_DEDUC := V_PENSION_ALLOWANCE;
          END;
          IF IDX.DESIG_CODE = '0' THEN
            V_HR_ALWNC_AMT      := 0;
            V_PENSION_ALLOWANCE := 0;
            V_PENSION_DEDUC     := 0;
          END IF;
        
          IF IDX.PF_LIEN = 'N' THEN
            V_PF_DED_AMT := 0;
          ELSE
            V_PF_DED_AMT := ROUND(V_BASIC_AMT *
                                  NVL(IDX.PF_DEDUCTION_PCT, 0) / 100,
                                  2);
          END IF;
        
        END IF;
      
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        P_ERROR_MSG := 'ERROR IN SP_SAL_CALC_INCRMNT: ' || SQLERRM;
    END SP_SAL_CALC_INCRMNT;
  
  BEGIN
    --- DBMS_OUTPUT.PUT_LINE('SALARY CALCULATED');
  
    SELECT LAST_DAY(TRUNC(SYSDATE)) INTO V_CBD_LAST_DATE FROM DUAL;
    SELECT EXTRACT(DAY FROM V_CBD_LAST_DATE) INTO V_CBD_LAST_DAY FROM DUAL;
  
    SELECT UPPER(TO_CHAR(V_ASON_DATE, 'Month')) INTO V_SAL_MONTH FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(V_ASON_DATE, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(V_ASON_DATE, 'YYYY'))
      INTO V_SAL_YEAR
      FROM DUAL;
    ----------------DELETE CURRENT MONTH SALARY FOR RE-GENERATING IT.
    DELETE FROM PRMS_TRANSACTION T
     WHERE T.ENTITY_NUMBER = 1
       AND T.SAL_YEAR = V_SAL_YEAR
       AND T.MONTH_CODE = V_MONTH_CODE;
    ----------------DELETE CURRENT MONTH SALARY FOR RE-GENERATING IT.
  
    --MAIN LOOP--
    FOR ID IN (SELECT *
                 FROM PRMS_EMP_SAL S
                 JOIN PRMS_MBRANCH B
                   ON (S.EMP_BRN_CODE = B.BRN_CODE)
                WHERE TRIM(S.ACC_NO_ACTIVE) <> 'N'
                     -- AND S.EMP_ID = '913'
                  AND (SELECT PRMS_EMPLOYEE.DOB
                         FROM PRMS_EMPLOYEE
                        WHERE PRMS_EMPLOYEE.EMP_ID = S.EMP_ID) IS NOT NULL) LOOP
    
      IF ID.DESIG_CODE = '0' THEN
        V_MIN_WELFARE_DED_AMT := 0;
        V_MIN_INS_DED_AMT     := 0;
      ELSIF ID.DESIG_CODE = '1' THEN
        V_MIN_WELFARE_DED_AMT := 50;
        V_MIN_INS_DED_AMT     := 0;
      ELSE
        V_MIN_WELFARE_DED_AMT := 50;
        V_MIN_INS_DED_AMT     := 40;
      END IF;
      BEGIN
        SELECT ADD_MONTHS(DOB, 59 * 12)
          INTO T_LPR_DATE
          FROM PRMS_EMPLOYEE
         WHERE EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          T_LPR_DATE := ID.LPR_LAST_DATE;
      END;
    
      ---ALWOANCE
    
      V_MED_ALWNC_AMT := ID.MEDICAL_ALLOWANCE;
    
      BEGIN
        SELECT A.TEL_ALLOWANCE,
               A.TRANS_ALLOWANCE,
               A.EDU_ALLOWANCE,
               A.WASH_ALLOWANCE,
               A.DOMES_ALLOWANCE,
               A.HILL_ALLWNC,
               A.ENTERTAIN_ALLOWANCE,
               A.OTHER_ALLOWANCE,
               A.REMARKS
          INTO V_TEL_ALWNC_AMT,
               V_TRANS_ALLOWANCE,
               V_EDU_ALLOWANCE,
               V_WASH_ALLOWANCE,
               V_DOMESTIC_ALLOWANCE,
               V_HILL_ALLWNC,
               V_ENTERTAINMENT,
               V_OTHER_ALLOWANCE,
               V_REMARKS_ALLOWANCE
        
          FROM PRMS_ALLOWANCE A
         WHERE A.EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('NO ALLOWANCE DATA FOUND FOR THIS EMPLOYEE: ' ||
                               ID.EMP_ID);
          --RAISE V_EXCEPTION;
      END;
    
      IF LAST_DAY(T_LPR_DATE) = V_CBD_LAST_DATE THEN
      
        SELECT EXTRACT(DAY FROM T_LPR_DATE) INTO T_LPR_DAY FROM DUAL;
      
        SP_SAL_CALC_INCRMNT(ID.EMP_ID, ID.BRN_TYPE, T_LPR_DAY, P_ERROR_MSG);
        V_MIN_WELFARE_DED_AMT := (V_MIN_WELFARE_DED_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_MIN_INS_DED_AMT     := (V_MIN_INS_DED_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_BASIC_AMT           := (V_BASIC_AMT * T_LPR_DAY) / V_CBD_LAST_DAY;
        V_MED_ALWNC_AMT       := (V_MED_ALWNC_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_TRANS_ALLOWANCE     := (V_TRANS_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_EDU_ALLOWANCE       := (V_EDU_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_WASH_ALLOWANCE      := (V_WASH_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_DOMESTIC_ALLOWANCE  := (V_DOMESTIC_ALLOWANCE * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_CARFARE_DEDUC       := (V_CARFARE_DEDUC * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_NEWS_PAPER_DEDUC    := (V_NEWS_PAPER_DEDUC * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
      
      ELSE
        SP_SAL_CALC_INCRMNT(ID.EMP_ID, ID.BRN_TYPE, 0, P_ERROR_MSG);
      END IF;
    
      -------------------------------------------------------------------------------------------------------------
      --                              PRL ARENA
      -------------------------------------------------------------------------------------------------------------
      /*IF T_LPR_DATE < V_CBD_LAST_DATE THEN
        --IF '25-FEB-2019' < '28-FEB-2019' THEN
        SELECT EXTRACT(DAY FROM T_LPR_DATE) INTO T_LPR_DAY FROM DUAL;
      
      
        --  V_HR_ALWNC_AMT := (V_HR_ALWNC_AMT * T_LPR_DAY) / V_CBD_LAST_DAY;
      END IF;*/
      -------------------------------------------------------------------------------------------------------------
    
      ---DEDUCTION
      BEGIN
        SELECT D.MCYCLE_DEDUC,
               D.BCYCLE_DEDUC,
               D.PFADV_DEDUC,
               D.REVENUE,
               D.CAR_FARE,
               D.CAR_USE,
               D.GAS_BILL,
               D.WATER_BILL,
               D.ELECT_BILL,
               D.NEWS_PAPER,
               D.HBADV_ARREAR,
               D.PFADV_ARREAR,
               D.TEL_EXCESS_BILL,
               D.OTHER_DEDUC,
               D.REMARKS,
               D.COMP_DEDUC,
               D.HBADV_DEDUC_PERCENT,
               D.INCOME_TAX,
               D.INCOME_TAX_ARR
          INTO V_MCYCLE_DEDUC,
               V_BICYCLE_DEDUC,
               V_PFADV_DEDUC,
               V_REVENUE_DEDUC,
               V_CARFARE_DEDUC,
               V_CARUSE_DEDUC,
               V_GAS_BILL,
               V_WATER_BILL,
               V_ELECTRICITY_BILL,
               V_NEWS_PAPER_DEDUC,
               V_HBADV_ARREAR_DEDUC,
               V_PFADV_ARREAR_DEDUC,
               V_TEL_EXCESS_BILL,
               V_OTHER_DEDUC,
               V_REMARKS_DEDUCTION,
               V_COMP_DEDUC,
               V_HBADV_DEDUC_PERCENT,
               V_INCOME_TAX,
               V_INCOME_TAX_ARR
          FROM PRMS_DEDUC D
         WHERE D.EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('NO DEDUCTION DATA FOUND FOR THIS EMPLOYEE: ' ||
                               ID.EMP_ID);
          --RAISE V_EXCEPTION;
      END;
    
      SELECT D.DESIGNATION_CATEGORY
        INTO V_DESIG_CATAGORY
        FROM PRMS_DESIGNATION D
       WHERE D.DESIGNATION_CODE = ID.DESIG_CODE;
    
      V_WELFARE_DED_AMT := GET_MIN_AMT(ROUND(V_BASIC_AMT * 0.01, 2),
                                       V_MIN_WELFARE_DED_AMT);
    
      IF V_DESIG_CATAGORY <> 1 THEN
        V_INS_DED_AMT := 0;
      ELSE
      
        V_INS_DED_AMT := GET_MIN_AMT(ROUND(V_BASIC_AMT * 0.007, 2),
                                     V_MIN_INS_DED_AMT);
      END IF;
    
      IF P_SALCODE = 'SPECIAL' THEN
        V_HBADV_DEDUC   := 0;
        V_MCYCLE_DEDUC  := 0;
        V_BICYCLE_DEDUC := 0;
        V_PFADV_DEDUC   := 0;
        V_COMP_DEDUC    := 0;
      END IF;
    
      V_TOT_SAL_ALLOWANCE := NVL(V_BASIC_AMT, 0) + NVL(V_MED_ALWNC_AMT, 0) +
                             NVL(V_HR_ALWNC_AMT, 0) +
                             NVL(V_TEL_ALWNC_AMT, 0) +
                             NVL(V_TRANS_ALLOWANCE, 0) +
                             NVL(V_EDU_ALLOWANCE, 0) +
                             NVL(V_WASH_ALLOWANCE, 0) +
                             NVL(V_ENTERTAINMENT, 0) +
                             NVL(V_DOMESTIC_ALLOWANCE, 0) +
                             NVL(V_OTHER_ALLOWANCE, 0) +
                             NVL(V_DREANESS_ALLWNC, 0) +
                             NVL(V_HILL_ALLWNC, 0);
    
      V_GROSS_PAY_AMT := V_TOT_SAL_ALLOWANCE + V_PENSION_ALLOWANCE;
    
      V_NET_DED_AMT := NVL(V_HBADV_DEDUC, 0) + NVL(V_MCYCLE_DEDUC, 0) +
                       NVL(V_BICYCLE_DEDUC, 0) + NVL(V_PFADV_DEDUC, 0) +
                       NVL(V_HBADV_ARREAR_DEDUC, 0) +
                       NVL(V_PFADV_ARREAR_DEDUC, 0) +
                       NVL(V_TEL_EXCESS_BILL, 0) + NVL(V_OTHER_DEDUC, 0) +
                       NVL(V_COMP_DEDUC, 0) + NVL(V_REVENUE_DEDUC, 0) +
                       NVL(V_CARFARE_DEDUC, 0) + NVL(V_CARUSE_DEDUC, 0) +
                       NVL(V_GAS_BILL, 0) + NVL(V_WATER_BILL, 0) +
                       NVL(V_ELECTRICITY_BILL, 0) +
                       NVL(V_HOUSE_RENT_DEDUC, 0) +
                       NVL(V_NEWS_PAPER_DEDUC, 0) +
                       NVL(V_WELFARE_DED_AMT, 0) + NVL(V_INS_DED_AMT, 0) +
                       NVL(V_PF_DED_AMT, 0) + NVL(V_INCOME_TAX, 0) +
                       NVL(V_INCOME_TAX_ARR, 0);
      V_NET_PAY_AMT := V_TOT_SAL_ALLOWANCE - V_NET_DED_AMT;
      ---------------------------INSERTION INTO TRANSACTION TABLE-------------------------------
      INSERT INTO PRMS_TRANSACTION
        (ENTITY_NUMBER,
         BRANCH_CODE,
         EMP_ID,
         SAL_YEAR,
         MONTH_CODE,
         SAL_MONTH,
         BASIC_PAY,
         MEDICAL_ALLOWANCE,
         HOUSE_RENT_ALLOWANCE,
         TEL_ALLOWANCE,
         TRANS_ALLOWANCE,
         EDU_ALLOWANCE,
         WASH_ALLOWANCE,
         PENSION_ALLOWANCE,
         ENTERTAINMENT,
         DOMESTIC_ALLOWANCE,
         OTHER_ALLOWANCE,
         GROSS_PAY_AMT,
         HBADV_DEDUC,
         MCYCLE_DEDUC,
         BICYCLE_DEDUC,
         PFADV_DEDUC,
         PENSION_DEDUC,
         REVENUE_DEDUC,
         WELFARE_DEDUC,
         CARFARE_DEDUC,
         CARUSE_DEDUC,
         GAS_BILL,
         WATER_BILL,
         ELECTRICITY_BILL,
         HOUSE_RENT_DEDUC,
         NEWS_PAPER_DEDUC,
         PF_DEDUCTION,
         NET_DED_AMT,
         NET_PAY_AMT,
         HBADV_ARREAR_DEDUC,
         PFADV_ARREAR_DEDUC,
         TEL_EXCESS_BILL,
         GEN_INSURENCE,
         /*SP_DEDUC,
         SP_DESCRIPTION,
         TREMARKS,*/
         ARREAR,
         OTHER_DEDUC,
         HBADV_DEDUC_PERCENT,
         TOT_SAL_ALLOWANCE,
         ARREAR_BASIC,
         /*  INSTL_AMT_TLO,
         INSTL_AMT_TLR,
         INSTL_AMT_INS,
         INSTL_AMT_INC,
         OFFICE_CODE,*/
         COMP_DEDUC,
         DEARNESS_ALLOWANCE,
         GENERATED_BY,
         GENERATED_ON,
         INCOME_TAX,
         INCOME_TAX_ARR,
         HILL_ALLWNC,
         ACTUAL_BASIC,
         DEDUCTION_REMARKS,
         ALLOWANCE_REMARKS)
      VALUES
        (P_ENTITY_NUM,
         ID.EMP_BRN_CODE,
         ID.EMP_ID,
         V_SAL_YEAR,
         V_MONTH_CODE,
         V_SAL_MONTH,
         ID.NEW_BASIC,
         V_MED_ALWNC_AMT,
         NVL(V_HR_ALWNC_AMT, 0),
         NVL(V_TEL_ALWNC_AMT, 0),
         NVL(V_TRANS_ALLOWANCE, 0),
         NVL(V_EDU_ALLOWANCE, 0),
         NVL(V_WASH_ALLOWANCE, 0),
         NVL(V_PENSION_ALLOWANCE, 0),
         NVL(V_ENTERTAINMENT, 0),
         NVL(V_DOMESTIC_ALLOWANCE, 0),
         NVL(V_OTHER_ALLOWANCE, 0),
         V_GROSS_PAY_AMT,
         NVL(V_HBADV_DEDUC, 0),
         NVL(V_MCYCLE_DEDUC, 0),
         NVL(V_BICYCLE_DEDUC, 0),
         NVL(V_PFADV_DEDUC, 0),
         NVL(V_PENSION_DEDUC, 0),
         NVL(V_REVENUE_DEDUC, 0),
         NVL(V_WELFARE_DED_AMT, 0),
         NVL(V_CARFARE_DEDUC, 0),
         NVL(V_CARUSE_DEDUC, 0),
         NVL(V_GAS_BILL, 0),
         NVL(V_WATER_BILL, 0),
         NVL(V_ELECTRICITY_BILL, 0),
         NVL(V_HOUSE_RENT_DEDUC, 0),
         NVL(V_NEWS_PAPER_DEDUC, 0),
         NVL(V_PF_DED_AMT, 0),
         V_NET_DED_AMT,
         V_NET_PAY_AMT,
         NVL(V_HBADV_ARREAR_DEDUC, 0),
         NVL(V_PFADV_ARREAR_DEDUC, 0),
         NVL(V_TEL_EXCESS_BILL, 0),
         NVL(V_INS_DED_AMT, 0),
         0, -----AREAR OTHER
         NVL(V_OTHER_DEDUC, 0),
         NVL(V_HBADV_DEDUC_PERCENT, 0),
         V_TOT_SAL_ALLOWANCE,
         NVL(ID.ARREAR_BASIC, 0),
         NVL(V_COMP_DEDUC, 0),
         NVL(V_DREANESS_ALLWNC, 0),
         P_USER_ID,
         V_ASON_DATE,
         NVL(V_INCOME_TAX, 0),
         NVL(V_INCOME_TAX_ARR, 0),
         NVL(V_HILL_ALLWNC, 0),
         ID.NEW_BASIC,
         V_REMARKS_DEDUCTION,
         V_REMARKS_ALLOWANCE);
      --EXCEPTION WHEN OTHERS
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR_MSG := 'ERROR IN SP_SALARY_CALCULATION: ' || SQLERRM;
      ROLLBACK;
  END SP_SALARY_CALCULATION;

  PROCEDURE SP_SALARY_CALCULATION_NEW(P_ENTITY_NUM IN NUMBER,
                                      P_USER_ID    IN VARCHAR2,
                                      P_SALCODE    IN VARCHAR2,
                                      P_ERROR_MSG  OUT VARCHAR2) IS
  
    V_BASIC_AMT           NUMBER(9, 2) := 0;
    V_AREARBASIC_AMT      NUMBER(9, 2) := 0;
    V_HR_ALWNC_AMT        NUMBER(9, 2) := 0;
    V_PENSION_ALLOWANCE   NUMBER(9, 2) := 0;
    V_HBADV_DEDUC         NUMBER(9, 2) := 0;
    V_PF_DED_AMT          NUMBER(9, 2) := 0;
    V_FRACTION_AMT        NUMBER(5, 2) := 0;
    V_DESIG_CATAGORY      NUMBER(2);
    V_MIN_WELFARE_DED_AMT NUMBER(9, 2) := 0;
    V_MIN_INS_DED_AMT     NUMBER(9, 2) := 0;
    V_CBD_LAST_DATE       DATE;
    V_CBD_LAST_DAY        NUMBER(2) := 0;
    T_LPR_DATE            DATE;
    T_LPR_DAY             NUMBER(2) := 0;
    V_EXCEPTION EXCEPTION;
    V_MONTH_CODE NUMBER(2);
    V_SAL_YEAR   NUMBER(4);
    V_SAL_MONTH  VARCHAR2(10) := '';
  
    V_MED_ALWNC_AMT      NUMBER(9, 2) := 0;
    V_TEL_ALWNC_AMT      NUMBER(9, 2) := 0;
    V_TRANS_ALLOWANCE    NUMBER(9, 2) := 0;
    V_EDU_ALLOWANCE      NUMBER(9, 2) := 0;
    V_WASH_ALLOWANCE     NUMBER(9, 2) := 0;
    V_ENTERTAINMENT      NUMBER(9, 2) := 0;
    V_DOMESTIC_ALLOWANCE NUMBER(9, 2) := 0;
    V_OTHER_ALLOWANCE    NUMBER(9, 2) := 0;
    V_DREANESS_ALLWNC    NUMBER(9, 2) := 0;
    V_HILL_ALLWNC        NUMBER(9, 2) := 0;
  
    V_MCYCLE_DEDUC        NUMBER(9, 2) := 0;
    V_BICYCLE_DEDUC       NUMBER(9, 2) := 0;
    V_PFADV_DEDUC         NUMBER(9, 2) := 0;
    V_HBADV_ARREAR_DEDUC  NUMBER(9, 2) := 0;
    V_PFADV_ARREAR_DEDUC  NUMBER(9, 2) := 0;
    V_TEL_EXCESS_BILL     NUMBER(9, 2) := 0;
    V_OTHER_DEDUC         NUMBER(9, 2) := 0;
    V_COMP_DEDUC          NUMBER(9, 2) := 0;
    V_PENSION_DEDUC       NUMBER(9, 2) := 0;
    V_REVENUE_DEDUC       NUMBER(9, 2) := 0;
    V_CARFARE_DEDUC       NUMBER(9, 2) := 0;
    V_CARUSE_DEDUC        NUMBER(9, 2) := 0;
    V_HBADV_DEDUC_PERCENT NUMBER(9, 2) := 0;
    V_GAS_BILL            NUMBER(9, 2) := 0;
    V_WATER_BILL          NUMBER(9, 2) := 0;
    V_ELECTRICITY_BILL    NUMBER(9, 2) := 0;
    V_HOUSE_RENT_DEDUC    NUMBER(9, 2) := 0;
    V_NEWS_PAPER_DEDUC    NUMBER(9, 2) := 0;
    V_WELFARE_DED_AMT     NUMBER(9, 2) := 0;
    V_INS_DED_AMT         NUMBER(9, 2) := 0;
    V_INCOME_TAX          NUMBER(9, 2) := 0;
    V_INCOME_TAX_ARR      NUMBER(9, 2) := 0;
    V_TOT_SAL_ALLOWANCE   NUMBER(9, 2) := 0;
    V_GROSS_PAY_AMT       NUMBER(9, 2) := 0;
    V_NET_PAY_AMT         NUMBER(9, 2) := 0;
    V_NET_DED_AMT         NUMBER(9, 2) := 0;
    V_ASON_DATE           DATE := TRUNC(SYSDATE);
    V_REMARKS_ALLOWANCE   VARCHAR2(100) := '';
    V_REMARKS_DEDUCTION   VARCHAR2(100) := '';
    V_HR_ARREAR_ALW       NUMBER(9, 2) := 0;
    V_HR_ARREAR_DED       NUMBER(9, 2) := 0;
  
    PROCEDURE SP_SAL_CALC_INCRMNT(P_EMP_ID    IN VARCHAR2,
                                  P_BRN_TYPE  IN NUMBER,
                                  P_PRL_DAYS  IN NUMBER,
                                  P_ERROR_MSG OUT VARCHAR2) IS
    
      V_PREV_BASIC_TOTAL NUMBER(9, 2) := 0;
      V_PREV_BASIC_AMT   NUMBER(9, 2) := 0;
      V_CURR_BASIC_AMT   NUMBER(9, 2) := 0;
      V_DAYS_COUNT1      NUMBER(2) := 0;
      V_DAYS_COUNT2      NUMBER(2) := 0;
      V_DAYS_COUNT       NUMBER(2) := 0;
      V_HR_AMT1          NUMBER(9, 2) := 0;
      V_HR_AMT2          NUMBER(9, 2) := 0;
      V_BRN_TYPE         PRMS_MBRANCH.BRN_TYPE%TYPE;
      V_SQ_RESIDENCE     VARCHAR2(1) := '';
      V_PF_DED_AMT1      NUMBER(9) := 0;
      V_PF_DED_AMT2      NUMBER(9) := 0;
      V_PD_DED_PCT       NUMBER(9, 2) := 0;
      V_PF_LIEN          PRMS_EMP_SAL.PF_LIEN%TYPE;
      V_HBADV_DED        NUMBER(9, 2) := 0;
      V_PENSION_ALLN     NUMBER(9, 2) := 0;
      V_MONTH_CODE       NUMBER(2);
      V_SAL_YEAR         NUMBER(4);
      V_ASON_DATE        DATE := TRUNC(SYSDATE);
    
      W_HR_ARREAR_ALW NUMBER(9, 2) := 0;
      W_HR_ARREAR_DED NUMBER(9, 2) := 0;
    BEGIN
      FOR IDX IN (SELECT * FROM PRMS_EMP_SAL S WHERE S.EMP_ID = P_EMP_ID) LOOP
      
        IF TO_DATE(LAST_DAY(IDX.TRANSFER_DATE)) =
           LAST_DAY(TRUNC(V_ASON_DATE)) THEN
          --TRANSFER OCCURED THIS MONTH
          SELECT EXTRACT(DAY FROM IDX.TRANSFER_DATE) - 1
            INTO V_DAYS_COUNT1
            FROM DUAL;
        
          SELECT EXTRACT(DAY FROM LAST_DAY(TRUNC(V_ASON_DATE)))
            INTO V_DAYS_COUNT
            FROM DUAL;
        
          IF P_PRL_DAYS > V_DAYS_COUNT1 THEN
            V_DAYS_COUNT2 := P_PRL_DAYS - V_DAYS_COUNT1;
          ELSE
            V_DAYS_COUNT2 := V_DAYS_COUNT - V_DAYS_COUNT1;
          END IF;
          SELECT NVL(H.NEW_BASIC, 0),
                 SQ_RESIDENCE,
                 (SELECT M.BRN_TYPE
                    FROM PRMS_MBRANCH M
                   WHERE M.BRN_CODE = H.EMP_BRN_CODE) AS BRN_TYPE,
                 H.PF_LIEN,
                 H.PF_DEDUCTION_PCT
            INTO V_PREV_BASIC_TOTAL,
                 V_SQ_RESIDENCE,
                 V_BRN_TYPE,
                 V_PF_LIEN,
                 V_PD_DED_PCT
            FROM PRMS_EMP_SAL_HIST H
           WHERE H.EMP_ID = IDX.EMP_ID
             AND H.EFT_SERIAL =
                 (SELECT MAX(H.EFT_SERIAL) - 1
                    FROM PRMS_EMP_SAL_HIST H
                   WHERE H.EMP_ID = IDX.EMP_ID);
        
          V_PREV_BASIC_AMT := (V_PREV_BASIC_TOTAL * V_DAYS_COUNT1) /
                              V_DAYS_COUNT;
          V_CURR_BASIC_AMT := ((IDX.NEW_BASIC) * V_DAYS_COUNT2) /
                              V_DAYS_COUNT;
        
          V_HR_AMT2 := FN_GET_HR_ALWNC(P_BRN_TYPE,
                                       NVL(IDX.NEW_BASIC, 0),
                                       V_CURR_BASIC_AMT);
          V_HR_AMT1 := FN_GET_HR_ALWNC(V_BRN_TYPE,
                                       V_PREV_BASIC_TOTAL,
                                       V_PREV_BASIC_AMT);
        
          SELECT NVL(D.HR_AREAR_DED, 0)
            INTO W_HR_ARREAR_DED
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
          SELECT NVL(A.HR_AREAR_ALW, 0)
            INTO W_HR_ARREAR_ALW
            FROM PRMS_ALLOWANCE A
           WHERE A.EMP_ID = IDX.EMP_ID;
        
          IF IDX.SQ_RESIDENCE = 'Y' THEN
            V_HR_AMT2 := 0;
          END IF;
        
          IF V_SQ_RESIDENCE = 'Y' THEN
            V_HR_AMT1 := 0;
          END IF;
        
          IF V_PF_LIEN = 'N' THEN
            V_PF_DED_AMT1 := 0;
          ELSE
            V_PF_DED_AMT1 := (V_PREV_BASIC_AMT * NVL(V_PD_DED_PCT, 0) / 100);
          END IF;
        
          IF IDX.PF_LIEN = 'N' THEN
            V_PF_DED_AMT2 := 0;
          ELSE
            V_PF_DED_AMT2 := ((V_CURR_BASIC_AMT + IDX.ARREAR_BASIC) *
                             NVL(IDX.PF_DEDUCTION_PCT, 0) / 100);
          END IF;
        
          SELECT TO_NUMBER(TO_CHAR(TO_DATE(V_ASON_DATE, 'dd-mon-yy'), 'mm'))
            INTO V_MONTH_CODE
            FROM DUAL;
          SELECT TO_NUMBER(TO_CHAR(V_ASON_DATE, 'YYYY'))
            INTO V_SAL_YEAR
            FROM DUAL;
          V_BASIC_AMT      := V_PREV_BASIC_AMT + V_CURR_BASIC_AMT;
          V_AREARBASIC_AMT := NVL(IDX.ARREAR_BASIC, 0);
          V_HR_ALWNC_AMT   := V_HR_AMT1 + V_HR_AMT2 + W_HR_ARREAR_ALW -
                              W_HR_ARREAR_DED;
        
          V_PENSION_ALLN := NVL(ROUND((IDX.PEN_PCT * V_BASIC_AMT) / 100, 2),
                                0);
        
          SELECT ROUND(((D.HBADV_DEDUC_PERCENT * V_HR_ALWNC_AMT) / 100), 2) +
                 NVL(D.HB_ADV_DEDUC, 0)
            INTO V_HBADV_DED
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
        
          V_PENSION_ALLOWANCE := V_PENSION_ALLN;
          V_PENSION_DEDUC     := V_PENSION_ALLOWANCE;
          V_HBADV_DEDUC       := V_HBADV_DED;
          V_PF_DED_AMT        := ROUND((V_PF_DED_AMT1 + V_PF_DED_AMT2), 2);
        
          IF IDX.DESIG_CODE = '0' THEN
            V_HR_ALWNC_AMT      := 0;
            V_PENSION_ALLOWANCE := 0;
            V_PENSION_DEDUC     := 0;
          END IF;
        
        ELSE
          --NO TRANSFER OCCURED--
          SELECT NVL(D.HR_AREAR_DED, 0)
            INTO W_HR_ARREAR_DED
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
          SELECT NVL(A.HR_AREAR_ALW, 0)
            INTO W_HR_ARREAR_ALW
            FROM PRMS_ALLOWANCE A
           WHERE A.EMP_ID = IDX.EMP_ID;
        
          V_BASIC_AMT      := NVL(IDX.NEW_BASIC, 0);
          V_AREARBASIC_AMT := NVL(IDX.ARREAR_BASIC, 0);
          --  V_ARRAR_BASIC:= NVL(IDX.ARREAR_BASIC, 0) ;    
          -- V_ARRAR_BASIC:=NVL(IDX.ARREAR_BASIC, 0);
          V_HR_ALWNC_AMT := FN_GET_HR_ALWNC(P_BRN_TYPE,
                                            IDX.NEW_BASIC,
                                            IDX.NEW_BASIC) +
                            W_HR_ARREAR_ALW - W_HR_ARREAR_DED;
        
          SELECT ROUND(((D.HBADV_DEDUC_PERCENT * (V_HR_ALWNC_AMT)) / 100),
                       2) + NVL(D.HB_ADV_DEDUC, 0)
            INTO V_HBADV_DEDUC
            FROM PRMS_DEDUC D
           WHERE D.EMP_ID = IDX.EMP_ID;
        
          IF IDX.SQ_RESIDENCE <> 'Y' THEN
            NULL;
          ELSE
            V_HR_ALWNC_AMT := 0;
          
          END IF;
          
           IF IDX.ACC_NO_ACTIVE = 'K' THEN
            V_HR_ALWNC_AMT:=ROUND(V_BASIC_AMT * 0.45, 2);
          END IF;
          
          IF IDX.ACC_NO_ACTIVE = 'S' or IDX.ACC_NO_ACTIVE = 'K' THEN
            V_BASIC_AMT := ROUND(V_BASIC_AMT * 0.5, 2);
          END IF;
        
          BEGIN
            SELECT NVL(ROUND((PEN_PCT * (V_BASIC_AMT + V_AREARBASIC_AMT)) / 100,
                             2),
                       0)
              INTO V_PENSION_ALLOWANCE
              FROM PRMS_EMP_SAL
             WHERE EMP_ID = IDX.EMP_ID;
            V_PENSION_DEDUC := V_PENSION_ALLOWANCE;
          END;
          IF IDX.DESIG_CODE = '0' THEN
            V_HR_ALWNC_AMT      := 0;
            V_PENSION_ALLOWANCE := 0;
            V_PENSION_DEDUC     := 0;
          END IF;
        
          IF IDX.PF_LIEN = 'N' THEN
            V_PF_DED_AMT := 0;
          ELSE
            V_PF_DED_AMT := Round((V_BASIC_AMT + V_AREARBASIC_AMT) *
                                  NVL(IDX.PF_DEDUCTION_PCT, 0) / 100,
                                  2);
          END IF;
        END IF;
      
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        P_ERROR_MSG := 'ERROR IN SP_SAL_CALC_INCRMNT: ' || SQLERRM;
    END SP_SAL_CALC_INCRMNT;
  
  BEGIN
    --- DBMS_OUTPUT.PUT_LINE('SALARY CALCULATED');
  
    SELECT LAST_DAY(TRUNC(SYSDATE)) INTO V_CBD_LAST_DATE FROM DUAL;
    SELECT EXTRACT(DAY FROM V_CBD_LAST_DATE) INTO V_CBD_LAST_DAY FROM DUAL;
  
    SELECT UPPER(TO_CHAR(V_ASON_DATE, 'Month')) INTO V_SAL_MONTH FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(V_ASON_DATE, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(V_ASON_DATE, 'YYYY'))
      INTO V_SAL_YEAR
      FROM DUAL;
    ----------------DELETE CURRENT MONTH SALARY FOR RE-GENERATING IT.
    DELETE FROM PRMS_TRANSACTION T
     WHERE T.ENTITY_NUMBER = 1
       AND T.SAL_YEAR = V_SAL_YEAR
       AND T.MONTH_CODE = V_MONTH_CODE;
    ----------------DELETE CURRENT MONTH SALARY FOR RE-GENERATING IT.
  
    --MAIN LOOP--
    FOR ID IN (SELECT *
                 FROM PRMS_EMP_SAL S
                 JOIN PRMS_MBRANCH B
                   ON (S.EMP_BRN_CODE = B.BRN_CODE)
                WHERE TRIM(S.ACC_NO_ACTIVE) <> 'N'
                     --  AND S.EMP_ID = '778'
                  AND (SELECT PRMS_EMPLOYEE.DOB
                         FROM PRMS_EMPLOYEE
                        WHERE PRMS_EMPLOYEE.EMP_ID = S.EMP_ID) IS NOT NULL) LOOP
    
      select WELFARE, GEN_INSURANCE
        into V_MIN_WELFARE_DED_AMT, V_MIN_INS_DED_AMT
        from prms_deduc d
       where d.emp_id = id.emp_id;
    
      IF ID.DESIG_CODE = '0' THEN
        V_MIN_WELFARE_DED_AMT := 0;
        V_MIN_INS_DED_AMT     := 0;
      ELSIF ID.DESIG_CODE = '1' THEN
        V_MIN_WELFARE_DED_AMT := 50;
        --  V_MIN_INS_DED_AMT     := 0;
      ELSE
        V_MIN_WELFARE_DED_AMT := V_MIN_WELFARE_DED_AMT;
        V_MIN_INS_DED_AMT     := V_MIN_INS_DED_AMT;
      END IF;
      BEGIN
        SELECT ADD_MONTHS(DOB, 60 * 12)
          INTO T_LPR_DATE
          FROM PRMS_EMPLOYEE
         WHERE EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          T_LPR_DATE := ID.LPR_LAST_DATE;
      END;
    
      ---ALWOANCE
    
      V_MED_ALWNC_AMT := ID.MEDICAL_ALLOWANCE;
    
      BEGIN
        SELECT A.TEL_ALLOWANCE,
               A.TRANS_ALLOWANCE,
               A.EDU_ALLOWANCE,
               A.WASH_ALLOWANCE,
               A.DOMES_ALLOWANCE,
               A.HILL_ALLWNC,
               A.ENTERTAIN_ALLOWANCE,
               A.OTHER_ALLOWANCE,
               A.REMARKS,
               NVL(A.HR_AREAR_ALW, 0)
          INTO V_TEL_ALWNC_AMT,
               V_TRANS_ALLOWANCE,
               V_EDU_ALLOWANCE,
               V_WASH_ALLOWANCE,
               V_DOMESTIC_ALLOWANCE,
               V_HILL_ALLWNC,
               V_ENTERTAINMENT,
               V_OTHER_ALLOWANCE,
               V_REMARKS_ALLOWANCE,
               V_HR_ARREAR_ALW
          FROM PRMS_ALLOWANCE A
         WHERE A.EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('NO ALLOWANCE DATA FOUND FOR THIS EMPLOYEE: ' ||
                               ID.EMP_ID);
          --RAISE V_EXCEPTION;
      END;
    
      IF TO_CHAR(LAST_DAY(T_LPR_DATE)) = TO_CHAR(V_CBD_LAST_DATE) THEN
      
        SELECT EXTRACT(DAY FROM T_LPR_DATE) INTO T_LPR_DAY FROM DUAL;
      
        SP_SAL_CALC_INCRMNT(ID.EMP_ID, ID.BRN_TYPE, T_LPR_DAY, P_ERROR_MSG);
        /* V_MIN_WELFARE_DED_AMT := (V_MIN_WELFARE_DED_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;
        V_MIN_INS_DED_AMT     := (V_MIN_INS_DED_AMT * T_LPR_DAY) /
                                 V_CBD_LAST_DAY;*/
        V_HR_ALWNC_AMT       := (V_HR_ALWNC_AMT * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
        V_BASIC_AMT          := (V_BASIC_AMT * T_LPR_DAY) / V_CBD_LAST_DAY;
        V_MED_ALWNC_AMT      := (V_MED_ALWNC_AMT * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
        V_TRANS_ALLOWANCE    := (V_TRANS_ALLOWANCE * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
        V_EDU_ALLOWANCE      := (V_EDU_ALLOWANCE * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
        V_WASH_ALLOWANCE     := (V_WASH_ALLOWANCE * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
        V_DOMESTIC_ALLOWANCE := (V_DOMESTIC_ALLOWANCE * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
        V_CARFARE_DEDUC      := (V_CARFARE_DEDUC * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
        V_NEWS_PAPER_DEDUC   := (V_NEWS_PAPER_DEDUC * T_LPR_DAY) /
                                V_CBD_LAST_DAY;
      
        V_PENSION_ALLOWANCE := (V_PENSION_ALLOWANCE * T_LPR_DAY) /
                               V_CBD_LAST_DAY;
        V_PENSION_DEDUC     := V_PENSION_ALLOWANCE;
        V_HBADV_DEDUC       := (V_HBADV_DEDUC * T_LPR_DAY) / V_CBD_LAST_DAY;
        V_PF_DED_AMT        := round((V_PF_DED_AMT * T_LPR_DAY) /
                                     V_CBD_LAST_DAY,
                                     0);
      
      ELSE
        SP_SAL_CALC_INCRMNT(ID.EMP_ID, ID.BRN_TYPE, 0, P_ERROR_MSG);
      END IF;
    
      /*PF FRACTION ISSUE*/
      V_FRACTION_AMT := V_PF_DED_AMT - TRUNC(V_PF_DED_AMT, 0);
    
      IF V_FRACTION_AMT < 0.50 THEN
        V_PF_DED_AMT := TRUNC(V_PF_DED_AMT);
      ELSE
        V_PF_DED_AMT := TRUNC(V_PF_DED_AMT) + 1.00;
      END IF;
    
      -----------------------------------DEDUCTION------------------
      BEGIN
        SELECT D.MCYCLE_DEDUC,
               D.BCYCLE_DEDUC,
               D.PFADV_DEDUC,
               D.REVENUE,
               D.CAR_FARE,
               D.CAR_USE,
               D.GAS_BILL,
               D.WATER_BILL,
               D.ELECT_BILL,
               D.NEWS_PAPER,
               D.HBADV_ARREAR,
               D.PFADV_ARREAR,
               D.TEL_EXCESS_BILL,
               D.OTHER_DEDUC,
               D.REMARKS,
               D.COMP_DEDUC,
               D.HBADV_DEDUC_PERCENT,
               D.INCOME_TAX,
               D.INCOME_TAX_ARR,
               NVL(D.HR_AREAR_DED, 0)
          INTO V_MCYCLE_DEDUC,
               V_BICYCLE_DEDUC,
               V_PFADV_DEDUC,
               V_REVENUE_DEDUC,
               V_CARFARE_DEDUC,
               V_CARUSE_DEDUC,
               V_GAS_BILL,
               V_WATER_BILL,
               V_ELECTRICITY_BILL,
               V_NEWS_PAPER_DEDUC,
               V_HBADV_ARREAR_DEDUC,
               V_PFADV_ARREAR_DEDUC,
               V_TEL_EXCESS_BILL,
               V_OTHER_DEDUC,
               V_REMARKS_DEDUCTION,
               V_COMP_DEDUC,
               V_HBADV_DEDUC_PERCENT,
               V_INCOME_TAX,
               V_INCOME_TAX_ARR,
               V_HR_ARREAR_DED
          FROM PRMS_DEDUC D
         WHERE D.EMP_ID = ID.EMP_ID;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          DBMS_OUTPUT.PUT_LINE('NO DEDUCTION DATA FOUND FOR THIS EMPLOYEE: ' ||
                               ID.EMP_ID);
          --RAISE V_EXCEPTION;
      END;
    
      SELECT D.DESIGNATION_CATEGORY
        INTO V_DESIG_CATAGORY
        FROM PRMS_DESIGNATION D
       WHERE D.DESIGNATION_CODE = ID.DESIG_CODE;
    
      V_WELFARE_DED_AMT := GET_MIN_AMT(ROUND(V_BASIC_AMT * 0.01, 2),
                                       V_MIN_WELFARE_DED_AMT);
    
      IF V_DESIG_CATAGORY <> 1 THEN
        V_INS_DED_AMT := 0;
      ELSE
      
        V_INS_DED_AMT := GET_MIN_AMT(ROUND(V_BASIC_AMT * 0.007, 2),
                                     V_MIN_INS_DED_AMT);
      END IF;
    
      IF P_SALCODE = 'SPECIAL' THEN
        V_HBADV_DEDUC   := 0;
        V_MCYCLE_DEDUC  := 0;
        V_BICYCLE_DEDUC := 0;
        V_PFADV_DEDUC   := 0;
        V_COMP_DEDUC    := 0;
      END IF;
    
      --  V_HR_ALWNC_AMT := V_HR_ALWNC_AMT + V_HR_ARREAR_ALW - V_HR_ARREAR_DED;
    
      V_TOT_SAL_ALLOWANCE := NVL(V_BASIC_AMT, 0) + NVL(V_AREARBASIC_AMT, 0) +
                             NVL(V_MED_ALWNC_AMT, 0) +
                             NVL(V_HR_ALWNC_AMT, 0) +
                             NVL(V_TEL_ALWNC_AMT, 0) +
                             NVL(V_TRANS_ALLOWANCE, 0) +
                             NVL(V_EDU_ALLOWANCE, 0) +
                             NVL(V_WASH_ALLOWANCE, 0) +
                             NVL(V_ENTERTAINMENT, 0) +
                             NVL(V_DOMESTIC_ALLOWANCE, 0) +
                             NVL(V_OTHER_ALLOWANCE, 0) +
                             NVL(V_DREANESS_ALLWNC, 0) +
                             NVL(V_HILL_ALLWNC, 0);
    
      V_GROSS_PAY_AMT := V_TOT_SAL_ALLOWANCE + V_PENSION_ALLOWANCE;
    
      V_NET_DED_AMT := NVL(V_HBADV_DEDUC, 0) + NVL(V_MCYCLE_DEDUC, 0) +
                       NVL(V_BICYCLE_DEDUC, 0) + NVL(V_PFADV_DEDUC, 0) +
                       NVL(V_HBADV_ARREAR_DEDUC, 0) +
                       NVL(V_PFADV_ARREAR_DEDUC, 0) +
                       NVL(V_TEL_EXCESS_BILL, 0) + NVL(V_OTHER_DEDUC, 0) +
                       NVL(V_COMP_DEDUC, 0) + NVL(V_REVENUE_DEDUC, 0) +
                       NVL(V_CARFARE_DEDUC, 0) + NVL(V_CARUSE_DEDUC, 0) +
                       NVL(V_GAS_BILL, 0) + NVL(V_WATER_BILL, 0) +
                       NVL(V_ELECTRICITY_BILL, 0) +
                       NVL(V_HOUSE_RENT_DEDUC, 0) +
                       NVL(V_NEWS_PAPER_DEDUC, 0) +
                       NVL(V_WELFARE_DED_AMT, 0) + NVL(V_INS_DED_AMT, 0) +
                       NVL(V_PF_DED_AMT, 0) + NVL(V_INCOME_TAX, 0) +
                       NVL(V_INCOME_TAX_ARR, 0);
      V_NET_PAY_AMT := V_TOT_SAL_ALLOWANCE - V_NET_DED_AMT;
      ---------------------------INSERTION INTO TRANSACTION TABLE-------------------------------
      INSERT INTO PRMS_TRANSACTION
        (ENTITY_NUMBER,
         BRANCH_CODE,
         EMP_ID,
         SAL_YEAR,
         MONTH_CODE,
         SAL_MONTH,
         BASIC_PAY,
         MEDICAL_ALLOWANCE,
         HOUSE_RENT_ALLOWANCE,
         TEL_ALLOWANCE,
         TRANS_ALLOWANCE,
         EDU_ALLOWANCE,
         WASH_ALLOWANCE,
         PENSION_ALLOWANCE,
         ENTERTAINMENT,
         DOMESTIC_ALLOWANCE,
         OTHER_ALLOWANCE,
         GROSS_PAY_AMT,
         HBADV_DEDUC,
         MCYCLE_DEDUC,
         BICYCLE_DEDUC,
         PFADV_DEDUC,
         PENSION_DEDUC,
         REVENUE_DEDUC,
         WELFARE_DEDUC,
         CARFARE_DEDUC,
         CARUSE_DEDUC,
         GAS_BILL,
         WATER_BILL,
         ELECTRICITY_BILL,
         HOUSE_RENT_DEDUC,
         NEWS_PAPER_DEDUC,
         PF_DEDUCTION,
         NET_DED_AMT,
         NET_PAY_AMT,
         HBADV_ARREAR_DEDUC,
         PFADV_ARREAR_DEDUC,
         TEL_EXCESS_BILL,
         GEN_INSURENCE,
         /*SP_DEDUC,
         SP_DESCRIPTION,
         TREMARKS,*/
         ARREAR,
         OTHER_DEDUC,
         HBADV_DEDUC_PERCENT,
         TOT_SAL_ALLOWANCE,
         ARREAR_BASIC,
         /*  INSTL_AMT_TLO,
         INSTL_AMT_TLR,
         INSTL_AMT_INS,
         INSTL_AMT_INC,
         OFFICE_CODE,*/
         COMP_DEDUC,
         DEARNESS_ALLOWANCE,
         GENERATED_BY,
         GENERATED_ON,
         INCOME_TAX,
         INCOME_TAX_ARR,
         HILL_ALLWNC,
         ACTUAL_BASIC,
         DEDUCTION_REMARKS,
         ALLOWANCE_REMARKS)
      VALUES
        (P_ENTITY_NUM,
         DECODE(ID.ACC_NO_ACTIVE,
                'S',
                (SELECT L.ATTACHED_BRANCH
                   FROM PRMS_SUSPEND_LIST L
                  WHERE L.ENTITY_NUM = P_ENTITY_NUM
                    AND L.EMP_ID = ID.EMP_ID
                    AND L.SUSPEND_SL =
                        (SELECT MAX(L.SUSPEND_SL)
                           FROM PRMS_SUSPEND_LIST L
                          WHERE L.ENTITY_NUM = P_ENTITY_NUM
                            AND L.EMP_ID = ID.EMP_ID)),
                ID.EMP_BRN_CODE),
         ID.EMP_ID,
         V_SAL_YEAR,
         V_MONTH_CODE,
         V_SAL_MONTH,
         V_BASIC_AMT,
         V_MED_ALWNC_AMT,
         NVL(V_HR_ALWNC_AMT, 0),
         NVL(V_TEL_ALWNC_AMT, 0),
         NVL(V_TRANS_ALLOWANCE, 0),
         NVL(V_EDU_ALLOWANCE, 0),
         NVL(V_WASH_ALLOWANCE, 0),
         NVL(V_PENSION_ALLOWANCE, 0),
         NVL(V_ENTERTAINMENT, 0),
         NVL(V_DOMESTIC_ALLOWANCE, 0),
         NVL(V_OTHER_ALLOWANCE, 0),
         V_GROSS_PAY_AMT,
         NVL(V_HBADV_DEDUC, 0),
         NVL(V_MCYCLE_DEDUC, 0),
         NVL(V_BICYCLE_DEDUC, 0),
         NVL(V_PFADV_DEDUC, 0),
         NVL(V_PENSION_DEDUC, 0),
         NVL(V_REVENUE_DEDUC, 0),
         NVL(V_WELFARE_DED_AMT, 0),
         NVL(V_CARFARE_DEDUC, 0),
         NVL(V_CARUSE_DEDUC, 0),
         NVL(V_GAS_BILL, 0),
         NVL(V_WATER_BILL, 0),
         NVL(V_ELECTRICITY_BILL, 0),
         NVL(V_HOUSE_RENT_DEDUC, 0),
         NVL(V_NEWS_PAPER_DEDUC, 0),
         NVL(V_PF_DED_AMT, 0),
         V_NET_DED_AMT,
         V_NET_PAY_AMT,
         NVL(V_HBADV_ARREAR_DEDUC, 0),
         NVL(V_PFADV_ARREAR_DEDUC, 0),
         NVL(V_TEL_EXCESS_BILL, 0),
         NVL(V_INS_DED_AMT, 0),
         0, -----AREAR OTHER 
         NVL(V_OTHER_DEDUC, 0),
         NVL(V_HBADV_DEDUC_PERCENT, 0),
         V_TOT_SAL_ALLOWANCE,
         NVL(V_AREARBASIC_AMT, 0),
         NVL(V_COMP_DEDUC, 0),
         NVL(V_DREANESS_ALLWNC, 0),
         P_USER_ID,
         V_ASON_DATE,
         NVL(V_INCOME_TAX, 0),
         NVL(V_INCOME_TAX_ARR, 0),
         NVL(V_HILL_ALLWNC, 0),
         V_BASIC_AMT,
         V_REMARKS_DEDUCTION,
         V_REMARKS_ALLOWANCE);
      --EXCEPTION WHEN OTHERS
    
    END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_ERROR_MSG := 'ERROR IN SP_SALARY_CALCULATION: ' || SQLERRM;
      ROLLBACK;
  END SP_SALARY_CALCULATION_NEW;

  PROCEDURE SP_INIT_VALUES(P_MSG OUT VARCHAR2) IS
  
    V_DAY_OF_MON NUMBER := 0;
  
  BEGIN
    SELECT EXTRACT(DAY FROM SYSDATE) INTO V_DAY_OF_MON FROM DUAL;
    --V_DAY_OF_MON := 1;
    IF (V_DAY_OF_MON <= 5) THEN
    
      UPDATE PRMS_DEDUC D
         SET CAR_USE         = 0,
             ELECT_BILL      = 0,
             HBADV_ARREAR    = 0,
             PFADV_ARREAR    = 0,
             TEL_EXCESS_BILL = 0,
             D.HR_AREAR_DED  = 0,
             D.REMARKS       = '';
    
      UPDATE PRMS_EMP_SAL SET ARREAR_BASIC = 0;
      UPDATE PRMS_ALLOWANCE A
         SET ARREAR            = 0,
             A.OTHER_ALLOWANCE = 0,
             A.HR_AREAR_ALW    = 0,
             A.REMARKS         = '';
    
      P_MSG := 'SUCCESS';
    ELSE
      P_MSG := 'EXPIRED';
    END IF;
  
  END SP_INIT_VALUES;

  PROCEDURE SP_EMPLOYEE_UPDATION(P_EMP_ID         IN VARCHAR2,
                                 P_NEW_BRN_CODE   IN VARCHAR2,
                                 P_NEW_BASIC      IN NUMBER,
                                 P_NEW_DESIG_CODE IN VARCHAR2,
                                 P_EFFECTIVE_DATE IN VARCHAR2,
                                 P_MSG            OUT VARCHAR2) IS
    V_MAX_SL         NUMBER(5) := 0;
    V_DESIG_DESC     PRMS_DESIGNATION.DESIGNATION_DESC%TYPE;
    V_EFFECTIVE_DATE DATE;
  BEGIN
  
    SELECT TO_DATE(P_EFFECTIVE_DATE /*TO_DATE(P_EFFECTIVE_DATE, 'YYYY-MM-DD')*/,
                   'DD-Mon-YYYY')
      INTO V_EFFECTIVE_DATE
      FROM DUAL;
    ----------------------------UPDATION------------------------
  
    IF (P_NEW_BRN_CODE <> 'NA') THEN
      UPDATE PRMS_EMP_SAL
         SET EMP_BRN_CODE  = P_NEW_BRN_CODE,
             TRANSFER_DATE = V_EFFECTIVE_DATE
       WHERE EMP_ID = P_EMP_ID;
    END IF;
  
    IF (NVL(P_NEW_BASIC, 0) > 0) THEN
      UPDATE PRMS_EMP_SAL
         SET NEW_BASIC = P_NEW_BASIC
       WHERE EMP_ID = P_EMP_ID;
    END IF;
  
    IF (P_NEW_DESIG_CODE <> 'NA') THEN
    
      SELECT D.DESIGNATION_DESC
        INTO V_DESIG_DESC
        FROM PRMS_DESIGNATION D
       WHERE D.DESIGNATION_CODE = P_NEW_DESIG_CODE;
      UPDATE PRMS_EMP_SAL
         SET PRMS_EMP_SAL.DESIG      = V_DESIG_DESC,
             PRMS_EMP_SAL.DESIG_CODE = P_NEW_DESIG_CODE
       WHERE EMP_ID = P_EMP_ID;
    END IF;
  
    --W_QUERY := 'UPDATE PRMS_EMP_SAL SET(' || W_UPDATE_COL ||') WHERE EMP_ID = P_EMP_ID';
    -----------------INSERTION: INTO HIST TABLE-----------------
  
    SELECT MAX(EFT_SERIAL) + 1
      INTO V_MAX_SL
      FROM PRMS_EMP_SAL_HIST
     WHERE EMP_ID = P_EMP_ID;
  
    BEGIN
      INSERT INTO PRMS_EMP_SAL_HIST
        (EFFECTIVE_DATE,
         EFT_SERIAL,
         EMP_ID,
         EMP_BRN_CODE,
         DESIG_CODE,
         DESIG,
         DESIG_SENIORITY_CODE,
         INCREMENT_DATE,
         PAYSCALE_CODE,
         STATUS_CODE,
         TIME_SCALE,
         PF_TYPE,
         PF_DEDUCTION_PCT,
         HOUSE_RENT_PCT,
         BANK_CODE,
         MEDICAL_ALLOWANCE,
         SQ_RESIDENCE,
         PF_LIEN,
         SP_INSURANCE,
         PAYMENT_BANK,
         ACC_NO_ACTIVE,
         BASIC_APY,
         EMP_CATEGORY,
         BANK_ACC,
         DEARNESS_PCT,
         PEN_PCT,
         ARREAR_BASIC,
         NEW_BASIC,
         BONUS_YN,
         HBFC_OWN,
         LPR_LAST_DATE,
         ENTD_BY,
         ENTD_ON,
         MOD_BY,
         MOD_ON,
         TRANSFER_DATE,
         EMP_DEPT_CODE)
        SELECT V_EFFECTIVE_DATE, V_MAX_SL, S.*
          FROM PRMS_EMP_SAL S
         WHERE S.EMP_ID = P_EMP_ID;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      P_MSG := SQLERRM;
      ROLLBACK;
  END SP_EMPLOYEE_UPDATION;
  PROCEDURE SP_NEW_EMPLOYEE_INSERTION(P_EMPLOYEE_ID    IN VARCHAR2,
                                      P_EMPLOYEE_NAME  IN VARCHAR2,
                                      P_BRANCH_CODE    IN VARCHAR2,
                                      P_DESIGNATION    IN VARCHAR2,
                                      P_JOINING_DATE   IN VARCHAR2,
                                      P_DEPT_CODE      IN VARCHAR2,
                                      P_GENDER_TYPE    IN VARCHAR2,
                                      P_BLOOD_GRP      IN VARCHAR2,
                                      P_RHFACTOR       IN VARCHAR2,
                                      P_DOB            IN VARCHAR2,
                                      P_CONTACT_NO     IN VARCHAR2,
                                      P_TIN            IN VARCHAR2,
                                      P_EMAIL          IN VARCHAR2,
                                      P_SENIORITY_CODE IN VARCHAR2,
                                      P_ADDRESS        IN VARCHAR2,
                                      P_ENTD_BY        IN VARCHAR2,
                                      P_RELIGION       IN CHAR,
                                      P_DEGREE         IN VARCHAR2,
                                      P_HOME_DIST      IN VARCHAR2,
                                      P_NID_NO         IN VARCHAR2,
                                      P_MSG            OUT VARCHAR2) IS
  
    V_EXIST  NUMBER(2) := 0;
    V_MAX_SL NUMBER(4) := 0;
  BEGIN
  
    SELECT NVL(COUNT(E.EMP_ID), 0)
      INTO V_EXIST
      FROM PRMS_EMPLOYEE E
     WHERE E.EMP_ID = P_EMPLOYEE_ID;
  
    IF V_EXIST = 0 THEN
      INSERT INTO PRMS_EMPLOYEE
        (EMP_ID,
         EMP_NAME,
         JOINING_DESIG,
         JOINING_DATE,
         GENDER,
         BLOOD_GRP,
         RHFACTOR,
         TIN_NO,
         EMAIL,
         CONTACT_NO,
         DOB,
         ADDRESS,
         RELIGION,
         ENTD_BY,
         ENTD_ON,
         MOD_BY,
         MOD_ON,
         HIGHEST_DEGREE,
         HOME_DISTRICT,
         NID)
      VALUES
        (P_EMPLOYEE_ID,
         P_EMPLOYEE_NAME,
         P_DESIGNATION,
         TO_DATE(P_JOINING_DATE, 'DD-Mon-YYYY'),
         P_GENDER_TYPE,
         P_BLOOD_GRP,
         P_RHFACTOR,
         P_TIN,
         LOWER(P_EMAIL),
         P_CONTACT_NO,
         TO_DATE(P_DOB, 'DD-Mon-YYYY'),
         P_ADDRESS,
         P_RELIGION,
         P_ENTD_BY,
         SYSDATE,
         '',
         '',
         P_DEGREE,
         P_HOME_DIST,
         P_NID_NO);
    
      INSERT INTO PRMS_EMP_SAL
        (EMP_ID,
         EMP_BRN_CODE,
         DESIG_CODE,
         DESIG,
         DESIG_SENIORITY_CODE,
         ACC_NO_ACTIVE,
         EMP_CATEGORY,
         NEW_BASIC,
         BONUS_YN,
         ENTD_BY,
         ENTD_ON,
         MOD_BY,
         MOD_ON,
         -- TRANSFER_DATE,
         EMP_DEPT_CODE,
         MEDICAL_ALLOWANCE,
         PEN_PCT,
         SQ_RESIDENCE)
      VALUES
        (P_EMPLOYEE_ID,
         P_BRANCH_CODE,
         P_DESIGNATION,
         (SELECT PRMS_DESIGNATION.DESIGNATION_DESC
            FROM PRMS_DESIGNATION
           WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION),
         P_SENIORITY_CODE,
         'N', --ACC_NO_ACTIVE,
         (SELECT PRMS_DESIGNATION.DESIGNATION_CATEGORY
            FROM PRMS_DESIGNATION
           WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION), --EMP_CATEGORY,
         0, --NEW_BASIC,
         'Y', --BONUS_YN,
         P_ENTD_BY, --ENTD_BY,
         SYSDATE, --ENTD_ON,
         '', --MOD_BY,
         '', --MOD_ON,
         --   TO_DATE(TO_DATE(P_JOINING_DATE, 'YYYY-MM-DD'), 'DD-Mon-YYYY'), --TRANSFER_DATE,
         P_DEPT_CODE, --EMP_DEPT_CODE
         1500,
         55,
         'N');
      INSERT INTO PRMS_EMP_SAL_HIST
        (EMP_ID,
         EFFECTIVE_DATE,
         EFT_SERIAL,
         EMP_BRN_CODE,
         DESIG_CODE,
         DESIG,
         DESIG_SENIORITY_CODE,
         ACC_NO_ACTIVE,
         EMP_CATEGORY,
         NEW_BASIC,
         BONUS_YN,
         ENTD_BY,
         ENTD_ON,
         MOD_BY,
         MOD_ON,
         --  TRANSFER_DATE,
         EMP_DEPT_CODE,
         MEDICAL_ALLOWANCE,
         PEN_PCT,
         SQ_RESIDENCE)
      VALUES
        (P_EMPLOYEE_ID,
         TO_DATE(P_JOINING_DATE, 'DD-Mon-YYYY'),
         1,
         P_BRANCH_CODE,
         P_DESIGNATION,
         (SELECT PRMS_DESIGNATION.DESIGNATION_DESC
            FROM PRMS_DESIGNATION
           WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION),
         P_SENIORITY_CODE,
         'N', --ACC_NO_ACTIVE,
         (SELECT PRMS_DESIGNATION.DESIGNATION_CATEGORY
            FROM PRMS_DESIGNATION
           WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION), --EMP_CATEGORY,
         0, --NEW_BASIC,
         'Y', --BONUS_YN,
         P_ENTD_BY, --ENTD_BY,
         SYSDATE, --ENTD_ON,
         '', --MOD_BY,
         '', --MOD_ON,
         --  TO_DATE(TO_DATE(P_JOINING_DATE, 'YYYY-MM-DD'), 'DD-Mon-YYYY'), --TRANSFER_DATE,
         P_DEPT_CODE, --EMP_DEPT_CODE
         1500,
         55,
         'N');
    
      INSERT INTO PRMS_ALLOWANCE (EMP_ID) VALUES (P_EMPLOYEE_ID);
      INSERT INTO PRMS_DEDUC (EMP_ID) VALUES (P_EMPLOYEE_ID);
    ELSE
      SELECT NVL(MAX(H.EFT_SERIAL), 0)
        INTO V_MAX_SL
        FROM PRMS_EMP_SAL_HIST H
       WHERE H.EMP_ID = P_EMPLOYEE_ID;
      UPDATE PRMS_EMPLOYEE
         SET EMP_NAME       = P_EMPLOYEE_NAME,
             JOINING_DESIG  = P_DESIGNATION,
             JOINING_DATE   = TO_DATE(P_JOINING_DATE, 'DD-Mon-YYYY'),
             GENDER         = P_GENDER_TYPE,
             BLOOD_GRP      = P_BLOOD_GRP,
             RHFACTOR       = P_RHFACTOR,
             TIN_NO         = P_TIN,
             EMAIL          = LOWER(P_EMAIL),
             CONTACT_NO     = P_CONTACT_NO,
             DOB            = TO_DATE(P_DOB, 'DD-Mon-YYYY'),
             ADDRESS        = P_ADDRESS,
             RELIGION       = P_RELIGION,
             MOD_BY         = P_ENTD_BY,
             MOD_ON         = SYSDATE,
             HIGHEST_DEGREE = P_DEGREE,
             HOME_DISTRICT  = P_HOME_DIST,
             NID            = P_NID_NO
       WHERE EMP_ID = P_EMPLOYEE_ID;
    
      UPDATE PRMS_EMP_SAL S
         SET EMP_BRN_CODE         = P_BRANCH_CODE,
             DESIG_CODE           = P_DESIGNATION,
             DESIG               =
             (SELECT PRMS_DESIGNATION.DESIGNATION_DESC
                FROM PRMS_DESIGNATION
               WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION),
             DESIG_SENIORITY_CODE = P_SENIORITY_CODE,
             EMP_CATEGORY        =
             (SELECT PRMS_DESIGNATION.DESIGNATION_CATEGORY
                FROM PRMS_DESIGNATION
               WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION),
             MOD_BY               = P_ENTD_BY,
             MOD_ON               = SYSDATE,
             EMP_DEPT_CODE        = P_DEPT_CODE
       WHERE S.EMP_ID = P_EMPLOYEE_ID;
    
      UPDATE PRMS_EMP_SAL_HIST S
         SET EMP_BRN_CODE         = P_BRANCH_CODE,
             DESIG_CODE           = P_DESIGNATION,
             DESIG               =
             (SELECT PRMS_DESIGNATION.DESIGNATION_DESC
                FROM PRMS_DESIGNATION
               WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION),
             DESIG_SENIORITY_CODE = P_SENIORITY_CODE,
             EMP_CATEGORY        =
             (SELECT PRMS_DESIGNATION.DESIGNATION_CATEGORY
                FROM PRMS_DESIGNATION
               WHERE PRMS_DESIGNATION.DESIGNATION_CODE = P_DESIGNATION),
             MOD_BY               = P_ENTD_BY,
             MOD_ON               = SYSDATE,
             EMP_DEPT_CODE        = P_DEPT_CODE
       WHERE S.EMP_ID = P_EMPLOYEE_ID
         AND S.EFT_SERIAL = V_MAX_SL;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_MSG := SQLERRM;
      ROLLBACK;
  END SP_NEW_EMPLOYEE_INSERTION;

  PROCEDURE SP_BONUS_CAL(P_ENTITY         IN NUMBER,
                         P_USER_ID        IN VARCHAR2,
                         P_BASIC_YEAR     IN NUMBER,
                         P_BASIC_MON_CODE IN NUMBER,
                         P_BONUS_TYPE     IN VARCHAR2,
                         P_BON_PCT        IN NUMBER,
                         P_BON_ORDER_NO   IN VARCHAR2,
                         P_MSG            OUT VARCHAR2) IS
    V_BON_DESC    VARCHAR2(100) := 'Bonus For ';
    V_REVENUE     NUMBER(9, 2) := 10;
    V_BASIC_AMT   NUMBER(9, 2) := 0;
    V_BON_AMT     NUMBER(9, 2) := 0;
    V_NET_BON_AMT NUMBER(9, 2) := 0;
    V_MONTH_CODE  NUMBER(2);
    V_SAL_YEAR    NUMBER(4);
    V_SAL_MONTH   VARCHAR2(10) := '';
    V_ASON_DATE   DATE := TRUNC(SYSDATE);
    V_EMP_REL     CHAR(1) := 'A';
  BEGIN
    IF P_BONUS_TYPE = 'EIDFT' THEN
      V_BON_DESC := V_BON_DESC || 'Eid-Ul-Fitr';
      V_EMP_REL  := 'M';
    ELSIF P_BONUS_TYPE = 'EIDAH' THEN
      V_BON_DESC := V_BON_DESC || 'Eid-Ul-Adha';
      V_EMP_REL  := 'M';
    ELSIF P_BONUS_TYPE = 'NEWYR' THEN
      V_BON_DESC := V_BON_DESC || 'Nabobarsho';
      -- V_EMP_REL  := 'A';
    ELSIF P_BONUS_TYPE = 'DURGA' THEN
      V_BON_DESC := V_BON_DESC || 'Durga Puja';
      V_EMP_REL  := 'H';
    ELSIF P_BONUS_TYPE = 'INCTV' THEN
      V_BON_DESC := 'Incentive Bonus';
      --   V_EMP_REL  := 'A';
    END IF;
    SELECT UPPER(TO_CHAR(V_ASON_DATE, 'Month')) INTO V_SAL_MONTH FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(TO_DATE(V_ASON_DATE, 'dd-mon-yy'), 'mm'))
      INTO V_MONTH_CODE
      FROM DUAL;
    SELECT TO_NUMBER(TO_CHAR(V_ASON_DATE, 'YYYY'))
      INTO V_SAL_YEAR
      FROM DUAL;
    -----------------DELETE ON MODIFY-----------------
    DELETE FROM PRMS_BONUS_TRANSACTION T
     WHERE T.ENTITY_NUM = P_ENTITY
       AND T.SAL_YEAR = V_SAL_YEAR
       AND T.MONTH_CODE = V_MONTH_CODE
       AND T.BONUS_TYPE = P_BONUS_TYPE;
    -----------------DELETE ON MODIFY-----------------
  
    IF V_EMP_REL <> 'A' THEN
      FOR ID IN (SELECT S.*, RELIGION, B.BRN_CODE
                   FROM PRMS_EMP_SAL S
                   JOIN PRMS_EMPLOYEE E
                     ON (E.EMP_ID = S.EMP_ID)
                   JOIN PRMS_MBRANCH B
                     ON (S.EMP_BRN_CODE = B.BRN_CODE)
                  WHERE S.ACC_NO_ACTIVE = 'Y'
                    AND S.DESIG_CODE <> 0
                    AND (SELECT PRMS_EMPLOYEE.DOB
                           FROM PRMS_EMPLOYEE
                          WHERE PRMS_EMPLOYEE.EMP_ID = S.EMP_ID) IS NOT NULL
                    AND DECODE(E.RELIGION, 'M', 'M', 'O', 'M', 'H') =
                        V_EMP_REL) LOOP
      
        BEGIN
          SELECT NVL(T.BASIC_PAY, 0)
            INTO V_BASIC_AMT
            FROM PRMS_TRANSACTION T
           WHERE T.ENTITY_NUMBER = P_ENTITY
             AND T.EMP_ID = ID.EMP_ID
             AND T.SAL_YEAR = P_BASIC_YEAR
             AND T.MONTH_CODE = P_BASIC_MON_CODE;
        
          SELECT C.REVENUE
            INTO V_REVENUE
            FROM PRMS_DEDUC C
           WHERE C.EMP_ID = ID.EMP_ID;
        
        EXCEPTION
          WHEN OTHERS THEN
            V_BASIC_AMT := NVL(ID.NEW_BASIC, 0);
        END;
        V_BON_AMT     := NVL(V_BASIC_AMT, 0) *
                         ROUND((NVL(P_BON_PCT, 0) / 100), 2);
        V_NET_BON_AMT := NVL(V_BON_AMT, 0) - NVL(V_REVENUE, 0);
      
        INSERT INTO PRMS_BONUS_TRANSACTION
          (ENTITY_NUM,
           BRANCH_CODE,
           EMP_ID,
           SAL_YEAR,
           MONTH_CODE,
           SAL_MONTH,
           BONUS_TYPE,
           BONUS_DESCRIPTION,
           REVENUE,
           RELIGION,
           BONUS_ORDER_NO,
           BASIC_AMT,
           BONUS_AMOUNT,
           NET_BON_AMT,
           ENTD_BY,
           ENTD_ON)
        VALUES
          (P_ENTITY,
           ID.EMP_BRN_CODE,
           ID.EMP_ID,
           V_SAL_YEAR,
           V_MONTH_CODE,
           V_SAL_MONTH,
           P_BONUS_TYPE,
           V_BON_DESC,
           V_REVENUE,
           (SELECT RELIGION FROM PRMS_EMPLOYEE E WHERE E.EMP_ID = ID.EMP_ID),
           P_BON_ORDER_NO,
           V_BASIC_AMT,
           V_BON_AMT,
           V_NET_BON_AMT,
           P_USER_ID,
           SYSDATE);
      END LOOP;
    ELSE
      FOR ID IN (SELECT S.*, E.RELIGION, B.BRN_CODE
                   FROM PRMS_EMP_SAL S
                   JOIN PRMS_EMPLOYEE E
                     ON (E.EMP_ID = S.EMP_ID)
                   JOIN PRMS_MBRANCH B
                     ON (S.EMP_BRN_CODE = B.BRN_CODE)
                  WHERE S.ACC_NO_ACTIVE = 'Y'
                    AND S.DESIG_CODE <> 0
                    AND (SELECT PRMS_EMPLOYEE.DOB
                           FROM PRMS_EMPLOYEE
                          WHERE PRMS_EMPLOYEE.EMP_ID = S.EMP_ID) IS NOT NULL) LOOP
      
        BEGIN
          SELECT NVL(T.BASIC_PAY, 0)
            INTO V_BASIC_AMT
            FROM PRMS_TRANSACTION T
           WHERE T.ENTITY_NUMBER = P_ENTITY
             AND T.EMP_ID = ID.EMP_ID
             AND T.SAL_YEAR = P_BASIC_YEAR
             AND T.MONTH_CODE = P_BASIC_MON_CODE;
        
          SELECT C.REVENUE
            INTO V_REVENUE
            FROM PRMS_DEDUC C
           WHERE C.EMP_ID = ID.EMP_ID;
        
        EXCEPTION
          WHEN OTHERS THEN
            V_BASIC_AMT := NVL(ID.NEW_BASIC, 0);
        END;
      
        --  V_BASIC_AMT   := NVL(ID.NEW_BASIC, 0);
        V_BON_AMT     := NVL(V_BASIC_AMT, 0) *
                         ROUND((NVL(P_BON_PCT, 0) / 100), 2);
        V_NET_BON_AMT := NVL(V_BON_AMT, 0) - NVL(V_REVENUE, 0);
      
        INSERT INTO PRMS_BONUS_TRANSACTION
          (ENTITY_NUM,
           BRANCH_CODE,
           EMP_ID,
           SAL_YEAR,
           MONTH_CODE,
           SAL_MONTH,
           BONUS_TYPE,
           BONUS_DESCRIPTION,
           REVENUE,
           RELIGION,
           BONUS_ORDER_NO,
           BASIC_AMT,
           BONUS_AMOUNT,
           NET_BON_AMT,
           ENTD_BY,
           ENTD_ON)
        VALUES
          (P_ENTITY,
           ID.EMP_BRN_CODE,
           ID.EMP_ID,
           V_SAL_YEAR,
           V_MONTH_CODE,
           V_SAL_MONTH,
           P_BONUS_TYPE,
           V_BON_DESC,
           V_REVENUE,
           (SELECT RELIGION FROM PRMS_EMPLOYEE E WHERE E.EMP_ID = ID.EMP_ID),
           P_BON_ORDER_NO,
           V_BASIC_AMT,
           V_BON_AMT,
           V_NET_BON_AMT,
           P_USER_ID,
           SYSDATE);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      P_MSG := SQLERRM;
  END SP_BONUS_CAL;

  FUNCTION FN_TAX_STMT_DATA(P_ENTITY_NUMBER IN NUMBER,
                            P_BRANCH_CODE   IN VARCHAR2,
                            P_YEAR1         IN VARCHAR2,
                            P_YEAR2         IN VARCHAR2) RETURN V_DATA
    PIPELINED IS
    V_TAX_DATA       TAX_DATA;
    V_BRANCH_CODE    VARCHAR2(5);
    V_EMP_ID         PRMS_EMP_SAL.EMP_ID%TYPE;
    V_DESIGNATION    PRMS_EMP_SAL.DESIG%TYPE;
    V_EMP_NAME       PRMS_EMPLOYEE.EMP_NAME%TYPE;
    V_MONTH_YEAR     VARCHAR(10);
    V_SAL_YEAR       PRMS_TRANSACTION.SAL_YEAR%TYPE;
    V_MONTH_CODE     NUMBER(2);
    V_BASIC_PAY      NUMBER(9, 2);
    V_DOM_ALLOWANCE  NUMBER(9, 2);
    V_ENTERTAINMENT  NUMBER(9, 2);
    V_MED_ALLOWANCE  NUMBER(9, 2);
    V_HR_ALLOWANCE   NUMBER(9, 2);
    V_EDU_ALLOWANCE  NUMBER(9, 2);
    V_PF_DEDUCTION   NUMBER(9, 2);
    V_WELFARE_DEDUC  NUMBER(9, 2);
    V_INCOME_TAX     NUMBER(9, 2);
    V_TEL_ALLOWANCE  NUMBER(9, 2);
    V_DRNS_ALLOWANCE NUMBER(9, 2);
    V_GEN_INSURENCE  NUMBER(9, 2);
    V_FESTIVAL_BONUS NUMBER(9, 2);
    V_FEST_BONUS_MON NUMBER(2);
  
  BEGIN
    FOR IDX IN (SELECT S.EMP_ID
                  FROM PRMS_EMP_SAL S
                 WHERE S.EMP_BRN_CODE = P_BRANCH_CODE) LOOP
      BEGIN
        SELECT (SELECT S.DESIG
                  FROM PRMS_EMP_SAL S
                 WHERE S.EMP_ID = IDX.EMP_ID) DESIGNATION,
               (SELECT E.EMP_NAME
                  FROM PRMS_EMPLOYEE E
                 WHERE E.EMP_ID = IDX.EMP_ID) EMP_NAME,
               SUBSTR(T.SAL_MONTH, 1, 3) || '-' || T.SAL_YEAR MONTH_YEAR,
               T.SAL_YEAR,
               T.MONTH_CODE,
               NVL(T.BASIC_PAY + T.ARREAR_BASIC, 0) BASIC_PAY,
               NVL(T.DOMESTIC_ALLOWANCE, 0) DOMESTIC_ALLOWANCE,
               NVL(T.ENTERTAINMENT, 0) ENTERTAINMENT,
               NVL(T.MEDICAL_ALLOWANCE, 0) MEDICAL_ALLOWANCE,
               NVL(T.HOUSE_RENT_ALLOWANCE, 0) HOUSE_RENT_ALLOWANCE,
               NVL(T.EDU_ALLOWANCE, 0) EDU_ALLOWANCE,
               NVL(T.PF_DEDUCTION, 0) PF_DEDUCTION,
               NVL(T.WELFARE_DEDUC, 0) WELFARE_DEDUC,
               NVL(T.INCOME_TAX + T.INCOME_TAX_ARR, 0) INCOME_TAX,
               NVL(T.TEL_ALLOWANCE, 0) TEL_ALLOWANCE,
               NVL(T.DEARNESS_ALLOWANCE, 0) DEARNESS_ALLOWANCE,
               NVL(T.GEN_INSURENCE, 0) GEN_INSURENCE
          INTO V_DESIGNATION,
               V_EMP_NAME,
               V_MONTH_YEAR,
               V_SAL_YEAR,
               V_MONTH_CODE,
               V_BASIC_PAY,
               V_DOM_ALLOWANCE,
               V_ENTERTAINMENT,
               V_MED_ALLOWANCE,
               V_HR_ALLOWANCE,
               V_EDU_ALLOWANCE,
               V_PF_DEDUCTION,
               V_WELFARE_DEDUC,
               V_INCOME_TAX,
               V_TEL_ALLOWANCE,
               V_DRNS_ALLOWANCE,
               V_GEN_INSURENCE
          FROM PRMS_TRANSACTION T
         WHERE T.ENTITY_NUMBER = P_ENTITY_NUMBER
           AND T.EMP_ID = IDX.EMP_ID
           AND T.SAL_YEAR = P_YEAR1
           AND T.MONTH_CODE > 6;
      END;
    
      SELECT NVL(B.BONUS_AMOUNT, 0), B.MONTH_CODE
        INTO V_FESTIVAL_BONUS, V_MONTH_CODE
        FROM PRMS_BONUS_TRANSACTION B
       WHERE B.ENTITY_NUM = 1
         AND B.BRANCH_CODE = P_BRANCH_CODE
         AND B.BONUS_TYPE IN ('EIDFT', 'EIDAH', 'DURGA')
         AND B.EMP_ID = IDX.EMP_ID;
    
      V_TAX_DATA.BRANCH_CODE    := V_BRANCH_CODE;
      V_TAX_DATA.EMP_ID         := IDX.EMP_ID;
      V_TAX_DATA.DESIGNATION    := V_DESIGNATION;
      V_TAX_DATA.EMP_NAME       := V_EMP_NAME;
      V_TAX_DATA.MONTH_YEAR     := V_MONTH_YEAR;
      V_TAX_DATA.SAL_YEAR       := V_SAL_YEAR;
      V_TAX_DATA.MONTH_CODE     := V_MONTH_YEAR;
      V_TAX_DATA.BASIC_PAY      := V_BASIC_PAY;
      V_TAX_DATA.DOM_ALLOWANCE  := V_DOM_ALLOWANCE;
      V_TAX_DATA.ENTERTAINMENT  := V_ENTERTAINMENT;
      V_TAX_DATA.MED_ALLOWANCE  := V_MED_ALLOWANCE;
      V_TAX_DATA.HR_ALLOWANCE   := V_HR_ALLOWANCE;
      V_TAX_DATA.EDU_ALLOWANCE  := V_EDU_ALLOWANCE;
      V_TAX_DATA.PF_DEDUCTION   := V_PF_DEDUCTION;
      V_TAX_DATA.WELFARE_DEDUC  := V_WELFARE_DEDUC;
      V_TAX_DATA.INCOME_TAX     := V_INCOME_TAX;
      V_TAX_DATA.TEL_ALLOWANCE  := V_TEL_ALLOWANCE;
      V_TAX_DATA.DRNS_ALLOWANCE := V_DRNS_ALLOWANCE;
      V_TAX_DATA.GEN_INSURENCE  := V_GEN_INSURENCE;
      V_TAX_DATA.FESTIVAL_BONUS := V_FESTIVAL_BONUS;
      PIPE ROW(V_TAX_DATA);
    END LOOP;
  END FN_TAX_STMT_DATA;

BEGIN
  NULL;
END PKG_PRMS;
/
