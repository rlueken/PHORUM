* PHORUM (PJM Hourly Open-source Reduced-form Unit commitment Model)
* Copyright (C) 2013  Roger Lueken
* PHORUMGAMS.gms
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
* You can contact the author at rlueken@gmail.com, or mail to:
* Roger Lueken
* Department of Engineering and Public Policy
* Carnegie Mellon University
* Baker Hall 129
* 5000 Forbes Avenue
* Pittsburgh, PA 15213

* Pull data from gdx files: LoadData.gdx, GenData.gdx, and StorageData.gdx
$GDXIN LoadData.gdx
set t "time";
Parameter loadTCR1(t)        "Hourly load - TCR1";
Parameter loadTCR2(t)        "Hourly load - TCR2";
Parameter loadTCR3(t)        "Hourly load - TCR3";
Parameter loadTCR4(t)        "Hourly load - TCR4";
Parameter loadTCR5(t)        "Hourly load - TCR5";
Parameter TI12max(t)         "Hourly Transmission Limit - TI12";
Parameter TI13max(t)         "Hourly Transmission Limit - TI13";
Parameter TI15max(t)         "Hourly Transmission Limit - TI15";
Parameter TI52max(t)         "Hourly Transmission Limit - TI52";
Parameter TI23max(t)         "Hourly Transmission Limit - TI23";
Parameter TI34max(t)        "Hourly Transmission Limit - TI34";
Parameter LMPTCR1actual(t)         "Actual LMPs - TCR1";
Parameter LMPTCR2actual(t)         "Actual LMPs - TCR2";
Parameter LMPTCR3actual(t)         "Actual LMPs - TCR3";
Parameter LMPTCR4actual(t)         "Actual LMPs - TCR4";
Parameter LMPTCR5actual(t)         "Actual LMPs - TCR5";
Parameter windMaxTCR1(t);
Parameter windMaxTCR2(t);
Parameter windMaxTCR3(t);
Parameter windMaxTCR4(t);
Parameter windMaxTCR5(t);
$LOAD t loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 TI12max TI13max TI15max TI52max TI23max TI34max LMPTCR1actual LMPTCR2actual LMPTCR3actual LMPTCR4actual LMPTCR5actual windMaxTCR1 windMaxTCR2 windMaxTCR3 windMaxTCR4 windMaxTCR5

set tOpt(t) "optimization periods";
alias (t, tp);

* Gather generator data
$GDXIN GenData.gdx
set g "thermal generators";

set gTCR1(g) "TCR1 generators";
set gTCR2(g) "TCR2 generators";
set gTCR3(g) "TCR3 generators";
set gTCR4(g) "TCR4 generators";
set gTCR5(g) "TCR5 generators";

Parameter gInitState(g)  "Generator initial state";
Parameter gInitGen(g)    "Generator initial generation";
Parameter gMinCapacity(g)        "Generator Min Power";
Parameter gCapacity(g)        "Generator Max Power";
Parameter gVC(g)    "Generator marginal cost";
Parameter gNLC(g)        "Generator no-load cost";
Parameter gRampRate(g)       "Generator Ramp Rate";
Parameter gMinUp(g)     "Generator Min Uptime";
Parameter gMinDown(g)   "Generator Min Downtime";
Parameter gOntime(g)     "Generator ontime";
Parameter gDowntime(g)   "Generator downtime";
Parameter gStartupC(g)      "Generator Startup Costs";

$LOAD g gTCR1 gTCR2 gTCR3 gTCR4 gTCR5 gInitState gInitGen gMinCapacity gCapacity gVC gNLC gRampRate gMinUp gMinDown gOntime gDowntime gStartupC

