      PROGRAM ENELMAS
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     ENPON FUER QUELMA 
C     ELEKTROMAGNETISCHE UEBERGANGSOPERATOREN FUER REAKTIONEN 
C  
C    
C
C    ES WERDEN PHOTONENERGIEUNABHAENGIGE MATRIXELEMENTE BERECHNET
C
C  NBAND1 KOMMT VON JQUELMA
C  NBAND2 enhaelt <BV/ABSORPTIONSOPERATOR/BV> 
C
       INCLUDE 'par/jenelmas'
C
C     1   '-NORM-OPERATOR'
C     2   '-PROTON-BAHN-OPERATOR'
C     3   '-NEUTRON-BAHN-OPERATOR'
C     4   '-PROTON-SPIN-OPERATOR'
C     5   '-NEUTRON-SPIN-OPERATOR'
C     6   '-PROTON-BAHN-OPERATOR'
C     7   '-NEUTRON-BAHN-OPERATOR'
C     8   '-PROTON-SPIN-OPERATOR'
C     9   '-NEUTRON-SPIN-OPERATOR'
C    10   '-R**L*YL-PROTON-OPERATOR'
C    11   '-R**L*YL-NEUTRON-OPERATOR'
C
      COMMON/COMY/D(100)
C
      COMMON /PARA/ PAR(NZPARM,NZKMAX),NAR(NZPARM,NZKMAX)
C     
      COMMON /POKA/ IKAPO(NZKMAX),IZP(NZKMAX),IZQ(NZKMAX+1),
     *              NZKAPO,KAPO(NZKMAX),IZPWM,NZKPL
C
      COMMON /DREH/ MLWERT(5,NZBMAX),JWERT(3,NZKMAX),
     *              MMS(5,NZBMAX),JWSL
C
      COMMON /TRIN/ 
     *    DN(NZPARM,NZPARM),GEFAK(NZOPER),
     *    UNK(NZUMAX), UMK(NZBMAX),UMKOF(NZKMAX,NZBMAX ),
     *    MMASSE(2,NZBMAX), MMLAD(2,NZBMAX),MS(3,NZKMAX),
     *    LUM(NZPARM+1,NZKMAX), NZREL(NZFMAX),
     *    NZRHO(NZFMAX), MREG(NZOPER),
     *    NUMK(NZBMAX), MUMK(NZBMAX),
     *    NCOF(NZBMAX,NZKMAX)

      DIMENSION DM(NDIM,NDIM,NZOPER)
C                  NDIM >= NZF*NZBV*NZREL
      DIMENSION DNN(NZPARM,NZPARM)

      DIMENSION NZPAQ(NZBMAX),PAQ(NZPARM,NZBMAX)
      DIMENSION NPARZ(NZFMAX)
      COMMON /MART/ 
     *    REDM(NZKMAX),
     *    OPW(NDIM,NZOPER), 
     *    OPWERT(NZOPER),
     *    KPB(NZBMAX),  LREG(NZOPER),
     *    NZPAR(NZKMAX),
     *    MLAD(2,NZKMAX),KPK(NZKMAX),
     *    NZQ(NZKMAX+1),LWERT(5,NZKMAX),MASSE(2,NZKMAX),
     *    NUM(NZPARM,NZKMAX)
C
      CHARACTER*10 CHINT(2)
            DATA CHINT /'(26I3)','(20I4)'/
C
      CHARACTER*80 INFILE, OUTPUTout, FORMFAout
      
      call getarg(1,INFILE)
      OPEN(UNIT=5,FILE=INFILE,STATUS='OLD')
      
      call getarg(2,OUTPUTout)
      OPEN(UNIT=6,FILE=OUTPUTout)
      
      call getarg(3,FORMFAout)
      OPEN(UNIT=19,FILE='MATOUT',STATUS='UNKNOWN',FORM='FORMATTED')
      OPEN(UNIT=15,FILE=FORMFAout,FORM='UNFORMATTED',
     *     STATUS='REPLACE')
C 	    
 1002 FORMAT(20I3)
 1003 FORMAT(1H1) 
 1035 FORMAT(1X,'J(BIND)  = ',I3,' /2  -'//)
 1034 FORMAT(1X,'J(BIND)  = ',I3,' /2  +'//)
 1025 FORMAT(/1X,'J(STREU) = ',I3,' /2  -'/)
 1024 FORMAT(/1X,'J(STREU) = ',I3,' /2  +'/)
 1006 FORMAT(27H FEHLER IN DEN EINGABEDATEN ,4I3) 
 1011 FORMAT(30H BENUTZTE RADIALFUNKTIONEN      ,/20I3) 
 1018 FORMAT (2H0/,I4,4H ) =,4(F10.4,2H /,I4,2H )), 
     1   30(/,9X,4(F10.4,2H /,I4,2H ))))  
C
      OPEN(UNIT=3,STATUS='SCRATCH',FORM='UNFORMATTED')
      OPEN(UNIT=4,STATUS='SCRATCH',FORM='UNFORMATTED')

      OPEN(UNIT=10,FILE='QUAOUT',STATUS='OLD',FORM='UNFORMATTED')
C
      NBAND2=15
      INPUT=5
      HC=197.32858
      H2MCP=HC/938.2796/2.
      H2MCN=HC/939.5731/2.
      D(1)=.0 
      D(2)=.0 
      DO 199 I=2,99 
      HMH=I
  199 D(I+1)=LOG( HMH)+D(I) 

      READ(INPUT,1002) NBAND1,IGAK,KAUSD,KEIND ,IDUM
C  BEI IGAK=1,2,3 WIRD UEBERGABE VON QUELMA AUSGEDRUCKT 
C  BEI KAUSD=2 WERDEN UNNORMIERTE MATRIXELEMENTE, 
C  BEI KAUSD=1 REDUZIERTE MATRIXELEMENTE
C  ZWISCHEN BOUNDSTATE(AUFSUMMIERT) UND BASISFUNKTION(KANAL,WEITE) AUDGEDRUCKT
C  KEIND.NE.0 DIENT ZUM UEBERLAGERN VON BASISVEKTOREN, INSBES. POLYNOMEN
      IF(IDUM.NE.2) IDUM=1
