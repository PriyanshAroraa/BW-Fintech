//+------------------------------------------------------------------+
//|                                                  DualPattern.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#include "..\CandleStick\CandleStick.mqh"
#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"

#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "http://www.mql4.com"
#property version   "1.00"
#property strict

static const string EnumDualPatternStrings[]=
  {
   "NADualPattern","BullishEngulfing","BearishEngulfing","TweezerTops","TweezerBottoms","BullishPiercingLine",
   "BearishPiercingLine","BullishKicking","BearishKicking","BullishHarami","BearishHarami", "BullishWindow", "BearishWindow", "BullishMeeting", "BearishMeeting", "MatchingHigh", "MatchingLow",
   "BullishSeperate", "BearishSeperate"
  };

enum ENUM_DUALCANDLESTICKPATTERN
{
   NADualPattern,
   BullishEngulfing,
   BearishEngulfing,
   TweezerTops,
   TweezerBottoms,
   BullishPiercingLine,
   BearishPiercingLine,
   BullishKicking,
   BearishKicking,
   BullishHarami,
   BearishHarami,
   BullishWindow,
   BearishWindow,
   BullishMeeting,
   BearishMeeting,
   MatchingHigh,
   MatchingLow,
   BullishSeperate,
   BearishSeperate
};

class DualPattern{
    private:
        CandleStick firstCS;
        CandleStick secondCS;

    
    public:
        DualPattern(CandleStick& first, CandleStick& second);
        ~DualPattern();
        ENUM_DUALCANDLESTICKPATTERN IdentifyDualPattern();
        void SetDualCandleStick(CandleStick& first, CandleStick& second);


