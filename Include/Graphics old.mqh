//+------------------------------------------------------------------+
//|                                                     Graphics.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+


int RegisterWindowMessageW(string MessageName);
int SendMessageW(long hWnd,int Msg,int wparam,uchar &Name[]);

/*
#include "..\iForexDNA\CandleStick\CandleStick.mqh"
#include "..\iForexDNA\CandleStick\CandleStickArray.mqh"
#include "..\iForexDNA\AccountManager.mqh"
#include "..\iForexDNA\IndicatorsHelper.mqh"
#include "..\iForexDNA\AdvanceIndicator.mqh"
#include "..\iForexDNA\MarketCondition.mqh"
#include "..\iForexDNA\ZigZag.mqh"
#include "..\iForexDNA\Fractals.mqh"
#include "..\iForexDNA\GraphicTool.mqh"
#include "..\iForexDNA\ExternVariables.mqh"
#include "..\iForexDNA\Probability.mqh"
#include "..\iForexDNA\OpenPosition.mqh"
*/

#include "..\iForexDNA\hash.mqh"
#include "..\iForexDNA\MiscFunc.mqh"
#include "..\iForexDNA\Enums.mqh"
#include <Trade\TerminalInfo.mqh>
#include <Controls\Edit.mqh>

#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Graphics
  {
private:
   Hash                 *m_WindowsHash;
   //CandleStickArray     *m_CSAnalysis;
   //AccountManager       *m_AccountManager;
   //IndicatorsHelper     *m_Indicators;
   //MarketCondition      *m_MarketCondition;
   //Probability          *m_Probability;

   //AdvanceIndicator     *m_AdvIndicators;
   //OpenPosition         *m_OpenPosition;           // temporary fix while waiting to create flag class
   
   
   // Main Window Graphics Stuff
   int               m_WindowID[6];
   long              m_ChartID;
   long              m_WindowHeightPixel;
   long              m_WindowWidthPixel;
   double            m_WindowHeightInch;
   double            m_WindowWidthInch;
   double            m_WindowBottomPrice;
   double            m_WindowTopPrice;

   
   
   int               m_YDistance[Y_DISTANCE_BUFFER];
   double            m_PIXEL_SIZE;
   
   datetime          m_ChartStartDatetime;
   datetime          m_ChartEndDatetime;
   
   
   long              m_ChartHeightPixel[6];
   long              m_ChartWidthPixel[6];
   int               m_DPI;               // Dot Per Inch
   int               m_PPI;               // Pixel Per Inch
   
   
   string            m_Indicator_Name_On_MainWindow[INDICATOR_MAX_ON_MAIN_WINDOW];
   int               m_Number_Of_Indicators_On_MainWindow;

private:

   bool              StartCustomIndicator(long hWnd,string ChartName,bool AutomaticallyAcceptDefaults=false);
   bool              InitSubwindow(string ChartName);

   bool              InitTechnicalAnalysisWindow0(string ChartName);
   bool              InitTechnicalAnalysisWindow1(string ChartName);
   bool              InitTechnicalAnalysisWindow2(string ChartName);
   bool              InitTechnicalAnalysisWindow3(string ChartName);
   bool              InitTradeSubwindow(string ChartName);
   
   bool              InitFibonacciOnChart(string ChartName);
   // bool              InitMTFOnChart(string ChartName);

   int               GetStringXSize(const string str);


public:
                     /*
                     Graphics(CandleStickArray *pCSAnalysis,AccountManager *pAccountManager,IndicatorsHelper *pIndicators,
                     AdvanceIndicator *pAdvanceIndicator, OpenPosition *pOpenPostion, MarketCondition *pMarketCondition, Probability *pProbability);
                     */
                     
                     Graphics();
                    ~Graphics();

   bool              Init();
   void              OnDeinit();
   void              OnUpdate(int TimeFrameIndex,bool IsNewBar);
   
   
   void              OnUpdateTechnicalAnalysisWindow1(int TimeFrameIndex);
   void              OnUpdateTechnicalAnalysisWindow2(int TimeFrameIndex);
   void              OnUpdateTechnicalAnalysisWindow3(int TimeFrameIndex);
   void              OnUpdateTradeSubwindow();
   
   
   void              OnUpdateFibonacciOnChart(int TimeFrameIndex);
   void              OnUpdateMTFOnChart(int TimeFrameIndex);
   
   
   bool              Init_Window_Resolutions(string ChartName);
   void              OnUpdate_Window_Resolutions(string ChartName);
   
   string            GetIndicatorsNameOnMainWindow(int Shift);
   int               OnUpdateNumberOfIndicatorsOnMainWindow(void);
   
   
   bool              ResizeSubWindow(string ChartName, long YHeight);
   double            GetChartBottomPrice();
   double            GetChartTopPrice();
   datetime          GetChartStartDatetime();
   datetime          GetChartEndDatetime();
   
   long              GetChartHeightPixel(int Subwindow);
   long              GetChartWidthPixel(int Subwindow);
   
   bool              RemoveSubwindowByName(string ChartName);

   


  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
Graphics::Graphics(CandleStickArray *pCSAnalysis,AccountManager *pAccountManager,IndicatorsHelper *pIndicators,
                     AdvanceIndicator *pAdvanceIndicator, OpenPosition *pOpenPostion, MarketCondition *pMarketCondition, Probability *pProbability)
*/

Graphics::Graphics()
  {
   /*
   m_CSAnalysis=NULL;
   m_AccountManager=NULL;
   m_Indicators=NULL;
   m_AdvIndicators=NULL;
   m_OpenPosition=NULL;
   m_MarketCondition=NULL;
   m_Probability=NULL;

   if(pCSAnalysis==NULL)
      LogError(__FUNCTION__,"CSAnalysis pointer is NULL");
   else
      m_CSAnalysis=pCSAnalysis;

   if(pAccountManager==NULL)
      LogError(__FUNCTION__,"AccountManager pointer is NULL");
   else
      m_AccountManager=pAccountManager;

   if(pIndicators==NULL)
      LogError(__FUNCTION__,"Indicators pointer is NULL");
   else
      m_Indicators=pIndicators;
      
   if(pAdvanceIndicator==NULL)
      LogError(__FUNCTION__,"AdvIndicator pointer is NULL");
   else
      m_AdvIndicators=pAdvanceIndicator;
      
   if(pOpenPostion==NULL)
      LogError(__FUNCTION__,"OpenPosition pointer is NULL");
   else
      m_OpenPosition=pOpenPostion;

   if(pMarketCondition==NULL)
      LogError(__FUNCTION__,"MarketCondition pointer is NULL");
   else
      m_MarketCondition=pMarketCondition;
      
   if(pProbability==NULL)
      LogError(__FUNCTION__,"Probability pointer is NULL");
   else
      m_Probability=pProbability;
   */
   m_WindowsHash=new Hash();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Graphics::~Graphics()
  {
   if(m_WindowsHash!=NULL)
      delete m_WindowsHash;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::Init()
  {
  
   ObjectsDeleteAll(m_ChartID);
   
  
   if(!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return false;
   
   /*
   if(m_CSAnalysis==NULL || m_AccountManager==NULL || m_Indicators==NULL || m_AdvIndicators==NULL || m_OpenPosition == NULL || m_MarketCondition == NULL || m_Probability == NULL)
     {
      LogError(__FUNCTION__,"Class pointer is NULL.");
      return false;
     }
  
   if(!ChartSetInteger(0,CHART_SHIFT,0,false)) 
   { 
      //--- display the error message in Experts journal 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 

   } 
   */
   
   if(m_WindowsHash.hGetInt(MAIN_WINDOW) < 0)
   {
      m_WindowsHash.hPutInt(MAIN_WINDOW, 0);
   }
   
   if(!ChartSetInteger(0,CHART_SHOW_GRID,0,false)) 
   { 
      //--- display the error message in Experts journal 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
   }
   
   if(ChartGetInteger(m_ChartID,CHART_MODE, CHART_CANDLES)!=CHART_CANDLES)
      ChartSetInteger(m_ChartID,CHART_MODE, CHART_CANDLES);

   bool chartShift=false;
   ChartSetInteger(m_ChartID,CHART_SHIFT, 100);
   
   if(!chartShift)
      ChartSetInteger(m_ChartID,CHART_SHIFT, 100);
      
   
   //       Window Resolution stuff
   
   if(!Init_Window_Resolutions(MAIN_WINDOW))
      return false;  

   if(!InitTechnicalAnalysisWindow1(SUBWINDOW1))
      return false;


   if(!InitTechnicalAnalysisWindow2(SUBWINDOW2))
      return false;

   if(!InitTechnicalAnalysisWindow3(SUBWINDOW3))
      return false;
   
   if(!InitTradeSubwindow(SUBWINDOW4))
      return false;

    //    Window Resolution Debug stuff
   /*
      LabelCreate(m_ChartID, "WindowSize0", 0, 230, (int) m_PIXEL_SIZE, true, CORNER_LEFT_UPPER, 
      "Height/Width/DPI/Font Size = ",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
      
      
      LabelCreate(m_ChartID,"WindowSizeHW0", 0, GetStringXSize("Technical Analysis")+GetStringXSize("Total Height/Height/Width/DPI/Font Size =")-30, (int) m_PIXEL_SIZE, true, CORNER_LEFT_UPPER, 
      (string) m_ChartHeightPixel[0]+"/"+ (string) m_ChartWidthPixel[0]+"/"+ (string)m_DPI + "/" + (string) DEFAULT_TXT_SIZE,
      DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);

      
      for(int j = 1; j < 5; j++)
      {
         LabelCreate(m_ChartID, "WindowSize"+(string)j, m_WindowID[j], GetStringXSize("Technical Analysis "), (int) m_PIXEL_SIZE, true, CORNER_LEFT_UPPER, 
         "Height/Width/DPI/Font Size = ",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
         
         
         LabelCreate(m_ChartID,"WindowSizeHW"+(string)j, m_WindowID[j], GetStringXSize("Technical Analysis")+GetStringXSize("Height/Width/DPI/Font Size = ")-35, (int) m_PIXEL_SIZE, true, CORNER_LEFT_UPPER, 
         (string) m_ChartHeightPixel[j]+"/"+ (string) m_ChartWidthPixel[j]+"/"+ (string)m_DPI + "/" + (string) DEFAULT_TXT_SIZE,
         DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
      }
   */

   OnUpdate_Window_Resolutions(MAIN_WINDOW);
   
   
   InitFibonacciOnChart(MAIN_WINDOW);              // If false, timeframe is not supported for Fibonacci   
   // InitMTFOnChart(MAIN_WINDOW);                 // If false, timeframe is not supported for Fibonacci

   return true;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnDeinit()
   {  
      if(m_WindowsHash!=NULL)
         delete m_WindowsHash;
         
      // printf("Window Hash = "+(string) m_WindowsHash.getEntry(0));  
         
      if(m_WindowsHash.hDel(MAIN_WINDOW)){printf("Deleted hDelInt Main Window");};
      m_WindowsHash.hDel(SUBWINDOW1);
      m_WindowsHash.hDel(SUBWINDOW2);
      m_WindowsHash.hDel(SUBWINDOW3);
      m_WindowsHash.hDel(SUBWINDOW4);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnUpdate(int TimeFrameIndex,bool IsNewBar)
  {
   if(!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return;


   OnUpdate_Window_Resolutions(MAIN_WINDOW);


   OnUpdateTechnicalAnalysisWindow1(TimeFrameIndex);
   OnUpdateTechnicalAnalysisWindow2(TimeFrameIndex);
   OnUpdateTechnicalAnalysisWindow3(TimeFrameIndex);   
   OnUpdateTradeSubwindow(); 
   
   OnUpdateNumberOfIndicatorsOnMainWindow();         
   
   if(IsNewBar)
   {  
      if(IsTimeFrameSupported(Period()))
      {
         //OnUpdateFibonacciOnChart(TimeFrameIndex);
         //OnUpdateMTFOnChart(TimeFrameIndex);  
      }

   }
   
   ChartRedraw();
   
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::Init_Window_Resolutions(string ChartName)
{
   
   m_WindowID[0]=m_WindowsHash.hGetInt(ChartName);
   
   
   
   m_ChartID=ChartID();
   
   
   // Show Chart Period Separator if testing and visual
   

   if(!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      ChartSetInteger(m_ChartID,CHART_SHOW_PERIOD_SEP,0,true);
   
   if(m_WindowID[0]<0)
      return false;
     
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return false;
   
   
   int XDistance=0;

   // Get the Pixel size of the Total Window Area
   
   m_WindowHeightPixel = ChartGetInteger(m_ChartID, CHART_HEIGHT_IN_PIXELS,0);
   m_WindowWidthPixel = ChartGetInteger(m_ChartID, CHART_WIDTH_IN_PIXELS,0);
   m_DPI = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   m_PPI = (int) MathSqrt(MathPow(m_WindowHeightPixel, 2) + MathPow(m_WindowWidthPixel, 2));       // PPI= sqrt(diagonal in pixels^2 / diagonal in inches^2)
   
   
   m_PIXEL_SIZE = MathRound(m_WindowWidthPixel/WINDOW_MAX_CHAR_WIDTH);     
   
   
   /*
   printf(Symbol()+" Window Height Pixel = "+(string) m_WindowHeightPixel);
   printf(Symbol()+" Window Width Pixel = "+(string) m_WindowWidthPixel);
   printf(Symbol()+" DPI = "+(string) m_DPI);               //    Dot Per Inch
   printf(Symbol()+" PPI = "+(string) m_PPI);               //    Pixel Per Inch
   printf(Symbol()+" Font Size = "+(string) m_PIXEL_SIZE); 
   */
   
   
   if(DEFAULT_TXT_SIZE == 0)
   {
      //DEFAULT_TXT_SIZE = (int) MathRound((m_WindowWidthPixel/WINDOW_MAX_CHAR_WIDTH)*ASPECT_RATIO);
   }
   
   for(int j = 0; j < Y_DISTANCE_BUFFER; j++)
   {
      m_YDistance[j] = (int) NormalizeDouble(m_PIXEL_SIZE*(j+2)*2, 0);
   }
   
      //    Set the height of each subwindows - This part needs to be fixed later
   
      m_ChartHeightPixel[1] = m_YDistance[7]; 
      m_ChartHeightPixel[2] = m_YDistance[5];
      m_ChartHeightPixel[3] = m_YDistance[6];
      m_ChartHeightPixel[4] = m_YDistance[10];
      
      m_ChartHeightPixel[0] = m_WindowHeightPixel;
      
      for(int i = 0; i < 5; i++) 
      {     
         m_ChartWidthPixel[i] = m_WindowWidthPixel;
      }

      ChartXYToTimePrice(m_ChartID,0,0,m_WindowID[0],m_ChartStartDatetime, m_WindowTopPrice);
      ChartXYToTimePrice(m_ChartID,(int)m_WindowWidthPixel, (int) m_WindowHeightPixel, m_WindowID[0],m_ChartEndDatetime, m_WindowBottomPrice);
      
      
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Graphics::OnUpdate_Window_Resolutions(string ChartName)
{
   m_WindowID[0]=m_WindowsHash.hGetInt(ChartName);
   
   
   
   m_ChartID=ChartID();
   
   
   // Show Chart Period Separator if testing and visual
   

   if(MQLInfoInteger(MQL_TESTER) && MQLInfoInteger(MQL_VISUAL_MODE))
      ChartSetInteger(m_ChartID,CHART_SHOW_PERIOD_SEP,0,true);
   
   if(m_WindowID[0]<0)
      return;
     
   if(MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return;
   
   
   int XDistance=0;

   // Get the Pixel size of the Total Window Area
   
   m_WindowHeightPixel = ChartGetInteger(m_ChartID, CHART_HEIGHT_IN_PIXELS,0);
   m_WindowWidthPixel = ChartGetInteger(m_ChartID, CHART_WIDTH_IN_PIXELS,0);
   m_DPI = TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   m_PPI = (int) MathSqrt(MathPow(m_WindowHeightPixel, 2) + MathPow(m_WindowWidthPixel, 2));       // PPI= sqrt(diagonal in pixels^2 / diagonal in inches^2)
   
   
   m_PIXEL_SIZE = MathRound(m_WindowWidthPixel/WINDOW_MAX_CHAR_WIDTH);     
   
   
   /*
   printf(Symbol()+" Window Height Pixel = "+(string) m_WindowHeightPixel);
   printf(Symbol()+" Window Width Pixel = "+(string) m_WindowWidthPixel);
   printf(Symbol()+" DPI = "+(string) m_DPI);               //    Dot Per Inch
   printf(Symbol()+" PPI = "+(string) m_PPI);               //    Pixel Per Inch
   printf(Symbol()+" Font Size = "+(string) m_PIXEL_SIZE); 
   */
   
   
   if(DEFAULT_TXT_SIZE == 0)
   {
      DEFAULT_TXT_SIZE = (int) MathRound((m_WindowWidthPixel/WINDOW_MAX_CHAR_WIDTH)*ASPECT_RATIO);
   }
   
   for(int j = 0; j < Y_DISTANCE_BUFFER; j++)
   {
      m_YDistance[j] = (int) NormalizeDouble(m_PIXEL_SIZE*(j+2)*2, 0);
   }
   
   
   

      //    Set the height of each subwindows - This part needs to be fixed later
   
      m_ChartHeightPixel[1] = m_YDistance[7]; 
      m_ChartHeightPixel[2] = m_YDistance[5];
      m_ChartHeightPixel[3] = m_YDistance[5];
      m_ChartHeightPixel[4] = m_YDistance[10];
      
      m_ChartHeightPixel[0] = m_WindowHeightPixel;
      
      for(int i = 0; i < 5; i++) 
      {     
         m_ChartWidthPixel[i] = m_WindowWidthPixel;
      }

      ChartXYToTimePrice(m_ChartID,0,0,m_WindowID[0],m_ChartStartDatetime, m_WindowTopPrice);
      ChartXYToTimePrice(m_ChartID,(int)m_WindowWidthPixel, (int) m_WindowHeightPixel, m_WindowID[0],m_ChartEndDatetime, m_WindowBottomPrice);
  
}
  
  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::StartCustomIndicator(long hWnd,string ChartName,bool AutomaticallyAcceptDefaults=false)
  {
   ResetLastError();
   
   printf("Start Custom Indicator");

   uchar charArrayIndicatorName[];
   StringToCharArray(ChartName,charArrayIndicatorName,0);

   // printf("charArrayIndicatorName = "+charArrayIndicatorName);

   int MessageNumber=RegisterWindowMessageW("MetaTrader4_Internal_Message");
   int res=SendMessageW(hWnd,MessageNumber,15,charArrayIndicatorName);
   if(res)
     {
      LogError(__FUNCTION__,"Failed to post a msg winAPI",GetLastError());
      return false;
     }

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+  
bool Graphics::InitSubwindow(string ChartName)
  {
   ResetLastError();
   
   if(ChartWindowFind(0,ChartName)>0)
     {
      if(m_WindowsHash.hGetInt(ChartName) < 0)
         m_WindowsHash.hPutInt(ChartName,ChartWindowFind(0,ChartName));

      return true;
     }

   long hWnd=ChartGetInteger(0,CHART_WINDOW_HANDLE,0);
   if(!hWnd)
     {
      LogError(__FUNCTION__,"Window not found",GetLastError());
      return false;
     }

   if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
     {
      Alert("DLLs are disabled.  To enable tick the checkbox in the Common Tab");
      LogError(__FUNCTION__,"DLLs is not allowed",GetLastError());
      return false;
     }

   if(ChartWindowFind(0,ChartName)<0)
     {
      MessageBox(ChartName+" Indicator window not found.","ERROR",MB_ICONERROR);
      LogError(__FUNCTION__,ChartName+" Indicator window not found",GetLastError());
      return false;
     }

   bool res=StartCustomIndicator(hWnd,ChartName);

   if(res)
      m_WindowsHash.hPutInt(ChartName,ChartWindowFind(0,ChartName));

   return res;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::InitTechnicalAnalysisWindow0(string ChartName)
  {
   if(!InitSubwindow(ChartName))
   {
      printf("Fail to Init Chart Name = "+ChartName);
      return false;
   }
   

   int windowID = ChartWindowFind(m_ChartID, ChartName); 
   m_WindowID[1] = windowID;
   
   if(m_WindowID[1]<0)
      return false;

   // ResizeSubWindow(ChartName,m_ChartHeightPixel[1]);

   int XDistance=0;
   
   return true;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::InitTechnicalAnalysisWindow1(string ChartName)
  {
   if(!InitSubwindow(ChartName))
   {
      printf("Fail to Init Chart Name = "+ChartName);
      return false;
   }
   

   int windowID = ChartWindowFind(m_ChartID, ChartName); 
   m_WindowID[2] = windowID;
   
   if(m_WindowID[2]<0)
      return false;

   ResizeSubWindow(ChartName,m_ChartHeightPixel[1]);

   int XDistance=0;

/*
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
*/
   
// Time Label

   LabelCreate(m_ChartID,"W1timelb",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"TIME",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"W1M1lb",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"M1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"W1M5lb",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"M5",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"W1M15lb",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"M15",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"W1H1lb",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"H1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"W1H4lb",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"H4",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"W1D1lb",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"D1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);

   XDistance=GetStringXSize("time");
   
   // Divergence Condition
   
   LabelCreate(m_ChartID,"BarShiftDivergencelb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"BarShift",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BarShiftDivergencelb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Divergence",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BarShiftDivergenceM1",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BarShiftDivergenceM5",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BarShiftDivergenceM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BarShiftDivergenceH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BarShiftDivergenceH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BarShiftDivergenceD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("x-xxxx-xx.xx%") - 10;
   
   // ZZ Adv Indicator M1-D1 Condition
   LabelCreate(m_ChartID,"ZigZaglb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"ZigZag",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZaglb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Values",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZagM1",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZagM5",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZagM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZagH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZagH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZagD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("ZigZag") -10; 

   // Demarkation line 

   LabelCreate(m_ChartID,"ZigZag_Divergence1",windowID,XDistance,0,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence2",windowID,XDistance,15,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence3",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence4",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence5",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence6",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence7",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence8",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ZigZag_Divergence9",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   
   XDistance+=10;
   
   // Bull Index graphics
   LabelCreate(m_ChartID,"BullBearlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Bull Bear",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBearlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Index",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT); 
   LabelCreate(m_ChartID,"BullM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("xxx.xx%") -10;
   
   
   // BullBear Separator 
   LabelCreate(m_ChartID,"BullBearSeperatorM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"/ ",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBearSeperatorH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"/ ",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBearSeperatorH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"/ ",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBearSeperatorD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"/",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("/");
   
   
   // Bear Index graphics
   LabelCreate(m_ChartID,"BearM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BearH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BearH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BearD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("xxx.xx%") - 10;  

   // Volatility Index graphics
   LabelCreate(m_ChartID,"Vollb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Volatility",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Vollb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Position",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"VolM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"VolH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"VolH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"VolD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Below Mean") - 20;
   

   // OB Index graphics
   LabelCreate(m_ChartID,"OBlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"OBOS",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Index",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   // ObjectSetString(m_ChartID,"OBlb",OBJPROP_TOOLTIP,"* = CrossOver");

   XDistance+=GetStringXSize("xx.xx%")-10;

   // OBOS Separator 
   LabelCreate(m_ChartID,"OBOSSeperatorM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"/",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBOSSeperatorH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"/",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBOSSeperatorH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"/",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OBOSSeperatorD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"/",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,NEUTRAL_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("/");

   // OS Index graphics
   LabelCreate(m_ChartID,"OSM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OSH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OSH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OSD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("xxx.xx%") - 10;
   
   // OB Position
   
   LabelCreate(m_ChartID,"OB_Postion_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"OB",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OB_Postion_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Position",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OB_Postion_M15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OB_Postion_H1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OB_Postion_H4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OB_Postion_D1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Below Mean") -20;
   
   // OS Position
   
   LabelCreate(m_ChartID,"OS_Postion_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"OS",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OS_Postion_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Position",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OS_Postion_M15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OS_Postion_H1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OS_Postion_H4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OS_Postion_D1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Below Mean") - 20;
   
   
   // Band Band
   
   LabelCreate(m_ChartID,"Bollinger_StdDevlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"BB Std Dev",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Bollinger_StdDevlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Curr/Max/Min",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Bollinger_StdDevM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Bollinger_StdDevH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Bollinger_StdDevH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Bollinger_StdDevD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("-x.xx/-x.xx/-x.xx") - 10;
   
   
   // Bollinger Position
   
   LabelCreate(m_ChartID,"BandPoslb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Bollinger",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BandPoslb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Position",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BandPosM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BandPosH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BandPosH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BandPosD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Below Mean") - 20;
   
   // Demarkation line 

   LabelCreate(m_ChartID,"BullBear_Vol_OBOS1",windowID,XDistance,0,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS2",windowID,XDistance,15,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS3",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS4",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS5",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS6",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS7",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS8",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BullBear_Vol_OBOS9",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   
   XDistance+=10;


   // Cross Bounce Trigger - (CB)
   LabelCreate(m_ChartID,"BIndicatorlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Buy Indicator",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BIndicatorlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Trigger Pos",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BIndicatorM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BIndicatorH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BIndicatorH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BIndicatorD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
 
   XDistance+=GetStringXSize("x.xx/xx.xx/-x.xx") - 30;

   // Cross Bounce Trigger - (CB)
   LabelCreate(m_ChartID,"SIndicatorlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Sell Indicator",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SIndicatorlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Trigger Pos",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SIndicatorM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SIndicatorH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SIndicatorH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SIndicatorD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("x.xx/xx.xx/-x.xx") -30;
   
   // Line Trigger 
   LabelCreate(m_ChartID,"BLineTriggerlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Buy Line",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BLineTriggerlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Trigger Pos",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BLineTriggerM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BLineTriggerH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BLineTriggerH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BLineTriggerD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("x.xx/xx.xx/-x.xx") - 30; 

   // Line Trigger 
   LabelCreate(m_ChartID,"SLineTriggerlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Sell Line",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SLineTriggerlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Trigger Pos",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SLineTriggerM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SLineTriggerH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SLineTriggerH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SLineTriggerD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("x.xx/xx.xx/-x.xx") - 30;

   // Checking MTF Fractal
   
   LabelCreate(m_ChartID,"MTFFractallb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"MTF",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MTFFractallb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Fractal",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MTFFractalM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MTFFractalH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MTFFractalH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MTFFractalD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("xxxx.xx/xxxx.xx");
   
   // Demarkation line 

   LabelCreate(m_ChartID,"CSPriceAction1",windowID,XDistance,0,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction2",windowID,XDistance,15,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction3",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction4",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction5",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction6",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction7",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction8",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceAction9",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);

   XDistance+=10;
  
   // CS Body Price Action
   
   LabelCreate(m_ChartID,"CSPriceActionBodylb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"CS Price",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionBodylb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Body",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionBodyM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionBodyH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionBodyH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionBodyD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("CS Price     ") + 15;  
   
   // CS Top Wick Price Action
   
   LabelCreate(m_ChartID,"CSPriceActionToplb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"CS Price",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionToplb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Top Wick",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);


   XDistance+=GetStringXSize("CS Price     ") + 15;

   // CS Bottom Wick Price Action
   
   LabelCreate(m_ChartID,"CSPriceActionLowlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"CS Price",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionLowlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Low Wick",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionLowM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionLowH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionLowH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionLowD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("CS Price     ") + 15;

   // CS Top VS Bottom Wick
   
   LabelCreate(m_ChartID,"CSPriceActionTopBotBiaslb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"CS",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopBotBiaslb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Bias",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopBotBiasM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopBotBiasH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopBotBiasH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSPriceActionTopBotBiasD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("CS Bias") - 20;

   // CS ATR BODY AND HL
   
   LabelCreate(m_ChartID,"CSBodyHLATRlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"CS(%)",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSBodyHLATRlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Body/HL",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSBodyHLATRM15",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSBodyHLATRH1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSBodyHLATRH4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CSBodyHLATRD1",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Body/HL") + 20;
   
   

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      OnUpdateTechnicalAnalysisWindow1(i);
         
   return true;
   
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::InitTechnicalAnalysisWindow2(string ChartName)
  {
   if(!InitSubwindow(ChartName))
   {
      printf("Fail to Init Chart Name = "+ChartName);
      return false;
   }

   int windowID = ChartWindowFind(m_ChartID, ChartName); 
   m_WindowID[3] = windowID;
   if(windowID<0)
      return false;

   ResizeSubWindow(ChartName,m_ChartHeightPixel[2]);

   int XDistance=0;

// Events
   
   LabelCreate(m_ChartID,"Eventlb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Time",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Eventlb2",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"M15",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Eventlb3",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"H1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Eventlb4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"H4",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Eventlb5",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"D1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Events") - 20;



    // Bull Bear MarketConditions

   LabelCreate(m_ChartID,"MarketBiaslb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Market",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketBiaslb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Bias",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketBiasM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketBiasH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketBiasH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketBiasD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Condition");



    // Bull Bear MarketConditions
   
   LabelCreate(m_ChartID,"MarketConditionlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Market",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Condition",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Condition   ") + 10;

   
   // Bull Bear MarketConditions
      
   LabelCreate(m_ChartID,"MarketConditionResistancelb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Anchored",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionResistancelb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Resistance",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionResistanceM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionResistanceH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionResistanceH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionResistanceD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Anchored    ");


    // Anchored Support 
   
   LabelCreate(m_ChartID,"MarketConditionSupportlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Anchored",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionSupportlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Support",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionSupportM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionSupportH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionSupportH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionSupportD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Anchored    ");


    // Bull Bear MarketConditions
   
   LabelCreate(m_ChartID,"MarketConditionBiaslb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Squeeze",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionBiaslb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Bias",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionBiasM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionBiasH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionBiasH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"MarketConditionBiasD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Condition");


   // Band Logics
   
   LabelCreate(m_ChartID,"bandlogic_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Band",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"bandlogic_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Logic",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"bandlogicM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"bandlogicH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"bandlogicH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"bandlogicD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Direction") - 10;

   // TenKan Logics
   
   LabelCreate(m_ChartID,"tenkanlogic_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Tenkan",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"tenkanlogic_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Logic",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"tenkanlogicM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"tenkanlogicH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"tenkanlogicH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"tenkanlogicD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Direction") - 10;
   
   // Kijun Logics
   
   LabelCreate(m_ChartID,"kijunlogic_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Kijun",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"kijunlogic_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Logic",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"kijunlogicM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"kijunlogicH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"kijunlogicH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"kijunlogicD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Direction") - 10;


   // Single Pattern
   
   LabelCreate(m_ChartID,"singlepattern_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Single",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"singlepattern_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Pattern",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"singlepatternM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"singlepatternH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"singlepatternH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"singlepatternD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Direction          ");
   

   // Dual Pattern
   
   LabelCreate(m_ChartID,"dualpattern_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Dual",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"dualpattern_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Pattern",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"dualpatternM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"dualpatternH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"dualpatternH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"dualpatternD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Direction          ");


   // Triple Pattern
   
   LabelCreate(m_ChartID,"triplepattern_lb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Triple",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"triplepattern_lb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Pattern",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"triplepatternM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"triplepatternH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"triplepatternH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"triplepatternD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Direction           ");



    // Buy Reversal Probability
   
   LabelCreate(m_ChartID,"BuyReversallb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Buy",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyReversallb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Reversal(%)",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyReversalM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyReversalH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyReversalH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyReversalD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);


   XDistance+=GetStringXSize("Condition");

    // Sell Reversal Probability
   
   LabelCreate(m_ChartID,"SellReversallb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Sell",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellReversallb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Reversal(%)",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellReversalM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellReversalH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellReversalH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellReversalD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Condition");


   // Bull Market Bias
   LabelCreate(m_ChartID,"BMarketBiaslb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Buy Momentum",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BMarketBiaslb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"%/Mean/Trend",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BMarketBiasM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BMarketBiasH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BMarketBiasH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BMarketBiasD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Below Mean     ");
   
   // Bear Market Bias
   LabelCreate(m_ChartID,"SMarketBiaslb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Sell Momentum",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SMarketBiaslb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"%/Mean/Trend",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SMarketBiasM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SMarketBiasH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SMarketBiasH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SMarketBiasD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Below Mean     ");



    // Buy Trend Probability
   
   LabelCreate(m_ChartID,"BuyTrendlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Buy Trend",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyTrendlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"%/Mean/Trend",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyTrendM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyTrendH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyTrendH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyTrendD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);


   XDistance+=GetStringXSize("Condition        ");

    // Sell Trend Probability
   
   LabelCreate(m_ChartID,"SellTrendlb1",windowID,XDistance,18,CORNER_LEFT_UPPER,"Sell Trend",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellTrendlb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"%/Mean/Trend",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellTrendM15",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellTrendH1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellTrendH4",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellTrendD1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Condition       ");

   // Demarkation line 

   LabelCreate(m_ChartID,"Verticalline1",windowID,XDistance,0,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline3",windowID,XDistance,15,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline4",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline5",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline6",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline7",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline8",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   
   XDistance+=10;


   
   

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      OnUpdateTechnicalAnalysisWindow2(i);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::InitTechnicalAnalysisWindow3(string ChartName)
  {
   if(!InitSubwindow(ChartName))
   {
      printf("Fail to Init Chart Name = "+ChartName);
      return false;
   }

   int windowID = ChartWindowFind(m_ChartID, ChartName); 
   if(windowID<0)
      return false;

   m_WindowID[4] = windowID;

   ResizeSubWindow(ChartName,m_ChartHeightPixel[3]);

   int XDistance=0;

   // Guan Strategy
   LabelCreate(m_ChartID,"Buylbl1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Strategy",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ReversalBuy",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"Reversal",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"TrendingBuy",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"Trending",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BreakoutBuy",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"Breakout",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ContinuationBuy",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"Continuation",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"FakeoutBuy",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"Fakeout",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Continuation");

   // Filter 1 Buy
   LabelCreate(m_ChartID,"Filter_1_Buylb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Condition",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   

   XDistance+=GetStringXSize("Condition") + 25;
   
   // Filter 2 Buy
   LabelCreate(m_ChartID,"Filter_2_Buylb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Buy Zone",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   

   XDistance+=GetStringXSize("Buy Zone") + 50;
   
   // Filter 3 Buy
   LabelCreate(m_ChartID,"Filter_3_Buylb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Trigger/CO",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   

   XDistance+=GetStringXSize("Trigger/CO") + 20;
   
   // Filter_4 - Tiggers && CO
   LabelCreate(m_ChartID,"Check_Risk_Buylb1",windowID,XDistance,15,CORNER_LEFT_UPPER,"Buy",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Buylb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Check Risk",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   

   XDistance+=GetStringXSize("Check Risk") + 20;
   
   // Open Buy Order
   LabelCreate(m_ChartID,"Open_Order_Buylb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Open Orders",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);   

   XDistance+=GetStringXSize("Close Orders") + 20;
   
   // Close Buy Order
   LabelCreate(m_ChartID,"Stop_Order_Buylb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Stop Orders",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Stop Order") + 20;
   
   // Modify Buy StopLoss
   LabelCreate(m_ChartID,"Modify_Buylb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Modify SL",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   

   XDistance+=GetStringXSize("Modify SL") +40;
   
   // Close Buy Order
   LabelCreate(m_ChartID,"Close_Order_Buylb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Close Orders",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Buy_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Buy_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Buy_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Buy_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Buy_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Close Order") + 20;
   
   // Demarkation line 

   LabelCreate(m_ChartID,"Verticalline9",windowID,XDistance,0,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline10",windowID,XDistance,15,CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline11",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline12",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline13",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline14",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline15",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Verticalline16",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"|",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrRed,0,ANCHOR_LEFT);

   XDistance+=20;
   
   
   // Filter_1
   LabelCreate(m_ChartID,"Filter_1_Selllb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Condition",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_1_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Condition") + 25;
   
   // Filter_2
   LabelCreate(m_ChartID,"Filter_2_Selllb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Sell Zone",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_2_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Sell Zone") + 50;
   
   // Filter_3
   LabelCreate(m_ChartID,"Filter_3_Selllb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Trigger/CO",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Filter_3_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Trigger/CO") + 20;
   
   // Filter_4 - Tiggers && CO
   LabelCreate(m_ChartID,"Check_Risk_Selllb1",windowID,XDistance,15,CORNER_LEFT_UPPER,"Sell",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Selllb2",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Check Risk",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Check_Risk_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Check Risk") + 20;
   
   // Open Sell Order
   LabelCreate(m_ChartID,"Open_Order_Selllb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Open Orders",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Open_Order_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   
   XDistance+=GetStringXSize("Open Orders") + 20;
   
   // Close Buy Order
   LabelCreate(m_ChartID,"Stop_Order_Selllb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Stop Orders",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Stop_Order_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Stop Order") + 20;
   
   // Modify Sell
   LabelCreate(m_ChartID,"ModifySelllb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Modify SL",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Modify_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   
   XDistance+=GetStringXSize("Modify SL") +40;
   
   // Close Sell Order
   LabelCreate(m_ChartID,"Close_Order_Selllb1",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Close Orders",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrLightPink,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Sell_0",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Sell_1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Sell_2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Sell_3",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Close_Order_Sell_4",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);


   XDistance+=GetStringXSize("Close Order") + 20;
   

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
      OnUpdateTechnicalAnalysisWindow3(i);

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::InitTradeSubwindow(string ChartName)
  {
   if(!InitSubwindow(ChartName))
   {
      printf("Fail to Init Chart Name = "+ChartName);
      return false;
   }

   int windowID = ChartWindowFind(m_ChartID, ChartName); 
   if(windowID<0)
      return false;
      
   m_WindowID[5] = windowID;

   ResizeSubWindow(ChartName, m_ChartHeightPixel[4]);

   int XDistance=0;
   

//Account & Symbol Info
   
   LabelCreate(m_ChartID,"accountNameLb",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Name:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"accountNumberLb",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"Acc #:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"currencyLb",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"Base Curr:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"symbolLb",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"Symbol:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"riskpertradeLb",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"Order/Acc Risk:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"leverageLb",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"Leverage:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"DigitsLB",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"Digit/Point:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT); 
   LabelCreate(m_ChartID,"maxLotsLb",windowID,XDistance,m_YDistance[7],CORNER_LEFT_UPPER,"Max/Min Lots:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"standardLotsLb",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"Std Lot:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"PricePipLb",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"Cost/Pip:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
      

   XDistance+=GetStringXSize("Digits/Points");
   
   
   LabelCreate(m_ChartID,"accountName",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,AccountInfoString(ACCOUNT_NAME),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"accountNumber",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,(string) AccountInfoInteger(ACCOUNT_LOGIN),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"currency",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,AccountInfoString(ACCOUNT_CURRENCY),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"currencypair",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,Symbol(),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"riskpertrade",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"To Be Changed",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"leverage",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"1:"+ (string) AccountInfoInteger(ACCOUNT_LEVERAGE),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"DigitsPoints",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,(string) AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"maxminLots",windowID,XDistance,m_YDistance[7],CORNER_LEFT_UPPER,(string) AccountInfoInteger(ACCOUNT_LIMIT_ORDERS),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"PricePip",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("XXXXXX");
//Time
   
   LabelCreate(m_ChartID,"MarketOpenLb",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Market:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"serverTimeLb",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"Server:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"localTimeLb",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,LOCAL_COUNTRY+":",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"AsiaTimeLb",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"Asia:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"LondonTimeLb",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"London: ",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"NYTimeLb",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"New York:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ReqMarginLB",windowID,XDistance,m_YDistance[7],CORNER_LEFT_UPPER,"Margin Level:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"StopOutLB",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"StopOut Level:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ATRMultiplierLB",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"ATR/StdDev Pos:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("Margin Level:");

   LabelCreate(m_ChartID,"MarketOpen",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Server",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Local",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Asia",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"London",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"New York",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ReqMargin",windowID,XDistance,m_YDistance[7],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"StopOut",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,(string) "TBD"+" %",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE, clrRed,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"ATRMultiplier",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE, DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   

   XDistance+=GetStringXSize("Fri xx XX xx:xxXX");


/// 
   LabelCreate(m_ChartID,"AccounntLB",windowID,XDistance,(int) m_PIXEL_SIZE+5,CORNER_LEFT_UPPER,"Account",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE+1,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"balanceLB",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Balance:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"EquityLB",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"Equity:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"FreeMarginLB",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"Free Margin:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Profits1LB",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"Profits %:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Profits2LB",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"Profits $:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"LockedProfitsPercentLB1",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"Lock Profits %:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"LockedProfitsPercentLB2",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"Lock Profits $:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   
   LabelCreate(m_ChartID,"AvgDailyMovement",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"Avg Daily:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CurrDailyMovement",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"Curr Daily:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   


   XDistance+=GetStringXSize("Profits %:   ");

   LabelCreate(m_ChartID,"balance",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrSpringGreen,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"Equity",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrSpringGreen,0,ANCHOR_LEFT); 
   LabelCreate(m_ChartID,"freeMargin",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"profit_Percent",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"profit_Currency",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"locked_Profit_Percent",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"locked_Profit_Currency",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"AvgDailyMovement_Value",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"CurrDailyMovement_Value",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   
   
   XDistance+=GetStringXSize("$x,xxx,xxx.xx");


//    Order Information
   
   LabelCreate(m_ChartID,"OpenBuyLB",windowID,XDistance,(int) m_PIXEL_SIZE+5,CORNER_LEFT_UPPER,"BUY-"+Symbol(),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrSpringGreen,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyOrdersLB",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Buy Orders:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyLotsLB",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"Buy Lots:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT); 
   LabelCreate(m_ChartID,"OpenBuyProfitLB1",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"Profit %:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyProfitLB2",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"Profit $:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyLockedProfitLB1",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"Lock Profit %:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyLockedProfitLB2",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"Lock Profit $:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyBreakEvenLB",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"BreakEven $:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyAskLB",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"Ask",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrSpringGreen,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuySpreadLB",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"Spread:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Buy Orders:");
   
   LabelCreate(m_ChartID,"OpenBuyOrders",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyLots",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT); 
   LabelCreate(m_ChartID,"OpenBuyProfit_Percent",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyProfit_Currency",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyLockedProfit_Percent",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyLockedProfit_Currency",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenBuyBreakEven",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_COLOR,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyAsk",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrSpringGreen,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"BuyAskSpread",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("$x,xxx,xxx.xx");

   LabelCreate(m_ChartID,"OpenSellLB",windowID,XDistance,(int) m_PIXEL_SIZE+5,CORNER_LEFT_UPPER,"SELL-"+Symbol(),DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrOrange,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellOrdersLB",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"Sell Orders:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellLotsLB",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"Sell Lots:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT); 
   LabelCreate(m_ChartID,"OpenSellProfitLB",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"Profit %:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellProfit1LB",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"Profit $:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellLockedProfitLB",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"Lock Profit %:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellLockedProfit1LB",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"Lock Profit $:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellBreakEvenLB",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"BreakEven $",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrCyan,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellAskLB",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"Bid",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrOrange,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellSpreadLB",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"Spread:",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);
   
   XDistance+=GetStringXSize("Sell Orders:");
   
   LabelCreate(m_ChartID,"OpenSellOrders",windowID,XDistance,m_YDistance[0],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_SIZE,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellLots",windowID,XDistance,m_YDistance[1],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_SIZE,0,ANCHOR_LEFT); 
   LabelCreate(m_ChartID,"OpenSellProfit_Percent",windowID,XDistance,m_YDistance[2],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_SIZE,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellProfit_Currency",windowID,XDistance,m_YDistance[3],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_SIZE,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellLockedProfit_Percent",windowID,XDistance,m_YDistance[4],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_SIZE,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellLockedProfit_Currency",windowID,XDistance,m_YDistance[5],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_SIZE,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"OpenSellBreakEven",windowID,XDistance,m_YDistance[6],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,DEFAULT_TXT_SIZE,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellBid",windowID,XDistance,m_YDistance[8],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrSpringGreen,0,ANCHOR_LEFT);
   LabelCreate(m_ChartID,"SellAskSpread",windowID,XDistance,m_YDistance[9],CORNER_LEFT_UPPER,"TXT",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE,clrYellow,0,ANCHOR_LEFT);

   XDistance+=GetStringXSize("$X,XXX.XX%");



   ///////////////////////////// Event Buttons ///////////////////////////////////////


   XDistance=GetStringXSize("SetAspectRatio     ")-10;


   //    Reboot EA Button
   
   ButtonCreate(m_ChartID,"ResetEA",windowID,XDistance,0,120,20,CORNER_RIGHT_UPPER,"Reset Graphics","Ariel",DEFAULT_TXT_SIZE-2, clrBlack,clrRed, clrWhite,false, false, false, false,0);      
   ObjectSetString(m_ChartID,"ResetEA",OBJPROP_TOOLTIP, "Reboot EA if Have Display Issues");
   
   //    Set Aspec Ratio Edit
   ButtonCreate(m_ChartID,"SetAspectRatio",windowID,XDistance,20,95,20,CORNER_RIGHT_UPPER,"Aspect Ratio =","Ariel",DEFAULT_TXT_SIZE-2, clrBlack,clrRed, clrWhite,false, false, false, false,0);      
   ObjectSetString(m_ChartID,"SetAspectRatio",OBJPROP_TOOLTIP, "Set Aspect Ratio.  Standard is 4/3");
   
   //EditCreate(m_ChartID,"AspectRatioEdit", windowID, XDistance - 95,20,27,20,DoubleToString(ASPECT_RATIO,2), "Ariel", DEFAULT_TXT_SIZE-2, ALIGN_CENTER, false, 
   //CORNER_RIGHT_UPPER, clrBlack, clrWhite, clrBlack, false, false,true,0);
   
   //       Close All Orders
   
   ButtonCreate(m_ChartID,"CloseAllOrders",windowID,XDistance,40,120,20,CORNER_RIGHT_UPPER,"Close All Orders","Ariel",DEFAULT_TXT_SIZE-2, clrBlack,clrRed, clrWhite,false, false, false, false,0);      
   ObjectSetString(m_ChartID,"CloseAllOrders",OBJPROP_TOOLTIP, "Close All Orders");
 
   //       Close All Orders on Symbol
   
   ButtonCreate(m_ChartID,"CloseAllBuyOrdersBySymbol",windowID,XDistance,60,120,20,CORNER_RIGHT_UPPER,"Close All Buy-"+Symbol(),"Ariel",DEFAULT_TXT_SIZE-2, clrBlack,clrRed, clrWhite,false, false, false, false,0);      
   ObjectSetString(m_ChartID,"CloseAllBuyOrdersBySymbol",OBJPROP_TOOLTIP, "Close All Buy Orders on This Chart");
   
   ButtonCreate(m_ChartID,"CloseAllSellOrdersBySymbol",windowID,XDistance,80,120,20,CORNER_RIGHT_UPPER,"Close All Sell-"+Symbol(),"Ariel",DEFAULT_TXT_SIZE-2, clrBlack,clrRed, clrWhite,false, false, false, false,0);      
   ObjectSetString(m_ChartID,"CloseAllSellOrdersBySymbol",OBJPROP_TOOLTIP, "Close All Sell Orders on This Chart");
   
 
 
   XDistance+=125;
 
   
   // Modify All stop Loss Manually
   
   
   ButtonCreate(m_ChartID,"ModifyBuySL",windowID,XDistance,0,80,20,CORNER_RIGHT_UPPER,"ModifyBuySL: ","Ariel",DEFAULT_TXT_SIZE-2, clrBlack,clrRed, clrWhite,false, false, false, false,0); 
   //EditCreate(m_ChartID,"ModifyBuySLEdit", windowID,  XDistance-80,0,40,20,"0", "Ariel", DEFAULT_TXT_SIZE-2, ALIGN_CENTER, false, 
   //CORNER_RIGHT_UPPER, clrBlack, clrWhite, clrBlack, false, false,true,0);   
   
   
   
   ButtonCreate(m_ChartID,"ModifySellSL",windowID,XDistance,20,80,20,CORNER_RIGHT_UPPER,"ModifySellSL: ","Ariel",DEFAULT_TXT_SIZE-2, clrBlack,clrRed, clrWhite,false, false, false, false,0);   
   //EditCreate(m_ChartID,"ModifySellSLEdit", windowID, XDistance-80,20,40,20,"0", "Ariel", DEFAULT_TXT_SIZE-2, ALIGN_CENTER, false, 
   //CORNER_RIGHT_UPPER, clrBlack, clrWhite, clrBlack, false, false,true,0); 
   
   // set trailing stop by PIP
   ButtonCreate(m_ChartID,"PipTrailingStop",windowID,XDistance,40,80,20, CORNER_RIGHT_UPPER,"TrailStop(PIP)",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-2, clrBlack,TRAILINGPIP_ENABLE?BUTTON_ON:BUTTON_OFF, clrWhite, TRAILINGPIP_ENABLE?true:false, false, false, true,0);
   
   // No. PIP Away from Current Price
   //EditCreate(m_ChartID,"PipTrailingEdit", windowID, XDistance-80,40,40,20,(string)Trailing_PIP, "Ariel", DEFAULT_TXT_SIZE-2, ALIGN_CENTER, false, 
   //CORNER_RIGHT_UPPER, clrBlack, clrWhite, clrBlack, false, false,true,0);    


   // set trailing stop by ATR
   ButtonCreate(m_ChartID,"ATRTrailingStop",windowID,XDistance,60,80,20, CORNER_RIGHT_UPPER,"TrailStop(ATR)",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-2, clrBlack,TRAILINGATR_ENABLE?BUTTON_ON:BUTTON_OFF, clrWhite, TRAILINGATR_ENABLE?true:false, false, false, true,0);
   
   // No. ATR Away from Current Price
   //EditCreate(m_ChartID,"ATRTrailingEdit", windowID, XDistance-80,60,40,20,(string)Trailing_ATR, "Ariel", DEFAULT_TXT_SIZE-2, ALIGN_CENTER, false, 
   //CORNER_RIGHT_UPPER, clrBlack, clrWhite, clrBlack, false, false,true,0);  



   XDistance+=65;

   
   // Fibonassi Buttons

   ButtonCreate(m_ChartID,"Fibonassi",windowID,XDistance,0,60,20, CORNER_RIGHT_UPPER,"Fibonassi",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FIB_ALL?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FIB_ALL?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"FibonassiM15",windowID,XDistance,20,60,20, CORNER_RIGHT_UPPER,"M15",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FIB_ON_CHART[0]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FIB_ON_CHART[0]?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"FibonassiH1",windowID,XDistance,40,60,20, CORNER_RIGHT_UPPER,"H1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FIB_ON_CHART[1]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FIB_ON_CHART[1]?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"FibonassiH4",windowID,XDistance,60,60,20, CORNER_RIGHT_UPPER,"H4",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FIB_ON_CHART[2]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FIB_ON_CHART[2]?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"FibonassiD1",windowID,XDistance,80,60,20, CORNER_RIGHT_UPPER,"D1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FIB_ON_CHART[3]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FIB_ON_CHART[3]?true:false, false, false, true,0);
   
   XDistance+=60;
   
   
   // MTF Buttons
   
   ButtonCreate(m_ChartID,"MTF",windowID,XDistance,0,60,20, CORNER_RIGHT_UPPER,"MTF",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FRACTAL_ALL?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FRACTAL_ALL?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"MTFM15",windowID,XDistance,20,60,20, CORNER_RIGHT_UPPER,"M15",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FRACTAL_ON_CHART[0]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FRACTAL_ON_CHART[0]?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"MTFH1",windowID,XDistance,40,60,20, CORNER_RIGHT_UPPER,"H1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FRACTAL_ON_CHART[1]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FRACTAL_ON_CHART[1]?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"MTFH4",windowID,XDistance,60,60,20, CORNER_RIGHT_UPPER,"H4",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FRACTAL_ON_CHART[2]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FRACTAL_ON_CHART[2]?true:false, false, false, true,0);
   ButtonCreate(m_ChartID,"MTFD1",windowID,XDistance,80,60,20, CORNER_RIGHT_UPPER,"D1",DEFAULT_TXT_FONT,DEFAULT_TXT_SIZE-1, clrBlack,SHOW_FRACTAL_ON_CHART[3]?BUTTON_ON:BUTTON_OFF, clrWhite, SHOW_FRACTAL_ON_CHART[3]?true:false, false, false, true,0);
   
   XDistance+=60;

   OnUpdateTradeSubwindow();

   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::InitFibonacciOnChart(string ChartName)
  {
  /*
   if(!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return false;    
      
   if(ChartName!=MAIN_WINDOW && !InitSubwindow(ChartName))
      return false;

   if(!IsTimeFrameSupported(Period()))
      return false;

   int chartTimeFrameIndex=GetTimeFrameIndex(Period());

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE;i++)
     {
      
      for(int l =0; l<FIBONACCI_LEVELS_SIZE; l++)
        {
         TextCreate(m_ChartID,"FIBOTXT"+GetTimeFramesString(i)+IntegerToString(l),m_WindowID[0],0,0,"","Arial",DEFAULT_TXT_SIZE-2,clrAqua,0,ANCHOR_LEFT_LOWER, false, false, true, 0);
         TrendCreate(m_ChartID,"FIBO"+GetTimeFramesString(i)+IntegerToString(l),m_WindowID[0],0,0,0,0,clrAqua,STYLE_SOLID,i+1,false,false,false, true);
         
        }

        OnUpdateFibonacciOnChart(i);
     }
 
 */    
   return true;
   
 
  }  
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::InitMTFOnChart(string ChartName)
  {
  
  if(!MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE))
      return false;
  
   if(ChartName!=MAIN_WINDOW && !InitSubwindow(ChartName))
      return false;

   Fractal *pFractal=m_Indicators.GetFractal();
   if(pFractal==NULL)
      return false;

   if(!IsTimeFrameSupported(Period()))
      return false;

   int chartTimeFrameIndex=GetTimeFrameIndex(Period());

   for(int i=0; i<ENUM_TIMEFRAMES_ARRAY_SIZE; i++)
     {
         color curr_color = FRACTAL_M15COLOR;
         if(i == 1)
            curr_color = FRACTAL_H1COLOR;
         else if(i == 2)
            curr_color = FRACTAL_H4COLOR;
         else if(i == 3)
            curr_color = FRACTAL_D1COLOR;
         
         TextCreate(m_ChartID,"MTFR_TXT"+GetTimeFramesString(i),m_WindowID[0],0,0,"","Arial",DEFAULT_TXT_SIZE-2,SHOW_FRACTAL_ON_CHART[i] ? curr_color : clrNONE,0,ANCHOR_LEFT_LOWER,SHOW_FRACTAL_ALL?true:false, false, true, 0);
         TrendCreate(m_ChartID,"MTFR_LINE"+GetTimeFramesString(i),m_WindowID[0],0,0,0,0,SHOW_FRACTAL_ON_CHART[i] ? curr_color : clrNONE,STYLE_DASHDOT,i+2,SHOW_FRACTAL_ALL?true:false,false,false,true,0);
         
         TextCreate(m_ChartID,"MTFS_TXT"+GetTimeFramesString(i),m_WindowID[0],0,0,"","Arial",DEFAULT_TXT_SIZE-2,SHOW_FRACTAL_ON_CHART[i] ? curr_color : clrNONE,0,ANCHOR_LEFT_LOWER,SHOW_FRACTAL_ALL?true:false, false, true, 0);
         TrendCreate(m_ChartID,"MTFS_LINE"+GetTimeFramesString(i),m_WindowID[0],0,0,0,0,SHOW_FRACTAL_ON_CHART[i] ? curr_color : clrNONE,STYLE_DASHDOT,i+2,SHOW_FRACTAL_ALL?true:false,false,false,true,0);         

         OnUpdateMTFOnChart(i);
     }

   return true;
  }
*/

///////////////////////////////////////////////////////// OnUpdate stuff   ///////////////////////////////////////////////////////////


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnUpdateTechnicalAnalysisWindow1(int TimeFrameIndex)
  {
   /*

    if(m_WindowsHash.hGetInt(SUBWINDOW1)<0)
      return;
      
   int windowID = ChartChartWindowFind(m_ChartID, SUBWINDOW1);
   if(windowID<0)
      return;


   // tools for all purposes
   string tooltip_comment = NULL;
   string tooltip_comparision = NULL;
   string timeFrameStr=GetTimeFramesString(TimeFrameIndex);

   string lbObj = "";
   color  ObjColor = clrNONE;

   //--------------------
   // AdvIndicator Visuals
   //--------------------


   //    Show M1 Divergence
   lbObj = "BarShiftDivergenceM1";
   ObjColor = DEFAULT_TXT_COLOR;
   tooltip_comment = NULL;
   
   string   Curr_M1_Divergence_Code  = m_AdvIndicators.GetDivergenceIndex().GetM1BarShiftDivergenceCode(0);
   double   Curr_M1_Divergence_Percent  = m_AdvIndicators.GetDivergenceIndex().GetM1BarShiftDivergencePercent(0);

   if(Curr_M1_Divergence_Code == "R-LLHL")
      ObjColor = BULL_DIVERGENCE_COLOR;
   else if(Curr_M1_Divergence_Code == "R-HHLH")
      ObjColor = BEAR_CONVERGENCE_COLOR;
   else if(Curr_M1_Divergence_Code == "H-HLLL")
      ObjColor = HIDDEN_BULL_DIVERGENCE_COLOR;
   else if(Curr_M1_Divergence_Code == "H-LHHH")
      ObjColor = HIDDEN_BEAR_DIVERGENCE_COLOR;
   else if(Curr_M1_Divergence_Code == "C-HHHH")
      ObjColor = BULL_CONVERGENCE_COLOR;
   else if(Curr_M1_Divergence_Code == "C-LLLL")
      ObjColor = BEAR_CONVERGENCE_COLOR;
   else if(Curr_M1_Divergence_Code == "C-LLLL")
      ObjColor = BULL_CONVERGENCE_COLOR;


   for(int i = 0; i < Shift_Look_Back; i++)
   {
      string M1_Divergence_Code  = m_AdvIndicators.GetDivergenceIndex().GetM1BarShiftDivergenceCode(i);
      double M1_Divergence_Percent  = m_AdvIndicators.GetDivergenceIndex().GetM1BarShiftDivergencePercent(i);
      
      tooltip_comment += (string) i+") "+M1_Divergence_Code+"-"+DoubleToStr(M1_Divergence_Percent, 2)+"%"+"\n";
   }

     
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   LabelTextChange(lbObj,Curr_M1_Divergence_Code+"-"+DoubleToStr(Curr_M1_Divergence_Percent, 2)+"%", DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   

   //    Show M5 Divergence
   lbObj = "BarShiftDivergenceM5";
   ObjColor = DEFAULT_TXT_COLOR;
   tooltip_comment = NULL;
   
   string   Curr_M5_Divergence_Code  = m_AdvIndicators.GetDivergenceIndex().GetM5BarShiftDivergenceCode(0);
   double   Curr_M5_Divergence_Percent  = m_AdvIndicators.GetDivergenceIndex().GetM5BarShiftDivergencePercent(0);


   if(Curr_M5_Divergence_Code == "R-LLHL")
      ObjColor = BULL_DIVERGENCE_COLOR;
   else if(Curr_M5_Divergence_Code == "R-HHLH")
      ObjColor = BEAR_CONVERGENCE_COLOR;
   else if(Curr_M5_Divergence_Code == "H-HLLL")
      ObjColor = HIDDEN_BULL_DIVERGENCE_COLOR;
   else if(Curr_M5_Divergence_Code == "H-LHHH")
      ObjColor = HIDDEN_BEAR_DIVERGENCE_COLOR;
   else if(Curr_M5_Divergence_Code == "C-HHHH")
      ObjColor = BULL_CONVERGENCE_COLOR;
   else if(Curr_M5_Divergence_Code == "C-LLLL")
      ObjColor = BEAR_CONVERGENCE_COLOR;


   for(int i = 0; i < Shift_Look_Back; i++)
   {
      string M5_Divergence_Code  = m_AdvIndicators.GetDivergenceIndex().GetM5BarShiftDivergenceCode(i);
      double M5_Divergence_Percent  = m_AdvIndicators.GetDivergenceIndex().GetM5BarShiftDivergencePercent(i);
      
      tooltip_comment += (string) i+") "+M5_Divergence_Code+"-"+DoubleToStr(M5_Divergence_Percent, 2)+"%"+"\n";
   }

     
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   LabelTextChange(lbObj,Curr_M5_Divergence_Code+"-"+DoubleToStr(Curr_M5_Divergence_Percent, 2)+"%", DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
    // M15 - D1 Divergence Index
   
   tooltip_comment = NULL;
   tooltip_comparision = NULL;

   lbObj = "BarShiftDivergence"+timeFrameStr;
   ObjColor = DEFAULT_TXT_COLOR;
   tooltip_comment = "";
   
   string  Curr_Divergence_Code  = m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(TimeFrameIndex, 0);
   double  Curr_Divergence_Percent = m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergencePercent(TimeFrameIndex, 0);
   
   if(Curr_Divergence_Code == "R-LLHL")
      ObjColor = BULL_DIVERGENCE_COLOR;
   else if(Curr_Divergence_Code == "R-HHLH")
      ObjColor = BEAR_CONVERGENCE_COLOR;
   else if(Curr_Divergence_Code == "H-HLLL")
      ObjColor = HIDDEN_BULL_DIVERGENCE_COLOR;
   else if(Curr_Divergence_Code == "H-LHHH")
      ObjColor = HIDDEN_BEAR_DIVERGENCE_COLOR;
   else if(Curr_Divergence_Code == "C-HHHH")
      ObjColor = BULL_CONVERGENCE_COLOR;
   else if(Curr_Divergence_Code == "C-LLLL")
      ObjColor = BEAR_CONVERGENCE_COLOR;

   for(int i = 0; i < Shift_Look_Back; i++){
      string  curr_Divergence_Code  = m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergenceCode(TimeFrameIndex, i);
      double  curr_Divergence_Percent = m_AdvIndicators.GetDivergenceIndex().GetBarShiftDivergencePercent(TimeFrameIndex, i);
      
      tooltip_comment += (string) i+" ="+curr_Divergence_Code+"-"+DoubleToStr(curr_Divergence_Percent, 2)+"%"+"\n";
   
   }
   LabelTextChange(lbObj,Curr_Divergence_Code+"-"+DoubleToStr(Curr_Divergence_Percent , 2)+"%", DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
   // ZZ Indicator Index
   
   //    Show M1 ZigZag
   
   lbObj = "ZigZagM1";
   ObjColor = DEFAULT_TXT_COLOR;
   tooltip_comment = NULL;
   
   double   Curr_ZZ_M1_Price  = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M1, 0);
   
   for(int i = 0; i < Shift_Look_Back; i++)
   {
      double curr_ZZ_M1_Price = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M1, i);
      
      tooltip_comment += (string) i+") "+DoubleToStr(curr_ZZ_M1_Price, Digits)+"\n";
   }
   
   
   if(Curr_ZZ_M1_Price > 0)
      ObjColor = BULL_COLOR;
   else if(Curr_ZZ_M1_Price < 0)
      ObjColor = BEAR_COLOR;
   else
      ObjColor = NEUTRAL_COLOR;
   
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   LabelTextChange(lbObj,DoubleToStr(Curr_ZZ_M1_Price, Digits), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   //    Show M5 ZigZag
   
   lbObj = "ZigZagM5";
   ObjColor = DEFAULT_TXT_COLOR;
   tooltip_comment = NULL;
   
   double   Curr_ZZ_M5_Price = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M5, 0);
   
   for(int i = 0; i < Shift_Look_Back; i++)
   {
      double   curr_ZZ_M5_Price = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(PERIOD_M5, i);
   
      tooltip_comment += (string) i+") "+DoubleToStr(curr_ZZ_M5_Price, Digits)+"\n";
   }
   
   if(Curr_ZZ_M5_Price > 0)
      ObjColor = BULL_COLOR;
   else if(Curr_ZZ_M5_Price < 0)
      ObjColor = BEAR_COLOR;
   else
      ObjColor = NEUTRAL_COLOR;
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   LabelTextChange(lbObj,DoubleToStr(Curr_ZZ_M5_Price, Digits), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
   // Show M15-D1 ZigZag
   
   lbObj = "ZigZag"+timeFrameStr;
   ObjColor = DEFAULT_TXT_COLOR;
   tooltip_comment = NULL;
   ENUM_TIMEFRAMES TimeFrameEnum = GetTimeFrameENUM(TimeFrameIndex);
   
   double Curr_ZZ_Price    =    m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(TimeFrameEnum, 0);
   
   for(int i = 0; i < Shift_Look_Back; i++){
   
      double curr_tmp_ZZ = m_AdvIndicators.GetZigZagAdvIndicator().GetZigZagBarShiftPrice(TimeFrameEnum, i);

      tooltip_comment += (string) i+") "+DoubleToStr(curr_tmp_ZZ, Digits)+"\n";
      
   }
   
   if(Curr_ZZ_Price > 0)
      ObjColor = BULL_COLOR;
   else if(Curr_ZZ_Price < 0)
      ObjColor = BEAR_COLOR;
   else
      ObjColor = NEUTRAL_COLOR;
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(Curr_ZZ_Price, Digits), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
   
   // BULL INDEX
   lbObj = "Bull"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double curBullPercent      = m_AdvIndicators.GetBullBear().GetBullPercent(TimeFrameIndex, 0);
   string BullCrossOver       = m_AdvIndicators.GetBullBear().IsBullCrossOver(TimeFrameIndex, 0) == true?"-BullCO":NULL;

   if(curBullPercent > 50)
      ObjColor = BULL_COLOR;

   for(int i = 0 ; i < Shift_Look_Back; i++)
   {
      double bullPercent   = m_AdvIndicators.GetBullBear().GetBullPercent(TimeFrameIndex, i);
      double bearPercent   = m_AdvIndicators.GetBullBear().GetBearPercent(TimeFrameIndex, i);
      string BullCO        = m_AdvIndicators.GetBullBear().IsBullCrossOver(TimeFrameIndex, i) == true?"-BullCO":NULL;
      string BearCO        = m_AdvIndicators.GetBullBear().IsBearCrossOver(TimeFrameIndex, i) == true?"-BearCO":NULL;
 
      tooltip_comment += (string) i+") "+ DoubleToStr(bullPercent, 2)+"%/"+DoubleToStr(bearPercent, 2)+"%"+BullCO+BearCO+"\n";
      
   }
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   
   LabelTextChange(lbObj,DoubleToStr(curBullPercent, 2)+"%", DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   

   // BEAR INDEX
   lbObj = "Bear"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double curBearPercent = m_AdvIndicators.GetBullBear().GetBearPercent(TimeFrameIndex, 0);
   string BearCrossOver    = m_AdvIndicators.GetBullBear().IsBearCrossOver(TimeFrameIndex, 0) == true ?"-BearCO":NULL;

   if(curBearPercent > 50)
      ObjColor = BEAR_COLOR;     

   for(int i =0 ; i < Shift_Look_Back; i++){
      double bullPercent   = m_AdvIndicators.GetBullBear().GetBullPercent(TimeFrameIndex, i);
      double bearPercent   = m_AdvIndicators.GetBullBear().GetBearPercent(TimeFrameIndex, i);
      string BullCO        = m_AdvIndicators.GetBullBear().IsBullCrossOver(TimeFrameIndex, i) == true?"-BullCO":NULL;
      string BearCO        = m_AdvIndicators.GetBullBear().IsBearCrossOver(TimeFrameIndex, i) == true?"-BearCO":NULL;

      tooltip_comment += (string) i+") "+ DoubleToStr(bullPercent, 2)+"%/"+DoubleToStr(bearPercent, 2)+"%"+BullCO+BearCO+"\n";
      
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   LabelTextChange(lbObj,DoubleToStr(curBearPercent, 2)+"%", DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   // VOLATILITY INDEX
   lbObj = "Vol"+timeFrameStr;
   ObjColor = DEFAULT_TXT_COLOR;
   tooltip_comment = "";

   string   Curr_Volatility_Position_String = GetIndicatorPositionString(m_AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, 0));

   for(int i =0 ; i < Shift_Look_Back; i++){
      string   curr_Volatility_Position_String = GetIndicatorPositionString(m_AdvIndicators.GetVolatility().GetVolatilityPosition(TimeFrameIndex, i));
      
      tooltip_comment += (string) i+")"+curr_Volatility_Position_String+"\n";
      
   }
   
   if(Curr_Volatility_Position_String == "3xStdDev+" || Curr_Volatility_Position_String == "2xStdDev+")
      ObjColor = BULL_COLOR;
   else if(Curr_Volatility_Position_String == "Above Mean" || Curr_Volatility_Position_String == "Equal Mean" || Curr_Volatility_Position_String == "Below Mean")
      ObjColor = NEUTRAL_COLOR;
   else if(Curr_Volatility_Position_String == "3xStdDev-" || Curr_Volatility_Position_String == "2xStdDev-")
      ObjColor = BEAR_COLOR;
   else
      ObjColor = NEUTRAL_COLOR;

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   LabelTextChange(lbObj,Curr_Volatility_Position_String, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   

   // OB INDEX
   lbObj = "OB"+timeFrameStr;
   tooltip_comment = "";
   
   double curOBPercent = m_AdvIndicators.GetOBOS().GetOBPercent(TimeFrameIndex, 0);
   
   ObjColor = curOBPercent>0?BULL_COLOR:NEUTRAL_COLOR;

   for(int i =0 ; i < Shift_Look_Back; i++){
      double obPercent = m_AdvIndicators.GetOBOS().GetOBPercent(TimeFrameIndex, i);
      double osPercent = m_AdvIndicators.GetOBOS().GetOSPercent(TimeFrameIndex, i);
   
      tooltip_comment += (string) i+")="+DoubleToStr(obPercent, 2)+"/"+DoubleToStr(osPercent, 2)+"%\n";
      
   }
   
   LabelTextChange(lbObj,DoubleToStr(curOBPercent, 2)+"%", DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // OS INDEX
   lbObj = "OS"+timeFrameStr;
   tooltip_comment = "";
   
   
   double curOSPercent = m_AdvIndicators.GetOBOS().GetOSPercent(TimeFrameIndex, 0);
   ObjColor = curOSPercent>0?BEAR_COLOR:NEUTRAL_COLOR;

   for(int i =0 ; i < Shift_Look_Back; i++){
      double obPercent = m_AdvIndicators.GetOBOS().GetOBPercent(TimeFrameIndex, i);
      double osPercent = m_AdvIndicators.GetOBOS().GetOSPercent(TimeFrameIndex, i);
    
      tooltip_comment += (string) i+")="+DoubleToStr(obPercent, 2)+"/"+DoubleToStr(osPercent, 2)+"%\n";
      
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }
   
   LabelTextChange(lbObj,DoubleToStr(curOSPercent, 2)+"%", DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
   // OB Position
   lbObj = "OB_Postion_"+timeFrameStr;
   tooltip_comment = "";
   
   string Curr_OB_Position = GetIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOBPosition(TimeFrameIndex, 0));
   
   if(Curr_OB_Position == "3xStdDev+" || Curr_OB_Position == "2xStdDev+")
      ObjColor = BULL_COLOR;
   else if(Curr_OB_Position == "Above Mean" || Curr_OB_Position == "Equal Mean" || Curr_OB_Position == "Below Mean")
      ObjColor = NEUTRAL_COLOR;
   else
      ObjColor = NEUTRAL_COLOR;

   for(int i =0 ; i < Shift_Look_Back; i++){
   
      string curr_OB_Position = GetIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOBPosition(TimeFrameIndex, i));
      
      tooltip_comment += (string) i+")="+curr_OB_Position+"\n";
      
   }
   
   LabelTextChange(lbObj,Curr_OB_Position, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
   // OS Position
   lbObj = "OS_Postion_"+timeFrameStr;
   tooltip_comment = "";
   
   string Curr_OS_Position = GetIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOSPosition(TimeFrameIndex, 0));
   
   if(Curr_OS_Position == "3xStdDev+" || Curr_OS_Position == "2xStdDev+")
      ObjColor = BEAR_COLOR;
   else if(Curr_OS_Position == "Above Mean" || Curr_OS_Position == "Equal Mean" || Curr_OS_Position == "Below Mean")
      ObjColor = NEUTRAL_COLOR;
   else
      ObjColor = NEUTRAL_COLOR;

   for(int i =0 ; i < Shift_Look_Back; i++){
   
      string curr_OS_Position = GetIndicatorPositionString(m_AdvIndicators.GetOBOS().GetOSPosition(TimeFrameIndex, i));
      
      tooltip_comment += (string) i+")="+curr_OS_Position+"\n";
      
   }
   
   LabelTextChange(lbObj,Curr_OS_Position, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   

   // Bollinger Band Positions
   lbObj = "Bollinger_StdDev"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   

   // Bollinger Current Position, Max position, Min Position
   
   double Curr_BB = m_Indicators.GetBands().GetBandStdDevPosition(TimeFrameIndex, 0);
   double Max_BB  = m_Indicators.GetBands().GetBandMaxStdDevPosition(TimeFrameIndex, 0);
   double Min_BB  = m_Indicators.GetBands().GetBandMinStdDevPosition(TimeFrameIndex, 0);
   
   
   for(int i = 0; i < Shift_Look_Back; i++){
      double curr_BB = m_Indicators.GetBands().GetBandStdDevPosition(TimeFrameIndex, i);
      double max_BB  = m_Indicators.GetBands().GetBandMaxStdDevPosition(TimeFrameIndex, i);
      double min_BB  = m_Indicators.GetBands().GetBandMinStdDevPosition(TimeFrameIndex, i);
   
      tooltip_comment += (string) i+")="+DoubleToStr(curr_BB, 2)+"/"+DoubleToStr(max_BB, 2)+"/"+DoubleToStr(min_BB, 2)+"\n";
   }

   if(Curr_BB > 3 || Curr_BB < -3)
      ObjColor = EXTREME_COLOR;
   else if(Curr_BB < -2 && Curr_BB > 2)
      ObjColor = TREND_COLOR;
   else
      ObjColor = NEUTRAL_COLOR;

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(Curr_BB, 2)+"/"+DoubleToStr(Max_BB, 2)+"/"+DoubleToStr(Min_BB, 2), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   // Band Position
   lbObj = "BandPos"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";

   
   string curBandPos=GetEnumIndicatorPositionString(m_Indicators.GetBands().GetPricePosition(TimeFrameIndex, 0));
   
   if(curBandPos == "3xStdDev+" || curBandPos == "2xStdDev+" || curBandPos == "AboveMean")
      ObjColor = BULL_COLOR;
      
   else if(curBandPos == "3xStdDev-" || curBandPos == "2xStdDev-" || curBandPos == "BelowMean")
      ObjColor = BEAR_COLOR;
      

   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string bandpos=GetEnumIndicatorPositionString(m_Indicators.GetBands().GetPricePosition(TimeFrameIndex, i));
   
      tooltip_comment += (string)i+")="+bandpos+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,curBandPos, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

   // Buy Indicator Trigger 
   lbObj = "BIndicator"+timeFrameStr; 
   ObjColor = NEUTRAL_COLOR; 
   tooltip_comment = ""; 
    
    
   ENUM_INDICATOR_POSITION Curr_Bull_Indicator_Position = m_AdvIndicators.GetIndicatorsTrigger().GetBuyPosition(TimeFrameIndex, 0); 
 
      
   // SHOULD BE MODIFY TO NEEDED 
   if(Curr_Bull_Indicator_Position < 3) 
      ObjColor = BULL_COLOR; 
      
    
   for(int i =0 ; i < Shift_Look_Back; i++) 
   { 
      string curr_Buy_Indicator_Position = GetEnumIndicatorPositionString(m_AdvIndicators.GetIndicatorsTrigger().GetBuyPosition(TimeFrameIndex, i));  
    
      tooltip_comment += (string) i+")="+curr_Buy_Indicator_Position+"\n"; 
   } 
 
 
   if(StringLen(tooltip_comment) > 256) 
   { 
      tooltip_comment = StringSubstr(tooltip_comment,0, 256); 
   } 
 
   LabelTextChange(lbObj,GetEnumIndicatorPositionString(Curr_Bull_Indicator_Position), DEFAULT_TXT_SIZE, NULL, ObjColor); 
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment); 
 
 
   // Sell Indicator Trigger 
   lbObj = "SIndicator"+timeFrameStr; 
   ObjColor = NEUTRAL_COLOR; 
   tooltip_comment = ""; 
    
    
   ENUM_INDICATOR_POSITION Curr_Bear_Indicator_Position = m_AdvIndicators.GetIndicatorsTrigger().GetSellPosition(TimeFrameIndex, 0);  

    
   // SHOULD BE MODIFY TO NEEDED 
   if(Curr_Bear_Indicator_Position < 3) 
      ObjColor = BEAR_COLOR;  
    
   for(int i =0 ; i < Shift_Look_Back; i++){ 
      string curr_Sell_Indicator_Position = GetEnumIndicatorPositionString(m_AdvIndicators.GetIndicatorsTrigger().GetSellPosition(TimeFrameIndex, i)); 
    
      tooltip_comment += (string) i+")="+curr_Sell_Indicator_Position+"\n"; 
   } 
 
   if(StringLen(tooltip_comment) > 256) 
   { 
      tooltip_comment = StringSubstr(tooltip_comment,0, 256); 
   } 
 
   LabelTextChange(lbObj,GetEnumIndicatorPositionString(Curr_Bear_Indicator_Position), DEFAULT_TXT_SIZE, NULL, ObjColor); 
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);



   // Buy Line Trigger
   lbObj = "BLineTrigger"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   
   ENUM_INDICATOR_POSITION Curr_Bull_Line_Position = m_AdvIndicators.GetLineTrigger().GetBuyPosition(TimeFrameIndex, 0);
   
   // SHOULD BE MODIFY TO NEEDED
   if(Curr_Bull_Line_Position < 3)
      ObjColor = BULL_COLOR; 
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      string  curr_Buy_Line_Position = GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetBuyPosition(TimeFrameIndex, i)); 
   
      tooltip_comment += (string) i+")="+curr_Buy_Line_Position+"\n";
   }


   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,GetEnumIndicatorPositionString(Curr_Bull_Line_Position), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // Sell Line Trigger
   lbObj = "SLineTrigger"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   
   ENUM_INDICATOR_POSITION Curr_Bear_Line_Position = m_AdvIndicators.GetLineTrigger().GetSellPosition(TimeFrameIndex, 0);

   
   // SHOULD BE MODIFY TO NEEDED
   if(Curr_Bear_Line_Position < 3)
      ObjColor = BEAR_COLOR; 
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      string  curr_Bear_Line_Position = GetEnumIndicatorPositionString(m_AdvIndicators.GetLineTrigger().GetSellPosition(TimeFrameIndex, i));

      tooltip_comment += (string) i+")="+curr_Bear_Line_Position+"\n";
   }

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,GetEnumIndicatorPositionString(Curr_Bear_Line_Position), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

   // MTF BarShift
   lbObj = "MTFFractal"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double curr_fractal_res_price = m_Indicators.GetFractal().GetFractalResistancePrice(TimeFrameIndex, 0);
   double curr_fractal_sup_price = m_Indicators.GetFractal().GetFractalSupportPrice(TimeFrameIndex, 0);
   
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      double fractal_res_price = m_Indicators.GetFractal().GetFractalResistancePrice(TimeFrameIndex, i);
      double fractal_sup_price = m_Indicators.GetFractal().GetFractalSupportPrice(TimeFrameIndex, i);
   
      tooltip_comment += (string) i+")="+DoubleToStr(fractal_res_price, Digits)+"/"+DoubleToStr(fractal_sup_price, Digits)+"\n";
   }

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(curr_fractal_res_price, Digits)+"/"+DoubleToStr(curr_fractal_sup_price, Digits), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

   // CS Price Action Body
   lbObj = "CSPriceActionBody"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double cur_BodyCS_Cumm_Percent=m_CSAnalysis.GetCummBodyPercent(TimeFrameIndex, 0);
   ENUM_INDICATOR_POSITION curr_BodyCS_Cumm_Pos = m_CSAnalysis.GetCummBodyPosition(TimeFrameIndex, 0);

   if(cur_BodyCS_Cumm_Percent == Plus_3_StdDev)
      ObjColor = BULL_COLOR;
   else if(cur_BodyCS_Cumm_Percent == Plus_2_StdDev || cur_BodyCS_Cumm_Percent == Minus_2_StdDev)
      ObjColor = EXTREME_COLOR;
   else if(cur_BodyCS_Cumm_Percent == Minus_3_StdDev)
      ObjColor = BEAR_COLOR;
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      double cumm_body_percent = m_CSAnalysis.GetCummBodyPercent(TimeFrameIndex, i);
      string cumm_body_pos = GetEnumIndicatorPositionString(m_CSAnalysis.GetCummBodyPosition(TimeFrameIndex, i));
   
      tooltip_comment += (string) i+")="+DoubleToStr(cumm_body_percent, 2)+"/"+cumm_body_pos+"\n";
   }

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(cur_BodyCS_Cumm_Percent, 2)+"/"+GetEnumIndicatorPositionString(curr_BodyCS_Cumm_Pos), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // CS Price Action Top Wick
   lbObj = "CSPriceActionTop"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double cur_TopCS_Cumm_Percent=m_CSAnalysis.GetCummTopWickPercent(TimeFrameIndex, 0);
   ENUM_INDICATOR_POSITION curr_TopCS_Cumm_Pos = m_CSAnalysis.GetCummTopPosition(TimeFrameIndex, 0);

   if(curr_TopCS_Cumm_Pos == Plus_3_StdDev)
      ObjColor = BEAR_COLOR;
   else if(curr_TopCS_Cumm_Pos == Plus_2_StdDev || curr_TopCS_Cumm_Pos == Minus_2_StdDev)
      ObjColor = EXTREME_COLOR;
   else if(curr_TopCS_Cumm_Pos == Minus_3_StdDev)
      ObjColor = BULL_COLOR;
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      double cumm_top_percent = m_CSAnalysis.GetCummTopWickPercent(TimeFrameIndex, i);
      string cumm_top_pos = GetEnumIndicatorPositionString(m_CSAnalysis.GetCummTopPosition(TimeFrameIndex, i));
   
      tooltip_comment += (string) i+")="+DoubleToStr(cumm_top_percent, 2)+"/"+cumm_top_pos+"\n";
   }

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(cur_TopCS_Cumm_Percent, 2)+"/"+GetEnumIndicatorPositionString(curr_TopCS_Cumm_Pos), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
   // CS Price Action Bottom Wick
   lbObj = "CSPriceActionLow"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double cur_BotCS_Cumm_Percent=m_CSAnalysis.GetCummBotWickPercent(TimeFrameIndex, 0);
   ENUM_INDICATOR_POSITION curr_BotCS_Cumm_Pos = m_CSAnalysis.GetCummBotPosition(TimeFrameIndex, 0);

   if(curr_BotCS_Cumm_Pos == Plus_3_StdDev)
      ObjColor = BULL_COLOR;
   else if(curr_BotCS_Cumm_Pos == Plus_2_StdDev || curr_BotCS_Cumm_Pos == Minus_2_StdDev)
      ObjColor = EXTREME_COLOR;
   else if(curr_BotCS_Cumm_Pos == Minus_3_StdDev)
      ObjColor = BEAR_COLOR;
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      double cumm_bot_percent = m_CSAnalysis.GetCummBotWickPercent(TimeFrameIndex, i);
      string cumm_bot_pos = GetEnumIndicatorPositionString(m_CSAnalysis.GetCummBotPosition(TimeFrameIndex, i));
   
      tooltip_comment += (string) i+")="+DoubleToStr(cumm_bot_percent, 2)+"/"+cumm_bot_pos+"\n";
   }

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(cur_BotCS_Cumm_Percent, 2)+"/"+GetEnumIndicatorPositionString(curr_BotCS_Cumm_Pos), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

   
   // CS Price Action Bottom Wick
   lbObj = "CSPriceActionTopBotBias"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   int curr_cs_topbot_bias=m_CSAnalysis.GetCummTopBotBias(TimeFrameIndex, 0);

   if(curr_cs_topbot_bias == BULL_TRIGGER)
      ObjColor = BULL_COLOR;
   else if(curr_cs_topbot_bias == BEAR_TRIGGER)
      ObjColor = BEAR_COLOR;
      
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      string cumm_cs_top_bias = GetTrend(m_CSAnalysis.GetCummTopBotBias(TimeFrameIndex, i));
      tooltip_comment += (string) i+")="+cumm_cs_top_bias+"\n";
   }

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,GetTrend(curr_cs_topbot_bias), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // CS Body && HL ATR Percent
   lbObj = "CSBodyHLATR"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double curr_cs_body_atr_percent=m_Indicators.GetBodyCSATRPercent(TimeFrameIndex, 0);
   double curr_cs_hl_atr_percent=m_Indicators.GetHighLowCSATRPercent(TimeFrameIndex, 0);

   if(curr_cs_body_atr_percent > 180 || curr_cs_hl_atr_percent > 200)
      ObjColor = BULL_COLOR;
   if(curr_cs_body_atr_percent < -180 || curr_cs_hl_atr_percent > 200)
      ObjColor = BEAR_COLOR;
      
   
   for(int i =0 ; i < Shift_Look_Back; i++){
      double cs_body_atr_percent = m_Indicators.GetBodyCSATRPercent(TimeFrameIndex, i);
      double cs_hl_atr_percent = m_Indicators.GetHighLowCSATRPercent(TimeFrameIndex, i);
      
      tooltip_comment += (string) i+")="+DoubleToStr(cs_body_atr_percent, 2)+"/"+DoubleToStr(cs_hl_atr_percent, 2)+"\n";
   }

   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(curr_cs_body_atr_percent, 2)+"/"+DoubleToStr(curr_cs_hl_atr_percent, 2), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

   */

   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnUpdateTechnicalAnalysisWindow2(int TimeFrameIndex)
  {   
   /*
   if(m_WindowsHash.hGetInt(SUBWINDOW2)<0)
      return;
      
   int windowID = ChartChartWindowFind(m_ChartID, SUBWINDOW2);
   if(windowID<0)
      return; 
      
   string tooltip_comment = NULL;
   string tooltip_comparision = NULL;
   string timeFrameStr=GetTimeFramesString(TimeFrameIndex);
   
   string lbObj = "";
   color  ObjColor = clrNONE;
   
   //--------------------
   // FLAGS VISUALS
   //--------------------
   
   
   // Market Bias
   
   lbObj = "MarketBias"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";   
   
   string curr_market_bias = m_MarketCondition.GetMarketMomentumString(TimeFrameIndex, 0);
   
   if(curr_market_bias == "StrongBull")
      ObjColor = BULL_COLOR;
      
   else if(curr_market_bias == "StrongBear")
      ObjColor = BEAR_COLOR;
   


   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string  market_bias_string = m_MarketCondition.GetMarketMomentumString(TimeFrameIndex, i);
      tooltip_comment += (string)i+")="+market_bias_string+"\n";
   }


   
  if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,curr_market_bias, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
   // MarketCondition
   
   lbObj = "MarketCondition"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   ENUM_MARKET_CONDITION  Curr_MarketCondtion_ENUM = m_MarketCondition.GetEnumMarketCondition(TimeFrameIndex, 0);
   string  Curr_MarketCondtion_String = m_MarketCondition.GetStringMarketCondition(TimeFrameIndex, 0);
   
   if(Curr_MarketCondtion_ENUM == Bull_Trend_3x || Curr_MarketCondtion_ENUM == Bear_Trend_3x)
   {
      ObjColor = EXTREME_COLOR;
   }
   else if(Curr_MarketCondtion_ENUM == Bull_Trend_2x || Curr_MarketCondtion_ENUM == Bull_Channel || Curr_MarketCondtion_ENUM == Bear_Trend_2x || Curr_MarketCondtion_ENUM == Bear_Channel)
   {
      ObjColor = TREND_COLOR;
   }
   else if(Curr_MarketCondtion_ENUM == Bull_Squeeze || Curr_MarketCondtion_ENUM == Bear_Squeeze)
   {
      ObjColor = SQUEEZE_COLOR;
   }
   else
   {
      ObjColor = NEUTRAL_COLOR;
   }
      

   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string  curr_MarketCondtion_String = m_MarketCondition.GetStringMarketCondition(TimeFrameIndex, i);
      tooltip_comment += (string)i+")="+curr_MarketCondtion_String+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,Curr_MarketCondtion_String, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);



   // Market Condition Anchored Resistance
   
   lbObj = "MarketConditionResistance"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";

   double anchored_resistance = m_MarketCondition.GetAnchoredResistance(TimeFrameIndex);
   
   if(anchored_resistance > 0 && CandleSticksBuffer[0][0].GetHigh() >= anchored_resistance)
      ObjColor = clrSpringGreen;
   
   LabelTextChange(lbObj,DoubleToStr(anchored_resistance, Digits), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // Market Condition Anchored Support
   
   lbObj = "MarketConditionSupport"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";

   double anchored_support = m_MarketCondition.GetAnchoredSupport(TimeFrameIndex);
   
   if(anchored_support > 0 && CandleSticksBuffer[0][0].GetLow() <= anchored_support)
      ObjColor = clrSpringGreen;
   
   LabelTextChange(lbObj,DoubleToStr(anchored_support, Digits), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // MarketCondition
   
   lbObj = "MarketConditionBias"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   int curr_cs_topbot_bias=m_MarketCondition.GetSqueezeCandleStickWickBias(TimeFrameIndex, 0);

   if(curr_cs_topbot_bias == BULL_TRIGGER)
      ObjColor = BULL_COLOR;
   else if(curr_cs_topbot_bias == BEAR_TRIGGER)
      ObjColor = BEAR_COLOR;
      
   for(int i =0 ; i < 2; i++)
   {
      string  curr_squeeze_bias = GetTrend(m_MarketCondition.GetSqueezeCandleStickWickBias(TimeFrameIndex, i));
      tooltip_comment += (string)i+")="+curr_squeeze_bias+"\n";
   }
      
      
   LabelTextChange(lbObj,GetTrend(curr_cs_topbot_bias), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

 // ------------------------------

   lbObj = "bandlogic"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   
   string cur_band_bias = GetEnumQuadrantString(m_Indicators.GetBands().GetBandBias(TimeFrameIndex, 0));
   
   if(cur_band_bias == "Upper")
      ObjColor = BULL_COLOR;
   else if(cur_band_bias == "Lower")
      ObjColor = BEAR_COLOR;    
   
   
   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string band_bias = GetEnumQuadrantString(m_Indicators.GetBands().GetBandBias(TimeFrameIndex, i));
      tooltip_comment += (string) i+")="+band_bias+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,cur_band_bias, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


 // ------------------------------

   lbObj = "tenkanlogic"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   
   string curr_tenkan_quadrant = GetEnumQuadrantString(m_Indicators.GetIchimoku().GetTenKanQuadrant(TimeFrameIndex, 0));
   
   if(curr_tenkan_quadrant == "Upper")
      ObjColor = BULL_COLOR;
   else if(curr_tenkan_quadrant == "Lower")
      ObjColor = BEAR_COLOR;    
   
   
   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string tenkan_quadrant = GetEnumQuadrantString(m_Indicators.GetIchimoku().GetTenKanQuadrant(TimeFrameIndex, i));
      tooltip_comment += (string) i+")="+tenkan_quadrant+"\n";
   }
   

   LabelTextChange(lbObj,curr_tenkan_quadrant, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);



 // ------------------------------

   lbObj = "kijunlogic"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   
   string curr_kijun_quadrant = GetEnumQuadrantString(m_Indicators.GetIchimoku().GetKijunQuadrant(TimeFrameIndex, 0));
   
   if(curr_kijun_quadrant == "Upper")
      ObjColor = BULL_COLOR;
   else if(curr_kijun_quadrant == "Lower")
      ObjColor = BEAR_COLOR;    
   
   
   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string kijun_quadrant = GetEnumQuadrantString(m_Indicators.GetIchimoku().GetKijunQuadrant(TimeFrameIndex, i));
      tooltip_comment += (string) i+")="+kijun_quadrant+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,curr_kijun_quadrant, DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

   // ------------------------------

   lbObj = "singlepattern"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   ENUM_CANDLESTICKPATTERN curr_single_pattern = m_CSAnalysis.GetSingleCandleStickPattern(TimeFrameIndex, 0);
   ObjColor = GetPatternColorSingle(curr_single_pattern);

   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string single_pattern = GetCSPatternString(m_CSAnalysis.GetSingleCandleStickPattern(TimeFrameIndex, i));
      tooltip_comment += (string) i+")="+single_pattern+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,GetCSPatternString(curr_single_pattern), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // ------------------------------

   lbObj = "dualpattern"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   ENUM_DUALCANDLESTICKPATTERN cur_dual_pattern = m_CSAnalysis.GetDualCandleStickPattern(TimeFrameIndex, 0);
   ObjColor = GetPatternColorDual(cur_dual_pattern);    
   
   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string dual_pattern = GetCSPatternString(m_CSAnalysis.GetDualCandleStickPattern(TimeFrameIndex, i));
      tooltip_comment += (string) i+")="+dual_pattern+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,GetCSPatternString(cur_dual_pattern), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);

   // ------------------------------

   lbObj = "triplepattern"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   ENUM_TRIPLECANDLESTICKPATTERN cur_triple_pattern = m_CSAnalysis.GetTripleCandleStickPattern(TimeFrameIndex, 0);
   ObjColor = GetPatternColorTriple(cur_triple_pattern);    
   
   for(int i =0 ; i < Shift_Look_Back; i++)
   {
      string triple_pattern = GetCSPatternString(m_CSAnalysis.GetTripleCandleStickPattern(TimeFrameIndex, i));
      tooltip_comment += (string) i+")="+triple_pattern+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,GetCSPatternString(cur_triple_pattern), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   
    // Buy Reversal
   
   lbObj = "BuyReversal"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double buy_reversal_probability = m_Probability.GetReversalProbability().GetBuyReversalProbability(TimeFrameIndex, 0);

   if(buy_reversal_probability > 50)
      ObjColor = BULL_COLOR;
      
   for(int i = 0; i < Shift_Look_Back; i++)
      tooltip_comment+= (string)i+")="+DoubleToStr(m_Probability.GetReversalProbability().GetBuyReversalProbability(TimeFrameIndex, i), 2)+"\n";
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(buy_reversal_probability, 2), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // Sell Reversal
   
   lbObj = "SellReversal"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double sell_reversal_probability = m_Probability.GetReversalProbability().GetSellReversalProbability(TimeFrameIndex, 0);

   if(sell_reversal_probability > 50)
      ObjColor = BEAR_COLOR;
      
   for(int i = 0; i < Shift_Look_Back; i++)
      tooltip_comment+= (string)i+")="+DoubleToStr(m_Probability.GetReversalProbability().GetSellReversalProbability(TimeFrameIndex, i), 2)+"\n";
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(sell_reversal_probability, 2), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


 // Buy Market Bias
   lbObj = "BMarketBias"+timeFrameStr; 
   ObjColor = NEUTRAL_COLOR; 
   tooltip_comment = ""; 
    
    
   double Curr_Bull_Market_Bias = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(TimeFrameIndex, 0); 
   double Curr_Bull_Mean = m_AdvIndicators.GetMarketMomentum().GetBuyMean(TimeFrameIndex, 0); 
   string Curr_Bull_Market_Trend = GetTrend(m_AdvIndicators.GetMarketMomentum().GetBuyMeanTrend(TimeFrameIndex, 0)); 
      
   // SHOULD BE MODIFY TO NEEDED 
   if(Curr_Bull_Market_Trend == "Bull") 
      ObjColor = BULL_COLOR;  
   if(Curr_Bull_Market_Trend == "Bear") 
      ObjColor = BEAR_COLOR;   
    
   for(int i =0 ; i < Shift_Look_Back; i++) 
   { 
      double curr_Bull_Market_Bias = m_AdvIndicators.GetMarketMomentum().GetBuyPercent(TimeFrameIndex, i); 
      double curr_Bull_Mean = m_AdvIndicators.GetMarketMomentum().GetBuyMean(TimeFrameIndex, i); 
      string curr_Bull_Market_Trend = GetTrend(m_AdvIndicators.GetMarketMomentum().GetBuyMeanTrend(TimeFrameIndex, i)); 
    
      tooltip_comment += (string) i+")="+DoubleToStr(curr_Bull_Market_Bias, 2)+"/"+DoubleToStr(curr_Bull_Mean, 2)+"/"+curr_Bull_Market_Trend+"\n"; 
   } 
 
 
   if(StringLen(tooltip_comment) > 256) 
   { 
      tooltip_comment = StringSubstr(tooltip_comment,0, 256); 
   } 
 
   LabelTextChange(lbObj,DoubleToStr(Curr_Bull_Market_Bias, 2)+"/"+DoubleToStr(Curr_Bull_Mean, 2)+"/"+Curr_Bull_Market_Trend, DEFAULT_TXT_SIZE, NULL, ObjColor); 
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment); 
 

   // Sell Market Bias
   lbObj = "SMarketBias"+timeFrameStr; 
   ObjColor = NEUTRAL_COLOR; 
   tooltip_comment = ""; 
    
    
   double Curr_Bear_Market_Bias = m_AdvIndicators.GetMarketMomentum().GetSellPercent(TimeFrameIndex, 0); 
   double Curr_Bear_Mean = m_AdvIndicators.GetMarketMomentum().GetSellMean(TimeFrameIndex, 0); 
   string Curr_Bear_Market_Trend = GetTrend(m_AdvIndicators.GetMarketMomentum().GetSellMeanTrend(TimeFrameIndex, 0)); 
   
      
   // SHOULD BE MODIFY TO NEEDED 
   if(Curr_Bear_Market_Trend == "Bull") 
      ObjColor = BULL_COLOR;  
   if(Curr_Bear_Market_Trend == "Bear") 
      ObjColor = BEAR_COLOR;  


   for(int i =0 ; i < Shift_Look_Back; i++) 
   { 
      double curr_Bear_Market_Bias = m_AdvIndicators.GetMarketMomentum().GetSellPercent(TimeFrameIndex, i); 
      double curr_Bear_Mean = m_AdvIndicators.GetMarketMomentum().GetSellMean(TimeFrameIndex, i); 
      string curr_Bear_Market_Trend = GetTrend(m_AdvIndicators.GetMarketMomentum().GetSellMeanTrend(TimeFrameIndex, i)); 
    
      tooltip_comment += (string) i+")="+DoubleToStr(curr_Bear_Market_Bias, 2)+"/"+DoubleToStr(curr_Bear_Mean, 2)+"/"+curr_Bear_Market_Trend+"\n"; 
   } 
 
 
   if(StringLen(tooltip_comment) > 256) 
   { 
      tooltip_comment = StringSubstr(tooltip_comment,0, 256); 
   } 
 
   LabelTextChange(lbObj,DoubleToStr(Curr_Bear_Market_Bias, 2)+"/"+DoubleToStr(Curr_Bear_Mean, 2)+"/"+Curr_Bear_Market_Trend, DEFAULT_TXT_SIZE, NULL, ObjColor); 
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment); 


   // Buy Trend
   
   lbObj = "BuyTrend"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double buy_trend_probability = m_AdvIndicators.GetTrendIndexes().GetBuyTrendIndexes(TimeFrameIndex, 0);
   double buy_trend_mean = m_AdvIndicators.GetTrendIndexes().GetBuyIndexesMean(TimeFrameIndex, 0);
   int buy_trend_pos = m_AdvIndicators.GetTrendIndexes().GetBuyMeanTrend(TimeFrameIndex, 0);

   if(buy_trend_pos == BULL_TRIGGER)
      ObjColor = BULL_COLOR;
   else if(buy_trend_pos == BEAR_TRIGGER)
      ObjColor = BEAR_COLOR;
      
   for(int i = 0; i < Shift_Look_Back; i++)
   {
      double cur_buy_trend_prob = m_AdvIndicators.GetTrendIndexes().GetBuyTrendIndexes(TimeFrameIndex, i);
      double cur_buy_trend_mean = m_AdvIndicators.GetTrendIndexes().GetBuyIndexesMean(TimeFrameIndex, i);
      int   cur_buy_trend_pos = m_AdvIndicators.GetTrendIndexes().GetBuyMeanTrend(TimeFrameIndex, i);
      
      tooltip_comment+= (string)i+")="+DoubleToStr(cur_buy_trend_prob, 2)+"/"+DoubleToStr(cur_buy_trend_mean, 2)+"/"+GetTrend(cur_buy_trend_pos)+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(buy_trend_probability, 2)+"/"+DoubleToStr(buy_trend_mean, 2)+"/"+GetTrend(buy_trend_pos), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);


   // Sell Trend
   
   lbObj = "SellTrend"+timeFrameStr;
   ObjColor = NEUTRAL_COLOR;
   tooltip_comment = "";
   
   double sell_trend_probability = m_AdvIndicators.GetTrendIndexes().GetSellTrendIndexes(TimeFrameIndex, 0);
   double sell_trend_mean = m_AdvIndicators.GetTrendIndexes().GetSellIndexesMean(TimeFrameIndex, 0);
   int sell_trend_pos = m_AdvIndicators.GetTrendIndexes().GetSellMeanTrend(TimeFrameIndex, 0);


   if(sell_trend_pos == BULL_TRIGGER)
      ObjColor = BULL_COLOR;
   else if(sell_trend_pos == BEAR_TRIGGER)
      ObjColor = BEAR_COLOR;

    
   for(int i = 0; i < Shift_Look_Back; i++)
   {
      double cur_sell_trend_prob = m_AdvIndicators.GetTrendIndexes().GetSellTrendIndexes(TimeFrameIndex, i);
      double cur_sell_trend_mean = m_AdvIndicators.GetTrendIndexes().GetSellIndexesMean(TimeFrameIndex, i);
      int   cur_sell_trend_pos = m_AdvIndicators.GetTrendIndexes().GetSellMeanTrend(TimeFrameIndex, i);
      
      tooltip_comment+= (string)i+")="+DoubleToStr(cur_sell_trend_prob, 2)+"/"+DoubleToStr(cur_sell_trend_mean, 2)+"/"+GetTrend(cur_sell_trend_pos)+"\n";
   }
   
   if(StringLen(tooltip_comment) > 256)
   {
      tooltip_comment = StringSubstr(tooltip_comment,0, 256);
   }

   LabelTextChange(lbObj,DoubleToStr(sell_trend_probability, 2)+"/"+DoubleToStr(sell_trend_mean, 2)+"/"+GetTrend(sell_trend_pos), DEFAULT_TXT_SIZE, NULL, ObjColor);
   ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
   
   */
}   
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnUpdateTechnicalAnalysisWindow3(int TimeFrameIndex)
  {
      /*
      
      if(m_WindowsHash.hGetInt(SUBWINDOW3)<0)
         return;
         
      int windowID = ChartChartWindowFind(m_ChartID, SUBWINDOW3);
      if(windowID<0)
         return;
   
      // tools for all purposes
      string tooltip_comment = NULL;
      string tooltip_comparision = NULL;
      string timeFrameStr=GetTimeFramesString(TimeFrameIndex);
   
      string lbObj = "";
      color  ObjColor = clrNONE;
      string   Filter_Comment;
      
      
      ////////////////////////////////////////        Guan Strategy   ////////////////////////////////////////////////////////////////////

      ////////////////////////////////////////               Open Buy            /////////////////////////////////////////////////////////
      
      
      // Buy Filter 1 ------------------------------
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Filter_1_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == Type_Reversal)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Reversal, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Reversal, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Reversal, Filter_1)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == Type_Trend)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Trend, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Trend, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Trend, Filter_1)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == Type_Breakout)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Breakout, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Breakout, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Breakout, Filter_1)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == Type_Continuation)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Continuation, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Continuation, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Continuation, Filter_1)?BULL_COLOR:NEUTRAL_COLOR;
         }

         else if(i == Type_Fakeout)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Fakeout, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Fakeout, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Fakeout, Filter_1)?BULL_COLOR:NEUTRAL_COLOR;
         }    
         
            
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }
      
      // Buy Filter 2 ------------------------------
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Filter_2_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Reversal, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Reversal, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Reversal, Filter_2)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Trend, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Trend, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Trend, Filter_2)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Breakout, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Breakout, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Breakout, Filter_2)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Continuation, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Continuation, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Continuation, Filter_2)?BULL_COLOR:NEUTRAL_COLOR;
         }    
         
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Fakeout, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Fakeout, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Fakeout, Filter_2)?BULL_COLOR:NEUTRAL_COLOR;
         }       
         
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }
      
      // Buy Filter 3 ------------------------------
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Filter_3_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Reversal, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Reversal, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Reversal, Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Trend, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Trend, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Trend, Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Breakout, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Breakout, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Breakout, Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Continuation, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Continuation, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Continuation, Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Fakeout, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Fakeout, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Fakeout, Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }
     
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }
      
      // Buy Check_Risk_Buy ------------------------------  
      
      for(int i = 0; i < Strategy_Number; i++)
      {
         lbObj = "Check_Risk_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Reversal, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Reversal, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Reversal, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Trend, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Trend, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Trend, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Breakout, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Breakout, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Breakout, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Continuation, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Continuation, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Continuation, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyComment(Type_Fakeout, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterBuyToolTip(Type_Fakeout, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterBuyFlag(Type_Fakeout, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }   
         
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
         
      }
      
      
      // Buy Open Order Comment ------------------------------
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Open_Order_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyComment(Type_Reversal, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyToolTip(Type_Reversal);
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyComment(Type_Trend, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyToolTip(Type_Trend);
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyComment(Type_Breakout, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyToolTip(Type_Breakout);
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyComment(Type_Continuation, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyToolTip(Type_Continuation);
         }
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyComment(Type_Fakeout, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenBuyToolTip(Type_Fakeout);
         }
    
         ObjColor = (Filter_Comment=="N/A"||Filter_Comment=="----")?NEUTRAL_COLOR:COMMENT_COLOR;    
         
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }

      // Buy Stop Order Comment ------------------------------
      bool isStopActivate = false;
      
      
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Stop_Order_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         isStopActivate = false;
         
         if(i == 0)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopBuyFlag(Type_Reversal);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopBuyComment(Type_Reversal);
         }
         else if(i == 1)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopBuyFlag(Type_Trend);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopBuyComment(Type_Trend);
         }
         else if(i == 2)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopBuyFlag(Type_Breakout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopBuyComment(Type_Breakout);
         }
         else if(i == 3)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopBuyFlag(Type_Continuation);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopBuyComment(Type_Continuation);
         }
         else if(i == 4)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopBuyFlag(Type_Fakeout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopBuyComment(Type_Fakeout);
         }
    
         ObjColor = isStopActivate?COMMENT_COLOR:NEUTRAL_COLOR;    
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
      }

     
      // Buy Modify Order Comment ------------------------------
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Modify_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifyBuyComment(Type_Reversal);
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifyBuyComment(Type_Trend);
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifyBuyComment(Type_Breakout);
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifyBuyComment(Type_Continuation);
         }
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifyBuyComment(Type_Fakeout);
         }
    
         ObjColor = (Filter_Comment=="N/A"||Filter_Comment=="----")?NEUTRAL_COLOR:COMMENT_COLOR;    
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
      }
      
      // Buy Open Close Comment ------------------------------
      lbObj = "N/A";
      ObjColor = NEUTRAL_COLOR;
      tooltip_comment = "";
      Filter_Comment = "";
   
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Close_Order_Buy_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         isStopActivate = false;
         
         if(i == 0)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseBuyFlag(Type_Reversal);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseBuyComment(Type_Reversal);
         }
         else if(i == 1)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseBuyFlag(Type_Trend);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseBuyComment(Type_Trend);
         }
         else if(i == 2)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseBuyFlag(Type_Breakout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseBuyComment(Type_Breakout);
         }
         else if(i == 3)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseBuyFlag(Type_Continuation);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseBuyComment(Type_Continuation);
         }
         else if(i == 4)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseBuyFlag(Type_Fakeout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseBuyComment(Type_Fakeout);
         }
        
         ObjColor = isStopActivate?COMMENT_COLOR:NEUTRAL_COLOR;
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
      }
      
      ////////////////////////////////////////               Open Sell            /////////////////////////////////////////////////////////
      
      
      // Sell Filter 1 ------------------------------
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Filter_1_Sell_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Reversal, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Reversal, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Reversal, Filter_1)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Trend, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Trend, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Trend, Filter_1)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Breakout, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Breakout, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Breakout, Filter_1)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Continuation, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Continuation, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Continuation, Filter_1)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Fakeout, Filter_1, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Fakeout, Filter_1);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Fakeout, Filter_1)?BULL_COLOR:NEUTRAL_COLOR; 
         }
            
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }   
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }
      
      // Sell Filter 2 ------------------------------
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Filter_2_Sell_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Reversal, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Reversal, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Reversal, Filter_2)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Trend, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Trend, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Trend, Filter_2)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Breakout, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Breakout, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Breakout, Filter_2)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Continuation, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Continuation, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Continuation, Filter_2)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Fakeout, Filter_2, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Fakeout, Filter_2);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Fakeout, Filter_2)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }    
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }
      
      // Sell Filter 3 ------------------------------
      lbObj = "N/A";
      ObjColor = NEUTRAL_COLOR;
      tooltip_comment = "";
      Filter_Comment = "";
   
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Filter_3_Sell_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Reversal, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Reversal, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Reversal,Filter_3)?BULL_COLOR:NEUTRAL_COLOR; 
         }
         else if(i == 1)
         {
            // Filter_Comment = "Test";
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Trend, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Trend, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Trend,Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Breakout, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Breakout, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Breakout,Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Continuation, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Continuation, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Continuation,Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Fakeout, Filter_3, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Fakeout, Filter_3);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Fakeout,Filter_3)?BULL_COLOR:NEUTRAL_COLOR;
         }
      
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }    
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }
      
      // Sell Check_Risk_Sell ------------------------------  
      
      for(int i = 0; i < Strategy_Number; i++)
      {
         lbObj = "Check_Risk_Sell_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         Filter_Comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Reversal, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Reversal, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Reversal, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Trend, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Trend, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Trend, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Breakout, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Breakout, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Breakout, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Continuation, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Continuation, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Continuation, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetFilterSellComment(Type_Fakeout, Filter_4, 0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetFilterSellToolTip(Type_Fakeout, Filter_4);
            ObjColor = m_OpenPosition.GetGuanStrategy().GetFilterSellFlag(Type_Fakeout, Filter_4)?BULL_COLOR:NEUTRAL_COLOR;
         }
         
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         }
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
         
      }

      
      // Sell Open Order Comment ------------------------------
      lbObj = "N/A";
      ObjColor = NEUTRAL_COLOR;
      tooltip_comment = "";
      Filter_Comment = "";
   
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Open_Order_Sell_"+(string)i;
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenSellComment(Type_Reversal,0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenSellToolTip(Type_Reversal);
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenSellComment(Type_Trend,0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenSellToolTip(Type_Trend);
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenSellComment(Type_Breakout,0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenSellToolTip(Type_Breakout);
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenSellComment(Type_Continuation,0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenSellToolTip(Type_Continuation);
         }
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetOpenSellComment(Type_Fakeout,0);
            tooltip_comment = m_OpenPosition.GetGuanStrategy().GetOpenSellToolTip(Type_Fakeout);
         }
    
         ObjColor = (Filter_Comment=="N/A"||Filter_Comment=="----")?NEUTRAL_COLOR:COMMENT_COLOR;   
         
         if(StringLen(tooltip_comment) > 256)
         {
            tooltip_comment = StringSubstr(tooltip_comment,0, 256);
         } 
      
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
         ObjectSetString(m_ChartID,lbObj,OBJPROP_TOOLTIP,tooltip_comment);
      }


      // Sell Open Stop Comment ------------------------------
      lbObj = "N/A";
      ObjColor = NEUTRAL_COLOR;
      tooltip_comment = "";
      Filter_Comment = "";

      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Stop_Order_Sell_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         isStopActivate = false;
         
         if(i == 0)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopSellFlag(Type_Reversal);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopSellComment(Type_Reversal);
         }
         else if(i == 1)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopSellFlag(Type_Trend);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopSellComment(Type_Trend);
         }
         else if(i == 2)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopSellFlag(Type_Breakout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopSellComment(Type_Breakout);
         }
         else if(i == 3)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopSellFlag(Type_Continuation);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopSellComment(Type_Continuation);
         }
         else if(i == 4)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetStopSellFlag(Type_Fakeout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetStopSellComment(Type_Fakeout);
         }

      
         ObjColor =isStopActivate?COMMENT_COLOR:NEUTRAL_COLOR;    
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
      }

      // Sell Modify Order Comment ------------------------------
      lbObj = "N/A";
      ObjColor = NEUTRAL_COLOR;
      tooltip_comment = "";
      Filter_Comment = "";
   
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Modify_Sell_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         
         if(i == 0)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifySellComment(Type_Reversal);
         }
         else if(i == 1)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifySellComment(Type_Trend);
         }
         else if(i == 2)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifySellComment(Type_Breakout);
         }
         else if(i == 3)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifySellComment(Type_Continuation);
         }
         else if(i == 4)
         {
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetModifySellComment(Type_Fakeout);
         }

       
         ObjColor = (Filter_Comment=="N/A"||Filter_Comment=="----")?NEUTRAL_COLOR:COMMENT_COLOR;   
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
      }
      
      // Sell Open Close Comment ------------------------------
      lbObj = "N/A";
      ObjColor = NEUTRAL_COLOR;
      tooltip_comment = "";
      Filter_Comment = "";
      
      for(int i = 0;i < Strategy_Number; i++)
      {
         lbObj = "Close_Order_Sell_"+(string)i;
         ObjColor = NEUTRAL_COLOR;
         tooltip_comment = "";
         isStopActivate = false;

         if(i == 0)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseSellFlag(Type_Reversal);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseSellComment(Type_Reversal);
         }
         else if(i == 1)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseSellFlag(Type_Trend);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseSellComment(Type_Trend);
         }
         else if(i == 2)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseSellFlag(Type_Breakout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseSellComment(Type_Breakout);
         }
         else if(i == 3)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseSellFlag(Type_Continuation);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseSellComment(Type_Continuation);
         }
         else if(i == 4)
         {
            isStopActivate = m_OpenPosition.GetGuanStrategy().GetCloseSellFlag(Type_Fakeout);
            Filter_Comment = m_OpenPosition.GetGuanStrategy().GetCloseSellComment(Type_Fakeout);
         }
     
         ObjColor =isStopActivate?COMMENT_COLOR:NEUTRAL_COLOR;    
         LabelTextChange(lbObj,Filter_Comment, DEFAULT_TXT_SIZE, NULL, ObjColor);
      }
   */
   }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnUpdateTradeSubwindow()
  {
   /*
   if(IsTesting() && !IsVisualMode())
      return;
   
   
   if(m_WindowsHash.hGetInt(SUBWINDOW4)<0)
      return;
      
   int windowID = ChartChartWindowFind(m_ChartID, SUBWINDOW4);
   if(windowID<0)
      return;

   
   double spread=MathAbs(Ask-Bid);
 
   // 1st Column
   
   
   LabelTextChange("PricePip", (string) NumberToCurrency(GetPricePerPip(Symbol()), m_AccountManager.GetAccountCurrencyPrefix(), 2));
   

   // 2nd Column 
   
   LabelTextChange("MarketOpen",MarketInfo(Symbol(),MODE_TRADEALLOWED)?"Market Open":"Market Close",DEFAULT_TXT_SIZE, NULL,MarketInfo(Symbol(),MODE_TRADEALLOWED)!=0?BULL_COLOR:BEAR_COLOR); 
   LabelTextChange("Server",TimeToStringCustom(TimeCurrent()),DEFAULT_TXT_SIZE, NULL,MarketInfo(Symbol(),MODE_TRADEALLOWED)!=0?BULL_COLOR:BEAR_COLOR);   
   LabelTextChange("Local",TimeToStringCustom(GetLocalTime()),DEFAULT_TXT_SIZE, NULL,clrSpringGreen);
   
   LabelTextChange("Asia",TimeToStringCustom(GetTokyoTime()),DEFAULT_TXT_SIZE, NULL,IsTokyoMarketOpen()?BULL_COLOR:BEAR_COLOR);
   LabelTextChange("London",TimeToStringCustom(GetLondonDateTime()),DEFAULT_TXT_SIZE, NULL,IsLondonMarketOpen()?BULL_COLOR:BEAR_COLOR);
   LabelTextChange("New York",TimeToStringCustom(GetNewYorkDateTime()),DEFAULT_TXT_SIZE, NULL,IsNewYorkMarketOpen()?BULL_COLOR:BEAR_COLOR);
   
   // 3rd Column  Account Info
   
   
   double accountProfitVal=m_AccountManager.GetAccountProfit();
   string accountProfitPercent = "";
   
   if(accountProfitVal == 0)
      accountProfitPercent = "0";
   else
      accountProfitPercent = DoubleToStr(m_AccountManager.GetAccountProfitPercent(),2)+"% ";

   LabelTextChange("balance",NumberToCurrency(m_AccountManager.GetAccountBalance(), m_AccountManager.GetAccountCurrencyPrefix(), 2));
   LabelTextChange("Equity",NumberToCurrency(m_AccountManager.GetAccountEquity(), m_AccountManager.GetAccountCurrencyPrefix(), 2));
   LabelTextChange("freeMargin",NumberToCurrency(m_AccountManager.GetAccountFreeMargin(), m_AccountManager.GetAccountCurrencyPrefix(),2), 0, NULL,AccountFreeMargin()>=0?BULL_COLOR:BEAR_COLOR);
   LabelTextChange("profit_Currency",NumberToCurrency(m_AccountManager.GetAccountProfit(),m_AccountManager.GetAccountCurrencyPrefix(),2),DEFAULT_TXT_SIZE, NULL,m_AccountManager.GetAccountProfit()>=0?BULL_COLOR:BEAR_COLOR);
   LabelTextChange("profit_Percent",DoubleToString(m_AccountManager.GetAccountProfitPercent(),2)+"%",DEFAULT_TXT_SIZE, NULL,m_AccountManager.GetAccountProfit()>=0?BULL_COLOR:BEAR_COLOR);
   
   LabelTextChange("locked_Profit_Percent", DoubleToString(m_AccountManager.GetAccountLockedProfitInPercent(), 2)+"%",DEFAULT_TXT_SIZE, NULL,m_AccountManager.GetAccountLockedProfitInPercent()>=0?BULL_COLOR:BEAR_COLOR);
   LabelTextChange("locked_Profit_Currency", NumberToCurrency(m_AccountManager.GetAccountLockedProfit(),m_AccountManager.GetAccountCurrencyPrefix(), 2),DEFAULT_TXT_SIZE, NULL,m_AccountManager.GetAccountLockedProfitInPercent()>=0?BULL_COLOR:BEAR_COLOR);
   LabelTextChange("ReqMargin",(string) DoubleToStr(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL),2)+"% ", 0, NULL,AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)< m_AccountManager.GetStopOutLevel()?clrRed:clrSpringGreen);
   LabelTextChange("ATRMultiplier",DoubleToStr(m_Indicators.GetATR().GetATR(0, 0), Digits)+"/"+DoubleToString(ATR_MULTIPLIER, 0), 0, NULL,ATR_MULTIPLIER > 2?clrSpringGreen:clrRed);
   
   LabelTextChange("AvgDailyMovement_Value", DoubleToStr(m_AccountManager.GetAverageDailyPriceMovement(), Digits),DEFAULT_TXT_SIZE, NULL,m_AccountManager.GetAverageDailyPriceMovement()>=CandleSticksBuffer[3][0].GetHLDiff()?BULL_COLOR:BEAR_COLOR);
   LabelTextChange("CurrDailyMovement_Value", DoubleToStr(CandleSticksBuffer[3][0].GetHLDiff(), Digits),DEFAULT_TXT_SIZE, NULL,m_AccountManager.GetAverageDailyPriceMovement()>=CandleSticksBuffer[3][0].GetHLDiff()?BULL_COLOR:BEAR_COLOR);


   // 4th Column
   
   double   NumberOfBuyOrders = NormalizeDouble(m_AccountManager.GetTotalNumberOfOpenBuyOrders(), 0);
   double   NumberOfBuyLots = NormalizeDouble(m_AccountManager.GetTotalBuyLots(), 2);
   double   BuyProfitVal=NormalizeDouble(m_AccountManager.GetTotalOpenBuyOrdersProfit(), 2);
   double   BuyProfitPercent = m_AccountManager.GetAccountBalance() > 0 ? (BuyProfitVal/m_AccountManager.GetAccountBalance()) * 100 : 0;
   double   BuyLockedProfitVal=NormalizeDouble(m_AccountManager.GetTotalOpenBuyOrdersLockedProfit(),2);
   double   BuyLockedProfitPercent= m_AccountManager.GetAccountBalance() > 0 ? (BuyLockedProfitVal/m_AccountManager.GetAccountBalance()) * 100 : 0;
   string   BuyProfitValStr = DoubleToStr(BuyProfitVal, 2);
   string   BuyProfitPercentStr = DoubleToStr(BuyProfitPercent, 2);
   string   BuyLockedProfitValStr = DoubleToStr(BuyLockedProfitVal, 2);
   string   BuyLockedProfitPercentStr = DoubleToStr(BuyLockedProfitPercent, 2);
   
   double   NumberOfSellOrders = NormalizeDouble(m_AccountManager.GetTotalNumberOfOpenSellOrders(), 0);
   double   NumberOfSellLots = NormalizeDouble(m_AccountManager.GetTotalSellLots(), 2);
   double   SellProfitVal=NormalizeDouble(m_AccountManager.GetTotalOpenSellOrdersProfit(), 2);
   double   SellProfitPercent = m_AccountManager.GetAccountBalance() > 0 ? (SellProfitVal/m_AccountManager.GetAccountBalance()) * 100 : 0;
   double   SellLockedProfitVal=NormalizeDouble(m_AccountManager.GetTotalOpenSellOrdersLockedProfit(),2);
   double   SellLockedProfitPercent= m_AccountManager.GetAccountBalance() > 0 ? (SellLockedProfitVal/m_AccountManager.GetAccountBalance()) * 100 : 0;
   string   SellProfitValStr = DoubleToStr(SellProfitVal, 2);
   string   SellProfitPercentStr = DoubleToStr(SellProfitPercent, 2);
   string   SellLockedProfitValStr = DoubleToStr(SellLockedProfitVal, 2);
   string   SellLockedProfitPercentStr = DoubleToStr(SellLockedProfitPercent, 2);
   
   
   
   if(AccountBalance() == 0)
   {
      BuyProfitValStr = "0";
      BuyProfitPercentStr = "0";
      BuyLockedProfitValStr = "0";
      BuyProfitPercentStr = "0";
      
      SellProfitValStr = "0";
      SellProfitPercentStr = "0";
      SellLockedProfitValStr = "0";
      SellProfitPercentStr = "0";
   }   
   
   LabelTextChange("OpenBuyOrders",DoubleToStr(NumberOfBuyOrders, 0),DEFAULT_TXT_SIZE, NULL,NumberOfBuyLots?clrSpringGreen:clrYellow);
   LabelTextChange("OpenBuyLots",DoubleToStr(NumberOfBuyLots, 2),DEFAULT_TXT_SIZE, NULL,NumberOfBuyLots?clrSpringGreen:clrYellow);
   LabelTextChange("OpenBuyProfit_Percent",BuyProfitPercentStr+"%",DEFAULT_TXT_SIZE, NULL,BuyProfitVal>0?clrSpringGreen:BuyProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("OpenBuyProfit_Currency",NumberToCurrency(BuyProfitVal, m_AccountManager.GetAccountCurrencyPrefix(),2),DEFAULT_TXT_SIZE, NULL,BuyProfitVal>0?clrSpringGreen:BuyProfitVal<0?clrOrange:clrYellow);  
   LabelTextChange("OpenBuyLockedProfit_Percent",BuyLockedProfitPercentStr+"%",DEFAULT_TXT_SIZE, NULL,BuyLockedProfitVal>=0?clrSpringGreen:BuyLockedProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("OpenBuyLockedProfit_Currency",NumberToCurrency(BuyLockedProfitVal, m_AccountManager.GetAccountCurrencyPrefix(), 2),DEFAULT_TXT_SIZE, NULL,BuyLockedProfitVal>=0?clrSpringGreen:BuyLockedProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("OpenBuyBreakEven",DoubleToStr(m_AccountManager.GetBuyBEPrice(), Digits),DEFAULT_TXT_SIZE, NULL,BuyProfitVal>=0?clrSpringGreen:BuyProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("BuyAsk",DoubleToString(Ask,Digits));
   LabelTextChange("BuyAskSpread",DoubleToString(spread,Digits));
   
   LabelTextChange("OpenSellOrders",DoubleToStr(NumberOfSellOrders, 0),DEFAULT_TXT_SIZE, NULL,NumberOfSellLots?clrSpringGreen:clrYellow);
   LabelTextChange("OpenSellLots",DoubleToStr(NumberOfSellLots, 2),DEFAULT_TXT_SIZE, NULL,NumberOfSellLots?clrSpringGreen:clrYellow);
   LabelTextChange("OpenSellProfit_Percent",SellProfitPercentStr+"%",DEFAULT_TXT_SIZE, NULL,SellProfitVal>0?clrSpringGreen:SellProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("OpenSellProfit_Currency",NumberToCurrency(SellProfitVal, m_AccountManager.GetAccountCurrencyPrefix(),2),DEFAULT_TXT_SIZE, NULL,SellProfitVal>0?clrSpringGreen:SellProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("OpenSellLockedProfit_Percent",SellLockedProfitPercentStr+"%",DEFAULT_TXT_SIZE, NULL,SellLockedProfitVal>=0?clrSpringGreen:SellLockedProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("OpenSellLockedProfit_Currency",NumberToCurrency(SellLockedProfitVal, m_AccountManager.GetAccountCurrencyPrefix(), 2),DEFAULT_TXT_SIZE, NULL,SellLockedProfitVal>=0?clrSpringGreen:SellLockedProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("OpenSellBreakEven",DoubleToStr(m_AccountManager.GetSellBEPrice(), Digits),DEFAULT_TXT_SIZE, NULL,SellProfitVal>=0?clrSpringGreen:SellProfitVal<0?clrOrange:clrYellow);
   LabelTextChange("SellBid",DoubleToString(Bid,Digits));
   LabelTextChange("SellAskSpread",DoubleToString(spread,Digits));
   */
  }
    
 //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnUpdateFibonacciOnChart(int TimeFrameIndex)
  {
  /*
   if(IsTesting() && !IsVisualMode())
      return;
      
      
   int chartTimeFrameIndex=GetTimeFrameIndex(Period());
  
   

   string timeFrameStr=GetTimeFramesString(TimeFrameIndex);
   ENUM_TIMEFRAMES timeFrameEnum=GetTimeFrameENUM(TimeFrameIndex);
   ENUM_TIMEFRAMES chartTimeFrameEnum=GetTimeFrameENUM(chartTimeFrameIndex);
   Fibonacci *fibo=m_Indicators.GetFibonacci();
   bool isUp=fibo.IsUp(TimeFrameIndex,0);
   color lineColor=isUp?BULL_COLOR:BEAR_COLOR;

   for(int i=0; i<FIBONACCI_LEVELS_SIZE; i++)
   {
      double fiboLevel=fibo.IndexToLevel(i);

      double fiboVal=isUp?fibo.GetUpFibonacci(TimeFrameIndex,0,fiboLevel):fibo.GetDownFibonacci(TimeFrameIndex,0,fiboLevel);
      string lineObjName="FIBO"+timeFrameStr+IntegerToString(i);
      string textObjName="FIBOTXT"+timeFrameStr+IntegerToString(i);
      


      // Turn visibility On and Off
      
      if(SHOW_FIB_ON_CHART[TimeFrameIndex] == false)
      {
         lineColor = clrNONE;
      }


      // Calculate the XY axis from Time/Price to X/Y pixels
      int   X1 =0, Y1=0, window = 0;
      int   X2 = 0, Y2 = 0;
      datetime time_X1, time_X2;
      double   price_X1, price_X2;
      
      if(ChartTimePriceToXY(0,0, (datetime) MarketInfo(Symbol(), MODE_TIME)+PeriodSeconds(), NormalizeDouble(fiboVal, Digits), X1, Y1) == false)
      {
         LogError(__FUNCTION__+", Error Code = ","",GetLastError());
         return;
      }     
      
      int   end_of_screen = (int) ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int   right_side_pixels = end_of_screen - X1;
      int   pixel_fib_columns = (int) (right_side_pixels/4);
   
      X1 = X1 + (pixel_fib_columns*TimeFrameIndex);
      X2 = X1 + pixel_fib_columns-10;
   
      // Limit the pixel so it doesn't go off screen
      if(X2 > end_of_screen)
         X2 = end_of_screen;
   
      ChartXYToTimePrice(0,X1,Y1,window,time_X1,price_X1); 
      ChartXYToTimePrice(0,X2,Y2,window,time_X2,price_X2);
      
          
      
      TextMove(0,textObjName,time_X1,fiboVal);
      
      TextChange(0,textObjName,timeFrameStr+" - "+DoubleToStr(FIBONACCI_LEVELS[i]*100,2)+"%", lineColor);
      ObjectSetString(m_ChartID,textObjName,OBJPROP_TOOLTIP,timeFrameStr+" - "+DoubleToStr(FIBONACCI_LEVELS[i]*100,2)+"% - ("+DoubleToStr(fiboVal,Digits)+")");
      
      
      TrendColorChange(0,lineObjName,lineColor);
      TrendPointChange(0,lineObjName,1,time_X1,fiboVal);
      TrendPointChange(0,lineObjName,0,time_X2,fiboVal);
      ObjectSetString(m_ChartID,lineObjName,OBJPROP_TOOLTIP,timeFrameStr+" - "+DoubleToStr(FIBONACCI_LEVELS[i]*100,2)+"% - ("+DoubleToStr(fiboVal,Digits)+")");
      
   }     
   */
} 
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Graphics::OnUpdateMTFOnChart(int TimeFrameIndex)
  {
   /*
   if(IsTesting() && !IsVisualMode())
      return;

   string timeFrameStr=GetTimeFramesString(TimeFrameIndex);

   Fractal *fractal=m_Indicators.GetFractal();

   color RlineColor = clrNONE;
   color SlineColor = clrNONE;
   double   fractalRVal, fractalSVal;
   fractalRVal = fractal.GetFractalResistancePrice(TimeFrameIndex,0);
   fractalSVal = fractal.GetFractalSupportPrice(TimeFrameIndex,0);


   // Turn visibility On and Off   
   if(SHOW_FRACTAL_ON_CHART[TimeFrameIndex])
   {
      // Resistance Line
      if(CandleSticksBuffer[0][0].GetClose() > fractalRVal)
         RlineColor = BULL_COLOR;
      else if(TimeFrameIndex == 0)
         RlineColor = FRACTAL_M15COLOR;
      else if(TimeFrameIndex == 1)
         RlineColor = FRACTAL_H1COLOR;
      else if(TimeFrameIndex == 2)
         RlineColor = FRACTAL_H4COLOR;
      else if(TimeFrameIndex == 3)
         RlineColor = FRACTAL_D1COLOR;

      // Support Line
      if(CandleSticksBuffer[0][0].GetClose() < fractalSVal)
         SlineColor = BULL_COLOR;
      else if(TimeFrameIndex == 0)
         SlineColor = FRACTAL_M15COLOR;
      else if(TimeFrameIndex == 1)
         SlineColor = FRACTAL_H1COLOR;
      else if(TimeFrameIndex == 2)
         SlineColor = FRACTAL_H4COLOR;
      else if(TimeFrameIndex == 3)
         SlineColor = FRACTAL_D1COLOR;
   }

   
   // MT4 drawing trendlines needs price and time while text label OBJ uses pixels
   // Am trying to recalculate everything into pixels and then back to time/price
   // Now check how many pixels i have on the screen from lastbar to the right of the screen
   
   int   X1 =0, Y1=0, window = 0;
   int   X2 = 0, Y2 = 0;
   datetime time_X1, time_X2;
   double   price_X1, price_X2;
   
   if(ChartTimePriceToXY(0,0, (datetime) MarketInfo(Symbol(), MODE_TIME)+PeriodSeconds(), NormalizeDouble(fractalRVal, Digits), X1, Y1) == false)
   {
      LogError(__FUNCTION__+", Error Code = ","",GetLastError());
      return;
   }     
   
   int   end_of_screen = (int) ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int   right_side_pixels = end_of_screen - X1;
   int   pixel_fib_columns = (int) (right_side_pixels/4);

   X1 = X1 + (pixel_fib_columns*TimeFrameIndex);
   X2 = X1 + pixel_fib_columns-10;

   // Limit the pixel so it doesn't go off screen
   if(X2 > end_of_screen)
      X2 = end_of_screen;


   // Calculate the XY axis from Time/Price to X/Y pixels
   ChartXYToTimePrice(0,X1,Y1,window,time_X1,price_X1); 
   ChartXYToTimePrice(0,X2,Y2,window,time_X2,price_X2);


   // Resistance Text + Line
   TextMove(0,"MTFR_TXT"+timeFrameStr,time_X1,fractalRVal);
   TextChange(0,"MTFR_TXT"+timeFrameStr,timeFrameStr+"-Resist", RlineColor);
   ObjectSetString(m_ChartID,"MTFR_TXT"+timeFrameStr,OBJPROP_TOOLTIP,timeFrameStr+" - "+DoubleToStr(fractalRVal,Digits)+")");

   TrendPointChange(0,"MTFR_LINE"+timeFrameStr,1,time_X1,fractalRVal);
   TrendPointChange(0,"MTFR_LINE"+timeFrameStr,0,time_X2,fractalRVal);
   TrendColorChange(0, "MTFR_LINE"+timeFrameStr, RlineColor);
   ObjectSetString(m_ChartID,"MTFR_LINE"+timeFrameStr,OBJPROP_TOOLTIP,timeFrameStr+" - "+DoubleToStr(fractalRVal,Digits)+")");

   // Support Text + Line
   TextMove(0,"MTFS_TXT"+timeFrameStr,time_X1,fractalSVal);
   TextChange(0,"MTFS_TXT"+timeFrameStr,timeFrameStr+"-Support", SlineColor);
   ObjectSetString(m_ChartID,"MTFS_TXT"+timeFrameStr,OBJPROP_TOOLTIP,timeFrameStr+" - "+DoubleToStr(fractalSVal,Digits)+")");

   TrendPointChange(0,"MTFS_LINE"+timeFrameStr,1,time_X1,fractalSVal);
   TrendPointChange(0,"MTFS_LINE"+timeFrameStr,0,time_X2,fractalSVal);
   TrendColorChange(0, "MTFS_LINE"+timeFrameStr, SlineColor);
   ObjectSetString(m_ChartID,"MTFS_LINE"+timeFrameStr,OBJPROP_TOOLTIP,timeFrameStr+" - "+DoubleToStr(fractalSVal,Digits)+")");
   */
  }
    
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::RemoveSubwindowByName(string ChartName)
  {
   bool res=ChartIndicatorDelete(m_WindowsHash.hGetInt(MAIN_WINDOW),m_WindowsHash.hGetInt(ChartName),ChartName);

   if(ChartWindowFind(0,ChartName)<0)
      m_WindowsHash.hDel(ChartName);
   else
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Graphics::ResizeSubWindow(string ChartName,long YHeight)
  {
   int windowID=m_WindowsHash.hGetInt(ChartName);

   if(YHeight<0 || windowID<0)
     {
      ASSERT("Invalid function input.",__FUNCTION__);
      return false;
     }
     
     

   if(!ChartSetInteger(ChartID(),CHART_HEIGHT_IN_PIXELS,windowID,YHeight))
     {
      LogError(__FUNCTION__+", Height Error Code = ","",GetLastError());
      printf("Height = "+(string) YHeight);
      return false;
     }
   
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Graphics::GetStringXSize(const string str)
  {
   int   width, height;
   
   TextGetSize(str, width, height);
   
   return width;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Graphics::OnUpdateNumberOfIndicatorsOnMainWindow(void)
  {
   
   m_Number_Of_Indicators_On_MainWindow = ChartIndicatorsTotal(0,0);
   return m_Number_Of_Indicators_On_MainWindow;
   
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Graphics::GetIndicatorsNameOnMainWindow(int Shift)
  {
  
   return ChartGetString(Shift,CHART_EXPERT_NAME);
   
  } 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Graphics::GetChartBottomPrice(void)
  {
   
   double res = m_WindowBottomPrice;
   
   return res;
  }   
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Graphics::GetChartTopPrice(void)
  {
   
   double res = m_WindowTopPrice;
   
   return res;
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Graphics::GetChartStartDatetime(void)
  {
   
   datetime res = m_ChartStartDatetime;
   
   return res;
  }   
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime Graphics::GetChartEndDatetime(void)
  {
   
   datetime res = m_ChartEndDatetime;
   
   return res;
  }   
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Graphics::GetChartHeightPixel(int Subwindow)
  {
   
   long res = m_ChartHeightPixel[Subwindow];
   
   return res;
  }   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long Graphics::GetChartWidthPixel(int Subwindow)
  {
   
   long res = m_ChartWidthPixel[Subwindow];
   
   return res;
  }   
 

////////////////////////////////////////        MQL4  STANDRARD FUNCTIONS        //////////////////////////////////////////  

//+------------------------------------------------------------------+
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID,               // chart's ID
                 const string            name,             // label name
                 const int               sub_window,             // subwindow index
                 const int               x,                      // X coordinate
                 const int               y,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner, // chart corner for anchoring
                 const string            text,             // text
                 const string            font,             // font
                 const int               font_size,             // font size
                 const color             clr,               // color
                 const double            angle,                // text slope
                 const ENUM_ANCHOR_POINT anchor, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }


//+------------------------------------------------------------------+ 
//| Creating Text object                                             | 
//+------------------------------------------------------------------+ 
bool TextCreate(const long              chart_ID,               // chart's ID 
                const string            name,              // object name 
                const int               sub_window,             // subwindow index 
                datetime                time,                   // anchor point time 
                double                  price,                  // anchor point price 
                const string            text,              // the text itself 
                const string            font,             // font 
                const int               font_size,             // font size 
                const color             clr,               // color 
                const double            angle,                // text slope 
                const ENUM_ANCHOR_POINT anchor, // anchor type 
                const bool              back=false,               // in the background 
                const bool              selection=false,          // highlight to move 
                const bool              hidden=true,              // hidden in the object list 
                const long              z_order=0)                // priority for mouse click 
  { 
//--- set anchor point coordinates if they are not set 
   ChangeTextEmptyPoint(time,price); 
//--- reset the error value 
   ResetLastError(); 
//--- create Text object 
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Text\" object! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the object by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Move the anchor point                                            | 
//+------------------------------------------------------------------+ 
bool TextMove(const long   chart_ID=0,  // chart's ID 
              const string name="Text", // object name 
              datetime     time=0,      // anchor point time coordinate 
              double       price=0)     // anchor point price coordinate 
  { 
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time) 
      time=TimeCurrent(); 
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,0,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to move the anchor point! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Change the object text                                           | 
//+------------------------------------------------------------------+ 
bool TextChange(const long   chart_ID=0,  // chart's ID 
                const string name="Text", // object name 
                const string text="Text") // text 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- change object text 
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text)) 
     { 
      Print(__FUNCTION__, 
            ": failed to change the text! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Delete Text object                                               | 
//+------------------------------------------------------------------+ 
bool TextDelete(const long   chart_ID=0,  // chart's ID 
                const string name="Text") // object name 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- delete the object 
   if(!ObjectDelete(chart_ID,name)) 
     { 
      Print(__FUNCTION__, 
            ": failed to delete \"Text\" object! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeTextEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
  
//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_left=false,    // line's continuation to the left
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a trend line by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the left
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move trend line anchor point                                     |
//+------------------------------------------------------------------+
bool TrendPointChange(const long   chart_ID=0,       // chart's ID
                      const string name="TrendLine", // line name
                      const int    point_index=0,    // anchor point index
                      datetime     time=0,           // anchor point time coordinate
                      double       price=0)          // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move trend line's anchor point
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
//+------------------------------------------------------------------+
//| The function deletes the trend line from the chart.              |
//+------------------------------------------------------------------+
bool TrendDelete(const long   chart_ID,       // chart's ID
                 const string name) // line name
  {
//--- reset the error value
   ResetLastError();
//--- delete a trend line
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the values of trend line's anchor points and set default   |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one
   if(!price2)
      price2=price1;
  }

//+------------------------------------------------------------------+
//| Create the button                                                |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID,               // chart's ID
                  const string            name,            // button name
                  const int               sub_window,             // subwindow index
                  const int               x,                      // X coordinate
                  const int               y,                      // Y coordinate
                  const int               width,                 // button width
                  const int               height,                // button height
                  const ENUM_BASE_CORNER  corner, // chart corner for anchoring
                  const string            text,            // text
                  const string            font,             // font
                  const int               font_size,             // font size
                  const color             clr,             // text color
                  const color             back_clr,  // background color
                  const color             border_clr,       // border color
                  const bool              state,              // pressed/released
                  const bool              back,               // in the background
                  const bool              selection,          // highlight to move
                  const bool              hidden,              // hidden in the object list
                  const long              z_order)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the button                                                  |
//+------------------------------------------------------------------+
bool ButtonMove(const long   chart_ID,    // chart's ID
                const string name, // button name
                const int    x,           // X coordinate
                const int    y)           // Y coordinate
  {
//--- reset the error value
   ResetLastError();
//--- move the button
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the button! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change button size                                               |
//+------------------------------------------------------------------+
bool ButtonChangeSize(const long   chart_ID,    // chart's ID
                      const string name, // button name
                      const int    width,      // button width
                      const int    height)     // button height
  {
//--- reset the error value
   ResetLastError();
//--- change the button size
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width))
     {
      Print(__FUNCTION__,
            ": failed to change the button width! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height))
     {
      Print(__FUNCTION__,
            ": failed to change the button height! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change corner of the chart for binding the button                |
//+------------------------------------------------------------------+
bool ButtonChangeCorner(const long             chart_ID,               // chart's ID
                        const string           name,            // button name
                        const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) // chart corner for anchoring
  {
//--- reset the error value
   ResetLastError();
//--- change anchor corner
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner))
     {
      Print(__FUNCTION__,
            ": failed to change the anchor corner! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change button text                                               |
//+------------------------------------------------------------------+
bool ButtonTextChange(const long   chart_ID,    // chart's ID
                      const string name, // button name
                      const string text)   // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete the button                                                |
//+------------------------------------------------------------------+
bool ButtonDelete(const long   chart_ID,    // chart's ID
                  const string name) // button name
  {
//--- reset the error value
   ResetLastError();
//--- delete the button
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

