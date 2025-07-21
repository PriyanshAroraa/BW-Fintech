//+------------------------------------------------------------------+
//|                                                Probabilities.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, iPayDNA"
#property link      "http://ipaydna.biz"
#property version   "1.00"
#property strict


////////  Input Variables ////////////
input bool    ALLOW_OPEN_TRADE        = true;
input bool    ALLOW_MODIFY_TRADE      = true;
input bool    ALLOW_CLOSE_TRADE       = true;
input bool    IS_PER_TICK             = true;
input double  TOTAL_RISK              = 2.0;       // Total allowable risk in percent
input double  MAX_RISK_PER_TRADE      = 0.5;       // Max risk per individual trade
input int     MAX_NUMBER_OF_ORDERS    = 5;
input bool    AMPM                    = false;     // false for 24-hour, true for AM/PM format
input string  LOCAL_COUNTRY           = "MY";      // Local country code (e.g., MY for Malaysia)
input int     LOCAL_TZ                = 8;         // Timezone offset from GMT (e.g., GMT+8)
input bool    DO_ANALYSIS             = true;
input string  MARKET_SENTIMENT        = "Neutral"; // Options: Bullish / Neutral / Bearish
input bool    WITH_TELEGRAM           = false;

//////// ENUM Declarations //////////
#define ENUM_TRADE_TYPE_SIZE 4
static const string EnumTradeTypeStrings[]={"Continuation", "Reversal", "Retracement", "NoTrade"};
#define ENUM_QUADRANT_SIZE 4      
static const string EnumQuadrantStrings[]={"Upper", "Lower", "Full", "Unknown"};
#define ENUM_MARKET_CONDITION_SIZE 9
static const string EnumMarketConditionStrings[]={"Bull_Trend_3x", "Bull_Trend_2x", "Bull_Channel", "Bull_Squeeze", "Bear_Squeeze", "Bear_Channel", "Bear_Trend_2x", "Bear_Trend_3x","UnknownMarketCondition"};
#define ENUM_MARKET_BIAS_SIZE 5
static const string EnumMarketBiasStrings[]={"StrongBull", "WeakBull", "StrongBear", "WeakBear", "Uncertainty"};
#define ENUM_PRICE_POSITION_SIZE 4
static const string EnumPricePositionString[]={"BelowSupport","BetweenSupportResist","AboveResist","UnknownPosition"};
#define ENUM_INDICATOR_POSITION_SIZE 8
static const string EnumIndicatorPositionString[]={"3xStdDev+", "2xStdDev+", "Above Mean", "Equal Mean", "Below Mean", "2xStdDev-", "3xStdDev-", "Null"};
static const int EnumMonthArray[]={1,2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
static const string EnumMonthString[]={"","Jan","Feb","Mar","Apr","May", "June", "July", "Aug", "Sept", "Oct", "Nov", "Dec"};

#define ENUM_ORDER_TYPE_ARRAY_SIZE 6
static const int EnumOrderTypeArray[]={ORDER_TYPE_BUY,ORDER_TYPE_SELL,ORDER_TYPE_BUY_LIMIT,ORDER_TYPE_SELL_LIMIT,ORDER_TYPE_BUY_STOP,ORDER_TYPE_SELL_STOP,ORDER_TYPE_BUY_STOP_LIMIT,ORDER_TYPE_SELL_STOP_LIMIT};
static const string EnumOrderTypeArrayStrings[]={"NAOrderType","Buy","Sell","Buy Limit","Sell Limit","Buy Stop","Sell Stop"};

//////// Order Variables //////////
bool     CloseAllBuyOrders, CloseAllSellOrders;


//////// Order Variables //////////

#define MAX_RETRIES 99        // to open orders and modify orders
#define OP_CLOSE_ALL 6        // New Variable to Close All orders


bool     isNewBar[6] = {false,false,false,false,false,false};

#define  Shift_Look_Back            10
#define  ANALYZE_LOOKBACK           5

//////   Advance Indicator Variables /////////////////

#define  TOTAL_VOLATILITY_INDEX 27
#define  TOTAL_OBOS_INDEX 12
#define  TOTAL_INDICATOR_TRIGGER 8
#define  TOTAL_MARKET_MOMENTUM_INDEX 8
#define  TOTAL_DIVERGENCE_INDEX 9

//////   Filter Varaibles /////////////////

#define  Strategy_Number         5

// Filter Type
#define  Type_Reversal           0
#define  Type_Trend              1
#define  Type_Breakout           2
#define  Type_Continuation       3
#define  Type_Fakeout            4

// Filter Number
#define  Filter_1                0
#define  Filter_2                1
#define  Filter_3                2
#define  Filter_4                3

#define  Filter_Numbers          4


#define  Filter_Nodes            20    // 30 Nodes per filter (Trigger/Co > 20 nodes)
#define  Node_1                  1
#define  Node_2                  2
#define  Node_3                  3
#define  Node_4                  4
#define  Node_5                  5
#define  Node_6                  6
#define  Node_7                  7
#define  Node_8                  8
#define  Node_9                  9
#define  Node_10                 10
#define  Node_11                 11
#define  Node_12                 12
#define  Node_13                 13
#define  Node_14                 14
#define  Node_15                 15
#define  Node_16                 16
#define  Node_17                 17
#define  Node_18                 18
#define  Node_19                 19
#define  Node_20                 20



///////  Marketing timezone ///////////////

static int LONDON_TZ= 1;
static int TOKYO_TZ = 9;
static int NEWYORK_TZ=-4;
static int SYDNEY_TZ=11;

static int NY_OPEN_HOUR=8;                // 8 am
static int NY_CLOSE_HOUR=17;              // 5 pm  
static int LONDON_OPEN_HOUR=7;            // 7 am
static int LONDON_CLOSE_HOUR=16;          // 4 pm  
static int TOKYO_OPEN_HOUR=8;             // 8 am
static int TOKYO_CLOSE_HOUR=17;           // 5 pm 
static int SYDNEY_OPEN_HOUR=7;             // 7 am
static int SYDNEY_CLOSE_HOUR=16;           // 4 pm  

int        LONDON_DAYLIGHT_SAVING = 0;
int        NY_DAYLIGHT_SAVING = 0;


//////// Cuurrency Pair Limitation //////////
static int XAUUSD_MINIMUM_STOP_LOSS_PIP = 30;
static int XAUUSD_MAXIMUM_STOP_LOSS_PIP = 70;

static int EURUSD_MINIMUM_STOP_LOSS_PIP = 20;
static int EURUSD_MAXIMUM_STOP_LOSS_PIP = 70;

static int KELLY_ARRAY_SIZE = 20;


//////// Windows //////////

#define APPNAME     "TrendDNA"
#define MAIN_WINDOW "MainWindow"

#define SUBWINDOW1 "iForexDNA Window 1"
#define SUBWINDOW2 "iForexDNA Window 2"
#define SUBWINDOW3 "iForexDNA Window 3"
#define SUBWINDOW4 "iForexDNA Trade Window"
#define Y_DISTANCE_BUFFER  12

//////// TimeFrame Variables //////////
#define ENUM_TIMEFRAMES_ARRAY_SIZE 6
static const ENUM_TIMEFRAMES EnumTimeFramesArray[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_H1,PERIOD_H4,PERIOD_D1};
static const string EnumTimeFramesStrings[]={"NATimeFrame","M1","M5","M15","H1","H4","D1"};




//////// Graphics //////////

#define  STANDARD_DPI 96
int      WINDOW_MAX_CHAR_WIDTH = 180;
double   ASPECT_RATIO=0.8;
#define  DEFAULT_TXT_FONT "Arial"
int      DEFAULT_TXT_SIZE=6;


// Simple Market Identifying Terms

#define  BULL_TRIGGER            1
#define  BEAR_TRIGGER            -1
#define  HIGH_VOLATILITY         1
#define  LOW_VOLATILITY          -1
#define  BULL_DIVERGENCE         1
#define  BEAR_DIVERGENCE         -1
#define  NEUTRAL                 0


#define  VERY_TIGHT_STOP_LOSS_MULTIPLIER                    0.5
#define  TIGHT_STOP_LOSS_MULTIPLIER                         1.0
#define  MEDIUM_STOP_LOSS_MULTIPLIER                        1.5
#define  LOOSE_STOP_LOSS_MULTIPLIER                         2.0
#define  VERY_LOOSE_STOP_LOSS_MULTIPLIER                    2.5
#define  EXTREME_LOOSE_STOP_LOSS_MULTIPLIER                 5.0

bool TRADE_GUAN_REVERSAL_STRATEGY            =              false;
bool TRADE_GUAN_BREAKOUT_STRATEGY            =              false;
bool TRADE_GUAN_CON_STRATEGY                 =              true;
bool TRADE_GUAN_TREND_STRATEGY               =              true;
bool TRADE_GUAN_FAKEOUT_STRATEGY             =              false;

#define GUAN_REVERSAL_BUY_STRATEGY                           200
#define GUAN_REVERSAL_SELL_STRATEGY                          -200

#define GUAN_TRENDING_BUY_STRATEGY                           210
#define GUAN_TRENDING_SELL_STRATEGY                          -210

#define GUAN_CONTINUATION_BUY_STRATEGY                       220
#define GUAN_CONTINUATION_SELL_STRATEGY                      -220

#define GUAN_BREAKOUT_BUY_STRATEGY                           230
#define GUAN_BREAKOUT_SELL_STRATEGY                          -230

#define GUAN_FAKEOUT_BUY_STRATEGY                            240
#define GUAN_FAKEOUT_SELL_STRATEGY                           -240

// D1 Strategy (3001 - 4000)





// GRAPHICS UTILS
#define  DEFAULT_TXT_COLOR       clrGray
#define  TREND_COLOR             clrSkyBlue
#define  BULL_CHANNELING_COLOR   clrLightGreen
#define  BEAR_CHANNELING_COLOR   clrBurlyWood
#define  CHANNEL_COLOR           clrTurquoise
#define  SQUEEZE_COLOR           clrYellow
#define  CROSOVER_COLOR          clrOrchid
#define  BULL_COLOR              clrSpringGreen
#define  BEAR_COLOR              clrOrange
#define  NEUTRAL_COLOR           clrYellow
#define  REVERSAL_COLOR          clrMediumOrchid
#define  EXTREME_COLOR           clrRed
#define  COMMENT_COLOR           clrViolet

#define  TRUE_COLOR              clrSpringGreen
#define  FALSE_COLOR             clrYellow

#define  BULL_DIVERGENCE_COLOR         clrSpringGreen
#define  BEAR_DIVERGENCE_COLOR         clrOrange
#define  HIDDEN_BULL_DIVERGENCE_COLOR  clrPaleGreen
#define  HIDDEN_BEAR_DIVERGENCE_COLOR  clrTan
#define  BULL_CONVERGENCE_COLOR        clrLimeGreen
#define  BEAR_CONVERGENCE_COLOR        clrDarkOrange


#define  ENUM_FONT_SIZE    DEFAULT_TXT_SIZE

#define  INDICATOR_MAX_ON_MAIN_WINDOW  10
// Button Color 

#define  BUTTON_ON         clrGreenYellow
#define  BUTTON_OFF        clrRed


int      PPI;              // Pixel Per Inch

//////// Global Applied Price and MA_Mode used //////////

ENUM_APPLIED_PRICE   APPLIED_PRICE = PRICE_CLOSE;
#define APPLIED_PRICE_METHOD     MODE_EMA
#define APPLIED_MA_METHOD        MODE_EMA


// EA Stoploss Variables
#define  ATR_MULTIPLIER 2

// pip
double Trailing_PIP = 0;
bool  TRAILINGPIP_ENABLE = false;


// ATR
double Trailing_ATR = 0;
bool  TRAILINGATR_ENABLE = false;


//////// Buffer Sizes //////////

#define  DEFAULT_BUFFER_SIZE 40
#define  DEFAULT_INDICATOR_PERIOD 14
#define  ADVANCE_INDICATOR_PERIOD 20

#define  PROBABILITY_INDEX_BUFFER_SIZE 10

#define  INDEXES_BUFFER_SIZE           20
#define  MARKET_CONDITION_BUFFER_SIZE  20
#define  MAX_TRIGGER                   6             

#define  DEFAULT_SHIFT 0

#define  ZIGZAG_BUFFER_SIZE 20
#define  FRACTAL_BUFFER_SIZE   20     
#define  CANDLESTICKS_BUFFER_SIZE 20


//////// MODES   GENERIC  //////////
#define  MODE_MAIN               0
#define  MODE_SIGNAL             1

//////// MODES   ADX  //////////
#define  MODE_PLUSDI             1
#define  MODE_MINUSDI            2

//////// MODES   Band  //////////
#define  MODE_UPPER              1
#define  MODE_LOWER              2


//////// MODES  Ichimoku  //////////
#define  TENKANSEN_LINE          0
#define  KIJUNSEN_LINE           1
#define  SENKOUSPANA_LINE        2
#define  SENKOUSPANB_LINE        3
#define  CHIKOUSPAN_LINE         4

//////// MODES   Support & Resistance  //////////
#define  MODE_RESISTANCE         0
#define  MODE_SUPPORT            1

//////// Ichimoku //////////
#define  ICHIMOKU_NEGATIVE_SHIFT -26
#define  ICHIMOKU_SPAN_BUFFER_SIZE 52      // shift 0 = Bar -25,  shift 25 = Bar 0
#define  ICHIMOKU_TENKANSEN 9
#define  ICHIMOKU_KIJUNSEN 26 
#define  ICHIMOKU_SENKOU_SPAN 52 

//////// ADX //////////
int ADX_PERIOD=14;

//////// ATR //////////
int ATR_PERIOD=14;

//////// Momentum //////////
int MOMENTUM_PERIOD=14;

//////// MA //////////
int MA_FAST_PERIOD=5;
int MA_MEDIUM_PERIOD=20;
int MA_SLOW_PERIOD=50;
int MA_MONEY_LINE_PERIOD=200;



//////// CCI //////////
int                    CCI_PERIOD = 14;
ENUM_APPLIED_PRICE     CCI_APPLIED_PRICE = PRICE_TYPICAL;


//////// BullBear Power  //////////
int     BULL_BEAR_POWER_PERIOD = 14;


//////// RVI  //////////
int     RVI_PERIOD = 14;


//////// Force  //////////
int     FORCE_PERIOD = 14;


//////// Bollinger Band //////////
int BANDS_PERIOD=20;
int BANDS_DEVIATION=2; 
#define  BANDS_MA_PERIOD 20
#define  BANDS_DEVIATION_SIZE 5


//////// Keltner  //////////
int      KELTNER_PERIOD = 20;
int      KELTNER_ATR_PERIOD = 14;
#define  KELTNER_MULTIPLIER 2
#define  KELTNER_MA_PERIOD 20
#define  KELTNER_MA_METHOD MODE_EMA

//////// PSAR //////////

int      SAR_SHIFT=0;
double   SAR_STEP=0.02;
double   SAR_MAXIMUM=0.2;

//////// Zigzag //////////

int      ZIGZAG_DEPTH=12;
int      ZIGZAG_DEVIATION=5;
int      ZIGZAG_BACKSTEP=3;


//////// MACD //////////
int MACD_FAST_PERIOD=12;
int MACD_SLOW_PERIOD=26;
int MACD_SIGNAL_PERIOD=9;


//////// STOCHASTICS //////////

int STO_KPERIOD=5;
int STO_DPERIOD=3;
int STO_SLOWING=3;
ENUM_STO_PRICE STO_PRICE_FIELD=STO_LOWHIGH;
#define STO_UPPER_THRESHOLD 80 
#define STO_LOWER_THRESHOLD 20 

//////// RSI //////////
int RSI_PERIOD=14;   

#define  RSI_UPPER_THRESHOLD 70
#define  RSI_LOWER_THRESHOLD 30

//////// Fibronassi //////////
#define FIBONACCI_LEVELS_SIZE 10
#define FIBOACCI_PRICE_LEVELS_SIZE 3
static double FIBONACCI_LEVELS[FIBONACCI_LEVELS_SIZE]={0.0,0.236,0.382,0.50,0.618,0.764,1.0,1.618,2.618,4.236};
bool  SHOW_FIB_ON_CHART[4] = {true, true, true, true}; bool  SHOW_FIB_ALL = true;



//////// Pivot //////////
#define PIVOT_LEVELS_SIZE 3
#define FRACTAL_M15COLOR clrYellow
#define FRACTAL_H1COLOR clrMagenta
#define FRACTAL_H4COLOR clrAqua
#define FRACTAL_D1COLOR clrRed
bool  SHOW_FRACTAL_ON_CHART[4] = {true, true, true, true};bool  SHOW_FRACTAL_ALL = true;

//////// MFI //////////
#define  MFI_PERIOD 14

#define  MFI_UPPER_THRESHOLD 80
#define  MFI_LOWER_THRESHOLD 20


//////// CandleStick //////////
#define CANDLESTICK_SHIFT 0
#define CANDLESTICK_PERIOD 14
#define CANDLESTICK_CUMMULATIVE_COUNT 3


// STRATEGY TESTER USAGE 
string ZIGZAG_FILENAME[4] = {"EURUSD-M15-ZZ.csv", "EURUSD-H1-ZZ.csv", "EURUSD-H4-ZZ.csv", "EURUSD-D1-ZZ.csv"};

// Telegram Informations
string  XAUUSD_TELEGRAM_BOT_TOKEN = "7336253788:AAFGSCNBEFWT89KMOg_Z7J8QDcrIyNWgLNg";
string  XAUUSD_CHAT_ID = "-1002312102020";

string  EURUSD_TELEGRAM_BOT_TOKEN = "7368251003:AAFQRoqC1X7YlNfOXxlO5OvdNsREWPNefP0";
string  EURUSD_CHAT_ID = "-1002192607148";

int  ZoneExpiryHours = 3;
int  TimeToleranceMinutes = 45;