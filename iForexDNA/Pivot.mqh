//+------------------------------------------------------------------+
//|                                                        Pivot.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Pivot:public BaseIndicator
  {
private:
   double            m_PivotPoints[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_PivotR[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE][PIVOT_LEVELS_SIZE];
   double            m_PivotS[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE][PIVOT_LEVELS_SIZE];
   double            m_PivotSupport[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_PivotResist[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   string            m_PivotSupportPosition[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   string            m_PivotResistPosition[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   
   double            m_WeeklyPivotPoint[DEFAULT_BUFFER_SIZE];
   double            m_WeeklyPivotR[DEFAULT_BUFFER_SIZE][PIVOT_LEVELS_SIZE];
   double            m_WeeklyPivotS[DEFAULT_BUFFER_SIZE][PIVOT_LEVELS_SIZE];
   
   
   
public:
                     Pivot();
                    ~Pivot();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetPivotPoint(int TimeFrameIndex,int Shift);
   double            GetPivot(int TimeFrameIndex,int Shift,int Level); 
   double            GetPivotR(int TimeFrameIndex,int Shift,int Level);
   double            GetPivotS(int TimeFrameIndex,int Shift,int Level);
   double            GetPivotSupport(int TimeFrameIndex,int Shift){return m_PivotSupport[TimeFrameIndex][Shift];};
   double            GetPivotResist(int TimeFrameIndex,int Shift){return m_PivotResist[TimeFrameIndex][Shift];};


   double            GetWeeklyPivotPoint(int Shift){return m_WeeklyPivotPoint[Shift];};   
   double            GetWeeklyPivotS(int Shift, int Level){return m_WeeklyPivotS[Shift][Level];};
   double            GetWeeeklyPivotR(int Shift, int Level){return m_WeeklyPivotR[Shift][Level];};

   
   
   string            GetPivotSupportPosition(int TimeFrameIndex,int Shift){return m_PivotSupportPosition[TimeFrameIndex][Shift];};
   string            GetPivotResistPosition(int TimeFrameIndex,int Shift){return m_PivotResistPosition[TimeFrameIndex][Shift];};
   
   void              CalculatePivot(int TimeFrameIndex,int Shift,double& arr[]);
     
private:
   void              CalculateWeeklyPivotSRPoint(int Shift);
   void              CalculatePivotSRPoint(int TimeFrameIndex,int Shift);
   void              CalculatePivotSRPosition(int TimeFrameIndex, int Shift);
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Pivot::Pivot():BaseIndicator("Pivot")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Pivot::~Pivot()
  {
         ArrayRemove(m_PivotPoints, 0);
         ArrayRemove(m_PivotR, 0);
         ArrayRemove(m_PivotS, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Pivot::Init()
  {
   ArrayInitialize(m_PivotPoints,-1);
   ArrayInitialize(m_PivotR,-1);
   ArrayInitialize(m_PivotS,-1);

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
     {
      for(int j=0; j<DEFAULT_BUFFER_SIZE; j++)
        {
         CalculatePivotSRPoint(i, j);
         CalculatePivotSRPosition(i, j); 
        }
     }
     
     
     // Weekly Pivot Calculation
     for(int i = 0; i < DEFAULT_BUFFER_SIZE; i++)
     {
         CalculateWeeklyPivotSRPoint(i);
     }
     

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Pivot::OnUpdate(int TimeFrameIndex,bool IsNewBar)
  {
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      CalculatePivotSRPosition(i, 0);
   }

   if(CheckIsNewBar(PERIOD_W1))
   {
      for(int j = DEFAULT_BUFFER_SIZE-1; j > 0; j--)
      {
         m_WeeklyPivotPoint[j]=m_WeeklyPivotPoint[j-1];

         for(int i=0; i<PIVOT_LEVELS_SIZE; i++)
           {
            m_WeeklyPivotR[j][i]=m_WeeklyPivotR[j-1][i];
            m_WeeklyPivotS[j][i]=m_WeeklyPivotS[j-1][i];
           }
      }

      CalculateWeeklyPivotSRPoint(0);

   }

   if(!IsNewBar)
      return;
      
   for(int j=DEFAULT_BUFFER_SIZE-1; j>0; j--)
     {
      m_PivotPoints[TimeFrameIndex][j]=m_PivotPoints[TimeFrameIndex][j-1];

      for(int i=0; i<PIVOT_LEVELS_SIZE; i++)
        {
         m_PivotR[TimeFrameIndex][j][i]=m_PivotR[TimeFrameIndex][j-1][i];
         m_PivotS[TimeFrameIndex][j][i]=m_PivotS[TimeFrameIndex][j-1][i];
        }
     }


   CalculatePivotSRPoint(TimeFrameIndex, 0);
   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Pivot::GetPivot(int TimeFrameIndex,int Shift,int Level)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE 
      || TimeFrameIndex<0 
      || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE 
      || Level<-PIVOT_LEVELS_SIZE || Level>PIVOT_LEVELS_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   if(Level==0)
      return GetPivotPoint(TimeFrameIndex,Shift);
   else if(Level<0)
      return GetPivotS(TimeFrameIndex,Shift,-Level-1);
   else if(Level>0)
      return GetPivotR(TimeFrameIndex,Shift,Level-1);      
   
   LogError(__FUNCTION__,"Unknow ERROR.");
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Pivot::GetPivotPoint(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=Normalize(m_PivotPoints[TimeFrameIndex][Shift]);
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Pivot::GetPivotR(int TimeFrameIndex,int Shift,int Level)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Level<0 || Level>=PIVOT_LEVELS_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=Normalize(m_PivotR[TimeFrameIndex][Shift][Level]);
   if(res<0)
   {
      ASSERT("Buffer Value not init.",__FUNCTION__);
   }

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Pivot::GetPivotS(int TimeFrameIndex,int Shift,int Level)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Level<0 || Level>=PIVOT_LEVELS_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=Normalize(m_PivotS[TimeFrameIndex][Shift][Level]);
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Pivot::CalculatePivotSRPoint(int TimeFrameIndex, int Shift){
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE || Shift<0){
      ASSERT("Invalid function input",__FUNCTION__);
      return;
   }
   
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   double high=Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetHigh():iHigh(Symbol(),timeFrameENUM,Shift+1);
   double low=Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetLow():iLow(Symbol(),timeFrameENUM,Shift+1);
   double close=Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetClose():iClose(Symbol(),timeFrameENUM,Shift+1);
   
   m_PivotPoints[TimeFrameIndex][Shift] = NormalizeDouble((high+low+close)/3, _Digits);
   
   m_PivotR[TimeFrameIndex][Shift][0] = (2*m_PivotPoints[TimeFrameIndex][Shift]) - low;
   m_PivotS[TimeFrameIndex][Shift][0] = (2*m_PivotPoints[TimeFrameIndex][Shift]) - high;
   
   m_PivotR[TimeFrameIndex][Shift][1] = m_PivotPoints[TimeFrameIndex][Shift]+(m_PivotR[TimeFrameIndex][Shift][0] - m_PivotS[TimeFrameIndex][Shift][0]);
   m_PivotS[TimeFrameIndex][Shift][1] = m_PivotPoints[TimeFrameIndex][Shift]-(m_PivotR[TimeFrameIndex][Shift][0] - m_PivotS[TimeFrameIndex][Shift][0]);
   
   m_PivotR[TimeFrameIndex][Shift][2] = high + (2*(m_PivotPoints[TimeFrameIndex][Shift]-low));
   m_PivotS[TimeFrameIndex][Shift][2] = low - (2*(high-m_PivotPoints[TimeFrameIndex][Shift]));
   

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Pivot::CalculateWeeklyPivotSRPoint(int Shift){
   if(Shift<0 || Shift >= DEFAULT_BUFFER_SIZE){
      ASSERT("Invalid function input",__FUNCTION__);
      return;
   }

   double high = iHigh(Symbol(), PERIOD_W1, Shift+1);
   double low = iLow(Symbol(), PERIOD_W1, Shift+1);
   double close = iClose(Symbol(), PERIOD_W1, Shift+1);
   
   m_WeeklyPivotPoint[Shift] = (high+low+close)/3;
   
   m_WeeklyPivotR[Shift][0] = (2*m_WeeklyPivotPoint[Shift]) - low;
   m_WeeklyPivotS[Shift][0] = (2*m_WeeklyPivotPoint[Shift]) - high;
   
   m_WeeklyPivotR[Shift][1] = m_WeeklyPivotPoint[Shift]+(m_WeeklyPivotR[Shift][0] - m_WeeklyPivotS[Shift][0]);
   m_WeeklyPivotS[Shift][1] = m_WeeklyPivotPoint[Shift]-(m_WeeklyPivotR[Shift][0] - m_WeeklyPivotS[Shift][0]);
   
   m_WeeklyPivotR[Shift][2] = high + (2*(m_WeeklyPivotPoint[Shift]-low));
   m_WeeklyPivotS[Shift][2] = low - (2*(high-m_WeeklyPivotPoint[Shift]));

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Pivot::CalculatePivotSRPosition(int TimeFrameIndex, int Shift)
{
     m_PivotResist[TimeFrameIndex][Shift] = 0;
     m_PivotSupport[TimeFrameIndex][Shift] = 0;
   
     double curr_close = Shift < CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() : iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift);
   
     for(int j = -3; j < 3; j++)
     {     
         if(curr_close > GetPivot(TimeFrameIndex, Shift, j) && curr_close <= GetPivot(TimeFrameIndex, Shift, j+1))
         {
            m_PivotSupport[TimeFrameIndex][Shift] = GetPivot(TimeFrameIndex, Shift, j);
            m_PivotResist[TimeFrameIndex][Shift] = GetPivot(TimeFrameIndex, Shift, j+1);
            
            if(j == 0)
            {
               m_PivotResistPosition[TimeFrameIndex][Shift] = "R"+ IntegerToString(j+1);
               m_PivotSupportPosition[TimeFrameIndex][Shift] = "P"+ (string)j;
            }
            
            else if(j > 0)
            {
               m_PivotSupportPosition[TimeFrameIndex][Shift] = "R"+ (string)j;
               m_PivotResistPosition[TimeFrameIndex][Shift] = "R"+ IntegerToString(j+1);
            }
            else if(j < 0)
            {
               m_PivotSupportPosition[TimeFrameIndex][Shift] = "S"+ (string) MathAbs(j);
               m_PivotResistPosition[TimeFrameIndex][Shift] = "S"+ (string) IntegerToString(MathAbs(j)-1);
            }
         
         }        
         
         else if(iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift) <= GetPivot(TimeFrameIndex, Shift, -3))
         {
            m_PivotResistPosition[TimeFrameIndex][Shift] = "< S3";
            m_PivotResistPosition[TimeFrameIndex][Shift] = "< S3";
            break;  
         }
         else if(iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift) >= GetPivot(TimeFrameIndex, Shift, 3))
         {
            m_PivotSupportPosition[TimeFrameIndex][Shift] = "> R3";
            m_PivotResistPosition[TimeFrameIndex][Shift] = "> R3";
            break;
         } 
        
     }   // j loop
        
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Pivot::CalculatePivot(int TimeFrameIndex,int Shift,double& arr[])     // S0, R0, S1, R1, S2, R2
{
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   double prevHigh=Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetHigh():iHigh(Symbol(),timeFrameENUM,Shift+1);
   double prevLow=Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetLow():iLow(Symbol(),timeFrameENUM,Shift+1);
   double prevClose=Shift+1<CANDLESTICKS_BUFFER_SIZE?CandleSticksBuffer[TimeFrameIndex][Shift+1].GetClose():iClose(Symbol(),timeFrameENUM,Shift+1);

   // calculate previous HLC3
   double pivotPoint = NormalizeDouble((prevHigh+prevLow+prevClose)/3, _Digits);
   
   arr[0] = (2*pivotPoint) - prevHigh;              // S1
   arr[1] = (2*pivotPoint) - prevLow;               // R1
   
   arr[2] = pivotPoint-(arr[1]-arr[0]);             // S2
   arr[3] = pivotPoint+(arr[1]-arr[0]);             // R2
   
   arr[4] = prevLow-(2*(prevHigh-pivotPoint));      // S3
   arr[5] = prevHigh+(2*(pivotPoint-prevLow));      // R3
   
}

//+------------------------------------------------------------------+
