

//+------------------------------------------------------------------+
//|                                                     Analysis.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict


#include "..\AdvanceIndicator.mqh"
#include "..\Probability.mqh"
#include "..\ExternVariables.mqh"
#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


class Analysis{
   private:
      CandleStickArray           *m_CandleStickArray;
      IndicatorsHelper           *m_Indicators;
      AdvanceIndicator           *m_AdvIndicators;
      Probability                *m_Probability;
      
   
   
      string                     zzfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        zzfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];
   
      datetime                   NextZigZagDate[ENUM_TIMEFRAMES_ARRAY_SIZE];
      string                     NextZigZagTrend[ENUM_TIMEFRAMES_ARRAY_SIZE];
      double                     NextZigZagPrice[ENUM_TIMEFRAMES_ARRAY_SIZE];
   
   
      // bull bear index
      string                     bullbearindexfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        bullbearindexfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];
         
      // volatility
      string                     volatilityfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        volatilityfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];

      // OBOS
      string                     obosfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        obosfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];

      // IndicatorTrigger
      string                     indicatorfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        indicatorfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];
      
      // LineTrigger
      string                     linefilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        linefilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];
    
      // Cumm CandleStick
      string                     csfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        csfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];
  
      // Divergence
      string                     divfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        divfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];


      // ZigZag 
      string                     zigzagfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        zigzagfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];      


      // Bollinger Band Position 
      string                     bandfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        bandfilehandle[ENUM_TIMEFRAMES_ARRAY_SIZE];  

      // Trend Probability
      string                     trendprobabilityfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        trendprobabilityfilehamdle[ENUM_TIMEFRAMES_ARRAY_SIZE]; 


      // Market Bias
      string                     marketbiasfilename[ENUM_TIMEFRAMES_ARRAY_SIZE];
      int                        marketbiasfilehamdle[ENUM_TIMEFRAMES_ARRAY_SIZE]; 

  
      void                       DiscardHeader();
      void                       AdjustTimeToDateTime();
      void                       ReadNextAnalyzeDate(int TimeFrameIndex);
 
   public:
                                 Analysis(IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvIndicators, CandleStickArray *pCandleStickArray, Probability *pProbability);
                                 ~Analysis();
                                 
                                 
      bool                       Init();
      void                       OnUpdate(int TimeFrameIndex, bool IsNewBar);
      bool                       InitData();
      void                       OnUpdateData(int TimeFrameIndex);

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Analysis::Analysis(IndicatorsHelper *pIndicators, AdvanceIndicator *pAdvIndicators, CandleStickArray *pCandleStickArray, Probability *pProbability)
{
   m_CandleStickArray=NULL;
   m_Indicators=NULL;
   m_AdvIndicators = NULL;
   m_Probability = NULL;

   if(pCandleStickArray==NULL)
      LogError(__FUNCTION__,"CandleStick Array pointer is NULL");
   else
      m_CandleStickArray=pCandleStickArray; 

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"IndicatorHelper pointer is NULL");
   else
      m_Indicators=pIndicators; 

   if(pAdvIndicators==NULL)
      LogError(__FUNCTION__,"AdvIndicators pointer is NULL");
   else
      m_AdvIndicators=pAdvIndicators; 

   if(pProbability==NULL)
      LogError(__FUNCTION__,"Probability Indexes pointer is NULL");
   else
      m_Probability=pProbability;
      
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