C     IDUM=2 WAEHLT FORMAT 20I4 FALLS MEHR ALS 999 KANAELE ODER BV
C
      READ(INPUT,1002) (MREG(K),K=1,NZOPER)
      IF (MREG(10).EQ.0.OR.MREG(11).EQ.0) then
        write(6,*)'SIEGERT VERSION: MKC 10 and 11 must be != 0.'
        STOP 23
      ENDIF
c             
      READ(INPUT,1013) (GEFAK(K),K=1,4) 
1013  FORMAT(4F12.4)
      GEFAK(1) = 1.
      DO 114 K=2,5,2
      GEFAK(K)=GEFAK(K)*H2MCP
114   GEFAK(K+1)=GEFAK(K+1)*H2MCN 
      DO 110 K=1,4
110   GEFAK(5+K)=GEFAK(K+1)
c 
C r^LY_L - proton
      GEFAK(10) = 1.0
C r^LY_L - neutron      
      GEFAK(11) = 0.0
C
      REWIND NBAND1 
      REWIND NBAND2 
      READ(NBAND1)NZF,MUL,(LREG(K),K=1,NZOPER),NZBASV,(NZRHO(K),K=1,NZF)
       IF(NZBASV.GT.NZBMAX)  GOTO 808

1010  FORMAT(1X,'L = ',I2,' - OPERATOREN',11I3) 
      DO 1 N=1,NZBASV 
      READ(NBAND1) MM,(MMASSE(J,N),J=1,2),(MMLAD(J,N),J=1,2), 
     1 (MMS(J,N),J=1,3),(MLWERT(J,N),J=1,5),(PAQ(J,N),J=1,MM),KPB(N)
      NZPAQ(N)=MM 
       IF(IGAK.EQ.0.) GOTO 1
      WRITE(NOUT,196) N,(MMASSE(J,N),J=1,2),(MMLAD(J,N),J=1,2),
     1     (MMS(J,N),J=1,3),(MLWERT(J,N),J=1,5),KPB(N)
  196 FORMAT(/I6/2(I6,I3),I6,2I3,I6,4I3,I6) 
    1 CONTINUE

      READ(INPUT,1002)JWSL,JWSR,JWSLM,MULM 

C    L=STREU,  R=BIND
      GJL  =.5*REAL(JWSL)
      GJR  =.5*REAL(JWSR)
      GJLM =.5*REAL(JWSLM) 
      AK   =   REAL(MUL) 
      AKM  =.5*REAL(MULM)
C      AKM=GJL-GJR
      AJRD=REAL(JWSR+1)
      AJLD=REAL(JWSL+1)
      MUL2=2*MUL
      
c this coupling coefficient is used only to assess whether the matrix element
c is !=0; its value is considered in the python post-processing of the output
c of this program

      CL=CLG(INT(2*AK), INT(2*GJR),INT(2*GJL),
     1       INT(2*AKM),INT(2*(GJLM-AKM)))      
C    CLEBSCH  FUER <STREU//ABSORPTIONSOPERATOR//BIND> 
      IF(CL.EQ.0.) stop 4

      DO 1126 NZERL=1,NZF
      NBVO = 1
      DO 1127 NZERLE=1,NZERL-1
1127  NBVO = NBVO + NZRHO(NZERLE)
1126  NPARZ(NZERL) = MOD(MLWERT(3,NBVO)+MLWERT(4,NBVO),2)

      OPW    = 0.
      OPWERT = 0.
      
      DM  = 0.
      DN  = 0.
      DNN = 0.
C
      NBAND=NBAND1
      NTI=1
C
      DO 140 MFL=1,NZF
C
      IRHO=NZRHO(MFL)
C
      MFRMAX=MFL
C        
      DO 139 MFR=1,MFRMAX
C
      JRHO=NZRHO(MFR)
C        

      DO 41 MKC=1,NZOPER
c
      A=IABS(((-1)**MUL-1)/2)
c      write(nout,*)'A=',A
      AA=IABS(NPARZ(MFL)-NPARZ(MFR))
c      write(nout,'(A19,2I3)')'(ecce) Parity L/R: ',
c     *  NPARZ(MFL),NPARZ(MFR)

      IF(LREG(MKC).LE.0) GOTO 41
      FPAR = 1.

      DO 401 NBVL=1,IRHO
C                     RECHTS        
        DO 402 NBVR=1,JRHO
C
c      IF (MFL.ne.MFR) THEN
C        NTI = 1 if 1<=MKC<=11
      READ (NBAND) NUML,NUMR,IK1,JK1,
     *       ((DNN(K,L),K=1,IK1),L=1,JK1)
C     * (IDUMMY,DNN(K,L,J),J=1,LL1),L=1,JK1),K=1,IK1)     
#ifdef DBG
      write(6,*)'MKC=',MKC
      write(6,'(A13,5I4)') '(from qual): ',NUML,NUMR,IK1,JK1
      write(6,'(2E24.8)') ((DNN(K,L),K=1,IK1),L=1,JK1)
#endif
          NZREL(MFL) = IK1
          NZREL(MFR) = JK1

C      IF(MREG(MKC).LE.0) GOTO 40
C      IF (IK1*JK1.EQ.1 .AND. DN(1,1).EQ.0.) GOTO 40 
      LBL=MLWERT(5,NUML)
      LBL2=2*LBL
      LBR=MLWERT(5,NUMR)
      LBR2=2*LBR
      ML=MMS(3,NUML)  
      SPL=.5* REAL(ML) 
      MR=MMS(3,NUMR)  
      SPR=.5* REAL(MR) 
      GOTO(99,91,91,92,92,91,91,92,92,91,91) MKC 
