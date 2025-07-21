//+------------------------------------------------------------------+
//|                                                BullBearIndex.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, iPayDNA"
#property link      "http://ipaydna.biz"
#property version   "1.00"
#property strict

#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class BullBearIndex:public BaseIndicator{
   private:
      IndicatorsHelper *m_Indicators;

      int      m_TotalBullBearIndex[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];


      double   m_ReactiveBullPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double   m_ReactiveBullMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double   m_ReactiveBullStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      double   m_LaggingBullPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double   m_LaggingBullMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double   m_LaggingBullStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      

      double   m_ReactiveBearPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];  
      double   m_ReactiveBearMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];   
      double   m_ReactiveBearStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      
      double   m_LaggingBearPercent[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double   m_LaggingBearMean[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
      double   m_LaggingBearStdDev[ENUM_TIMEFRAMES_ARRAY_SIZE][INDEXES_BUFFER_SIZE];
           
      void     OnUpdateBullBearStdDev(int TimeFrameIndex);
 
   public:
            BullBearIndex(IndicatorsHelper *pIndicators);
            ~BullBearIndex();
      bool  Init();
      void  OnUpdate(int TimeFrameIndex, bool IsNewBar);
   
   
      // Reactive Bull/Bear Index
      double GetReactiveBullPercent(int TimeFrameIndex, int Shift){return m_ReactiveBullPercent[TimeFrameIndex][Shift];};
      double GetReactiveBullMean(int TimeFrameIndex, int Shift){return m_ReactiveBullMean[TimeFrameIndex][Shift];};
      double GetReactiveBullStdDev(int TimeFrameIndex, int Shift){return m_ReactiveBullStdDev[TimeFrameIndex][Shift];};

      double GetReactiveBullUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_ReactiveBullMean[TimeFrameIndex][Shift]+Multiplier*m_ReactiveBullStdDev[TimeFrameIndex][Shift];}; 
      double GetReactiveBullLowerStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_ReactiveBullMean[TimeFrameIndex][Shift]-Multiplier*m_ReactiveBullStdDev[TimeFrameIndex][Shift];};
      
      double GetReactiveBearPercent(int TimeFrameIndex, int Shift){return m_ReactiveBearPercent[TimeFrameIndex][Shift];}; 
      double GetReactiveBearMean(int TimeFrameIndex, int Shift){return m_ReactiveBearMean[TimeFrameIndex][Shift];};
      double GetReactiveBearStdDev(int TimeFrameIndex, int Shift){return m_ReactiveBearStdDev[TimeFrameIndex][Shift];};

      double GetReactiveBearUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_ReactiveBearMean[TimeFrameIndex][Shift]+Multiplier*m_ReactiveBearStdDev[TimeFrameIndex][Shift];}; 
      double GetReactiveBearLowerStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_ReactiveBearMean[TimeFrameIndex][Shift]-Multiplier*m_ReactiveBearStdDev[TimeFrameIndex][Shift];};
    
      // Lagging Bull/Bear Index
      double GetLaggingBullPercent(int TimeFrameIndex, int Shift){return m_LaggingBullPercent[TimeFrameIndex][Shift];};
      double GetLaggingBullMean(int TimeFrameIndex, int Shift){return m_LaggingBullMean[TimeFrameIndex][Shift];};
      double GetLaggingBullStdDev(int TimeFrameIndex, int Shift){return m_LaggingBullStdDev[TimeFrameIndex][Shift];};

      double GetLaggingBullUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_LaggingBullMean[TimeFrameIndex][Shift]+Multiplier*m_LaggingBullStdDev[TimeFrameIndex][Shift];}; 
      double GetLaggingBullLowerStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_LaggingBullMean[TimeFrameIndex][Shift]-Multiplier*m_LaggingBullStdDev[TimeFrameIndex][Shift];};
     

      double GetLaggingBearPercent(int TimeFrameIndex, int Shift){return m_LaggingBearPercent[TimeFrameIndex][Shift];};
      double GetLaggingBearMean(int TimeFrameIndex, int Shift){return m_LaggingBearMean[TimeFrameIndex][Shift];};
      double GetLaggingBearStdDev(int TimeFrameIndex, int Shift){return m_LaggingBearStdDev[TimeFrameIndex][Shift];};

      double GetLaggingBearUpperStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_LaggingBearMean[TimeFrameIndex][Shift]+Multiplier*m_LaggingBearStdDev[TimeFrameIndex][Shift];}; 
      double GetLaggingBearLowerStdDev(int TimeFrameIndex, int Shift, float Multiplier=2){return m_LaggingBearMean[TimeFrameIndex][Shift]-Multiplier*m_LaggingBearStdDev[TimeFrameIndex][Shift];};
      
       
      string   CalculateBullBear(int TimeFrameENUM,int Shift);             // Summary for all the indicators BullBear Index   

      int    GetReactiveTotalBullBearIndex(int TimeFrameIndex, int Shift){return m_TotalBullBearIndex[TimeFrameIndex][Shift];};
      
      bool   IsReactiveBullCrossOver(int TimeFrameIndex, int Shift)
      {
            if(m_ReactiveBullPercent[TimeFrameIndex][Shift] > m_ReactiveBearPercent[TimeFrameIndex][Shift]
            && m_ReactiveBullPercent[TimeFrameIndex][Shift+1] <= m_ReactiveBearPercent[TimeFrameIndex][Shift+1])
               return true;
            else
               return false;
      };
      
      bool   IsReactiveBearCrossOver(int TimeFrameIndex, int Shift)
      {
            if(m_ReactiveBearPercent[TimeFrameIndex][Shift] > m_ReactiveBullPercent[TimeFrameIndex][Shift] 
            && m_ReactiveBearPercent[TimeFrameIndex][Shift+1] <= m_ReactiveBullPercent[TimeFrameIndex][Shift+1])
               return true;
            else
               return false;
      }; 


      bool   IsLaggingBullCrossOver(int TimeFrameIndex, int Shift)
      {
            if(m_LaggingBullPercent[TimeFrameIndex][Shift] > m_LaggingBearPercent[TimeFrameIndex][Shift]
            && m_LaggingBullPercent[TimeFrameIndex][Shift+1] <= m_LaggingBearPercent[TimeFrameIndex][Shift+1])
               return true;
            else
               return false;
      };
      
      bool   IsLaggingBearCrossOver(int TimeFrameIndex, int Shift)
      {
            if(m_LaggingBearPercent[TimeFrameIndex][Shift] > m_LaggingBullPercent[TimeFrameIndex][Shift] 
            && m_LaggingBearPercent[TimeFrameIndex][Shift+1] <= m_LaggingBullPercent[TimeFrameIndex][Shift+1])
               return true;
            else
               return false;
      }; 



      ENUM_INDICATOR_POSITION          GetReactiveBullPosition(int TimeFrameIndex, int Shift);
      ENUM_INDICATOR_POSITION          GetReactiveBearPosition(int TimeFrameIndex, int Shift);

      ENUM_INDICATOR_POSITION          GetLaggingBullPosition(int TimeFrameIndex, int Shift);
      ENUM_INDICATOR_POSITION          GetLaggingBearPosition(int TimeFrameIndex, int Shift);
};


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

