//+------------------------------------------------------------------+
//|                                             IndicatorsHelper.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\ADX.mqh"
#include "..\iForexDNA\STO.mqh"
#include "..\iForexDNA\Bands.mqh"
#include "..\iForexDNA\RSI.mqh"
#include "..\iForexDNA\MACD.mqh"
#include "..\iForexDNA\Momentum.mqh"
#include "..\iForexDNA\ATR.mqh"
#include "..\iForexDNA\KeltnerChannel.mqh"
#include "..\iForexDNA\OnBalance.mqh"
#include "..\iForexDNA\VolumeIndicator.mqh"
#include "..\iForexDNA\RVI.mqh"
#include "..\iForexDNA\BullBearPower.mqh"
#include "..\iForexDNA\ForceIndex.mqh"
#include "..\iForexDNA\CCI.mqh"
#include "..\iForexDNA\Accumulation.mqh"
#include "..\iForexDNA\MoneyFlow.mqh"
#include "..\iForexDNA\SAR.mqh"
#include "..\iForexDNA\MovingAverage.mqh"
#include "..\iForexDNA\Fractals.mqh"
#include "..\iForexDNA\Fibonacci.mqh"
#include "..\iForexDNA\Pivot.mqh"
#include "..\iForexDNA\ZigZag.mqh"
#include "..\iForexDNA\Ichimoku.mqh"
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IndicatorsHelper
  {
private:
   BaseIndicator    *m_Indicators[];

public:
                     IndicatorsHelper();
                    ~IndicatorsHelper();

   bool              Init();
   void              OnDeInit();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   ADX              *GetADX();
   STO              *GetSTO();
   Bands            *GetBands();
   RSI              *GetRSI();
   MACD             *GetMACD();
   Momentum         *GetMomentum();
   ATR              *GetATR();
   KeltnerChannel   *GetKeltner();
   VolumeIndicator  *GetVolumeIndicator();
   Accumulation     *GetAccumulation();
   MoneyFlow        *GetMoneyFlow();
   OnBalance        *GetOnBalance();
   CCI              *GetCCI();
   ForceIndex       *GetForceIndex();
   BullBearPower    *GetBullBearPower();  
   RVI              *GetRVI();
   
   SAR              *GetSAR();
   MovingAverage    *GetMovingAverage();
   ZigZag           *GetZigZag();
   Fractal          *GetFractal();
   Fibonacci        *GetFibonacci();
   Pivot            *GetPivot();

   Ichimoku         *GetIchimoku();  
   CandleStick      *GetCS();

   double            GetBodyCS(int TimeFrameIndex,int Shift);
   double            GetBodyCSPercent(int TimeFrameIndex,int Shift);
   double            GetTopWickCSPercent(int TimeFrameIndex,int Shift);
   double            GetLowWickCSPercent(int TimeFrameIndex,int Shift);
   double            GetHighLowCSPips(int TimeFrameIndex,int Shift);
   double            GetBodyCSPips(int TimeFrameIndex,int Shift);
   double            GetTopWickCSPips(int TimeFrameIndex,int Shift);
   double            GetLowWickCSPips(int TimeFrameIndex,int Shift);

   double            GetHighLowCSATRPercent(int TimeFrameIndex,int Shift);
   double            GetBodyCSATRPercent(int TimeFrameIndex,int Shift);
   double            GetTopWickCSATRPercent(int TimeFrameIndex,int Shift);
   double            GetLowWickCSATRPercent(int TimeFrameIndex,int Shift);
   
   string            CalculateCSBlendedSinglePattern(int TimeFrameIndex,int NumberOfBars, int Shift);

   double            GetBodyCSATRMaxPercent(int TimeFrameIndex,int Shift);
   double            GetBodyCSATRMinPercent(int TimeFrameIndex,int Shift);
private:
   
   bool              AddIndicatorToArray(BaseIndicator *Indicator);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IndicatorsHelper::IndicatorsHelper()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IndicatorsHelper::~IndicatorsHelper()
  {
   OnDeInit();
  }
//+------------------------------------------------------------------+
bool IndicatorsHelper::Init()
  {

   if(!AddIndicatorToArray(new ADX())
      || !AddIndicatorToArray(new STO())
      || !AddIndicatorToArray(new Bands())
      || !AddIndicatorToArray(new RSI())
      || !AddIndicatorToArray(new MACD())
      || !AddIndicatorToArray(new Momentum())
      || !AddIndicatorToArray(new ATR())
      || !AddIndicatorToArray(new KeltnerChannel())
      || !AddIndicatorToArray(new Ichimoku())
      || !AddIndicatorToArray(new VolumeIndicator())
      || !AddIndicatorToArray(new OnBalance())
      || !AddIndicatorToArray(new MoneyFlow())
      || !AddIndicatorToArray(new Accumulation())
      || !AddIndicatorToArray(new RVI())
      || !AddIndicatorToArray(new CCI())
      || !AddIndicatorToArray(new BullBearPower())
      || !AddIndicatorToArray(new ForceIndex()) 
      || !AddIndicatorToArray(new SAR())
      || !AddIndicatorToArray(new MovingAverage())
      || !AddIndicatorToArray(new ZigZag())
      || !AddIndicatorToArray(new Fractal())
      || !AddIndicatorToArray(new Fibonacci(GetZigZag()))
      || !AddIndicatorToArray(new Pivot())
      )
      return false;

   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      if(i<0 || i>=arraySize)
        {
         LogError(__FUNCTION__,"Indicators array out of sync.");
         return false;
        }
      string s=typename(m_Indicators[i]);
      if(!m_Indicators[i].Init())
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorsHelper::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   int arraySize=ArraySize(m_Indicators);
   
   for(int i =0; i < arraySize; i++)
   {
      m_Indicators[i].OnUpdate(TimeFrameIndex, IsNewBar);
   }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ADX *IndicatorsHelper::GetADX()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      ADX *pRes=dynamic_cast<ADX *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

STO *IndicatorsHelper::GetSTO()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      STO *pRes=dynamic_cast<STO *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Bands *IndicatorsHelper::GetBands()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      Bands *pRes=dynamic_cast<Bands *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
RSI *IndicatorsHelper::GetRSI()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      RSI *pRes=dynamic_cast<RSI *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MACD *IndicatorsHelper::GetMACD()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      MACD *pRes=dynamic_cast<MACD *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Momentum *IndicatorsHelper::GetMomentum()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      Momentum *pRes=dynamic_cast<Momentum *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ATR *IndicatorsHelper::GetATR()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      ATR *pRes=dynamic_cast<ATR *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

KeltnerChannel *IndicatorsHelper::GetKeltner()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      KeltnerChannel *pRes=dynamic_cast<KeltnerChannel *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
SAR *IndicatorsHelper::GetSAR()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      SAR *pRes=dynamic_cast<SAR *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MovingAverage *IndicatorsHelper::GetMovingAverage()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      MovingAverage *pRes=dynamic_cast<MovingAverage *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ForceIndex *IndicatorsHelper::GetForceIndex()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      ForceIndex *pRes=dynamic_cast<ForceIndex *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

BullBearPower *IndicatorsHelper::GetBullBearPower()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      BullBearPower *pRes=dynamic_cast<BullBearPower *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

RVI *IndicatorsHelper::GetRVI()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      RVI *pRes=dynamic_cast<RVI *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CCI *IndicatorsHelper::GetCCI()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      CCI *pRes=dynamic_cast<CCI *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Fractal *IndicatorsHelper::GetFractal()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      Fractal *pRes=dynamic_cast<Fractal *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Fibonacci *IndicatorsHelper::GetFibonacci()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      Fibonacci *pRes=dynamic_cast<Fibonacci *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Pivot *IndicatorsHelper::GetPivot()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      Pivot *pRes=dynamic_cast<Pivot *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ZigZag *IndicatorsHelper::GetZigZag()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      ZigZag *pRes=dynamic_cast<ZigZag *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku *IndicatorsHelper::GetIchimoku()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      Ichimoku *pRes=dynamic_cast<Ichimoku *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CandleStick *IndicatorsHelper::GetCS()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      CandleStick *pRes=dynamic_cast<CandleStick *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

VolumeIndicator *IndicatorsHelper::GetVolumeIndicator()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      VolumeIndicator *pRes=dynamic_cast<VolumeIndicator *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Accumulation *IndicatorsHelper::GetAccumulation()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      Accumulation *pRes=dynamic_cast<Accumulation *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

MoneyFlow *IndicatorsHelper::GetMoneyFlow()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      MoneyFlow *pRes=dynamic_cast<MoneyFlow *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OnBalance *IndicatorsHelper::GetOnBalance()
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
     {
      OnBalance *pRes=dynamic_cast<OnBalance *>(m_Indicators[i]);
      if(pRes!=NULL)
         return pRes;
     }

   LogError(__FUNCTION__,"Indicator not found.");
   return NULL;
  }

//+------------------------------------------------------------------+
//|     GetHighLowCSSize                                             |
//+------------------------------------------------------------------+
double IndicatorsHelper::GetHighLowCSPips(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE )
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }
   
   double   high = CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh();
   double   low = CandleSticksBuffer[TimeFrameIndex][Shift].GetLow();
   double   open = CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen();
   double   close = CandleSticksBuffer[TimeFrameIndex][Shift].GetClose();


   if(open > close)
      return (low - high)/_Point/10;
   else if(open < close)
      return   (high - low)/_Point/10;
   else
      return 0;
  }
