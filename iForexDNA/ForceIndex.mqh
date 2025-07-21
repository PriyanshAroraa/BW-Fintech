//+------------------------------------------------------------------+
//|                                                   ForceIndex.mqh |
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

class ForceIndex:public BaseIndicator{
    private:
        int                     m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];
        int                     m_Shift;
        int                     m_Period;
        ENUM_MA_METHOD          m_MAMethod;
        ENUM_APPLIED_PRICE      m_AppliedPrice;



        double                  m_ForceIndex[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_ForceMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
        double                  m_ForceStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];

      
        double                  m_LatestSumOfFI[ENUM_TIMEFRAMES_ARRAY_SIZE];
        double                  m_LatestSumOfSqrtFI[ENUM_TIMEFRAMES_ARRAY_SIZE];
   
    public:
                                ForceIndex();
                                ~ForceIndex();


        bool                    Init();
        void                    OnUpdate(int TimeFrameIndex, bool IsNewBar);



        double                  GetForceIndexValue(int TimeFrameIndex, int Shift);
        double                  GetForceMean(int TimeFrameIndex, int Shift);
        double                  GetForceStdDev(int TimeFrameIndex, int Shift);


        double                  CalculateForceIndex(ENUM_TIMEFRAMES timeFrameENUM, int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE);


    private:
        bool                    SetShift(int Shift);
        bool                    SetPeriod(int ForcePeriod);
        bool                    SetMAMethod(ENUM_MA_METHOD MAMethod);
        bool                    SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);

        void                    OnUpdateForceStdDev(int TimeFrameIndex);


};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ForceIndex::ForceIndex():BaseIndicator("ForceIndex"){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ForceIndex::~ForceIndex(){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ForceIndex::Init(){
    m_Shift = -1;
    m_Period = -1;
    m_MAMethod = -1;
    m_AppliedPrice = -1;


    if(!SetShift(DEFAULT_SHIFT)
    || !SetPeriod(FORCE_PERIOD)
    || !SetMAMethod(APPLIED_PRICE_METHOD)
    || !SetAppliedPrice(APPLIED_PRICE))
        return false;
    


   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE;i++){      
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
         
      // Initializing handlers
      m_Handler[i] = iForce(Symbol(),timeFrameENUM, m_Period, m_MAMethod, VOLUME_TICK);
      
      if(m_Handler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize ForceIndex handlers.");
         return false;
      }
      
      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      // calculate MACD
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
        if(j < DEFAULT_BUFFER_SIZE){
            m_ForceIndex[i][j] = GetForceIndex(m_Handler[i], j+m_Shift);

            // save into temp Hist Array
            tempArray[j] = m_ForceIndex[i][j];            
            continue;
        }
         
        tempArray[j] = GetForceIndex(m_Handler[i], j+m_Shift);

      }
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_ForceMean[i][x]=MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD);     
         m_ForceStdDev[i][x]=MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD);  
      }
      
   }
      
   return true;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ForceIndex::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }

   if(IsNewBar){
      for(int j=DEFAULT_BUFFER_SIZE-1; j>0; j--){
         m_ForceIndex[TimeFrameIndex][j]=m_ForceIndex[TimeFrameIndex][j-1];
         m_ForceMean[TimeFrameIndex][j]=m_ForceMean[TimeFrameIndex][j-1];
         m_ForceStdDev[TimeFrameIndex][j]=m_ForceStdDev[TimeFrameIndex][j-1];
      }
   }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_ForceIndex[TimeFrameIndex][0]=GetForceIndex(m_Handler[TimeFrameIndex], m_Shift);

   OnUpdateForceStdDev(TimeFrameIndex);
   
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ForceIndex::GetForceIndexValue(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_ForceIndex[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ForceIndex::GetForceMean(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_ForceMean[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ForceIndex::GetForceStdDev(int TimeFrameIndex, int Shift){
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

    return m_ForceStdDev[TimeFrameIndex][Shift];

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ForceIndex::OnUpdateForceStdDev(int TimeFrameIndex)
{
 double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_ForceIndex[TimeFrameIndex][i];
      
   
   m_ForceMean[TimeFrameIndex][0]=MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD);     
   m_ForceStdDev[TimeFrameIndex][0]=MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD);   

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ForceIndex::CalculateForceIndex(ENUM_TIMEFRAMES timeFrameENUM,int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE)
{
   return GetForceIndex(m_Handler[GetTimeFrameIndex(timeFrameENUM)] ,Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ForceIndex::SetShift(int Shift)
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

bool ForceIndex::SetPeriod(int ForcePeriod)
  {
   if(ForcePeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=ForcePeriod;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ForceIndex::SetMAMethod(ENUM_MA_METHOD MAMethod){
   if(MAMethod<0 || MAMethod>3)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_MAMethod=-1;
      return false;
     }


   m_MAMethod=MAMethod;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ForceIndex::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
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