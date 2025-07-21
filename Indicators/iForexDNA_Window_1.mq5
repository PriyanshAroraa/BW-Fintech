#property copyright "Copyright 2025, Your Name"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 0
#property indicator_plots   0

#include    "..\iForexDNA\Graphics.mqh"

Graphics *graphics;

int OnInit() {
   int subwindow = 1; // Hardcode to first subwindow
   Print("Initializing Graphics for subwindow: ", subwindow);
   graphics = new Graphics(subwindow, 0); // 0 for Header Panel
   if (graphics == NULL || !graphics.Init()) {
      Print("Failed to initialize Graphics for subwindow: ", subwindow);
      delete graphics;
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
   if (graphics != NULL) delete graphics;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
   return(rates_total);
}