set g1(g) "first generator";
* Storage data
$GDXIN StorageData.gdx
set s "storage units";
set sTCR1(s) "TCR1 SUs";
set sTCR2(s) "TCR2 SUs";
set sTCR3(s) "TCR3 SUs";
set sTCR4(s) "TCR4 SUs";
set sTCR5(s) "TCR5 SUs";
Parameter sSOCmax(s)        "Storage capacity";
Parameter sRampRate(s)        "Storage ramp rate";
Parameter sChargeEff(s)       "Storage charge efficiency";
Parameter sDischargeEff(s)    "Storage discharge efficiency";
Parameter sInitSOC(s)       "Storage initial state";

$LOAD s sTCR1 sTCR2 sTCR3 sTCR4 sTCR5 sSOCmax sRampRate sChargeEff sDischargeEff sInitSOC

* tOpt is a subset of t that excludes the first hour from the optimization
tOpt(t) = yes$(ord(t) gt 1);

Variables
* System variables
        SysCost                System cost
        HourlyCost(t)          Hourly cost
        TI12(t)                Power transfered from TCR1 to TCR2
        TI13(t)                Power transfered from TCR1 to TCR3
        TI15(t)                Power transfered from TCR1 to TCR5
        TI52(t)                Power transfered from TCR5 to TCR2
        TI23(t)                Power transfered from TCR2 to TCR3
        TI34(t)                Power transfered from TCR3 to TCR4
        windTCR1(t)
        windTCR2(t)
        windTCR3(t)
        windTCR4(t)
        windTCR5(t)


* Generator variables
        gLevel(g, t)           Power plant production level
*        gLevelReserves(g, t)   Power plant production level - reserves NEW
        gStartupCost(g, t)     Hourly startup cost for each generator
        U(g, t)                Discrete decision var of Gen g for on (+1) or off (-1) of unit at time t+1

* Storage variables
         sCharge(s, t)         Storage charging rate
         sDischarge(s,t)       Storage discharging rate
         sSOC(s, t)            Storage state of charge

* Set limits on variables
Positive variable gLevel;
Positive variable windTCR1;
Positive variable windTCR2;
Positive variable windTCR3;
Positive variable windTCR4;
Positive variable windTCR5;

*Positive variable gLevelReserves;
Binary variable U;
Positive variable gStartupCost;
Positive variable sSOC;
Positive variable sCharge;
Positive variable sDischarge;
Positive variable vSOC;
Positive variable vCharge;

windTCR1.up(t) = windMaxTCR1(t);
windTCR2.up(t) = windMaxTCR2(t);
windTCR3.up(t) = windMaxTCR3(t);
windTCR4.up(t) = windMaxTCR4(t);
windTCR5.up(t) = windMaxTCR5(t);

sCharge.lo(s,t) = 0;
sCharge.up(s,t) = sRampRate(s);
sDischarge.lo(s,t) = 0;
sDischarge.up(s,t) = sRampRate(s);
sSOC.lo(s,t) = 0.1;
sSOC.up(s,t) = sSOCmax(s);

TI12.lo(t)$(ord(t) gt 1) = -TI12max(t);
TI12.up(t)$(ord(t) gt 1) = TI12max(t);
TI13.lo(t)$(ord(t) gt 1) = -TI13max(t);
TI13.up(t)$(ord(t) gt 1) = TI13max(t);
TI15.lo(t)$(ord(t) gt 1) = -TI15max(t);
TI15.up(t)$(ord(t) gt 1) = TI15max(t);
TI52.lo(t)$(ord(t) gt 1) = -TI52max(t);
TI52.up(t)$(ord(t) gt 1) = TI52max(t);
TI23.lo(t)$(ord(t) gt 1) = -TI23max(t);
TI23.up(t)$(ord(t) gt 1) = TI23max(t);
TI34.lo(t)$(ord(t) gt 1) = -TI34max(t);
TI34.up(t)$(ord(t) gt 1) = TI34max(t);

