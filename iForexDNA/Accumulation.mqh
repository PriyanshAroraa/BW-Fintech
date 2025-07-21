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

class Accumulation:public BaseIndicator{
   private:
      int            m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int            m_Shift;


      double         m_AD[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];                 
      double         m_MeanAD[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      double         m_StdDevAD[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      
   
   public:
                     Accumulation();
                     ~Accumulation();
                     
      bool           Init();
      void           OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double         GetADValue(int TimeFrameIndex, int Shift);
      double         GetMeanAD(int TimeFrameIndex, int Shift);
      double         GetStdDevAD(int TimeFrameIndex, int Shift);
      double         GetStdDevPosition(int TimeFrameIndex, int Shift);
      
      
      double         CalculateAD(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
      
      
  private:
      bool           SetShift(int Shift);    
      void           OnUpdateMeanStdDev(int TimeFrameIndex);    
         
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Accumulation::Accumulation():BaseIndicator("Accumulation"){
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Accumulation::~Accumulation(){
   ArrayRemove(m_AD,0);
   ArrayRemove(m_MeanAD,0);
   ArrayRemove(m_StdDevAD,0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Accumulation::Init(){
   m_Shift = -1;
   
   if(!SetShift(DEFAULT_SHIFT)){
      return false;
   }
      
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
         
      // Initializing handlers
      m_Handler[i] = iAD(Symbol(), timeFrameENUM, VOLUME_TICK);
      
      if(m_Handler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize Accumulation handlers.");
         return false;
      }
      
      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);
      
      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++){
         if(j < DEFAULT_BUFFER_SIZE){
            m_AD[i][j] = GetAD(m_Handler[i], j + m_Shift);
            tempArray[j] = m_AD[i][j];
            continue;
         }
         
         tempArray[j] = GetAD(m_Handler[i], j + m_Shift);
      }
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_MeanAD[i][x]=NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD), 0);     
         m_StdDevAD[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD), 0);   
      }


   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Accumulation::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid TimeFrame Index...", __FUNCTION__);
      return;
   }
   
   if(IsNewBar)
   {
      for(int i = DEFAULT_BUFFER_SIZE-1; i>0; i--){
         m_AD[TimeFrameIndex][i] = m_AD[TimeFrameIndex][i-1];
         m_MeanAD[TimeFrameIndex][i] = m_MeanAD[TimeFrameIndex][i-1];
         m_StdDevAD[TimeFrameIndex][i] = m_StdDevAD[TimeFrameIndex][i-1];
      }
   }

   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   m_AD[TimeFrameIndex][0]=GetAD(m_Handler[TimeFrameIndex], m_Shift);
   OnUpdateMeanStdDev(TimeFrameIndex);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Accumulation::OnUpdateMeanStdDev(int TimeFrameIndex)
{
   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_AD[TimeFrameIndex][i];
      
   
   m_MeanAD[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD),0);     
   m_StdDevAD[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 0);   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Accumulation::GetADValue(int TimeFrameIndex,int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("Array out of range / TimeFrame Index out of range", __FUNCTION__);
      return -1;
   }
   
   return m_AD[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Accumulation::GetMeanAD(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   return m_MeanAD[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Accumulation::GetStdDevAD(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   return m_StdDevAD[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Accumulation::GetStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   return m_StdDevAD[TimeFrameIndex][Shift] != 0 ? (GetADValue(TimeFrameIndex, Shift) - m_MeanAD[TimeFrameIndex][Shift])/m_StdDevAD[TimeFrameIndex][Shift] : 0;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Accumulation::CalculateAD(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   return GetAD(m_Handler[GetTimeFrameIndex(timeFrameENUM)], Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Accumulation::SetShift(int Shift){
   if(Shift < 0){
      LogError(__FUNCTION__, "Invalid Function Input.");
      m_Shift = -1;
      return false;
   }
   
   m_Shift = Shift;
   return true;
}

//+------------------------------------------------------------------+
