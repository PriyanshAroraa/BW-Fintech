//+------------------------------------------------------------------+
//|                                                     Momentum.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"
#include "..\iForexDNA\MathFunc.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Momentum:public BaseIndicator
  {
private:
   int               m_Shift;
   int               m_Period;
   ENUM_APPLIED_PRICE m_AppliedPrice;
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

   
   double            m_Momentum[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   double            m_MomentumMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];            
   double            m_MomentumStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];

public:
                     Momentum();
                    ~Momentum();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetMomentumValue(int TimeFrameIndex,int Shift);
   double            GetMomentumMean(int TimeFrameIndex, int Shift){return m_MomentumMean[TimeFrameIndex][Shift];};
   double            GetMomentumStdDev(int TimeFrameIndex, int Shift){return m_MomentumStdDev[TimeFrameIndex][Shift];};
   double            GetMomentumPosition(int TimeFrameIndex, int Shift){return ((GetMomentumValue(TimeFrameIndex, Shift) - m_MomentumMean[TimeFrameIndex][Shift])/m_MomentumStdDev[TimeFrameIndex][Shift]);};


   double            CalculateMomentum(ENUM_TIMEFRAMES timeFrameENUM, int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE);

private:
   bool              SetShift(int Shift);
   bool              SetPeriod(int MomentumPeriod);
   bool              SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);

   void              OnUpdateMOMStdDev(int TimeFrameIndex);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Momentum::Momentum():BaseIndicator("Momentum")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Momentum::~Momentum()
  {
      ArrayRemove(m_Momentum, 0);
      ArrayRemove(m_MomentumMean, 0);
      ArrayRemove(m_MomentumStdDev, 0);     
      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


bool Momentum::Init(){
   m_Shift=-1;
   m_Period=-1;
   m_AppliedPrice=-1;
   
   
   if(!SetShift(DEFAULT_SHIFT)
      || !SetPeriod(MOMENTUM_PERIOD)
      || !SetAppliedPrice(APPLIED_PRICE))
      return false;
      
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_Handlers[i] = iMomentum(Symbol(), timeFrameENUM, m_Period, m_AppliedPrice);

      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize Momentum handlers.");
         return false;
      }
      
      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
            
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
         if(j < DEFAULT_BUFFER_SIZE){
            m_Momentum[i][j] = GetMomentum(m_Handlers[i],j+m_Shift);
            tempArray[j] = m_Momentum[i][j];
            continue;
         }
         
         tempArray[j] = GetMomentum(m_Handlers[i],j+m_Shift);
      }      
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_MomentumMean[i][x]=MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD);     
         m_MomentumStdDev[i][x]=MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD);   
      }
   
   }
   
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Momentum::OnUpdate(int TimeFrameIndex,bool IsNewBar)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }

   if(IsNewBar)
     {
      for(int j=DEFAULT_BUFFER_SIZE-1; j>0; j--)
        {
         m_Momentum[TimeFrameIndex][j]=m_Momentum[TimeFrameIndex][j-1];
         m_MomentumMean[TimeFrameIndex][j]=m_MomentumMean[TimeFrameIndex][j-1];
         m_MomentumStdDev[TimeFrameIndex][j]=m_MomentumStdDev[TimeFrameIndex][j-1];
        }
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_Momentum[TimeFrameIndex][0]=GetMomentum(m_Handlers[TimeFrameIndex],m_Shift);
   OnUpdateMOMStdDev(TimeFrameIndex);
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Momentum::GetMomentumValue(int TimeFrameIndex,int Shift)
  {
    if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_Momentum[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Momentum::CalculateMomentum(ENUM_TIMEFRAMES timeFrameENUM,int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetMomentum(m_Handlers[TimeFrameIndex],Shift);
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Momentum::SetShift(int Shift)
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
bool Momentum::SetPeriod(int MomentumPeriod)
  {
   if(MomentumPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=MomentumPeriod;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Momentum::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
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
//|                                                                  |
//+------------------------------------------------------------------+

void Momentum::OnUpdateMOMStdDev(int TimeFrameIndex)
{   
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_Momentum[TimeFrameIndex][i];
      
   
   m_MomentumMean[TimeFrameIndex][0]=MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD);     
   m_MomentumStdDev[TimeFrameIndex][0]=MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD);   

}
    
//+------------------------------------------------------------------+
