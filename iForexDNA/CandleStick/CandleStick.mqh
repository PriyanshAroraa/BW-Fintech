//+------------------------------------------------------------------+
//|                                                  CandleStick.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"

#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict

static const string EnumTrendStrings[]={"NATrend","Bullish ","Neutral","Bearish"};   // Trend Variation
static const string EnumPatternStrings[]=
  {
   "NAPattern","SpinningTops","WhiteMarubozu","BlackMarubozu","Doji","LongLeggedDoji","DragonflyDoji","GravestoneDoji",
   "FourPriceDoji","Hammer","HangingMan","InvertedHammer","ShootingStar"
  };


enum ENUM_CANDLESTICKTREND
    {
        NATrend,
        Bullish,
        Neutral,
        Bearish,
    };


enum ENUM_CANDLESTICKPATTERN
    {
      NAPattern,
      SpinningTops,
      WhiteMarubozu,
      BlackMarubozu,
      Doji,
      LongLeggedDoji,
      DragonflyDoji,
      GravestoneDoji,
      FourPriceDoji,
      Hammer,
      HangingMan,
      InvertedHammer,
      ShootingStar,
    };


class CandleStick{     
    private:
        datetime          m_OpenDateTime;

        double            m_Open;
        double            m_Close;
        double            m_High;
        double            m_Low;
        double            m_HLC3;
        double            m_OHLC4;
        long              m_Volume;

        ENUM_TIMEFRAMES             m_TimeFrame;
        ENUM_CANDLESTICKTREND       m_Trend;
        ENUM_CANDLESTICKPATTERN     m_Pattern;
        
        
    public:
        CandleStick();
        CandleStick(datetime DateTime,double OpenVal,double CloseVal,double HighVal,double LowVal,ENUM_TIMEFRAMES TimeFrame);
        CandleStick(ENUM_TIMEFRAMES TimeFrame,int Shift=0);
        ~CandleStick();

        bool               SetPrice(double OpenVal,double CloseVal,double HighVal,double LowVal)
                           {
                              m_Open = OpenVal;
                              m_Close = CloseVal;
                              m_High = HighVal;
                              m_Low = LowVal;
                              
                              return true;
                           }

        datetime           GetOpenDateTime();
        datetime           GetCloseDateTime();
        double             GetOpen(int FloatingPoint=-1);
        double             GetClose(int FloatingPoint=-1);
        double             GetHigh(int FloatingPoint=-1);
        double             GetLow(int FloatingPoint=-1);
        double             GetHLC3(int FloatingPoint=-1);
        double             GetOHLC4(int FloatingPoint=-1);
        long               GetVolume();

        double             GetHLDiff(int FloatingPoint=-1);
        double             GetRealBody(int FloatingPoint=-1);
        double             GetRealBodyAbs(int FloatingPoint=-1);
        double             GetTopShadow(int FloatingPoint=-1);
        double             GetBottomShadow(int FloatingPoint=-1);

        double             GetRealBodyPercentage(int FloatingPoint=-1);
        double             GetTopShadowPercentage(int FloatingPoint=-1);
        double             GetBottomShadowPercentage(int FloatingPoint=-1);

        ENUM_TIMEFRAMES    GetTimeFrame();
        ENUM_CANDLESTICKTREND GetTrend();
        ENUM_CANDLESTICKPATTERN GetPattern();

        string             GetDateTimeString(int Mode=TIME_DATE|TIME_MINUTES);
        string             GetTimeFrameString();
        string             GetTrendString();
        string             GetPatternString()
                           {
                              ENUM_CANDLESTICKPATTERN SinglePattern = CalculatePattern();
                              return   EnumPatternStrings[SinglePattern];
                           };
   
        void               OnUpdate(int Shift);
        
        
        ENUM_CANDLESTICKTREND    CalculateTrend();
        ENUM_CANDLESTICKPATTERN  CalculatePattern();
        void                     AnalysisCandleStick();

    private:
    
