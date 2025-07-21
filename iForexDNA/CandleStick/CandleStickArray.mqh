//+------------------------------------------------------------------+
//|                                            CandleStickArray.mqh  |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\CandleStick\CandleStick.mqh"
#include "..\CandleStick\DualPattern.mqh"
#include "..\CandleStick\TriplePattern.mqh"
#include "..\hash.mqh"
#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"
#include "..\MathFunc.mqh"

#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

static CandleStick *CandleSticksBuffer[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];


class CandleStickArray{
    private: 
        int                                 m_Shift;

        ENUM_DUALCANDLESTICKPATTERN         m_DualPattern[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        ENUM_TRIPLECANDLESTICKPATTERN       m_TriplePattern[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];


        double                              m_CummUpperWick[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        double                              m_CummLowerWick[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        double                              m_CummBody[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];                              


        double                              m_CummUpperWickMean[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        double                              m_CummUpperWickStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
           
        double                              m_CummLowerWickMean[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        double                              m_CummLowerWickStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
  
        double                              m_CummBodyMean[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        double                              m_CummBodyStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        
        int                                 m_CummTopBotBias[ENUM_TIMEFRAMES_ARRAY_SIZE][CANDLESTICKS_BUFFER_SIZE];
        
        double                              m_AverageDailyPriceMovement;
  
  
        ENUM_DUALCANDLESTICKPATTERN         CalculateDualPattern(int TimeFrameIndex, int Shift);
        ENUM_TRIPLECANDLESTICKPATTERN       CalculateTriplePattern(int TimeFrameIndex, int Shift);
         
  
        void                                InitAverageDailyPriceMovement();
        void                                CalculateCummulativeCandleStick(int TimeFrameIndex, int Shift);
        void                                OnUpdateCummCSMeanStdDev(int TimeFrameIndex);
        
        bool                                SetShift(int Shift);
    
    public:
        CandleStickArray();
        ~CandleStickArray();
        bool Init();

        bool                                initCandleStickBuffer();
        void                                OnUpdate(int TimeFrameIndex, bool IsNewBar);


        double                              GetCummBodyPercent(int TimeFrameIndex, int Shift){return m_CummBody[TimeFrameIndex][Shift];};
        double                              GetCummBodyMean(int TimeFrameIndex, int Shift){return m_CummBodyMean[TimeFrameIndex][Shift];};
        double                              GetCummBodyStdDev(int TimeFrameIndex, int Shift){return m_CummBodyStdDev[TimeFrameIndex][Shift];};
        double                              GetCummBodyStdDevPos(int TimeFrameIndex, int Shift);
        
        double                              GetCummTopWickPercent(int TimeFrameIndex, int Shift){return m_CummUpperWick[TimeFrameIndex][Shift];};
        double                              GetCummTopWickMean(int TimeFrameIndex, int Shift){return m_CummUpperWickMean[TimeFrameIndex][Shift];};
        double                              GetCummTopWickStdDev(int TimeFrameIndex, int Shift){return m_CummUpperWickStdDev[TimeFrameIndex][Shift];};
        double                              GetCummTopWickStdDevPos(int TimeFrameIndex, int Shift);
       
       
        double                              GetCummBotWickPercent(int TimeFrameIndex, int Shift){return m_CummLowerWick[TimeFrameIndex][Shift];};
        double                              GetCummBotWickMean(int TimeFrameIndex, int Shift){return m_CummLowerWickMean[TimeFrameIndex][Shift];};
        double                              GetCummBotWickStdDev(int TimeFrameIndex, int Shift){return m_CummLowerWickStdDev[TimeFrameIndex][Shift];};
        double                              GetCummBotWickStdDevPos(int TimeFrameIndex, int Shift);    
        
        
        double                              GetCummBodyUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_CummBodyMean[TimeFrameIndex][Shift]+Multiplier*m_CummBodyStdDev[TimeFrameIndex][Shift];};
        double                              GetCummBodyLowerStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_CummBodyMean[TimeFrameIndex][Shift]-Multiplier*m_CummBodyStdDev[TimeFrameIndex][Shift];};

        double                              GetCummLowerWickUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_CummLowerWickMean[TimeFrameIndex][Shift]+Multiplier*m_CummLowerWickStdDev[TimeFrameIndex][Shift];};
        double                              GetCummLowerWickLowerStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_CummLowerWickMean[TimeFrameIndex][Shift]-Multiplier*m_CummLowerWickStdDev[TimeFrameIndex][Shift];};

        double                              GetCummUpperWickUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_CummUpperWickMean[TimeFrameIndex][Shift]+Multiplier*m_CummUpperWickStdDev[TimeFrameIndex][Shift];};
        double                              GetCummUpperWickLowerStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_CummUpperWickMean[TimeFrameIndex][Shift]-Multiplier*m_CummUpperWickStdDev[TimeFrameIndex][Shift];};


