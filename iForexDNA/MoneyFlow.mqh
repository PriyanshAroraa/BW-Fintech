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

class MoneyFlow:public BaseIndicator{
   private:
      int            m_Shift;
      int            m_Period;
      int            m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];
        
        
      double         m_MFI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];   
      double         m_MeanMFI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      double         m_StdDevMFI[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      
   
   public:
                     MoneyFlow();
                     ~MoneyFlow();
                     
      bool           Init();
      void           OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double         GetMFIValue(int TimeFrameIndex, int Shift);
      double         GetMeanMFI(int TimeFrameIndex, int Shift);
      double         GetStdDevMFI(int TimeFrameIndex, int Shift);
      double         GetMFIStdDevPosition(int TimeFrameIndex, int Shift){return (int)(GetMFIValue(TimeFrameIndex, Shift) - m_MeanMFI[TimeFrameIndex][Shift])/m_StdDevMFI[TimeFrameIndex][Shift];};
      
      double         CalculateMFI(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
      
  private:
      bool           SetShift(int Shift);
      bool           SetPeriod(int MFPeriod);
      void           OnUpdateMFIStdDev(int TimeFrameIndex);               
         
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MoneyFlow::MoneyFlow():BaseIndicator("MoneyFlow")
{   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MoneyFlow::~MoneyFlow(){
   ArrayRemove(m_MFI, 0);
   ArrayRemove(m_MeanMFI, 0);
   ArrayRemove(m_StdDevMFI, 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MoneyFlow::Init(){
   m_Shift = -1;
   m_Period = -1;
   
   
   if(!SetPeriod(MFI_PERIOD) 
   || !SetShift(DEFAULT_SHIFT)
   )
      return false;
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_Handlers[i] = iMFI(Symbol(), timeFrameENUM, m_Period, VOLUME_TICK);
      
      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize MFI handlers.");
         return false;
      }

      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
         if(j < DEFAULT_BUFFER_SIZE){
            m_MFI[i][j] = GetMFI(m_Handlers[i], m_Shift+j);
            tempArray[j] = m_MFI[i][j];
            continue;
         }
         
         tempArray[j] = GetMFI(m_Handlers[i], m_Shift+j);
      
         
      }   
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_MeanMFI[i][x]=NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);     
         m_StdDevMFI[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD), 2);   
      }      
      
      
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MoneyFlow::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid TimeFrame Index...", __FUNCTION__);
      return;
   }
   
   if(IsNewBar){
      for(int i = DEFAULT_BUFFER_SIZE-1; i>0; i--){
         m_MFI[TimeFrameIndex][i] = m_MFI[TimeFrameIndex][i-1];
         m_MeanMFI[TimeFrameIndex][i] = m_MeanMFI[TimeFrameIndex][i-1];
         m_StdDevMFI[TimeFrameIndex][i] = m_StdDevMFI[TimeFrameIndex][i-1];
      }
   }
   
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   
   m_MFI[TimeFrameIndex][0] = GetMFI(m_Handlers[TimeFrameIndex], m_Shift);
   OnUpdateMFIStdDev(TimeFrameIndex);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MoneyFlow::GetMFIValue(int TimeFrameIndex,int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("Array out of range / TimeFrame Index out of range", __FUNCTION__);
      return -1;
   }
   
   if(m_MFI[TimeFrameIndex][Shift] < 0){
      ASSERT("Buffer value not init.", __FUNCTION__);
      return -1;
   }
   
   return m_MFI[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MoneyFlow::GetMeanMFI(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   if(m_MeanMFI[TimeFrameIndex][Shift] < 0){
      ASSERT("Value is not init/set.", __FUNCTION__);
      return -1;
   }
   
   return m_MeanMFI[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MoneyFlow::GetStdDevMFI(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   if(m_StdDevMFI[TimeFrameIndex][Shift] < 0){
      ASSERT("Value is not init/set.", __FUNCTION__);
      return -1;
   }
   
   return m_StdDevMFI[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MoneyFlow::CalculateMFI(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetMFI(m_Handlers[TimeFrameIndex], Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MoneyFlow::SetShift(int Shift)
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

bool MoneyFlow::SetPeriod(int MFPeriod){
   if(MFPeriod < 0){
      LogError(__FUNCTION__, "Invalid Function Input.");
      m_Period = -1;
      return false;
   }
   
   m_Period = MFPeriod;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MoneyFlow::OnUpdateMFIStdDev(int TimeFrameIndex)
{   
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_MFI[TimeFrameIndex][i];
      
   
   m_MeanMFI[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 2);     
   m_StdDevMFI[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 2);   

}

//+------------------------------------------------------------------+
