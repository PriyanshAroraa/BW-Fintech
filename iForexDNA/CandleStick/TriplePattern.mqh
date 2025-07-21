//+------------------------------------------------------------------+
//|                                                TriplePattern.mqh |
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

static const string EnumTriplePatternStrings[]=
  {
   "NATriplePattern","MorningStar","EveningStar","ThreeWhiteSoldiers","ThreeBlackSoldiers",
   "ThreeInsideUp","ThreeInsideDown", "ThreeOutsideUp", "ThreeOutsideDown", "DownsideTasukiGap", "UpsideTasukiGap"
  };


enum ENUM_TRIPLECANDLESTICKPATTERN
{
   NATriplePattern,
   MorningStar,
   EveningStar,
   ThreeWhiteSoldiers,
   ThreeBlackSoldiers,
   ThreeInsideUp,
   ThreeInsideDown,
   ThreeOutsideUp,
   ThreeOutsideDown,
   DownsideTasukiGap,
   UpsideTasukiGap
};

class TriplePattern{
    private:
        CandleStick firstCS;
        CandleStick secondCS;
        CandleStick thirdCS;

    
    public:
        TriplePattern(CandleStick& first, CandleStick& second, CandleStick& third);
        ~TriplePattern();
        ENUM_TRIPLECANDLESTICKPATTERN IdentifyTriplePattern();
        void SetTripleCandleStick(CandleStick& first, CandleStick& second, CandleStick& third);


    private:
        // bulish triple patterns
        bool isMorningStar();      
        bool isThreeWhiteSoldiers();
        bool isThreeInsideUp();
        bool isThreeOutsideUp();
        bool isUpsideTasukiGap();
        
