      SUBROUTINE SDA1(L,MW,NEL,C,JJ,ND)
      IMPLICIT double precision (A-H,O-Z)
C     THIS SUBROUTINE CALCULATES ALL POSSIBLE REPRESENTATIONS
C     AND DETERMINES WHAT SIGMA FACTORS EXIST
C     FOR EACH REDUCED MATRIXELEMENT
C
C     L CONTAINS NQ L-VALUES
C     MW CONTAINS ALL M-VALUE COMBINATIONS
C     NEL IS THE NUMBER OF MATRIX ELEMENTS C
C     JJ IS DETERMINED IN SDA1 AND GIVES THE NUMBER OF SIGMA COMBINATIONS
C
      INCLUDE 'par/LUCN'
C
      COMMON /SDA/ CW(NDIMCW), MVM(NZIQMA,NDIMCW), KAUS,
     *           N5, IQ, NKAPO
      COMMON /FAKTOR/ F8(2*LWMAX+1)
C
      DIMENSION L(3*(2*(NZCMAX-1))),MW(NDIMC,3*(2*(NZCMAX-1)))
      DIMENSION IVM(NZIQMA),IVN(NZIQMA),IG(NZIQMA),C(NDIMC)
      DIMENSION JVM(NZIQMA),JVN(NZIQMA),LQ(3*(2*(NZCMAX-1)))
      DIMENSION KY(3*(2*(NZCMAX-1))),KYS(3*(2*(NZCMAX-1)))
      DIMENSION MKOM(2*(NZCMAX-1)+1,2*(NZCMAX-1)+1)
      DIMENSION IWN(NZIQMA),IWM(NZIQMA)
C
C     CHECK PRINTOUT
      IF(KAUS.LE.0) GOTO 20
      WRITE (NOUT,1001) NEL,ND
1001  FORMAT(' ANZAHL DER MATRIXELEMENTE',I4,'ANZAHL DER',
     1 ' DREHIMPULSE',I4)
      WRITE (NOUT,1002) (L(KH),KH=1,ND)
1002  FORMAT(' DREHIMPULSE',19I3)
      DO 10 KH=1,NEL
10    WRITE (NOUT,1003) C(KH),(MW(KH,NH),NH=1,ND)
1003  FORMAT(' MATRIXELEMENT ',E12.4,' M-WERTE',19I3)
C     PREPARATION
20    JJ=0
      NQ=N5+(ND-(2*NKAPO+1)*N5)
      ITEN=0
      IF(NQ.NE.N5) ITEN=1
C      TREATS TENSOR SEPARATELY
      IH=0
      DO 22 MH=1,NQ
      DO 22 NH=MH,NQ
      IH=IH+1
22    MKOM(MH,NH)=IH
C     MKOM GIVES THE COMBINATION OF SIGMA FACTORS
      IH=0
      DO 24  MH=1,ND
      LQ(MH)=L(MH)
24    IH=IH+L(MH)
      IF(MOD(IH,2).NE.0) GOTO 2000
C     CHECK IF SUM L EVEN
      IQ=IH/2
      IF(IH.GT.0) GOTO 28
      C1=0.
      DO 26 NH=1,NEL
26    C1=C1+C(NH)
      CW(1)=C1
      JJ=1
      MVM(1,1)=0
C     NO SIGMA FACTORS
      RETURN
28    DO 32 NH=1,NEL
      IH=0
      DO 30 MH=1,ND
30    IH=IH+MW(NH,MH)
      IF(IH.NE.0) GOTO 2001
C     CHECK IF SUM M-VALUES ZERO
32    CONTINUE
C     LOOK FOR POSSIBLE SIGMA FACTORS
C     DETERMINE INDICES JVN AND JVM
      IH=1
      MD=ND-1
      M=1
34    JVM(IH)=M
      IF(LQ(M)) 2002,54,36
36    LQ(M)=LQ(M)-1
      IF(IH-1) 2003,40,38
38    IF(M.NE.JVM(IH-1)) GOTO 40
      N=JVN(IH-1)
      GOTO 42
