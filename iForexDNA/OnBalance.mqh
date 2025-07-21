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

class OnBalance:public BaseIndicator{
   private:
      int                        m_Shift;
      ENUM_APPLIED_PRICE         m_AppliedPrice;
      
      int                        m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];
      
      
      double                     m_OBV[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      double                     m_MeanOBV[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      double                     m_StdDevOBV[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      
      
   public:
                                 OnBalance();
                                 ~OnBalance();
                                 
      bool                       Init();
      void                       OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double                     GetOBVValue(int TimeFrameIndex, int Shift);
      double                     GetMeanOBV(int TimeFrameIndex, int Shift);        
      double                     GetStdDevOBV(int TimeFrameIndex, int Shift);
      double                     GetStdDevPosition(int TimeFrameIndex, int Shift){return (int)(GetOBVValue(TimeFrameIndex, Shift) - m_MeanOBV[TimeFrameIndex][Shift])/m_StdDevOBV[TimeFrameIndex][Shift];};  
      
      double                     CalculateOBV(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
      
   private:
      bool                       SetShift(int Shift);
      bool                       SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);
      void                       OnUpdateOBVStdDev(int TimeFrameIndex);
      
      
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OnBalance::OnBalance():BaseIndicator("OnBalance"){
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OnBalance::~OnBalance(){
   ArrayRemove(m_OBV, 0);
   ArrayRemove(m_MeanOBV, 0);
   ArrayRemove(m_StdDevOBV, 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OnBalance::Init(){
   m_Shift = -1;
   m_AppliedPrice = -1;
   
   
   if(!SetShift(DEFAULT_SHIFT)
   || !SetAppliedPrice(APPLIED_PRICE))
      return false;


   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_Handler[i] = iOBV(Symbol(), timeFrameENUM, VOLUME_TICK);

      if(m_Handler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize OBV handlers.");
         return false;
      }

      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);

      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
         if(j < DEFAULT_BUFFER_SIZE){
            m_OBV[i][j] = GetOBV(m_Handler[i], j);
            tempArray[j] = m_OBV[i][j];            
            continue;
         }
         
         tempArray[j] = GetOBV(m_Handler[i], j);

      }   
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_MeanOBV[i][x]=NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD), 0);     
         m_StdDevOBV[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD), 0);          
         
      }
      
   }
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnBalance::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid TimeFrame Index...", __FUNCTION__);
      return;
   }
   
   if(IsNewBar){
      for(int i = DEFAULT_BUFFER_SIZE-1; i>0; i--){
         m_OBV[TimeFrameIndex][i] = m_OBV[TimeFrameIndex][i-1];
         m_MeanOBV[TimeFrameIndex][i] = m_MeanOBV[TimeFrameIndex][i-1];
         m_StdDevOBV[TimeFrameIndex][i] = m_StdDevOBV[TimeFrameIndex][i-1];
      }
   }
   
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   
   m_OBV[TimeFrameIndex][0] = GetOBV(m_Handler[TimeFrameIndex], m_Shift);
   OnUpdateOBVStdDev(TimeFrameIndex);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OnBalance::GetOBVValue(int TimeFrameIndex,int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("Array out of range / TimeFrame Index out of range", __FUNCTION__);
      return -1;
   }
   
   return m_OBV[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OnBalance::GetMeanOBV(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("Array out of range / TimeFrame Index out of range", __FUNCTION__);
      return -1;
   }
   
   return m_MeanOBV[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OnBalance::GetStdDevOBV(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("Array out of range / TimeFrame Index out of range", __FUNCTION__);
      return -1;
   }
   
   return m_StdDevOBV[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OnBalance::CalculateOBV(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   
   return GetOBV(m_Handler[TimeFrameIndex], Shift);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OnBalance::SetShift(int Shift){
   if(Shift < 0){
      LogError(__FUNCTION__, "Invalid Function Input.");
      m_Shift = -1;
      return false;
   }
   
   m_Shift = Shift;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OnBalance::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice){
   if(AppliedPrice < 0 || AppliedPrice > 6){
      LogError(__FUNCTION__, "Invalid Applied Price.");
      m_AppliedPrice = -1;
      return false;
   }

   m_AppliedPrice = AppliedPrice;
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnBalance::OnUpdateOBVStdDev(int TimeFrameIndex){   
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_OBV[TimeFrameIndex][i];
      
   
   m_MeanOBV[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 0);     
   m_StdDevOBV[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 0);   

}

//+------------------------------------------------------------------+