        double                              GetAverageDailyPriceMovement(){return m_AverageDailyPriceMovement;};
        int                                 GetCummTopBotBias(int TimeFrameIndex, int Shift){return m_CummTopBotBias[TimeFrameIndex][Shift];};


        ENUM_INDICATOR_POSITION             GetCummBodyPosition(int TimeFrameIndex, int Shift);
        ENUM_INDICATOR_POSITION             GetCummTopPosition(int TimeFrameIndex, int Shift);
        ENUM_INDICATOR_POSITION             GetCummBotPosition(int TimeFrameIndex, int Shift);
        
        
        ENUM_CANDLESTICKPATTERN             GetSingleCandleStickPattern(int TimeFrameIndex, int Shift){return CandleSticksBuffer[TimeFrameIndex][Shift].GetPattern();};
        ENUM_DUALCANDLESTICKPATTERN         GetDualCandleStickPattern(int TimeFrameIndex, int Shift){return m_DualPattern[TimeFrameIndex][Shift];};
        ENUM_TRIPLECANDLESTICKPATTERN       GetTripleCandleStickPattern(int TimeFrameIndex, int Shift){return m_TriplePattern[TimeFrameIndex][Shift];};

};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CandleStickArray::CandleStickArray()
{
   ArrayInitialize(m_CummBody, 0);
   ArrayInitialize(m_CummBodyMean, 0);
   ArrayInitialize(m_CummBodyStdDev, 0);

   ArrayInitialize(m_CummLowerWick, 0);
   ArrayInitialize(m_CummLowerWickMean, 0);
   ArrayInitialize(m_CummLowerWickStdDev, 0);
   
   ArrayInitialize(m_CummUpperWick, 0);
   ArrayInitialize(m_CummUpperWickMean, 0);
   ArrayInitialize(m_CummUpperWickStdDev, 0);
   
   ArrayInitialize(m_CummTopBotBias, NEUTRAL);
}

//+------------------------------------------------------------------+
//|                         clear buffer                             |
//+------------------------------------------------------------------+

