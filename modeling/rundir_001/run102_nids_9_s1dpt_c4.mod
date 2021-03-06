$PROB one cmpt simple mu modeled bayes multidose nids: 9 scenario: s1dpt
;; based_on: run100
$SUB ADVAN1 TRANS2
$INPUT ID TIME DV OBSNUM CMT EVID AMT RATE ADDL II 
$DATA ../mdata/simple_nocovar_56id_6tp_md.csv 
IGNORE=@ 
IGNORE=(OBSNUM.EQN.2)
IGNORE=(OBSNUM.EQN.4)
IGNORE=(OBSNUM.EQN.5)
IGNORE=(ID.GT.9)
$ABBR REPLACE THETA(CL, V) = THETA(1 to 2)
$ABBR REPLACE ETA(CL, V) = ETA(1 to 2)

$THETAI
THETA(1:NTHETA)=LOG(THETAI(1:NTHETA))
THETAP(1:NTHETAP)=LOG(THETAPI(1:NTHETAP))
$THETAR
THETAR(1:NTHETA)=EXP(THETA(1:NTHETA))
THETAPR(1:NTHETAP)=EXP(THETAP(1:NTHETAP))

$PRIOR NWPRI 

$PK
"USE NMBAYES_INT, ONLY: ITER_REPORT,BAYES_EXTRA_REQUEST,BAYES_EXTRA
; Request extra information for Bayesian analysis.
; An extra call will then be made for accepted samples
"BAYES_EXTRA_REQUEST=1

MU_1 = THETA(CL)
MU_2 = THETA(V)
CL = EXP(MU_1 + ETA(CL))
V = EXP(MU_2 + ETA(V))
S1 = V

"IF(BAYES_EXTRA==1 .AND. ITER_REPORT>=0 .AND. TIME==0.0) THEN
"WRITE(50,98) ITER_REPORT,ID,CL,V
"98 FORMAT(I12,1X,F14.0,4(1X,1PG12.5))
"ENDIF

$ERROR
IPRED=F
Y = IPRED*(1 + ERR(1))  

$THETA
(0.001, 2.5) ; TVCL
(0.001, 46) ; TVV

$OMEGA BLOCK(2)
0.1    ; nCL
0.1  0.1  ; nV

$SIGMA
0.03 ; PROP

; THETA PRIORS
$THETAP (2.5 FIX) (46 FIX) 

; THETA (uniformative) PRIORs
$THETAPV BLOCK(2)
10000 FIX
0.0 10000 

$OMEGAP BLOCK(2)
0.2 FIX
0 0.2

; degrees of freedom to prior omega matrix - low dof = highly uninformative
$OMEGAPD (2 FIX)

$EST METHOD=CHAIN FILE=..\run100.chn NSAMPLE=0 ISAMPLE=4 DF=20
$EST METHOD=BAYES INTER NBURN=4000 NITER=10000 PRINT=20 NOPRIOR=0 CTYPE=3 CITER=10 SEED=56664
