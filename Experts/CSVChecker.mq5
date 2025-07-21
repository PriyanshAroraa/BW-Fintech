//+------------------------------------------------------------------+
//|                                                   CSVChecker.mq4 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include    "..\iForexDNA\ExternVariables.mqh"
#include    "..\iForexDNA\hash.mqh"
#include    "..\iForexDNA\MiscFunc.mqh"
#include    "..\iForexDNA\Enums.mqh"
#include    "..\iForexDNA\CandleStick\CandleStick.mqh"
#include    "..\iForexDNA\CandleStick\CandleStickArray.mqh"

#include    "..\iForexDNA\IndicatorsHelper.mqh"
#include    "..\iForexDNA\AdvanceIndicator.mqh"


CandleStickArray     CSAnalysis;
IndicatorsHelper     Indicators;
AdvanceIndicator     AdvIndicators(&Indicators);

//--- Indicators Handlers
int zzhandler = INVALID_HANDLE;
int fractalhandler = INVALID_HANDLE;
int pivothandler = INVALID_HANDLE;
int volhandler = INVALID_HANDLE;
int mahandler = INVALID_HANDLE;
int obvhandler = INVALID_HANDLE;
int rsihandler = INVALID_HANDLE;
int rvihandler = INVALID_HANDLE;
int cshandler = INVALID_HANDLE;
int ichimokuhandler = INVALID_HANDLE;
int macdhandler = INVALID_HANDLE;
int momhandler = INVALID_HANDLE;
int ccihandler = INVALID_HANDLE;
int bullbearpowerhandler = INVALID_HANDLE;
int stohandler = INVALID_HANDLE;
int sarhandler = INVALID_HANDLE;
int adxhandler = INVALID_HANDLE;
int atrhandler = INVALID_HANDLE;
int bbhandler = INVALID_HANDLE;
int forcehandler = INVALID_HANDLE;
int acchandler = INVALID_HANDLE;
int mfihandler = INVALID_HANDLE;
int keltnerhandler = INVALID_HANDLE;


//--- Advance Indicators Handlers
int zzadvhandler = INVALID_HANDLE;
int divhandler = INVALID_HANDLE;
int bbindexhandler = INVALID_HANDLE;
int volindexhandler = INVALID_HANDLE;
int oboshandler = INVALID_HANDLE;
int indicatorhandler = INVALID_HANDLE;
int linehandler = INVALID_HANDLE;
int middlehandler = INVALID_HANDLE;
int marketmomentumhandler = INVALID_HANDLE;
int markettrendhandler = INVALID_HANDLE;

enum testingType
{
   IsIndicator,
   IsAdvanceIndicator
};

