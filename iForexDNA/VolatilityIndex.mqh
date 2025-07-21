//+------------------------------------------------------------------+
//|                                              VolatilityIndex.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, iPayDNA"
#property link      "http://ipaydna.biz"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class VolatilityIndex:public BaseIndicator{
   private:
      IndicatorsHelper              *m_Indicators;
 
      int                           m_TotalVolatility;
    
      double                        m_Volatility_Percent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];  
      double                        m_Volatility_Mean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double                        m_Volatility_StdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];


      double                        CalculateVolatility(int TimeFrameIndex, int Shift);
      void                          OnUpdateVolatilityMeanStdDev(int TimeFrameIndex);
      
      bool                          SetTotalVolatility(int TotalVolatility);


   public:
                                    VolatilityIndex(IndicatorsHelper *pIndicators);
                                    ~VolatilityIndex();
                     
      bool                          Init();
      void                          OnUpdate(int TimeFrameIndex, bool IsNewBar);
   
   
      double                        GetVolatilityPercent(int TimeFrameIndex, int Shift){return m_Volatility_Percent[TimeFrameIndex][Shift];};  
      
      double                        GetVolatilityMean(int TimeFrameIndex, int Shift){return m_Volatility_Mean[TimeFrameIndex][Shift];};
      double                        GetVolatilityStdDev(int TimeFrameIndex, int Shift){return m_Volatility_StdDev[TimeFrameIndex][Shift];};
      
      //    Get the 2 x or 3 x std dev using float variable
      
      double                        GetVolatilityUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_Volatility_Mean[TimeFrameIndex][Shift]+(Multiplier*m_Volatility_StdDev[TimeFrameIndex][Shift]);};

      double                        GetVolatilityStdDevPosition(int TimeFrameIndex, int Shift);

      ENUM_INDICATOR_POSITION       GetVolatilityPosition(int TimeFrameIndex, int Shift);

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