91    CONTINUE
C     BAHNOPERATOREN, SIEGERT UND KORREKTUROPERATOR
      IF(ML.NE.MR) THEN
c         WRITE (6,1200) MKC, ML, MR
         FPAR = 0.
      ENDIF
C
C    o/srank: rank of the spatial/spin component of the radiation operator
      ISRANK2  = INT(0)
C    if spin rank=0, I set the m projection maximal which is allowed b/c
C    this is the reduced matrix element       
      IORANK2  = INT(MUL2)

c lines 1,2: separation of spatial and spin MEs
c lines 3,4: Clebsch from WE theorem (reduced ME)

      FK1new = SQRT(JWSR+1.)*SQRT(MUL2+1.)
     1  *F9J(LBL2,LBR2,IORANK2,ML,MR,ISRANK2,JWSL,JWSR,MUL2)
     2  *CLG(INT(2*GJR),INT(2*AK),INT(2*GJL),
     3      INT(2*(GJLM-AKM)),INT(2*AKM))

#ifdef DBG
      write(nout,*) SQRT(JWSR+1.),SQRT(MUL2+1.)
     1  ,F9J(LBL2,LBR2,IORANK2,ML,MR,ISRANK2,JWSL,JWSR,MUL2)
     2  ,CLG(INT(2*GJR),INT(2*AK),INT(2*GJL),
     3      INT(2*(GJLM-AKM)),INT(2*AKM))
#endif

C      FK1new = F9J(LBL2,LBR2,IORANK2,ML,MR,ISRANK2,JWSL,JWSR,MUL2)
C     2  *CLG(INT(2*GJR),INT(2*AK),INT(2*GJL),
C     3      INT(2*(GJLM-AKM)),INT(2*AKM))

C      write(nout,*) 'FK1new,MFL/R,MKC = ', FK1new,MFL,MFR,MKC
C      WRITE(6,*) ' Jr mr Jl ml  L mL Sl Sr Ll Lr'
C      write(6,'(10I3)')Int(GJR),INT(GJLM-AKM),Int(GJL),Int(GJLM),
C     *  Int(AK),Int(AKM),Int(ML*0.5),
C     *  Int(MR*0.5),Int(LBL2*0.5),Int(LBR2*0.5)

      GOTO 100
      
92    FK1=(-1)**((ML+MR+LBL2+LBR2+JWSL+JWSR)/2) 
      FK1=FK1*SQRT(AJRD*AJLD) 
      FK2=FK1*REAL((-1)**(LBR-LBL))
      MUL2M1=MUL2 
      IF(MKC.EQ.4.OR.MKC.EQ.5) GOTO 93
      MUL2M1=MUL2-2 
93    CONTINUE
      FK1=FK1*F9J(ML,MR,2,LBL2,LBR2,MUL2M1,JWSL,JWSR,MUL2)
      FK2=FK2*F9J(MR,ML,2,LBR2,LBL2,MUL2M1,JWSL,JWSR,MUL2)
      goto 100

99    CONTINUE
C     NORM
C     this factor matches the one for the non-central operators
C     while considering the rank-zero values in the 9J
      FK1new=(-1)**(LBR)*F6J(LBR2,MR,JWSR,ML,LBL2,0)
C      IF ((ML.NE.MR).or.(LBR2.ne.LBL2)) THEN
C        WRITE (6,*) 'norm op should yield zero for ',MKC, ML, MR
C        STOP 13
C      ENDIF

100   CONTINUE

C  for F1 <J'|L|J> + F2 <J|L|J'>
      IF (MREG(MKC).eq.0) THEN
      FK1new = 0.
      ENDIF
C     ALLE OPERATOREN
C                 = hbarc/mn for siegert proton      
      F1=FK1new*GEFAK(MKC)*FPAR
#ifdef DBG
      write(6,'(A30,5F12.8,I3/)')'F1,F,FK1new,GEFAK(MKC),FPAR,MKC',
     *           F1,F,FK1new,GEFAK(MKC),FPAR,MKC
#endif
      DO 458 K=1,IK1
      DO 458 L=1,JK1
      if(MKC.ne.1) then        
      DNN(K,L) = F1*DNN(K,L)
      ELSE
#ifdef DBG      
      write(nout,*)'nf=',F1
#endif      
      DNN(K,L) = F1*DNN(K,L)
C      DNN(K,L) = 0.5*F1*DNN(K,L)      
      endif
#ifdef DBG
      write(nout,'(A13,F8.4,3I3)')'(ecce) DNN = ',DNN(K,L),K,L
#endif
  458 CONTINUE
C 
      DO 459 K=1,IK1
      DO 459 L=1,JK1        
      DN(K,L) = DN(K,L) + DNN(K,L)
  459 CONTINUE    
C
      NROWOz = 1
      NCOLOz = 1

      DO 221 nr=1,MFL-1
  221  NROWOz = NROWOz + NZRHO(nr)*NZREL(nr)
      DO 222 nc=1,MFR-1
  222  NCOLOz = NCOLOz + NZRHO(nc)*NZREL(nc)
c      write(nout,*)MFL,MFR,NCOLOz,NROWOz
C
c      write(nout,'(A20,2I5)') '(ecce): row0, col0: ',NROWOz,NCOLOz  
      NROWOv=NROWOz
      NCOLOv=NCOLOz
      DO 223 nr=1,NBVL-1
  223  NROWOv = NROWOv + NZREL(MFL)
      DO 224 nc=1,NBVR-1
  224  NCOLOv = NCOLOv + NZREL(MFR)

      NROW = NROWOv
      DO 469 K=1,IK1
      NCOL = NCOLOv
      DO 468 L=1,JK1
      if(ABS(DN(K,L)).lt.1E-20) DN(K,L)=0