BullBearIndex::BullBearIndex(IndicatorsHelper *pIndicators):BaseIndicator("BullBear"){
   m_Indicators = NULL;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

BullBearIndex::~BullBearIndex(){

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool BullBearIndex::Init(){
   for(int i = 0; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++){      
      double tempBullArray[INDEXES_BUFFER_SIZE*2];
      double tempBearArray[INDEXES_BUFFER_SIZE*2];   
      
      double tempLaggingBullArray[INDEXES_BUFFER_SIZE*2];
      double tempLaggingBearArray[INDEXES_BUFFER_SIZE*2];   
      
      int arrsize=ArraySize(tempBearArray);
   
      for(int j = 0; j < INDEXES_BUFFER_SIZE*2; j++)
      {
         if(j < INDEXES_BUFFER_SIZE)
         {
            CalculateBullBear(i, j);
            tempBullArray[j] = m_ReactiveBullPercent[i][j];
            tempBearArray[j] = m_ReactiveBearPercent[i][j];
            
            tempLaggingBullArray[j] = m_LaggingBullPercent[i][j];
            tempLaggingBearArray[j] = m_LaggingBearPercent[i][j];
         }
         
         else
         {
            string BullBearArray[2];
            StringSplit(CalculateBullBear(i,j), '/', BullBearArray);
      
            //--- Reactive Bull Bear Index
            tempBullArray[j] = StringToDouble(BullBearArray[0]);
            tempBearArray[j] = 100-tempBullArray[j];
            
            //--- Lagging Bull Bear Index
            tempLaggingBullArray[j] = StringToDouble(BullBearArray[1]);
            tempLaggingBearArray[j] = 100-tempLaggingBullArray[j];
         }         
          
      }

      // calculate mean/std
      for(int x = 0; x < INDEXES_BUFFER_SIZE; x++)
      {
         m_ReactiveBullMean[i][x] = NormalizeDouble(MathMean(tempBullArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_ReactiveBullStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempBullArray, x, ADVANCE_INDICATOR_PERIOD), 2);

         m_ReactiveBearMean[i][x] = NormalizeDouble(MathMean(tempBearArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_ReactiveBearStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempBearArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         
         m_LaggingBullMean[i][x] = NormalizeDouble(MathMean(tempLaggingBullArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_LaggingBullStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempLaggingBullArray, x, ADVANCE_INDICATOR_PERIOD), 2);

         m_LaggingBearMean[i][x] = NormalizeDouble(MathMean(tempLaggingBearArray, x, ADVANCE_INDICATOR_PERIOD), 2);
         m_LaggingBearStdDev[i][x] = NormalizeDouble(MathStandardDeviation(tempLaggingBearArray, x, ADVANCE_INDICATOR_PERIOD), 2);
      } 
      
     
      
      
   }

   return true;
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void BullBearIndex::OnUpdate(int TimeFrameIndex,bool IsNewBar){   
   if(IsNewBar){
      for(int j = INDEXES_BUFFER_SIZE-1; j > 0; j--){
         
         //--- Reactive Bull Bear Index
         m_ReactiveBullPercent[TimeFrameIndex][j] = m_ReactiveBullPercent[TimeFrameIndex][j-1];
         m_ReactiveBearPercent[TimeFrameIndex][j] = m_ReactiveBearPercent[TimeFrameIndex][j-1];

         m_ReactiveBullMean[TimeFrameIndex][j] = m_ReactiveBullMean[TimeFrameIndex][j-1];
         m_ReactiveBearMean[TimeFrameIndex][j] = m_ReactiveBearMean[TimeFrameIndex][j-1];

         m_ReactiveBullStdDev[TimeFrameIndex][j] = m_ReactiveBullStdDev[TimeFrameIndex][j-1];     
         m_ReactiveBearStdDev[TimeFrameIndex][j] = m_ReactiveBearStdDev[TimeFrameIndex][j-1];   

         //--- Lagging Bull Bear Index
         m_LaggingBullPercent[TimeFrameIndex][j] = m_LaggingBullPercent[TimeFrameIndex][j-1];
         m_LaggingBearPercent[TimeFrameIndex][j] = m_LaggingBearPercent[TimeFrameIndex][j-1];

         m_LaggingBullMean[TimeFrameIndex][j] = m_LaggingBullMean[TimeFrameIndex][j-1];
         m_LaggingBearMean[TimeFrameIndex][j] = m_LaggingBearMean[TimeFrameIndex][j-1];

         m_LaggingBullStdDev[TimeFrameIndex][j] = m_LaggingBullStdDev[TimeFrameIndex][j-1];     
         m_LaggingBearStdDev[TimeFrameIndex][j] = m_LaggingBearStdDev[TimeFrameIndex][j-1];   
      }  
   }
   
   // constantly update the latest only
   CalculateBullBear(TimeFrameIndex, 0);
   OnUpdateBullBearStdDev(TimeFrameIndex);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void BullBearIndex::OnUpdateBullBearStdDev(int TimeFrameIndex)
{     
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   double tempBullArray[ADVANCE_INDICATOR_PERIOD];
   double tempBearArray[ADVANCE_INDICATOR_PERIOD];

   double tempLaggingBullArray[ADVANCE_INDICATOR_PERIOD];
   double tempLaggingBearArray[ADVANCE_INDICATOR_PERIOD];

   for(int i=0; i < ADVANCE_INDICATOR_PERIOD; i++)
   {
      tempBullArray[i] = m_ReactiveBullPercent[TimeFrameIndex][i];
      tempBearArray[i] = m_ReactiveBearPercent[TimeFrameIndex][i];
      
      tempLaggingBullArray[i] = m_LaggingBullPercent[TimeFrameIndex][i];
      tempLaggingBearArray[i] = m_LaggingBearPercent[TimeFrameIndex][i];
      
   }   

   //--- Reactive Bull Bear Index
   m_ReactiveBullMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempBullArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_ReactiveBullStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempBullArray, 0, ADVANCE_INDICATOR_PERIOD), 2);

   m_ReactiveBearMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempBearArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_ReactiveBearStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempBearArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
  
   //--- Lagging Bull Bear Index
   m_LaggingBullMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempLaggingBullArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_LaggingBullStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempLaggingBullArray, 0, ADVANCE_INDICATOR_PERIOD), 2);

   m_LaggingBearMean[TimeFrameIndex][0] = NormalizeDouble(MathMean(tempLaggingBearArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
   m_LaggingBearStdDev[TimeFrameIndex][0] = NormalizeDouble(MathStandardDeviation(tempLaggingBearArray, 0, ADVANCE_INDICATOR_PERIOD), 2);
  
  
  
  
}

//+------------------------------------------------------------------+
//|  Get BullBear Index                                              |
//+------------------------------------------------------------------+

string  BullBearIndex::CalculateBullBear(int TimeFrameIndex,int Shift)
{
   // terminate if Shift > DEFAULT BUFFER SIZE
   if(Shift >= DEFAULT_BUFFER_SIZE)
      return "";

   double Bull_Index = 0;
   double Bear_Index = 0;
   double Total_Bull_Bear_Index = 0, Lagging_Total_Bull_Bear_Index = 0;

   ENUM_TIMEFRAMES TimeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);

   double Current_Applied_Price = Shift < CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift].GetClose() : iClose(Symbol(), TimeFrameENUM, Shift);
   double Previous_Applied_Price = Shift+1 < CANDLESTICKS_BUFFER_SIZE ? CandleSticksBuffer[TimeFrameIndex][Shift+1].GetClose() : iClose(Symbol(), TimeFrameENUM, Shift+1);

   
   // DI
   double DIHist = m_Indicators.GetADX().GetDIHist(TimeFrameIndex, Shift);
   double DIHistMean = m_Indicators.GetADX().GetDIMean(TimeFrameIndex, Shift);
   double DIHistStdDev = m_Indicators.GetADX().GetDIStdDev(TimeFrameIndex, Shift);

   double Current_DMI = m_Indicators.GetADX().GetDMI(TimeFrameIndex, Shift);
   double Previoius_DMI = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetADX().GetDMI(TimeFrameIndex, Shift+1) : m_Indicators.GetADX().CalculateDMI(TimeFrameENUM, Shift+1);


   if(DIHist > DIHistMean+(2*DIHistStdDev) && Current_DMI > Previoius_DMI)
   {
      Bull_Index+=2;   
      Total_Bull_Bear_Index+=2;     
   }  
   else if(DIHist > DIHistMean+(DIHistStdDev) && Current_DMI > Previoius_DMI)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;     
   }  
   else if(DIHist < DIHistMean-(2*DIHistStdDev) && Current_DMI > Previoius_DMI)
   {
      Bear_Index+=2;   
      Total_Bull_Bear_Index+=2; 
   }
   else if(DIHist < DIHistMean-(DIHistStdDev) && Current_DMI > Previoius_DMI)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++; 
   }
   
   Lagging_Total_Bull_Bear_Index+=2;
   
   
   // Bollinger Band
   double   Current_BandMain = m_Indicators.GetBands().GetMain(TimeFrameIndex, Shift);
   double   Previous_BandMain = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetBands().GetMain(TimeFrameIndex, Shift+1) : m_Indicators.GetBands().CalculateBandsMain(TimeFrameENUM, Shift+1);

   
   if(Current_Applied_Price > m_Indicators.GetBands().GetUpper(TimeFrameIndex, 2, Shift) && Current_BandMain > Previous_BandMain)
   { 
      Bull_Index+=2;
      Total_Bull_Bear_Index+=2;
   }
   else if(Current_Applied_Price < m_Indicators.GetBands().GetLower(TimeFrameIndex, 2, Shift) && Current_BandMain < Previous_BandMain)
   {
      Bear_Index+=2;
      Total_Bull_Bear_Index+=2;
   }
   else if(Current_Applied_Price > m_Indicators.GetBands().GetUpper(TimeFrameIndex, 1, Shift) && Current_BandMain > Previous_BandMain)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }
   else if(Current_Applied_Price < m_Indicators.GetBands().GetLower(TimeFrameIndex, 1, Shift) && Current_BandMain < Previous_BandMain)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++; 
   }
   
   Lagging_Total_Bull_Bear_Index+=2;


   // TenKan Kijun
   double TenKanKijunHist = m_Indicators.GetIchimoku().GetTenKanKijunHist(TimeFrameIndex, Shift);
   double TenKanKijunHistMean = m_Indicators.GetIchimoku().GetTenKanKijunHistMean(TimeFrameIndex, Shift);
   double TenKanKijunHistStdDev = m_Indicators.GetIchimoku().GetTenKanKijunHistStdDev(TimeFrameIndex, Shift);

   
   if(TenKanKijunHist > 0 
   && TenKanKijunHist > TenKanKijunHistMean + (2*TenKanKijunHistStdDev)
   && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index+=2;   
      Total_Bull_Bear_Index+=2;   
   }
   else if(TenKanKijunHist > 0 
   && TenKanKijunHist > TenKanKijunHistMean + TenKanKijunHistStdDev
   && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;   
   }
   else if(TenKanKijunHist < 0 
   && TenKanKijunHist < TenKanKijunHistMean - (2*TenKanKijunHistStdDev)
   && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index+=2;   
      Total_Bull_Bear_Index+=2;
   }
   else if(TenKanKijunHist < 0 
   && TenKanKijunHist < TenKanKijunHistMean - TenKanKijunHistStdDev
   && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }

   Lagging_Total_Bull_Bear_Index+=2;

   // Price & Kumo
   double SpanA0 = Shift-ICHIMOKU_NEGATIVE_SHIFT < ICHIMOKU_SPAN_BUFFER_SIZE ? m_Indicators.GetIchimoku().GetSenkouSpanA(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT): m_Indicators.GetIchimoku().CalculateSenkouSpanA(TimeFrameENUM, Shift);
   double SpanB0 = Shift-ICHIMOKU_NEGATIVE_SHIFT < ICHIMOKU_SPAN_BUFFER_SIZE ? m_Indicators.GetIchimoku().GetSenkouSpanB(TimeFrameIndex, Shift-ICHIMOKU_NEGATIVE_SHIFT) : m_Indicators.GetIchimoku().CalculateSenkouSpanB(TimeFrameENUM, Shift);
      
   
   if(Current_Applied_Price > SpanA0 && Current_Applied_Price > SpanB0 && Current_Applied_Price > Previous_Applied_Price)     
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }
   else if (Current_Applied_Price < SpanA0 && Current_Applied_Price < SpanB0 && Current_Applied_Price < Previous_Applied_Price) 
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }

   Lagging_Total_Bull_Bear_Index++;

   // Chikou Line
   double Current_Chikou = m_Indicators.GetIchimoku().GetChikouSpan(TimeFrameIndex, Shift);
   double Previous_Chikou = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetIchimoku().GetChikouSpan(TimeFrameIndex, Shift+1):m_Indicators.GetIchimoku().CalculateChikouSpan(TimeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT+1);
   
   
   if(Current_Chikou > iHigh(Symbol(), TimeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT) && Current_Chikou > Previous_Chikou)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }
   else if(Current_Chikou < iLow(Symbol(), TimeFrameENUM, Shift-ICHIMOKU_NEGATIVE_SHIFT) && Current_Chikou < Previous_Chikou)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }

   Lagging_Total_Bull_Bear_Index++;
   
   //   Moving Averages
   
   double   MA5 =    m_Indicators.GetMovingAverage().GetFastMA(TimeFrameIndex, Shift);
   double   MA20 =   m_Indicators.GetMovingAverage().GetMediumMA(TimeFrameIndex, Shift);
   double   MA50 =   m_Indicators.GetMovingAverage().GetSlowMA(TimeFrameIndex, Shift);
   double   MA200 =  m_Indicators.GetMovingAverage().GetMoneyLineMA(TimeFrameIndex, Shift);
   

   // MA Analysis - Price Action versus MA
   
   
   // MA 5
   if(Current_Applied_Price > MA5 && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }
   
   else if(Current_Applied_Price < MA5 && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }
   
   Lagging_Total_Bull_Bear_Index++; 
   
   // MA 20
   if(Current_Applied_Price > MA20 && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }

   else if(Current_Applied_Price < MA20 && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }
   
   Lagging_Total_Bull_Bear_Index++;
      
         
   // MA 50
   if(Current_Applied_Price > MA50 && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }
   
   else if(Current_Applied_Price < MA50 && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }
   
   Lagging_Total_Bull_Bear_Index++;
      
   // MA 200
   if(Current_Applied_Price > MA200 && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }
   
   else if(Current_Applied_Price < MA200 && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }

   Lagging_Total_Bull_Bear_Index++;

   // PSAR
   double PSAR = m_Indicators.GetSAR().GetSar(TimeFrameIndex, Shift);
   
   if(PSAR < iLow(Symbol(), TimeFrameENUM, Shift) && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++; 
   }
   else if(PSAR > iHigh(Symbol(), TimeFrameENUM, Shift) && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;     
   }

   Lagging_Total_Bull_Bear_Index++;


   // Bull Power Versus Bear Power
   double BullPower = m_Indicators.GetBullBearPower().GetBullPowerValue(TimeFrameIndex, Shift);
   double BearPower = m_Indicators.GetBullBearPower().GetBearPowerValue(TimeFrameIndex, Shift);
   
   double BullPowerMean = m_Indicators.GetBullBearPower().GetBullMean(TimeFrameIndex, Shift);
   double BearPowerMean = m_Indicators.GetBullBearPower().GetBearMean(TimeFrameIndex, Shift);
   double BullPowerStdDev = m_Indicators.GetBullBearPower().GetBullStdDev(TimeFrameIndex, Shift);
   double BearPowerStdDev = m_Indicators.GetBullBearPower().GetBearStdDev(TimeFrameIndex, Shift);


   if(BullPower > BullPowerMean + (2*BullPowerStdDev) && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index+=2;   
      Total_Bull_Bear_Index+=2;  
   }

   else if(BullPower > BullPowerMean + (BullPowerStdDev) && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;  
   }

   else if(BearPower > BearPowerMean + (2*BearPowerStdDev) && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index+=2;   
      Total_Bull_Bear_Index+=2;  
   }
   
   else if(BearPower > BearPowerMean + (BearPowerStdDev) && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;  
   }
   
   Lagging_Total_Bull_Bear_Index+=2;


   // CCI
   double curCCI = m_Indicators.GetCCI().GetCCIValue(TimeFrameIndex, Shift);
   double prevCCI = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetCCI().GetCCIValue(TimeFrameIndex, Shift+1) : m_Indicators.GetCCI().CalculateCCI(TimeFrameENUM, Shift+1);
   
   double CCIMean = m_Indicators.GetCCI().GetCCIMean(TimeFrameIndex, Shift);
   double CCIStdDev = m_Indicators.GetCCI().GetCCIStdDev(TimeFrameIndex, Shift);

   
   if(curCCI > CCIMean + (2*CCIStdDev) && curCCI > prevCCI)
   {
      Bull_Index+=2;   
      Total_Bull_Bear_Index+=2;  
   }
   
   else if(curCCI > CCIMean + (CCIStdDev) && curCCI > prevCCI)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;  
   }
   
   else if(curCCI < CCIMean - (2*CCIStdDev) && curCCI < prevCCI)
   {
      Bear_Index+=2;   
      Total_Bull_Bear_Index+=2;  
   }
   
   else if(curCCI < CCIMean - (CCIStdDev) && curCCI < prevCCI)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;  
   }

   Lagging_Total_Bull_Bear_Index+=2;

   // Force Index
   double FI = m_Indicators.GetForceIndex().GetForceIndexValue(TimeFrameIndex, Shift);
   double prevFI = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetForceIndex().GetForceIndexValue(TimeFrameIndex, Shift+1) : m_Indicators.GetForceIndex().CalculateForceIndex(TimeFrameENUM, Shift+1);
   
   double FIMean = m_Indicators.GetForceIndex().GetForceMean(TimeFrameIndex, Shift);
   double FIStdDev = m_Indicators.GetForceIndex().GetForceStdDev(TimeFrameIndex, Shift);



   if(FI > FIMean + (2*FIStdDev) && FI > prevFI)
   {
      Bull_Index+=2;   
      Total_Bull_Bear_Index+=2;  
   }
   
   else if(FI > FIMean + (FIStdDev) && FI > prevFI)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;  
   }
   
   else if(FI < FIMean - (2*FIStdDev) && FI < prevFI)
   {
      Bear_Index+=2;   
      Total_Bull_Bear_Index+=2;  
   }
   
   else if(FI < FIMean - (FIStdDev) && FI < prevFI)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;  
   }

   Lagging_Total_Bull_Bear_Index+=2;

   // MACD (lagging)
   double MACDHist = m_Indicators.GetMACD().GetHistogram(TimeFrameIndex, Shift);
      
   if(MACDHist > 0 && Current_Applied_Price > Previous_Applied_Price)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++;
   }
   else if(MACDHist < 0 && Current_Applied_Price < Previous_Applied_Price)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }

   Lagging_Total_Bull_Bear_Index++;

   // RSI
   double curRSI = m_Indicators.GetRSI().GetRSIValue(TimeFrameIndex, Shift);
   double prevRSI = Shift+1 < DEFAULT_BUFFER_SIZE ? m_Indicators.GetRSI().GetRSIValue(TimeFrameIndex, Shift+1) : m_Indicators.GetRSI().CalculateRSI(TimeFrameENUM, Shift+1);
   
   double RSIMean = m_Indicators.GetRSI().GetRSIMean(TimeFrameIndex, Shift);
   double RSIStdDev = m_Indicators.GetRSI().GetRSIStdDev(TimeFrameIndex, Shift);
   


   if(curRSI > RSIMean+(2*RSIStdDev) && curRSI > prevRSI)
   {
      Bull_Index+=2;   
      Total_Bull_Bear_Index+=2; 
   }
   else if(curRSI > RSIMean+(RSIStdDev) && curRSI > prevRSI)
   {
      Bull_Index++;   
      Total_Bull_Bear_Index++; 
   }
   else if(curRSI < RSIMean-(2*RSIStdDev) && curRSI < prevRSI)
   {
      Bear_Index+=2;   
      Total_Bull_Bear_Index+=2;
   }   
   else if(curRSI < RSIMean-(RSIStdDev) && curRSI < prevRSI)
   {
      Bear_Index++;   
      Total_Bull_Bear_Index++;
   }  

   Lagging_Total_Bull_Bear_Index+=2;
   
   // RVI
   double RVIHist = m_Indicators.GetRVI().GetRVIHist(TimeFrameIndex, Shift);

   
   if(RVIHist > 0)
   {
      Bull_Index++;
      Total_Bull_Bear_Index++;
   }
   
   else if(RVIHist < 0)
   {
      Bear_Index++;
      Total_Bull_Bear_Index++;
   }

   Lagging_Total_Bull_Bear_Index++;
   
   // STO
   double STOHist = m_Indicators.GetSTO().GetSTOHist(TimeFrameIndex, Shift);


   if(STOHist > 0)
   {
      Bull_Index++;
      Total_Bull_Bear_Index++;
   }
   
   else if(STOHist < 0)
   {
      Bear_Index++;
      Total_Bull_Bear_Index++;
   }
   
   Lagging_Total_Bull_Bear_Index++;
   
   
   //--- Calculation 
   double reactiveBuyPercent = NormalizeDouble((Bull_Index/Total_Bull_Bear_Index) * 100, 2);
   double laggingBuyPercent = NormalizeDouble((Bull_Index/Lagging_Total_Bull_Bear_Index) * 100, 2);


   // summarize the calculation (Calculation for StdDev/ Basic Calculation)
   if(Shift < INDEXES_BUFFER_SIZE)
   {
      m_ReactiveBullPercent[TimeFrameIndex][Shift] = reactiveBuyPercent;
      m_ReactiveBearPercent[TimeFrameIndex][Shift] = 100-reactiveBuyPercent;
      
      m_LaggingBullPercent[TimeFrameIndex][Shift] = laggingBuyPercent;
      m_LaggingBearPercent[TimeFrameIndex][Shift] = 100-laggingBuyPercent;
      
      return "";
   }

   return DoubleToString(reactiveBuyPercent, 2) + "/" + DoubleToString(laggingBuyPercent, 2);
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


