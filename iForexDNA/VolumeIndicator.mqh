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

class VolumeIndicator:public BaseIndicator{
   private:
      int            m_Shift;
      int            m_Handler[ENUM_TIMEFRAMES_ARRAY_SIZE];

      double         m_Volume[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
                 
      double         m_MeanVolume[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
      double         m_StdDevVolume[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   public:
                     VolumeIndicator();
                     ~VolumeIndicator();
                     
      bool           Init();
      void           OnUpdate(int TimeFrameIndex, bool IsNewBar);
      
      
      double         GetVolumeValue(int TimeFrameIndex, int Shift);
      double         GetMeanVolume(int TimeFrameIndex, int Shift);
      double         GetStdDevVolume(int TimeFrameIndex, int Shift);
      double         GetVolStdDevPosition(int TimeFrameIndex, int Shift){
                     return GetStdDevVolume(TimeFrameIndex, Shift) > 0?(GetVolumeValue(TimeFrameIndex, Shift) - GetMeanVolume(TimeFrameIndex, Shift)) / GetStdDevVolume(TimeFrameIndex, Shift):0;};
      
      
      double         CalculateVolume(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
      int            GetHandler(int TimeFrameIndex){return m_Handler[TimeFrameIndex];};
      
  private:
      bool           SetShift(int Shift);
      void           OnUpdateVolumeStdDev(int TimeFrameIndex);               
         
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

VolumeIndicator::VolumeIndicator():BaseIndicator("VolumeIndicator"){
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

VolumeIndicator::~VolumeIndicator(){
   ArrayRemove(m_Volume, 0);
   ArrayRemove(m_MeanVolume, 0);
   ArrayRemove(m_StdDevVolume, 0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool VolumeIndicator::Init()
{
   m_Shift = -1;
   
   if(!SetShift(DEFAULT_SHIFT))
      return false; 
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(i);
      
      m_Handler[i] = iVolumes(Symbol(), timeFrameENUM, VOLUME_TICK);

      if(m_Handler[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize Volume handlers.");
         return false;
      }

      double tempArray[DEFAULT_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempArray);

      for(int j = 0; j < DEFAULT_BUFFER_SIZE*2; j++)
      {
         if(j < DEFAULT_BUFFER_SIZE){
            m_Volume[i][j] = GetVolume(m_Handler[i], j+m_Shift);
            tempArray[j] = m_Volume[i][j];
            continue;
         }
       
         tempArray[j] = GetVolume(m_Handler[i], j+m_Shift);
      }
                        
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_MeanVolume[i][x]=NormalizeDouble(MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD), 0);
         m_StdDevVolume[i][x]=NormalizeDouble(MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD), 0);
      }
         
   }

   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void VolumeIndicator::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid TimeFrame Index...", __FUNCTION__);
      return;
   }
   
   if(IsNewBar){
      for(int i = DEFAULT_BUFFER_SIZE-1; i>0; i--){
         m_Volume[TimeFrameIndex][i] = m_Volume[TimeFrameIndex][i-1];
         m_MeanVolume[TimeFrameIndex][i] = m_MeanVolume[TimeFrameIndex][i-1];
         m_StdDevVolume[TimeFrameIndex][i] = m_StdDevVolume[TimeFrameIndex][i-1];
      }
   }
   
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   
   m_Volume[TimeFrameIndex][0] = GetVolume(m_Handler[TimeFrameIndex], m_Shift);
   OnUpdateVolumeStdDev(TimeFrameIndex);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double VolumeIndicator::GetVolumeValue(int TimeFrameIndex,int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("Array out of range / TimeFrame Index out of range", __FUNCTION__);
      return -1;
   }
   
   if(m_Volume[TimeFrameIndex][Shift] < 0){
      ASSERT("Buffer value not init.", __FUNCTION__);
      return -1;
   }
   
   return m_Volume[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double VolumeIndicator::GetMeanVolume(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   if(m_MeanVolume[TimeFrameIndex][Shift] < 0){
      ASSERT("Value is not init/set.", __FUNCTION__);
      return -1;
   }
   
   return m_MeanVolume[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double VolumeIndicator::GetStdDevVolume(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("TimeFrame Index out of range...", __FUNCTION__);
      return -1;
   }
   
   if(m_StdDevVolume[TimeFrameIndex][Shift] < 0){
      ASSERT("Value is not init/set.", __FUNCTION__);
      return -1;
   }
   
   return m_StdDevVolume[TimeFrameIndex][Shift];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double VolumeIndicator::CalculateVolume(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   return GetVolume(m_Handler[TimeFrameIndex], Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool VolumeIndicator::SetShift(int Shift){
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

void VolumeIndicator::OnUpdateVolumeStdDev(int TimeFrameIndex)
{   
double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_Volume[TimeFrameIndex][i];
      
   m_MeanVolume[TimeFrameIndex][0]=NormalizeDouble(MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 0);
   m_StdDevVolume[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD), 0);
   
}

//+------------------------------------------------------------------+