CandleStickArray::~CandleStickArray(){
   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++){
      for(int j=0; j<CANDLESTICKS_BUFFER_SIZE; j++){
         delete(CandleSticksBuffer[i][j]);
         CandleSticksBuffer[i][j] = NULL;
      }
    }
     
    ArrayRemove(CandleSticksBuffer, 0);
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStickArray::initCandleStickBuffer(){
  if(ArraySize(EnumTimeFramesArray)!=ENUM_TIMEFRAMES_ARRAY_SIZE){
    LogError(__FUNCTION__,"TimeFrame Array size out of sync .");
    return false;
  }

  if(!SetShift(CANDLESTICK_SHIFT))
  {
    LogError(__FUNCTION__, "Shift below 0...");
    return false;
  }
    
 
  if(CandleSticksBuffer[ENUM_TIMEFRAMES_ARRAY_SIZE-1][CANDLESTICKS_BUFFER_SIZE-1] != NULL)
  {
    Print("CandleStickBuffer is already initialized...");
    return true;
  }

  for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
  {
    ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);
  
    for(int j = 0; j < CANDLESTICKS_BUFFER_SIZE; j++)
    {
      // initialized candlestick + add into candlestick Buffer
      CandleSticksBuffer[i][j] = new CandleStick(timeFrameENUM, j+m_Shift);
    }
  }
  return true; 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStickArray::Init()
{
    // true if candlestick buffer not init yet
    if(!initCandleStickBuffer())
        return false;

   for(int i=0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      double tempBodyArray[CANDLESTICKS_BUFFER_SIZE];
      double tempTopWickArray[CANDLESTICKS_BUFFER_SIZE];
      double tempBottomWickArray[CANDLESTICKS_BUFFER_SIZE];
      
      ArrayInitialize(tempBodyArray, 0);
      ArrayInitialize(tempTopWickArray, 0);
      ArrayInitialize(tempBottomWickArray, 0);
   
      for(int j=CANDLESTICKS_BUFFER_SIZE-1;j>=0; j--)
      {
         if(j+CANDLESTICK_CUMMULATIVE_COUNT >= CANDLESTICKS_BUFFER_SIZE)
            continue;
            
         CalculateCummulativeCandleStick(i,j);   
         m_CummTopBotBias[i][j] = m_CummUpperWick[i][j] > m_CummLowerWick[i][j] ? BEAR_TRIGGER : BULL_TRIGGER;
         
         tempBodyArray[j]=m_CummBody[i][j];
         tempBottomWickArray[j]=m_CummLowerWick[i][j];
         tempTopWickArray[j]=m_CummUpperWick[i][j];
         
         
         if(j+CANDLESTICK_PERIOD+CANDLESTICK_CUMMULATIVE_COUNT < CANDLESTICKS_BUFFER_SIZE)
         {         
            m_CummBodyMean[i][j]=NormalizeDouble(MathMean(tempBodyArray, j, CANDLESTICK_PERIOD), 2);
            m_CummBodyStdDev[i][j]=NormalizeDouble(MathStandardDeviation(tempBodyArray, j, CANDLESTICK_PERIOD),2);
            
            m_CummLowerWickMean[i][j]=NormalizeDouble(MathMean(tempBottomWickArray, j, CANDLESTICK_PERIOD),2);
            m_CummLowerWickStdDev[i][j]=NormalizeDouble(MathStandardDeviation(tempBottomWickArray, j, CANDLESTICK_PERIOD),2);

            m_CummUpperWickMean[i][j]=NormalizeDouble(MathMean(tempTopWickArray, j, CANDLESTICK_PERIOD),2);
            m_CummUpperWickStdDev[i][j]=NormalizeDouble(MathStandardDeviation(tempTopWickArray, j, CANDLESTICK_PERIOD),2);
         }
         
         // Pattern Recognitions
         if(i + 1 < CANDLESTICKS_BUFFER_SIZE)
            m_DualPattern[i][j] = CalculateDualPattern(i, j);
         
         if(i + 2 < CANDLESTICKS_BUFFER_SIZE)
            m_TriplePattern[i][j] = CalculateTriplePattern(i, j);
           
      }
   }
   
   InitAverageDailyPriceMovement();          // Update the daily price movement based on previous 3 days 
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CandleStickArray::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE)
   {
      ASSERT("Invalid TimeFrame Index...", __FUNCTION__);
      return;
   }

  
   if(IsNewBar)
   {
      CandleSticksBuffer[TimeFrameIndex][0].OnUpdate(1);
      
       delete CandleSticksBuffer[TimeFrameIndex][CANDLESTICKS_BUFFER_SIZE-1];
       CandleSticksBuffer[TimeFrameIndex][CANDLESTICKS_BUFFER_SIZE-1] = NULL;
   
      for(int j=CANDLESTICKS_BUFFER_SIZE-1; j>0;j--)
      {
         CandleSticksBuffer[TimeFrameIndex][j]=CandleSticksBuffer[TimeFrameIndex][j-1];
         
         m_DualPattern[TimeFrameIndex][j] = m_DualPattern[TimeFrameIndex][j-1];
         m_TriplePattern[TimeFrameIndex][j] = m_TriplePattern[TimeFrameIndex][j-1];
      
         m_CummBody[TimeFrameIndex][j] = m_CummBody[TimeFrameIndex][j-1];
         m_CummBodyMean[TimeFrameIndex][j] = m_CummBodyMean[TimeFrameIndex][j-1];
         m_CummBodyStdDev[TimeFrameIndex][j] = m_CummBodyStdDev[TimeFrameIndex][j-1];    
         
         m_CummLowerWick[TimeFrameIndex][j] = m_CummLowerWick[TimeFrameIndex][j-1];
         m_CummLowerWickMean[TimeFrameIndex][j] = m_CummLowerWickMean[TimeFrameIndex][j-1];
         m_CummLowerWickStdDev[TimeFrameIndex][j] = m_CummLowerWickStdDev[TimeFrameIndex][j-1];    
         
         m_CummUpperWick[TimeFrameIndex][j] = m_CummUpperWick[TimeFrameIndex][j-1];
         m_CummUpperWickMean[TimeFrameIndex][j] = m_CummUpperWickMean[TimeFrameIndex][j-1];
         m_CummUpperWickStdDev[TimeFrameIndex][j] = m_CummUpperWickStdDev[TimeFrameIndex][j-1];    
         
         m_CummTopBotBias[TimeFrameIndex][j] = m_CummTopBotBias[TimeFrameIndex][j-1];
      }

      CandleSticksBuffer[TimeFrameIndex][0] = new CandleStick(GetTimeFrameENUM(TimeFrameIndex), m_Shift);
   
      // Update Average Daily Price Movement once a day 
      if(GetTimeFrameENUM(TimeFrameIndex) == PERIOD_D1)
         InitAverageDailyPriceMovement();

   }
   
   CandleSticksBuffer[TimeFrameIndex][0].OnUpdate(0);
   m_DualPattern[TimeFrameIndex][0] = CalculateDualPattern(TimeFrameIndex, m_Shift);
   m_TriplePattern[TimeFrameIndex][0] = CalculateTriplePattern(TimeFrameIndex, m_Shift);
   CalculateCummulativeCandleStick(TimeFrameIndex, m_Shift);
   m_CummTopBotBias[TimeFrameIndex][0] = m_CummUpperWick[TimeFrameIndex][0] > m_CummLowerWick[TimeFrameIndex][0] ? BEAR_TRIGGER : BULL_TRIGGER;
   OnUpdateCummCSMeanStdDev(TimeFrameIndex);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CandleStickArray::CalculateCummulativeCandleStick(int TimeFrameIndex,int Shift)
{
   m_CummBody[TimeFrameIndex][Shift]=0;
   m_CummLowerWick[TimeFrameIndex][Shift]=0;
   m_CummUpperWick[TimeFrameIndex][Shift]=0;

   double topwick=0, bottomwick=0, body=0, csheight=0;

   for(int i =0; i < CANDLESTICK_CUMMULATIVE_COUNT; i++)
   {   
      topwick+=CandleSticksBuffer[TimeFrameIndex][Shift+i].GetTopShadow();
      bottomwick+=CandleSticksBuffer[TimeFrameIndex][Shift+i].GetBottomShadow();
      body+=CandleSticksBuffer[TimeFrameIndex][Shift+i].GetRealBody();
      csheight+=CandleSticksBuffer[TimeFrameIndex][Shift+i].GetHLDiff();
   }
   
   if(csheight<=0)
      return;
   
   m_CummBody[TimeFrameIndex][Shift]=NormalizeDouble((body/csheight)*100, 2);
   m_CummLowerWick[TimeFrameIndex][Shift]=NormalizeDouble((bottomwick/csheight)*100, 2);
   m_CummUpperWick[TimeFrameIndex][Shift]=NormalizeDouble((topwick/csheight)*100, 2);    
 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CandleStickArray::OnUpdateCummCSMeanStdDev(int TimeFrameIndex)
{
   double cummBodyArray[CANDLESTICK_PERIOD];
   double cummLowerWickArray[CANDLESTICK_PERIOD];
   double cummUpperWickArray[CANDLESTICK_PERIOD];
   

   for(int i =0; i < CANDLESTICK_PERIOD; i++)
   {
      cummBodyArray[i]=m_CummBody[TimeFrameIndex][i];
      cummLowerWickArray[i]=m_CummLowerWick[TimeFrameIndex][i];
      cummUpperWickArray[i]=m_CummUpperWick[TimeFrameIndex][i];
   }


   m_CummBodyMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(cummBodyArray, 0, CANDLESTICK_PERIOD), 2);
   m_CummBodyStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(cummBodyArray, 0, CANDLESTICK_PERIOD), 2);
   
   m_CummLowerWickMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(cummLowerWickArray, 0, CANDLESTICK_PERIOD), 2);
   m_CummLowerWickStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(cummLowerWickArray, 0, CANDLESTICK_PERIOD), 2);
  
   m_CummUpperWickMean[TimeFrameIndex][0]=NormalizeDouble(MathMean(cummUpperWickArray, 0, CANDLESTICK_PERIOD), 2);
   m_CummUpperWickStdDev[TimeFrameIndex][0]=NormalizeDouble(MathStandardDeviation(cummUpperWickArray, 0, CANDLESTICK_PERIOD), 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_DUALCANDLESTICKPATTERN CandleStickArray::CalculateDualPattern(int TimeFrameIndex,int Shift)
{
    if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || (Shift+1) >= CANDLESTICKS_BUFFER_SIZE){
        LogError(__FUNCTION__, "Out of sync Array size...");
        return NADualPattern;
    }

    if(CandleSticksBuffer[TimeFrameIndex][Shift] == NULL || CandleSticksBuffer[TimeFrameIndex][Shift+1] == NULL){
        LogError(__FUNCTION__, "NULL Pointer in CandleStick Buffer.");
        return NADualPattern;
    }
    

    DualPattern dualPatternObject(CandleSticksBuffer[TimeFrameIndex][Shift+1], CandleSticksBuffer[TimeFrameIndex][Shift]);
    ENUM_DUALCANDLESTICKPATTERN dualPattern = dualPatternObject.IdentifyDualPattern();
    
    return dualPattern;
    
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_TRIPLECANDLESTICKPATTERN CandleStickArray::CalculateTriplePattern(int TimeFrameIndex,int Shift)
{

    if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE || Shift < 0 || (Shift+2) >= CANDLESTICKS_BUFFER_SIZE){
        LogError(__FUNCTION__, "Out of sync Array size...");
        return NATriplePattern;
    }

    if(CandleSticksBuffer[TimeFrameIndex][Shift] == NULL || CandleSticksBuffer[TimeFrameIndex][Shift+1] == NULL || CandleSticksBuffer[TimeFrameIndex][Shift+2] == NULL){
        LogError(__FUNCTION__, "NULL Pointer in CandleStick Buffer.");
        return NATriplePattern;
    }

    TriplePattern triplePatternObject(CandleSticksBuffer[TimeFrameIndex][Shift+2], CandleSticksBuffer[TimeFrameIndex][Shift+1], CandleSticksBuffer[TimeFrameIndex][Shift]);
    ENUM_TRIPLECANDLESTICKPATTERN triplePattern = triplePatternObject.IdentifyTriplePattern();
   
    return triplePattern;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandleStickArray::GetCummBodyStdDevPos(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE 
   || Shift < 0 || Shift >= CANDLESTICKS_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "CandleStick Shift out of range...");
      return -1;
   }
   
   
   return m_CummBodyStdDev[TimeFrameIndex][Shift]!=0 ? (m_CummBody[TimeFrameIndex][Shift]-m_CummBodyMean[TimeFrameIndex][Shift])/m_CummBodyStdDev[TimeFrameIndex][Shift]: 0;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandleStickArray::GetCummTopWickStdDevPos(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE 
   || Shift < 0 || Shift >= CANDLESTICKS_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "CandleStick Shift out of range...");
      return -1;
   }
   
   
   return m_CummUpperWickStdDev[TimeFrameIndex][Shift]!=0 ? (m_CummUpperWick[TimeFrameIndex][Shift]-m_CummUpperWickMean[TimeFrameIndex][Shift])/m_CummUpperWickStdDev[TimeFrameIndex][Shift] : 0;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandleStickArray::GetCummBotWickStdDevPos(int TimeFrameIndex,int Shift)
{
   if(TimeFrameIndex < 0 || TimeFrameIndex >= ENUM_TIMEFRAMES_ARRAY_SIZE 
   || Shift < 0 || Shift >= CANDLESTICKS_BUFFER_SIZE)
   {
      LogError(__FUNCTION__, "CandleStick Shift out of range...");
      return -1;
   }
   
   
   return m_CummLowerWickStdDev[TimeFrameIndex][Shift]!=0 ? (m_CummLowerWick[TimeFrameIndex][Shift]-m_CummLowerWickMean[TimeFrameIndex][Shift])/m_CummLowerWickStdDev[TimeFrameIndex][Shift]: 0;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION CandleStickArray::GetCummBodyPosition(int TimeFrameIndex,int Shift)
{
   if(m_CummBodyMean[TimeFrameIndex][Shift] == 0 || m_CummBodyStdDev[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_CummBody[TimeFrameIndex][Shift] > GetCummBodyUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_CummBody[TimeFrameIndex][Shift] > GetCummBodyUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_CummBody[TimeFrameIndex][Shift] > m_CummBodyMean[TimeFrameIndex][Shift] && m_CummBody[TimeFrameIndex][Shift] < GetCummBodyUpperStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
   
   else if(m_CummBody[TimeFrameIndex][Shift] == m_CummBodyMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_CummBody[TimeFrameIndex][Shift] < m_CummBodyMean[TimeFrameIndex][Shift] && m_CummBody[TimeFrameIndex][Shift] > GetCummBodyLowerStdDev(TimeFrameIndex, Shift, 2))
      return Below_Mean;
      
   else if(m_CummBody[TimeFrameIndex][Shift] < GetCummBodyLowerStdDev(TimeFrameIndex, Shift, 2))
      return Minus_2_StdDev;
      
   else if(m_CummBody[TimeFrameIndex][Shift] < GetCummBodyLowerStdDev(TimeFrameIndex, Shift, 3))
      return Minus_3_StdDev;

   else
      return Null;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION CandleStickArray::GetCummTopPosition(int TimeFrameIndex,int Shift)
{
   if(m_CummUpperWickMean[TimeFrameIndex][Shift] == 0 || m_CummUpperWickStdDev[TimeFrameIndex][Shift] == 0)
      return Null;
   
   else if(m_CummUpperWick[TimeFrameIndex][Shift] > GetCummUpperWickUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_CummUpperWick[TimeFrameIndex][Shift] > GetCummUpperWickUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_CummUpperWick[TimeFrameIndex][Shift] > m_CummUpperWickMean[TimeFrameIndex][Shift] && m_CummUpperWick[TimeFrameIndex][Shift] < GetCummUpperWickUpperStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
   
   else if(m_CummUpperWick[TimeFrameIndex][Shift] == m_CummUpperWickMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_CummUpperWick[TimeFrameIndex][Shift] < m_CummUpperWickMean[TimeFrameIndex][Shift] && m_CummUpperWick[TimeFrameIndex][Shift] > GetCummUpperWickLowerStdDev(TimeFrameIndex, Shift, 2))
      return Below_Mean;
      
   else if(m_CummUpperWick[TimeFrameIndex][Shift] < GetCummUpperWickLowerStdDev(TimeFrameIndex, Shift, 2))
      return Minus_2_StdDev;
      
   else if(m_CummUpperWick[TimeFrameIndex][Shift] < GetCummUpperWickLowerStdDev(TimeFrameIndex, Shift, 3))
      return Minus_3_StdDev;

   else
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION CandleStickArray::GetCummBotPosition(int TimeFrameIndex,int Shift)
{
   if(m_CummLowerWickMean[TimeFrameIndex][Shift] == 0 || m_CummLowerWickStdDev[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_CummLowerWick[TimeFrameIndex][Shift] > GetCummLowerWickUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_CummLowerWick[TimeFrameIndex][Shift] > GetCummLowerWickUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_CummLowerWick[TimeFrameIndex][Shift] > m_CummLowerWickMean[TimeFrameIndex][Shift] && m_CummLowerWick[TimeFrameIndex][Shift] < GetCummLowerWickUpperStdDev(TimeFrameIndex, Shift, 2))
      return Above_Mean;
   
   else if(m_CummLowerWick[TimeFrameIndex][Shift] == m_CummLowerWickMean[TimeFrameIndex][Shift])
      return Equal_Mean;
   
   else if(m_CummLowerWick[TimeFrameIndex][Shift] < m_CummLowerWickMean[TimeFrameIndex][Shift] && m_CummLowerWick[TimeFrameIndex][Shift] > GetCummLowerWickLowerStdDev(TimeFrameIndex, Shift, 2))
      return Below_Mean;
      
   else if(m_CummLowerWick[TimeFrameIndex][Shift] < GetCummLowerWickLowerStdDev(TimeFrameIndex, Shift, 2))
      return Minus_2_StdDev;
      
   else if(m_CummLowerWick[TimeFrameIndex][Shift] < GetCummLowerWickLowerStdDev(TimeFrameIndex, Shift, 3))
      return Minus_3_StdDev;

   else
      return Null;
      
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CandleStickArray::InitAverageDailyPriceMovement()
{
   // Get daily period
   int TimeFrameIndex = GetTimeFrameIndex(PERIOD_D1);

   // 3 HL Price movement from daily candle
   m_AverageDailyPriceMovement = NormalizeDouble((CandleSticksBuffer[TimeFrameIndex][1].GetHLDiff() + CandleSticksBuffer[TimeFrameIndex][2].GetHLDiff() + CandleSticksBuffer[TimeFrameIndex][3].GetHLDiff())/3, _Digits);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStickArray::SetShift(int Shift){
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
template<typename T>
string GetCSPatternString(const T t)
  {
   string typeOfT=typename(t);

   string res;

   if(typeOfT=="ENUM_CANDLESTICKPATTERN")
     {
      if(t<0 || t>=sizeof(EnumPatternStrings))
        {
         ASSERT("Array out of Sync",__FUNCTION__);
         return EnumPatternStrings[0];
        }

      res=EnumPatternStrings[t];
     }
   else if(typeOfT=="ENUM_DUALCANDLESTICKPATTERN")
     {
      if(t<0 || t>=sizeof(EnumDualPatternStrings))
        {
         ASSERT("Array out of Sync",__FUNCTION__);
         return EnumDualPatternStrings[0];
        }

      res=EnumDualPatternStrings[t];
     }
   else if(typeOfT=="ENUM_TRIPLECANDLESTICKPATTERN")
     {
      if(t<0 || t>=sizeof(EnumTriplePatternStrings))
        {
         ASSERT("Array out of Sync",__FUNCTION__);
         return EnumTriplePatternStrings[0];
        }

      res=EnumTriplePatternStrings[t];
     }
   else
     {
      LogError(__FUNCTION__,"Type of ENUM pattern is not supported.");
     }

   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetPatternColorSingle(ENUM_CANDLESTICKPATTERN p)
  {
   color res=DEFAULT_TXT_COLOR;

   if(p==WhiteMarubozu || p==DragonflyDoji || p==Hammer || p==InvertedHammer)
      res=BULL_COLOR;
   else if(p==BlackMarubozu || p==GravestoneDoji || p==HangingMan || p==ShootingStar)
      res=BEAR_COLOR;
   else if(p == SpinningTops || p == Doji || p == FourPriceDoji || p == LongLeggedDoji)
      res=NEUTRAL_COLOR;

   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetPatternColorDual(ENUM_DUALCANDLESTICKPATTERN p)
  {
   color res=DEFAULT_TXT_COLOR;

   if(p==BullishEngulfing || p==TweezerBottoms || p==BullishPiercingLine || p==BullishKicking || p==BullishHarami || p==BullishWindow || p==BullishMeeting || p==MatchingLow || p==BullishSeperate)
      res=BULL_COLOR;
   else if(p==BearishEngulfing || p==TweezerTops || p==BearishPiercingLine || p==BearishKicking || p==BearishHarami || p ==BearishWindow || p==BearishMeeting || p==MatchingHigh || p==BearishSeperate)
      res=BEAR_COLOR;

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetPatternColorTriple(ENUM_TRIPLECANDLESTICKPATTERN p)
  {
   color res=DEFAULT_TXT_COLOR;

   if(p==MorningStar || p==ThreeWhiteSoldiers || p==ThreeInsideUp || p==ThreeOutsideUp || p==UpsideTasukiGap)
      res=BULL_COLOR;
   else if(p==EveningStar || p==ThreeBlackSoldiers || p==ThreeInsideDown || p==ThreeOutsideDown || p==DownsideTasukiGap)
      res=BEAR_COLOR;

   return res;
  }