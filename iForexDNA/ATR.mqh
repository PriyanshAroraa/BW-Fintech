//+------------------------------------------------------------------+
//|                                                          ATR.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"
#include "..\iForexDNA\MathFunc.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ATR:public BaseIndicator
  {
private:
   int               m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];
   int               m_Shift;
   int               m_Period;
   int               m_MAPeriod;
   ENUM_MA_METHOD    m_MAMethod;
   
   // look back and get the normalized value for ATR
   double            m_ATR[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_MeanATR[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];            
   double            m_StdDevATR[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   

public:
                     ATR();
                    ~ATR();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetATRValue(int TimeFrameIndex,int Shift);
   double            GetATRValueMean(int TimeFrameIndex, int Shift){return m_MeanATR[TimeFrameIndex][Shift];};
   double            GetATRValueStdDev(int TimeFrameIndex, int Shift){return m_StdDevATR[TimeFrameIndex][Shift];};
   double            GetATRValueStdDevPosition(int TimeFrameIndex, int Shift);

   double            CalculateATR(ENUM_TIMEFRAMES timeFrameENUM, int Shift);


private:
   bool              SetShift(int Shift);
   bool              SetPeriod(int ATRPeriod);
   bool              SetMAPeriod(int MAPeriod);
   bool              SetMAMethod(ENUM_MA_METHOD MAMethod);

   void              OnUpdateATRStdDev(int TimeFrameIndex);
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ATR::ATR():BaseIndicator("ATR")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ATR::~ATR()
  {
      ArrayRemove(m_ATR,0);
      ArrayRemove(m_MeanATR,0);
      ArrayRemove(m_StdDevATR,0);
      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ATR::Init(){
   m_Shift=-1;
   m_Period=-1;
   
   if(
      !SetShift(DEFAULT_SHIFT)       // Set ATR shift == 0
      || !SetPeriod(ATR_PERIOD)
      )
      return false;
   
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      m_Handler[i] = iATR(Symbol(),timeFrameENUM,m_Period);
      if(m_Handler[i] == INVALID_HANDLE)
      {
          LogError(__FUNCTION__, "Failed to initialize ATR handlers.");
          return false;
      }
      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      // calculate atr
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
         if(j < DEFAULT_BUFFER_SIZE)
         {
            m_ATR[i][j] = GetATR(m_Handler[i],j+m_Shift);
            tempArray[j] = m_ATR[i][j];
            continue;
         }
         
         tempArray[j] = GetATR(m_Handler[i], j+m_Shift);
      }
         
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_MeanATR[i][x]=MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD);
         m_StdDevATR[i][x]=MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD);
      }
     
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATR::OnUpdate(int TimeFrameIndex,bool IsNewBar)
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
         m_ATR[TimeFrameIndex][j]= m_ATR[TimeFrameIndex][j-1];
         m_MeanATR[TimeFrameIndex][j] = m_MeanATR[TimeFrameIndex][j-1];
         m_StdDevATR[TimeFrameIndex][j] = m_StdDevATR[TimeFrameIndex][j-1];
        }
               
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   // calculate latest ATR value
   m_ATR[TimeFrameIndex][0]=GetATR(m_Handler[TimeFrameIndex],m_Shift);
   
   // update latest min/max/mean/stdDev
   OnUpdateATRStdDev(TimeFrameIndex);
   
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ATR::GetATRValue(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_ATR[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ATR::GetATRValueStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   return m_StdDevATR[TimeFrameIndex][Shift] != 0 ? (m_ATR[TimeFrameIndex][Shift] - m_MeanATR[TimeFrameIndex][Shift])/m_StdDevATR[TimeFrameIndex][Shift] : 0;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ATR::SetShift(int Shift)
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
bool ATR::SetPeriod(int ATRPeriod)
  {
   if(ATRPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=ATRPeriod;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ATR::OnUpdateATRStdDev(int TimeFrameIndex)
{
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_ATR[TimeFrameIndex][i];
      
   m_MeanATR[TimeFrameIndex][0]=MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD);
   m_StdDevATR[TimeFrameIndex][0]=MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ATR::CalculateATR(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   return GetATR(m_Handler[GetTimeFrameIndex(timeFrameENUM)],Shift);
}

//+------------------------------------------------------------------+