* Fix values for first hour, which is the last hour of the previous day
sSOC.fx(s, t)$(ord(t) eq 1) = sInitSOC(s);
sSOC.fx(s, t)$(ord(t) eq 49) = sSOCmax(s)/2;
sCharge.fx(s,t)$(ord(t) eq 1) = 0;
sDischarge.fx(s,t)$(ord(t) eq 1) = 0;
if((sum(g, gInitGen(g)) > 0),
         U.fx(g, t)$(ord(t) eq 1) = gInitState(g);
         gLevel.fx(g, t)$(ord(t) eq 1) = gInitGen(g);
);

Equations
         OBJ_FN
         HOURLY_COSTc(t)

* Generator constraints
         MAXGENc(g,t)
         MINGENc(g,t)
         RAMPUPc(g,t)
         RAMPDOWNc(g,t)
         UPTIME1c(g,t)
         UPTIME2c(g,t)
         UPTIME3c(g,t)
         DOWNTIME1c(g,t)
         DOWNTIME2c(g,t)
         DOWNTIME3c(g,t)
         STARTUPCOSTc(g, t)

* Storage constraints
         SOCc(s,t)

* TCR constraints
         SUPPLYTCR1c(t)
         SUPPLYTCR2c(t)
         SUPPLYTCR3c(t)
         SUPPLYTCR4c(t)
         SUPPLYTCR5c(t);
*         tempEqn(t);

* Reserve constraints
*         RESERVETCR1c(t)
*         RESERVETCR234c(t)
*         RESERVETCR5c(t);

OBJ_FN ..            SysCost =e= sum(tOpt, HourlyCost(tOpt));
HOURLY_COSTc(t) ..   HourlyCost(t) =e= sum(g, gLevel(g, t)*(gVC(g)) + gStartupCost(g, t) + gNLC(g)*U(g,t));
STARTUPCOSTc(g,t) .. gStartupCost(g,t) =g= gStartupC(g)*(U(g,t) - U(g,t-1));

* Load constraints for each TCR
SUPPLYTCR1c(t)$(ord(t) gt 1) ..            loadTCR1(t) =e= sum(gTCR1, gLevel(gTCR1, t)) - TI12(t) - TI13(t) - TI15(t) + windTCR1(t) + sum(sTCR1,sDischarge(sTCR1,t)-sCharge(sTCR1,t));
SUPPLYTCR2c(t)$(ord(t) gt 1) ..            loadTCR2(t) =e= sum(gTCR2, gLevel(gTCR2, t)) + TI12(t) + TI52(t) - TI23(t)  + windTCR2(t) + sum(sTCR2,sDischarge(sTCR2,t)-sCharge(sTCR2,t));
SUPPLYTCR3c(t)$(ord(t) gt 1) ..            loadTCR3(t) =e= sum(gTCR3, gLevel(gTCR3, t)) + TI23(t) + TI13(t) - TI34(t)  + windTCR3(t) + sum(sTCR3,sDischarge(sTCR3,t)-sCharge(sTCR3,t));
SUPPLYTCR4c(t)$(ord(t) gt 1) ..            loadTCR4(t) =e= sum(gTCR4, gLevel(gTCR4, t)) + TI34(t)  + windTCR4(t) + sum(sTCR4,sDischarge(sTCR4,t)-sCharge(sTCR4,t));
SUPPLYTCR5c(t)$(ord(t) gt 1) ..            loadTCR5(t) =e= sum(gTCR5, gLevel(gTCR5, t)) + TI15(t)  + windTCR5(t) - TI52(t) + sum(sTCR5,sDischarge(sTCR5,t)-sCharge(sTCR5,t));

*tempEqn(t)$(ord(t) gt 1) .. tempOutput(t) =e= sum((v,a)$(ord(a) eq 1),vCharge(v,t,a)*vNum(v,a)*vCR(v));

* Reserve constraints for each TCR
*RESERVETCR1c(t)$(ord(t) gt 1) ..            1300  =e= sum(gTCR1, gLevelReserves(gTCR1, t));
*RESERVETCR234c(t)$(ord(t) gt 1) ..          1170  =e= sum(gTCR2, gLevelReserves(gTCR2, t)) + sum(gTCR3, gLevelReserves(gTCR3, t)) + sum(gTCR4, gLevelReserves(gTCR4, t));
*RESERVETCR5c(t)$(ord(t) gt 1) ..            1170  =e= sum(gTCR5, gLevelReserves(gTCR5, t));

