//+------------------------------------------------------------------+
//|                                                 BaseStrategy.mqh |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property strict

#include "..\MiscFunc.mqh"
#include "..\Enums.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class BaseStrategy 
{
   private:
       bool                         isPastHighTimeFrameSetUp;
       bool                         isPastHighTimeFrameConfirmation;
       bool                         isPastLowTimeFrameSetUp;
       bool                         isPastAddLotSetUp;
       datetime                     ExpiryDate;
       datetime                     AddLotExpiryDate;
       bool                         isEntered;
       int                          OrderDirection;
       int                          NoAddLotPosition;
       ENUM_TRADE_TYPE              TradeType;
       string                       Comments;
       datetime                     CooldownTime;
   
   
       // Order Management Utils
       int                          WinTrades;
       int                          LoseTrades;
       double                       WinAmount;
       double                       LoseAmount;


    public:
       BaseStrategy() 
        {
            setIsPastHighTimeFrameSetUp(false);
            setIsPastHighTimeFrameConfirmation(false);
            setIsPastLowTimeFrameSetUp(false);
            setIsPastAddLotSetUp(false);
            setExpiryDate(0);
            setAddLotExpiryDate(0);
            setIsEntered(false);
            setOrderDirection(NEUTRAL);
            setNoAddLotPosition(0);
            setTradeType(NoTrade);
            setComments("");
            setCooldownTime(0);
        };
       
       
       ~BaseStrategy(){};


        virtual int     StrategySetUp() const {return NEUTRAL;};
        virtual bool    StrategySetUpConfirmation() const {return false;};
        virtual bool    StrategyLowTimeFrameSetUp() const {return false;};
        virtual void    DetermineStrategyEntry();
        


        // additional functions
        string          GetTradeType(string TradeComment);

        void            ResetStrategy()
        {
            setIsPastHighTimeFrameSetUp(false);
            setIsPastHighTimeFrameConfirmation(false);
            setIsPastLowTimeFrameSetUp(false);
            setIsPastAddLotSetUp(false);
            setExpiryDate(0);
            setAddLotExpiryDate(0);
            setIsEntered(false);
            setOrderDirection(NEUTRAL);
            setNoAddLotPosition(0);
            setTradeType(NoTrade);
            setComments("");
        };


        // Setter and Getter for isPastHighTimeFrameSetUp
        void setIsPastHighTimeFrameSetUp(bool value) {
            isPastHighTimeFrameSetUp = value;
        }
        
        bool getIsPastHighTimeFrameSetUp() {
            return isPastHighTimeFrameSetUp;
        }

        // Setter and Getter for isPastHighTimeFrameConfirmation
        void setIsPastHighTimeFrameConfirmation(bool value) {
            isPastHighTimeFrameConfirmation = value;
        }

        bool getIsPastHighTimeFrameConfirmation() {
            return isPastHighTimeFrameConfirmation;
        }
        
        // Setter and Getter for isPastLowTimeFrameSetUp
        void setIsPastLowTimeFrameSetUp(bool value) {
            isPastLowTimeFrameSetUp = value;
        }

        bool getIsPastLowTimeFrameSetUp() {
            return isPastLowTimeFrameSetUp;
        }

        // Setter and Getter for isPastAddLotSetUp
        void setIsPastAddLotSetUp(bool value) {
            isPastAddLotSetUp = value;
        }

        bool getIsPastAddLotSetUp() {
            return isPastAddLotSetUp;
        }

        // Setter and Getter for FilterOneExpiryDate
        void setExpiryDate(datetime value) {
            ExpiryDate = value;
        }

        datetime getExpiryDate() {
            return ExpiryDate;
        }


        // Setter and Getter for FilterTwoExpiryDate
        void setAddLotExpiryDate(datetime value) {
            AddLotExpiryDate = value;
        }

        datetime getAddLotExpiryDate() {
            return AddLotExpiryDate;
        }

        // Setter and Getter for isEntered
        void setIsEntered(bool value) {
            isEntered = value;
        }

        bool getIsEntered() {
            return isEntered;
        }

        // Setter and Getter for OrderDirection
        void setOrderDirection(int value) {
            OrderDirection = value;
        }

        int getOrderDirection() {
            return OrderDirection;
        }

        // Setter and Getter for NoAddLotPosition
        void setNoAddLotPosition(int value) {
            NoAddLotPosition = value;
        }

        int getNoAddLotPosition() {
            return NoAddLotPosition;
        }

        // Setter and Getter for TradeType
        void setTradeType(ENUM_TRADE_TYPE value) {
            TradeType = value;
        }

        ENUM_TRADE_TYPE getTradeType() {
            return TradeType;
        }

        // Setter and Getter for Comments
        void setComments(string value) {
            Comments = value;
        }

        string getComments() {
            return Comments;
        }
        
        
        // Setter and Getter for CoolDown Time
        void setCooldownTime(datetime cooldown){
            CooldownTime = cooldown;
        }
        
        datetime getCooldownTime(){
            return CooldownTime;
        }


      // Setter functions
      void AddWinTrades(int amount) {
         WinTrades+=amount;
      }
      
      void AddLoseTrades(int amount) {
         LoseTrades+=amount;
      }
      
      void AddWinAmount(double amount) {
         WinAmount+=amount;
      }
      
      void AddLoseAmount(double amount) {
         LoseAmount+=amount;
      }
      
      // Getter functions
      int GetWinTrades() {
         return WinTrades;
      }
      
      int GetLoseTrades() {
         return LoseTrades;
      }
      
      double GetWinAmount() {
         return WinAmount;
      }
      
      double GetLoseAmount() {
         return LoseAmount;
      }

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string BaseStrategy::GetTradeType(string TradeComment)
{
   if(TradeComment == "")
   {
      LogError(__FUNCTION__, "Trade Comment is empty.");
      return "";
   }
   
   string result[];
   int len_result = StringSplit(TradeComment, '-', result);
      
   return result[len_result-1];        // Give latest trading information
   
}

//+------------------------------------------------------------------+