//+------------------------------------------------------------------+
//|     GetBodyCSSize                                             |
//+------------------------------------------------------------------+
double IndicatorsHelper::GetBodyCSPips(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE )
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }
   
   double   open = CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen();
   double   close = CandleSticksBuffer[TimeFrameIndex][Shift].GetClose();


   if(open > close)
      return (open - close)/_Point/10;
   else if(open < close)
      return   (close - open)/_Point/10;
   else
      return 0;
  }
//+------------------------------------------------------------------+
//|     GetTopWickCSSize                                             |
//+------------------------------------------------------------------+
double IndicatorsHelper::GetTopWickCSPips(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE )
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }
   
   double   high = CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh();
   double   open = CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen();
   double   close = CandleSticksBuffer[TimeFrameIndex][Shift].GetClose();


   if(open > close)
      return (high - open)/_Point/10;
   else if(open < close)
      return   (high - close)/_Point/10;
   else
      return 0;
  }
//+------------------------------------------------------------------+
//|     GetTopWickCSSize                                             |
//+------------------------------------------------------------------+
double IndicatorsHelper::GetLowWickCSPips(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE )
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }
   
   double   low = CandleSticksBuffer[TimeFrameIndex][Shift].GetLow();
   double   open = CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen();
   double   close = CandleSticksBuffer[TimeFrameIndex][Shift].GetClose();


   if(open > close)
      return (close - low)/_Point/10;
   else if(open < close)
      return   (open - low)/_Point/10;
   else
      return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IndicatorsHelper::GetBodyCSPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE )
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }
   
   double   high = CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh();
   double   low = CandleSticksBuffer[TimeFrameIndex][Shift].GetLow();
   double   open = CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen();
   double   close = CandleSticksBuffer[TimeFrameIndex][Shift].GetClose();
   
   if(open - close == 0 || high - low == 0)
      return 0;
   
   return (close - open)/ (high - low)*100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsHelper::GetTopWickCSPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }
   
   double   high = CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh();
   double   low = CandleSticksBuffer[TimeFrameIndex][Shift].GetLow();
   double   open = CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen();
   double   close = CandleSticksBuffer[TimeFrameIndex][Shift].GetClose();
   
   if(open - close == 0 || high - low == 0)
      return 0;
   
   return MathAbs((high - MathMax(open,close))/ (high - low)*100);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsHelper::GetLowWickCSPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }

   double   high = CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh();
   double   low = CandleSticksBuffer[TimeFrameIndex][Shift].GetLow();
   double   open = CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen();
   double   close = CandleSticksBuffer[TimeFrameIndex][Shift].GetClose();
   
   if(open - close == 0 || high - low == 0)
      return 0;
   
   return MathAbs((MathMin(open,close) - low)/ (high - low)*100);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IndicatorsHelper::GetHighLowCSATRPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }

   double res=(CandleSticksBuffer[TimeFrameIndex][Shift].GetHLDiff())/GetATR().GetATRValue(TimeFrameIndex,Shift)*100;

   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsHelper::GetBodyCSATRPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }

   return (CandleSticksBuffer[TimeFrameIndex][Shift].GetRealBody())/GetATR().GetATRValue(TimeFrameIndex,Shift)*100;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsHelper::GetTopWickCSATRPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }

   return CandleSticksBuffer[TimeFrameIndex][Shift].GetTopShadow()/GetATR().GetATRValue(TimeFrameIndex,Shift)*100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsHelper::GetLowWickCSATRPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }

   return CandleSticksBuffer[TimeFrameIndex][Shift].GetBottomShadow()/GetATR().GetATRValue(TimeFrameIndex,Shift)*100;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string IndicatorsHelper::CalculateCSBlendedSinglePattern(int TimeFrameIndex,int NumberOfBars, int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return "Error";
     }

   string   res = NULL;
   
   
   // Combine/Blend CS based on number of bars
   
   double BlendedOpen = iOpen(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift+NumberOfBars);
   double BlendedClose = iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift);
   double BlendedHighest = iHighest(Symbol(), GetTimeFrameENUM(TimeFrameIndex), MODE_HIGH, NumberOfBars, Shift);
   double BlendedLowest = iLowest(Symbol(), GetTimeFrameENUM(TimeFrameIndex), MODE_LOW, NumberOfBars, Shift);
   
   GetCS().SetPrice(BlendedOpen, BlendedClose, BlendedHighest, BlendedLowest);
   
   ENUM_CANDLESTICKPATTERN SingleCSPattern =  GetCS().CalculatePattern();

   res = GetCS().GetPatternString();
   
   
   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double IndicatorsHelper::GetBodyCSATRMaxPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }

   return (CandleSticksBuffer[TimeFrameIndex][Shift].GetHigh()-CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen())/GetATR().GetATRValue(TimeFrameIndex,Shift)*100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double IndicatorsHelper::GetBodyCSATRMinPercent(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=CANDLESTICKS_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input");
      return 0;
     }

   return (CandleSticksBuffer[TimeFrameIndex][Shift].GetLow()-CandleSticksBuffer[TimeFrameIndex][Shift].GetOpen())/GetATR().GetATRValue(TimeFrameIndex,Shift)*100;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IndicatorsHelper::OnDeInit(void)
  {
   int arraySize=ArraySize(m_Indicators);
   for(int i=0; i<arraySize; i++)
      delete(m_Indicators[i]);

   ArrayFree(m_Indicators);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IndicatorsHelper::AddIndicatorToArray(BaseIndicator *Indicator)
  {
   if(CheckPointer(Indicator)==POINTER_INVALID)
     {
      LogError(__FUNCTION__,"Invalid Indicator pointer.");
      return false;
     }

   int arraySize=ArraySize(m_Indicators);

   if(ArrayResize(m_Indicators,arraySize+1)<0)
     {
      LogError(__FUNCTION__,"Array resize fail.");
      return false;
     }

   if(CheckPointer(m_Indicators[arraySize])!=POINTER_INVALID)
     {
      LogError(__FUNCTION__,"Indicators array out of sync.");
      return false;
     }

   m_Indicators[arraySize]=Indicator;
   return true;
  }
//+------------------------------------------------------------------+
