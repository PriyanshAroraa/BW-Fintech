//+------------------------------------------------------------------+
//|                                                        Bands.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"
#include "..\iForexDNA\MathFunc.mqh"



int BANDS_DEVIATION_LEVELS[BANDS_DEVIATION_SIZE]={1,2,3,4,5};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Bands:public BaseIndicator
  {
private:
   int               m_Shift;
   int               m_Period;
   double            m_Deviation;
   ENUM_APPLIED_PRICE m_AppliedPrice;
   int               m_MAPeriod;
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

   double            m_Main[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_Upper[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE][BANDS_DEVIATION_SIZE];
   double            m_Lower[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE][BANDS_DEVIATION_SIZE];
   
   double            m_MaxBollingerBandPosition[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_MinBollingerBandPosition[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];

   ENUM_QUADRANT     m_Band_Bias[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];

public:
                     Bands();
                    ~Bands();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetMain(int TimeFrameIndex,int Shift);
   double            GetUpper(int TimeFrameIndex,int DeviationLevel,int Shift);
   double            GetLower(int TimeFrameIndex,int DeviationLevel,int Shift);
   
   double            GetBandSize(int TimeFrameIndex,int Deviation,int Shift);
   double            GetBandStdDev(int TimeFrameIndex, int Deviation, int Shift);

   double            GetBandStdDevPosition(int TimeFrameIndex, int Shift);
                     
   double            GetBandMaxStdDevPosition(int TimeFrameIndex, int Shift){return m_MaxBollingerBandPosition[TimeFrameIndex][Shift];};
   double            GetBandMinStdDevPosition(int TimeFrameIndex, int Shift){return m_MinBollingerBandPosition[TimeFrameIndex][Shift];};


   ENUM_QUADRANT     GetBandBias(int TimeFrameIndex, int Shift){ return m_Band_Bias[TimeFrameIndex][Shift];};


   double                                 CalculateBandsMain(ENUM_TIMEFRAMES TimeFrameENUM, int Shift);
   ENUM_INDICATOR_POSITION                GetPricePosition(int TimeFrameIndex, int Shift);
   
   
private:
   bool              SetShift(int Shift);
   bool              SetPeriod(int BandsPeriod);
   bool              SetDeviation(double Deviation);
   bool              SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice);
   bool              SetMAPeriod(int MAPeriod);
   bool              SetMAMethod(ENUM_MA_METHOD MAMethod);

   int               GetDeviationLevel(int DeviationIndex);
   int               GetDeviationIndex(int DeviationLevel);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Bands::Bands():BaseIndicator("Bands"){

}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Bands::~Bands()
{
   ArrayRemove(m_Main, 0);
   ArrayRemove(m_Upper, 0);
   ArrayRemove(m_Lower, 0);
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Bands::Init()
{
   m_Shift=-1;
   m_Period=-1;
   m_Deviation=-1;
   m_AppliedPrice=-1;
   m_MAPeriod=-1;

   if(!SetShift(DEFAULT_SHIFT)
      || !SetPeriod(BANDS_PERIOD)
      || !SetDeviation(BANDS_DEVIATION)
      || !SetAppliedPrice(APPLIED_PRICE)
      || !SetMAPeriod(BANDS_MA_PERIOD))
      return false;

   ArrayInitialize(m_Main,-1);
   ArrayInitialize(m_Upper,-1);
   ArrayInitialize(m_Lower,-1);
   ArrayInitialize(m_Band_Bias, UNKNOWN);
   
   
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {      
      ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);
      
      m_Handlers[i] = iBands(Symbol(), timeFrameENUM, m_Period, m_Shift, m_Deviation, m_AppliedPrice);
      
      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize Bands handlers.");
         return false;
      }
      
      for(int j = 0; j < DEFAULT_BUFFER_SIZE; j++)
      {
         m_Main[i][j] = GetBands(m_Handlers[i],MODE_MAIN,j+m_Shift);
         
         for(int d = 0; d < BANDS_DEVIATION_SIZE; d++)
         {
            int deviationLevel = GetDeviationLevel(d);
            
            if(deviationLevel < 0)
               return false;
               
            m_Upper[i][j][d] = GetBands(m_Handlers[i],MODE_UPPER,j+m_Shift);
            m_Lower[i][j][d] = GetBands(m_Handlers[i],MODE_LOWER,j+m_Shift);
         }
         
         double std = m_Upper[i][j][0]-m_Main[i][j];
         
         m_MaxBollingerBandPosition[i][j]=((iHigh(Symbol(), timeFrameENUM, j)-m_Main[i][j])/std);
         m_MinBollingerBandPosition[i][j]=((iLow(Symbol(), timeFrameENUM, j)-m_Main[i][j])/std);
                  
      
         // Calculate Band Bias
         int Band_Bias_Upper_Quadrant = 0;
         int Band_Bias_Lower_Quadrant = 0;
         
         for(int k = 0; k < DEFAULT_BUFFER_SIZE/2; k++)
         {
            double   curr_close_price = iClose(Symbol(), timeFrameENUM, m_Shift+j+k);
            double   Plus_1X_StdDev_Price = GetBands(m_Handlers[i],MODE_UPPER,m_Shift+j+k);
            double   Minus_1X_StdDev_Price = GetBands(m_Handlers[i],MODE_LOWER,m_Shift+j+k);
            
            if(curr_close_price > Plus_1X_StdDev_Price)
               Band_Bias_Upper_Quadrant++;
            else if(curr_close_price < Minus_1X_StdDev_Price)
               Band_Bias_Lower_Quadrant++;
         }  // k loop
         
                
            if(Band_Bias_Upper_Quadrant > Band_Bias_Lower_Quadrant && Band_Bias_Upper_Quadrant > m_MAPeriod/2)      
               m_Band_Bias[i][j] = UPPER_QUADRANT;
            else if(Band_Bias_Upper_Quadrant < Band_Bias_Lower_Quadrant && Band_Bias_Lower_Quadrant > m_MAPeriod/2)     
               m_Band_Bias[i][j] = LOWER_QUADRANT; 
            else
               m_Band_Bias[i][j] = FULL_QUADRANT;   
      }      
   
   }
   
   return true;
   
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Bands::OnUpdate(int TimeFrameIndex,bool IsNewBar)
{
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid function input",__FUNCTION__);
      return;
      
   }
   
   if(IsNewBar)
   {
      for(int j = DEFAULT_BUFFER_SIZE-1; j>0; j--)
      {
         m_Main[TimeFrameIndex][j] = m_Main[TimeFrameIndex][j-1];
         m_MaxBollingerBandPosition[TimeFrameIndex][j]=m_MaxBollingerBandPosition[TimeFrameIndex][j-1];
         m_MinBollingerBandPosition[TimeFrameIndex][j]=m_MinBollingerBandPosition[TimeFrameIndex][j-1];
         m_Band_Bias[TimeFrameIndex][j] = m_Band_Bias[TimeFrameIndex][j-1];
         
         
         for(int d = 0; d < BANDS_DEVIATION_SIZE; d++)
         {
            int deviationLevel=GetDeviationLevel(d);
            if(deviationLevel<0)
               return;
               
            m_Upper[TimeFrameIndex][j][d]=m_Upper[TimeFrameIndex][j-1][d];
            m_Lower[TimeFrameIndex][j][d]=m_Lower[TimeFrameIndex][j-1][d];            
         }
      }
      
      m_MaxBollingerBandPosition[TimeFrameIndex][0]=-100000;
      m_MinBollingerBandPosition[TimeFrameIndex][0]=100000;
      
   }
   
   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);
   
   m_Main[TimeFrameIndex][0]=GetBands(m_Handlers[TimeFrameIndex],MODE_MAIN,m_Shift);

   
   // update upper and lower
   for(int d=0; d<BANDS_DEVIATION_SIZE; d++)
   {
      int deviationLevel=GetDeviationLevel(d);
      
      if(deviationLevel<0)
         return;
         
      m_Upper[TimeFrameIndex][0][d]=GetBands(m_Handlers[TimeFrameIndex],MODE_UPPER,m_Shift);
      m_Lower[TimeFrameIndex][0][d]=GetBands(m_Handlers[TimeFrameIndex],MODE_LOWER,m_Shift);      
   }
   
   // update max/min 
   double stdpos = GetBandStdDevPosition(TimeFrameIndex,0);
   m_MaxBollingerBandPosition[TimeFrameIndex][0]=MathMax(m_MaxBollingerBandPosition[TimeFrameIndex][0], stdpos);
   m_MinBollingerBandPosition[TimeFrameIndex][0]=MathMin(m_MinBollingerBandPosition[TimeFrameIndex][0], stdpos);


   // Calculate Band Bias
   int Band_Bias_Upper_Quadrant = 0;
   int Band_Bias_Lower_Quadrant = 0;
   
   for(int k = 0; k < DEFAULT_BUFFER_SIZE/2; k++)
   {
      double   curr_close_price = iClose(Symbol(), timeFrameENUM, k);
      double   Plus_1X_StdDev_Price = GetBands(m_Handlers[TimeFrameIndex],MODE_UPPER,k);
      double   Minus_1X_StdDev_Price = GetBands(m_Handlers[TimeFrameIndex],MODE_LOWER,k);
      
      if(curr_close_price > Plus_1X_StdDev_Price)
         Band_Bias_Upper_Quadrant++;
      else if(curr_close_price < Minus_1X_StdDev_Price)
         Band_Bias_Lower_Quadrant++;
   }  // k loop
   
          
   if(Band_Bias_Upper_Quadrant > Band_Bias_Lower_Quadrant && Band_Bias_Upper_Quadrant > m_MAPeriod/2)      
      m_Band_Bias[TimeFrameIndex][0] = UPPER_QUADRANT;
   else if(Band_Bias_Upper_Quadrant < Band_Bias_Lower_Quadrant && Band_Bias_Lower_Quadrant > m_MAPeriod/2)     
      m_Band_Bias[TimeFrameIndex][0] = LOWER_QUADRANT; 
   else
      m_Band_Bias[TimeFrameIndex][0] = FULL_QUADRANT;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bands::GetMain(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_Main[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Bands::GetUpper(int TimeFrameIndex,int DeviationLevel,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE
      || DeviationLevel>BANDS_DEVIATION_SIZE || DeviationLevel<1)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   int deviationIndex=GetDeviationIndex(DeviationLevel);
   if(deviationIndex<0)
      return -1;
   double res=m_Upper[TimeFrameIndex][Shift][deviationIndex];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Bands::GetLower(int TimeFrameIndex,int DeviationLevel,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   int deviationIndex=GetDeviationIndex(DeviationLevel);
   if(deviationIndex<0)
      return -1;
   double res=m_Lower[TimeFrameIndex][Shift][deviationIndex];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Bands::GetBandSize(int TimeFrameIndex, int Deviation, int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   return GetUpper(TimeFrameIndex,Deviation,Shift)-GetLower(TimeFrameIndex,Deviation,Shift);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Bands::GetBandStdDev(int TimeFrameIndex, int Deviation, int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   return GetUpper(TimeFrameIndex,Deviation,Shift) - GetMain(TimeFrameIndex, Shift);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Bands::GetBandStdDevPosition(int TimeFrameIndex,int Shift)
{
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   if(GetBandStdDev(TimeFrameIndex, 1, Shift) == 0)
      return 0;
      
   double close = Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetClose():iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift);
      
   return NormalizeDouble(((close - m_Main[TimeFrameIndex][Shift])/GetBandStdDev(TimeFrameIndex, 1, Shift)), 2);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION Bands::GetPricePosition(int TimeFrameIndex,int Shift)
{
   double close=Shift<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift].GetClose():iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift);
   double bandStdDevPosition=GetBandStdDevPosition(TimeFrameIndex, Shift);
   
   
   if(m_Main[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(bandStdDevPosition >= 3)
      return Plus_3_StdDev;
      
   else if(bandStdDevPosition >= 2)
      return Plus_2_StdDev;
      
   else if(close > m_Main[TimeFrameIndex][Shift] && bandStdDevPosition < 2)
      return Above_Mean;
      
   else if(close == m_Main[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(close < m_Main[TimeFrameIndex][Shift] && bandStdDevPosition > -2)
      return Below_Mean;
      
   else if(bandStdDevPosition <= -2)
      return Minus_2_StdDev;
      
   else if(bandStdDevPosition <= -3)
      return Minus_3_StdDev;
   else
      return Null;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Bands::CalculateBandsMain(ENUM_TIMEFRAMES TimeFrameENUM, int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(TimeFrameENUM);
   return GetBands(m_Handlers[TimeFrameIndex], MODE_MAIN, Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Bands::SetShift(int Shift)
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
bool Bands::SetPeriod(int BandsPeriod)
  {
   if(BandsPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Period=-1;
      return false;
     }

   m_Period=BandsPeriod;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Bands::SetDeviation(double Deviation)
  {
   if(Deviation<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_Deviation=-1;
      return false;
     }

   m_Deviation=Deviation;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Bands::SetAppliedPrice(ENUM_APPLIED_PRICE AppliedPrice)
  {
   if(AppliedPrice<0 || AppliedPrice>6)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_AppliedPrice=-1;
      return false;
     }

   m_AppliedPrice=AppliedPrice;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Bands::SetMAPeriod(int MAPeriod)
  {
   if(MAPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_MAPeriod=-1;
      return false;
     }

   m_MAPeriod=MAPeriod;
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Bands::GetDeviationLevel(int DeviationIndex)
  {
   if(DeviationIndex<0 || DeviationIndex>=BANDS_DEVIATION_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      return -1;
     }

   return BANDS_DEVIATION_LEVELS[DeviationIndex];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Bands::GetDeviationIndex(int DeviationLevel)
  {
   if(DeviationLevel<1 || DeviationLevel>BANDS_DEVIATION_SIZE)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      return -1;
     }

   for(int i=0; i<BANDS_DEVIATION_SIZE; i++)
     {
      if(BANDS_DEVIATION_LEVELS[i]==DeviationLevel)
         return i;
     }

   LogError(__FUNCTION__,"Deviation level is not valid.");
   return -1;
  }

//+------------------------------------------------------------------+