c additional check for the norm: any n-element < threshold is =0
C      if(DN(L,L).lt.1E-20) DN(L,L)=ABS(DN(L,L))
C      if(DN(K,K).lt.1E-20) DN(K,K)=ABS(DN(K,K))
      DM(NROW,NCOL,MKC) = DN(K,L)
c      if(MKC.eq.10) then
C      write(6,'(2I2,A11,I2,A1,I2,A1,I2,A4,2E18.8)')K,L,
C     *   '(ecce): DM(',NROW,',',NCOL,',',MKC,') = ',
C     *   DN(K,L),DN(L,K)
c      endif
      NCOL = NCOL + 1
  468 CONTINUE
      NROW = NROW + 1
  469 CONTINUE
C
      DN = 0.
      DNN= 0.
C     ENDE LOOP BASISVEKTOR-RECHTS
  402 CONTINUE
C     ENDE LOOP BASISVEKTOR-LINKS      
  401 CONTINUE
C     ENDE LOOP OPERATOREN
   41 CONTINUE
C     ENDE LOOP ZERLEGUNGEN RECHTS
  139 CONTINUE
C     ENDE LOOP ZERLEGUNGEN LINKS
  140 CONTINUE
#ifdef DBG
      write(nout,*) 'norm_diag -start',NCOL,NROW    
      write(nout,*) (DM(L,L,1),L=1,NROW-1 )
      write(nout,*) 'norm_diag -end'
#endif
C  DM(K,L,10) <-> proton
C  DM(K,L,11) <-> neutron  (see jump labels 114-117 in jobelmanoo.f)

      WRITE(NBAND2)
     *   (( DM(K,L,10)/SQRT(DM(L,L,1)*DM(K,K,1))     
     *   ,L=1,NCOL-1 ),K=1,NROW-1 )

      write(NBAND2) ((DM(K,L,1),L=1,NCOL-1 ),K=1,NROW-1 )
      write(19,'(F20.12)') ((DM(K,L,1),L=1,NCOL-1 ),K=1,NROW-1 )
#ifdef DBG
      write(nout,*)'op-me'
      WRITE(nout,'(F30.10)')
     *   (( DM(K,L,10)/SQRT(DM(L,L,1)*DM(K,K,1))      
     *   ,L=1,NCOL-1 ),K=1,NROW-1 )
      write(nout,*)'norm-me'
      write(nout,'(F30.10)') ((DM(K,L,1),L=1,NCOL-1 ),K=1,NROW-1 )      
#endif
C      if(DM(K,L,10).ne.0) then
C      write(nout,*)'non-zero MEs'
C      WRITE(nout,*)
C     *   (( DM(K,L,10)/SQRT(DM(L,L,1)*DM(K,K,1))
C     *   ,L=1,NCOL-1 ),K=1,NROW-1 )
C      else
C      write(nout,*)'zero MEs'
C      WRITE(nout,*)
C     *   (( (DM(K,L,10)+DM(K,L,11))
C     *   ,L=1,NCOL-1 ),K=1,NROW-1 )
C      endif

      goto 666
c
      DO 143 K=1,NROW-1
      DO 143 L=1,NCOL-1
      WRITE(19,'(A38,2I3,3E12.4)') 
     *      '(K,L) DM(K,L,1),DM(K,L,10),DM(K,L,11):',
     *       K,L,DM(K,L,1),DM(K,L,10),DM(K,L,11)
      write(19,'(2F20.12)')DM(L,L,1),DM(K,K,1)     
  143 WRITE(19,'(F20.12)')
     *  DM(K,L,10)

C       DO 42 KANL=1,NZKL
C       DO 142 KANR=NZKL1,NZKA
C       FAK1 = UMKOF(KANL,NUML)*UMKOF(KANR,NUMR)
C       FAK2 = UMKOF(KANL,NUMR)*UMKOF(KANR,NUML)
C       write(nout,*)'tmp:',FAK1,FAK2
C       IF(ABS(FAK1)+ABS(FAK2).LT.1.E-12) GOTO 142
C       IF(NUML.EQ.NUMR) FAK2=0.
C       FA=FAK1*F1
C       FB=FAK2*F2
C       DO 46 K=1,IK1 
C       DO 146 L=1,JK1  
C       K1=LUM(K,KANL)  
C       L1=LUM(L,KANR)  
C       K2=LUM(K,KANR)
C       L2=LUM(L,KANL)
C       KK=NZQ(KANL)+K1
C       LL=NZQ(KANR)+L1
C       LK=NZQ(KANR)+K2
C       KL=NZQ(KANL)+L2
C       IF(K1*L1.LE.0) GOTO 44
Cc      OP(KK,LL)=OP(KK,LL)+DN(K,L)*FA
C       OPW(KK,MKC)=OPW(KK,MKC)+DN(K,L)*FA
C 44    IF(K2*L2.LE.0) GOTO 45
Cc      OP(KL,LK)=OP(KL,LK)+DN(K,L)*FB
C       OPW(KL,MKC)=OPW(KL,MKC)+DN(K,L)*FB
CC    OPW = <BIND//EMISSIONSOPERATOR//STREU>
C 45    CONTINUE
C 146   CONTINUE
CC     LOOP PARAMETER RECHTS 
C 46    CONTINUE
CC     LOOP PARAMETER LINKS
C 142   CONTINUE
CC  LOOP KANAELE LINKS
C 42    CONTINUE
C      write(nout,*) OPW(1,MKC)
c C  LOOP KANAELE RECHTS
c    40 CONTINUE
C     LOOP MATRIZEN 
c      IF(KAUSD.LT.2) GOTO 51
c      WRITE(NOUT,1201) MKC 
c 1201  FORMAT(/1X,'OPERATOR',I3) 
c      CALL SCHEMA(OP,MMM,MMM,NDIM)
c
c       DO 150 MKC=1,NZOPER
c       DO 150 K=1,MM
c 150   OPW(K,MKC)=OPW(K,MKC)*SQRT(2.*GJL+1.)/CL/ANORMB 
c       REWIND NBAND2
c       WRITE(NBAND2) MUL, JWSL,JWSR,NZKPL,EB 
c       DO 151 K=1,NZKPL
c       MH=KAPO(K)
c       WRITE(NBAND2) LWERT(4,MH),(JWERT(KH,MH),KH=1,3),REDM(MH)
c      $,MASSE(1,MH),MASSE(2,MH),MLAD(1,MH),MLAD(2,MH)
c 151   CONTINUE
c c
c       CALL POLKA(NZPAR,NZQ,NBAND2)
c       WRITE(NBAND2)((OPW(K,MKC),K=1,MM),MKC=1,NZOPER) 
c 
      WRITE(NOUT,1222)
