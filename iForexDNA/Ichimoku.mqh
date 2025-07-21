//+------------------------------------------------------------------+
//|                                                     Ichimoku.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\BaseIndicator.mqh"
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\CopybufferFunc.mqh"
#include "..\iForexDNA\MathFunc.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Ichimoku:public BaseIndicator
  {
private:
   int               m_TenkanSenPeriod;
   int               m_KijunSenPeriod;
   int               m_SenkouSpanPeriod;
   
   int               m_Handlers[ENUM_TIMEFRAMES_ARRAY_SIZE];

   double            m_TenkanSen[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   ENUM_QUADRANT     m_TenkanSenQuadrant[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   
   double            m_KijunSen[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   ENUM_QUADRANT     m_KijunQuadrant[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];


   double            m_ChikouSpan[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];   


   double            m_TenKanKijunHist[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_TenKanKijunHistMean[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];
   double            m_TenKanKijunHistStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][DEFAULT_BUFFER_SIZE];   
   
   
   double            m_SenkouSpanA[ENUM_TIMEFRAMES_ARRAY_SIZE][ICHIMOKU_SPAN_BUFFER_SIZE];
   double            m_SenkouSpanB[ENUM_TIMEFRAMES_ARRAY_SIZE][ICHIMOKU_SPAN_BUFFER_SIZE];

   
public:
                     Ichimoku();
                    ~Ichimoku();

   bool              Init();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);

   double            GetTenkanSen(int TimeFrameIndex,int Shift);
   ENUM_QUADRANT     GetTenKanQuadrant(int TimeFrameIndex, int Shift);


   double            GetKijunSen(int TimeFrameIndex,int Shift);
   ENUM_QUADRANT     GetKijunQuadrant(int TimeFrameIndex, int Shift);
   
   double            GetTenKanKijunHist(int TimeFrameIndex,int Shift);
   double            GetTenKanKijunHistMean(int TimeFrameIndex,int Shift);
   double            GetTenKanKijunHistStdDev(int TimeFrameIndex,int Shift);

   
   double            GetSenkouSpanA(int TimeFrameIndex,int Shift);
   double            GetSenkouSpanB(int TimeFrameIndex,int Shift);
   double            GetChikouSpan(int TimeFrameIndex,int Shift);
   

   double            CalculateTenKan(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   double            CalculateKijun(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   double            CalculateTenKanKijunHist(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   
   double            CalculateChikouSpan(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   double            CalculateSenkouSpanA(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   double            CalculateSenkouSpanB(ENUM_TIMEFRAMES timeFrameENUM, int Shift);
   
   
   int               GetChikouPosition(int TimeFrameIndex, int Shift);
   int               GetTenKanKijunCross(int TimeFrameIndex, int Shift); 
   
   int               GetHandlers(int TimeFrameIndex){return m_Handlers[TimeFrameIndex];};             
   
private:
   bool              SetTenkanSenPeriod(int TenkanSenPeriod);
   bool              SetKijunSenPeriod(int KijunSenPeriod);
   bool              SetSenkouSpanPeriod(int SenkouSpanPeriod);
   
   void              OnUpdateTenKanKijunHistStdDdev(int TimeFrameIndex);
   void              CalculateQuadrant(int TimeFrameIndex);
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::Ichimoku():BaseIndicator("Ichimoku")
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::~Ichimoku()
  {
      ArrayRemove(m_TenkanSen, 0);
      ArrayRemove(m_KijunSen, 0);
      ArrayRemove(m_SenkouSpanA, 0);
      ArrayRemove(m_SenkouSpanB, 0);
      ArrayRemove(m_ChikouSpan, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Ichimoku::Init()
{
   m_TenkanSenPeriod=-1;
   m_KijunSenPeriod=-1;
   m_SenkouSpanPeriod=-1;


   if(!SetTenkanSenPeriod(ICHIMOKU_TENKANSEN)
      || !SetKijunSenPeriod(ICHIMOKU_KIJUNSEN)
      || !SetSenkouSpanPeriod(ICHIMOKU_SENKOU_SPAN))
      return false;
      
   
   // check cloud span vs default buffer size
   int maxBuffer = DEFAULT_BUFFER_SIZE*2 > ICHIMOKU_SPAN_BUFFER_SIZE ? DEFAULT_BUFFER_SIZE*2 : ICHIMOKU_SPAN_BUFFER_SIZE;
  
   ArrayInitialize(m_TenkanSenQuadrant, UNKNOWN);
   ArrayInitialize(m_KijunQuadrant, UNKNOWN);
   
   for(int i=0; i< ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(i);     
      
      m_Handlers[i] = iIchimoku(Symbol(), timeFrameENUM, m_TenkanSenPeriod, m_KijunSenPeriod, m_SenkouSpanPeriod);

      if(m_Handlers[i] == INVALID_HANDLE)
      {
         LogError(__FUNCTION__, "Failed to initialize Ichimoku handlers.");
         return false;
      }

      double tempArray[DEFAULT_BUFFER_SIZE*2];
      double TenKanArray[DEFAULT_BUFFER_SIZE*2];
      double KijunArray[DEFAULT_BUFFER_SIZE*2];
      
      ArrayInitialize(tempArray, 0);
      ArrayInitialize(TenKanArray, 0);
      ArrayInitialize(KijunArray, 0);
      
      int arrsize=ArraySize(tempArray);
      
      for(int j = 0; j < maxBuffer; j++)
      {      
         // within range of ichimoku buffer size
         if(j < DEFAULT_BUFFER_SIZE)
         {
            // conversion line, base line, lagging span
            m_TenkanSen[i][j]=GetIchimoku(m_Handlers[i],TENKANSEN_LINE,j);
            m_KijunSen[i][j]=GetIchimoku(m_Handlers[i],KIJUNSEN_LINE,j);
            
            // tenKan Kijun Histogram
            m_TenKanKijunHist[i][j] = m_TenkanSen[i][j] - m_KijunSen[i][j];
            
            TenKanArray[j] = m_TenkanSen[i][j];
            KijunArray[j] = m_KijunSen[i][j];
            tempArray[j] = m_TenKanKijunHist[i][j];
            
            m_ChikouSpan[i][j]=GetIchimoku(m_Handlers[i],CHIKOUSPAN_LINE,j-ICHIMOKU_NEGATIVE_SHIFT);
         }
         
         else if(j >= DEFAULT_BUFFER_SIZE && j < DEFAULT_BUFFER_SIZE*2)
         {
            TenKanArray[j] = GetIchimoku(m_Handlers[i],TENKANSEN_LINE,j);
            KijunArray[j] = GetIchimoku(m_Handlers[i],KIJUNSEN_LINE,j);
            tempArray[j] = GetIchimoku(m_Handlers[i],TENKANSEN_LINE,j) - GetIchimoku(m_Handlers[i],KIJUNSEN_LINE,j);

            // Calculate Quadrant
            int tenkan_lower = 0, tenkan_upper = 0;
            int kijun_lower = 0, kijun_upper = 0;

            // calculating the quadrant here
            for(int d = 0; d < DEFAULT_BUFFER_SIZE/2; d++)
            {
               double close = iClose(Symbol(),timeFrameENUM, d+j-DEFAULT_BUFFER_SIZE);
            
               // TenKan Quadrant Calcuation
               if(TenKanArray[d+j-DEFAULT_BUFFER_SIZE] < close)
                  tenkan_upper++;
               else if(TenKanArray[d+j-DEFAULT_BUFFER_SIZE] > close)
                  tenkan_lower++;
                  
               // Kijun Quadrant Calculation
               if(KijunArray[d+j-DEFAULT_BUFFER_SIZE] < close)
                  kijun_upper++;
               else if(KijunArray[d+j-DEFAULT_BUFFER_SIZE] > close)
                  kijun_lower++;
            }
            
            // Finalizing the quadrant
            if(tenkan_upper > tenkan_lower && tenkan_upper > DEFAULT_BUFFER_SIZE/4)          // half the times -- which is 10 out of 20
               m_TenkanSenQuadrant[i][j-DEFAULT_BUFFER_SIZE] = UPPER_QUADRANT;
            else if(tenkan_upper < tenkan_lower && tenkan_lower > DEFAULT_BUFFER_SIZE/4)     // half the times -- which is 10 out of 20
               m_TenkanSenQuadrant[i][j-DEFAULT_BUFFER_SIZE] = LOWER_QUADRANT;
            else
               m_TenkanSenQuadrant[i][j-DEFAULT_BUFFER_SIZE] = FULL_QUADRANT;
         
         
            // Finalizing the quadrant
            if(kijun_upper > kijun_lower && kijun_upper > DEFAULT_BUFFER_SIZE/4)          // half the times -- which is 10 out of 20
               m_KijunQuadrant[i][j-DEFAULT_BUFFER_SIZE] = UPPER_QUADRANT;
            else if(kijun_upper < kijun_lower && kijun_lower > DEFAULT_BUFFER_SIZE/4)     // half the times -- which is 10 out of 20
               m_KijunQuadrant[i][j-DEFAULT_BUFFER_SIZE] = LOWER_QUADRANT;
            else
               m_KijunQuadrant[i][j-DEFAULT_BUFFER_SIZE] = FULL_QUADRANT;         
         }
         
         // update Ichimoku Spans         
         if(j < ICHIMOKU_SPAN_BUFFER_SIZE)
         {
            m_SenkouSpanA[i][j]=GetIchimoku(m_Handlers[i],SENKOUSPANA_LINE,j+ICHIMOKU_NEGATIVE_SHIFT);
            m_SenkouSpanB[i][j]=GetIchimoku(m_Handlers[i],SENKOUSPANB_LINE,j+ICHIMOKU_NEGATIVE_SHIFT);;
         }
      
      }
      
      
      // calculate mean/std
      for(int x = 0; x < DEFAULT_BUFFER_SIZE; x++)
      {
         m_TenKanKijunHistMean[i][x]=MathMean(tempArray, x, DEFAULT_INDICATOR_PERIOD);     
         m_TenKanKijunHistStdDev[i][x]=MathStandardDeviation(tempArray, x, DEFAULT_INDICATOR_PERIOD);   
      }
            
   }
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Ichimoku::OnUpdate(int TimeFrameIndex,bool IsNewBar){
   if(TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE){
      ASSERT("Invalid function input",__FUNCTION__);
      return;
   }
   
   ENUM_TIMEFRAMES timeFrameENUM=GetTimeFrameENUM(TimeFrameIndex);
   
   if(IsNewBar)
   {
      // check cloud span vs default buffer size
      int maxBuffer = DEFAULT_BUFFER_SIZE > ICHIMOKU_SPAN_BUFFER_SIZE ? DEFAULT_BUFFER_SIZE : ICHIMOKU_SPAN_BUFFER_SIZE;
   
      for(int i = maxBuffer-1; i > 0; i--){
         if(i < DEFAULT_BUFFER_SIZE){
            m_TenkanSen[TimeFrameIndex][i] = m_TenkanSen[TimeFrameIndex][i-1];
            m_TenkanSenQuadrant[TimeFrameIndex][i] = m_TenkanSenQuadrant[TimeFrameIndex][i-1];
            
            m_KijunSen[TimeFrameIndex][i] = m_KijunSen[TimeFrameIndex][i-1];
            m_KijunQuadrant[TimeFrameIndex][i] = m_KijunQuadrant[TimeFrameIndex][i-1];
            
            m_TenKanKijunHist[TimeFrameIndex][i] = m_TenKanKijunHist[TimeFrameIndex][i-1];
            m_TenKanKijunHistMean[TimeFrameIndex][i] = m_TenKanKijunHistMean[TimeFrameIndex][i-1];
            m_TenKanKijunHistStdDev[TimeFrameIndex][i] = m_TenKanKijunHistStdDev[TimeFrameIndex][i-1];
            m_ChikouSpan[TimeFrameIndex][i] = m_ChikouSpan[TimeFrameIndex][i-1];
         }
         
         if(i < ICHIMOKU_SPAN_BUFFER_SIZE){
            m_SenkouSpanA[TimeFrameIndex][i]=m_SenkouSpanA[TimeFrameIndex][i-1];
            m_SenkouSpanB[TimeFrameIndex][i]=m_SenkouSpanB[TimeFrameIndex][i-1];
         }
        
      }
       
   }
   
   // ichimoku cloud does not update every tick, therefore, only update per bar
   m_SenkouSpanA[TimeFrameIndex][0]=GetIchimoku(m_Handlers[TimeFrameIndex],SENKOUSPANA_LINE,ICHIMOKU_NEGATIVE_SHIFT);
   m_SenkouSpanB[TimeFrameIndex][0]=GetIchimoku(m_Handlers[TimeFrameIndex],SENKOUSPANB_LINE,ICHIMOKU_NEGATIVE_SHIFT);
      
      
   m_TenkanSen[TimeFrameIndex][0]=GetIchimoku(m_Handlers[TimeFrameIndex],TENKANSEN_LINE,0);
   m_KijunSen[TimeFrameIndex][0]=GetIchimoku(m_Handlers[TimeFrameIndex],KIJUNSEN_LINE,0);
   m_TenKanKijunHist[TimeFrameIndex][0] = m_TenkanSen[TimeFrameIndex][0] - m_KijunSen[TimeFrameIndex][0];
   
   m_ChikouSpan[TimeFrameIndex][0]=GetIchimoku(m_Handlers[TimeFrameIndex],CHIKOUSPAN_LINE,-ICHIMOKU_NEGATIVE_SHIFT);
   
   OnUpdateTenKanKijunHistStdDdev(TimeFrameIndex);
   CalculateQuadrant(TimeFrameIndex);
   
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Ichimoku::OnUpdateTenKanKijunHistStdDdev(int TimeFrameIndex)
{   

   double tempArray[DEFAULT_INDICATOR_PERIOD];
   
   for(int i=0;i<DEFAULT_INDICATOR_PERIOD;i++)
      tempArray[i]=m_TenKanKijunHist[TimeFrameIndex][i];
      
   m_TenKanKijunHistMean[TimeFrameIndex][0]=MathMean(tempArray, 0, DEFAULT_INDICATOR_PERIOD);     
   m_TenKanKijunHistStdDev[TimeFrameIndex][0]=MathStandardDeviation(tempArray, 0, DEFAULT_INDICATOR_PERIOD); 

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Ichimoku::CalculateQuadrant(int TimeFrameIndex)
{
   if(TimeFrameIndex<0 || TimeFrameIndex> ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return;
     }
          
   // Calculate Quadrant
   int tenkan_lower = 0, tenkan_upper = 0;
   int kijun_lower = 0, kijun_upper = 0;
   
   for(int k = 0; k < DEFAULT_BUFFER_SIZE/2; k++)
   {
      double close = iClose(Symbol(),GetTimeFrameENUM(TimeFrameIndex), k);
   
      // TenKan Quadrant Calcuation
      if(m_TenkanSen[TimeFrameIndex][k] < close)
         tenkan_upper++;
      else if(m_TenkanSen[TimeFrameIndex][k] > close)
         tenkan_lower++;
         
      // Kijun Quadrant Calculation
      if(m_KijunSen[TimeFrameIndex][k] < close)
         kijun_upper++;
      else if(m_KijunSen[TimeFrameIndex][k] > close)
         kijun_lower++;
   }
   
   // Finalizing the quadrant
   if(tenkan_upper > tenkan_lower && tenkan_upper > DEFAULT_BUFFER_SIZE/4)          // half the times -- which is 10 out of 20
      m_TenkanSenQuadrant[TimeFrameIndex][0] = UPPER_QUADRANT;
   else if(tenkan_upper < tenkan_lower && tenkan_lower > DEFAULT_BUFFER_SIZE/4)     // half the times -- which is 10 out of 20
      m_TenkanSenQuadrant[TimeFrameIndex][0] = LOWER_QUADRANT;
   else
      m_TenkanSenQuadrant[TimeFrameIndex][0] = FULL_QUADRANT;


   // Finalizing the quadrant
   if(kijun_upper > kijun_lower && kijun_upper > DEFAULT_BUFFER_SIZE/4)          // half the times -- which is 10 out of 20
      m_KijunQuadrant[TimeFrameIndex][0] = UPPER_QUADRANT;
   else if(kijun_upper < kijun_lower && kijun_lower > DEFAULT_BUFFER_SIZE/4)     // half the times -- which is 10 out of 20
      m_KijunQuadrant[TimeFrameIndex][0] = LOWER_QUADRANT;
   else
      m_KijunQuadrant[TimeFrameIndex][0] = FULL_QUADRANT;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Ichimoku::GetTenkanSen(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex> ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      printf("Shift="+(string) Shift);
      return -1;
     }

   double res=m_TenkanSen[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_QUADRANT Ichimoku::GetTenKanQuadrant(int TimeFrameIndex,int Shift)
{
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex> ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      printf("Shift="+(string) Shift);
      return -1;
     }
     
   ENUM_QUADRANT res=m_TenkanSenQuadrant[TimeFrameIndex][Shift];
   if(res<0 || res >= ENUM_QUADRANT_SIZE)
      ASSERT("Qudrant Value invalid.",__FUNCTION__);

   return res;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ichimoku::GetKijunSen(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex> ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=m_KijunSen[TimeFrameIndex][Shift];
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_QUADRANT Ichimoku::GetKijunQuadrant(int TimeFrameIndex,int Shift)
{
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex> ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      printf("Shift="+(string) Shift);
      return -1;
     }
     
   ENUM_QUADRANT res=m_KijunQuadrant[TimeFrameIndex][Shift];
   if(res<0 || res >= ENUM_QUADRANT_SIZE)
      ASSERT("Qudrant Value invalid.",__FUNCTION__);

   return res;
   
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ichimoku::GetTenKanKijunHist(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex> ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   return m_TenKanKijunHist[TimeFrameIndex][Shift];

  }  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ichimoku::GetTenKanKijunHistMean(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex> ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   return m_TenKanKijunHistMean[TimeFrameIndex][Shift];

  }  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ichimoku::GetTenKanKijunHistStdDev(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   return m_TenKanKijunHistStdDev[TimeFrameIndex][Shift];

  }  
  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int Ichimoku::GetTenKanKijunCross(int TimeFrameIndex,int Shift)
{
   if(Shift<0 || Shift+1>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
     
     if(m_TenKanKijunHist[TimeFrameIndex][Shift] > 0 && m_TenKanKijunHist[TimeFrameIndex][Shift+1] <= 0)
      return BULL_TRIGGER;
     
     else if(m_TenKanKijunHist[TimeFrameIndex][Shift] < 0 && m_TenKanKijunHist[TimeFrameIndex][Shift+1] >= 0)
      return BEAR_TRIGGER;
      
     return NEUTRAL; 
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ichimoku::GetSenkouSpanA(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=ICHIMOKU_SPAN_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   double res=Normalize(m_SenkouSpanA[TimeFrameIndex][Shift]);
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ichimoku::GetSenkouSpanB(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=ICHIMOKU_SPAN_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }

   double res=Normalize(m_SenkouSpanB[TimeFrameIndex][Shift]);
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ichimoku::GetChikouSpan(int TimeFrameIndex,int Shift)
  {
   if(Shift<0 || Shift>=DEFAULT_BUFFER_SIZE || TimeFrameIndex<0 || TimeFrameIndex>=ENUM_TIMEFRAMES_ARRAY_SIZE)
     {
      ASSERT("Invalid function input",__FUNCTION__);
      return -1;
     }
   
   double res;
   

   res=m_ChikouSpan[TimeFrameIndex][Shift];
  
   if(res<0)
      ASSERT("Buffer Value not init.",__FUNCTION__);

   return res;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int Ichimoku::GetChikouPosition(int TimeFrameIndex,int Shift)
{
   double close=iClose(Symbol(), GetTimeFrameENUM(TimeFrameIndex), Shift-ICHIMOKU_NEGATIVE_SHIFT);
   
   if(close < m_ChikouSpan[TimeFrameIndex][Shift])
      return BULL_TRIGGER;
      
   return BEAR_TRIGGER;
   
}
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Ichimoku::CalculateTenKan(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   return GetIchimoku(m_Handlers[TimeFrameIndex],TENKANSEN_LINE,Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Ichimoku::CalculateKijun(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   return GetIchimoku(m_Handlers[TimeFrameIndex],KIJUNSEN_LINE,Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Ichimoku::CalculateTenKanKijunHist(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);

   return (
      GetIchimoku(m_Handlers[TimeFrameIndex],TENKANSEN_LINE,Shift)
      - GetIchimoku(m_Handlers[TimeFrameIndex],KIJUNSEN_LINE,Shift)
   );
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Ichimoku::CalculateChikouSpan(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetIchimoku(m_Handlers[TimeFrameIndex],CHIKOUSPAN_LINE,Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Ichimoku::CalculateSenkouSpanA(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetIchimoku(m_Handlers[TimeFrameIndex],SENKOUSPANA_LINE,Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Ichimoku::CalculateSenkouSpanB(ENUM_TIMEFRAMES timeFrameENUM,int Shift)
{
   int TimeFrameIndex = GetTimeFrameIndex(timeFrameENUM);
   return GetIchimoku(m_Handlers[TimeFrameIndex],SENKOUSPANB_LINE,Shift);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Ichimoku::SetTenkanSenPeriod(int TenkanSenPeriod)
  {
   if(TenkanSenPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_TenkanSenPeriod=-1;
      return false;
     }

   m_TenkanSenPeriod=TenkanSenPeriod;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Ichimoku::SetKijunSenPeriod(int KijunSenPeriod)
  {
   if(KijunSenPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_KijunSenPeriod=-1;
      return false;
     }

   m_KijunSenPeriod=KijunSenPeriod;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Ichimoku::SetSenkouSpanPeriod(int SenkouSpanPeriod)
  {
   if(SenkouSpanPeriod<=0)
     {
      LogError(__FUNCTION__,"Invalid function input.");
      m_SenkouSpanPeriod=-1;
      return false;
     }

   m_SenkouSpanPeriod=SenkouSpanPeriod;
   return true;
  }
//+------------------------------------------------------------------+
