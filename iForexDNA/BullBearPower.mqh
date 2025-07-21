//+------------------------------------------------------------------+
//|                                                BullBearPower.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"
#include "..\iForexDNA\MathFunc.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class BullBearPower:public BaseIndicator{
    private:
        int                     m_Shift;
        int                     m_Period;
        ENUM_APPLIED_PRICE      m_AppliedPrice;
        int                     m_BullHandlers[ENUM_TIMEFRAMES_ARRAY_SIZE];
        int                     m_BearHandlers[ENUM_TIMEFRAMES_ARRAY_SIZE];



        double                  m_BullPower[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_BearPower[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];


        double                  m_BullMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_BearMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];

        double                  m_BullStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_BearStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];


    public:
                                BullBearPower();
                                ~BullBearPower();


        bool                    Init();
        void                    OnUpdate(int TimeFrameIndex, bool IsNewBar);



        double                  GetBullPowerValue(int TimeFrameIndex, int Shift);
        double                  GetBearPowerValue(int TimeFrameIndex, int Shift);


        double                  GetBullMean(int TimeFrameIndex, int Shift);
        double                  GetBullStdDev(int TimeFrameIndex, int Shift);

        double                  GetBearMean(int TimeFrameIndex, int Shift);
        double                  GetBearStdDev(int TimeFrameIndex, int Shift);


        double                  CalculateBullPower(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
        double                  CalculateBearPower(ENUM_TIMEFRAMES timeFrameENUM, int Shift);


    private:
        bool                    SetShift(int Shift);
        bool                    SetPeriod(int BullBearPeriod);
        bool                    SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);

        void                    OnUpdateBullBearStdDev(int TimeFrameIndex);

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

BullBearPower::BullBearPower():BaseIndicator("BullBearPower"){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

BullBearPower::~BullBearPower(){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool BullBearPower::Init(){
    m_Shift = -1;
    m_Period = -1;
    m_AppliedPrice = -1;


    if(!SetShift(DEFAULT_SHIFT)
    || !SetPeriod(BULL_BEAR_POWER_PERIOD)
    || !SetAppliedPrice(APPLIED_PRICE))
        return false;
    


   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE;i++){      
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_BullHandlers[i] = iBullsPower(Symbol(), timeFrameENUM, m_Period);
      m_BearHandlers[i] = iBearsPower(Symbol(), timeFrameENUM, m_Period);

      if(m_BullHandlers[i] == INVALID_HANDLE || m_BearHandlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize ADX handlers.");
         return false;
      }
      
      double bullTempArray[DEFAULT_BUFFER_SIZE*2];
      double bearTempArray[DEFAULT_BUFFER_SIZE*2];     
      int arrsize=ArraySize(bullTempArray); 
      
      // calculate MACD
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
        if(j < DEFAULT_BUFFER_SIZE){
            m_BullPower[i][j] = GetBullPower(m_BullHandlers[i], j+m_Shift);
            m_BearPower[i][j] = GetBearPower(m_BearHandlers[i], j+m_Shift);

            // save into temp Hist Array
            bullTempArray[j] = m_BullPower[i][j];
            bearTempArray[j] = m_BearPower[i][j];
            continue;
        }

        bullTempArray[j] = GetBullPower(m_BullHandlers[i], j+m_Shift);
        bearTempArray[j] = GetBearPower(m_BearHandlers[i], j+m_Shift);

      }
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_BullMean[i][x]=MathMean(bullTempArray, x, DEFAULT_INDICATOR_PERIOD);
         m_BearMean[i][x]=MathMean(bearTempArray, x, DEFAULT_INDICATOR_PERIOD); 
 
         m_BullStdDev[i][x]=MathStandardDeviation(bullTempArray, x, DEFAULT_INDICATOR_PERIOD);
         m_BearStdDev[i][x]=MathStandardDeviation(bearTempArray, x, DEFAULT_INDICATOR_PERIOD);
      }
      
   }
      
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void BullBearPower::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }

   if(IsNewBar){
      for(int j=DEFAULT_BUFFER_SIZE-1; j>0; j--){
         m_BullPower[TimeFrameIndex][j]=m_BullPower[TimeFrameIndex][j-1];
         m_BullMean[TimeFrameIndex][j]=m_BullMean[TimeFrameIndex][j-1];
         m_BullStdDev[TimeFrameIndex][j]=m_BullStdDev[TimeFrameIndex][j-1];

         m_BearPower[TimeFrameIndex][j]=m_BearPower[TimeFrameIndex][j-1];
         m_BearMean[TimeFrameIndex][j]=m_BearMean[TimeFrameIndex][j-1];
         m_BearStdDev[TimeFrameIndex][j]=m_BearStdDev[TimeFrameIndex][j-1];
      }
   }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_BullPower[TimeFrameIndex][0]=GetBullPower(m_BullHandlers[TimeFrameIndex], m_Shift);
   m_BearPower[TimeFrameIndex][0]=GetBearPower(m_BearHandlers[TimeFrameIndex], m_Shift);

   OnUpdateBullBearStdDev(TimeFrameIndex);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::GetBullPowerValue(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_BullPower[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::GetBearPowerValue(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_BearPower[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::GetBullMean(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_BullMean[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::GetBearMean(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_BearMean[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::GetBullStdDev(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_BullStdDev[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::GetBearStdDev(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_BearStdDev[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void BullBearPower::OnUpdateBullBearStdDev(int TimeFrameIndex)
{
  double tempBullArray[DEFAULT_INDICATOR_PERIOD];
   double tempBearArray[DEFAULT_INDICATOR_PERIOD];

   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
   {
      tempBullArray[i]=m_BullPower[TimeFrameIndex][i];
      tempBearArray[i]=m_BearPower[TimeFrameIndex][i];
   }

   m_BullMean[TimeFrameIndex][0]=MathMean(tempBullArray, 0, DEFAULT_INDICATOR_PERIOD);
   m_BearMean[TimeFrameIndex][0]=MathMean(tempBearArray, 0, DEFAULT_INDICATOR_PERIOD); 
 
   m_BullStdDev[TimeFrameIndex][0]=MathStandardDeviation(tempBullArray, 0, DEFAULT_INDICATOR_PERIOD);
   m_BearStdDev[TimeFrameIndex][0]=MathStandardDeviation(tempBearArray, 0, DEFAULT_INDICATOR_PERIOD);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::CalculateBullPower(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetBullPower(m_BullHandlers[TimeFrameIndex], Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double BullBearPower::CalculateBearPower(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetBearPower(m_BearHandlers[TimeFrameIndex], Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool BullBearPower::SetShift(int Shift)
  {
   if(Shift<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Shift=-1;
      return false;
     }

   m_Shift=Shift;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool BullBearPower::SetPeriod(int BullBearPeriod)
  {
   if(BullBearPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=BullBearPeriod;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool BullBearPower::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
  {
   if(AppliedPrice<0 || AppliedPrice>6)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_AppliedPrice=-1;
      return false;
     }

   m_AppliedPrice=AppliedPrice;
   return true;
  }

//+------------------------------------------------------------------+