1222  FORMAT(1X,'END OF ENELMAS')
      GOTO 666
   16 WRITE(NOUT,1006)  N,N2 ,J
      GOTO 666  
808    PRINT 809,NZBASV,NZBMAX 
809    FORMAT(' TOO MANY BASISVECTORS',2I10)
       GOTO 666
905   PRINT 906,MMM,NDIM 
906   FORMAT(' TOO MANY RADIALPARAMETERS*CHANNELS',2I5) 
      GOTO 666
911   WRITE(NOUT,1204) GJR,GJR,AK,AKM,GJL,GJL,CL 
1204  FORMAT(1X,'(',4F6.1,'  / ',2F6.1,' ) = ',F6.2)
      GOTO 666
910   PRINT 1200,MKC,ML,MR
1200  FORMAT(1X,'BEI OPERATOR',I2,'  SL.NE.SR ',2I5)
      GOTO 666
888   PRINT 1300,NZKA,NZKMAX
1300  FORMAT(1X,'ZU VIELE KANAELE',2I5) 
666   continue
      END 
      SUBROUTINE SCHEMA(S,IM1,IM2,JM2)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C  AUFRUF VON SCHEMA   (NAME,ZEILENZAHL,SPALTENZAHL,ZEILENDIMENSION)
       INCLUDE 'par/jenelmas'
      DIMENSION S(1)  
      IMGA=IM2/10 
      IF(IMGA)    10,10,11
   11 CONTINUE
      DO 30  LL=1,IMGA
      LXU=(LL-1)*10 +1
      LXO=LL*10 
      PRINT 2019,(LO,LO=LXU,LXO)
      DO 30  K=1,IM1  
      I1=(LXU-1)*JM2+K
      I2=(LXO-1)*JM2+K
   30 PRINT 2018,K,(S(I),I=I1,I2,JM2) 
   10 CONTINUE
      LXU=1+IMGA*10 
      IF(LXU-IM2) 2,2,1 
    2 CONTINUE
      PRINT 2019,(LO,LO=LXU,IM2)
      DO 100  K=1,IM1 
      I1=(LXU-1)*JM2+K
      I2=(IM2-1)*JM2+K
  100  PRINT 2018,K,(S(I),I=I1,I2,JM2)
    1 CONTINUE
 2018 FORMAT(1X,I3,2X,1P10E12.4)
 2019 FORMAT(/10(10X,I2)/)
      RETURN
      END 
       SUBROUTINE UMKOPM(KL,LL,F)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     UMKOP BERECHNET 9J(L1,L2,L3;S1,S2,S3;J1,J2,J3)*
C      6J(J,S3,L5;L3,L4,J3)*
C       HAT(J1,J2,L3,S3,L5,J3)*(-)**(L5+S3-J)
c      phase mit +j!!!!!!!!!!!!
       INCLUDE 'par/jenelmas'
C
C
      COMMON /DREH/ MLWERT(5,NZBMAX),JWERT(3,NZKMAX),
     *              MMS(5,NZBMAX),JWSL
C
C
      FL1=(JWERT(1,KL)+1)*(JWERT(2,KL)+1)*(JWERT(3,KL)+1)
     1*(2*MLWERT(3,LL)+1)*(2*MLWERT(5,LL)+1)*(MMS(3,LL)+1)
      PHAS=(-1)**((MMS(3,LL) - JWSL)/2+MLWERT(5,LL))
      F=F9J(2*MLWERT(1,LL),2*MLWERT(2,LL),2*MLWERT(3,LL),
     1      MMS(1,LL),MMS(2,LL),MMS(3,LL),
     2      JWERT(1,KL),JWERT(2,KL),JWERT(3,KL))*
     3  F6J(JWSL,MMS(3,LL),2*MLWERT(5,LL),
     4      2*MLWERT(3,LL),2*MLWERT(4,LL),JWERT(3,KL))*SQRT(FL1)*PHAS
      RETURN
      END
      SUBROUTINE POLKA(MZP,MZQ,NBAND2)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
       INCLUDE 'par/jenelmas'
      DIMENSION MZP(NZKMAX),MZQ(NZKMAX+1) 
      DIMENSION IDUM(30),DUM(30)
C
      COMMON /PARA/ PAR(NZPARM,NZKMAX),NAR(NZPARM,NZKMAX)
C     
      COMMON /POKA/ IKAPO(NZKMAX),IZP(NZKMAX),IZQ(NZKMAX+1),
     *              NZKAPO,KAPO(NZKMAX),IZPWM,NZKPL
      IZQ(1)=0
      K1=1
      IZPWM=0 
      DO 20 I=1,NZKPL 
      K2=KAPO(I)
      IZP(I)=0
      DO 10 KH=K1,K2
10    IZP(I)=IZP(I)+MZP(KH) 
      K1=K2+1 
      IZQ(I+1)=IZQ(I)+IZP(I)
20    IZPWM=MAX0(IZPWM,IZP(I))
      IF(IZQ(NZKPL+1).NE.MZQ(K2+1)) STOP 333
      WRITE (NBAND2) IZQ(NZKPL+1),IZPWM,(IZP(I),IZQ(I),I=1,NZKPL) 
      K1=1
      DO 30 IH=1,NZKPL
      K2=KAPO(IH) 
      I=0 
      DO 25 KH=K1,K2
      N=MZP(KH) 
      DO 24 NH=1,N
      I=I+1 
      IDUM(I)=NAR(NH,KH)
