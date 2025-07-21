//+------------------------------------------------------------------+
//|                                                   Middleline.mqh |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class Middleline:public BaseIndicator{
   private:
      IndicatorsHelper     *m_Indicators;
      
      double               m_Main[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      
   public:
                           Middleline(IndicatorsHelper *pIndicators);
                           ~Middleline();
                           
                           
                           
                           
       bool                Init();
       void                OnUpdate(int TimeFrameIndex, bool IsNewBar);
       
       
       double              GetMain(int TimeFrameIndex, int Shift){return m_Main[TimeFrameIndex][Shift];};
       double              GetUpper(int TimeFrameIndex, int Shift, float Multiplier=1.0);
       double              GetLower(int TimeFrameIndex, int Shift, float Multiplier=1.0);
     
      
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Middleline::Middleline(IndicatorsHelper *pIndicators):BaseIndicator("Middleline"){
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Middleline::~Middleline()
{

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Middleline::Init(){
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {       
      for(int j=0; j < INDEXES_BUFFER_SIZE; j++)
      {      
         m_Main[i][j] = NormalizeDouble((m_Indicators.GetBands().GetMain(i, j)
                                          +m_Indicators.GetIchimoku().GetKijunSen(i,j)
                                          +m_Indicators.GetIchimoku().GetTenkanSen(i, j)/3), _Digits);
                                         
      }

   }

   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Middleline::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   if(IsNewBar)
   {
      for(int j = INDEXES_BUFFER_SIZE-1; j > 0; j--)
      {
         m_Main[TimeFrameIndex][j] = m_Main[TimeFrameIndex][j-1];
      }  
   }
   
   m_Main[TimeFrameIndex][0] = NormalizeDouble(((m_Indicators.GetBands().GetMain(TimeFrameIndex, 0)
                                                +m_Indicators.GetIchimoku().GetKijunSen(TimeFrameIndex,0)
                                                +m_Indicators.GetIchimoku().GetTenkanSen(TimeFrameIndex, 0))/3), _Digits);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Middleline::GetUpper(int TimeFrameIndex,int Shift,float Multiplier=1.0)
{
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
   }
     
   double atr = m_Indicators.GetATR().GetATRValue(TimeFrameIndex, Shift);
   
   return NormalizeDouble(m_Main[TimeFrameIndex][Shift]+Multiplier*atr, _Digits);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Middleline::GetLower(int TimeFrameIndex,int Shift,float Multiplier=1.0)
{
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
   }
     
   double atr = m_Indicators.GetATR().GetATRValue(TimeFrameIndex, Shift);
   
   return NormalizeDouble(m_Main[TimeFrameIndex][Shift]-Multiplier*atr, _Digits);
   
}

//+------------------------------------------------------------------+