input testingType type = IsIndicator;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   if(!CSAnalysis.Init())
   {
      printf("CSAnalysis.Init() Failed");
      return(REASON_INITFAILED);
   }

   if(!Indicators.Init())
   {
      printf("Indicators.Init() Failed");
      return(REASON_INITFAILED);
   }

   if(!AdvIndicators.Init())
   {
      printf("Indicators.Init() Failed");
      return(REASON_INITFAILED);
   }
   
   //--- Indicator Testing
   if(type == IsIndicator)
   {
      OpenIndicatorFiles();
      InitIndicatorsHeader();
   }
   else
   {
      OpenAdvanceIndicatorFile();
      InitAdvanceHeader();
   }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(type == IsIndicator)
   {
      FileClose(zzhandler);
      FileClose(fractalhandler);
      FileClose(pivothandler);
      FileClose(volhandler);
      FileClose(mahandler);
      FileClose(obvhandler);
      FileClose(rsihandler);
      FileClose(rvihandler);
      FileClose(cshandler);
      FileClose(ichimokuhandler);
      FileClose(macdhandler);
      FileClose(momhandler);
      FileClose(ccihandler);
      FileClose(bullbearpowerhandler);
      FileClose(stohandler);
      FileClose(sarhandler);
      FileClose(adxhandler);
      FileClose(atrhandler);
      FileClose(bbhandler);
      FileClose(forcehandler);
      FileClose(acchandler);
      FileClose(mfihandler);
      FileClose(keltnerhandler);
      Print("Closed All Indicator File...");
   }
   
   else if(type == IsAdvanceIndicator)
   {
      FileClose(zzadvhandler);
      FileClose(divhandler);
      FileClose(bbindexhandler);
      FileClose(volindexhandler);
      FileClose(oboshandler);
      FileClose(indicatorhandler);
      FileClose(linehandler);
      FileClose(middlehandler);
      FileClose(marketmomentumhandler);
      FileClose(markettrendhandler);
      Print("Closed All Advancce Indicator File...");
   }
   
  
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   bool ism15newbar = CheckIsNewBar(PERIOD_M15);

   // On Update Values
   CSAnalysis.OnUpdate(2, ism15newbar);
   Indicators.OnUpdate(2, ism15newbar);
   AdvIndicators.OnUpdate(2, ism15newbar);
   
   if(ism15newbar)
   {
      if(type == IsIndicator)
         OnUpdateIndicatorValues();
      else
         OnUpdateAdvanceValues();
      
   }
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OpenIndicatorFiles()
{
   string timeFrameString = GetTimeFramesString(PERIOD_M15);
   
   // Creation of new files for data analysis
   
   // ZigZag
   string zzfilename = Symbol() + "-" + timeFrameString + "-ZZ.csv";
   zzhandler = FileOpen(zzfilename, FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI, ",");
   
   // Fractal
   string fractalfilename = Symbol() + "-" + timeFrameString + "-Fractal.csv";
   fractalhandler = FileOpen(fractalfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Pivot
   string pivotfilename = Symbol() + "-" + timeFrameString + "-Pivot.csv";
   pivothandler = FileOpen(pivotfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Volume
   string volfilename = Symbol() + "-" + timeFrameString + "-Volume.csv";
   volhandler = FileOpen(volfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Moving Average
   string mafilename = Symbol() + "-" + timeFrameString + "-MA.csv";
   mahandler = FileOpen(mafilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // On Balance Volume
   string obvfilename = Symbol() + "-" + timeFrameString + "-OBV.csv";
   obvhandler = FileOpen(obvfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // RSI
   string rsifilename = Symbol() + "-" + timeFrameString + "-RSI.csv";
   rsihandler = FileOpen(rsifilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // RVI
   string rvifilename = Symbol() + "-" + timeFrameString + "-RVI.csv";
   rvihandler = FileOpen(rvifilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // CandleStick
   string csfilename = Symbol() + "-" + timeFrameString + "-CS.csv";
   cshandler = FileOpen(csfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Ichimoku
   string ichimokufilename = Symbol() + "-" + timeFrameString + "-Ichimoku.csv";
   ichimokuhandler = FileOpen(ichimokufilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // MACD
   string macdfilename = Symbol() + "-" + timeFrameString + "-MACD.csv";
   macdhandler = FileOpen(macdfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Momentum
   string momfilename = Symbol() + "-" + timeFrameString + "-Momentum.csv";
   momhandler = FileOpen(momfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // CCI
   string ccifilename = Symbol() + "-" + timeFrameString + "-CCI.csv";
   ccihandler = FileOpen(ccifilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Bull/Bear Power
   string bullbearfilename = Symbol() + "-" + timeFrameString + "-BullBear.csv";
   bullbearpowerhandler = FileOpen(bullbearfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Stochastic
   string stofilename = Symbol() + "-" + timeFrameString + "-STO.csv";
   stohandler = FileOpen(stofilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // SAR
   string sarfilename = Symbol() + "-" + timeFrameString + "-SAR.csv";
   sarhandler = FileOpen(sarfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

   // ADX
   string adxfilename = Symbol() + "-" + timeFrameString + "-ADX.csv";
   adxhandler = FileOpen(adxfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

   // ATR
   string atrfilename = Symbol() + "-" + timeFrameString + "-ATR.csv";
   atrhandler = FileOpen(atrfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Bollinger Bands
   string bbfilename = Symbol() + "-" + timeFrameString + "-BB.csv";
   bbhandler = FileOpen(bbfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Force Index
   string forcefilename = Symbol() + "-" + timeFrameString + "-Force.csv";
   forcehandler = FileOpen(forcefilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Acceleration/Deceleration
   string accfilename = Symbol() + "-" + timeFrameString + "-Acc.csv";
   acchandler = FileOpen(accfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Money Flow Index
   string mfifilename = Symbol() + "-" + timeFrameString + "-MFI.csv";
   mfihandler = FileOpen(mfifilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Keltner Channel
   string keltnerfilename = Symbol() + "-" + timeFrameString + "-Keltner.csv";
   keltnerhandler = FileOpen(keltnerfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Check for file open errors
   CheckFileOpenErrors();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Helper function to check if files were opened successfully
void CheckFileOpenErrors()
{
   if(zzhandler == INVALID_HANDLE) Print("Failed to open ZigZag file");
   if(fractalhandler == INVALID_HANDLE) Print("Failed to open Fractal file");
   if(pivothandler == INVALID_HANDLE) Print("Failed to open Pivot file");
   if(volhandler == INVALID_HANDLE) Print("Failed to open Volume file");
   if(mahandler == INVALID_HANDLE) Print("Failed to open MA file");
   if(obvhandler == INVALID_HANDLE) Print("Failed to open OBV file");
   if(rsihandler == INVALID_HANDLE) Print("Failed to open RSI file");
   if(rvihandler == INVALID_HANDLE) Print("Failed to open RVI file");
   if(cshandler == INVALID_HANDLE) Print("Failed to open Custom file");
   if(ichimokuhandler == INVALID_HANDLE) Print("Failed to open Ichimoku file");
   if(macdhandler == INVALID_HANDLE) Print("Failed to open MACD file");
   if(momhandler == INVALID_HANDLE) Print("Failed to open Momentum file");
   if(ccihandler == INVALID_HANDLE) Print("Failed to open CCI file");
   if(bullbearpowerhandler == INVALID_HANDLE) Print("Failed to open BullBear file");
   if(stohandler == INVALID_HANDLE) Print("Failed to open Stochastic file");
   if(sarhandler == INVALID_HANDLE) Print("Failed to open SAR file");
   if(atrhandler == INVALID_HANDLE) Print("Failed to open ATR file");
   if(bbhandler == INVALID_HANDLE) Print("Failed to open Bollinger Bands file");
   if(forcehandler == INVALID_HANDLE) Print("Failed to open Force Index file");
   if(acchandler == INVALID_HANDLE) Print("Failed to open Acceleration file");
   if(mfihandler == INVALID_HANDLE) Print("Failed to open MFI file");
   if(keltnerhandler == INVALID_HANDLE) Print("Failed to open Keltner file");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitIndicatorsHeader()
{
//--- Indicators Sections

   FileWrite(zzhandler, "Datetime", "Price");
   FileFlush(zzhandler);
   
   FileWrite(fractalhandler, "Datetime", "Resistance", "Support");
   FileFlush(fractalhandler);
   
   FileWrite(pivothandler, "Datetime", "S1", "S2", "S3");
   FileFlush(pivothandler);
   
   FileWrite(volhandler, "Datetime", "Volume", "VolMean", "VolStdDev");
   FileFlush(volhandler);
   
   FileWrite(mahandler, "Datetime", "MA5", "MA20", "MA50", "MA200");
   FileFlush(mahandler);
   
   FileWrite(obvhandler, "Datetime", "OBV", "OBVMean", "OBVStdDev");
   FileFlush(obvhandler);
   
   FileWrite(rsihandler, "Datetime", "RSI", "RSIMean", "RSIStdDev");
   FileFlush(rsihandler);
   
   FileWrite(rvihandler, "Datetime", "RVI", "RVIMean", "RVIStdDev");
   FileFlush(rvihandler);
   
   FileWrite(cshandler, "Datetime", "CSBody", "CSTopWick", "CSBotWick");
   FileFlush(cshandler);
   
   FileWrite(ichimokuhandler, "Datetime", "TKHist", "Chikou", "SpanA", "SpanB");
   FileFlush(ichimokuhandler);
   
   FileWrite(macdhandler, "Datetime", "Hist", "Mean", "StdDev");
   FileFlush(macdhandler);
   
   FileWrite(momhandler, "Datetime", "MoM", "Mean", "StdDev");
   FileFlush(momhandler);
   
   FileWrite(ccihandler, "Datetime", "CCI", "Mean", "StdDev");
   FileFlush(ccihandler);
   
   FileWrite(bullbearpowerhandler, "Datetime", "BullPower", "BearPower");
   FileFlush(bullbearpowerhandler);
   
   FileWrite(stohandler, "Datetime", "STOHist", "Mean", "StdDev");
   FileFlush(stohandler);
   
   FileWrite(sarhandler, "Datetime", "Value");
   FileFlush(sarhandler);
   
   FileWrite(atrhandler, "Datetime", "ATR", "Mean", "StdDev");
   FileFlush(atrhandler);
   
   FileWrite(bbhandler, "Datetime", "Main", "Upper", "Lower");
   FileFlush(bbhandler);
   
   FileWrite(forcehandler, "Datetime", "Force", "Mean", "StdDev");
   FileFlush(forcehandler);
   
   FileWrite(acchandler, "Datetime", "Acc", "Mean", "StdDev");
   FileFlush(acchandler);
   
   FileWrite(mfihandler, "Datetime", "Mfi", "Mean", "StdDev");
   FileFlush(mfihandler);
   
   FileWrite(keltnerhandler, "Datetime", "Main", "Upper", "Lower");
   FileFlush(keltnerhandler);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OpenAdvanceIndicatorFile()
{
   string timeFrameString = GetTimeFramesString(PERIOD_M15);

   // zz
   string zzadvfilename = Symbol() + "-" + timeFrameString + "-ZZADV.csv";
   zzadvhandler = FileOpen(zzadvfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

   // div
   string divfilename = Symbol() + "-" + timeFrameString + "-DIV.csv";
   divhandler = FileOpen(divfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

   // bb index
   string bbindexfilename = Symbol() + "-" + timeFrameString + "-BBINDEX.csv";
   bbindexhandler = FileOpen(bbindexfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // vol index
   string volindexfilename = Symbol() + "-" + timeFrameString + "-VOLINDEX.csv";
   volindexhandler = FileOpen(volindexfilename, FILE_READ| FILE_WRITE | FILE_CSV, ",");
   
   // OBOS index
   string obosfilename = Symbol() + "-" + timeFrameString + "-OBOS.csv";
   oboshandler = FileOpen(obosfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // Indicator index
   string indicatorfilename = Symbol() + "-" + timeFrameString + "-IND.csv";
   indicatorhandler = FileOpen(indicatorfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

   // line index
   string linefilename = Symbol() + "-" + timeFrameString + "-LINE.csv";
   linehandler = FileOpen(linefilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

   // market momentum
   string marketmomentumfilename = Symbol() + "-" + timeFrameString + "-MOMADV.csv";
   marketmomentumhandler = FileOpen(marketmomentumfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");
   
   // market trend
   string markettrendfilename = Symbol() + "-" + timeFrameString + "-TREND.csv";
   markettrendhandler = FileOpen(markettrendfilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

   // MiddleLine
   string middlinefilename = Symbol() + "-" + timeFrameString + "-MIDDLELINE.csv";
   middlehandler = FileOpen(middlinefilename, FILE_READ | FILE_WRITE | FILE_CSV, ",");

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void InitAdvanceHeader()
{
   FileWrite(zzadvhandler, "Datetime", "Price");
   FileFlush(zzadvhandler);

   FileWrite(divhandler, "Datetime", "DivergencePercent", "DivergenceType", "DivergenceOrderType");
   FileFlush(divhandler);

   FileWrite(bbindexhandler, "Datetime", "BullPercent", "BearPercent");
   FileFlush(bbindexhandler);
   
   FileWrite(volindexhandler, "Datetime", "VolatilityPercent");
   FileFlush(volindexhandler);
   
   FileWrite(oboshandler, "Datetime", "OBPercent", "OSPercent");
   FileFlush(oboshandler);
   
   FileWrite(indicatorhandler, "Datetime", "BullPercent", "BearPercent");
   FileFlush(indicatorhandler);
   
   FileWrite(linehandler, "Datetime", "BullPercent", "BearPercent");
   FileFlush(linehandler);
   
   FileWrite(marketmomentumhandler, "Datetime", "BuyPercent", "SellPercent");
   FileFlush(marketmomentumhandler);
   
   FileWrite(markettrendhandler, "Datetime", "BuyPercent", "SellPercent");
   FileFlush(markettrendhandler);
   
   FileWrite(middlehandler, "Datetime", "Main", "Upper", "Lower");
   FileFlush(middlehandler);

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnUpdateIndicatorValues()
{
   datetime startTime = iTime(Symbol(), PERIOD_M15, 0);
   
   // ZigZag
   FileWrite(zzhandler, startTime, DoubleToString(Indicators.GetZigZag().GetZigZagPrice(0, 1), _Digits));
   FileFlush(zzhandler);
   
   // Fractal
   FileWrite(fractalhandler, startTime, DoubleToString(Indicators.GetFractal().GetFractalResistancePrice(0, 1), _Digits),
             DoubleToString(Indicators.GetFractal().GetFractalSupportBarShiftPrice(0, 1), _Digits)
            );
   FileFlush(fractalhandler);
   
   // Pivot
   FileWrite(pivothandler, startTime, DoubleToString(Indicators.GetPivot().GetPivotS(0, 1, 0), _Digits),
             DoubleToString(Indicators.GetPivot().GetPivotS(0, 1, 1), _Digits),
             DoubleToString(Indicators.GetPivot().GetPivotS(0, 1, 2), _Digits)
            );
   FileFlush(pivothandler);
   
   // Volume
   FileWrite(volhandler, startTime, DoubleToString(Indicators.GetVolumeIndicator().GetVolumeValue(0, 1), 0),
             DoubleToString(Indicators.GetVolumeIndicator().GetMeanVolume(0, 1), 0),
             DoubleToString(Indicators.GetVolumeIndicator().GetStdDevVolume(0, 1), 0)
            );
   FileFlush(volhandler);
   
   // MA
   FileWrite(mahandler, startTime, DoubleToString(Indicators.GetMovingAverage().GetFastMA(0, 1), _Digits),
             DoubleToString(Indicators.GetMovingAverage().GetMediumMA(0, 1), _Digits),
             DoubleToString(Indicators.GetMovingAverage().GetSlowMA(0, 1), _Digits),
             DoubleToString(Indicators.GetMovingAverage().GetMoneyLineMA(0, 1), _Digits)
            );
   FileFlush(mahandler);
   
   // OBV
   FileWrite(obvhandler, startTime, DoubleToString(Indicators.GetOnBalance().GetOBVValue(0, 1), 0),
             DoubleToString(Indicators.GetOnBalance().GetMeanOBV(0, 1), 0),
             DoubleToString(Indicators.GetOnBalance().GetStdDevOBV(0, 1), 0)
            );
   FileFlush(obvhandler);
   
   // RSI
   FileWrite(rsihandler, startTime, DoubleToString(Indicators.GetRSI().GetRSIValue(0, 1), 2),
             DoubleToString(Indicators.GetRSI().GetRSIMean(0, 1), 2),
             DoubleToString(Indicators.GetRSI().GetRSIStdDev(0, 1), 2)
            );
   FileFlush(rsihandler);
   
   // RVI
   FileWrite(rvihandler, startTime, DoubleToString(Indicators.GetRVI().GetRVIHist(0, 1), 2),
             DoubleToString(Indicators.GetRVI().GetRVIHistMean(0, 1), 2),
             DoubleToString(Indicators.GetRVI().GetRVIHistStdDev(0, 1), 2)
            );
   FileFlush(rvihandler);
   
   // CS
   FileWrite(cshandler, startTime, DoubleToString(CSAnalysis.GetCummBodyPercent(0, 1), 2),
             DoubleToString(CSAnalysis.GetCummTopWickPercent(0, 1), 2),
             DoubleToString(CSAnalysis.GetCummBotWickPercent(0, 1), 2)
            );
   FileFlush(cshandler);
   
   // Ichimoku
   FileWrite(ichimokuhandler, startTime, DoubleToString(Indicators.GetIchimoku().GetTenKanKijunHist(0, 1), _Digits),
             DoubleToString(Indicators.GetIchimoku().GetChikouSpan(0, 1), _Digits),
             DoubleToString(Indicators.GetIchimoku().GetSenkouSpanA(0, 1), _Digits),
             DoubleToString(Indicators.GetIchimoku().GetSenkouSpanB(0, 1), _Digits)
            );
   FileFlush(ichimokuhandler);
   
   // MACD
   FileWrite(macdhandler, startTime, DoubleToString(Indicators.GetMACD().GetHistogram(0, 1), _Digits),
             DoubleToString(Indicators.GetMACD().GetHistogramMean(0, 1), _Digits),
             DoubleToString(Indicators.GetMACD().GetHistStdDev(0, 1), _Digits)
            );
   FileFlush(macdhandler);
   
   // MOM
   FileWrite(momhandler, startTime, DoubleToString(Indicators.GetMomentum().GetMomentumValue(0, 1), 2),
             DoubleToString(Indicators.GetMomentum().GetMomentumMean(0, 1), 2),
             DoubleToString(Indicators.GetMomentum().GetMomentumStdDev(0, 1), 2)
            );
   FileFlush(momhandler);
   
   // CCI
   FileWrite(ccihandler, startTime, DoubleToString(Indicators.GetCCI().GetCCIValue(0, 1), 2),
             DoubleToString(Indicators.GetCCI().GetCCIMean(0, 1), 2),
             DoubleToString(Indicators.GetCCI().GetCCIStdDev(0, 1), 2)
            );
   FileFlush(ccihandler);
   
   // Bull bear Power
   FileWrite(bullbearpowerhandler, startTime, DoubleToString(Indicators.GetBullBearPower().GetBullPowerValue(0, 1), _Digits),
             DoubleToString(Indicators.GetBullBearPower().GetBearPowerValue(0, 1), _Digits)
            );
   FileFlush(bullbearpowerhandler);
   
   // STO
   FileWrite(stohandler, startTime, DoubleToString(Indicators.GetSTO().GetSTOHist(0, 1), 2),
             DoubleToString(Indicators.GetSTO().GetSTOHistMean(0, 1), 2),
             DoubleToString(Indicators.GetSTO().GetSTOHistStdDev(0, 1), 2)
            );
   FileFlush(stohandler);
   
   // SAR
   FileWrite(sarhandler, startTime, DoubleToString(Indicators.GetSAR().GetSar(0, 1), _Digits));
   FileFlush(sarhandler);
   
   // ATR
   FileWrite(atrhandler, startTime, DoubleToString(Indicators.GetATR().GetATRValue(0, 1), _Digits),
             DoubleToString(Indicators.GetATR().GetATRValueMean(0, 1), _Digits),
             DoubleToString(Indicators.GetATR().GetATRValueStdDev(0, 1), _Digits)
            );
   FileFlush(atrhandler);
   
   // BB
   FileWrite(bbhandler, startTime, DoubleToString(Indicators.GetBands().GetMain(0, 1), _Digits),
             DoubleToString(Indicators.GetBands().GetUpper(0, 2, 1), _Digits),
             DoubleToString(Indicators.GetBands().GetLower(0, 2, 1), _Digits)
            );
   FileFlush(bbhandler);
   
   // Force
   FileWrite(forcehandler, startTime, DoubleToString(Indicators.GetForceIndex().GetForceIndexValue(0, 1), _Digits),
             DoubleToString(Indicators.GetForceIndex().GetForceMean(0, 1), _Digits),
             DoubleToString(Indicators.GetForceIndex().GetForceStdDev(0, 1), _Digits)
            );
   FileFlush(forcehandler);
   
   // AD
   FileWrite(acchandler, startTime, DoubleToString(Indicators.GetAccumulation().GetADValue(0, 1), 0),
             DoubleToString(Indicators.GetAccumulation().GetMeanAD(0, 1), 0),
             DoubleToString(Indicators.GetAccumulation().GetStdDevAD(0, 1), 0)
            );
   FileFlush(acchandler);
   
   // MFI
   FileWrite(mfihandler, startTime, DoubleToString(Indicators.GetMoneyFlow().GetMFIValue(0, 1), 2),
             DoubleToString(Indicators.GetMoneyFlow().GetMeanMFI(0, 1), 2),
             DoubleToString(Indicators.GetMoneyFlow().GetStdDevMFI(0, 1), 2)
            );
   FileFlush(mfihandler);
   
   // Keltner
   FileWrite(keltnerhandler, startTime, DoubleToString(Indicators.GetKeltner().GetMain(0, 1), _Digits),
             DoubleToString(Indicators.GetKeltner().GetUpper(0, 1), _Digits),
             DoubleToString(Indicators.GetKeltner().GetLower(0, 1), _Digits)
            );
   FileFlush(keltnerhandler);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnUpdateAdvanceValues()
{

   datetime startTime = iTime(Symbol(), PERIOD_M15, 0);
   
   // ZigZag
   FileWrite(zzadvhandler, startTime, AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M15, 1));
   FileFlush(zzadvhandler);
   
   // Divergence
   FileWrite(divhandler, startTime, AdvIndicators.GetDivergenceIndex().GetBarShiftDivergencePercent(2, 1), AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(2, 1), AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceType(2, 1));
   FileFlush(divhandler);
   
   // BullBear Index
   FileWrite(bbindexhandler, startTime, AdvIndicators.GetBullBear().GetBullPercent(2, 1), AdvIndicators.GetBullBear().GetBearPercent(2, 1));
   FileFlush(bbindexhandler);
   
   // Volatility Index
   FileWrite(volindexhandler, startTime, AdvIndicators.GetVolatility().GetVolatilityPercent(2, 1));
   FileFlush(volindexhandler);
   
   // OBOS Index
   FileWrite(oboshandler, startTime, AdvIndicators.GetOBOS().GetOBPercent(2, 1), AdvIndicators.GetOBOS().GetOSPercent(2, 1));
   FileFlush(oboshandler);
   
   // Indicator Trigger
   FileWrite(indicatorhandler, startTime, AdvIndicators.GetIndicatorsTrigger().GetBuyPercent(2, 1), AdvIndicators.GetIndicatorsTrigger().GetSellPercent(2, 1));
   FileFlush(indicatorhandler);
   
   // Line Trigger
   FileWrite(linehandler, startTime, AdvIndicators.GetLineTrigger().GetBuyPercent(2, 1), AdvIndicators.GetLineTrigger().GetSellPercent(2, 1));
   FileFlush(linehandler);
   
   // market momentum
   FileWrite(marketmomentumhandler, startTime, AdvIndicators.GetMarketMomentum().GetBuyPercent(2, 1), AdvIndicators.GetMarketMomentum().GetSellPercent(2, 1));
   FileFlush(marketmomentumhandler);
   
   // trend indexes
   FileWrite(markettrendhandler, startTime, AdvIndicators.GetTrendIndexes().GetBuyTrendIndexes(2, 1), AdvIndicators.GetTrendIndexes().GetSellTrendIndexes(2, 1));
   FileFlush(markettrendhandler);
   
   // MiddleLine
   FileWrite(middlehandler, startTime, AdvIndicators.GetMiddleLine().GetMain(2, 1), AdvIndicators.GetMiddleLine().GetUpper(2, 1), AdvIndicators.GetMiddleLine().GetLower(2, 1));
   FileFlush(middlehandler);

}

//+------------------------------------------------------------------+