24    DUM(I)=PAR(NH,KH) 
25     CONTINUE 
      WRITE(NBAND2) (IDUM(K),K=1,IZPWM) 
      WRITE(NBAND2) (DUM(K),K=1,IZPWM)
30    K1=K2+1 
      RETURN
      END 
      SUBROUTINE DEFPOKA(NZP,NZKL,NZKR,IND) 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     DEFPOKA DEFINIERT DIE POLYNOMKANAELE
       INCLUDE 'par/jenelmas'
C     
      COMMON /POKA/ IKAPO(NZKMAX),IZP(NZKMAX),IZQ(NZKMAX+1),
     *              NZKAPO,KAPO(NZKMAX),IZPWM,NZKPL
      DIMENSION NZP(NZKMAX) 
      NZKA=NZKL+NZKR
      IZQ(1)=0
      IF(IND.EQ.0) GOTO 30
      IF(NZKAPO.EQ.0) GOTO 30 
      DO 20 IHX=1,NZKAPO
      PRINT 5,IHX 
5     FORMAT(' ZUM',I3,' -TEN POLYNOMKANAL GEHOEREN DIE KANAELE') 
      IHY=0 
      DO 10 IH=1,NZKA 
      IF(IKAPO(IH).NE.IHX) GOTO 10
      KAPO(IHX)=IH
C    ZUORDNUNG POLYNOMKANAL LETZTER EINFACHER KANAL 
      IHY=IHY+NZP(IH) 
      PRINT 6,IH
6     FORMAT(I5)
10    CONTINUE
      IZP(IHX)=IHY
      IZQ(IHX+1)=IZQ(IHX)+IHY 
20      CONTINUE
      RETURN
30    DO 35 I=1,NZKA
      KAPO(I)=I 
      IKAPO(I)=I
      IZP(I)=NZP(I) 
35    IZQ(I+1)=IZQ(I)+IZP(I)
      NZKAPO=NZKA 
      NZKPL=NZKL
      RETURN
      END 
      DOUBLE PRECISION FUNCTION CLG(J1,J2,J3,M1,M2)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C 
C     CLG BERECHNET DIE CLEBSCH-GORDAN-KOEFFIZIENTEN
C     (J1/2,M1/2;J2/2,M2/2|J3/2,(M1+M2)/2) NACH
C     EDMONDS 'ANGULAR MOMENTUM IN QUANTUM MECHANICS',
C     PRINCETON, 1960 GLEICHUNGEN (3.10.60), (3.7.3)
C     UND TABELLE 2 (1. GLEICHUNG)
C
C     BENUTZT COMMON /COMY/ MIT DEN LOGRITHMEN DER
C     FAKULTAETEN
C
C     M. UNKELBACH 1989
C     LETZTE AENDERUNG: 06.02.89
C
C
      INTEGER JW1, JW2, JW3, MW1, MW2, MW3, JSUM, JSUM1,
     *        JDIF1, JDIF2, JDIF3, JMSUM1, JMSUM2, JMSUM3,
     *        JMDIF1, JMDIF2, JMDIF3, JJM1, JJM2, IMAX, IMIN,
     *        I, J1, J2, J3, M1, M2
C
      DOUBLE PRECISION FAKLN, CLGH
C
      COMMON /COMY/ FAKLN(0:99)
C     FAKLN(I) = LOG(I!)
C
C
C
C
      JW1=J1
      JW2=J2
      JW3=J3
      MW1=M1
      MW2=M2
C
C     CHECK, OB CLG = 0
      CLG=0.
      IF (JW1.LT.IABS(MW1)) RETURN
      IF (JW2.LT.IABS(MW2)) RETURN
      IF (JW3.GT.JW1+JW2.OR.JW3.LT.IABS(JW1-JW2)) RETURN
      MW3=MW1+MW2
      IF (JW3.LT.IABS(MW3)) RETURN
      JMSUM1=JW1+MW1
      JMSUM2=JW2+MW2
      JMSUM3=JW3+MW3
      IF (MOD(JMSUM1,2).EQ.1) RETURN
      IF (MOD(JMSUM2,2).EQ.1) RETURN
      IF (MOD(JMSUM3,2).EQ.1) RETURN
C
C
      JSUM=(JW1+JW2+JW3)/2
      JSUM1=JSUM+1
      JDIF1=JSUM-JW1
      JDIF2=JSUM-JW2
      JDIF3=JSUM-JW3
C
      IF (IABS(MW1)+IABS(MW2).EQ.0) GOTO 100
C
C     NORMALE CLEBSCH-GORDAN-KOEFFIZIENTEN
      JMSUM1=JMSUM1/2
      JMDIF1=JMSUM1-MW1
      JMSUM2=JMSUM2/2
      JMDIF2=JMSUM2-MW2
      JMSUM3=JMSUM3/2
      JMDIF3=JMSUM3-MW3
      JJM1=JDIF1+JMDIF1
      JJM2=JDIF3-JMDIF1
      IMIN=MAX0(0,-JJM2)
      IMAX=MIN0(JMDIF1,JMDIF3)
C
      CLGH=0.
      DO 50, I=IMIN, IMAX
       CLGH=CLGH+DBLE(1-2*MOD(I,2))*
     *     EXP(FAKLN(JMSUM1+I)+FAKLN(JJM1-I)-FAKLN(I)-FAKLN(JMDIF1-I)-
     *         FAKLN(JMDIF3-I)-FAKLN(JJM2+I))