Analysis::~Analysis()
{
   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      FileClose(zzfilehandle[i]);
      FileClose(zigzagfilehandle[i]);


      //FileClose(bullbearindexfilehandle[i]);
      /*
      FileClose(volatilityfilehandle[i]);
      FileClose(obosfilehandle[i]);
      FileClose(linefilehandle[i]);
      FileClose(csfilehandle[i]);
      FileClose(divfilehandle[i]);
      FileClose(bandfilehandle[i]);      
      FileClose(trendprobabilityfilehamdle[i]);
      FileClose(marketbiasfilehamdle[i]);
      */

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Analysis::Init()
{

   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {

      zzfilename[i]=ZIGZAG_FILENAME[i];
      zzfilehandle[i] = FileOpen(zzfilename[i], FILE_READ|FILE_CSV, ',');
         
      // file existence
      if(zzfilehandle[i] == -1)
      {
         LogError(__FUNCTION__, "File not Found. ");
         return false;
      }
      
      string timeFrameString=GetTimeFramesString(i);
      
      zigzagfilename[i] = Symbol() + "-"+timeFrameString+"-ZIGZAG.csv";
      zigzagfilehandle[i] = FileOpen(zigzagfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");
      
/*
      // creation of new files for getting the datas for data analysis
      bullbearindexfilename[i] = Symbol() + "-"+timeFrameString+"-BB.csv";
      bullbearindexfilehandle[i] = FileOpen(bullbearindexfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");
      
      bullbearindexMTFfilename[i] = Symbol() + "-"+timeFrameString+"-MTFBB.csv";
      bullbearindexMTFfilehandle[i] = FileOpen(bullbearindexMTFfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");
      
      csfilename[i] = Symbol() + "-"+timeFrameString+"-CS.csv";
      csfilehandle[i] = FileOpen(csfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");

      divfilename[i] = Symbol() + "-"+timeFrameString+"-DIV.csv";
      divfilehandle[i] = FileOpen(divfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");

      bandfilename[i] = Symbol() + "-"+timeFrameString+"-BAND.csv";
      bandfilehandle[i] = FileOpen(bandfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");

      
      ichimokufilename[i] = Symbol() + "-"+timeFrameString+"-ICHIMOKU.csv";
      ichimokufilehandle[i] = FileOpen(ichimokufilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");


      indicatorfilename[i] = Symbol() + "-"+timeFrameString+"-IND.csv";
      indicatorfilehandle[i] = FileOpen(indicatorfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");

      volatilityfilename[i] = Symbol() + "-"+timeFrameString+"-VOL.csv";
      volatilityfilehandle[i] = FileOpen(volatilityfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");

    
      obosfilename[i] = Symbol() + "-"+timeFrameString+"-OBOS.csv";
      obosfilehandle[i] = FileOpen(obosfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");
      
      
      linefilename[i] = Symbol() + "-"+timeFrameString+"-LINE.csv";
      linefilehandle[i] = FileOpen(linefilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");

      trendprobabilityfilename[i] = Symbol() + "-"+timeFrameString+"-TREND.csv";
      trendprobabilityfilehamdle[i] = FileOpen(trendprobabilityfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");
      
      marketbiasfilename[i] = Symbol() + "-"+timeFrameString+"-MB.csv";
      marketbiasfilehamdle[i] = FileOpen(marketbiasfilename[i], FILE_READ|FILE_WRITE|FILE_CSV, ",");
      */
      
      
   }

   InitData();
   DiscardHeader();
   AdjustTimeToDateTime();
   
   return true;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Analysis::OnUpdate(int TimeFrameIndex, bool IsNewBar)
{
   if(IsNewBar)
   {
      datetime dt=iTime(Symbol(), GetTimeFrameENUM(TimeFrameIndex), 0)-(60*15);
            
      if(dt==NextZigZagDate[TimeFrameIndex])
      {
         if(TimeFrameIndex == 0)
            OnUpdateData(TimeFrameIndex);
            
         ReadNextAnalyzeDate(TimeFrameIndex);
      }
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Analysis::InitData()
{
   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
   
      FileWrite(zigzagfilehandle[i], "Datetime", "Price", "Direction");
      
   
      //FileWrite(bullbearindexfilehandle[i], "Datetime", "BullPercent", "BullPosition", "BearPercent", "BearPosition", "BullCross", "BearCross", "Direction");  
      //FileWrite(bullbearindexMTFfilehandle[i], "Datetime", "LowBullPercent", "LowBearPercent", "HighBullPercent", "HighBearPercent", "Direction");  
      /*
      FileWrite(volatilityfilehandle[i], "Datetime", "VolatilityPercent", "VolatilityPosition", "Direction"); 
      FileWrite(obosfilehandle[i], "Datetime", "OBPercent", "OBPosition", "OSPercent", "OSPosition", "Direction"); 
      FileWrite(linefilehandle[i], "Datetime", "BullPercent", "BullPosition", "BearPercent", "BearPosition", "Direction");  
      FileWrite(linefilehandle[i], "Datetime", "BullPercent", "BullPosition", "BearPercent", "BearPosition", "Direction");
      FileWrite(csfilehandle[i], "Datetime", "CummBodyPercent", "CummBodyPosition", "CummTopWickPercent", "CummTopWickPosition", "CummBotWickPercent", "CummBotWickPosition", "Direction");
      FileWrite(divfilehandle[i], "Datetime", "DivergencePercent", "DivergenceType", "DivergenceOrderType", "Direction");

      FileWrite(bandfilehandle[i], "Datetime", "M15BandPosition", "H1BandPosition", "H4BandPosition", "D1BandPosition", "Direction");
      FileWrite(ichimokufilehandle[i], "Datetime", "M15ChikouPosition", "H1ChikouPosition", "H4ChikouPosition", "D1ChikouPosition", "Direction");
 
 
      FileWrite(volatilityfilehandle[i], "Datetime", "VolatilityPercent", "VolatilityPosition",
      "H1VolatilityPercent", "H1VolatilityPosition",
      "H4VolatilityPercent", "H4VolatilityPosition",
      "D1VolatilityPercent", "D1VolatilityPosition",
       "Direction");   
 
 
      FileWrite(obosfilehandle[i], "Datetime", "OBPercent", "OBPosition", "OSPercent", "OSPosition",
      "H1OBPercent", "H1OBPosition", "H1OSPercent", "H1OSPosition",
      "H4OBPercent", "H4OBPosition", "H4OSPercent", "H4OSPosition",
      "D1OBPercent", "D1OBPosition", "D1OSPercent", "D1OSPosition",
       "Direction");  
 
 
      FileWrite(linefilehandle[i], "Datetime", "BullPercent", "BullPosition", "BearPercent", "BearPosition",
      "H1BullPercent", "H1BullPosition", "H1BearPercent", "H1BearPosition",
      "H4BullPercent", "H4BullPosition", "H4BearPercent", "H4BearPosition",
      "D1BullPercent", "D1BullPosition", "D1BearPercent", "D1BearPosition",
       "Direction");  
      
      FileWrite(trendprobabilityfilehamdle[i], "Datetime", "BuyPercent", "BuyPosition", "SellPercent", "BSellPosition",
      "H1BuyPercent", "H1BuyPosition", "H1SellPercent", "H1SellPosition",
      "H4BuyPercent", "H4BuyPosition", "H4SellPercent", "H4SellPosition",
      "D1BuyPercent", "D1BuyPosition", "D1SellPercent", "D1SellPosition",
       "Direction");  
       
       
      FileWrite(marketbiasfilehamdle[i], "Datetime", "BuyPercent", "BuyPosition", "SellPercent", "BSellPosition",
      "H1BuyPercent", "H1BuyPosition", "H1SellPercent", "H1SellPosition",
      "H4BuyPercent", "H4BuyPosition", "H4SellPercent", "H4SellPosition",
      "D1BuyPercent", "D1BuyPosition", "D1SellPercent", "D1SellPosition",
       "Direction");  
      */          
 
   }
 
   return true;
     
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Analysis::OnUpdateData(int TimeFrameIndex)
{
   ENUM_TIMEFRAMES timeFrameENUM = GetTimeFrameENUM(TimeFrameIndex);
   
   for(int i =0 ; i < 3; i++)
   {
      datetime curtime = iTime(Symbol(), timeFrameENUM, i);
      string curtimestr = TimeToStr(curtime, TIME_DATE|TIME_MINUTES);
      
      double zigzag = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(timeFrameENUM, i);
      FileWrite(zigzagfilehandle[TimeFrameIndex], curtimestr, zigzag, NextZigZagTrend[TimeFrameIndex]); 
   }

/*
   // write previous 5 in one string line
   for(int i = 0; i < 3; i++)
   {  
      // ZigZag Values
      double bullval=m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(GetTimeFrameENUM(TimeFrameIndex), i);
      string bullposition=CharToStr(m_AdvIndicators.GetZigZagAdvIndicator().Get);
      FileWrite(zigzagfilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, NextZigZagTrend[TimeFrameIndex]);  

      double bullval=m_AdvIndicators.GetBullBear().GetBullPercent(TimeFrameIndex, i);
      double bearval=m_AdvIndicators.GetBullBear().GetBearPercent(TimeFrameIndex, i);
      string bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetBullBear().GetBullPosition(TimeFrameIndex, i));
      string bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetBullBear().GetBearPosition(TimeFrameIndex, i));
      bool isBullCross=m_AdvIndicators.GetBullBear().IsBullCrossOver(TimeFrameIndex, i);
      bool isBearCross=m_AdvIndicators.GetBullBear().IsBearCrossOver(TimeFrameIndex, i);
   
      // BullBear Index
      FileWrite(bullbearindexfilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, bearval, bearposition, isBullCross, isBearCross, NextZigZagTrend[TimeFrameIndex]);      
   
   
      double ltfbullval=m_AdvIndicators.GetBullBear().GetBullPercent(TimeFrameIndex, i);
      double ltfbearval=m_AdvIndicators.GetBullBear().GetBearPercent(TimeFrameIndex, i);
      
      double htfbullval=0;
      double htfbearval=0;
      
      if(TimeFrameIndex+1 < ENUM_TIMEFRAMES_ARRAY_SIZE)
      {
         htfbullval=m_AdvIndicators.GetBullBear().GetBullPercent(TimeFrameIndex+1, i);
         htfbearval=m_AdvIndicators.GetBullBear().GetBearPercent(TimeFrameIndex+1, i);
      }
   
      // BullBear Index
      FileWrite(bullbearindexMTFfilehandle[TimeFrameIndex], curtimestr, ltfbullval, ltfbearval, htfbullval, htfbearval, NextZigZagTrend[TimeFrameIndex]); 
      
      /*
      // Volatility
      bullval=m_AdvIndicators.GetVolatility().GetVolatilityPercent(TimeFrameIndex, i);
      bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, i));
      
      FileWrite(volatilityfilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, NextZigZagTrend[TimeFrameIndex]);
      
      
      // OBOS
      bullval=m_AdvIndicators.GetOBOS().GetOBPercent(TimeFrameIndex, i);
      bearval=m_AdvIndicators.GetOBOS().GetOSPercent(TimeFrameIndex, i);
      bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOBPosition(TimeFrameIndex, i));
      bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOSPosition(TimeFrameIndex, i));
      FileWrite(obosfilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, bearval, bearposition, NextZigZagTrend[TimeFrameIndex]);
            
      // Line Trigger
      bullval=m_AdvIndicators.GetLineTrigger().GetBuyPercent(TimeFrameIndex, i);
      bearval=m_AdvIndicators.GetLineTrigger().GetSellPercent(TimeFrameIndex, i);
      bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetBuyPosition(TimeFrameIndex, i));
      bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetSellPosition(TimeFrameIndex, i));
      FileWrite(linefilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, bearval, bearposition, NextZigZagTrend[TimeFrameIndex]);  
       

      // Cummulative Candlestick Analysis
      bullval=m_CandleStickArray.GetCummTopWickPercent(TimeFrameIndex, i);
      bearval=m_CandleStickArray.GetCummBotWickPercent(TimeFrameIndex, i);
      bullposition=GetEnumIndicatorPositionString(m_CandleStickArray.GetCummTopPosition(TimeFrameIndex, i));
      bearposition=GetEnumIndicatorPositionString(m_CandleStickArray.GetCummBotPosition(TimeFrameIndex, i));
      FileWrite(csfilehandle[TimeFrameIndex], curtimestr,
      m_CandleStickArray.GetCummBodyPercent(TimeFrameIndex, i), GetEnumIndicatorPositionString(m_CandleStickArray.GetCummBodyPosition(TimeFrameIndex, i)),
       bullval, bullposition, bearval, bearposition, NextZigZagTrend[TimeFrameIndex]);  


      // Divergence 
      bullval=m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergencePercent(TimeFrameIndex, i);
      bullposition=m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(TimeFrameIndex, i);
      int divordertype=m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceOrderType(TimeFrameIndex, i);
      FileWrite(divfilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, divordertype, NextZigZagTrend[TimeFrameIndex]);  
      



      // Band Position
      string bullposition=GetEnumIndicatorPositionString(m_Indicators.GetBands().GetPricePosition(TimeFrameIndex, i));
      
      // multi-timeframe
      string h1bullposition=GetEnumIndicatorPositionString(m_Indicators.GetBands().GetPricePosition(1, i));
      string h4bullposition=GetEnumIndicatorPositionString(m_Indicators.GetBands().GetPricePosition(2, i));
      string d1bullposition=GetEnumIndicatorPositionString(m_Indicators.GetBands().GetPricePosition(3, i));
      
      FileWrite(bandfilehandle[TimeFrameIndex], curtimestr, bullposition, h1bullposition, h4bullposition, d1bullposition, NextZigZagTrend[TimeFrameIndex]);  

      // Chikou Position
      bullposition=GetTrend(m_Indicators.GetIchimoku().GetChikouPosition(TimeFrameIndex, i));
      
      // multi-timeframe
      h1bullposition=GetTrend(m_Indicators.GetIchimoku().GetChikouPosition(1, i));
      h4bullposition=GetTrend(m_Indicators.GetIchimoku().GetChikouPosition(2, i));
      d1bullposition=GetTrend(m_Indicators.GetIchimoku().GetChikouPosition(3, i));
      
      
      FileWrite(ichimokufilehandle[TimeFrameIndex], curtimestr, bullposition, h1bullposition, h4bullposition, d1bullposition, NextZigZagTrend[TimeFrameIndex]);  



      // Indicator Trigger
      double bullval=m_AdvIndicators.GetIndicatorsTrigger().GetBuyPercent(TimeFrameIndex, i);
      double bearval=m_AdvIndicators.GetIndicatorsTrigger().GetSellPercent(TimeFrameIndex, i);
      string bullposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetBuyMeanTrend(TimeFrameIndex, i));
      string bearposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetSellMeanTrend(TimeFrameIndex, i));
      
      double h1bullval=m_AdvIndicators.GetIndicatorsTrigger().GetBuyPercent(1, i);
      double h4bullval=m_AdvIndicators.GetIndicatorsTrigger().GetBuyPercent(2, i);
      double d1bullval=m_AdvIndicators.GetIndicatorsTrigger().GetBuyPercent(3, i);
      
      double h1bearval=m_AdvIndicators.GetIndicatorsTrigger().GetSellPercent(1, i);
      double h4bearval=m_AdvIndicators.GetIndicatorsTrigger().GetSellPercent(2, i);
      double d1bearval=m_AdvIndicators.GetIndicatorsTrigger().GetSellPercent(3, i);
      
      string h1bullposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetBuyMeanTrend(1, i));
      string h4bullposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetBuyMeanTrend(2, i));
      string d1bullposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetBuyMeanTrend(3, i));
   
      string h1bearposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetSellMeanTrend(1, i));
      string h4bearposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetSellMeanTrend(2, i));
      string d1bearposition=GetTrend(m_AdvIndicators.GetIndicatorsTrigger().GetSellMeanTrend(3, i));
      
      FileWrite(indicatorfilehandle[TimeFrameIndex], curtimestr, NextZigZagPrice[TimeFrameIndex], bullval, bullposition, bearval, bearposition, 
      h1bullval, h1bullposition, h1bearval, h1bearposition,
      h4bullval, h4bullposition, h4bearval, h4bearposition,
      d1bullval, d1bullposition, d1bearval, d1bearposition,
      NextZigZagTrend[TimeFrameIndex]);  


      // Line Trigger
      double bullval=m_AdvIndicators.GetLineTrigger().GetBuyPercent(TimeFrameIndex, i);
      double bearval=m_AdvIndicators.GetLineTrigger().GetSellPercent(TimeFrameIndex, i);
      string bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetBuyPosition(TimeFrameIndex, i));
      string bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetSellPosition(TimeFrameIndex, i));
      
      double h1bullval=m_AdvIndicators.GetLineTrigger().GetBuyPercent(1, i);
      double h4bullval=m_AdvIndicators.GetLineTrigger().GetBuyPercent(2, i);
      double d1bullval=m_AdvIndicators.GetLineTrigger().GetBuyPercent(3, i);
      
      double h1bearval=m_AdvIndicators.GetLineTrigger().GetSellPercent(1, i);
      double h4bearval=m_AdvIndicators.GetLineTrigger().GetSellPercent(2, i);
      double d1bearval=m_AdvIndicators.GetLineTrigger().GetSellPercent(3, i);

      string h1bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetBuyPosition(1, i));
      string h4bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetBuyPosition(2, i));
      string d1bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetBuyPosition(3, i));
   
      string h1bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetSellPosition(1, i));
      string h4bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetSellPosition(2, i));
      string d1bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetSellPosition(3, i));



      FileWrite(linefilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, bearval, bearposition, 
      h1bullval, h1bullposition, h1bearval, h1bearposition,
      h4bullval, h4bullposition, h4bearval, h4bearposition,
      d1bullval, d1bullposition, d1bearval, d1bearposition,
      NextZigZagTrend[TimeFrameIndex]);  


      // OBOS
      bullval=m_AdvIndicators.GetOBOS().GetOBPercent(TimeFrameIndex, i);
      bearval=m_AdvIndicators.GetOBOS().GetOSPercent(TimeFrameIndex, i);
      bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOBPosition(TimeFrameIndex, i));
      bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOSPosition(TimeFrameIndex, i));

      h1bullval=m_AdvIndicators.GetOBOS().GetOBPercent(1, i);
      h4bullval=m_AdvIndicators.GetOBOS().GetOBPercent(2, i);
      d1bullval=m_AdvIndicators.GetOBOS().GetOBPercent(3, i);

      h1bearval=m_AdvIndicators.GetOBOS().GetOSPercent(1, i);
      h4bearval=m_AdvIndicators.GetOBOS().GetOSPercent(2, i);
      d1bearval=m_AdvIndicators.GetOBOS().GetOSPercent(3, i);
      
      h1bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOBPosition(1, i));
      h4bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOBPosition(2, i));
      d1bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOBPosition(3, i));

      h1bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOSPosition(1, i));
      h4bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOSPosition(2, i));
      d1bearposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOSPosition(3, i));


      FileWrite(obosfilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, bearval, bearposition, 
      h1bullval, h1bullposition, h1bearval, h1bearposition,
      h4bullval, h4bullposition, h4bearval, h4bearposition,
      d1bullval, d1bullposition, d1bearval, d1bearposition,
      NextZigZagTrend[TimeFrameIndex]);  

      
      
      // Volatility
      bullval=m_AdvIndicators.GetVolatility().GetVolatilityPercent(TimeFrameIndex, i);
      bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, i));
      
      h1bullval=m_AdvIndicators.GetVolatility().GetVolatilityPercent(1, i);
      h4bullval=m_AdvIndicators.GetVolatility().GetVolatilityPercent(2, i);
      d1bullval=m_AdvIndicators.GetVolatility().GetVolatilityPercent(3, i);
      
      h1bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, i));
      h4bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, i));
      d1bullposition=GetEnumIndicatorPositionString(m_AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, i));

      FileWrite(volatilityfilehandle[TimeFrameIndex], curtimestr, bullval, bullposition, 
      h1bullval, h1bullposition,
      h4bullval, h4bullposition,
      d1bullval, d1bullposition,
      NextZigZagTrend[TimeFrameIndex]);  



      // Market Bias
      double bullval=m_AdvIndicators.GetMarketBias().GetBuyPercent(0, i);
      string bullposition=GetTrend(m_AdvIndicators.GetMarketBias().GetBuyMeanTrend(0, i));
      
      double h1bullval=m_AdvIndicators.GetMarketBias().GetBuyPercent(1, i);
      double h4bullval=m_AdvIndicators.GetMarketBias().GetBuyPercent(2, i);
      double d1bullval=m_AdvIndicators.GetMarketBias().GetBuyPercent(3, i);
      
      string h1bullposition=GetTrend(m_AdvIndicators.GetMarketBias().GetBuyMeanTrend(1, i));
      string h4bullposition=GetTrend(m_AdvIndicators.GetMarketBias().GetBuyMeanTrend(2, i));
      string d1bullposition=GetTrend(m_AdvIndicators.GetMarketBias().GetBuyMeanTrend(3, i));
      
      double bearval = m_AdvIndicators.GetMarketBias().GetSellPercent(0, i);
      string bearposition = GetTrend(m_AdvIndicators.GetMarketBias().GetSellMeanTrend(0, i));
      
      double h1bearval=m_AdvIndicators.GetMarketBias().GetSellPercent(1, i);
      double h4bearval=m_AdvIndicators.GetMarketBias().GetSellPercent(2, i);
      double d1bearval=m_AdvIndicators.GetMarketBias().GetSellPercent(3, i);
      
      string h1bearposition=GetTrend(m_AdvIndicators.GetMarketBias().GetSellMeanTrend(1, i));
      string h4bearposition=GetTrend(m_AdvIndicators.GetMarketBias().GetSellMeanTrend(2, i));
      string d1bearposition=GetTrend(m_AdvIndicators.GetMarketBias().GetSellMeanTrend(3, i));
      
      

      FileWrite(marketbiasfilehamdle[TimeFrameIndex], curtimestr, bullval, bullposition, bearval, bearposition,
      h1bullval, h1bullposition, h1bearval, h1bearposition,
      h4bullval, h4bullposition, h4bearval, h4bearposition,
      d1bullval, d1bullposition, d1bearval, d1bearposition,
      NextZigZagTrend[TimeFrameIndex]); 



      // Trend Probability
      bullval=m_Probability.GetTrendProbability().GetBuyTrendProbability(0, i);
      bullposition=GetTrend(m_Probability.GetTrendProbability().GetBuyMeanTrend(0, i));
      
      h1bullval=m_Probability.GetTrendProbability().GetBuyTrendProbability(1, i);
      h4bullval=m_Probability.GetTrendProbability().GetBuyTrendProbability(2, i);
      d1bullval=m_Probability.GetTrendProbability().GetBuyTrendProbability(3, i);
      
      h1bullposition=GetTrend(m_Probability.GetTrendProbability().GetBuyMeanTrend(1, i));
      h4bullposition=GetTrend(m_Probability.GetTrendProbability().GetBuyMeanTrend(2, i));
      d1bullposition=GetTrend(m_Probability.GetTrendProbability().GetBuyMeanTrend(3, i));
      
      bearval = m_Probability.GetTrendProbability().GetSellTrendProbability(0, i);
      bearposition = GetTrend(m_Probability.GetTrendProbability().GetSellMeanTrend(0, i));
      
      h1bearval=m_Probability.GetTrendProbability().GetSellTrendProbability(1, i);
      h4bearval=m_Probability.GetTrendProbability().GetSellTrendProbability(2, i);
      d1bearval=m_Probability.GetTrendProbability().GetSellTrendProbability(3, i);
      
      h1bearposition=GetTrend(m_Probability.GetTrendProbability().GetSellMeanTrend(1, i));
      h4bearposition=GetTrend(m_Probability.GetTrendProbability().GetSellMeanTrend(2, i));
      d1bearposition=GetTrend(m_Probability.GetTrendProbability().GetSellMeanTrend(3, i));
      
      FileWrite(trendprobabilityfilehamdle[TimeFrameIndex], curtimestr, bullval, bullposition, bearval, bearposition,
      h1bullval, h1bullposition, h1bearval, h1bearposition,
      h4bullval, h4bullposition, h4bearval, h4bearposition,
      d1bullval, d1bullposition, d1bearval, d1bearposition,
      NextZigZagTrend[TimeFrameIndex]); 

   }   

      */

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Analysis::DiscardHeader()
{
   for(int i = 0; i < ArraySize(zzfilehandle); i++)
   {
      if(!FileIsEnding(zzfilehandle[i]))
      {
         // read off the header
         FileReadString(zzfilehandle[i]);
         FileReadString(zzfilehandle[i]);
         FileReadString(zzfilehandle[i]);
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Analysis::AdjustTimeToDateTime()
{
   datetime curtime=TimeCurrent();
   
   for(int i =0 ; i < ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
   {
      while(curtime > NextZigZagDate[i])
         ReadNextAnalyzeDate(i);
   }
   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Analysis::ReadNextAnalyzeDate(int TimeFrameIndex)
{
   if(!FileIsEnding(zzfilehandle[TimeFrameIndex]))
   {
      NextZigZagDate[TimeFrameIndex]=StrToTime(FileReadString(zzfilehandle[TimeFrameIndex]));
      NextZigZagPrice[TimeFrameIndex]=StringToDouble(FileReadString(zzfilehandle[TimeFrameIndex]));
      NextZigZagTrend[TimeFrameIndex]=FileReadString(zzfilehandle[TimeFrameIndex]);
   }
}

//+------------------------------------------------------------------+