40    N=M+1
42    JVN(IH)=N
      IF(LQ(N)) 2002,48,44
44    LQ(N)=LQ(N)-1
      IF(IH-IQ) 46,66,2003
46    IH=IH+1
C     NEXT FACTOR SIGMA
      GOTO 34
C     LOOK FOR OTHER N
48    IF(N-ND) 50,52,2003
50    N=N+1
      GOTO 42
52    LQ(M)=LQ(M)+1
C     RESTORE L-VALUE AND LOOK FOR OTHER M
54    IF(M-MD)  56,58,2003
56    M=M+1
      GOTO 34
58    IF(IH-1)  2003,999,60
60    IH=IH-1
62    M=JVM(IH)
C     ENTRY POINT FOR SEARCH OF OTHER SIGMA COMBINATION
      N=JVN(IH)
      LQ(N)=LQ(N)+1
      GOTO 48
C     JVM AND JVN DETERMINED
C     DETERMINE INDICES IG
66    C1=0.
C     LOOP OVER ALL M-COMBINATIONS
      DO 500 KE=1,NEL
      IF(KAUS.GT.3) WRITE(NOUT,1500) KE
1500   FORMAT(' LOOP UEBER M-WERTE',I5,' TES M-ELEMENT')
      C2=C(KE)
      DO 70 NH=1,ND
      KY(NH)=L(NH)-1+MW(KE,NH)
70    KYS(NH)=L(NH)-1-MW(KE,NH)
C     KY AND KYS GIVE THE NUMBER OF ARROWS FROM N AND TO N
C     CHOOSE SIGMA FACTOR
C     PREPARATION
      IH=1
      M=JVM(IH)
      N=JVN(IH)
      GOTO 100
80    IF(IH-IQ)  82,200,2003
82    IH=IH+1
      M=JVM(IH)
      N=JVN(IH)
C     CHECK IF SAME SIGMA FACTOR
      IF(M-JVM(IH-1).NE.0) GOTO 100
      IF(N-JVN(IH-1).NE.0) GOTO 100
      IF(IG(IH-1))  140,160,100
C     TRY FOR IG=+1,ARROW FROM M TO N
100   IF(KY(N).LE.0) GOTO 140
      IF(KYS(M).LE.0) GOTO 140
      IG(IH)=1
      KY(N)=KY(N)-2
      KYS(M)=KYS(M)-2
C     NEXT SIGMA FACTOR
      GOTO 80
C     TRY FOR IG=-1,ARROW FROM N TO M
140   IF(KYS(N)) 190,162,142
142   IF(KY(M)) 190,164,144
144   IG(IH)=-1
      KY(M)=KY(M)-2
      KYS(N)=KYS(N)-2
C     NEXT SIGMA FACTOR
      GOTO 80
C     TRY FOR IG=0, NO ARROW
160   IF(KYS(N).LT.0) GOTO 190
162   IF(KY(M).LT.0) GOTO 190
164   IF(KY(N).LT.0) GOTO 190
      IF(KYS(M).LT.0) GOTO 190
      IG(IH)=0
      KY(N)=KY(N)-1
      KYS(N)=KYS(N)-1
      KY(M)=KY(M)-1
      KYS(M)=KYS(M)-1
C     NEXT SIGMA FACTOR
      GOTO 80
190   IF(IH-1) 2003,500,192
192   IH=IH-1
194   N=JVN(IH)
      M=JVM(IH)
      IF(IG(IH))  196,197,195
C     RESTORE IG=+1
195   KY(N)=KY(N)+2
      KYS(M)=KYS(M)+2
C     TRY IG=-1
      GOTO 140
C     RESTORE IG=-1
196   KY(M)=KY(M)+2
      KYS(N)=KYS(N)+2
C     TRY IG=0
      GOTO 164
C     RESTORE IG=0
197   KY(M)=KY(M)+1
      KYS(M)=KYS(M)+1
      KY(N)=KY(N)+1
      KYS(N)=KYS(N)+1
