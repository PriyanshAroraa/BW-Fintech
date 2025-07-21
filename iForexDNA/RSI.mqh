//+------------------------------------------------------------------+
//|                                                          RSI.mqh |
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
class RSI:public BaseIndicator
  {
private:
   int               m_Shift;
   int               m_Period;
   ENUM_APPLIED_PRICE m_AppliedPrice;
   double            m_UpperThreshold;
   double            m_LowerThreshold;
   int               m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];
   
   
   // look back and get the normalized value for RSI
   double            m_RSI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_MeanRSI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];            
   double            m_StdDevRSI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   

public:
                     RSI();
                    ~RSI();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetRSIValue(int TimeFrameIndex,int Shift);
   double            GetRSIMean(int TimeFrameIndex, int Shift){return NormalizeDouble(m_MeanRSI[TimeFrameIndex][Shift],2);};
   double            GetRSIStdDev(int TimeFrameIndex, int Shift){return NormalizeDouble(m_StdDevRSI[TimeFrameIndex][Shift],2);};
   double            GetRSIPosition(int TimeFrameIndex, int Shift){return (int)(((GetRSIValue(TimeFrameIndex, Shift) - m_MeanRSI[TimeFrameIndex][Shift])/m_StdDevRSI[TimeFrameIndex][Shift])-0.5);};
   double            GetUpperThreshold();
   double            GetLowerThreshold();
   

   double            CalculateRSI(ENUM_TIMEFRAMES timeFrameENUM, int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE);

private:
   bool              SetShift(int Shift);
   bool              SetPeriod(int RSIPeriod);
   bool              SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);
   bool              SetUpperThreshold(double UpperThreshold);
   bool              SetLowerThreshold(double LowerThreshold);


   void              OnUpdateRSIStdDev(int TimeFrameIndex);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RSI::RSI():BaseIndicator("RSI")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RSI::~RSI()
  {
      ArrayRemove(m_RSI, 0);
      ArrayRemove(m_MeanRSI, 0);
      ArrayRemove(m_StdDevRSI, 0);

  }
//+------------------------------------------------------------------+
bool RSI::Init()
  {
   m_Shift=-1;
   m_Period=-1;
   m_AppliedPrice=-1;
   m_UpperThreshold=-1;
   m_LowerThreshold=-1;

   if(
      !SetShift(DEFAULT_SHIFT)
      || !SetPeriod(RSI_PERIOD)
      || !SetUpperThreshold(RSI_UPPER_THRESHOLD)
      || !SetLowerThreshold(RSI_LOWER_THRESHOLD)
      || !SetAppliedPrice(APPLIED_PRICE))
      return false;

   ArrayInitialize(m_RSI,-1);

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
     {
      ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);
      
      m_Handler[i] = iRSI(Symbol(), timeFrameENUM, m_Period, m_AppliedPrice);

      if(m_Handler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize RSI handlers.");
         return false;
      }

      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
         if(j < DEFAULT_BUFFER_SIZE){
            m_RSI[i][j] = GetRSI(m_Handler[i], m_Shift+j);
            tempArray[j] = m_RSI[i][j];
            continue;
         }
         
         tempArray[j] = GetRSI(m_Handler[i], m_Shift+j);
         
      }
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_MeanRSI[i][x]=NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);     
         m_StdDevRSI[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);     
      }
      
    }

   return true;
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RSI::OnUpdate(int TimeFrameIndex,bool IsNewBar)
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
         m_RSI[TimeFrameIndex][j]= m_RSI[TimeFrameIndex][j-1];
         m_MeanRSI[TimeFrameIndex][j] = m_MeanRSI[TimeFrameIndex][j-1];
         m_StdDevRSI[TimeFrameIndex][j] = m_StdDevRSI[TimeFrameIndex][j-1];
        }
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   // calculate latest RSI value
   m_RSI[TimeFrameIndex][0]=GetRSI(m_Handler[TimeFrameIndex], m_Shift);
   
   // update latest min/max/mean/stdDev
   OnUpdateRSIStdDev(TimeFrameIndex);
   
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double RSI::CalculateRSI(ENUM_TIMEFRAMES timeFrameENUM,int Shift, ENUM_APPLIED_PRICE appliedPrice=PRICE_CLOSE)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   return GetRSI(m_Handler[TimeFrameIndex], Shift);
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSI::GetRSIValue(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_RSI[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSI::GetUpperThreshold()
  {
   if(m_UpperThreshold<0)
      ASSERT("Upper Threshold Value not init.",__FUNCTION__);

   return m_UpperThreshold;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double RSI::GetLowerThreshold(void)
  {
   if(m_LowerThreshold<0)
      ASSERT("Lower Threshold Value not init.",__FUNCTION__);

   return m_LowerThreshold;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RSI::SetShift(int Shift)
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
bool RSI::SetPeriod(int RSIPeriod)
  {
   if(RSIPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=RSIPeriod;
   return true;
  } 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RSI::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
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
bool RSI::SetUpperThreshold(double UpperThreshold)
  {
   if(UpperThreshold<0 || UpperThreshold>100)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_UpperThreshold=-1;
      return false;
     }

   m_UpperThreshold=UpperThreshold;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RSI::SetLowerThreshold(double LowerThreshold)
  {
   if(LowerThreshold<0 || LowerThreshold>100)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_LowerThreshold=-1;
      return false;
     }

   m_LowerThreshold=LowerThreshold;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void RSI::OnUpdateRSIStdDev(int TimeFrameIndex)
{   
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_RSI[TimeFrameIndex][i];
      
   
   m_MeanRSI[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 2);   
   m_StdDevRSI[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 2);   

}

//+------------------------------------------------------------------+