        // bearish triple patterens
        bool isEveningStar();
        bool isThreeBlackSoldiers();
        bool isThreeInsideDown();
        bool isThreeOutsideDown();
        bool isDownsideTasukiGap();
        

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TriplePattern::TriplePattern(CandleStick& first, CandleStick& second, CandleStick& third){
    this.firstCS = first;
    this.secondCS = second;
    this.thirdCS = third;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TriplePattern::~TriplePattern(){
   delete &firstCS;
   delete &secondCS;
   delete &thirdCS;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ENUM_TRIPLECANDLESTICKPATTERN TriplePattern::IdentifyTriplePattern(){
    if(isMorningStar()){
        return MorningStar;
    }

    else if(isEveningStar()){
        return  EveningStar;
    }

    else if(isThreeWhiteSoldiers()){
        return ThreeWhiteSoldiers;
    }    

    else if(isThreeBlackSoldiers()){
        return ThreeBlackSoldiers;
    }

    else if(isThreeInsideUp()){
        return ThreeInsideUp;
    }

    else if(isThreeInsideDown()){
        return ThreeInsideDown;
    }

    else if(isThreeOutsideUp()){
        return ThreeOutsideUp;
    }

    else if(isThreeOutsideDown()){
        return ThreeOutsideDown;
    }
    
    else if(isDownsideTasukiGap()){
        return DownsideTasukiGap;
    }

    else if(isUpsideTasukiGap()){
        return UpsideTasukiGap;
    }


    return NATriplePattern;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TriplePattern::SetTripleCandleStick(CandleStick& first, CandleStick& second, CandleStick& third){
    this.firstCS = first;
    this.secondCS = second;
    this.thirdCS = third;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+                 Pattern Variation                                +
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isMorningStar(){
    if(firstCS.GetTrend() == Bearish && thirdCS.GetTrend() == Bullish
    && firstCS.GetHigh() > secondCS.GetHigh()
    && MathMax(secondCS.GetClose(), secondCS.GetOpen()) >= firstCS.GetClose()
    && thirdCS.GetClose() >= (firstCS.GetHigh()-(firstCS.GetHLDiff()/2))
    )
    {
     return true;
    }

    return false; 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isEveningStar(){
    if(firstCS.GetTrend() == Bullish && thirdCS.GetTrend() == Bearish
        && firstCS.GetLow() < secondCS.GetLow()
         && MathMin(secondCS.GetClose(), secondCS.GetOpen()) <= firstCS.GetClose()
        && thirdCS.GetClose() <= (firstCS.GetHigh()-(firstCS.GetHLDiff()/2))
    )
     {
      return true;
     }

     return false; 
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isThreeWhiteSoldiers(){
    if(firstCS.GetTrend()==Bullish && secondCS.GetTrend()==Bullish && thirdCS.GetTrend()==Bullish
      && firstCS.GetPattern() == WhiteMarubozu && secondCS.GetPattern() == WhiteMarubozu && thirdCS.GetPattern() == WhiteMarubozu
      )
      {
        return true;
      }

      return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isThreeBlackSoldiers(){
    if(firstCS.GetTrend()==Bearish && secondCS.GetTrend()==Bearish && thirdCS.GetTrend()==Bearish
      && firstCS.GetPattern() == BlackMarubozu && secondCS.GetPattern() == BlackMarubozu && thirdCS.GetPattern() == BlackMarubozu
      )
      {
        return true;
      }

      return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isThreeInsideUp(){
    if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish && thirdCS.GetTrend() == Bullish
        && firstCS.GetRealBodyPercentage() >= 50 && (secondCS.GetPattern() == SpinningTops || secondCS.GetPattern() == Doji)
        && secondCS.GetOpen() > firstCS.GetClose()
        && firstCS.GetOpen() > secondCS.GetClose()
        && firstCS.GetRealBodyPercentage() > secondCS.GetRealBodyPercentage()
        && thirdCS.GetClose() > firstCS.GetOpen()
        && (thirdCS.GetRealBodyPercentage() >= 65)
    )
      {
        return true;
      }

      return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isThreeInsideDown(){
    if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish && thirdCS.GetTrend() == Bearish
        && firstCS.GetRealBodyPercentage() >= 50 && (secondCS.GetPattern() == SpinningTops || secondCS.GetPattern() == Doji)
        && firstCS.GetOpen() > secondCS.GetClose()
        && firstCS.GetClose() > secondCS.GetOpen()
        && firstCS.GetRealBodyPercentage() > secondCS.GetRealBodyPercentage()
        && firstCS.GetOpen() > thirdCS.GetClose()
        && (thirdCS.GetRealBodyPercentage() >= 65)
    )
      {
        return true;
      }

      return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isThreeOutsideUp(){
   if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bullish && thirdCS.GetTrend() == Bullish
   && firstCS.GetClose() > secondCS.GetOpen() && firstCS.GetOpen() < secondCS.GetClose()
   && thirdCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isThreeOutsideDown(){
   if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bearish && thirdCS.GetTrend() == Bearish
   && firstCS.GetClose() < secondCS.GetOpen() && firstCS.GetOpen() > secondCS.GetClose()
   && thirdCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isUpsideTasukiGap(){
   if(firstCS.GetTrend() == Bullish && secondCS.GetTrend() == Bullish && thirdCS.GetTrend() == Bearish
   && firstCS.GetClose() < secondCS.GetOpen() && firstCS.GetRealBodyPercentage() > secondCS.GetRealBodyPercentage()
   && (secondCS.GetClose() - (secondCS.GetRealBodyAbs()/2)) >= thirdCS.GetOpen() && secondCS.GetOpen() > thirdCS.GetClose()
   && thirdCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool TriplePattern::isDownsideTasukiGap(){
   if(firstCS.GetTrend() == Bearish && secondCS.GetTrend() == Bearish && thirdCS.GetTrend() == Bullish
   && firstCS.GetClose() > secondCS.GetOpen() && firstCS.GetRealBodyPercentage() > secondCS.GetRealBodyPercentage()
   && (secondCS.GetClose() - (secondCS.GetRealBodyAbs()/2)) <= thirdCS.GetOpen() && secondCS.GetOpen() < thirdCS.GetClose()
   && thirdCS.GetRealBodyPercentage() >= 40
   )
   {
      return true;
   }
   
   return false;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