C     TRY PRIOR SIGMA FACTOR
      GOTO 190
C     END OF IG
C     UTILYSE EQUALITY OF SIGMA FACTORS
200    DO 250 IK=1,IQ
C     VM FACTOR
      KH=(JVM(IK)-1)/N5
      IVM(IK)=JVM(IK)-KH*N5*NKAPO
C      NO POLYNOMIAL = NKAPO =0,NO REDUCTION NECESSARY
      IF(ITEN*KH.EQ.3) IVM(IK)=IVM(IK)+N5
      KH=MOD(KH,3)
      IWM(IK)=KH+1
C     VN FACTORS
      KH=(JVN(IK)-1)/N5
      IVN(IK)=JVN(IK)-KH*N5*NKAPO
C      NO POLYNOMIAL = NKAPO =0,NO REDUCTION NECESSARY
      IF(ITEN*KH.EQ.3) IVN(IK)=IVN(IK)+N5
      KH=MOD(KH,3)
      IWN(IK)=KH+1
      IF(KAUS.GT.3)  WRITE (NOUT,1200) IK,JVM(IK),JVN(IK)
     1  ,IVM(IK),IVN(IK),IWM(IK),IWN(IK),IG(IK)
1200  FORMAT(' LOOP W-INDICES, IK,JVM,JVN,IVM,IVN,IWM,IWN,IG =',8I5)
C     ORDER VM .LE. VN
      IF(IVM(IK).LE.IVN(IK)) GOTO 230
      KH=IVM(IK)
      IVM(IK)=IVN(IK)
      IVN(IK)=KH
C     ORDER WM .LE. WN
230   IF(IWM(IK).LE.IWN(IK)) GOTO 250
      KH=IWM(IK)
      IWM(IK)=IWN(IK)
      IWN(IK)=KH
250   CONTINUE
C     DETERMINE CONSTANT
      C3=C2
      NF=2
      DO 320 IK=1,IQ
      IS=IK-1
      IF(IG(IK).NE.0) C3=C3*(-.5)
      IF(IS.EQ.0) GOTO 320
C     SKIP FIRST FACTOR
C     CHECK FOR EQUALITY OF ALL INDICES AND CALCULATE FACULTY
      IF(JVN(IK).NE.JVN(IS)) GOTO 310
      IF(JVM(IK).NE.JVM(IS)) GOTO 310
      IF(IG(IK).NE.IG(IS)) GOTO 310
      NF=NF+1
      GOTO 320
310   C3=C3*F8(NF)
      NF=2
320   CONTINUE
      C3=C3*F8(NF)
      C1=C1+C3
C     FACTOR DETERMINED AND SUMMED UP
      IH=IQ
C     RESTORE KY AND KYS VALUES
      IF(KAUS.GT.1) WRITE (NOUT,1320) C1,IH,(IVM(LX),IVN(LX),LX=1,IH)
1320   FORMAT(' NEUES ELEMENT C1=',G15.5,' IH=',I5,' VM VN',20I3)
      GOTO 194
500   CONTINUE
C     CHECK IF FACTOR DIFFERENT FROM ZERO
      IF(ABS(C1).LT.1.E-10) GOTO 610
      JJ=JJ+1
      IF(JJ.GT.NDIMCW) GOTO 2004
C      ORDER INDICES
      CALL SORT2(IQ,IVM,IVN)
      CW(JJ)=C1
      DO 600 IK=1,IQ
      MH=IVM(IK)
      NH=IVN(IK)
600   MVM(IK,JJ)=MKOM(MH,NH)
C     LOOK FOR DIFFERENT SIGMA FACTORS
      IF(KAUS.GT.1) WRITE(NOUT,1610)JJ,CW(JJ),(MVM(IK,JJ),IK=1,IQ)
1610  FORMAT(I5,'TES M-ELEMENT C =',G15.5,' MVM',19I3)
610   IH=IQ
      GOTO 62
999   CONTINUE
      RETURN
