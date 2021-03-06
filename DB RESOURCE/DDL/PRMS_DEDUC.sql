CREATE TABLE PRMS_DEDUC
(
  EMP_ID              VARCHAR2(20) NOT NULL,
  HB_ADV_DEDUC        NUMBER(7,2),
  MCYCLE_DEDUC        NUMBER(7,2),
  PFADV_DEDUC         NUMBER(7,2),
  PENSION             NUMBER(7,2),
  REVENUE             NUMBER(5,2),
  WELFARE             NUMBER(7,2),
  CAR_FARE            NUMBER(7,2),
  CAR_USE             NUMBER(7,2),
  GAS_BILL            NUMBER(7,2),
  WATER_BILL          NUMBER(7,2),
  ELECT_BILL          NUMBER(7,2),
  HOUSE_RENT          NUMBER(7,2),
  NEWS_PAPER          NUMBER(5,2),
  HBADV_ARREAR        NUMBER(7,2),
  PFADV_ARREAR        NUMBER(7,2),
  TEL_EXCESS_BILL     NUMBER(7,2),
  HBADV_DEDUC_PERCENT NUMBER(6,2),
  GEN_INSURANCE       NUMBER(7,2),
  BCYCLE_DEDUC        NUMBER(7,2),
  PF_DEDUCTION        VARCHAR2(1),
  OTHER_DEDUC         NUMBER(7,2),
  COMP_DEDUC          NUMBER(9,2)
);
ALTER TABLE PRMS_DEDUC
  ADD  PRIMARY KEY (EMP_ID);
  
ALTER TABLE PRMS_DEDUC
ADD   (INCOME_TAX     NUMBER(7,2),
       INCOME_TAX_ARR NUMBER(7,2));
	   
ALTER TABLE PRMS_DEDUC ADD REMARKS VARCHAR2(50);	   