    private:
        bool isBullishEngulfing();
        bool isBearishEngulfing();
        bool isTweezerTops();
        bool isTweezerBottoms();
        bool isBullishPiercingLine();
        bool isBearishPiercingLine();
        bool isBullishKicking();
        bool isBearishKicking();
        bool isBullishHarami();
        bool isBearishHarami();
        bool isBullishWindow();
        bool isBearishWindow();
        bool isBullishMeeting();
        bool isBearishMeeting();
        bool isMatchingHigh();
        bool isMatchingLow();
        bool isBullishSeperate();
        bool isBearishSeperate();

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

DualPattern::DualPattern(CandleStick& first, CandleStick& second){
    this.firstCS = first;
    this.secondCS = second;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

DualPattern::~DualPattern(){
   delete &firstCS;
   delete &secondCS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_DUALCANDLESTICKPATTERN DualPattern::IdentifyDualPattern(){
    if(isBullishEngulfing()){
        return BullishEngulfing;
    }

    else if(isBearishEngulfing()){
        return BearishEngulfing;
    }
    
    else if(isBullishKicking()){
        return BullishKicking;
    }

    else if(isBearishKicking()){
        return BearishKicking;
    }

    else if(isBullishHarami()){
        return BullishHarami;
    }

    else if(isBearishHarami()){
        return BearishHarami;
    }
    
    
    else if(isMatchingLow()){
        return MatchingLow;
    }

    else if(isMatchingHigh()){
        return MatchingHigh;
    }   
    
    
    else if(isBullishPiercingLine()){
        return BullishPiercingLine;
    }

    else if(isBearishPiercingLine()){
        return BearishPiercingLine;
    }
    
    else if(isBullishMeeting()){
        return BullishMeeting;
    }    
    
    else if(isBullishSeperate()){
        return BullishSeperate;
    }    
    
    
    else if(isBearishMeeting()){
        return BearishMeeting;
    }      
    
    else if(isBearishSeperate()){
        return BearishSeperate;
    }    
      
    
    else if(isBullishWindow()){
        return BullishWindow;
    }    
    
    else if(isBearishWindow()){
        return BearishWindow;
    }    
    
    else if(isTweezerTops()){
        return TweezerTops;
    }

    else if(isTweezerBottoms()){
        return TweezerBottoms;
    }

    return NADualPattern;

}
//+------------------------------------------------------------------+
//|                                                                  |
//+                       Pattern Variation                          +
//|                                                                  |
//+------------------------------------------------------------------+

void DualPattern::SetDualCandleStick(CandleStick& first, CandleStick& second){
    this.firstCS = first;
    this.secondCS = second;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBullishEngulfing(){
    if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish
        && firstCS.GetRealBodyAbs()*1.3<=secondCS.GetRealBodyAbs()
        && firstCS.GetClose() <= secondCS.GetOpen()
        && firstCS.GetOpen() < secondCS.GetClose()
        && secondCS.GetRealBodyPercentage() >= 40
    )
        {
            return true;
        }

        return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBearishEngulfing(){
    if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish
        && firstCS.GetRealBodyAbs()*1.3<=secondCS.GetRealBodyAbs()
        && firstCS.GetClose() >= secondCS.GetOpen() 
        && firstCS.GetOpen() > secondCS.GetClose() 
        && secondCS.GetRealBodyPercentage() >= 40
    )
        {
            return true;
        }

        return false;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isTweezerTops(){
    if(firstCS.GetTrend()== Bullish && secondCS.GetTrend()== Bearish
        && MathAbs(firstCS.GetHigh() - secondCS.GetHigh()) <= (_Point * 5)
        && firstCS.GetRealBodyPercentage() >= 15
    )
     {
      return true;
     }

     return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isTweezerBottoms(){
    if(firstCS.GetTrend()==Bearish && secondCS.GetTrend()==Bullish 
        && MathAbs(firstCS.GetLow() - secondCS.GetLow()) <= (_Point * 5)
        && firstCS.GetRealBodyPercentage() >= 15 
    )
    {
    return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBullishPiercingLine(){
   if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish
        && firstCS.GetRealBodyPercentage() >= 50
        && secondCS.GetRealBodyPercentage() >= 50
        && firstCS.GetClose() > secondCS.GetOpen()
        && firstCS.GetOpen() > secondCS.GetClose()
        && secondCS.GetClose()>=(firstCS.GetClose()+(firstCS.GetRealBodyAbs()/2))
    )
     {
      return true;
     }

     return false;   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBearishPiercingLine(){
    if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish
        && firstCS.GetRealBodyPercentage() >= 50
        && secondCS.GetRealBodyPercentage() >= 50
        && secondCS.GetOpen() > firstCS.GetClose()
        && secondCS.GetClose() > firstCS.GetOpen()
        && secondCS.GetClose()<=(firstCS.GetClose()+(firstCS.GetRealBodyAbs()/2))
    )
     {
      return true;
     }

     return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBullishKicking(){
    if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish
        && firstCS.GetRealBodyPercentage() >= 30
        && (secondCS.GetRealBodyPercentage() >= 50)
        && secondCS.GetOpen() > firstCS.GetOpen()
    )
     {
      return true;
     }

     return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBearishKicking(){
    if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish
        && firstCS.GetRealBodyPercentage() >= 30
        && secondCS.GetRealBodyPercentage() >= 50
        && firstCS.GetOpen() > secondCS.GetOpen()
    )
     {
      return true;
     }

     return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBullishHarami(){
    if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish
        && secondCS.GetOpen() > firstCS.GetClose()
        && firstCS.GetOpen() > secondCS.GetClose()
        && (secondCS.GetRealBody()/firstCS.GetRealBody()) * 100 <= 50
        && secondCS.GetRealBodyPercentage() >= 40
    )
    {
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBearishHarami(){
    if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish
        && secondCS.GetClose() > firstCS.GetOpen()
        && firstCS.GetClose() > secondCS.GetOpen()
        && (secondCS.GetRealBody()/firstCS.GetRealBody()) * 100 <= 50
        && secondCS.GetRealBodyPercentage() >= 40
    )
    {
        return true;
    }

    return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBullishWindow(){
   if((secondCS.GetLow() - firstCS.GetHigh()) >= _Point * 10){
      return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBearishWindow(){
   if((firstCS.GetLow() - secondCS.GetHigh()) >= _Point * 10){
      return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBullishMeeting(){
   if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish
   && firstCS.GetClose() >= secondCS.GetClose()
   && secondCS.GetRealBodyPercentage() >= 10
   )
   {
      return true;
   }
   
   return false;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBearishMeeting(){
   if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish
   && firstCS.GetClose() <= secondCS.GetClose()
   && secondCS.GetRealBodyPercentage() >= 10
   )
   {
      return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isMatchingHigh(){
   if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bullish
   && (MathAbs(firstCS.GetClose() - secondCS.GetClose()) <= _Point *5)
   && firstCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isMatchingLow(){
   if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bearish
   && (MathAbs(firstCS.GetClose() - secondCS.GetClose()) <= _Point *5)
   && firstCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBullishSeperate(){
   if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish
   && secondCS.GetOpen() > firstCS.GetOpen()
   && secondCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool DualPattern::isBearishSeperate(){
   if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish
   && secondCS.GetOpen() < firstCS.GetOpen()
   && secondCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+