        bool isSpinningTops();
        bool isWhiteMarubozu();
        bool isBlackMarubozu();
        bool isDoji();
        bool isLongLeggedDoji();
        bool isDragonflyDoji();
        bool isGravestoneDoji();
        bool isFourPriceDoji();
        bool isHammer();
        bool isHangingMan();
        bool isInvertedHammer();
        bool isShootingStar();
   
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CandleStick::CandleStick()
  {
  }

//+------------------------------------------------------------------+
//|                           Constructor                            |
//+------------------------------------------------------------------+

CandleStick::CandleStick(datetime DateTime,double OpenVal,double CloseVal,double HighVal,double LowVal,ENUM_TIMEFRAMES TimeFrame)
   : m_OpenDateTime(DateTime),
     m_Open(Normalize(OpenVal)),m_Close(Normalize(CloseVal)),
     m_High(Normalize(HighVal)),m_Low(Normalize(LowVal)),
     m_Trend(NATrend),m_Pattern(NAPattern),m_TimeFrame(TimeFrame)
  {
   ASSERT("CandleStick::CandleStick(double OpenVal,double CloseVal,double HighVal,double LowVal, TimeFrames TimeFrame) IS USED",__FUNCTION__);
   AnalysisCandleStick();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CandleStick::CandleStick(ENUM_TIMEFRAMES TimeFrame, int Shift = 0) : m_Trend(NATrend),m_Pattern(NAPattern){
  ASSERT_IF(Shift<0,"Invalid Shift value",__FUNCTION__);

  m_OpenDateTime=iTime(Symbol(),TimeFrame,Shift);
  m_Open=Normalize(iOpen(Symbol(),TimeFrame,Shift));
  m_Close= Normalize(iClose(Symbol(),TimeFrame,Shift));
  m_High = Normalize(iHigh(Symbol(),TimeFrame,Shift));
  m_Low=Normalize(iLow(Symbol(),TimeFrame,Shift));
  m_TimeFrame=TimeFrame;

  AnalysisCandleStick();


}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CandleStick::~CandleStick()
  {
  }

//+------------------------------------------------------------------+
//|                         Open Time                                |
//+------------------------------------------------------------------+

datetime CandleStick::GetOpenDateTime()
  {
   return m_OpenDateTime;
  }

//+------------------------------------------------------------------+
//|                         Close Time                               |
//+------------------------------------------------------------------+

datetime CandleStick::GetCloseDateTime()
  {
   return m_OpenDateTime+((m_TimeFrame-1)*60);
  }

//+------------------------------------------------------------------+
//|                         Open Price                               |
//+------------------------------------------------------------------+

double CandleStick::GetOpen(int FloatingPoint=-1)
  {
   return Normalize(m_Open,FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                         Close Price                              |
//+------------------------------------------------------------------+

double CandleStick::GetClose(int FloatingPoint=-1)
  {
   return Normalize(m_Close,FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                        High Price                                |
//+------------------------------------------------------------------+

double CandleStick::GetHigh(int FloatingPoint=-1)
  {
   return Normalize(m_High,FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                       Low Price                                  |
//+------------------------------------------------------------------+

double CandleStick::GetLow(int FloatingPoint=-1)
  {
   return Normalize(m_Low,FloatingPoint);
  }
//+------------------------------------------------------------------+
//|                       Low Price                                  |
//+------------------------------------------------------------------+

double CandleStick::GetHLC3(int FloatingPoint=-1)
  {
   return Normalize(m_HLC3,FloatingPoint);
  }
//+------------------------------------------------------------------+
//|                       Low Price                                  |
//+------------------------------------------------------------------+

double CandleStick::GetOHLC4(int FloatingPoint=-1)
  {
   return Normalize(m_OHLC4,FloatingPoint);
  }
//+------------------------------------------------------------------+
//|                      High/Low Difference                         |
//+------------------------------------------------------------------+

double CandleStick::GetHLDiff(int FloatingPoint=-1)
  {
   return Normalize(GetHigh(FloatingPoint)-GetLow(FloatingPoint),FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                           Get Volume                             |
//+------------------------------------------------------------------+

long CandleStick::GetVolume(){
  return m_Volume;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandleStick::GetRealBody(int FloatingPoint=-1)
  {
   return Normalize(GetClose(FloatingPoint)-GetOpen(FloatingPoint), FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                   Real Body abs value                            |
//+------------------------------------------------------------------+

double CandleStick::GetRealBodyAbs(int FloatingPoint=-1)
  {
   return MathAbs(GetRealBody(FloatingPoint));
  }

//+------------------------------------------------------------------+
//|                      Top Wick                                    |
//+------------------------------------------------------------------+

double CandleStick::GetTopShadow(int FloatingPoint=-1)
  {
   double topShadow;

   if(m_Close>m_Open)
      topShadow=GetHigh(FloatingPoint)-GetClose(FloatingPoint);
   else
      topShadow=GetHigh(FloatingPoint)-GetOpen(FloatingPoint);

   return Normalize(topShadow,FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                     Bottom Wick                                  |
//+------------------------------------------------------------------+

double CandleStick::GetBottomShadow(int FloatingPoint=-1)
  {
   double bottomShadow;

   if(m_Close>m_Open)
      bottomShadow=GetOpen(FloatingPoint)-GetLow(FloatingPoint);
   else
      bottomShadow=GetClose(FloatingPoint)-GetLow(FloatingPoint);

   return Normalize(bottomShadow,FloatingPoint);
  }

//+------------------------------------------------------------------+
//|            Real Body percentage/ bull bear percentage            |
//+------------------------------------------------------------------+

double CandleStick::GetRealBodyPercentage(int FloatingPoint=-1)
  {
   return GetHLDiff(FloatingPoint)==0 ? 0 : (GetRealBodyAbs(FloatingPoint)*100)/GetHLDiff(FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                      Top Wick Percentage                         |
//+------------------------------------------------------------------+

double CandleStick::GetTopShadowPercentage(int FloatingPoint=-1)
  {
   return GetHLDiff(FloatingPoint)==0 ? 0 : (GetTopShadow(FloatingPoint)*100)/GetHLDiff(FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                     Bottom Wick Percentage                       |
//+------------------------------------------------------------------+

double CandleStick::GetBottomShadowPercentage(int FloatingPoint=-1)
  {
   return GetHLDiff(FloatingPoint)==0 ? 0 : (GetBottomShadow(FloatingPoint)*100)/GetHLDiff(FloatingPoint);
  }

//+------------------------------------------------------------------+
//|                    TimeFrame                                     |
//+------------------------------------------------------------------+

ENUM_TIMEFRAMES CandleStick::GetTimeFrame()
  {
   return m_TimeFrame;
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string CandleStick::GetDateTimeString(int Mode=TIME_DATE|TIME_MINUTES)
  {
   return TimeToString(m_OpenDateTime, Mode);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string CandleStick::GetTimeFrameString()
  {
   return GetTimeFramesString(m_TimeFrame);
  }
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CandleStick::GetTrendString()
  {
   ASSERT_IF(m_Trend<0 || m_Trend>=ArraySize(EnumTrendStrings),"m_Trend < 0 || m_Trend >= ArraySize(EnumTrendStrings)",__FUNCTION__);
   return EnumTrendStrings[m_Trend];
  }

//+------------------------------------------------------------------+
//|                           Patterns                               |
//+------------------------------------------------------------------+

bool CandleStick::isSpinningTops(){
  if(GetRealBodyPercentage() <= 33 && GetBottomShadowPercentage() >= 25 && GetTopShadowPercentage() >= 25){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isWhiteMarubozu(){
  if(GetRealBodyPercentage() >= 80 && GetTrend() == Bullish){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isBlackMarubozu(){
  if(GetRealBodyPercentage() >= 80 && GetTrend() == Bearish){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                          Doji                                    |
//+------------------------------------------------------------------+

bool CandleStick::isDoji(){
  if(GetRealBodyPercentage() <= 5 && !isLongLeggedDoji() && !isGravestoneDoji() && !isDragonflyDoji() && !isFourPriceDoji()){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isDragonflyDoji(){
  if(GetRealBodyPercentage() <= 5 && GetTopShadowPercentage() <= 20){
    return true;
  }

  return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isLongLeggedDoji(){
  if(GetRealBodyPercentage() <= 5 && GetBottomShadowPercentage() >= 40 && GetTopShadowPercentage() >= 40){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isGravestoneDoji(){
  if(GetRealBodyPercentage() <= 5 && GetBottomShadowPercentage() <= 20){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isFourPriceDoji(){
  if(GetHLDiff() <= _Point){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isHammer(){
  if(GetRealBodyPercentage()*2.5 < GetBottomShadowPercentage() && GetTopShadowPercentage()<=10 && GetTrend() == Bullish){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isHangingMan(){
  if(GetRealBodyPercentage()*2.5 < GetBottomShadowPercentage() && GetTopShadowPercentage()<=10 && GetTrend() == Bearish){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isInvertedHammer(){
  if(GetRealBodyPercentage()*2.5 < GetTopShadowPercentage() && GetBottomShadowPercentage()<=10 && m_Trend==Bullish){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandleStick::isShootingStar(){
  if(GetRealBodyPercentage()*2.5 < GetTopShadowPercentage() && GetBottomShadowPercentage()<=10 && m_Trend==Bearish){
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                    CandleStick Trend Getter                      |
//+------------------------------------------------------------------+

ENUM_CANDLESTICKTREND CandleStick::GetTrend()
  {
   return m_Trend;
  }

//+------------------------------------------------------------------+
//|                    CandleStick Trend Setter                      |
//+------------------------------------------------------------------+

ENUM_CANDLESTICKTREND  CandleStick::CalculateTrend()
  {
   if(m_Close > m_Open && GetRealBodyPercentage() > 5)
      return Bullish;
   else if(m_Close < m_Open && GetRealBodyPercentage() > 5)
      return Bearish;

   return Neutral;
  }

//+------------------------------------------------------------------+
//|                    CandleStick Pattern Getter                    |
//+------------------------------------------------------------------+

ENUM_CANDLESTICKPATTERN CandleStick::GetPattern()
  {
   return m_Pattern;
  }

//+------------------------------------------------------------------+
//|                    CandleStick Pattern Setter                    |
//+------------------------------------------------------------------+

ENUM_CANDLESTICKPATTERN CandleStick::CalculatePattern(){

  ASSERT_IF(!m_Open || !m_Close || !m_High || !m_Low,"CandleStick Data is not Init: TimeFrame: "+GetTimeFrameString(),__FUNCTION__);
  ASSERT_IF(m_Trend==NATrend,"CandleStick Trend is NA",__FUNCTION__);
  
    // doji check
  if(isDoji()){
    return Doji;
  }

  // long-legged check
  else if(isLongLeggedDoji()){
    return LongLeggedDoji;
  }

  // dragon fly doji check
  else if(isDragonflyDoji()){
    return DragonflyDoji;
  }

  // gravestone doji check
  else if(isGravestoneDoji()){
    return GravestoneDoji;
  }

  // four price doji check
  else if(isFourPriceDoji()){
    return FourPriceDoji;
  }

  // white marubozu check
  else if(isWhiteMarubozu()){
    return WhiteMarubozu;
  }

  // black marubozu check
  else if(isBlackMarubozu()){
    return BlackMarubozu;
  }

  // hammer check
  else if(isHammer()){
    return Hammer;
  }

  // hanging man check
  else if(isHangingMan()){
    return HangingMan;
  }

  // inverted hammer check
  else if(isInvertedHammer()){
    return InvertedHammer;
  }

  // inverted hammer check
  else if(isShootingStar()){
    return ShootingStar;
  }
  
  // spinning top check
  else if(isSpinningTops()){
    return SpinningTops;
  }

  return NAPattern;
  
 }

//+------------------------------------------------------------------+
//|                    Update CandleStick                            |
//+------------------------------------------------------------------+

void CandleStick::AnalysisCandleStick()
  {
   ASSERT_IF(!m_Open || !m_Close || !m_High || !m_Low,"CandleStick Data is not Init",__FUNCTION__);

   m_Trend=CalculateTrend();
   m_Pattern=CalculatePattern();
  }

//+------------------------------------------------------------------+

    // needed when shift 0 is included

void CandleStick::OnUpdate(int Shift)
  {
   m_Close=Normalize(iClose(Symbol(),m_TimeFrame,Shift));
   m_High=Normalize(iHigh(Symbol(),m_TimeFrame,Shift));
   m_Low=Normalize(iLow(Symbol(),m_TimeFrame,Shift));
   m_Volume=iVolume(Symbol(), m_TimeFrame,Shift);
   m_HLC3=Normalize((m_Close+m_High+m_Low)/3);
   m_OHLC4=Normalize((m_Close+m_High+m_Low+m_Open)/4);
   AnalysisCandleStick();
  }

//+------------------------------------------------------------------+
//|                             End                                  |
//+------------------------------------------------------------------+