50    CONTINUE
C
      IF (IMIN.GT.IMAX) CLGH=1.
      CLGH=CLGH*EXP((FAKLN(JDIF3)+FAKLN(JMDIF1)+FAKLN(JMDIF2)+
     *             FAKLN(JMDIF3)+FAKLN(JMSUM3)-FAKLN(JSUM1)-
     *             FAKLN(JDIF1)-FAKLN(JDIF2)-FAKLN(JMSUM1)-
     *             FAKLN(JMSUM2)+FAKLN(JW3+1)-FAKLN(JW3))*.5)
      CLG=CLGH*DBLE(1-2*MOD(JMDIF1,2))
C
C     ENDE DER BERECHNUNG FUER NORMALE CLEBSCH-GORDAN-KOEFFIZIENTEN
      RETURN
C
C
C
100   CONTINUE
C     PARITAETSCLEBSCH
C
      IF (MOD(JSUM,2).EQ.1) RETURN
C
      CLGH=EXP((FAKLN(JDIF1)+FAKLN(JDIF2)+FAKLN(JDIF3)-FAKLN(JSUM1)+
     *         FAKLN(JW3+1)-FAKLN(JW3))*.5+
     *        FAKLN(JSUM/2)-FAKLN(JDIF1/2)-FAKLN(JDIF2/2)-
     *        FAKLN(JDIF3/2))
      CLG=CLGH*DBLE(1-2*MOD((JSUM+JW1-JW2)/2,2))
C
C
C     ENDE DER RECHNUNG FUER PARITAETSCLEBSCH
      RETURN
      END
      FUNCTION F6J(JD1,JD2,JD3,LD1,LD2,LD3)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     VERSION I F6J FUNCTION CALLS S6J  FORTRAN IV
C     VEREINFACHT 27.9.95 H.M.H
      J1=JD1
      J2=JD2
      J3=JD3
      L1=LD1
      L2=LD2
      L3=LD3
C     ANGULAR MOMENTUM COUPLING TESTS FOR 6J COEFFICIENT
      F6J=0.0
      IF(J1.LT.0 .OR. J2.LT.0 .OR. J3.LT.0) RETURN
      IF(L1.LT.0 .OR. L2.LT.0 .OR. L3.LT.0) RETURN
      IF(MOD(J1+J2+J3,2).NE.0) RETURN
      IF(J3.GT.J1+J2 .OR. J3.LT.ABS(J1-J2)) RETURN
      IF(MOD(J1+L2+L3,2).NE.0) RETURN
      IF(L3.GT.J1+L2 .OR. L3.LT.ABS(J1-L2)) RETURN
      IF(MOD(L1+J2+L3,2).NE.0) RETURN
      IF(L3.GT.L1+J2 .OR. L3.LT.ABS(L1-J2)) RETURN
      IF(MOD(L1+L2+J3,2).NE.0) RETURN
      IF(J3.GT.L1+L2 .OR. J3.LT.ABS(L1-L2)) RETURN
      F6J=S6J(J1,J2,J3,L1,L2,L3)
      RETURN
      END
      FUNCTION F9J(JD1,JD2,JD3,JD4,JD5,JD6,JD7,JD8,JD9)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     F9J VERSION I  CALLS S6J  FORTRAN IV
C     VEREINFACHT 27.9.95 H.M.H.
      DIMENSION KN(6),KX(6),NN(6)
      J1=JD1   
      J2=JD2  
      J3=JD3 
      J4=JD4
      J5=JD5
      J6=JD6
      J7=JD7
      J8=JD8
      J9=JD9
      F9J= 0.0
C     ANGULAR MOMENTUM COUPLING TESTS FOR 9J COEFFICIENT 
      IF(MOD(J1+J2+J3,2).NE.0) RETURN
      IF(J3.GT.J1+J2 .OR. J3.LT.ABS(J1-J2)) RETURN
      IF(MOD(J4+J5+J6,2).NE.0) RETURN
      IF(J6.GT.J4+J5 .OR. J6.LT.ABS(J4-J5)) RETURN
      IF(MOD(J7+J8+J9,2).NE.0) RETURN
      IF(J9.GT.J7+J8 .OR. J9.LT.ABS(J7-J8)) RETURN
      IF(MOD(J1+J4+J7,2).NE.0) RETURN
      IF(J7.GT.J1+J4 .OR. J7.LT.ABS(J1-J4)) RETURN
      IF(MOD(J2+J5+J8,2).NE.0) RETURN
      IF(J8.GT.J2+J5 .OR. J8.LT.ABS(J2-J5)) RETURN
      IF(MOD(J3+J6+J9,2).NE.0) RETURN
      IF(J9.GT.J3+J6 .OR. J9.LT.ABS(J3-J6)) RETURN
      KN(1)=MAX0(IABS(J2-J6),IABS(J1-J9),IABS(J4-J8))
      KN(2)=MAX0(IABS(J2-J7),IABS(J5-J9),IABS(J4-J3))
      KN(3)=MAX0(IABS(J6-J7),IABS(J5-J1),IABS(J8-J3))
      KN(4)=MAX0(IABS(J6-J1),IABS(J2-J9),IABS(J5-J7))
      KN(5)=MAX0(IABS(J2-J4),IABS(J3-J7),IABS(J6-J8))
      KN(6)=MAX0(IABS(J3-J5),IABS(J1-J8),IABS(J4-J9))
      KX(1)=MIN0(J2+J6,J1+J9,J4+J8)
      KX(2)=MIN0(J2+J7,J5+J9,J4+J3)
      KX(3)=MIN0(J6+J7,J5+J1,J8+J3)
      KX(4)=MIN0(J1+J6,J2+J9,J5+J7)
      KX(5)=MIN0(J2+J4,J3+J7,J6+J8)
      KX(6)=MIN0(J3+J5,J1+J8,J4+J9)
      DO 35 K=1,6
   35 NN(K)=KX(K)-KN(K)
      KSIGN=1
      I=MIN0(NN(1),NN(2),NN(3),NN(4),NN(5),NN(6))
      DO 40 K=1,6
      IF(I-NN(K))40,50,40
   40 CONTINUE
   50 KMIN=KN(K)+1
      KMAX=KX(K)+1
      GO TO(130,52,53,54,55,56),K
   52 J=J1
      J1=J5
      J5=J
      J=J3
      J3=J8
      J8=J
      J=J6
      J6=J7
      J7=J
      GO TO 130
   53 J=J2
      J2=J7
      J7=J
      J=J3
      J3=J4
      J4=J
      J=J5
      J5=J9
      J9=J
      GO TO 130
   54 J=J1
      J1=J2
      J2=J
      J=J4
      J4=J5
      J5=J
      J=J7
      J7=J8
      J8=J
      GO TO 120
   55 J=J1
      J1=J3
      J3=J
      J=J4
      J4=J6
      J6=J
      J=J7
      J7=J9
      J9=J
      GO TO 120
   56 J=J2
      J2=J3
      J3=J
      J=J5
      J5=J6
      J6=J
      J=J8
      J8=J9
      J9=J
  120 KSIGN=(1-MOD(J1+J2+J3+J4+J5+J6+J7+J8+J9,4))
