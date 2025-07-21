//+------------------------------------------------------------------+
//|                                           zzAlignmentIndex.mqh   |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict


#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\ZigZag.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\MiscFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class ZigZagAdvIndicator:public BaseIndicator{
   private:   
      IndicatorsHelper                 *m_Indicators;
      
      double                           m_ZZ_Value[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];

      // Reversals From ZigZag
      string                           m_Bull_ReversalType;
      string                           m_Bear_ReversalType;

   public:
                                      ZigZagAdvIndicator(IndicatorsHelper *pIndicators);
                                      ~ZigZagAdvIndicator();
                                                  
      bool                            Init();
      void                            OnUpdate(int TimeFrameIndex, bool IsNewBar);
                
      
      //       ZZ Price based on barshift
                
      double                          GetZigZagBarShiftPrice(ENUM_TIMEFRAMES TimeFrameENUM, int BarShift);
      
      
      // ZigZag Reversal Getter
      string                           GetBullReversalType(){return m_Bull_ReversalType;};
      string                           GetBearReversalType(){return m_Bear_ReversalType;};



};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ZigZagAdvIndicator::ZigZagAdvIndicator(IndicatorsHelper *pIndicators):BaseIndicator("ZigZagAdvIndicator")
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

ZigZagAdvIndicator::~ZigZagAdvIndicator()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ZigZagAdvIndicator::Init()
{
   ArrayInitialize(m_ZZ_Value, 0);
   
   for(int i = 0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      for(int j = 0; j < INDEXES_BUFFER_SIZE; j++)
      {
         datetime curTime = iTime(Symbol(), PERIOD_M15, j);
      
         // Lower than M15 (Just push the data)
         if(i  <= 2)
            m_ZZ_Value[i][j] = m_Indicators.GetZigZag().GetZigZagPriceFromBarShift(i, j);
         
         else
         {
            int barshift = iBarShift(Symbol(), GetTimeFrameENUM(i), curTime);
            m_ZZ_Value[i][j] = m_Indicators.GetZigZag().GetZigZagPriceFromBarShift(i, barshift);
         }
      }
   }
   
   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void ZigZagAdvIndicator::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{
   // Updates the < M15
   if(TimeFrameIndex < 2)
   {
      if(IsNewBar)
      {
         for(int i = INDEXES_BUFFER_SIZE-1; i > 0; i--)
            m_ZZ_Value[TimeFrameIndex][i] = m_ZZ_Value[TimeFrameIndex][i-1];
      }
      
      // Update current bar
      m_ZZ_Value[TimeFrameIndex][0] = m_Indicators.GetZigZag().GetZigZagPriceFromBarShift(TimeFrameIndex, 0);
   }

   // Other timeframes are updated based on M15
   else if(TimeFrameIndex == 2)
   {
      if(IsNewBar)
      {
         for(int i = INDEXES_BUFFER_SIZE-1; i > 0; i--)
         {
            m_ZZ_Value[2][i] = m_ZZ_Value[2][i-1];  // Update M15
            m_ZZ_Value[3][i] = m_ZZ_Value[3][i-1];  // Update H1
            m_ZZ_Value[4][i] = m_ZZ_Value[4][i-1];  // Update H4
            m_ZZ_Value[5][i] = m_ZZ_Value[5][i-1];  // Update D1
         }
      }
      
      datetime curtime = iTime(Symbol(), GetTimeFrameENUM(TimeFrameIndex), 0);
      
      // Updates the current zigzag price
      for(int i = 2; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      {
         int barshift = iBarShift(Symbol(), GetTimeFrameENUM(i), curtime);
         m_ZZ_Value[i][0] = m_Indicators.GetZigZag().GetZigZagPriceFromBarShift(i, barshift);
      }
   }   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double ZigZagAdvIndicator::GetZigZagBarShiftPrice(ENUM_TIMEFRAMES TimeFrameENUM,int BarShift)
{
   if(BarShift < 0 || BarShift >= INDEXES_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "BarShift is out of range.");
      return 0;
   }
         
   int TimeFrameIndex = GetTimeFrameIndex(TimeFrameENUM);
   
   return m_ZZ_Value[TimeFrameIndex][BarShift];
   
}

//+------------------------------------------------------------------+