* Generation levels
MAXGENc(g,t) ..      gLevel(g,t) =l= gCapacity(g)*U(g,t);
MINGENc(g,t) ..      gLevel(g,t) =g= gMinCapacity(g)*U(g,t);
*MAXGENc(g,t) ..      gLevel(g,t) + gLevelReserves(g,t) =l= gCapacity(g)*U(g,t);
*MINGENc(g,t) ..      gLevel(g,t) + gLevelReserves(g,t)  =g= gMinCapacity(g)*U(g,t);

* Ramp rates
RAMPUPc(g,t)$(ord(t) gt 1) ..   gLevel(g,t) =l= gLevel(g, t-1) + gRampRate(g)*U(g,t-1)+gMinCapacity(g)*(U(g,t)-U(g,t-1));
RAMPDOWNc(g,t)$(ord(t) gt 1) .. gLevel(g,t-1) - gLevel(g,t) =l= gRampRate(g)*U(g,t)+gMinCapacity(g)*(U(g,t-1)-U(g,t));

* Min uptime
UPTIME1c(g,t)$(ord(t) gt 1 and ord(t) le gOntime(g)*gInitState(g)).. sum(tp, 1 - U(g,tp)) =e= 0;
UPTIME2c(g,t)$(ord(t) gt gOntime(g)*gInitState(g)+1).. sum(tp,U(g,tp)) =g= gMinUp(g)*(U(g,t) - U(g,t-1));
UPTIME3c(g,t)$(ord(t) ge card(t)-gMinUp(g)+2).. sum(tp, U(g,tp)-(U(g,t)-U(g,t-1))) =g= 0;

* Min downtime
DOWNTIME1c(g,t)$(ord(t) gt 1 and ord(t)le gDowntime(g)*(1-gInitState(g))).. sum(tp, U(g,tp)) =e= 0;
DOWNTIME2c(g,t)$(ord(t) gt gDowntime(g)*(1-gInitState(g))+1).. sum(tp,1-U(g,tp)) =g= gMinDown(g)*(U(g,t-1) - U(g,t));
DOWNTIME3c(g,t)$(ord(t) ge card(t)-gMinDown(g)+2).. sum(tp, 1-U(g,tp)-(U(g,t-1)-U(g,t))) =g= 0;

* Storage state of charge
SOCc(s,t)$(ord(t) gt 1) ..                sSOC(s,t) =e= sSOC(s,t-1)+ sChargeEff(s)*sCharge(s,t) - (1/sDischargeEff(s))*sDischarge(s,t);

Model PHORUM /all/;

* Scale varibles to speed optimization
SUPPLYTCR1c.scale(t) = 1000;
SUPPLYTCR2c.scale(t) = 1000;
SUPPLYTCR3c.scale(t) = 1000;
SUPPLYTCR4c.scale(t) = 1000;
SUPPLYTCR5c.scale(t) = 1000;
SOCc.scale(s, t) = 1000;
OBJ_FN.scale = 10000;

PHORUM.OptFile=1;

Solve PHORUM using MIP minimizing SysCost;
execute_unload "results.gdx" gLevel U HourlyCost gVC TI12 TI15 TI13 TI52 TI23 TI34 sDischarge sCharge sSOC SUPPLYTCR1c.m SUPPLYTCR2c.m SUPPLYTCR3c.m SUPPLYTCR4c.m SUPPLYTCR5c.m loadTCR1 loadTCR2 loadTCR3 loadTCR4 TI12max loadTCR5 TI13max TI15max TI52max TI23max TI34max LMPTCR1actual LMPTCR2actual LMPTCR3actual LMPTCR4actual LMPTCR5actual windTCR1 windTCR2 windTCR3 windTCR4 windTCR5
