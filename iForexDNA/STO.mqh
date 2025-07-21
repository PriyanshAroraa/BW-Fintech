//+------------------------------------------------------------------+
//|                                                          STO.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
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
class STO:public BaseIndicator
  {
private:
   int               m_Shift;
   int               m_KPeriod;
   int               m_DPeriod;
   int               m_Slowing;
   ENUM_MA_METHOD    m_MAMethod;
   ENUM_STO_PRICE    m_PriceField;
   double            m_UpperThreshold;
   double            m_LowerThreshold;
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

   double            m_Main[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_Signal[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_STOMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_STOStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   double            m_Hist[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_HistMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_HistStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   double            m_LatestSumOfSTOSignal[ENUM_TIMEFRAMES_ARRAY_SIZE];
   double            m_LatestSumOfSqrtSTOSignal[ENUM_TIMEFRAMES_ARRAY_SIZE];
        
   double            m_LatestSumOfSTOHist[ENUM_TIMEFRAMES_ARRAY_SIZE];
   double            m_LatestSumOfSqrtSTOHist[ENUM_TIMEFRAMES_ARRAY_SIZE];
   
   
public:
                     STO();
                    ~STO();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetMain(int TimeFrameIndex,int Shift);
   double            GetSignal(int TimeFrameIndex,int Shift);
   double            GetSTOMean(int TimeFrameIndex, int Shift){return m_STOMean[TimeFrameIndex][Shift];};
   double            GetSTOStdDev(int TimeFrameIndex, int Shift){return m_STOStdDev[TimeFrameIndex][Shift];};
   
   
   double            GetSTOHist(int TimeFrameIndex, int Shift){return m_Hist[TimeFrameIndex][Shift];};
   double            GetSTOHistMean(int TimeFrameIndex, int Shift){return m_HistMean[TimeFrameIndex][Shift];};
   double            GetSTOHistStdDev(int TimeFrameIndex, int Shift){return m_HistStdDev[TimeFrameIndex][Shift];};
   
   double            CalculateMain(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   double            CalculateSignal(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   double            CalculateSTOHist(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   
   double            GetUpperThreshold();
   double            GetLowerThreshold();
private:

   bool              SetShift(int Shift);
   bool              SetKPeriod(int KPeriod);
   bool              SetDPeriod(int DPeriod);
   bool              SetSlowing(int Slowing);
   bool              SetMAMethod(ENUM_MA_METHOD MAMethod);
   bool              SetPriceField(ENUM_STO_PRICE PriceField);
   bool              SetUpperThreshold(double Threshold);
   bool              SetLowerThreshold(double Threshold);
   
   
   void              OnUpdateSTOStdDev(int TimeFrameIndex);
  };
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

STO::STO():BaseIndicator("STO")
  {
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
STO::~STO()
  {

  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::Init()
  {
   m_Shift=-1;
   m_KPeriod=-1;
   m_DPeriod=-1;
   m_Slowing=-1;
   m_MAMethod=-1;
   m_PriceField=-1;
   m_UpperThreshold=-1;
   m_LowerThreshold=-1;
   
   if(!SetShift(DEFAULT_SHIFT)
      || !SetKPeriod(STO_KPERIOD)
      || !SetDPeriod(STO_DPERIOD)
      || !SetSlowing(STO_SLOWING)
      || !SetMAMethod(APPLIED_MA_METHOD)
      || !SetPriceField(STO_PRICE_FIELD)
      || !SetUpperThreshold(STO_UPPER_THRESHOLD)
      || !SetLowerThreshold(STO_LOWER_THRESHOLD))
      return false;

   ArrayInitialize(m_Main,-1);
   ArrayInitialize(m_Signal,-1);

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
     {
      ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);
      m_Handlers[i] = iStochastic(Symbol(), timeFrameENUM, m_KPeriod, m_DPeriod, m_Slowing, m_MAMethod, m_PriceField);

      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize STO handlers.");
         return false;
      }

      double tempArray[DEFAULT_BUFFER_SIZE*2];
      double tempSignalArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      string symbol = Symbol();
      
      for(int j=0; j<DEFAULT_BUFFER_SIZE*2; j++)
        {
         if(j < DEFAULT_BUFFER_SIZE){
            m_Main[i][j]=GetSTO(m_Handlers[i], MODE_MAIN, m_Shift+j);
            m_Signal[i][j]=GetSTO(m_Handlers[i], MODE_SIGNAL, m_Shift+j);
            m_Hist[i][j]=m_Main[i][j] - m_Signal[i][j];
            tempArray[j] = m_Hist[i][j];
            tempSignalArray[j] = m_Signal[i][j];
            continue;
         }
         
         double tempMain = GetSTO(m_Handlers[i], MODE_MAIN, m_Shift+j);
         double tempSignal =GetSTO(m_Handlers[i], MODE_SIGNAL, m_Shift+j);
         tempArray[j]=tempMain-tempSignal;
         tempSignalArray[j] = tempSignal;

        }
        
        
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_STOMean[i][x]=NormalizeDouble(MathMean(tempSignalArray, x, DEFAULT_INDICATOR_PERIOD),2);
         m_HistMean[i][x]=NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD),2); 
 
         m_STOStdDev[i][x]=NormalizeDouble(MathStandardDeviation(tempSignalArray, x, DEFAULT_INDICATOR_PERIOD),2);
         m_HistStdDev[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD),2);
      }
      
     }

   return true;
   
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void  STO::OnUpdate(int TimeFrameIndex,bool IsNewBar)
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
         m_STOMean[TimeFrameIndex][j]=m_STOMean[TimeFrameIndex][j-1];
         m_STOStdDev[TimeFrameIndex][j]=m_STOStdDev[TimeFrameIndex][j-1];
         
         m_Hist[TimeFrameIndex][j]=m_Hist[TimeFrameIndex][j-1];
         m_HistMean[TimeFrameIndex][j]=m_HistMean[TimeFrameIndex][j-1];
         m_HistStdDev[TimeFrameIndex][j]=m_HistStdDev[TimeFrameIndex][j-1];
        }
     }

   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);

   m_Main[TimeFrameIndex][0]=GetSTO(m_Handlers[TimeFrameIndex], MODE_MAIN, m_Shift);
   m_Signal[TimeFrameIndex][0]=GetSTO(m_Handlers[TimeFrameIndex], MODE_SIGNAL, m_Shift);
   m_Hist[TimeFrameIndex][0] = m_Main[TimeFrameIndex][0]-m_Signal[TimeFrameIndex][0];

   OnUpdateSTOStdDev(TimeFrameIndex);
  
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::SetKPeriod(int KPeriod)
  {
   if(KPeriod<=0)
     {
      LogError(__FUNCTION__,"STO KPeriod extern value is not valid.");
      return false;
     }

   m_KPeriod=KPeriod;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double STO::GetMain(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   double res=m_Main[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);
   
   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double STO::GetSignal(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   double res=m_Signal[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);
   
   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double STO::GetUpperThreshold()
  {
   if(m_UpperThreshold<0)
      ASSERT("Upper threshold Value not init.",__FUNCTION__);
   return m_UpperThreshold;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double STO::GetLowerThreshold()
  {
   if(m_LowerThreshold<0)
      ASSERT("Lower threshold Value not init.",__FUNCTION__);
   return m_LowerThreshold;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::SetShift(int Shift)
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

bool STO::SetDPeriod(int DPeriod)
  {
   if(DPeriod<=0)
     {
      LogError(__FUNCTION__,"STO DPeriod extern value is not valid.");
      return false;
     }

   m_DPeriod=DPeriod;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::SetSlowing(int Slowing)
  {
   if(Slowing<=0)
     {
      LogError(__FUNCTION__,"STO Slowing extern value is not valid.");
      return false;
     }

   m_Slowing=Slowing;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::SetMAMethod(ENUM_MA_METHOD MAMethod)
  {
   if(MAMethod<0 || MAMethod>3)
     {
      LogError(__FUNCTION__,"STO MAMethod extern value is not valid.");
      return false;
     }

   m_MAMethod=MAMethod;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::SetPriceField(ENUM_STO_PRICE PriceField)
  {
   if(PriceField!=STO_CLOSECLOSE && PriceField!=STO_LOWHIGH)
     {
      LogError(__FUNCTION__,"STO PriceField extern value is not valid.");
      return false;
     }

   m_PriceField=PriceField;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::SetUpperThreshold(double Threshold)
  {
   if(Threshold<0 || Threshold>=100)
     {
      LogError(__FUNCTION__,"STO upper Threshold extern value is not valid.");
      return false;
     }

   m_UpperThreshold=Threshold;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool STO::SetLowerThreshold(double Threshold)
  {
   if(Threshold<0 || Threshold>=100)
     {
      LogError(__FUNCTION__,"STO lower Threshold extern value is not valid.");
      return false;
     }

   m_LowerThreshold=Threshold;
   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void STO::OnUpdateSTOStdDev(int TimeFrameIndex)
{
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   double tempHistArray[DEFAULT_INDICATOR_PERIOD];

   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
   {
      tempArray[i]=m_Signal[TimeFrameIndex][i];
      tempHistArray[i]=m_Hist[TimeFrameIndex][i];
   }

   m_STOMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD),2);
   m_HistMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempHistArray, 0, DEFAULT_INDICATOR_PERIOD),2);
 
   m_STOStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD),2);
   m_HistStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempHistArray, 0, DEFAULT_INDICATOR_PERIOD),2);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double STO::CalculateSTOHist(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return (GetSTO(m_Handlers[TimeFrameIndex], MODE_MAIN, Shift) - 
   GetSTO(m_Handlers[TimeFrameIndex], MODE_SIGNAL, Shift)
   );
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double STO::CalculateMain(ENUM_TIMEFRAMES timeFrameENUM, int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetSTO(m_Handlers[TimeFrameIndex], MODE_MAIN, Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double STO::CalculateSignal(ENUM_TIMEFRAMES timeFrameENUM, int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetSTO(m_Handlers[TimeFrameIndex], MODE_SIGNAL, Shift);
}

//+------------------------------------------------------------------+