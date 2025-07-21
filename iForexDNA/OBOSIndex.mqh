//+------------------------------------------------------------------+
//|                                                   OBOSIndex.mqh  |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, iPayDNA"
#property link      "http://ipaydna.biz"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BullBearIndex.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class OBOSIndex:public BaseIndicator{
   private:
      IndicatorsHelper    *m_Indicators;
      int                  m_TotalOBOSIndex;
         
         
         
      // OBOS index 
      double               m_OBPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double               m_OSPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      double               m_OBMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double               m_OSMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      double               m_OBStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double               m_OSStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];



      string               CalculateOBOS(int TimeFrameIndex, int Shift);             // Summary for all the indicators BullBear Index
      void                 OnUpdateOBOSStdDev(int TimeFrameIndex);
      
      
      bool                 SetTotalOBOSIndex(int TotalOBOSIndex);
      
   public:
                           OBOSIndex(IndicatorsHelper *pIndicators);
                           ~OBOSIndex();
      bool                 Init();
      void                 OnUpdate(int TimeFrameIndex, bool IsNewBar);
   
   
      // get OB/OS result
      double               GetOBPercent(int TimeFrameIndex, int Shift){return m_OBPercent[TimeFrameIndex][Shift];};
      double               GetOSPercent(int TimeFrameIndex, int Shift){return m_OSPercent[TimeFrameIndex][Shift];};
      
      double               GetOBMean(int TimeFrameIndex, int Shift){return m_OBMean[TimeFrameIndex][Shift];};
      double               GetOSMean(int TimeFrameIndex, int Shift){return m_OSMean[TimeFrameIndex][Shift];};

      double               GetOBStdDev(int TimeFrameIndex, int Shift){return m_OBStdDev[TimeFrameIndex][Shift];};
      double               GetOSStdDev(int TimeFrameIndex, int Shift){return m_OSStdDev[TimeFrameIndex][Shift];};

      double               GetOBUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_OBMean[TimeFrameIndex][Shift] + Multiplier*m_OBStdDev[TimeFrameIndex][Shift];};
      double               GetOSUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_OSMean[TimeFrameIndex][Shift] + Multiplier*m_OSStdDev[TimeFrameIndex][Shift];};

      double               GetOBStdDevPosition(int TimeFrameIndex, int Shift);
      double               GetOSStdDevPosition(int TimeFrameIndex, int Shift); 


      ENUM_INDICATOR_POSITION    GetOBPosition(int TimeFrameIndex, int Shift);
      ENUM_INDICATOR_POSITION    GetOSPosition(int TimeFrameIndex, int Shift);
      
      int                        GetIsCrossOBOS(int TimeFrameIndex, int Shift);

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OBOSIndex::OBOSIndex(IndicatorsHelper *pIndicators):BaseIndicator("OBOS")
{
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OBOSIndex::~OBOSIndex(){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OBOSIndex::Init(){
   if(!SetTotalOBOSIndex(TOTAL_OBOS_INDEX))
      return false;

   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      double tempOBArray[INDEXES_BUFFER_SIZE*2];
      double tempOSArray[INDEXES_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempOBArray);
   
      for(int j = 0; j < INDEXES_BUFFER_SIZE; j++)
      {
         if(j < INDEXES_BUFFER_SIZE) 
         {
            CalculateOBOS(i,j);
         }
         
         else
         {
            string tempArray[2];
            StringSplit(CalculateOBOS(i,j), '/', tempArray);
   
            tempOBArray[j] = StringToDouble(tempArray[0]);
            tempOSArray[j] = StringToDouble(tempArray[1]);
         }

      }

      // calculate mean/std
      for(int x = 0; x < INDEXES_BUFFER_SIZE; x++)
      {
         m_OBMean[i][x] = NormalizeDouble(MathMean(tempOBArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_OBStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempOBArray, x, ADVANCE_INDICATOR_PERIOD), 2);


         m_OSMean[i][x] = NormalizeDouble(MathMean(tempOSArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_OSStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempOSArray, x, ADVANCE_INDICATOR_PERIOD), 2);
                   
      }

   }  // i loop
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OBOSIndex::OnUpdate(int TimeFrameIndex,bool IsNewBar){ 
   if(IsNewBar){
      for(int j = INDEXES_BUFFER_SIZE-1; j > 0; j--){  
         m_OBPercent[TimeFrameIndex][j] = m_OBPercent[TimeFrameIndex][j-1];
         m_OSPercent[TimeFrameIndex][j] = m_OSPercent[TimeFrameIndex][j-1];

         m_OBMean[TimeFrameIndex][j] = m_OBMean[TimeFrameIndex][j-1];
         m_OSMean[TimeFrameIndex][j] = m_OSMean[TimeFrameIndex][j-1];
         
         m_OBStdDev[TimeFrameIndex][j] = m_OBStdDev[TimeFrameIndex][j-1];
         m_OSStdDev[TimeFrameIndex][j] = m_OSStdDev[TimeFrameIndex][j-1];
         
      }  

   }
   
   CalculateOBOS(TimeFrameIndex, 0);
   OnUpdateOBOSStdDev(TimeFrameIndex);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string OBOSIndex::CalculateOBOS(int TimeFrameIndex, int Shift) {
   double OB_Index = 0;
   double OS_Index = 0;


   ENUM_TIMEFRAMES TimeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   // PIVOT
   double curClose = Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetClose():iClose(Symbol(),TimeFrameENUM,Shift);
   
   if(TimeFrameENUM == PERIOD_D1)
   {
      if(curClose > m_Indicators.GetPivot().GetPivotR(TimeFrameIndex, Shift, 1))
         OB_Index++;
         
      else if(curClose < m_Indicators.GetPivot().GetPivotS(TimeFrameIndex, Shift, 1))
         OS_Index++;
   }


   else{
      if(curClose > m_Indicators.GetPivot().GetPivotR(TimeFrameIndex, Shift, 2))
         OB_Index++;
         
      else if(curClose < m_Indicators.GetPivot().GetPivotS(TimeFrameIndex, Shift, 2))
         OS_Index++;
   }

   
   // Stochastic
   double STOSignal = m_Indicators.GetSTO().GetSignal(TimeFrameIndex, Shift);
   double STOMean = m_Indicators.GetSTO().GetSTOMean(TimeFrameIndex, Shift);
   double STOStdDev = m_Indicators.GetSTO().GetSTOStdDev(TimeFrameIndex, Shift);
   

   // OB
   if(STOSignal > STOMean + (3*STOStdDev))
      OB_Index+=3;
   


   else if(STOSignal > STOMean + (2*STOStdDev))
      OB_Index+=2;
   
   
   
   else if(STOSignal > STOMean + STOStdDev)
      OB_Index++;


   // OS
   if(STOSignal < STOMean - (3*STOStdDev))
      OS_Index+=3;
   
   
   else if(STOSignal < STOMean - (2*STOStdDev)) 
      OS_Index+=2;
   
   
   else if(STOSignal < STOMean - STOStdDev)
      OS_Index++;
   


  
   // RSI
  double RSIVal = m_Indicators.GetRSI().GetRSIValue(TimeFrameIndex, Shift);
  double RSIMean = m_Indicators.GetRSI().GetRSIMean(TimeFrameIndex, Shift);
  double RSIStdDev = m_Indicators.GetRSI().GetRSIStdDev(TimeFrameIndex, Shift);
  
  
   // OB
   if(RSIVal > RSIMean + (3*RSIStdDev))
      OB_Index+=3;
      
   
   else if(RSIVal > RSIMean + (2*RSIStdDev))
      OB_Index+=2;
   
   
   else if(RSIVal > RSIMean + RSIStdDev)
      OB_Index++;


   
   // OS
   if(RSIVal < RSIMean - (3*RSIStdDev))
      OS_Index+=3;

   
   else if(RSIVal < RSIMean - (2*RSIStdDev))
      OS_Index+=2;

   
   
   else if(RSIVal < RSIMean - RSIStdDev)
      OS_Index++;


 
   
   // RVI
   double   RVISignal = m_Indicators.GetRVI().GetRVISignal(TimeFrameIndex, Shift);
   double   RVIMean = m_Indicators.GetRVI().GetRVIMean(TimeFrameIndex, Shift);
   double   RVIStdDev = m_Indicators.GetRVI().GetRVIStdDev(TimeFrameIndex, Shift);
   
   
   
   // OB
   if(RVISignal > RVIMean + (3*RVIStdDev))
      OB_Index+=2;

   
   else if(RVISignal > RVIMean + (2*RVIStdDev))
      OB_Index++;
   
   // OS
   if(RVISignal < RVIMean - (3*RVIStdDev))
      OS_Index+=2;

   
   else if(RVISignal < RVIMean - (2*RVIStdDev))
      OS_Index++;

   
   
   // MFI
   double MFIVal = m_Indicators.GetMoneyFlow().GetMFIValue(TimeFrameIndex, Shift);
   double MFIMean = m_Indicators.GetMoneyFlow().GetMeanMFI(TimeFrameIndex, Shift);
   double MFIStdDev = m_Indicators.GetMoneyFlow().GetStdDevMFI(TimeFrameIndex, Shift);
   
   
   if(MFIVal > MFIMean + (3*MFIStdDev))
      OB_Index+=3;

   
   else if(MFIVal > MFIMean + (2*MFIStdDev))
      OB_Index+=2;

   
   else if(MFIVal > MFIMean + MFIStdDev)
      OB_Index++;
      
   
   // OS
   if(MFIVal < MFIMean - (3*MFIStdDev))
      OS_Index+=3;

   
   else if(MFIVal < MFIMean - (2*MFIStdDev))
      OS_Index+=2;

   
   else if(MFIVal < MFIMean - MFIStdDev)
      OS_Index++;

   
   if(Shift < INDEXES_BUFFER_SIZE)
   {
      m_OBPercent[TimeFrameIndex][Shift] = NormalizeDouble((OB_Index/(double)m_TotalOBOSIndex)*100, 2);
      m_OSPercent[TimeFrameIndex][Shift] = NormalizeDouble((OS_Index/(double)m_TotalOBOSIndex)*100, 2);
   
      return "";
   }
   
   string OBPercent = DoubleToString((OB_Index/(double)m_TotalOBOSIndex)*100, 2);
   string OSPercent = DoubleToString((OS_Index/(double)m_TotalOBOSIndex)*100, 2);
   
   return OBPercent + "/" + OSPercent;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OBOSIndex::OnUpdateOBOSStdDev(int TimeFrameIndex)
{
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   double tempOBArray[ADVANCE_INDICATOR_PERIOD];
   double tempOSArray[ADVANCE_INDICATOR_PERIOD];

   for(int i=0; i < ADVANCE_INDICATOR_PERIOD; i++)
   {
      tempOBArray[i] = m_OBPercent[TimeFrameIndex][i];
      tempOSArray[i] = m_OSPercent[TimeFrameIndex][i];
   }   

   m_OBMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempOBArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_OBStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempOBArray, 0, ADVANCE_INDICATOR_PERIOD), 2);


   m_OSMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempOSArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_OSStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempOSArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OBOSIndex::GetOBStdDevPosition(int TimeFrameIndex,int Shift){
   if(m_OBStdDev[TimeFrameIndex][Shift] == 0)
      return 0;
      
   
   return NormalizeDouble((m_OBPercent[TimeFrameIndex][Shift] - m_OBMean[TimeFrameIndex][Shift])/m_OBStdDev[TimeFrameIndex][Shift], 2);
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OBOSIndex::GetOSStdDevPosition(int TimeFrameIndex,int Shift){
   if(m_OSStdDev[TimeFrameIndex][Shift] == 0)
      return 0;
      
   
   return NormalizeDouble((m_OSPercent[TimeFrameIndex][Shift] - m_OSMean[TimeFrameIndex][Shift])/m_OSStdDev[TimeFrameIndex][Shift], 2);
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION OBOSIndex::GetOBPosition(int TimeFrameIndex,int Shift)
{
   if(m_OBPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_OBPercent[TimeFrameIndex][Shift] > GetOBUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_OBPercent[TimeFrameIndex][Shift] > GetOBUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_OBPercent[TimeFrameIndex][Shift] > m_OBMean[TimeFrameIndex][Shift] && m_OBPercent[TimeFrameIndex][Shift] < GetOBUpperStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
   
   else if(m_OBPercent[TimeFrameIndex][Shift] == m_OBMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_OBPercent[TimeFrameIndex][Shift] < m_OBMean[TimeFrameIndex][Shift])
      return Below_Mean;   

   else
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION OBOSIndex::GetOSPosition(int TimeFrameIndex,int Shift)
{
   if(m_OSPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_OSPercent[TimeFrameIndex][Shift] > GetOSUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_OSPercent[TimeFrameIndex][Shift] > GetOSUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_OSPercent[TimeFrameIndex][Shift] > m_OSMean[TimeFrameIndex][Shift] && m_OSPercent[TimeFrameIndex][Shift] < GetOSUpperStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
      
   else if(m_OSPercent[TimeFrameIndex][Shift] == m_OSMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_OSPercent[TimeFrameIndex][Shift] < m_OSMean[TimeFrameIndex][Shift])
      return Below_Mean;
      
   else 
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OBOSIndex::GetIsCrossOBOS(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || Shift+1 >= INDEXES_BUFFER_SIZE) 
   {
      LogError(__FUNCTION__, "TimeFrameIndex/Shift out of range.");
      return false;
   }  
   
   if(m_OBPercent[TimeFrameIndex][Shift] >= m_OSPercent[TimeFrameIndex][Shift]
   && m_OBPercent[TimeFrameIndex][Shift+1] < m_OSPercent[TimeFrameIndex][Shift+1]
   )
      return BULL_TRIGGER;
      
   else if(m_OBPercent[TimeFrameIndex][Shift] <= m_OSPercent[TimeFrameIndex][Shift]
   && m_OBPercent[TimeFrameIndex][Shift+1] > m_OSPercent[TimeFrameIndex][Shift+1]
   )
      return BEAR_TRIGGER;
      
   return NEUTRAL;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OBOSIndex::SetTotalOBOSIndex(int TotalOBOSIndex)
{
   if(TotalOBOSIndex<0)
     {
      LogError(__FUNCTION__,"Invalid Total OBOS Index input.");
      m_TotalOBOSIndex=0;
      return false;
     }

   m_TotalOBOSIndex=TotalOBOSIndex;
   return true;
}

//+------------------------------------------------------------------+