C     SUMMATION OF SERIES OF EQUATION (2)  
  130 SUM=0.0                             
      SIG=(-1)**(KMIN-1)*KSIGN
      FLK=KMIN                           
      DO 200 K=KMIN,KMAX,2              
      TERM=FLK*S6J(J1,J4,J7,J8,J9,K-1)*S6J(J2,J5,J8,J4,K-1,J6)
     1*S6J(J3,J6,J9,K-1,J1,J2)
      FLK=FLK+2.0                      
  200 SUM=SUM+TERM                    
      F9J=SUM*SIG
      RETURN                       
      END                         
      FUNCTION S6J(JD1,JD2,JD3,LD1,LD2,LD3)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     VERSION I  FORTRAN IV
      DIMENSION MA(4),MB(3),MED(12)
      COMMON /FACT/FL(322),NCALL
      DATA NCALL/1/
      J1=JD1
      J2=JD2
      J3=JD3
      L1=LD1
      L2=LD2
      L3=LD3
C     DETERMINE WHETHER TO CALCULATE FL(N) S
      IF(NCALL.EQ.0) GOTO 15
      NCALL=0
C     CALCULATE FL(N) S
      FL(1)=0.0
      FL(2)=0.0
      DO 50 N= 3,322
      FN=N-1
   50 FL(N)=FL(N-1)+LOG(FN)
   15 MED(1)=(-J1+J2+J3)/2
      MED(2)=(+J1-J2+J3)/2
      MED(3)=(+J1+J2-J3)/2
      MED(4)=(-J1+L2+L3)/2
      MED(5)=(+J1-L2+L3)/2
      MED(6)=(+J1+L2-L3)/2
      MED(7)=(-L1+J2+L3)/2
      MED(8)=(+L1-J2+L3)/2
      MED(9)=(+L1+J2-L3)/2
      MED(10)=(-L1+L2+J3)/2
      MED(11)=(+L1-L2+J3)/2
      MED(12)=(+L1+L2-J3)/2
      MA(1)=MED(1)+MED(2)+MED(3)
      MA(2)=MED(4)+MED(5)+MED(6)
      MA(3)=MED(7)+MED(8)+MED(9)
      MA(4)=MED(10)+MED(11)+MED(12)
      MB(1)=MA(1)+MED(12)
      MB(2)=MA(1)+MED(4)
      MB(3)=MA(1)+MED(8)
C     DETERMINE MAXIMUM OF (J1+J2+J3),(J1+L2+L3),(L1+J2+L3),(L1+L2+J3)
      MAX=MA(1)
      DO 30 N=2,4
      IF (MAX-MA(N)) 20,30,30
   20 MAX=MA(N)
   30 CONTINUE
C     DETERMINE MINIMUM OF (J1+J2+L1+L2), (J2+J3+L2+L3),(J3+J1+L3+L1)
      MIN=MB(1)
      DO 51 N=2,3
      IF (MIN-MB(N)) 51,51,40
   40 MIN=MB(N)
   51 CONTINUE
      MINH=MIN
      KMAX=MIN-MAX
      MINP1=MIN+1
      MINI  =MINP1-MA(1)
      MIN2=MINP1-MA(2)
      MIN3=MINP1-MA(3)
      MIN4=MINP1-MA(4)
      MIN5=MINP1+1
      MIN6=MB(1)-MIN
      MIN7=MB(2)-MIN
      MIN8=MB(3)-MIN
      UK=1.E-15
      S=1.0E-15
      IF (KMAX) 65,65,55
   55 DO 60 K=1,KMAX
      UK=-UK*DBLE(MINI-K)*DBLE(MIN2-K)*DBLE(MIN3-K)*DBLE(MIN4-K)/
     1 (DBLE(MIN5-K)*DBLE(MIN6+K)*DBLE(MIN7+K)*DBLE(MIN8+K))
C     CUT OFF SERIES AT 1.0D-25
      IF(ABS(UK)-1.E-25) 65,60,60
   60 S=S+UK
   65 S=S*1.0E+15
C     CALCULATE DELTA FUNCTIONS
      DELOG=0.0
      DO 70 N=1,12
      NUM=MED(N)
   70 DELOG=DELOG+FL(NUM+1)
      NUM1=MA(1)+2
      NUM2=MA(2)+2
      NUM3=MA(3)+2
      NUM4=MA(4)+2
      DELOG=DELOG-FL(NUM1)-FL(NUM2)-FL(NUM3)-FL(NUM4)
      DELOG=0.5*DELOG
      ULOG=FL(MIN5)-FL(MINI)-FL(MIN2)-FL(MIN3)-FL(MIN4)-FL(MIN6+1)-
     1   FL(MIN7+1)-FL(MIN8+1)
      PLOG=DELOG+ULOG
      P=EXP (PLOG)
      S6J=P*S
      IF(MOD(MINH,2).NE.0)  S6J=-S6J
      RETURN
      END

