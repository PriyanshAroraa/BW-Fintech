//+------------------------------------------------------------------+
//|                                                         MACD.mqh |
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
class MACD:public BaseIndicator
  {
private:
   int               m_Shift;
   int               m_FastPeriod;
   int               m_SlowPeriod;
   int               m_SignalPeriod;
   ENUM_APPLIED_PRICE m_AppliedPrice;
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

   double            m_Main[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_Signal[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_Histogram[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];   


   double            m_HistogramMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_HistogramStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];   
   
   
public:
                     MACD();
                    ~MACD();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetMain(int TimeFrameIndex,int Shift);
   double            GetSignal(int TimeFrameIndex,int Shift);
   double            GetHistogram(int TimeFrameIndex,int Shift);
   double            GetHistogramMean(int TimeFrameIndex, int Shift);
   double            GetHistStdDev(int TimeFrameIndex, int Shift);
   double            GetHistStdDevPosition(int TimeFrameIndex, int Shift){return NormalizeDouble((m_Histogram[TimeFrameIndex][Shift]-GetHistogramMean(TimeFrameIndex, Shift))/ GetHistStdDev(TimeFrameIndex, Shift), 2);};


   double            CalculateMACDHist(ENUM_TIMEFRAMES timeFrameENUM, int Shift);

private:
   bool              SetShift(int Shift);
   bool              SetFastPeriod(int FastPeriod);
   bool              SetSlowPeriod(int SlowPeriod);
   bool              SetSignalPeriod(int SignalPeriod);
   bool              SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);
   
   void              OnUpdateMACDStdDev(int TimeFrameIndex);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MACD::MACD():BaseIndicator("MACD")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MACD::~MACD()
  {
      ArrayRemove(m_Main, 0);
      ArrayRemove(m_Signal, 0);
      ArrayRemove(m_Histogram, 0);
      ArrayRemove(m_HistogramMean, 0);
      ArrayRemove(m_HistogramStdDev, 0);
      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MACD::Init(){
   m_Shift=-1;
   m_FastPeriod=-1;
   m_SlowPeriod=-1;
   m_SignalPeriod=-1;
   m_AppliedPrice=-1;

   if(!SetShift(DEFAULT_SHIFT)
      || !SetFastPeriod(MACD_FAST_PERIOD)
      || !SetSlowPeriod(MACD_SLOW_PERIOD)
      || !SetSignalPeriod(MACD_SIGNAL_PERIOD)
      || !SetAppliedPrice(APPLIED_PRICE))
      return false;
      
   
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE;i++){      
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_Handlers[i] = iMACD(Symbol(), timeFrameENUM, m_FastPeriod, m_SlowPeriod, m_SignalPeriod, m_AppliedPrice);
      
      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize MACD handlers.");
         return false;
      }
      
      double HistArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(HistArray);
      
      
      // calculate MACD
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
         if(j < DEFAULT_BUFFER_SIZE){
            m_Main[i][j] = GetMACD(m_Handlers[i],MODE_MAIN,j+m_Shift);
            m_Signal[i][j]=GetMACD(m_Handlers[i],MODE_SIGNAL,j+m_Shift);
            m_Histogram[i][j]= m_Main[i][j] - m_Signal[i][j];
            
            // save into temp Hist Array
            HistArray[j] = m_Histogram[i][j];
            continue;
         }
         
         HistArray[j] = GetMACD(m_Handlers[i],MODE_MAIN,j+m_Shift) - 
         GetMACD(m_Handlers[i],MODE_SIGNAL,j+m_Shift);
      
      }
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_HistogramMean[i][x]=MathMean(HistArray, x, DEFAULT_INDICATOR_PERIOD);     
         m_HistogramStdDev[i][x]=MathStandardDeviation(HistArray, x, DEFAULT_INDICATOR_PERIOD);       
      }
      
   }
   
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MACD::OnUpdate(int TimeFrameIndex,bool IsNewBar)
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
         m_Main[TimeFrameIndex][j]=m_Main[TimeFrameIndex][j-1];
         m_Signal[TimeFrameIndex][j]=m_Signal[TimeFrameIndex][j-1];
         m_Histogram[TimeFrameIndex][j]=m_Histogram[TimeFrameIndex][j-1];
         m_HistogramMean[TimeFrameIndex][j]=m_HistogramMean[TimeFrameIndex][j-1];
         m_HistogramStdDev[TimeFrameIndex][j]=m_HistogramStdDev[TimeFrameIndex][j-1];
        }
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_Main[TimeFrameIndex][0]=GetMACD(m_Handlers[TimeFrameIndex],MODE_MAIN,m_Shift);
   m_Signal[TimeFrameIndex][0]=GetMACD(m_Handlers[TimeFrameIndex],MODE_SIGNAL,m_Shift);
   m_Histogram[TimeFrameIndex][0]= m_Main[TimeFrameIndex][0] - m_Signal[TimeFrameIndex][0];
   
   OnUpdateMACDStdDev(TimeFrameIndex);
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MACD::GetMain(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_Main[TimeFrameIndex][Shift];
  
   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MACD::GetSignal(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   double res=m_Signal[TimeFrameIndex][Shift];
   
   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MACD::GetHistogram(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   return m_Histogram[TimeFrameIndex][Shift];
  }  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MACD::GetHistogramMean(int TimeFrameIndex, int Shift)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   return m_HistogramMean[TimeFrameIndex][Shift];
  }  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MACD::GetHistStdDev(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0 || Shift>=DEFAULT_BUFFER_SIZE){
      ASSERT("Invalid Function Input...", __FUNCTION__);
      return -1;
   }
   
   return m_HistogramStdDev[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MACD::CalculateMACDHist(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return (GetMACD(m_Handlers[TimeFrameIndex],MODE_MAIN,Shift) - 
         GetMACD(m_Handlers[TimeFrameIndex],MODE_SIGNAL,Shift)
         );
}

//+------------------------------------------------------------------+, 
//|                                                                  |
//+------------------------------------------------------------------+
bool MACD::SetShift(int Shift)
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
bool MACD::SetFastPeriod(int FastPeriod)
  {
   if(FastPeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_FastPeriod=-1;
      return false;
     }

   m_FastPeriod=FastPeriod;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MACD::SetSlowPeriod(int SlowPeriod)
  {
   if(SlowPeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_SlowPeriod=-1;
      return false;
     }

   m_SlowPeriod=SlowPeriod;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MACD::SetSignalPeriod(int SignalPeriod)
  {
   if(SignalPeriod<0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_SignalPeriod=-1;
      return false;
     }

   m_SignalPeriod=SignalPeriod;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MACD::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
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

void MACD::OnUpdateMACDStdDev(int TimeFrameIndex)
{   
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_Histogram[TimeFrameIndex][i];
      
   
   m_HistogramMean[TimeFrameIndex][0]=MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD);     
   m_HistogramStdDev[TimeFrameIndex][0]=MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD);   

}


//+------------------------------------------------------------------+