ENUM_INDICATOR_POSITION BullBearIndex::GetReactiveBullPosition(int TimeFrameIndex,int Shift)
{
   if(m_ReactiveBullPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_ReactiveBullPercent[TimeFrameIndex][Shift] > GetReactiveBullUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_ReactiveBullPercent[TimeFrameIndex][Shift] > GetReactiveBullUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_ReactiveBullPercent[TimeFrameIndex][Shift] < GetReactiveBullLowerStdDev(TimeFrameIndex, Shift, 2))
      return Minus_2_StdDev;
      
   else if(m_ReactiveBullPercent[TimeFrameIndex][Shift] < GetReactiveBullLowerStdDev(TimeFrameIndex, Shift, 3))
      return Minus_3_StdDev;

   else if(m_ReactiveBullPercent[TimeFrameIndex][Shift] > m_ReactiveBullMean[TimeFrameIndex][Shift])
      return Above_Mean;
      
   else if(m_ReactiveBullPercent[TimeFrameIndex][Shift] == m_ReactiveBullMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_ReactiveBullPercent[TimeFrameIndex][Shift] < m_ReactiveBullMean[TimeFrameIndex][Shift])
      return Below_Mean;
   else
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION BullBearIndex::GetReactiveBearPosition(int TimeFrameIndex,int Shift)
{
   if(m_ReactiveBearPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_ReactiveBearPercent[TimeFrameIndex][Shift] > GetReactiveBearUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_ReactiveBearPercent[TimeFrameIndex][Shift] > GetReactiveBearUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
     
   else if(m_ReactiveBearPercent[TimeFrameIndex][Shift] < GetReactiveBearLowerStdDev(TimeFrameIndex, Shift, 2))
      return Minus_2_StdDev;
      
   else if(m_ReactiveBearPercent[TimeFrameIndex][Shift] < GetReactiveBearLowerStdDev(TimeFrameIndex, Shift, 3))
      return Minus_3_StdDev;

   else if(m_ReactiveBearPercent[TimeFrameIndex][Shift] > m_ReactiveBearMean[TimeFrameIndex][Shift])
      return Above_Mean;

   else if(m_ReactiveBearPercent[TimeFrameIndex][Shift] == m_ReactiveBearMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_ReactiveBearPercent[TimeFrameIndex][Shift] < m_ReactiveBearMean[TimeFrameIndex][Shift])
      return Below_Mean;
      
   else
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION BullBearIndex::GetLaggingBullPosition(int TimeFrameIndex,int Shift)
{
   if(m_LaggingBullPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_LaggingBullPercent[TimeFrameIndex][Shift] > GetLaggingBullUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_LaggingBullPercent[TimeFrameIndex][Shift] > GetLaggingBullUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
      
   else if(m_LaggingBullPercent[TimeFrameIndex][Shift] < GetLaggingBullLowerStdDev(TimeFrameIndex, Shift, 2))
      return Minus_2_StdDev;
      
   else if(m_LaggingBullPercent[TimeFrameIndex][Shift] < GetLaggingBullLowerStdDev(TimeFrameIndex, Shift, 3))
      return Minus_3_StdDev;

   else if(m_LaggingBullPercent[TimeFrameIndex][Shift] > m_LaggingBullMean[TimeFrameIndex][Shift])
      return Above_Mean;
      
   else if(m_LaggingBullPercent[TimeFrameIndex][Shift] == m_LaggingBullMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_LaggingBullPercent[TimeFrameIndex][Shift] < m_LaggingBullMean[TimeFrameIndex][Shift])
      return Below_Mean;
   else
      return Null;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_INDICATOR_POSITION BullBearIndex::GetLaggingBearPosition(int TimeFrameIndex,int Shift)
{
   if(m_LaggingBearPercent[TimeFrameIndex][Shift] == 0)
      return Null;

   else if(m_LaggingBearPercent[TimeFrameIndex][Shift] > GetLaggingBearUpperStdDev(TimeFrameIndex, Shift, 3))
      return Plus_3_StdDev;
      
   else if(m_LaggingBearPercent[TimeFrameIndex][Shift] > GetLaggingBearUpperStdDev(TimeFrameIndex, Shift, 2))
      return Plus_2_StdDev;
     
   else if(m_LaggingBearPercent[TimeFrameIndex][Shift] < GetLaggingBearLowerStdDev(TimeFrameIndex, Shift, 2))
      return Minus_2_StdDev;
      
   else if(m_LaggingBearPercent[TimeFrameIndex][Shift] < GetLaggingBearLowerStdDev(TimeFrameIndex, Shift, 3))
      return Minus_3_StdDev;

   else if(m_LaggingBearPercent[TimeFrameIndex][Shift] > m_LaggingBearMean[TimeFrameIndex][Shift])
      return Above_Mean;

   else if(m_LaggingBearPercent[TimeFrameIndex][Shift] == m_LaggingBearMean[TimeFrameIndex][Shift])
      return Equal_Mean;
      
   else if(m_LaggingBearPercent[TimeFrameIndex][Shift] < m_LaggingBearMean[TimeFrameIndex][Shift])
      return Below_Mean;
      
   else
      return Null;
      
}

//+------------------------------------------------------------------+