VolatilityIndex::VolatilityIndex(IndicatorsHelper *pIndicators):BaseIndicator("Volatility"){
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;   

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

VolatilityIndex::~VolatilityIndex()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool VolatilityIndex::Init(){
   if(!SetTotalVolatility(TOTAL_VOLATILITY_INDEX))
      return false;


   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      double tempVolatilityArray[INDEXES_BUFFER_SIZE*2];
      int arrsize=ArraySize(tempVolatilityArray);

      for(int j = 0; j < INDEXES_BUFFER_SIZE*2; j++){
         if(j < INDEXES_BUFFER_SIZE)
         {
            m_Volatility_Percent[i][j] = CalculateVolatility(i, j);
            tempVolatilityArray[j] = m_Volatility_Percent[i][j];
            continue;
         }
            
         tempVolatilityArray[j] = CalculateVolatility(i,j);
            
      }
      
      
      // calculate Mean/StdDev
      for(int k = 0; k < INDEXES_BUFFER_SIZE; k++)
      {
         m_Volatility_Mean[i][k]=NormalizeDouble(MathMean(tempVolatilityArray, k, ADVANCE_INDICATOR_PERIOD), 2);
         m_Volatility_StdDev[i][k]=NormalizeDouble(MathStandardDeviation(tempVolatilityArray, k, ADVANCE_INDICATOR_PERIOD), 2);
      }
      
   }
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void VolatilityIndex::OnUpdate(int TimeFrameIndex,bool IsNewBar){   
   //       Look for the One Liner Indicator Peak after the break out
   //       i notice the max High and Max low of the below 9 indicators can tell where the reverals are.  
   //       At the max of these one line indicators and i can find the maximum peak and Volatility is close to 0 or within +/- 1 std dev.
   //       This shows the volatility has dried up and its moving to probably consolidation phase or distribution phase
   //       The Highest and Lowest are reset when DI+ crosses DI- or vice versus 


   if(IsNewBar)
   {
      for(int j = INDEXES_BUFFER_SIZE-1; j>0; j--){
         // volatility index update

         m_Volatility_Percent[TimeFrameIndex][j] = m_Volatility_Percent[TimeFrameIndex][j-1];
         m_Volatility_Mean[TimeFrameIndex][j] = m_Volatility_Mean[TimeFrameIndex][j-1];
         m_Volatility_StdDev[TimeFrameIndex][j] = m_Volatility_StdDev[TimeFrameIndex][j-1];    

      }
      
   } 
   
   m_Volatility_Percent[TimeFrameIndex][0] = CalculateVolatility(TimeFrameIndex, 0);
   OnUpdateVolatilityMeanStdDev(TimeFrameIndex);

}

   //////////////////////////////////////////////////// So if it is a break out then it should follow price action
   //////////////////////////////////////////////////// Also comparing Pirce Action with Indicator (If Possible) will give a faster reaction
   //////////////////////////////////////////////////// Since This is Volatility so i am adding codes for divergence to show Volatility drying up 
   //////////////////////////////////////////////////// OR Volatility reversing

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double VolatilityIndex::CalculateVolatility(int TimeFrameIndex, int Shift)
{
   // temporary variables for Value, Mean, StdDev
   double IndicatorValue = 0, IndicatorMean = 0, IndicatorStdDev = 0; 
   double VolIndex = 0;
   

    
   // ATR
   IndicatorValue = m_Indicators.GetATR().GetATRValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetATR().GetATRValueMean(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetATR().GetATRValueStdDev(TimeFrameIndex, Shift);
   
   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev))
      VolIndex+=3;
   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev))
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev))
      VolIndex++;  

   
   // DMI
   IndicatorValue = m_Indicators.GetADX().GetDMI(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetADX().GetDMIMean(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetADX().GetDMIStdDev(TimeFrameIndex, Shift);
   

   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev))
      VolIndex+=3;
   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev))
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev))
      VolIndex++;


   // MOM
   IndicatorValue = m_Indicators.GetMomentum().GetMomentumValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetMomentum().GetMomentumMean(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetMomentum().GetMomentumStdDev(TimeFrameIndex, Shift);

   
   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (3*IndicatorStdDev)
   )
      VolIndex+=3;

   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (2*IndicatorStdDev)
   )
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (IndicatorStdDev)
   )
      VolIndex++;
     
      
   // Force Index
   IndicatorValue = m_Indicators.GetForceIndex().GetForceIndexValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetForceIndex().GetForceMean(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetForceIndex().GetForceStdDev(TimeFrameIndex, Shift);

   
   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (3*IndicatorStdDev)
   )
      VolIndex+=3;

   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (2*IndicatorStdDev)
   )
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (IndicatorStdDev)
   )
      VolIndex++;

   
   // MFI
   IndicatorValue = m_Indicators.GetMoneyFlow().GetMFIValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetMoneyFlow().GetMeanMFI(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetMoneyFlow().GetStdDevMFI(TimeFrameIndex, Shift);

   
   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (3*IndicatorStdDev)
   )
      VolIndex+=3;
   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (2*IndicatorStdDev)
   )
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (IndicatorStdDev)
   )
      VolIndex++;
      
   
   // CCI
   IndicatorValue = m_Indicators.GetCCI().GetCCIValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetCCI().GetCCIMean(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetCCI().GetCCIStdDev(TimeFrameIndex, Shift);
   

   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (3*IndicatorStdDev)
   )
      VolIndex+=3;
   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (2*IndicatorStdDev)
   )
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (IndicatorStdDev)
   )
      VolIndex++;

 
   // OBV
   IndicatorValue = m_Indicators.GetOnBalance().GetOBVValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetOnBalance().GetMeanOBV(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetOnBalance().GetStdDevOBV(TimeFrameIndex, Shift);
    

   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (3*IndicatorStdDev)
   )
      VolIndex+=3;
   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (2*IndicatorStdDev)
   )
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (IndicatorStdDev)
   )
      VolIndex++;

   
   // AD
   IndicatorValue = m_Indicators.GetAccumulation().GetADValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetAccumulation().GetMeanAD(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetAccumulation().GetStdDevAD(TimeFrameIndex, Shift);


   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (3*IndicatorStdDev)
   )
      VolIndex+=3;   
   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (2*IndicatorStdDev)
   )
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev)
   || IndicatorValue < IndicatorMean - (IndicatorStdDev)
   )
      VolIndex++;


   // Vol
   IndicatorValue = m_Indicators.GetVolumeIndicator().GetVolumeValue(TimeFrameIndex, Shift);
   IndicatorMean = m_Indicators.GetVolumeIndicator().GetMeanVolume(TimeFrameIndex, Shift);
   IndicatorStdDev = m_Indicators.GetVolumeIndicator().GetStdDevVolume(TimeFrameIndex, Shift);


   if(IndicatorValue > IndicatorMean + (3*IndicatorStdDev))
      VolIndex+=3;
   
   else if(IndicatorValue > IndicatorMean + (2*IndicatorStdDev))
      VolIndex+=2;
      
   else if(IndicatorValue > IndicatorMean + (IndicatorStdDev))
      VolIndex++;


  
   // FINAL CALCULATION 
   return NormalizeDouble((VolIndex/(double)m_TotalVolatility)*100, 2);
  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void VolatilityIndex::OnUpdateVolatilityMeanStdDev(int TimeFrameIndex)
{  
   
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   double tempVolatilityArray[ADVANCE_INDICATOR_PERIOD];

   for(int i=0; i < ADVANCE_INDICATOR_PERIOD; i++)
      tempVolatilityArray[i] = m_Volatility_Percent[TimeFrameIndex][i];
      

   m_Volatility_Mean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempVolatilityArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_Volatility_StdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempVolatilityArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION VolatilityIndex::GetVolatilityPosition(int TimeFrameIndex, int Shift)
{
   if(m_Volatility_Percent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_Volatility_Percent[TimeFrameIndex][Shift] > GetVolatilityUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_Volatility_Percent[TimeFrameIndex][Shift] > GetVolatilityUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_Volatility_Percent[TimeFrameIndex][Shift] > m_Volatility_Mean[TimeFrameIndex][Shift] && m_Volatility_Percent[TimeFrameIndex][Shift] < GetVolatilityUpperStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
      
   else if(m_Volatility_Percent[TimeFrameIndex][Shift] == m_Volatility_Mean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_Volatility_Percent[TimeFrameIndex][Shift] < m_Volatility_Mean[TimeFrameIndex][Shift])
      return Below_Mean;
      
   else
      return Null;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double VolatilityIndex::GetVolatilityStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(m_Volatility_StdDev[TimeFrameIndex][Shift] == 0)
      return 0;
      
   
   return NormalizeDouble((m_Volatility_Percent[TimeFrameIndex][Shift] - m_Volatility_Mean[TimeFrameIndex][Shift])/m_Volatility_StdDev[TimeFrameIndex][Shift], 2);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool VolatilityIndex::SetTotalVolatility(int TotalVolatility)
{
   if(TotalVolatility<0)
     {
      LogError(__FUNCTION__,"Invalid Total Volatility Index input.");
      m_TotalVolatility=0;
      return false;
     }

   m_TotalVolatility=TotalVolatility;
   return true;

}

//+------------------------------------------------------------------+
