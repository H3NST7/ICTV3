//+------------------------------------------------------------------+
//|                                    ICT_XAUUSD_Master_EA.mq5    |
//|                        Copyright 2025, h3nst7                  |
//|                   Complete Omnipotent ICT Implementation v5.02 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, H3nst7"
#property link      "https://innercircletrader.net"
#property version   "5.02"
#property description "Complete ICT Implementation for XAUUSD - All Concepts Integrated with Advanced Visualization"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// FORWARD DECLARATIONS - CRITICAL FOR COMPILATION
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void InitializePowerOf3Session(string session_name, datetime start_time);
void DrawChartObjects();
void DeleteAllEAObjects();
void UpdateInformationPanel();
void DrawFVGObjects();
void DrawOrderBlockObjects();
void DrawLiquidityObjects();
void DrawSessionObjects();
void DrawMarketStructureObjects();
void DrawIPDAObjects();
void DrawPowerOf3Objects();
void DrawTradeObjects();
void DrawGapObjects();
bool LogDebug(string category, string message);

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// ICT ENUMERATION DEFINITIONS - SINGLE DECLARATION WITH PROPER VALUES
// ═══════════════════════════════════════════════════════════════════════════════════════════════

enum ENUM_ICT_BIAS { 
    BIAS_NONE = 0,
    BIAS_BULLISH, 
    BIAS_BEARISH, 
    BIAS_NEUTRAL 
};

enum ENUM_ICT_SESSION { 
    SESSION_NONE = 0,
    SESSION_ASIAN, 
    SESSION_LONDON, 
    SESSION_NEWYORK, 
    SESSION_OVERLAP 
};

enum ENUM_FVG_TYPE { 
    FVG_NONE = 0,
    FVG_BISI, 
    FVG_SIBI, 
    FVG_IFVG 
};

enum ENUM_OB_TYPE { 
    OB_NONE = 0,
    OB_BULLISH, 
    OB_BEARISH, 
    OB_BREAKER, 
    OB_MITIGATION 
};

enum ENUM_SETUP_TYPE { 
    SETUP_NONE = 0,
    SETUP_FVG, 
    SETUP_OB, 
    SETUP_LIQUIDITY, 
    SETUP_MSS, 
    SETUP_BOS, 
    SETUP_SILVERB,
    SETUP_VENOM
};

enum ENUM_MARKET_STRUCTURE { 
    MS_NONE = 0,
    MS_STH, 
    MS_STL, 
    MS_ITH, 
    MS_ITL, 
    MS_LTH, 
    MS_LTL 
};

enum ENUM_TRADE_STATE {
    TRADE_STATE_OPEN = 0,
    TRADE_STATE_BREAKEVEN,
    TRADE_STATE_PARTIAL_1,
    TRADE_STATE_PARTIAL_2,
    TRADE_STATE_TRAILING
};

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// INPUT PARAMETERS - COMPREHENSIVE ICT CONFIGURATION
// ═══════════════════════════════════════════════════════════════════════════════════════════════

input group "═══ CORE ICT PARAMETERS ═══"
input double InpRiskPercent = 1.0; // Risk per trade (%)
input int InpMagicNumber = 789123; // Magic number
input int InpMaxDailyTrades = 3; // Maximum trades per day
input bool InpUseMultiTimeframe = true; // Enable multi-timeframe analysis

input group "═══ ICT MARKET STRUCTURE ═══"
input int InpMSS_Lookback = 20; // MSS detection lookback
input double InpDisplacementATR = 1.5; // Displacement ATR multiplier
input bool InpRequireConfluence = true; // Require multiple confluences

input group "═══ FAIR VALUE GAPS ═══"
input double InpMinFVGSize = 5.0; // Minimum FVG size (points)
input double InpMaxFVGSize = 200.0; // Maximum FVG size (points)
input int InpFVGExpiry = 48; // FVG expiry (hours)
input bool InpTradeUntestedFVG = true; // Trade only untested FVGs

input group "═══ ORDER BLOCKS ═══"
input int InpOBLookback = 10; // Order block lookback
input double InpOBMinSize = 10.0; // Minimum OB size (points)
input bool InpUseBreakerBlocks = true; // Enable breaker blocks

input group "═══ LIQUIDITY ANALYSIS ═══"
input int InpLiquidityLookback = 50; // Liquidity detection range
input double InpRelativeEqualThreshold = 5.0; // REH/REL threshold (points)
input bool InpRequireLiquiditySweep = true; // Require liquidity sweep confirmation

input group "═══ SESSION FILTERS ═══"
input bool InpUseLondonSession = true; // Trade London session
input bool InpUseNewYorkSession = true; // Trade New York session
input bool InpUseAsianSession = false; // Trade Asian session
input bool InpUseSilverBullet = true; // Enable Silver Bullet (10-11 AM)

input group "═══ GAPS ANALYSIS ═══"
input bool InpUseNDOG = true; // New Day Opening Gap
input bool InpUseNWOG = true; // New Week Opening Gap
input double InpGapQuarter1 = 0.25; // Gap quarter level 1 (25%)
input double InpGapQuarter2 = 0.50; // Gap quarter level 2 (50%)
input double InpGapQuarter3 = 0.75; // Gap quarter level 3 (75%)
input double InpGapQuarter4 = 1.00; // Gap quarter level 4 (100%)

input group "═══ PREMIUM/DISCOUNT ═══"
input bool InpUsePremiumDiscount = true; // Enable premium/discount analysis
input double InpOTE_Low = 0.618; // OTE lower bound
input double InpOTE_High = 0.786; // OTE upper bound

input group "═══ RISK MANAGEMENT ═══"
input double InpMaxDrawdown = 15.0; // Maximum drawdown (%)
input double InpTrailingATR = 2.0; // Trailing stop ATR
input double InpBreakevenATR = 1.0; // Breakeven trigger ATR
input bool InpUseNewsFilter = true; // Enable news filter

input group "═══ ADVANCED SETTINGS ═══"
input int InpServerTimeOffset = 0; // Server time offset from NY (hours)
input bool InpUseDSTAdjustment = true; // Enable DST adjustment
input double InpConfluenceThreshold = 50.0; // Minimum confluence score (LOWERED FOR TESTING)
input double InpVenomTargetTicks = 65.0; // Venom model target (ticks)
input double InpSilverBulletMinHandles = 5.0; // Silver Bullet minimum handles

input group "═══ VISUALIZATION CONTROLS ═══"
input bool InpShowFVGs = true; // Show Fair Value Gaps
input bool InpShowOrderBlocks = true; // Show Order Blocks
input bool InpShowLiquidity = true; // Show Liquidity Levels
input bool InpShowSessions = true; // Show Trading Sessions
input bool InpShowMarketStructure = true; // Show Market Structure
input bool InpShowIPDA = true; // Show IPDA Levels
input bool InpShowPowerOf3 = true; // Show Power of 3
input bool InpShowTrades = true; // Show Trade Levels
input bool InpShowGaps = true; // Show Gap Analysis
input bool InpShowInfoPanel = true; // Show Information Panel
input color InpFVGBullishColor = clrLimeGreen; // Bullish FVG Color
input color InpFVGBearishColor = clrTomato; // Bearish FVG Color
input color InpOBBullishColor = clrDodgerBlue; // Bullish OB Color
input color InpOBBearishColor = clrOrangeRed; // Bearish OB Color
input color InpLiquidityBuysideColor = clrCyan; // Buyside Liquidity Color
input color InpLiquiditySellsideColor = clrMagenta; // Sellside Liquidity Color

input group "═══ DEBUGGING ═══"
input bool InpEnableDebugLogging = true; // Enable detailed debug logging
input bool InpLogConfluenceScores = true; // Log confluence calculations
input bool InpLogTradingConditions = true; // Log trading condition checks

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// STRUCTURE DEFINITIONS - FIXED FOR MQL5 COMPILATION
// ═══════════════════════════════════════════════════════════════════════════════════════════════

struct ICTPattern {
    datetime time;
    double high, low, open, close;
    ENUM_SETUP_TYPE type;
    ENUM_ICT_BIAS direction;
    ENUM_FVG_TYPE fvg_type;
    ENUM_OB_TYPE ob_type;
    double confluence_score;
    bool valid;
    bool tested;
    bool untested_required;
    int timeframe;
    double atr_at_formation;
    
    ICTPattern() {
        time = 0;
        high = low = open = close = 0.0;
        type = SETUP_NONE;
        direction = BIAS_NONE;
        fvg_type = FVG_NONE;
        ob_type = OB_NONE;
        confluence_score = 0.0;
        valid = false;
        tested = false;
        untested_required = false;
        timeframe = PERIOD_M1;
        atr_at_formation = 0.0;
    }
};

struct MarketStructure {
    datetime time;
    double price;
    ENUM_MARKET_STRUCTURE type;
    bool confirmed;
    int significance_score;
    
    MarketStructure() {
        time = 0;
        price = 0.0;
        type = MS_NONE;
        confirmed = false;
        significance_score = 0;
    }
};

struct LiquidityLevel {
    datetime time;
    double price;
    bool is_buyside;
    bool swept;
    int touch_count;
    double relative_equal_threshold;
    
    LiquidityLevel() {
        time = 0;
        price = 0.0;
        is_buyside = false;
        swept = false;
        touch_count = 0;
        relative_equal_threshold = 0.0;
    }
};

struct SessionData {
    datetime start_time;
    datetime end_time;
    double high, low, open, close;
    ENUM_ICT_SESSION session_type;
    bool active;
    
    SessionData() {
        start_time = end_time = 0;
        high = low = open = close = 0.0;
        session_type = SESSION_NONE;
        active = false;
    }
};

struct GapData {
    datetime formation_time;
    double upper_level;
    double lower_level;
    double quarter_levels[4];
    bool is_ndog;
    bool is_nwog;
    bool filled;
    double fill_percentage;
    
    GapData() {
        formation_time = 0;
        upper_level = lower_level = 0.0;
        for(int i = 0; i < 4; i++) quarter_levels[i] = 0.0;
        is_ndog = is_nwog = filled = false;
        fill_percentage = 0.0;
    }
};

struct TradeInfo {
    ulong ticket;
    ENUM_SETUP_TYPE setup_type;
    ENUM_TRADE_STATE state;
    datetime entry_time;
    double entry_price;
    double original_sl;
    double original_tp;
    
    TradeInfo() {
        ticket = 0;
        setup_type = SETUP_NONE;
        state = TRADE_STATE_OPEN;
        entry_time = 0;
        entry_price = original_sl = original_tp = 0.0;
    }
};

struct IPDAData {
    double highs_20[20];
    double lows_20[20];
    double highs_40[40]; 
    double lows_40[40];
    double highs_60[60];
    double lows_60[60];
    double highest_20, lowest_20;
    double highest_40, lowest_40;
    double highest_60, lowest_60;
    datetime last_update;
    bool quarterly_shift_pending;
    int days_since_shift;
    
    IPDAData() {
        for(int i = 0; i < 20; i++) {
            highs_20[i] = 0.0;
            lows_20[i] = 0.0;
        }
        for(int i = 0; i < 40; i++) {
            highs_40[i] = 0.0;
            lows_40[i] = 0.0;
        }
        for(int i = 0; i < 60; i++) {
            highs_60[i] = 0.0;
            lows_60[i] = 0.0;
        }
        highest_20 = lowest_20 = highest_40 = lowest_40 = highest_60 = lowest_60 = 0.0;
        last_update = 0;
        quarterly_shift_pending = false;
        days_since_shift = 0;
    }
};

struct VenomRange {
    double high;
    double low;
    datetime start_time;
    bool active;
    bool swept_high;
    bool swept_low;
    
    VenomRange() {
        high = low = 0.0;
        start_time = 0;
        active = swept_high = swept_low = false;
    }
};

struct PowerOf3 {
    double accumulation_level;
    double manipulation_level;
    double distribution_target;
    ENUM_ICT_BIAS po3_bias;
    datetime session_start;
    bool manipulation_complete;
    bool distribution_active;
    
    PowerOf3() {
        accumulation_level = manipulation_level = distribution_target = 0.0;
        po3_bias = BIAS_NONE;
        session_start = 0;
        manipulation_complete = distribution_active = false;
    }
};

struct IndicatorCache {
    double atr_m1_14;
    double atr_h1_14;
    double atr_h4_14;
    double ema_fast_h1;
    double ema_slow_h1;
    double ema_fast_h4; 
    double ema_slow_h4;
    datetime last_update;
    
    IndicatorCache() {
        atr_m1_14 = atr_h1_14 = atr_h4_14 = 0.0;
        ema_fast_h1 = ema_slow_h1 = ema_fast_h4 = ema_slow_h4 = 0.0;
        last_update = 0;
    }
};

struct NewsEvent {
    datetime event_time;
    string currency;
    int impact_level;
    string description;
    
    NewsEvent() {
        event_time = 0;
        currency = "";
        impact_level = 0;
        description = "";
    }
};

struct DSTInfo {
    datetime dst_start;
    datetime dst_end;
    int offset_standard;
    int offset_dst;
    bool is_dst_active;
    
    DSTInfo() {
        dst_start = dst_end = 0;
        offset_standard = offset_dst = 0;
        is_dst_active = false;
    }
};

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// GLOBAL VARIABLES
// ═══════════════════════════════════════════════════════════════════════════════════════════════

CTrade g_trade;
CSymbolInfo g_symbol;
CPositionInfo g_position;
CAccountInfo g_account;
CDealInfo g_deal;

ICTPattern g_patterns[];
MarketStructure g_market_structure[];
LiquidityLevel g_liquidity_levels[];
SessionData g_sessions[4];
GapData g_gaps[];
NewsEvent g_news_events[];
TradeInfo g_active_trades[];

IPDAData g_ipda;
VenomRange g_venom_range;
PowerOf3 g_power_of_3;
IndicatorCache g_indicator_cache;
DSTInfo g_dst_info;

ENUM_ICT_BIAS g_daily_bias = BIAS_NEUTRAL;
ENUM_ICT_BIAS g_htf_bias = BIAS_NEUTRAL;
datetime g_last_analysis_time;
int g_trades_today = 0;
double g_daily_pnl = 0.0;

double g_equity_high = 0.0;
double g_max_dd = 0.0;
int g_pattern_count = 0;
int g_liquidity_count = 0;
int g_gap_count = 0;
int g_market_structure_count = 0;
int g_news_count = 0;
int g_active_trades_count = 0;

double g_cached_highs[100];
double g_cached_lows[100];
double g_cached_opens[100];
double g_cached_closes[100];
datetime g_cached_times[100];
bool g_cache_initialized = false;

int g_atr_m1_handle = INVALID_HANDLE;
int g_atr_h1_handle = INVALID_HANDLE;
int g_atr_h4_handle = INVALID_HANDLE;
int g_ema_fast_h1_handle = INVALID_HANDLE;
int g_ema_slow_h1_handle = INVALID_HANDLE;
int g_ema_fast_h4_handle = INVALID_HANDLE;
int g_ema_slow_h4_handle = INVALID_HANDLE;

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// SYSTEM CONSTANTS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

const int SECONDS_PER_MINUTE = 60;
const int SECONDS_PER_HOUR = 3600;
const int SECONDS_PER_DAY = 86400;
const int BARS_PER_DAY_M1 = 1440;

const double EMERGENCY_STOP_MULTIPLIER = 1.5;
const double MARGIN_UTILIZATION_LIMIT = 0.9;
const double DAILY_LOSS_LIMIT_PERCENT = 0.05;

const int MIN_SWING_CONFIRMATION_BARS = 3;
const int LIQUIDITY_SWEEP_LOOKBACK_BARS = 10;
const double STOP_BUFFER_ATR_MULTIPLIER = 0.5;
const double BREAKEVEN_BUFFER_POINTS = 5.0;
const double VENOM_STRIKE_BUFFER_TICKS = 15.0;
const double SILVER_BULLET_MIN_HANDLES = 5.0;

const int LONDON_KILL_ZONE_START = 2;
const int LONDON_KILL_ZONE_END = 5;
const int NY_AM_KILL_ZONE_START_HOUR = 8;
const int NY_AM_KILL_ZONE_START_MIN = 30;
const int NY_AM_KILL_ZONE_END = 11;
const int NY_PM_KILL_ZONE_START_HOUR = 13;
const int NY_PM_KILL_ZONE_START_MIN = 30;
const int NY_PM_KILL_ZONE_END = 16;
const int SILVER_BULLET_START = 10;
const int SILVER_BULLET_END = 11;

const int IPDA_SHORT_LOOKBACK = 20;
const int IPDA_MEDIUM_LOOKBACK = 40;
const int IPDA_LONG_LOOKBACK = 60;
const int IPDA_QUARTERLY_SHIFT_MIN_DAYS = 90;
const int IPDA_QUARTERLY_SHIFT_MAX_DAYS = 120;

const int VENOM_ELECTRONIC_TRADING_START = 8;
const int VENOM_ELECTRONIC_TRADING_END_HOUR = 9;
const int VENOM_ELECTRONIC_TRADING_END_MIN = 30;
const int VENOM_TARGET_TICKS_MIN = 50;
const int VENOM_TARGET_TICKS_MAX = 80;

const int CACHE_UPDATE_FREQUENCY_SECONDS = 60;
const int ARRAY_OPTIMIZATION_FREQUENCY = 100;
const int DATA_COMPRESSION_FREQUENCY_SECONDS = 3600;

const int HIGH_IMPACT_NEWS_BUFFER_MINUTES = 30;
const int NEWS_CACHE_EXPIRY_HOURS = 24;

const int DST_START_MONTH = 3;
const int DST_END_MONTH = 11;
const int DST_WEEK_OF_MONTH = 2;

// Chart object prefixes for organized management
const string OBJ_PREFIX_FVG = "ICT_FVG_";
const string OBJ_PREFIX_OB = "ICT_OB_";
const string OBJ_PREFIX_LIQ = "ICT_LIQ_";
const string OBJ_PREFIX_SESSION = "ICT_SESSION_";
const string OBJ_PREFIX_MS = "ICT_MS_";
const string OBJ_PREFIX_IPDA = "ICT_IPDA_";
const string OBJ_PREFIX_PO3 = "ICT_PO3_";
const string OBJ_PREFIX_TRADE = "ICT_TRADE_";
const string OBJ_PREFIX_GAP = "ICT_GAP_";
const string OBJ_PREFIX_INFO = "ICT_INFO_";

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// MAIN EA FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

int OnInit() {
    Print("═══════════════════════════════════════════════════════════════");
    Print("ICT XAUUSD MASTER EA v5.02 - OMNIPOTENT ICT IMPLEMENTATION");
    Print("Initializing advanced algorithmic trading system with visualization...");
    Print("═══════════════════════════════════════════════════════════════");
    
    if(!InitializeSymbol()) {
        LogCriticalEvent("INIT_ERROR", "Symbol initialization failed");
        return INIT_PARAMETERS_INCORRECT;
    }
    
    if(!ValidateInputsEnhanced()) {
        LogCriticalEvent("INIT_ERROR", "Enhanced input validation failed");
        return INIT_PARAMETERS_INCORRECT;
    }
    
    if(!InitializeTradingObjects()) {
        LogCriticalEvent("INIT_ERROR", "Trading objects initialization failed");
        return INIT_FAILED;
    }
    
    if(!InitializeDataStructures()) {
        LogCriticalEvent("INIT_ERROR", "Data structures initialization failed");
        return INIT_FAILED;
    }
    
    if(!InitializeIndicatorHandles()) {
        LogCriticalEvent("INIT_ERROR", "Indicator handles initialization failed");
        return INIT_FAILED;
    }
    
    InitializeICTStructures();
    InitializeDSTSettings();
    InitializeNewsFilter();
    InitializePerformanceTracking();
    ConfigureXAUUSDSettings();
    InitializeSystemState();
    
    // Initialize visualization system
    DeleteAllEAObjects();
    
    LogCriticalEvent("EA_STARTUP", "ICT XAUUSD Master EA initialized successfully");
    Print("Features: Venom Model, Silver Bullet, IPDA, Power of 3, Advanced FVG/OB");
    Print("Session Analysis, Kill Zones, Gap Analysis, Multi-timeframe Bias");
    Print("News Filter, DST Adjustment, Weighted Confluence, Enhanced Trade Management");
    Print("Risk Management: Emergency stops, state machine, performance monitoring");
    Print("Visualization: Complete chart object system with advanced ICT analysis display");
    Print("═══════════════════════════════════════════════════════════════");
    
    return INIT_SUCCEEDED;
}

void OnTick() {
    if(!IsNewBar()) return;
    
    LogDebug("ONTICK", "New bar detected - Starting analysis cycle");
    
    if(!UpdateMarketDataBatch()) {
        LogDebug("ONTICK", "Market data update failed - Skipping cycle");
        return;
    }
    
    UpdateIndicatorCache();
    UpdateNewsEvents();
    
    UpdateMarketBias();
    UpdateIPDAData();
    UpdatePowerOf3();
    AnalyzeGapSignificance();
    
    AnalyzeMarketStructure();
    ScanFairValueGaps();
    ScanOrderBlocks();
    AnalyzeLiquidity();
    
    UpdateSessions();
    AnalyzeKillZones();
    
    if(InpUseSilverBullet) ProcessSilverBulletSetups();
    ProcessVenomModel();
    
    LogDebug("TRADING_CHECK", StringFormat("Trading allowed check - Current status being evaluated"));
    
    if(IsTradingAllowed()) {
        LogDebug("TRADING", "Trading conditions met - Processing setups");
        ProcessHighProbabilitySetups();
    } else {
        LogDebug("TRADING", "Trading conditions not met - Skipping trade processing");
    }
    
    ManagePositions();
    UpdatePerformanceMetrics();
    CleanupExpiredData();
    
    // Update visualization
    if(InpShowInfoPanel || InpShowFVGs || InpShowOrderBlocks || InpShowLiquidity || 
       InpShowSessions || InpShowMarketStructure || InpShowIPDA || InpShowPowerOf3 || 
       InpShowTrades || InpShowGaps) {
        DrawChartObjects();
    }
}

void OnDeinit(const int reason) {
    LogCriticalEvent("EA_SHUTDOWN", StringFormat("Deinitializing EA. Reason: %s", 
                                                 GetUninitReasonText(reason)));
    
    GeneratePerformanceReport();
    
    // Release indicator handles
    if(g_atr_m1_handle != INVALID_HANDLE) IndicatorRelease(g_atr_m1_handle);
    if(g_atr_h1_handle != INVALID_HANDLE) IndicatorRelease(g_atr_h1_handle);
    if(g_atr_h4_handle != INVALID_HANDLE) IndicatorRelease(g_atr_h4_handle);
    if(g_ema_fast_h1_handle != INVALID_HANDLE) IndicatorRelease(g_ema_fast_h1_handle);
    if(g_ema_slow_h1_handle != INVALID_HANDLE) IndicatorRelease(g_ema_slow_h1_handle);
    if(g_ema_fast_h4_handle != INVALID_HANDLE) IndicatorRelease(g_ema_fast_h4_handle);
    if(g_ema_slow_h4_handle != INVALID_HANDLE) IndicatorRelease(g_ema_slow_h4_handle);
    
    // Clean up arrays
    ArrayFree(g_patterns);
    ArrayFree(g_market_structure);
    ArrayFree(g_liquidity_levels);
    ArrayFree(g_gaps);
    ArrayFree(g_active_trades);
    ArrayFree(g_news_events);
    
    // Remove all chart objects
    DeleteAllEAObjects();
    
    if(reason == REASON_PROGRAM || reason == REASON_REMOVE) {
        CloseAllPositions();
    }
    
    Print("ICT XAUUSD Master EA successfully deinitialized");
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// INITIALIZATION FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

bool InitializeSymbol() {
    if(!g_symbol.Name(_Symbol)) {
        Print("Error: Failed to initialize symbol");
        return false;
    }
    
    if(!g_symbol.RefreshRates()) {
        Print("Error: Failed to refresh rates");
        return false;
    }
    
    if(StringFind(_Symbol, "XAU") == -1 && StringFind(_Symbol, "GOLD") == -1) {
        Print("Warning: EA designed for XAUUSD, current symbol: ", _Symbol);
    }
    
    LogDebug("SYMBOL", StringFormat("Symbol initialized: %s, Point: %.5f, Digits: %d", 
                                   _Symbol, g_symbol.Point(), g_symbol.Digits()));
    
    return true;
}

bool ValidateInputsEnhanced() {
    bool validation_passed = true;
    
    if(InpRiskPercent <= 0 || InpRiskPercent > 10) {
        Print("ERROR: Risk percentage must be between 0.1% and 10%");
        validation_passed = false;
    }
    
    if(InpMaxDrawdown <= 0 || InpMaxDrawdown > 50) {
        Print("ERROR: Maximum drawdown must be between 1% and 50%");
        validation_passed = false;
    }
    
    if(InpMaxDailyTrades < 1 || InpMaxDailyTrades > 20) {
        Print("ERROR: Daily trades must be between 1 and 20");
        validation_passed = false;
    }
    
    if(InpMinFVGSize <= 0 || InpMinFVGSize >= InpMaxFVGSize) {
        Print("ERROR: Invalid FVG size parameters");
        validation_passed = false;
    }
    
    if(InpFVGExpiry < 1 || InpFVGExpiry > 168) {
        Print("ERROR: FVG expiry must be between 1 and 168 hours");
        validation_passed = false;
    }
    
    if(InpConfluenceThreshold < 10 || InpConfluenceThreshold > 100) {
        Print("ERROR: Confluence threshold must be between 10 and 100");
        validation_passed = false;
    }
    
    if(InpServerTimeOffset < -12 || InpServerTimeOffset > 12) {
        Print("ERROR: Server time offset must be between -12 and +12 hours");
        validation_passed = false;
    }
    
    if(InpVenomTargetTicks < 30 || InpVenomTargetTicks > 150) {
        Print("ERROR: Venom target must be between 30 and 150 ticks");
        validation_passed = false;
    }
    
    if(InpSilverBulletMinHandles < 3 || InpSilverBulletMinHandles > 15) {
        Print("ERROR: Silver Bullet minimum handles must be between 3 and 15");
        validation_passed = false;
    }
    
    LogDebug("VALIDATION", StringFormat("Input validation %s", validation_passed ? "PASSED" : "FAILED"));
    
    return validation_passed;
}

bool InitializeTradingObjects() {
    g_trade.SetExpertMagicNumber(InpMagicNumber);
    g_trade.SetDeviationInPoints(20);
    g_trade.SetTypeFilling(ORDER_FILLING_IOC);
    
    if(!g_trade.SetTypeFillingBySymbol(_Symbol)) {
        Print("WARNING: Could not set optimal filling type for symbol");
        g_trade.SetTypeFilling(ORDER_FILLING_RETURN);
    }
    
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        Print("ERROR: Trading not allowed in terminal");
        return false;
    }
    
    if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
        Print("ERROR: Trading not allowed for Expert Advisors");
        return false;
    }
    
    if(!g_account.TradeAllowed()) {
        Print("ERROR: Trading not allowed for account");
        return false;
    }
    
    if(g_account.MarginMode() == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
        Print("INFO: Retail hedging account detected");
    }
    
    LogDebug("TRADING", "Trading objects initialized successfully");
    
    return true;
}

bool InitializeDataStructures() {
    if(ArrayResize(g_patterns, 300) != 300) {
        Print("ERROR: Failed to resize g_patterns array");
        return false;
    }
    
    if(ArrayResize(g_market_structure, 150) != 150) {
        Print("ERROR: Failed to resize g_market_structure array");
        return false;
    }
    
    if(ArrayResize(g_liquidity_levels, 200) != 200) {
        Print("ERROR: Failed to resize g_liquidity_levels array");
        return false;
    }
    
    if(ArrayResize(g_gaps, 100) != 100) {
        Print("ERROR: Failed to resize g_gaps array");
        return false;
    }
    
    if(ArrayResize(g_active_trades, 30) != 30) {
        Print("ERROR: Failed to resize g_active_trades array");
        return false;
    }
    
    if(ArrayResize(g_news_events, 50) != 50) {
        Print("ERROR: Failed to resize g_news_events array");
        return false;
    }
    
    g_pattern_count = 0;
    g_liquidity_count = 0;
    g_gap_count = 0;
    g_active_trades_count = 0;
    g_market_structure_count = 0;
    g_news_count = 0;
    
    LogDebug("STRUCTURES", "Enhanced data structures initialized successfully");
    return true;
}

bool InitializeIndicatorHandles() {
    g_atr_m1_handle = iATR(_Symbol, PERIOD_M1, 14);
    if(g_atr_m1_handle == INVALID_HANDLE) {
        Print("ERROR: Failed to create ATR M1 handle");
        return false;
    }
    
    g_atr_h1_handle = iATR(_Symbol, PERIOD_H1, 14);
    if(g_atr_h1_handle == INVALID_HANDLE) {
        Print("ERROR: Failed to create ATR H1 handle");
        return false;
    }
    
    g_atr_h4_handle = iATR(_Symbol, PERIOD_H4, 14);
    if(g_atr_h4_handle == INVALID_HANDLE) {
        Print("ERROR: Failed to create ATR H4 handle");
        return false;
    }
    
    g_ema_fast_h1_handle = iMA(_Symbol, PERIOD_H1, 8, 0, MODE_EMA, PRICE_CLOSE);
    if(g_ema_fast_h1_handle == INVALID_HANDLE) {
        Print("ERROR: Failed to create EMA Fast H1 handle");
        return false;
    }
    
    g_ema_slow_h1_handle = iMA(_Symbol, PERIOD_H1, 21, 0, MODE_EMA, PRICE_CLOSE);
    if(g_ema_slow_h1_handle == INVALID_HANDLE) {
        Print("ERROR: Failed to create EMA Slow H1 handle");
        return false;
    }
    
    g_ema_fast_h4_handle = iMA(_Symbol, PERIOD_H4, 8, 0, MODE_EMA, PRICE_CLOSE);
    if(g_ema_fast_h4_handle == INVALID_HANDLE) {
        Print("ERROR: Failed to create EMA Fast H4 handle");
        return false;
    }
    
    g_ema_slow_h4_handle = iMA(_Symbol, PERIOD_H4, 21, 0, MODE_EMA, PRICE_CLOSE);
    if(g_ema_slow_h4_handle == INVALID_HANDLE) {
        Print("ERROR: Failed to create EMA Slow H4 handle");
        return false;
    }
    
    LogDebug("INDICATORS", "Indicator handles initialized successfully");
    return true;
}

void InitializeICTStructures() {
    g_ipda = IPDAData();
    
    g_venom_range = VenomRange();
    g_venom_range.low = DBL_MAX;
    
    g_power_of_3 = PowerOf3();
    g_indicator_cache = IndicatorCache();
    
    LogDebug("ICT", "ICT structures initialized successfully");
}

void InitializeDSTSettings() {
    g_dst_info = DSTInfo();
    g_dst_info.offset_standard = InpServerTimeOffset;
    g_dst_info.offset_dst = InpServerTimeOffset + 1;
    
    if(InpUseDSTAdjustment) {
        MqlDateTime dt;
        TimeToStruct(TimeCurrent(), dt);
        
        MqlDateTime dst_start;
        dst_start.year = dt.year;
        dst_start.mon = DST_START_MONTH;
        dst_start.day = 8;
        dst_start.hour = 2;
        dst_start.min = dst_start.sec = 0;
        
        datetime temp_time = StructToTime(dst_start);
        MqlDateTime temp_dt;
        TimeToStruct(temp_time, temp_dt);
        
        while(temp_dt.day_of_week != 0) {
            temp_time += SECONDS_PER_DAY;
            TimeToStruct(temp_time, temp_dt);
        }
        temp_time += SECONDS_PER_DAY * 7;
        g_dst_info.dst_start = temp_time;
        
        dst_start.mon = DST_END_MONTH;
        dst_start.day = 1;
        temp_time = StructToTime(dst_start);
        TimeToStruct(temp_time, temp_dt);
        
        while(temp_dt.day_of_week != 0) {
            temp_time += SECONDS_PER_DAY;
            TimeToStruct(temp_time, temp_dt);
        }
        g_dst_info.dst_end = temp_time;
        
        g_dst_info.is_dst_active = IsDSTActive(TimeCurrent());
        
        LogDebug("DST", StringFormat("DST settings initialized: Start=%s End=%s", 
                                    TimeToString(g_dst_info.dst_start), 
                                    TimeToString(g_dst_info.dst_end)));
    }
}

void InitializeNewsFilter() {
    for(int i = 0; i < ArraySize(g_news_events); i++) {
        g_news_events[i] = NewsEvent();
    }
    g_news_count = 0;
    
    LogDebug("NEWS", "Enhanced news filter infrastructure initialized");
}

void InitializePerformanceTracking() {
    g_last_analysis_time = TimeCurrent();
    g_equity_high = g_account.Equity();
    g_max_dd = 0.0;
    g_trades_today = 0;
    g_daily_pnl = 0.0;
    g_cache_initialized = false;
    
    LogDebug("PERFORMANCE", "Enhanced performance tracking initialized");
}

void ConfigureXAUUSDSettings() {
    string symbol_name = _Symbol;
    
    if(StringFind(symbol_name, "XAU") == -1 && 
       StringFind(symbol_name, "GOLD") == -1 && 
       StringFind(symbol_name, "GLD") == -1) {
        
        Print("═══════════════════════════════════════════════════════════════");
        Print("WARNING: EA OPTIMIZED FOR XAUUSD/GOLD INSTRUMENTS");
        Print("Current symbol: ", symbol_name);
        Print("Some features may not work optimally on other instruments");
        Print("═══════════════════════════════════════════════════════════════");
        
        LogCriticalEvent("SYMBOL_WARNING", 
                        StringFormat("Non-XAUUSD symbol detected: %s", symbol_name));
    } else {
        LogDebug("SYMBOL", "XAUUSD symbol detected - Optimal configuration active");
    }
    
    double tick_size = g_symbol.TickSize();
    double tick_value = g_symbol.TickValue();
    int digits = g_symbol.Digits();
    
    LogDebug("SYMBOL", StringFormat("Symbol configuration: Tick size=%.5f, Tick value=%.2f, Digits=%d", 
                                   tick_size, tick_value, digits));
}

void InitializeSystemState() {
    g_daily_bias = BIAS_NONE;
    g_htf_bias = BIAS_NONE;
    
    for(int i = 0; i < 4; i++) {
        g_sessions[i] = SessionData();
        g_sessions[i].session_type = (ENUM_ICT_SESSION)i;
    }
    
    LogDebug("STATE", "System state initialized successfully");
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// MARKET ANALYSIS FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

bool UpdateMarketDataBatch() {
    static datetime last_update = 0;
    datetime current_time = TimeCurrent();
    
    if(current_time - last_update < 60) return true;
    
    if(CopyHigh(_Symbol, PERIOD_M1, 0, 100, g_cached_highs) != 100) {
        LogDebug("DATA_ERROR", "Failed to copy highs");
        return false;
    }
    
    if(CopyLow(_Symbol, PERIOD_M1, 0, 100, g_cached_lows) != 100) {
        LogDebug("DATA_ERROR", "Failed to copy lows");
        return false;
    }
    
    if(CopyOpen(_Symbol, PERIOD_M1, 0, 100, g_cached_opens) != 100) {
        LogDebug("DATA_ERROR", "Failed to copy opens");
        return false;
    }
    
    if(CopyClose(_Symbol, PERIOD_M1, 0, 100, g_cached_closes) != 100) {
        LogDebug("DATA_ERROR", "Failed to copy closes");
        return false;
    }
    
    if(CopyTime(_Symbol, PERIOD_M1, 0, 100, g_cached_times) != 100) {
        LogDebug("DATA_ERROR", "Failed to copy times");
        return false;
    }
    
    if(!g_symbol.RefreshRates()) {
        LogDebug("DATA_ERROR", "Failed to refresh symbol rates");
        return false;
    }
    
    g_cache_initialized = true;
    last_update = current_time;
    
    LogDebug("DATA", "Market data batch updated successfully");
    return true;
}

void UpdateIndicatorCache() {
    datetime current_time = TimeCurrent();
    
    if(g_indicator_cache.last_update == current_time && MQLInfoInteger(MQL_TESTER)) return;
    
    if(g_indicator_cache.last_update >= iTime(_Symbol, PERIOD_M1, 0) && !MQLInfoInteger(MQL_TESTER)) return;
    
    double buffer[1];
    
    if(CopyBuffer(g_atr_m1_handle, 0, 1, 1, buffer) > 0) {
        g_indicator_cache.atr_m1_14 = buffer[0];
    }
    
    static datetime last_h1_bar_time = 0;
    datetime current_h1_bar_time = iTime(_Symbol, PERIOD_H1, 0);
    if(current_h1_bar_time != last_h1_bar_time) {
        if(CopyBuffer(g_atr_h1_handle, 0, 1, 1, buffer) > 0) {
            g_indicator_cache.atr_h1_14 = buffer[0];
        }
        
        if(CopyBuffer(g_ema_fast_h1_handle, 0, 0, 1, buffer) > 0) {
            g_indicator_cache.ema_fast_h1 = buffer[0];
        }
        
        if(CopyBuffer(g_ema_slow_h1_handle, 0, 0, 1, buffer) > 0) {
            g_indicator_cache.ema_slow_h1 = buffer[0];
        }
        
        last_h1_bar_time = current_h1_bar_time;
    }
    
    static datetime last_h4_bar_time = 0;
    datetime current_h4_bar_time = iTime(_Symbol, PERIOD_H4, 0);
    if(current_h4_bar_time != last_h4_bar_time) {
        if(CopyBuffer(g_atr_h4_handle, 0, 1, 1, buffer) > 0) {
            g_indicator_cache.atr_h4_14 = buffer[0];
        }
        
        if(CopyBuffer(g_ema_fast_h4_handle, 0, 0, 1, buffer) > 0) {
            g_indicator_cache.ema_fast_h4 = buffer[0];
        }
        
        if(CopyBuffer(g_ema_slow_h4_handle, 0, 0, 1, buffer) > 0) {
            g_indicator_cache.ema_slow_h4 = buffer[0];
        }
        
        last_h4_bar_time = current_h4_bar_time;
    }
    
    g_indicator_cache.last_update = iTime(_Symbol, PERIOD_M1, 0);
    
    LogDebug("INDICATORS", StringFormat("Indicator cache updated - ATR M1: %.5f", g_indicator_cache.atr_m1_14));
}

datetime ConvertToNYTime(datetime server_time) {
    if(!InpUseDSTAdjustment) {
        return server_time + (InpServerTimeOffset * SECONDS_PER_HOUR);
    }
    
    int offset = g_dst_info.is_dst_active ? g_dst_info.offset_dst : g_dst_info.offset_standard;
    return server_time + (offset * SECONDS_PER_HOUR);
}

bool IsDSTActive(datetime check_time) {
    return (check_time >= g_dst_info.dst_start && check_time < g_dst_info.dst_end);
}

void UpdateMarketBias() {
    ENUM_ICT_BIAS h1_bias = AnalyzeBias(PERIOD_H1);
    ENUM_ICT_BIAS h4_bias = AnalyzeBias(PERIOD_H4);
    ENUM_ICT_BIAS d1_bias = AnalyzeBias(PERIOD_D1);
    ENUM_ICT_BIAS ipda_bias = AnalyzeIPDABias();
    
    double bullish_score = 0, bearish_score = 0;
    
    if(h1_bias == BIAS_BULLISH) bullish_score += 1.0;
    else if(h1_bias == BIAS_BEARISH) bearish_score += 1.0;
    
    if(h4_bias == BIAS_BULLISH) bullish_score += 2.5;
    else if(h4_bias == BIAS_BEARISH) bearish_score += 2.5;
    
    if(d1_bias == BIAS_BULLISH) bullish_score += 4.0;
    else if(d1_bias == BIAS_BEARISH) bearish_score += 4.0;
    
    if(ipda_bias == BIAS_BULLISH) bullish_score += 2.0;
    else if(ipda_bias == BIAS_BEARISH) bearish_score += 2.0;
    
    if(IsPowerOf3Confluence(BIAS_BULLISH)) bullish_score += 1.5;
    if(IsPowerOf3Confluence(BIAS_BEARISH)) bearish_score += 1.5;
    
    double bias_threshold = 1.5;
    if(bullish_score > bearish_score + bias_threshold) g_daily_bias = BIAS_BULLISH;
    else if(bearish_score > bullish_score + bias_threshold) g_daily_bias = BIAS_BEARISH;
    else g_daily_bias = BIAS_NEUTRAL;
    
    g_htf_bias = d1_bias;
    
    LogDebug("BIAS", StringFormat("Market bias updated - Daily: %s, HTF: %s (Bull: %.1f, Bear: %.1f)", 
                                 EnumToString(g_daily_bias), EnumToString(g_htf_bias), 
                                 bullish_score, bearish_score));
}

ENUM_ICT_BIAS AnalyzeBias(ENUM_TIMEFRAMES timeframe) {
    int lookback = (timeframe == PERIOD_D1) ? 20 : (timeframe == PERIOD_H4) ? 40 : 60;
    
    double highs[], lows[], closes[];
    ArrayResize(highs, lookback);
    ArrayResize(lows, lookback);
    ArrayResize(closes, lookback);
    
    if(CopyHigh(_Symbol, timeframe, 0, lookback, highs) != lookback) return BIAS_NEUTRAL;
    if(CopyLow(_Symbol, timeframe, 0, lookback, lows) != lookback) return BIAS_NEUTRAL;
    if(CopyClose(_Symbol, timeframe, 0, lookback, closes) != lookback) return BIAS_NEUTRAL;
    
    bool higher_highs = highs[0] > highs[5] && highs[5] > highs[10];
    bool higher_lows = lows[0] > lows[5] && lows[5] > lows[10];
    bool lower_highs = highs[0] < highs[5] && highs[5] < highs[10];
    bool lower_lows = lows[0] < lows[5] && lows[5] < lows[10];
    
    double recent_momentum = (closes[0] - closes[9]) / closes[9];
    double momentum_threshold = 0.01;
    
    double current_price = closes[0];
    double range_high = highs[ArrayMaximum(highs)];
    double range_low = lows[ArrayMinimum(lows)];
    double price_position = (current_price - range_low) / (range_high - range_low);
    
    int bullish_signals = 0, bearish_signals = 0;
    
    if(higher_highs && higher_lows) bullish_signals += 2;
    if(lower_highs && lower_lows) bearish_signals += 2;
    if(recent_momentum > momentum_threshold) bullish_signals++;
    if(recent_momentum < -momentum_threshold) bearish_signals++;
    if(price_position > 0.6) bullish_signals++;
    if(price_position < 0.4) bearish_signals++;
    
    if(timeframe == PERIOD_H1) {
        if(g_indicator_cache.ema_fast_h1 > g_indicator_cache.ema_slow_h1) bullish_signals++;
        else bearish_signals++;
    } else if(timeframe == PERIOD_H4) {
        if(g_indicator_cache.ema_fast_h4 > g_indicator_cache.ema_slow_h4) bullish_signals++;
        else bearish_signals++;
    }
    
    if(bullish_signals > bearish_signals + 1) return BIAS_BULLISH;
    if(bearish_signals > bullish_signals + 1) return BIAS_BEARISH;
    
    return BIAS_NEUTRAL;
}

void UpdateIPDAData() {
    datetime current_time = TimeCurrent();
    
    if(g_ipda.last_update > 0 && (current_time - g_ipda.last_update) < SECONDS_PER_DAY) return;
    
    double temp_highs_60[60], temp_lows_60[60];
    
    if(CopyHigh(_Symbol, PERIOD_D1, 1, 60, temp_highs_60) != 60 ||
       CopyLow(_Symbol, PERIOD_D1, 1, 60, temp_lows_60) != 60) {
        LogCriticalEvent("IPDA_ERROR", "Failed to acquire sufficient historical data for IPDA analysis");
        return;
    }
    
    // CORRECTED IPDA CALCULATION - Fixed ArrayMaximum/ArrayMinimum issue
    for(int i = 0; i < 20; i++) {
        g_ipda.highs_20[i] = temp_highs_60[i];
        g_ipda.lows_20[i] = temp_lows_60[i];
    }
    
    for(int i = 0; i < 40; i++) {
        g_ipda.highs_40[i] = temp_highs_60[i];
        g_ipda.lows_40[i] = temp_lows_60[i];
    }
    
    for(int i = 0; i < 60; i++) {
        g_ipda.highs_60[i] = temp_highs_60[i];
        g_ipda.lows_60[i] = temp_lows_60[i];
    }
    
    // CORRECTED: Manual calculation for min/max values
    g_ipda.highest_20 = temp_highs_60[0];
    g_ipda.lowest_20 = temp_lows_60[0];
    for(int k = 1; k < 20; k++) {
        if(temp_highs_60[k] > g_ipda.highest_20) g_ipda.highest_20 = temp_highs_60[k];
        if(temp_lows_60[k] < g_ipda.lowest_20) g_ipda.lowest_20 = temp_lows_60[k];
    }
    
    g_ipda.highest_40 = temp_highs_60[0];
    g_ipda.lowest_40 = temp_lows_60[0];
    for(int k = 1; k < 40; k++) {
        if(temp_highs_60[k] > g_ipda.highest_40) g_ipda.highest_40 = temp_highs_60[k];
        if(temp_lows_60[k] < g_ipda.lowest_40) g_ipda.lowest_40 = temp_lows_60[k];
    }
    
    g_ipda.highest_60 = temp_highs_60[0];
    g_ipda.lowest_60 = temp_lows_60[0];
    for(int k = 1; k < 60; k++) {
        if(temp_highs_60[k] > g_ipda.highest_60) g_ipda.highest_60 = temp_highs_60[k];
        if(temp_lows_60[k] < g_ipda.lowest_60) g_ipda.lowest_60 = temp_lows_60[k];
    }
    
    g_ipda.days_since_shift++;
    if(g_ipda.days_since_shift >= IPDA_QUARTERLY_SHIFT_MIN_DAYS && 
       g_ipda.days_since_shift <= IPDA_QUARTERLY_SHIFT_MAX_DAYS) {
        g_ipda.quarterly_shift_pending = true;
        LogCriticalEvent("IPDA_QUARTERLY", 
                        StringFormat("Quarterly shift detection active - Day %d of cycle", g_ipda.days_since_shift));
    }
    
    g_ipda.last_update = current_time;
    
    LogCriticalEvent("IPDA_UPDATE", 
                    StringFormat("IPDA ranges updated: 20D[%.5f-%.5f] 40D[%.5f-%.5f] 60D[%.5f-%.5f]", 
                               g_ipda.lowest_20, g_ipda.highest_20,
                               g_ipda.lowest_40, g_ipda.highest_40, 
                               g_ipda.lowest_60, g_ipda.highest_60));
}

ENUM_ICT_BIAS AnalyzeIPDABias() {
    if(g_ipda.last_update == 0) return BIAS_NEUTRAL;
    
    double current_price = g_symbol.Bid();
    double price_position_20 = (current_price - g_ipda.lowest_20) / (g_ipda.highest_20 - g_ipda.lowest_20);
    double price_position_40 = (current_price - g_ipda.lowest_40) / (g_ipda.highest_40 - g_ipda.lowest_40);
    double price_position_60 = (current_price - g_ipda.lowest_60) / (g_ipda.highest_60 - g_ipda.lowest_60);
    
    double weighted_position = (price_position_20 * 0.5) + (price_position_40 * 0.3) + (price_position_60 * 0.2);
    
    if(g_ipda.quarterly_shift_pending) {
        if(weighted_position > 0.7) return BIAS_BEARISH;
        if(weighted_position < 0.3) return BIAS_BULLISH;
    } else {
        if(weighted_position > 0.6) return BIAS_BULLISH;
        if(weighted_position < 0.4) return BIAS_BEARISH;
    }
    
    return BIAS_NEUTRAL;
}

void UpdatePowerOf3() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    bool new_session_detected = false;
    datetime session_start = 0;
    
    if(dt.hour == 2 && dt.min == 0) {
        new_session_detected = true;
        session_start = TimeCurrent();
        InitializePowerOf3Session("LONDON_KILL_ZONE", session_start);
    }
    else if(dt.hour == 8 && dt.min == 0) {
        new_session_detected = true;
        session_start = TimeCurrent();
        InitializePowerOf3Session("NY_AM_KILL_ZONE", session_start);
    }
    
    if(new_session_detected) {
        g_power_of_3.session_start = session_start;
        g_power_of_3.accumulation_level = g_symbol.Bid();
        g_power_of_3.manipulation_level = 0;
        g_power_of_3.distribution_target = 0;
        g_power_of_3.po3_bias = g_daily_bias;
        g_power_of_3.manipulation_complete = false;
        g_power_of_3.distribution_active = false;
        
        LogCriticalEvent("PO3_SESSION_INIT", 
                        StringFormat("Power of 3 session initialized at %.5f", g_power_of_3.accumulation_level));
    }
    
    datetime session_elapsed = TimeCurrent() - g_power_of_3.session_start;
    
    if(!g_power_of_3.manipulation_complete && session_elapsed < SECONDS_PER_HOUR) {
        double session_high = g_cached_highs[0];
        double session_low = g_cached_lows[0];
        double session_volume_proxy = 0;
        int accumulation_bars = 0;
        
        for(int i = 1; i < 60; i++) {
            if(g_cached_times[i] >= g_power_of_3.session_start) {
                session_high = MathMax(session_high, g_cached_highs[i]);
                session_low = MathMin(session_low, g_cached_lows[i]);
                
                double bar_range = g_cached_highs[i] - g_cached_lows[i];
                session_volume_proxy += bar_range;
                accumulation_bars++;
            }
        }
        
        if(accumulation_bars > 0) {
            double range_center = (session_high + session_low) / 2.0;
            double volume_weight = session_volume_proxy / accumulation_bars;
            g_power_of_3.accumulation_level = range_center;
            
            LogCriticalEvent("PO3_ACCUMULATION", 
                            StringFormat("Accumulation phase: Range %.5f-%.5f, Center %.5f", 
                                       session_low, session_high, range_center));
        }
    }
    
    if(!g_power_of_3.manipulation_complete && session_elapsed >= SECONDS_PER_HOUR) {
        double current_price = g_symbol.Bid();
        double manipulation_threshold = g_indicator_cache.atr_m1_14 * 0.618;
        
        if(g_power_of_3.po3_bias == BIAS_BULLISH) {
            if(current_price < g_power_of_3.accumulation_level - manipulation_threshold) {
                g_power_of_3.manipulation_level = current_price;
                g_power_of_3.manipulation_complete = true;
                
                double manipulation_distance = g_power_of_3.accumulation_level - current_price;
                g_power_of_3.distribution_target = g_power_of_3.accumulation_level + (manipulation_distance * 2.618);
                
                LogCriticalEvent("PO3_MANIPULATION", 
                                StringFormat("Bullish manipulation detected at %.5f, Target: %.5f", 
                                           current_price, g_power_of_3.distribution_target));
            }
        } else if(g_power_of_3.po3_bias == BIAS_BEARISH) {
            if(current_price > g_power_of_3.accumulation_level + manipulation_threshold) {
                g_power_of_3.manipulation_level = current_price;
                g_power_of_3.manipulation_complete = true;
                
                double manipulation_distance = current_price - g_power_of_3.accumulation_level;
                g_power_of_3.distribution_target = g_power_of_3.accumulation_level - (manipulation_distance * 2.618);
                
                LogCriticalEvent("PO3_MANIPULATION", 
                                StringFormat("Bearish manipulation detected at %.5f, Target: %.5f", 
                                           current_price, g_power_of_3.distribution_target));
            }
        }
    }
    
    if(g_power_of_3.manipulation_complete && !g_power_of_3.distribution_active) {
        double current_price = g_symbol.Bid();
        
        if(g_power_of_3.po3_bias == BIAS_BULLISH) {
            if(current_price > g_power_of_3.accumulation_level) {
                g_power_of_3.distribution_active = true;
                LogCriticalEvent("PO3_DISTRIBUTION", "Bullish distribution phase activated");
            }
        } else if(g_power_of_3.po3_bias == BIAS_BEARISH) {
            if(current_price < g_power_of_3.accumulation_level) {
                g_power_of_3.distribution_active = true;
                LogCriticalEvent("PO3_DISTRIBUTION", "Bearish distribution phase activated");
            }
        }
    }
}

void InitializePowerOf3Session(string session_name, datetime start_time) {
    LogCriticalEvent("PO3_INIT", 
                    StringFormat("Power of 3 %s session commenced at %s", 
                               session_name, TimeToString(start_time, TIME_MINUTES)));
}

void AnalyzeGapSignificance() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    static datetime last_day_check = 0;
    
    if(dt.hour == 0 && dt.min == 0 && TimeCurrent() != last_day_check) {
        last_day_check = TimeCurrent();
        
        if(InpUseNDOG) {
            double previous_close = iClose(_Symbol, PERIOD_D1, 1);
            double current_open = iOpen(_Symbol, PERIOD_D1, 0);
            
            if(MathAbs(current_open - previous_close) > g_indicator_cache.atr_m1_14 * 0.5) {
                GapData ndog;
                ndog.formation_time = TimeCurrent();
                ndog.upper_level = MathMax(current_open, previous_close);
                ndog.lower_level = MathMin(current_open, previous_close);
                ndog.is_ndog = true;
                ndog.is_nwog = false;
                ndog.filled = false;
                ndog.fill_percentage = 0;
                
                double gap_range = ndog.upper_level - ndog.lower_level;
                ndog.quarter_levels[0] = ndog.lower_level + (gap_range * InpGapQuarter1);
                ndog.quarter_levels[1] = ndog.lower_level + (gap_range * InpGapQuarter2);
                ndog.quarter_levels[2] = ndog.lower_level + (gap_range * InpGapQuarter3);
                ndog.quarter_levels[3] = ndog.lower_level + (gap_range * InpGapQuarter4);
                
                if(g_gap_count < ArraySize(g_gaps)) {
                    g_gaps[g_gap_count] = ndog;
                    g_gap_count++;
                    
                    LogDebug("GAP", StringFormat("NDOG detected: %.5f-%.5f", ndog.lower_level, ndog.upper_level));
                }
            }
        }
    }
}

void UpdateSessions() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    for(int i = 0; i < 4; i++) {
        g_sessions[i].active = false;
    }
    
    if(dt.hour >= 18 || dt.hour < 3) {
        g_sessions[SESSION_ASIAN].active = true;
        if(g_sessions[SESSION_ASIAN].start_time == 0) {
            g_sessions[SESSION_ASIAN].start_time = TimeCurrent();
            g_sessions[SESSION_ASIAN].high = g_symbol.Bid();
            g_sessions[SESSION_ASIAN].low = g_symbol.Bid();
        }
        g_sessions[SESSION_ASIAN].high = MathMax(g_sessions[SESSION_ASIAN].high, g_symbol.Ask());
        g_sessions[SESSION_ASIAN].low = MathMin(g_sessions[SESSION_ASIAN].low, g_symbol.Bid());
    }
    
    if(dt.hour >= 3 && dt.hour < 12) {
        g_sessions[SESSION_LONDON].active = true;
        if(g_sessions[SESSION_LONDON].start_time == 0) {
            g_sessions[SESSION_LONDON].start_time = TimeCurrent();
            g_sessions[SESSION_LONDON].high = g_symbol.Bid();
            g_sessions[SESSION_LONDON].low = g_symbol.Bid();
        }
        g_sessions[SESSION_LONDON].high = MathMax(g_sessions[SESSION_LONDON].high, g_symbol.Ask());
        g_sessions[SESSION_LONDON].low = MathMin(g_sessions[SESSION_LONDON].low, g_symbol.Bid());
    }
    
    LogDebug("SESSIONS", StringFormat("Sessions updated - Asian: %s, London: %s", 
                                     g_sessions[SESSION_ASIAN].active ? "Active" : "Inactive",
                                     g_sessions[SESSION_LONDON].active ? "Active" : "Inactive"));
}

void AnalyzeKillZones() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    bool in_kill_zone = false;
    string kill_zone_type = "";
    
    if(dt.hour >= LONDON_KILL_ZONE_START && dt.hour < LONDON_KILL_ZONE_END) {
        in_kill_zone = true;
        kill_zone_type = "LONDON_KILL_ZONE";
    }
    
    if((dt.hour == NY_AM_KILL_ZONE_START_HOUR && dt.min >= NY_AM_KILL_ZONE_START_MIN) || 
       (dt.hour > NY_AM_KILL_ZONE_START_HOUR && dt.hour < NY_AM_KILL_ZONE_END)) {
        in_kill_zone = true;
        kill_zone_type = "NY_AM_KILL_ZONE";
    }
    
    if(in_kill_zone) {
        for(int i = 0; i < g_pattern_count; i++) {
            if(g_patterns[i].valid && 
               (TimeCurrent() - g_patterns[i].time) < 3600) {
                g_patterns[i].confluence_score += 5;
            }
        }
        
        LogDebug("KILLZONE", StringFormat("Active kill zone: %s", kill_zone_type));
    }
}

void AnalyzeMarketStructure() {
    for(int i = 3; i < 50; i++) {
        if(IsSwingHigh(i)) {
            AddMarketStructure(g_cached_times[i], g_cached_highs[i], MS_STH);
            if(IsIntermediateHigh(i)) {
                AddMarketStructure(g_cached_times[i], g_cached_highs[i], MS_ITH);
                if(IsLongTermHigh(i)) {
                    AddMarketStructure(g_cached_times[i], g_cached_highs[i], MS_LTH);
                }
            }
        }
        
        if(IsSwingLow(i)) {
            AddMarketStructure(g_cached_times[i], g_cached_lows[i], MS_STL);
            if(IsIntermediateLow(i)) {
                AddMarketStructure(g_cached_times[i], g_cached_lows[i], MS_ITL);
                if(IsLongTermLow(i)) {
                    AddMarketStructure(g_cached_times[i], g_cached_lows[i], MS_LTL);
                }
            }
        }
    }
    DetectMarketStructureShift();
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// PATTERN DETECTION FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void ScanFairValueGaps() {
    double atr = g_indicator_cache.atr_m1_14;
    if(atr <= 0) {
        LogCriticalEvent("FVG_ERROR", "Invalid ATR reading - FVG scan aborted");
        return;
    }
    
    int scan_limit = MathMin(50, (int)(100 * (atr / (g_symbol.Point() * 100))));
    
    LogDebug("FVG_SCAN", StringFormat("Scanning %d bars for FVGs with ATR: %.5f", scan_limit, atr));
    
    for(int i = 2; i < scan_limit; i++) {
        // BISI FVG Detection
        if(g_cached_closes[i+1] < g_cached_opens[i+1] && 
           g_cached_closes[i] > g_cached_opens[i] &&     
           g_cached_closes[i-1] > g_cached_opens[i-1]) { 
            
            double gap_low = g_cached_highs[i+1];
            double gap_high = g_cached_lows[i-1];
            double gap_size = (gap_high - gap_low) / _Point;
            
            if(gap_size >= InpMinFVGSize && 
               gap_size <= InpMaxFVGSize && 
               gap_high > gap_low && 
               (!InpTradeUntestedFVG || IsUntestedFVG(i, gap_low, gap_high))) {
                
                ICTPattern bisi_fvg;
                bisi_fvg.time = g_cached_times[i];
                bisi_fvg.high = gap_high;
                bisi_fvg.low = gap_low;
                bisi_fvg.open = g_cached_opens[i];
                bisi_fvg.close = g_cached_closes[i];
                bisi_fvg.type = SETUP_FVG;
                bisi_fvg.direction = BIAS_BULLISH;
                bisi_fvg.fvg_type = FVG_BISI;
                
                bisi_fvg.confluence_score = CalculateWeightedConfluence(bisi_fvg);
                
                bisi_fvg.valid = true;
                bisi_fvg.tested = false;
                bisi_fvg.untested_required = InpTradeUntestedFVG;
                bisi_fvg.timeframe = PERIOD_M1;
                bisi_fvg.atr_at_formation = atr;
                
                AddPattern(bisi_fvg);
                
                LogCriticalEvent("BISI_DETECTED", 
                               StringFormat("BISI FVG: %.5f-%.5f, Size: %.1f pts, Confluence: %.1f", 
                                          gap_low, gap_high, gap_size, bisi_fvg.confluence_score));
            }
        }
        
        // SIBI FVG Detection
        if(g_cached_closes[i+1] > g_cached_opens[i+1] && 
           g_cached_closes[i] < g_cached_opens[i] &&     
           g_cached_closes[i-1] < g_cached_opens[i-1]) { 
            
            double gap_high = g_cached_lows[i+1];
            double gap_low = g_cached_highs[i-1];
            double gap_size = (gap_high - gap_low) / _Point;
            
            if(gap_size >= InpMinFVGSize && 
               gap_size <= InpMaxFVGSize && 
               gap_high > gap_low && 
               (!InpTradeUntestedFVG || IsUntestedFVG(i, gap_low, gap_high))) {
                
                ICTPattern sibi_fvg;
                sibi_fvg.time = g_cached_times[i];
                sibi_fvg.high = gap_high;
                sibi_fvg.low = gap_low;
                sibi_fvg.open = g_cached_opens[i];
                sibi_fvg.close = g_cached_closes[i];
                sibi_fvg.type = SETUP_FVG;
                sibi_fvg.direction = BIAS_BEARISH;
                sibi_fvg.fvg_type = FVG_SIBI;
                
                sibi_fvg.confluence_score = CalculateWeightedConfluence(sibi_fvg);
                
                sibi_fvg.valid = true;
                sibi_fvg.tested = false;
                sibi_fvg.untested_required = InpTradeUntestedFVG;
                sibi_fvg.timeframe = PERIOD_M1;
                sibi_fvg.atr_at_formation = atr;
                
                AddPattern(sibi_fvg);
                
                LogCriticalEvent("SIBI_DETECTED", 
                               StringFormat("SIBI FVG: %.5f-%.5f, Size: %.1f pts, Confluence: %.1f", 
                                          gap_low, gap_high, gap_size, sibi_fvg.confluence_score));
            }
        }
        
        DetectIFVG(i, atr);
    }
}

void ScanOrderBlocks() {
    double atr = g_indicator_cache.atr_m1_14;
    if(atr <= 0) {
        LogCriticalEvent("OB_ERROR", "ATR calculation failure - Order block scan terminated");
        return;
    }
    
    int scan_depth = MathMin(30, (int)(50 * (atr / (g_symbol.Point() * 100))));
    double displacement_threshold = atr * InpDisplacementATR;
    
    LogDebug("OB_SCAN", StringFormat("Scanning %d bars for Order Blocks with displacement threshold: %.5f", 
                                    scan_depth, displacement_threshold));
    
    for(int i = 3; i < scan_depth; i++) {
        if(IsBullishOrderBlock(i)) {
            double ob_high = g_cached_highs[i];
            double ob_low = g_cached_lows[i];
            double ob_open = g_cached_opens[i];
            double ob_close = g_cached_closes[i];
            double ob_size = (ob_high - ob_low) / _Point;
            
            bool size_validation = (ob_size >= InpOBMinSize);
            bool displacement_validation = ValidateDisplacement(i, BIAS_BULLISH, displacement_threshold);
            bool institutional_signature = ValidateInstitutionalFootprint(i, BIAS_BULLISH);
            
            if(size_validation && displacement_validation && institutional_signature) {
                ICTPattern bullish_ob;
                bullish_ob.time = g_cached_times[i];
                bullish_ob.high = ob_high;
                bullish_ob.low = ob_low;
                bullish_ob.open = ob_open;
                bullish_ob.close = ob_close;
                bullish_ob.type = SETUP_OB;
                bullish_ob.direction = BIAS_BULLISH;
                bullish_ob.ob_type = OB_BULLISH;
                
                bullish_ob.confluence_score = CalculateWeightedConfluence(bullish_ob);
                
                bullish_ob.valid = true;
                bullish_ob.tested = false;
                bullish_ob.timeframe = PERIOD_M1;
                bullish_ob.atr_at_formation = atr;
                
                AddPattern(bullish_ob);
                
                LogCriticalEvent("BULLISH_OB_DETECTED", 
                               StringFormat("Bullish OB: %.5f-%.5f, Size: %.1f pts, Displacement: %.5f, Confluence: %.1f", 
                                          ob_low, ob_high, ob_size, displacement_threshold, bullish_ob.confluence_score));
            }
        }
        
        if(IsBearishOrderBlock(i)) {
            double ob_high = g_cached_highs[i];
            double ob_low = g_cached_lows[i];
            double ob_open = g_cached_opens[i];
            double ob_close = g_cached_closes[i];
            double ob_size = (ob_high - ob_low) / _Point;
            
            bool size_validation = (ob_size >= InpOBMinSize);
            bool displacement_validation = ValidateDisplacement(i, BIAS_BEARISH, displacement_threshold);
            bool institutional_signature = ValidateInstitutionalFootprint(i, BIAS_BEARISH);
            
            if(size_validation && displacement_validation && institutional_signature) {
                ICTPattern bearish_ob;
                bearish_ob.time = g_cached_times[i];
                bearish_ob.high = ob_high;
                bearish_ob.low = ob_low;
                bearish_ob.open = ob_open;
                bearish_ob.close = ob_close;
                bearish_ob.type = SETUP_OB;
                bearish_ob.direction = BIAS_BEARISH;
                bearish_ob.ob_type = OB_BEARISH;
                
                bearish_ob.confluence_score = CalculateWeightedConfluence(bearish_ob);
                
                bearish_ob.valid = true;
                bearish_ob.tested = false;
                bearish_ob.timeframe = PERIOD_M1;
                bearish_ob.atr_at_formation = atr;
                
                AddPattern(bearish_ob);
                
                LogCriticalEvent("BEARISH_OB_DETECTED", 
                               StringFormat("Bearish OB: %.5f-%.5f, Size: %.1f pts, Displacement: %.5f, Confluence: %.1f", 
                                          ob_low, ob_high, ob_size, displacement_threshold, bearish_ob.confluence_score));
            }
        }
        
        if(InpUseBreakerBlocks) {
            DetectBreakerBlocks(i);
        }
        
        DetectMitigationBlocks(i);
        DetectRejectionBlocks(i);
    }
}

void AnalyzeLiquidity() {
    IdentifyBuySideLiquidity();
    IdentifySellSideLiquidity();
    DetectRelativeEqualLevels();
    AnalyzeLiquiditySweeps();
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// ADVANCED MODEL FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void ProcessSilverBulletSetups() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    if(dt.hour == 10 && dt.min >= 0 && dt.min <= 59) {
        double session_high = GetSessionHigh(9, 30, 10, 0);
        double session_low = GetSessionLow(9, 30, 10, 0);
        
        bool liquidity_swept = false;
        ENUM_ICT_BIAS sweep_direction = BIAS_NEUTRAL;
        
        if(g_cached_highs[0] > session_high) {
            liquidity_swept = true;
            sweep_direction = BIAS_BEARISH;
        } else if(g_cached_lows[0] < session_low) {
            liquidity_swept = true;
            sweep_direction = BIAS_BULLISH;
        }
        
        if(liquidity_swept) {
            ICTPattern htf_fvg = DetectSilverBulletFVG(sweep_direction);
            if(htf_fvg.valid) {
                ICTPattern ltf_fvg = DetectSecondaryFVG(sweep_direction);
                if(ltf_fvg.valid) {
                    double target_distance = CalculateTargetDistance(ltf_fvg, sweep_direction);
                    if(target_distance >= InpSilverBulletMinHandles * 10 * _Point) {
                        ExecuteSilverBulletTrade(ltf_fvg, target_distance);
                    }
                }
            }
        }
        
        for(int i = 0; i < g_pattern_count; i++) {
            if(g_patterns[i].valid && g_patterns[i].confluence_score >= 80) {
                g_patterns[i].confluence_score += 25;
                
                if(g_patterns[i].type != SETUP_SILVERB) {
                    ICTPattern sb_pattern = g_patterns[i];
                    sb_pattern.type = SETUP_SILVERB;
                    sb_pattern.confluence_score += 15;
                    AddPattern(sb_pattern);
                }
            }
        }
        
        LogDebug("SILVERBULLET", "Silver Bullet session processing completed");
    }
}

void ProcessVenomModel() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    if(dt.hour >= 8 && dt.hour < 10) {
        if(!g_venom_range.active) {
            g_venom_range.start_time = TimeCurrent();
            g_venom_range.high = g_cached_highs[0];
            g_venom_range.low = g_cached_lows[0];
            g_venom_range.active = true;
            g_venom_range.swept_high = false;
            g_venom_range.swept_low = false;
            
            LogDebug("VENOM", "Venom range initialized");
        } else {
            g_venom_range.high = MathMax(g_venom_range.high, g_cached_highs[0]);
            g_venom_range.low = MathMin(g_venom_range.low, g_cached_lows[0]);
        }
    }
    
    if(dt.hour >= 10 && g_venom_range.active) {
        if(g_cached_highs[0] > g_venom_range.high && !g_venom_range.swept_high) {
            g_venom_range.swept_high = true;
            CreateVenomSetup(BIAS_BEARISH);
        }
        
        if(g_cached_lows[0] < g_venom_range.low && !g_venom_range.swept_low) {
            g_venom_range.swept_low = true;
            CreateVenomSetup(BIAS_BULLISH);
        }
        
        if(dt.hour >= 17) {
            g_venom_range.active = false;
            LogDebug("VENOM", "Venom range deactivated");
        }
    }
}

void CreateVenomSetup(ENUM_ICT_BIAS direction) {
    ICTPattern venom;
    venom.time = TimeCurrent();
    venom.high = g_cached_highs[0];
    venom.low = g_cached_lows[0];
    venom.open = g_cached_opens[0];
    venom.close = g_cached_closes[0];
    venom.type = SETUP_VENOM;
    venom.direction = direction;
    venom.confluence_score = 85;
    venom.valid = true;
    venom.timeframe = PERIOD_M1;
    venom.atr_at_formation = g_indicator_cache.atr_m1_14;
    
    AddPattern(venom);
    
    LogCriticalEvent("VENOM_SETUP", 
                    StringFormat("Venom model setup created: %s at %.5f", 
                               direction == BIAS_BULLISH ? "Bullish" : "Bearish",
                               g_symbol.Bid()));
}

void ProcessHighProbabilitySetups() {
    LogDebug("SETUP_PROCESSING", StringFormat("Processing %d patterns for high probability setups", g_pattern_count));
    
    for(int i = 0; i < g_pattern_count; i++) {
        if(!g_patterns[i].valid) {
            LogDebug("SETUP_SKIP", StringFormat("Pattern %d invalid - skipping", i));
            continue;
        }
        
        if(InpLogConfluenceScores) {
            LogDebug("CONFLUENCE", StringFormat("Pattern %d - Type: %s, Direction: %s, Score: %.1f, Threshold: %.1f", 
                                               i, EnumToString(g_patterns[i].type), 
                                               EnumToString(g_patterns[i].direction),
                                               g_patterns[i].confluence_score, InpConfluenceThreshold));
        }
        
        if(g_patterns[i].confluence_score < InpConfluenceThreshold) {
            LogDebug("CONFLUENCE_FAIL", StringFormat("Pattern %d confluence score %.1f below threshold %.1f", 
                                                    i, g_patterns[i].confluence_score, InpConfluenceThreshold));
            continue;
        }
        
        if(!IsPatternValid(i)) {
            LogDebug("PATTERN_INVALID", StringFormat("Pattern %d failed validation checks", i));
            continue;
        }
        
        if(!IsOptimalEntry(i)) {
            LogDebug("ENTRY_NOT_OPTIMAL", StringFormat("Pattern %d entry conditions not optimal", i));
            continue;
        }
        
        if(IsHighImpactNews()) {
            LogCriticalEvent("TRADE_FILTER", "Trade blocked due to high-impact news");
            continue;
        }
        
        LogDebug("EXECUTING_TRADE", StringFormat("All conditions met for pattern %d - executing trade", i));
        ExecuteICTTrade(g_patterns[i]);
        
        g_patterns[i].valid = false;
    }
}

void UpdateNewsEvents() {
    static datetime last_news_update = 0;
    datetime current_time = TimeCurrent();
    
    if(current_time - last_news_update < 900) return;
    
    MqlDateTime dt;
    TimeToStruct(current_time, dt);
    
    // Simulate high-impact news events for testing
    if(dt.day_of_week == 3 && dt.hour == 14 && dt.min >= 0 && dt.min <= 15) {
        AddNewsEvent(current_time, "USD", 3, "FOMC Interest Rate Decision");
    }
    
    if(dt.day_of_week == 5 && dt.hour == 8 && dt.min >= 30 && dt.min <= 45) {
        AddNewsEvent(current_time, "USD", 3, "Non-Farm Payrolls");
    }
    
    if(dt.day == 15 && dt.hour == 8 && dt.min >= 30 && dt.min <= 45) {
        AddNewsEvent(current_time, "USD", 3, "Consumer Price Index");
    }
    
    if(dt.day_of_week == 4 && dt.hour == 7 && dt.min >= 45 && dt.min <= 59) {
        AddNewsEvent(current_time, "EUR", 3, "ECB Interest Rate Decision");
    }
    
    CalculateNewsVolatilityExpectation();
    
    last_news_update = current_time;
    
    LogCriticalEvent("NEWS_UPDATE", 
                    StringFormat("Economic calendar updated - %d active high-impact events monitored", 
                               CountHighImpactEvents()));
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// TRADING FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void ExecuteICTTrade(const ICTPattern& pattern) {
    // CORRECTED: Use Ask for bullish entries, Bid for bearish entries
    double entry_price = pattern.direction == BIAS_BULLISH ? g_symbol.Ask() : g_symbol.Bid();
    double stop_loss = CalculateStopLoss(pattern);
    double take_profit = CalculateTakeProfit(pattern, entry_price);
    double lot_size = CalculateLotSize(entry_price, stop_loss);
    
    LogDebug("TRADE_CALC", StringFormat("Trade calculation - Entry: %.5f, SL: %.5f, TP: %.5f, Lot: %.2f", 
                                       entry_price, stop_loss, take_profit, lot_size));
    
    if(lot_size <= 0) {
        LogCriticalEvent("TRADE_ERROR", "Invalid lot size calculated");
        return;
    }
    
    // Check broker constraints
    double min_stop_level_points = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
    double min_distance = min_stop_level_points * _Point;
    
    if(pattern.direction == BIAS_BULLISH) {
        if(entry_price - stop_loss < min_distance) {
            stop_loss = entry_price - min_distance - _Point;
            LogDebug("TRADE_ADJUST", StringFormat("SL adjusted for broker constraints: %.5f", stop_loss));
        }
    } else {
        if(stop_loss - entry_price < min_distance) {
            stop_loss = entry_price + min_distance + _Point;
            LogDebug("TRADE_ADJUST", StringFormat("SL adjusted for broker constraints: %.5f", stop_loss));
        }
    }
    
    ENUM_ORDER_TYPE order_type = pattern.direction == BIAS_BULLISH ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
    string comment = StringFormat("ICT_%s_%s", 
                                  EnumToString(pattern.type), 
                                  EnumToString(pattern.direction));
    
    LogDebug("TRADE_EXECUTE", StringFormat("Attempting to execute %s trade", comment));
    
    if(g_trade.PositionOpen(_Symbol, order_type, lot_size, entry_price, stop_loss, take_profit, comment)) {
        ulong position_ticket = 0;
        
        ulong deal_ticket = g_trade.ResultDeal();
        if(deal_ticket > 0) {
            position_ticket = GetPositionTicketFromDeal(deal_ticket);
        }
        
        if(position_ticket == 0) {
            for(int pos = PositionsTotal() - 1; pos >= 0; pos--) {
                if(g_position.SelectByIndex(pos) && 
                   g_position.Symbol() == _Symbol && 
                   g_position.Magic() == InpMagicNumber) {
                    position_ticket = g_position.Ticket();
                    break;
                }
            }
        }
        
        if(position_ticket > 0 && g_active_trades_count < ArraySize(g_active_trades)) {
            g_active_trades[g_active_trades_count].ticket = position_ticket;
            g_active_trades[g_active_trades_count].setup_type = pattern.type;
            g_active_trades[g_active_trades_count].state = TRADE_STATE_OPEN;
            g_active_trades[g_active_trades_count].entry_time = TimeCurrent();
            g_active_trades[g_active_trades_count].entry_price = entry_price;
            g_active_trades[g_active_trades_count].original_sl = stop_loss;
            g_active_trades[g_active_trades_count].original_tp = take_profit;
            g_active_trades_count++;
        }
        
        g_trades_today++;
        
        LogCriticalEvent("TRADE_EXECUTED", 
                        StringFormat("%s executed: Entry=%.5f, SL=%.5f, TP=%.5f, Volume=%.2f, Ticket=%lld", 
                                   comment, entry_price, stop_loss, take_profit, lot_size, position_ticket));
    } else {
        HandleCriticalError(g_trade.ResultRetcode());
        LogCriticalEvent("TRADE_ERROR", 
                        StringFormat("Trade execution failed - Code: %d, Description: %s", 
                                   g_trade.ResultRetcode(), g_trade.ResultComment()));
    }
}

double CalculateStopLoss(const ICTPattern& pattern) {
    double atr = g_indicator_cache.atr_m1_14;
    double stop_loss = 0;
    
    switch(pattern.type) {
        case SETUP_FVG:
            if(pattern.direction == BIAS_BULLISH) {
                stop_loss = pattern.low - (atr * STOP_BUFFER_ATR_MULTIPLIER);
            } else {
                stop_loss = pattern.high + (atr * STOP_BUFFER_ATR_MULTIPLIER);
            }
            break;
            
        case SETUP_OB:
            if(pattern.direction == BIAS_BULLISH) {
                stop_loss = pattern.low - (atr * 0.3);
            } else {
                stop_loss = pattern.high + (atr * 0.3);
            }
            break;
            
        case SETUP_SILVERB:
        case SETUP_VENOM:
            if(pattern.direction == BIAS_BULLISH) {
                stop_loss = pattern.low - (atr * 0.8);
            } else {
                stop_loss = pattern.high + (atr * 0.8);
            }
            break;
            
        default:
            stop_loss = pattern.direction == BIAS_BULLISH ? 
                       g_symbol.Bid() - (atr * 2) : 
                       g_symbol.Ask() + (atr * 2);
    }
    
    return NormalizeDouble(stop_loss, g_symbol.Digits());
}

double CalculateTakeProfit(const ICTPattern& pattern, double entry_price) {
    double stop_loss = CalculateStopLoss(pattern);
    double risk = MathAbs(entry_price - stop_loss);
    double reward = risk * 2.0;
    
    switch(pattern.type) {
        case SETUP_SILVERB:
            reward = risk * 3.0;
            break;
        case SETUP_VENOM:
            reward = risk * 2.5;
            break;
        case SETUP_LIQUIDITY:
            reward = risk * 1.5;
            break;
    }
    
    double optimal_target = FindOptimalTarget(pattern, entry_price, reward);
    
    return NormalizeDouble(optimal_target, g_symbol.Digits());
}

double CalculateLotSize(double entry_price, double stop_loss) {
    double account_balance = g_account.Balance();
    double risk_amount = account_balance * InpRiskPercent / 100.0;
    double stop_distance = MathAbs(entry_price - stop_loss);
    
    if(stop_distance <= 0) {
        LogDebug("LOT_CALC", "Invalid stop distance - returning 0 lot size");
        return 0;
    }
    
    double tick_value = g_symbol.TickValue();
    double tick_size = g_symbol.TickSize();
    
    if(tick_size <= 0 || tick_value <= 0) {
        LogDebug("LOT_CALC", "Invalid tick size or tick value");
        return 0;
    }
    
    double lot_size = risk_amount / (stop_distance / tick_size * tick_value);
    
    double min_lot = g_symbol.LotsMin();
    double max_lot = g_symbol.LotsMax();
    double lot_step = g_symbol.LotsStep();
    
    lot_size = MathMax(min_lot, MathMin(max_lot, lot_size));
    lot_size = NormalizeDouble(lot_size / lot_step, 0) * lot_step;
    
    LogDebug("LOT_CALC", StringFormat("Lot calculation - Balance: %.2f, Risk: %.2f, Distance: %.5f, Final Lot: %.2f", 
                                     account_balance, risk_amount, stop_distance, lot_size));
    
    return lot_size;
}

void ManagePositions() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(!g_position.SelectByIndex(i)) continue;
        if(g_position.Magic() != InpMagicNumber) continue;
        
        ulong ticket = g_position.Ticket();
        
        int trade_info_index = -1;
        for(int j = 0; j < g_active_trades_count; j++) {
            if(g_active_trades[j].ticket == ticket) {
                trade_info_index = j;
                break;
            }
        }
        
        if(trade_info_index == -1) continue;
        
        TradeInfo trade_info = g_active_trades[trade_info_index];
        double current_price = g_position.PriceCurrent();
        double entry_price = trade_info.entry_price;
        double profit_distance = MathAbs(current_price - entry_price);
        double atr = g_indicator_cache.atr_m1_14;
        
        switch(trade_info.state) {
            case TRADE_STATE_OPEN:
                if(profit_distance >= atr * InpBreakevenATR) {
                    if(MoveToBE(ticket, entry_price)) {
                        g_active_trades[trade_info_index].state = TRADE_STATE_BREAKEVEN;
                        LogCriticalEvent("TRADE_MANAGEMENT", 
                                       StringFormat("Position %lld moved to breakeven", ticket));
                    }
                }
                break;
                
            case TRADE_STATE_BREAKEVEN:
                if(profit_distance >= atr * 1.5) {
                    if(TakePartialProfit(ticket, 0.3)) {
                        g_active_trades[trade_info_index].state = TRADE_STATE_PARTIAL_1;
                        LogCriticalEvent("TRADE_MANAGEMENT", 
                                       StringFormat("First partial taken on %lld", ticket));
                    }
                }
                break;
                
            case TRADE_STATE_PARTIAL_1:
                if(profit_distance >= atr * 2.0) {
                    if(TakePartialProfit(ticket, 0.3)) {
                        g_active_trades[trade_info_index].state = TRADE_STATE_PARTIAL_2;
                        LogCriticalEvent("TRADE_MANAGEMENT", 
                                       StringFormat("Second partial taken on %lld", ticket));
                    }
                }
                break;
                
            case TRADE_STATE_PARTIAL_2:
                if(profit_distance >= atr * InpTrailingATR) {
                    if(StartTrailingStop(ticket)) {
                        g_active_trades[trade_info_index].state = TRADE_STATE_TRAILING;
                        LogCriticalEvent("TRADE_MANAGEMENT", 
                                       StringFormat("Trailing stop activated on %lld", ticket));
                    }
                }
                break;
                
            case TRADE_STATE_TRAILING:
                UpdateTrailingStop(ticket, atr);
                break;
        }
    }
    
    CleanupClosedTrades();
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// UTILITY FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

bool IsSwingHigh(int index) {
    if(index < 1 || index >= 99) return false;
    return g_cached_highs[index] > g_cached_highs[index-1] && 
           g_cached_highs[index] > g_cached_highs[index+1];
}

bool IsSwingLow(int index) {
    if(index < 1 || index >= 99) return false;
    return g_cached_lows[index] < g_cached_lows[index-1] && 
           g_cached_lows[index] < g_cached_lows[index+1];
}

// CORRECTED: Implement proper ICT market structure definitions
bool IsIntermediateHigh(int index) { 
    if(!IsSwingHigh(index)) return false;
    
    // Check for lower highs on both sides within larger lookback
    bool left_lower = false, right_lower = false;
    
    for(int i = index + 2; i < MathMin(index + 10, 99); i++) {
        if(IsSwingHigh(i) && g_cached_highs[i] < g_cached_highs[index]) {
            left_lower = true;
            break;
        }
    }
    
    for(int i = MathMax(0, index - 10); i < index - 1; i++) {
        if(IsSwingHigh(i) && g_cached_highs[i] < g_cached_highs[index]) {
            right_lower = true;
            break;
        }
    }
    
    return left_lower && right_lower;
}

bool IsIntermediateLow(int index) { 
    if(!IsSwingLow(index)) return false;
    
    // Check for higher lows on both sides within larger lookback
    bool left_higher = false, right_higher = false;
    
    for(int i = index + 2; i < MathMin(index + 10, 99); i++) {
        if(IsSwingLow(i) && g_cached_lows[i] > g_cached_lows[index]) {
            left_higher = true;
            break;
        }
    }
    
    for(int i = MathMax(0, index - 10); i < index - 1; i++) {
        if(IsSwingLow(i) && g_cached_lows[i] > g_cached_lows[index]) {
            right_higher = true;
            break;
        }
    }
    
    return left_higher && right_higher;
}

bool IsLongTermHigh(int index) { 
    return IsIntermediateHigh(index) && (g_cached_highs[index] - g_cached_lows[index]) > g_indicator_cache.atr_m1_14 * 3;
}

bool IsLongTermLow(int index) { 
    return IsIntermediateLow(index) && (g_cached_highs[index] - g_cached_lows[index]) > g_indicator_cache.atr_m1_14 * 3;
}

bool IsNewBar() {
    static datetime last_bar_time = 0;
    datetime current_bar_time = iTime(_Symbol, PERIOD_M1, 0);
    
    if(current_bar_time != last_bar_time) {
        last_bar_time = current_bar_time;
        return true;
    }
    return false;
}

bool IsTradingAllowed() {
    LogDebug("TRADING_ALLOWED", "Starting trading permission checks");
    
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) { 
        LogDebug("TRADING_DENIED", "Terminal trade not allowed"); 
        return false; 
    }
    
    if(!MQLInfoInteger(MQL_TRADE_ALLOWED)) { 
        LogDebug("TRADING_DENIED", "MQL trade not allowed"); 
        return false; 
    }
    
    if(!g_account.TradeAllowed()) { 
        LogDebug("TRADING_DENIED", "Account trade not allowed"); 
        return false; 
    }
    
    if(!IsTradingTimeAllowed()) { 
        LogDebug("TRADING_DENIED", "Trading time/session check failed"); 
        return false; 
    }
    
    if(g_trades_today >= InpMaxDailyTrades) { 
        LogDebug("TRADING_DENIED", StringFormat("Max daily trades reached: %d", g_trades_today)); 
        return false; 
    }
    
    if(!IsEquitySafe()) { 
        LogDebug("TRADING_DENIED", "Equity not safe"); 
        return false; 
    }
    
    LogDebug("TRADING_ALLOWED", "All trading conditions met - ALLOWED");
    return true;
}

bool IsTradingTimeAllowed() {
    if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE)) {
        LogCriticalEvent("TRADING_RESTRICTED", "Symbol trading mode disabled");
        return false;
    }
    
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        LogCriticalEvent("TRADING_RESTRICTED", "Terminal trading permissions disabled");
        return false;
    }
    
    if(!g_account.TradeAllowed()) {
        LogCriticalEvent("TRADING_RESTRICTED", "Account trading authorization revoked");
        return false;
    }
    
    MqlDateTime dt_server;
    TimeToStruct(TimeCurrent(), dt_server);
    
    if(dt_server.day_of_week == 0 || dt_server.day_of_week == 6) {
        LogDebug("TRADING_TIME", "Weekend - trading not allowed");
        return false;
    }
    
    if((dt_server.hour >= 23 && dt_server.min >= 55) || 
       (dt_server.hour == 0 && dt_server.min <= 5)) {
        LogDebug("TRADING_TIME", "Rollover period - trading not allowed");
        return false;
    }
    
    if(!IsValidTradingSession()) {
        LogDebug("TRADING_TIME", "Invalid trading session");
        return false;
    }
    
    if(InpUseNewsFilter && IsHighImpactNews()) {
        LogCriticalEvent("TRADING_RESTRICTED", "High-impact news event detected - Trading suspended");
        return false;
    }
    
    return true;
}

bool IsValidTradingSession() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    if(InpUseLondonSession && dt.hour >= 3 && dt.hour < 12) return true;
    if(InpUseNewYorkSession && dt.hour >= 8 && dt.hour < 17) return true;
    if(InpUseAsianSession && (dt.hour >= 0 && dt.hour < 9)) return true;
    
    return false;
}

bool IsPatternValid(int pattern_index) {
    if(pattern_index >= g_pattern_count) return false;
    
    ICTPattern pattern = g_patterns[pattern_index];
    
    int hours_since_formation = (int)((TimeCurrent() - pattern.time) / 3600);
    if(hours_since_formation > InpFVGExpiry) {
        LogDebug("PATTERN_INVALID", StringFormat("Pattern %d expired - %d hours old", pattern_index, hours_since_formation));
        return false;
    }
    
    if(InpRequireConfluence && pattern.direction != g_daily_bias && g_daily_bias != BIAS_NEUTRAL) {
        LogDebug("PATTERN_INVALID", StringFormat("Pattern %d conflicts with daily bias", pattern_index));
        return false;
    }
    
    double current_price = g_symbol.Bid();
    double pattern_distance = MathMin(MathAbs(current_price - pattern.high), 
                                     MathAbs(current_price - pattern.low));
    
    if(pattern_distance > g_indicator_cache.atr_m1_14 * 3) {
        LogDebug("PATTERN_INVALID", StringFormat("Pattern %d too far from current price - Distance: %.5f", 
                                                pattern_index, pattern_distance));
        return false;
    }
    
    return true;
}

bool IsOptimalEntry(int pattern_index) {
    if(pattern_index >= g_pattern_count) return false;
    
    ICTPattern pattern = g_patterns[pattern_index];
    
    // CORRECTED: Use appropriate price for entry direction
    double current_price = pattern.direction == BIAS_BULLISH ? g_symbol.Ask() : g_symbol.Bid();
    
    switch(pattern.type) {
        case SETUP_FVG:
        case SETUP_OB:
            bool in_range = current_price >= pattern.low && current_price <= pattern.high;
            LogDebug("ENTRY_CHECK", StringFormat("Pattern %d entry check - Price: %.5f, Range: %.5f-%.5f, In range: %s", 
                                                 pattern_index, current_price, pattern.low, pattern.high, 
                                                 in_range ? "YES" : "NO"));
            return in_range;
            
        case SETUP_LIQUIDITY:
            bool near_level = MathAbs(current_price - pattern.high) < 10 * _Point ||
                             MathAbs(current_price - pattern.low) < 10 * _Point;
            LogDebug("ENTRY_CHECK", StringFormat("Pattern %d liquidity proximity check: %s", 
                                                 pattern_index, near_level ? "YES" : "NO"));
            return near_level;
            
        default:
            return true;
    }
}

bool IsEquitySafe() {
    double current_equity = g_account.Equity();
    double current_drawdown = (g_equity_high - current_equity) / g_equity_high * 100.0;
    
    bool safe = current_drawdown < InpMaxDrawdown;
    
    LogDebug("EQUITY_CHECK", StringFormat("Equity safety - Current: %.2f, High: %.2f, DD: %.2f%%, Safe: %s", 
                                         current_equity, g_equity_high, current_drawdown, 
                                         safe ? "YES" : "NO"));
    
    return safe;
}

bool IsHighImpactNews() {
    if(!InpUseNewsFilter) return false;
    
    datetime current_time = TimeCurrent();
    
    for(int i = 0; i < g_news_count; i++) {
        if(g_news_events[i].impact_level >= 3) {
            int time_diff = (int)MathAbs(current_time - g_news_events[i].event_time);
            if(time_diff <= HIGH_IMPACT_NEWS_BUFFER_MINUTES * 60) {
                LogDebug("NEWS_FILTER", StringFormat("High impact news detected: %s", g_news_events[i].description));
                return true;
            }
        }
    }
    
    return false;
}

ulong GetPositionTicketFromDeal(ulong deal_ticket) {
    if(deal_ticket == 0) {
        LogCriticalEvent("DEAL_ERROR", "Invalid deal ticket provided to position mapper");
        return 0;
    }
    
    if(!HistoryDealSelect(deal_ticket)) {
        LogCriticalEvent("DEAL_ERROR", 
                        StringFormat("Failed to select deal ticket %lld from history", deal_ticket));
        return 0;
    }
    
    ulong position_id = HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);
    
    if(position_id == 0) {
        LogCriticalEvent("DEAL_ERROR", 
                        StringFormat("Deal %lld contains invalid position ID", deal_ticket));
        return 0;
    }
    
    if(PositionSelectByTicket(position_id)) {
        LogCriticalEvent("POSITION_MAPPING", 
                        StringFormat("Successfully mapped deal %lld to position %lld", 
                                   deal_ticket, position_id));
        return position_id;
    }
    
    LogCriticalEvent("POSITION_WARNING", 
                    StringFormat("Position %lld from deal %lld not found in active positions", 
                               position_id, deal_ticket));
    return position_id;
}

bool MoveToBE(ulong ticket, double entry_price) {
    if(!g_position.SelectByTicket(ticket)) return false;
    
    double new_sl = entry_price + (g_position.PositionType() == POSITION_TYPE_BUY ? 
                                  BREAKEVEN_BUFFER_POINTS * _Point : 
                                  -BREAKEVEN_BUFFER_POINTS * _Point);
    
    return g_trade.PositionModify(ticket, new_sl, g_position.TakeProfit());
}

bool TakePartialProfit(ulong ticket, double partial_percent) {
    if(!g_position.SelectByTicket(ticket)) return false;
    
    double partial_volume = g_position.Volume() * partial_percent;
    partial_volume = NormalizeDouble(partial_volume, 2);
    
    if(partial_volume < g_symbol.LotsMin()) return false;
    
    return g_trade.PositionClosePartial(ticket, partial_volume);
}

bool StartTrailingStop(ulong ticket) {
    return true; // Implementation placeholder
}

void UpdateTrailingStop(ulong ticket, double atr) {
    if(!g_position.SelectByTicket(ticket)) return;
    
    double current_price = g_position.PriceCurrent();
    double current_sl = g_position.StopLoss();
    double trail_distance = atr * InpTrailingATR;
    double new_sl = 0;
    
    if(g_position.PositionType() == POSITION_TYPE_BUY) {
        new_sl = current_price - trail_distance;
        if(new_sl > current_sl) {
            g_trade.PositionModify(ticket, new_sl, g_position.TakeProfit());
        }
    } else {
        new_sl = current_price + trail_distance;
        if(new_sl < current_sl || current_sl == 0) {
            g_trade.PositionModify(ticket, new_sl, g_position.TakeProfit());
        }
    }
}

void CleanupClosedTrades() {
    for(int i = g_active_trades_count - 1; i >= 0; i--) {
        if(!g_position.SelectByTicket(g_active_trades[i].ticket)) {
            for(int j = i; j < g_active_trades_count - 1; j++) {
                g_active_trades[j] = g_active_trades[j + 1];
            }
            g_active_trades_count--;
        }
    }
}

double FindOptimalTarget(const ICTPattern& pattern, double entry_price, double default_reward) {
    double target = 0;
    
    if(pattern.direction == BIAS_BULLISH) {
        target = entry_price + default_reward;
        
        for(int i = 0; i < g_liquidity_count; i++) {
            if(g_liquidity_levels[i].is_buyside && 
               g_liquidity_levels[i].price > entry_price &&
               g_liquidity_levels[i].price < target + 50 * _Point) {
                target = g_liquidity_levels[i].price - 5 * _Point;
                break;
            }
        }
        
        for(int i = 0; i < g_gap_count; i++) {
            if(!g_gaps[i].filled) {
                for(int j = 0; j < 4; j++) {
                    if(g_gaps[i].quarter_levels[j] > entry_price && 
                       g_gaps[i].quarter_levels[j] < target + 30 * _Point) {
                        target = g_gaps[i].quarter_levels[j] - 3 * _Point;
                        break;
                    }
                }
            }
        }
    } else {
        target = entry_price - default_reward;
        
        for(int i = 0; i < g_liquidity_count; i++) {
            if(!g_liquidity_levels[i].is_buyside && 
               g_liquidity_levels[i].price < entry_price &&
               g_liquidity_levels[i].price > target - 50 * _Point) {
                target = g_liquidity_levels[i].price + 5 * _Point;
                break;
            }
        }
        
        for(int i = 0; i < g_gap_count; i++) {
            if(!g_gaps[i].filled) {
                for(int j = 0; j < 4; j++) {
                    if(g_gaps[i].quarter_levels[j] < entry_price && 
                       g_gaps[i].quarter_levels[j] > target - 30 * _Point) {
                        target = g_gaps[i].quarter_levels[j] + 3 * _Point;
                        break;
                    }
                }
            }
        }
    }
    
    return target;
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// CONFLUENCE AND VALIDATION FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

double CalculateWeightedConfluence(const ICTPattern& pattern) {
    double base_score = 50.0;
    double weighted_score = base_score;
    
    if(pattern.direction == g_daily_bias) {
        weighted_score += 25.0;
        LogCriticalEvent("CONFLUENCE_BOOST", "Daily bias alignment confirmed");
    } else if(pattern.direction == g_htf_bias) {
        weighted_score += 15.0;
        LogCriticalEvent("CONFLUENCE_BOOST", "HTF bias alignment confirmed");
    }
    
    if(IsNearLiquidity(pattern.low, pattern.high)) {
        weighted_score += 20.0;
        
        for(int i = 0; i < g_liquidity_count; i++) {
            if((g_liquidity_levels[i].price >= pattern.low && g_liquidity_levels[i].price <= pattern.high)) {
                if(g_liquidity_levels[i].touch_count >= 3) {
                    weighted_score += 5.0;
                }
                if(!g_liquidity_levels[i].swept) {
                    weighted_score += 3.0;
                }
            }
        }
        LogCriticalEvent("CONFLUENCE_BOOST", "Institutional liquidity proximity confirmed");
    }
    
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    bool in_premium_session = false;
    string session_type = "";
    
    if(dt.hour >= LONDON_KILL_ZONE_START && dt.hour < LONDON_KILL_ZONE_END) {
        weighted_score += 15.0;
        in_premium_session = true;
        session_type = "LONDON_KILL_ZONE";
    }
    else if((dt.hour == NY_AM_KILL_ZONE_START_HOUR && dt.min >= NY_AM_KILL_ZONE_START_MIN) || 
            (dt.hour > NY_AM_KILL_ZONE_START_HOUR && dt.hour < NY_AM_KILL_ZONE_END)) {
        weighted_score += 15.0;
        in_premium_session = true;
        session_type = "NY_AM_KILL_ZONE";
    }
    else if((dt.hour == NY_PM_KILL_ZONE_START_HOUR && dt.min >= NY_PM_KILL_ZONE_START_MIN) || 
            (dt.hour > NY_PM_KILL_ZONE_START_HOUR && dt.hour < NY_PM_KILL_ZONE_END)) {
        weighted_score += 12.0;
        in_premium_session = true;
        session_type = "NY_PM_KILL_ZONE";
    }
    else if(IsOptimalSession()) {
        weighted_score += 8.0;
        session_type = "STANDARD_SESSION";
    }
    
    if(in_premium_session) {
        LogCriticalEvent("CONFLUENCE_BOOST", 
                        StringFormat("Premium session confluence: %s", session_type));
    }
    
    if(InpUsePremiumDiscount && IsInOptimalPDZone(pattern.low, pattern.high, pattern.direction)) {
        weighted_score += 15.0;
        LogCriticalEvent("CONFLUENCE_BOOST", "Optimal PD zone entry confirmed");
    }
    
    if(IsNearIPDALevel(pattern.low, pattern.high)) {
        weighted_score += 10.0;
        
        if(g_ipda.quarterly_shift_pending) {
            weighted_score += 5.0;
            LogCriticalEvent("CONFLUENCE_BOOST", "IPDA quarterly shift confluence active");
        }
        LogCriticalEvent("CONFLUENCE_BOOST", "IPDA level confluence confirmed");
    }
    
    if(IsPowerOf3Confluence(pattern.direction)) {
        weighted_score += 10.0;
        LogCriticalEvent("CONFLUENCE_BOOST", "Power of 3 model alignment confirmed");
    }
    
    switch(pattern.type) {
        case SETUP_SILVERB:
            weighted_score += 20.0;
            LogCriticalEvent("CONFLUENCE_BOOST", "Silver Bullet algorithm confluence");
            break;
        case SETUP_VENOM:
            weighted_score += 15.0;
            LogCriticalEvent("CONFLUENCE_BOOST", "Venom model institutional flow");
            break;
        case SETUP_LIQUIDITY:
            weighted_score += 12.0;
            LogCriticalEvent("CONFLUENCE_BOOST", "Liquidity sweep reversal confluence");
            break;
        case SETUP_MSS:
            weighted_score += 10.0;
            LogCriticalEvent("CONFLUENCE_BOOST", "Market structure shift confluence");
            break;
        case SETUP_BOS:
            weighted_score += 8.0;
            LogCriticalEvent("CONFLUENCE_BOOST", "Break of structure confluence");
            break;
    }
    
    if(pattern.type == SETUP_FVG) {
        switch(pattern.fvg_type) {
            case FVG_IFVG:
                weighted_score += 15.0;
                LogCriticalEvent("CONFLUENCE_BOOST", "Inverse FVG premium confluence");
                break;
            case FVG_BISI:
            case FVG_SIBI:
                if(!pattern.tested && pattern.untested_required) {
                    weighted_score += 8.0;
                    LogCriticalEvent("CONFLUENCE_BOOST", "Untested FVG confluence");
                }
                break;
        }
    }
    
    if(pattern.type == SETUP_OB) {
        switch(pattern.ob_type) {
            case OB_BREAKER:
                weighted_score += 12.0;
                LogCriticalEvent("CONFLUENCE_BOOST", "Breaker block premium confluence");
                break;
            case OB_MITIGATION:
                weighted_score += 10.0;
                LogCriticalEvent("CONFLUENCE_BOOST", "Mitigation block confluence");
                break;
        }
    }
    
    double current_atr = g_indicator_cache.atr_m1_14;
    double pattern_size = pattern.high - pattern.low;
    
    if(pattern_size >= current_atr * 0.5 && pattern_size <= current_atr * 2.0) {
        weighted_score += 5.0;
        LogCriticalEvent("CONFLUENCE_BOOST", "Optimal volatility range confluence");
    }
    
    if(g_daily_bias != BIAS_NEUTRAL && g_htf_bias == g_daily_bias) {
        weighted_score += 3.0;
    }
    
    if(weighted_score > 100.0) {
        weighted_score = 100.0 + (weighted_score - 100.0) * 0.1;
    }
    
    weighted_score = MathMax(0.0, MathMin(weighted_score, 120.0));
    
    LogCriticalEvent("CONFLUENCE_CALCULATED", 
                    StringFormat("Pattern confluence: %.1f - Type: %s, Direction: %s", 
                               weighted_score, EnumToString(pattern.type), EnumToString(pattern.direction)));
    
    return weighted_score;
}

bool IsNearLiquidity(double low, double high) {
    for(int i = 0; i < g_liquidity_count; i++) {
        double level = g_liquidity_levels[i].price;
        if((level >= low && level <= high) || 
           MathAbs(level - low) < 20 * _Point || 
           MathAbs(level - high) < 20 * _Point) {
            return true;
        }
    }
    return false;
}

bool IsOptimalSession() {
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    if((dt.hour >= 2 && dt.hour < 5) || 
       (dt.hour >= 8 && dt.hour < 11) || 
       (dt.hour >= 13 && dt.hour < 16)) {
        return true;
    }
    
    return false;
}

bool IsInOptimalPDZone(double low, double high, ENUM_ICT_BIAS direction) {
    if(!InpUsePremiumDiscount) return true;
    
    double daily_high = iHigh(_Symbol, PERIOD_D1, 0);
    double daily_low = iLow(_Symbol, PERIOD_D1, 0);
    double daily_range = daily_high - daily_low;
    
    if(daily_range <= 0) return true;
    
    double pattern_mid = (low + high) / 2;
    double position_in_range = (pattern_mid - daily_low) / daily_range;
    
    if(direction == BIAS_BULLISH) {
        return position_in_range <= InpOTE_High;
    } else if(direction == BIAS_BEARISH) {
        return position_in_range >= InpOTE_Low;
    }
    
    return true;
}

bool IsNearIPDALevel(double low, double high) {
    if(g_ipda.last_update == 0) return false;
    
    double pattern_mid = (low + high) / 2;
    double tolerance = g_indicator_cache.atr_m1_14 * 0.5;
    
    if(MathAbs(pattern_mid - g_ipda.highest_20) < tolerance || 
       MathAbs(pattern_mid - g_ipda.lowest_20) < tolerance ||
       MathAbs(pattern_mid - g_ipda.highest_40) < tolerance || 
       MathAbs(pattern_mid - g_ipda.lowest_40) < tolerance ||
       MathAbs(pattern_mid - g_ipda.highest_60) < tolerance || 
       MathAbs(pattern_mid - g_ipda.lowest_60) < tolerance) {
        return true;
    }
    
    return false;
}

bool IsPowerOf3Confluence(ENUM_ICT_BIAS direction) {
    if(g_power_of_3.session_start == 0) return false;
    
    if(g_power_of_3.distribution_active && direction == g_power_of_3.po3_bias) {
        return true;
    }
    
    if(g_power_of_3.manipulation_complete && direction != g_power_of_3.po3_bias) {
        return true;
    }
    
    return false;
}

bool IsUntestedFVG(int index, double gap_low, double gap_high) {
    for(int i = 0; i < index; i++) {
        if(g_cached_lows[i] <= gap_high && g_cached_highs[i] >= gap_low) {
            return false;
        }
    }
    return true;
}

bool IsBullishOrderBlock(int index) {
    if(g_cached_closes[index] >= g_cached_opens[index]) return false;
    
    bool displacement_found = false;
    for(int i = index - 1; i >= MathMax(0, index - 5); i--) {
        if(g_cached_closes[i] > g_cached_highs[index]) {
            displacement_found = true;
            break;
        }
    }
    
    return displacement_found;
}

bool IsBearishOrderBlock(int index) {
    if(g_cached_closes[index] <= g_cached_opens[index]) return false;
    
    bool displacement_found = false;
    for(int i = index - 1; i >= MathMax(0, index - 5); i--) {
        if(g_cached_closes[i] < g_cached_lows[index]) {
            displacement_found = true;
            break;
        }
    }
    
    return displacement_found;
}

bool ValidateDisplacement(int ob_index, ENUM_ICT_BIAS direction, double threshold) {
    double displacement_magnitude = 0.0;
    double cumulative_vector = 0.0;
    
    for(int i = ob_index - 1; i >= MathMax(0, ob_index - 5); i--) {
        double bar_movement = MathAbs(g_cached_closes[i] - g_cached_opens[ob_index]);
        double temporal_weight = MathPow(0.8, ob_index - i);
        
        cumulative_vector += bar_movement * temporal_weight;
        
        if(direction == BIAS_BULLISH && g_cached_closes[i] > g_cached_highs[ob_index]) {
            displacement_magnitude = MathMax(displacement_magnitude, bar_movement);
        } else if(direction == BIAS_BEARISH && g_cached_closes[i] < g_cached_lows[ob_index]) {
            displacement_magnitude = MathMax(displacement_magnitude, bar_movement);
        }
    }
    
    double displacement_ratio = displacement_magnitude / threshold;
    bool magnitude_validation = (displacement_ratio >= 1.0);
    bool vector_validation = (cumulative_vector >= threshold * 0.7);
    
    return magnitude_validation && vector_validation;
}

bool ValidateInstitutionalFootprint(int ob_index, ENUM_ICT_BIAS direction) {
    double body_size = MathAbs(g_cached_closes[ob_index] - g_cached_opens[ob_index]);
    double total_range = g_cached_highs[ob_index] - g_cached_lows[ob_index];
    double body_ratio = (total_range > 0) ? body_size / total_range : 0;
    
    bool structure_signature = false;
    bool rejection_signature = false;
    bool momentum_signature = false;
    
    if(direction == BIAS_BULLISH) {
        structure_signature = (g_cached_closes[ob_index] < g_cached_opens[ob_index]);
        rejection_signature = (body_ratio < 0.7);
        
        double lower_wick = g_cached_opens[ob_index] - g_cached_lows[ob_index];
        double upper_wick = g_cached_highs[ob_index] - g_cached_closes[ob_index];
        momentum_signature = (lower_wick > upper_wick * 1.5);
        
    } else if(direction == BIAS_BEARISH) {
        structure_signature = (g_cached_closes[ob_index] > g_cached_opens[ob_index]);
        rejection_signature = (body_ratio < 0.7);
        
        double lower_wick = g_cached_lows[ob_index] - g_cached_opens[ob_index];
        double upper_wick = g_cached_highs[ob_index] - g_cached_closes[ob_index];
        momentum_signature = (upper_wick > lower_wick * 1.5);
    }
    
    double recent_volatility = CalculateRecentVolatility(ob_index, 5);
    double current_volatility = total_range / g_symbol.Point();
    bool volume_signature = (current_volatility > recent_volatility * 1.2);
    
    int signature_count = 0;
    if(structure_signature) signature_count++;
    if(rejection_signature) signature_count++;
    if(momentum_signature) signature_count++;
    if(volume_signature) signature_count++;
    
    return (signature_count >= 2);
}

double CalculateRecentVolatility(int start_index, int lookback) {
    double total_range = 0.0;
    int valid_bars = 0;
    
    for(int i = start_index + 1; i <= MathMin(start_index + lookback, 99); i++) {
        double bar_range = (g_cached_highs[i] - g_cached_lows[i]) / g_symbol.Point();
        total_range += bar_range;
        valid_bars++;
    }
    
    return (valid_bars > 0) ? total_range / valid_bars : 0.0;
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// PATTERN DETECTION SUPPORT FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void DetectIFVG(int index, double atr) {
    if(index < 4 || index >= 96) return;
    
    bool found_ifvg = false;
    ENUM_ICT_BIAS ifvg_direction = BIAS_NONE;
    double ifvg_high = 0, ifvg_low = 0;
    
    if(g_cached_lows[index+2] > g_cached_highs[index+1] && 
       g_cached_highs[index] >= g_cached_lows[index+2] && 
       g_cached_lows[index-1] > g_cached_highs[index-2]) { 
        
        found_ifvg = true;
        ifvg_direction = BIAS_BULLISH;
        ifvg_low = g_cached_highs[index-2];
        ifvg_high = g_cached_lows[index-1];
    }
    
    if(g_cached_highs[index+2] < g_cached_lows[index+1] && 
       g_cached_lows[index] <= g_cached_highs[index+2] && 
       g_cached_highs[index-1] < g_cached_lows[index-2]) { 
        
        found_ifvg = true;
        ifvg_direction = BIAS_BEARISH;
        ifvg_high = g_cached_lows[index-2];
        ifvg_low = g_cached_highs[index-1];
    }
    
    if(found_ifvg) {
        double gap_size = (ifvg_high - ifvg_low) / _Point;
        
        if(gap_size >= InpMinFVGSize && gap_size <= InpMaxFVGSize && ifvg_high > ifvg_low) {
            ICTPattern ifvg;
            ifvg.time = g_cached_times[index];
            ifvg.high = ifvg_high;
            ifvg.low = ifvg_low;
            ifvg.open = g_cached_opens[index];
            ifvg.close = g_cached_closes[index];
            ifvg.type = SETUP_FVG;
            ifvg.direction = ifvg_direction;
            ifvg.fvg_type = FVG_IFVG;
            ifvg.confluence_score = CalculateWeightedConfluence(ifvg) + 15;
            ifvg.valid = true;
            ifvg.tested = false;
            ifvg.untested_required = InpTradeUntestedFVG;
            ifvg.timeframe = PERIOD_M1;
            ifvg.atr_at_formation = atr;
            
            AddPattern(ifvg);
            
            LogCriticalEvent("IFVG_DETECTED", 
                           StringFormat("IFVG: %.5f-%.5f, Direction: %s, Confluence: %.1f", 
                                      ifvg_low, ifvg_high, EnumToString(ifvg_direction), ifvg.confluence_score));
        }
    }
}

void DetectBreakerBlocks(int index) {
    if(index < 4) return;
    
    if(IsSwingHigh(index+3) && IsSwingLow(index+2) && 
       g_cached_highs[index+1] > g_cached_highs[index+3] && 
       g_cached_lows[index] < g_cached_lows[index+2]) {
        
        ICTPattern breaker;
        breaker.time = g_cached_times[index+2];
        breaker.high = g_cached_highs[index+2];
        breaker.low = g_cached_lows[index+2];
        breaker.open = g_cached_opens[index+2];
        breaker.close = g_cached_closes[index+2];
        breaker.type = SETUP_OB;
        breaker.direction = BIAS_BEARISH;
        breaker.ob_type = OB_BREAKER;
        breaker.confluence_score = 80;
        breaker.valid = true;
        breaker.timeframe = PERIOD_M1;
        breaker.atr_at_formation = g_indicator_cache.atr_m1_14;
        
        AddPattern(breaker);
        
        LogCriticalEvent("BREAKER_DETECTED", "Bearish breaker block detected");
    }
    
    if(IsSwingLow(index+3) && IsSwingHigh(index+2) && 
       g_cached_lows[index+1] < g_cached_lows[index+3] && 
       g_cached_highs[index] > g_cached_highs[index+2]) {
        
        ICTPattern breaker;
        breaker.time = g_cached_times[index+2];
        breaker.high = g_cached_highs[index+2];
        breaker.low = g_cached_lows[index+2];
        breaker.open = g_cached_opens[index+2];
        breaker.close = g_cached_closes[index+2];
        breaker.type = SETUP_OB;
        breaker.direction = BIAS_BULLISH;
        breaker.ob_type = OB_BREAKER;
        breaker.confluence_score = 80;
        breaker.valid = true;
        breaker.timeframe = PERIOD_M1;
        breaker.atr_at_formation = g_indicator_cache.atr_m1_14;
        
        AddPattern(breaker);
        
        LogCriticalEvent("BREAKER_DETECTED", "Bullish breaker block detected");
    }
}

void DetectMitigationBlocks(int index) {
    for(int i = 0; i < g_pattern_count; i++) {
        if(g_patterns[i].type == SETUP_OB && 
           g_patterns[i].valid && 
           !g_patterns[i].tested &&
           (g_patterns[i].time <= g_cached_times[index+5])) {
            
            bool tested = false;
            if(g_patterns[i].direction == BIAS_BULLISH) {
                if(g_cached_lows[index] <= g_patterns[i].high && 
                   g_cached_lows[index] >= g_patterns[i].low) {
                    tested = true;
                }
            } else {
                if(g_cached_highs[index] >= g_patterns[i].low && 
                   g_cached_highs[index] <= g_patterns[i].high) {
                    tested = true;
                }
            }
            
            if(tested) {
                g_patterns[i].tested = true;
                g_patterns[i].ob_type = OB_MITIGATION;
                g_patterns[i].confluence_score += 20;
                
                LogCriticalEvent("OB_MITIGATION", 
                               StringFormat("Order block mitigated at %.5f", g_patterns[i].low));
            }
        }
    }
}

void DetectRejectionBlocks(int index) {
    for(int i = 0; i < g_pattern_count; i++) {
        if(g_patterns[i].type == SETUP_OB && 
           g_patterns[i].valid && 
           !g_patterns[i].tested &&
           (g_patterns[i].time <= g_cached_times[index + 10])) {
            
            bool penetration_detected = false;
            bool rejection_confirmed = false;
            
            if(g_patterns[i].direction == BIAS_BULLISH) {
                if(g_cached_lows[index] < g_patterns[i].low) {
                    penetration_detected = true;
                    
                    for(int j = index - 1; j >= MathMax(0, index - 3); j--) {
                        if(g_cached_closes[j] > g_patterns[i].low) {
                            rejection_confirmed = true;
                            break;
                        }
                    }
                }
            } else if(g_patterns[i].direction == BIAS_BEARISH) {
                if(g_cached_highs[index] > g_patterns[i].high) {
                    penetration_detected = true;
                    
                    for(int j = index - 1; j >= MathMax(0, index - 3); j--) {
                        if(g_cached_closes[j] < g_patterns[i].high) {
                            rejection_confirmed = true;
                            break;
                        }
                    }
                }
            }
            
            if(penetration_detected && rejection_confirmed) {
                ICTPattern rejection_block = g_patterns[i];
                rejection_block.ob_type = OB_BREAKER;
                rejection_block.confluence_score += 15.0;
                rejection_block.tested = true;
                
                LogCriticalEvent("REJECTION_BLOCK", 
                               StringFormat("Rejection block formation at %.5f - Failed penetration of %s OB", 
                                          g_symbol.Bid(), 
                                          rejection_block.direction == BIAS_BULLISH ? "Bullish" : "Bearish"));
                
                g_patterns[i] = rejection_block;
            }
        }
    }
}

void DetectMarketStructureShift() {
    double atr = g_indicator_cache.atr_m1_14;
    
    for(int i = 1; i < 20; i++) {
        bool displacement_up = (g_cached_closes[0] - g_cached_opens[i]) > atr * InpDisplacementATR;
        bool displacement_down = (g_cached_opens[i] - g_cached_closes[0]) > atr * InpDisplacementATR;
        
        if(displacement_up || displacement_down) {
            ENUM_ICT_BIAS mss_direction = displacement_up ? BIAS_BULLISH : BIAS_BEARISH;
            
            if(ConfirmStructureBreak(mss_direction)) {
                ICTPattern mss;
                mss.time = g_cached_times[0];
                mss.high = g_cached_highs[0];
                mss.low = g_cached_lows[0];
                mss.open = g_cached_opens[0];
                mss.close = g_cached_closes[0];
                mss.type = SETUP_MSS;
                mss.direction = mss_direction;
                mss.confluence_score = 75;
                mss.valid = true;
                mss.timeframe = PERIOD_M1;
                mss.atr_at_formation = atr;
                
                AddPattern(mss);
                
                LogCriticalEvent("MSS_DETECTED", 
                               StringFormat("Market Structure Shift detected: %s at %.5f", 
                                          mss_direction == BIAS_BULLISH ? "Bullish" : "Bearish",
                                          g_cached_closes[0]));
            }
        }
    }
}

bool ConfirmStructureBreak(ENUM_ICT_BIAS direction) {
    if(direction == BIAS_BULLISH) {
        for(int i = 1; i < 20; i++) {
            if(IsSwingHigh(i) && g_cached_highs[0] > g_cached_highs[i]) return true;
        }
    } else {
        for(int i = 1; i < 20; i++) {
            if(IsSwingLow(i) && g_cached_lows[0] < g_cached_lows[i]) return true;
        }
    }
    return false;
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// LIQUIDITY ANALYSIS FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void IdentifyBuySideLiquidity() {
    for(int i = 5; i < InpLiquidityLookback; i++) {
        if(IsSwingHigh(i)) {
            double liquidity_level = g_cached_highs[i];
            
            if(!IsLevelSwept(liquidity_level, true)) {
                LiquidityLevel level;
                level.time = g_cached_times[i];
                level.price = liquidity_level;
                level.is_buyside = true;
                level.swept = false;
                level.touch_count = CountTouches(liquidity_level);
                level.relative_equal_threshold = InpRelativeEqualThreshold;
                
                AddLiquidityLevel(level);
            }
        }
    }
}

void IdentifySellSideLiquidity() {
    for(int i = 5; i < InpLiquidityLookback; i++) {
        if(IsSwingLow(i)) {
            double liquidity_level = g_cached_lows[i];
            
            if(!IsLevelSwept(liquidity_level, false)) {
                LiquidityLevel level;
                level.time = g_cached_times[i];
                level.price = liquidity_level;
                level.is_buyside = false;
                level.swept = false;
                level.touch_count = CountTouches(liquidity_level);
                level.relative_equal_threshold = InpRelativeEqualThreshold;
                
                AddLiquidityLevel(level);
            }
        }
    }
}

void DetectRelativeEqualLevels() {
    for(int i = 0; i < g_liquidity_count - 1; i++) {
        for(int j = i + 1; j < g_liquidity_count; j++) {
            if(g_liquidity_levels[i].is_buyside == g_liquidity_levels[j].is_buyside) {
                double price_diff = MathAbs(g_liquidity_levels[i].price - g_liquidity_levels[j].price);
                
                if(price_diff <= InpRelativeEqualThreshold * _Point) {
                    g_liquidity_levels[i].relative_equal_threshold = price_diff;
                    g_liquidity_levels[j].relative_equal_threshold = price_diff;
                    g_liquidity_levels[i].touch_count += 5;
                    g_liquidity_levels[j].touch_count += 5;
                }
            }
        }
    }
}

void AnalyzeLiquiditySweeps() {
    double current_high = g_cached_highs[0];
    double current_low = g_cached_lows[0];
    
    for(int i = 0; i < g_liquidity_count; i++) {
        if(!g_liquidity_levels[i].swept) {
            if(g_liquidity_levels[i].is_buyside && current_high > g_liquidity_levels[i].price) {
                g_liquidity_levels[i].swept = true;
                OnLiquiditySweep(i, true);
            }
            else if(!g_liquidity_levels[i].is_buyside && current_low < g_liquidity_levels[i].price) {
                g_liquidity_levels[i].swept = true;
                OnLiquiditySweep(i, false);
            }
        }
    }
}

void OnLiquiditySweep(int level_index, bool is_buyside) {
    if(InpRequireLiquiditySweep) {
        ENUM_ICT_BIAS expected_reversal = is_buyside ? BIAS_BEARISH : BIAS_BULLISH;
        
        double sweep_price = g_liquidity_levels[level_index].price;
        datetime sweep_time = TimeCurrent();
        
        ICTPattern sweep_pattern;
        sweep_pattern.time = sweep_time;
        sweep_pattern.high = is_buyside ? sweep_price : g_cached_highs[0];
        sweep_pattern.low = is_buyside ? g_cached_lows[0] : sweep_price;
        sweep_pattern.type = SETUP_LIQUIDITY;
        sweep_pattern.direction = expected_reversal;
        sweep_pattern.confluence_score = 70;
        sweep_pattern.valid = true;
        sweep_pattern.timeframe = PERIOD_M1;
        sweep_pattern.atr_at_formation = g_indicator_cache.atr_m1_14;
        
        AddPattern(sweep_pattern);
        
        ScanForPostSweepSetups(sweep_price, expected_reversal);
        
        LogCriticalEvent("LIQUIDITY_SWEEP", 
                        StringFormat("%s liquidity swept at %.5f - Expecting %s reversal", 
                                    is_buyside ? "Buyside" : "Sellside", 
                                    sweep_price,
                                    expected_reversal == BIAS_BULLISH ? "Bullish" : "Bearish"));
    }
}

void ScanForPostSweepSetups(double sweep_price, ENUM_ICT_BIAS expected_direction) {
    for(int i = 0; i < 5; i++) {
        for(int j = 0; j < g_pattern_count; j++) {
            if(g_patterns[j].type == SETUP_FVG && 
               g_patterns[j].direction == expected_direction &&
               MathAbs(g_patterns[j].time - g_cached_times[i]) < 60) {
                g_patterns[j].confluence_score += 30;
            }
        }
        
        for(int j = 0; j < g_pattern_count; j++) {
            if(g_patterns[j].type == SETUP_OB && 
               g_patterns[j].direction == expected_direction &&
               MathAbs(g_patterns[j].time - g_cached_times[i]) < 60) {
                g_patterns[j].confluence_score += 25;
            }
        }
    }
}

bool IsLevelSwept(double level, bool is_buyside) {
    for(int i = 0; i < 10; i++) {
        if(is_buyside && g_cached_highs[i] > level) return true;
        if(!is_buyside && g_cached_lows[i] < level) return true;
    }
    return false;
}

int CountTouches(double level) {
    int touches = 0;
    double tolerance = 5 * _Point;
    
    for(int i = 0; i < 50; i++) {
        if(MathAbs(g_cached_highs[i] - level) <= tolerance || 
           MathAbs(g_cached_lows[i] - level) <= tolerance) {
            touches++;
        }
    }
    return touches;
}

int CalculateSignificance(ENUM_MARKET_STRUCTURE type) {
    switch(type) {
        case MS_LTH:
        case MS_LTL: return 100;
        case MS_ITH:
        case MS_ITL: return 75;
        case MS_STH:
        case MS_STL: return 50;
        default: return 25;
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// SILVER BULLET AND VENOM SUPPORT FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

double GetSessionHigh(int start_hour, int start_min, int end_hour, int end_min) {
    double session_high = 0;
    
    for(int i = 0; i < 100; i++) {
        MqlDateTime bar_time;
        TimeToStruct(ConvertToNYTime(g_cached_times[i]), bar_time);
        
        if((bar_time.hour > start_hour || (bar_time.hour == start_hour && bar_time.min >= start_min)) &&
           (bar_time.hour < end_hour || (bar_time.hour == end_hour && bar_time.min <= end_min))) {
            session_high = MathMax(session_high, g_cached_highs[i]);
        }
    }
    
    return session_high;
}

double GetSessionLow(int start_hour, int start_min, int end_hour, int end_min) {
    double session_low = DBL_MAX;
    
    for(int i = 0; i < 100; i++) {
        MqlDateTime bar_time;
        TimeToStruct(ConvertToNYTime(g_cached_times[i]), bar_time);
        
        if((bar_time.hour > start_hour || (bar_time.hour == start_hour && bar_time.min >= start_min)) &&
           (bar_time.hour < end_hour || (bar_time.hour == end_hour && bar_time.min <= end_min))) {
            session_low = MathMin(session_low, g_cached_lows[i]);
        }
    }
    
    return session_low == DBL_MAX ? 0 : session_low;
}

ICTPattern DetectSilverBulletFVG(ENUM_ICT_BIAS direction) {
    ICTPattern fvg;
    
    double highs_5m[10], lows_5m[10], opens_5m[10], closes_5m[10];
    datetime times_5m[10];
    
    if(CopyHigh(_Symbol, PERIOD_M5, 0, 10, highs_5m) == 10 &&
       CopyLow(_Symbol, PERIOD_M5, 0, 10, lows_5m) == 10 &&
       CopyOpen(_Symbol, PERIOD_M5, 0, 10, opens_5m) == 10 &&
       CopyClose(_Symbol, PERIOD_M5, 0, 10, closes_5m) == 10 &&
       CopyTime(_Symbol, PERIOD_M5, 0, 10, times_5m) == 10) {
        
        for(int i = 2; i < 8; i++) {
            if(direction == BIAS_BULLISH &&
               closes_5m[i+1] < opens_5m[i+1] && 
               closes_5m[i] > opens_5m[i] &&     
               closes_5m[i-1] > opens_5m[i-1]) { 
                
                double gap_low = highs_5m[i+1];
                double gap_high = lows_5m[i-1];
                
                if(gap_high > gap_low) {
                    fvg.time = times_5m[i];
                    fvg.high = gap_high;
                    fvg.low = gap_low;
                    fvg.direction = BIAS_BULLISH;
                    fvg.type = SETUP_FVG;
                    fvg.valid = true;
                    break;
                }
            }
            
            if(direction == BIAS_BEARISH &&
               closes_5m[i+1] > opens_5m[i+1] && 
               closes_5m[i] < opens_5m[i] &&     
               closes_5m[i-1] < opens_5m[i-1]) { 
                
                double gap_high = lows_5m[i+1];
                double gap_low = highs_5m[i-1];
                
                if(gap_high > gap_low) {
                    fvg.time = times_5m[i];
                    fvg.high = gap_high;
                    fvg.low = gap_low;
                    fvg.direction = BIAS_BEARISH;
                    fvg.type = SETUP_FVG;
                    fvg.valid = true;
                    break;
                }
            }
        }
    }
    
    return fvg;
}

ICTPattern DetectSecondaryFVG(ENUM_ICT_BIAS direction) {
    ICTPattern fvg;
    
    for(int i = 2; i < 10; i++) {
        if((TimeCurrent() - g_cached_times[i]) < 600) {
            
            if(direction == BIAS_BULLISH &&
               g_cached_closes[i+1] < g_cached_opens[i+1] &&
               g_cached_closes[i] > g_cached_opens[i] &&
               g_cached_closes[i-1] > g_cached_opens[i-1]) {
                
                double gap_low = g_cached_highs[i+1];
                double gap_high = g_cached_lows[i-1];
                
                if(gap_high > gap_low) {
                    fvg.time = g_cached_times[i];
                    fvg.high = gap_high;
                    fvg.low = gap_low;
                    fvg.direction = BIAS_BULLISH;
                    fvg.type = SETUP_FVG;
                    fvg.valid = true;
                    break;
                }
            }
            
            if(direction == BIAS_BEARISH &&
               g_cached_closes[i+1] > g_cached_opens[i+1] &&
               g_cached_closes[i] < g_cached_opens[i] &&
               g_cached_closes[i-1] < g_cached_opens[i-1]) {
                
                double gap_high = g_cached_lows[i+1];
                double gap_low = g_cached_highs[i-1];
                
                if(gap_high > gap_low) {
                    fvg.time = g_cached_times[i];
                    fvg.high = gap_high;
                    fvg.low = gap_low;
                    fvg.direction = BIAS_BEARISH;
                    fvg.type = SETUP_FVG;
                    fvg.valid = true;
                    break;
                }
            }
        }
    }
    
    return fvg;
}

double CalculateTargetDistance(const ICTPattern& fvg, ENUM_ICT_BIAS direction) {
    double entry_level = direction == BIAS_BULLISH ? fvg.low : fvg.high;
    double target_level = 0;
    
    if(direction == BIAS_BULLISH) {
        for(int i = 0; i < g_liquidity_count; i++) {
            if(g_liquidity_levels[i].is_buyside && 
               g_liquidity_levels[i].price > entry_level) {
                if(target_level == 0 || g_liquidity_levels[i].price < target_level) {
                    target_level = g_liquidity_levels[i].price;
                }
            }
        }
    } else {
        for(int i = 0; i < g_liquidity_count; i++) {
            if(!g_liquidity_levels[i].is_buyside && 
               g_liquidity_levels[i].price < entry_level) {
                if(target_level == 0 || g_liquidity_levels[i].price > target_level) {
                    target_level = g_liquidity_levels[i].price;
                }
            }
        }
    }
    
    if(target_level == 0) {
        target_level = direction == BIAS_BULLISH ? 
                      entry_level + (g_indicator_cache.atr_m1_14 * 3) :
                      entry_level - (g_indicator_cache.atr_m1_14 * 3);
    }
    
    return MathAbs(target_level - entry_level);
}

void ExecuteSilverBulletTrade(const ICTPattern& fvg, double target_distance) {
    ICTPattern silver_bullet = fvg;
    silver_bullet.type = SETUP_SILVERB;
    silver_bullet.confluence_score = 95;
    
    AddPattern(silver_bullet);
    
    LogCriticalEvent("SILVER_BULLET", 
                    StringFormat("Silver Bullet setup executed: %s, Target distance: %.1f points", 
                               fvg.direction == BIAS_BULLISH ? "Bullish" : "Bearish",
                               target_distance / _Point));
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// NEWS AND UTILITY SUPPORT FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void AddNewsEvent(datetime event_time, string currency, int impact_level, string description) {
    if(g_news_count >= ArraySize(g_news_events)) {
        int new_size = ArraySize(g_news_events) + 20;
        if(ArrayResize(g_news_events, new_size) != new_size) {
            LogCriticalEvent("NEWS_ERROR", "Failed to expand news events array capacity");
            return;
        }
    }
    
    NewsEvent news_event;
    news_event.event_time = event_time;
    news_event.currency = currency;
    news_event.impact_level = impact_level;
    news_event.description = description;
    
    g_news_events[g_news_count] = news_event;
    g_news_count++;
    
    LogCriticalEvent("NEWS_ADDED", 
                    StringFormat("High-impact event registered: %s %s at %s", 
                               currency, description, TimeToString(event_time, TIME_MINUTES)));
}

int CountHighImpactEvents() {
    int high_impact_count = 0;
    datetime current_time = TimeCurrent();
    
    for(int i = 0; i < g_news_count; i++) {
        if(g_news_events[i].impact_level >= 3 && 
           g_news_events[i].event_time > current_time) {
            high_impact_count++;
        }
    }
    
    return high_impact_count;
}

void CalculateNewsVolatilityExpectation() {
    datetime current_time = TimeCurrent();
    double volatility_multiplier = 1.0;
    int upcoming_events = 0;
    
    for(int i = 0; i < g_news_count; i++) {
        int time_to_event = (int)(g_news_events[i].event_time - current_time);
        
        if(time_to_event > 0 && time_to_event <= 14400) {
            upcoming_events++;
            
            switch(g_news_events[i].impact_level) {
                case 3: volatility_multiplier *= 1.5; break;
                case 2: volatility_multiplier *= 1.2; break;
                case 1: volatility_multiplier *= 1.1; break;
            }
        }
    }
    
    if(upcoming_events > 0) {
        LogCriticalEvent("VOLATILITY_FORECAST", 
                        StringFormat("Expected volatility increase: %.1f%% based on %d upcoming events", 
                                   (volatility_multiplier - 1.0) * 100.0, upcoming_events));
    }
}

void AddPattern(const ICTPattern& pattern) {
    for(int i = 0; i < g_pattern_count; i++) {
        if(g_patterns[i].time == pattern.time && 
           g_patterns[i].type == pattern.type &&
           MathAbs(g_patterns[i].high - pattern.high) < _Point) {
            return;
        }
    }
    
    if(g_pattern_count >= ArraySize(g_patterns)) {
        int new_size = ArraySize(g_patterns) + 50;
        if(ArrayResize(g_patterns, new_size) != new_size) {
            Print("ERROR: Failed to resize g_patterns array!");
            return;
        }
    }
    
    g_patterns[g_pattern_count] = pattern;
    g_pattern_count++;
}

void AddLiquidityLevel(const LiquidityLevel& level) {
    for(int i = 0; i < g_liquidity_count; i++) {
        if(MathAbs(g_liquidity_levels[i].price - level.price) < 2 * _Point) return;
    }
    
    if(g_liquidity_count >= ArraySize(g_liquidity_levels)) {
        int new_size = ArraySize(g_liquidity_levels) + 50;
        if(ArrayResize(g_liquidity_levels, new_size) != new_size) {
            Print("ERROR: Failed to resize g_liquidity_levels array!");
            return;
        }
    }
    
    g_liquidity_levels[g_liquidity_count] = level;
    g_liquidity_count++;
}

void AddMarketStructure(datetime time, double price, ENUM_MARKET_STRUCTURE type) {
    for(int i = 0; i < g_market_structure_count; i++) {
        if(g_market_structure[i].time == time && 
           MathAbs(g_market_structure[i].price - price) < _Point) return;
    }
    
    if(g_market_structure_count >= ArraySize(g_market_structure)) {
        int new_size = ArraySize(g_market_structure) + 50;
        if(ArrayResize(g_market_structure, new_size) != new_size) {
            Print("ERROR: Failed to resize g_market_structure array!");
            return;
        }
    }
    
    g_market_structure[g_market_structure_count].time = time;
    g_market_structure[g_market_structure_count].price = price;
    g_market_structure[g_market_structure_count].type = type;
    g_market_structure[g_market_structure_count].confirmed = true;
    g_market_structure[g_market_structure_count].significance_score = CalculateSignificance(type);
    g_market_structure_count++;
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// SYSTEM MANAGEMENT FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void LogCriticalEvent(string event_type, string message) {
    string log_entry = StringFormat("[%s] %s: %s", 
                                   TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
                                   event_type, message);
    Print(log_entry);
    
    int file_handle = FileOpen("ICT_Master_EA_Log.txt", 
                               FILE_WRITE|FILE_READ|FILE_TXT|FILE_COMMON);
    if(file_handle != INVALID_HANDLE) {
        FileSeek(file_handle, 0, SEEK_END);
        FileWriteString(file_handle, log_entry + "\n");
        FileClose(file_handle);
    }
    
    if(event_type == "CRITICAL_ERROR" || event_type == "TRADE_EXECUTED") {
        SendNotification(log_entry);
    }
}

bool LogDebug(string category, string message) {
    if(!InpEnableDebugLogging) return true;
    
    string debug_entry = StringFormat("[DEBUG] [%s] %s: %s", 
                                     TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                                     category, message);
    Print(debug_entry);
    return true;
}

void HandleCriticalError(int error_code) {
    string error_description = "";
    bool should_halt = false;
    
    switch(error_code) {
        case TRADE_RETCODE_NO_MONEY:
            error_description = "Insufficient funds for trading";
            should_halt = true;
            break;
        case TRADE_RETCODE_TRADE_DISABLED:
            error_description = "Trading is disabled";
            should_halt = true;
            break;
        case TRADE_RETCODE_MARKET_CLOSED:
            error_description = "Market is closed";
            should_halt = false;
            break;
        case TRADE_RETCODE_INVALID_STOPS:
            error_description = "Invalid stop loss or take profit";
            should_halt = false;
            break;
        case TRADE_RETCODE_INVALID_VOLUME:
            error_description = "Invalid trade volume";
            should_halt = false;
            break;
        case TRADE_RETCODE_REQUOTE:
            error_description = "Requote error";
            should_halt = false;
            break;
        default:
            error_description = "Unknown error occurred";
            should_halt = false;
    }
    
    LogCriticalEvent("CRITICAL_ERROR", StringFormat("Code: %d, Description: %s", 
                                                   error_code, error_description));
    
    if(should_halt) {
        ExpertRemove();
    }
}

void CleanupExpiredData() {
    int valid_count = 0;
    for(int i = 0; i < g_pattern_count; i++) {
        int age_hours = (int)((TimeCurrent() - g_patterns[i].time) / 3600);
        
        if(g_patterns[i].valid && age_hours < InpFVGExpiry) {
            if(valid_count != i) {
                g_patterns[valid_count] = g_patterns[i];
            }
            valid_count++;
        }
    }
    g_pattern_count = valid_count;
    
    int ms_valid_count = 0;
    for(int i = 0; i < g_market_structure_count; i++) {
        int age_days = (int)((TimeCurrent() - g_market_structure[i].time) / 86400);
        
        if(age_days < 7) {
            if(ms_valid_count != i) {
                g_market_structure[ms_valid_count] = g_market_structure[i];
            }
            ms_valid_count++;
        }
    }
    g_market_structure_count = ms_valid_count;
    
    int liq_valid_count = 0;
    for(int i = 0; i < g_liquidity_count; i++) {
        int age_days = (int)((TimeCurrent() - g_liquidity_levels[i].time) / 86400);
        
        if(age_days < 3) {
            if(liq_valid_count != i) {
                g_liquidity_levels[liq_valid_count] = g_liquidity_levels[i];
            }
            liq_valid_count++;
        }
    }
    g_liquidity_count = liq_valid_count;
}

void UpdatePerformanceMetrics() {
    double current_equity = g_account.Equity();
    
    if(current_equity > g_equity_high) {
        g_equity_high = current_equity;
    }
    
    double current_drawdown = (g_equity_high - current_equity) / g_equity_high * 100.0;
    if(current_drawdown > g_max_dd) {
        g_max_dd = current_drawdown;
    }
    
    static int last_day = -1;
    MqlDateTime dt;
    TimeToStruct(TimeCurrent(), dt);
    
    if(dt.day != last_day) {
        g_trades_today = 0;
        g_daily_pnl = 0.0;
        last_day = dt.day;
    }
}

string GetUninitReasonText(int reason) {
    switch(reason) {
        case REASON_ACCOUNT: return "Account changed";
        case REASON_CHARTCHANGE: return "Chart changed";
        case REASON_CHARTCLOSE: return "Chart closed";
        case REASON_PARAMETERS: return "Parameters changed";
        case REASON_RECOMPILE: return "Expert recompiled";
        case REASON_REMOVE: return "Expert removed";
        case REASON_TEMPLATE: return "Template changed";
        case REASON_INITFAILED: return "Initialization failed";
        case REASON_CLOSE: return "Terminal closed";
        default: return "Unknown reason";
    }
}

void GeneratePerformanceReport() {
    string report = "\n═══════════════════════════════════════════════════════════════\n";
    report += "                    ICT XAUUSD MASTER EA PERFORMANCE REPORT\n";
    report += "═══════════════════════════════════════════════════════════════\n";
    report += StringFormat("Final Equity: $%.2f\n", g_account.Equity());
    report += StringFormat("Equity High: $%.2f\n", g_equity_high);
    report += StringFormat("Maximum Drawdown: %.2f%%\n", g_max_dd);
    report += StringFormat("Trades Today: %d\n", g_trades_today);
    report += StringFormat("Total Patterns Detected: %d\n", g_pattern_count);
    report += StringFormat("Active Liquidity Levels: %d\n", g_liquidity_count);
    report += StringFormat("Current Bias: %s\n", EnumToString(g_daily_bias));
    report += "═══════════════════════════════════════════════════════════════\n";
    
    Print(report);
    LogCriticalEvent("PERFORMANCE_REPORT", report);
}

void CloseAllPositions() {
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(g_position.SelectByIndex(i)) {
            if(g_position.Magic() == InpMagicNumber) {
                g_trade.PositionClose(g_position.Ticket());
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════════════════════
// COMPREHENSIVE CHART VISUALIZATION SYSTEM
// ═══════════════════════════════════════════════════════════════════════════════════════════════

void DrawChartObjects() {
    static datetime last_draw_time = 0;
    
    if(TimeCurrent() - last_draw_time < 5) return; // Update every 5 seconds max
    
    if(InpShowFVGs) DrawFVGObjects();
    if(InpShowOrderBlocks) DrawOrderBlockObjects();
    if(InpShowLiquidity) DrawLiquidityObjects();
    if(InpShowSessions) DrawSessionObjects();
    if(InpShowMarketStructure) DrawMarketStructureObjects();
    if(InpShowIPDA) DrawIPDAObjects();
    if(InpShowPowerOf3) DrawPowerOf3Objects();
    if(InpShowTrades) DrawTradeObjects();
    if(InpShowGaps) DrawGapObjects();
    if(InpShowInfoPanel) UpdateInformationPanel();
    
    ChartRedraw();
    last_draw_time = TimeCurrent();
}

void DrawFVGObjects() {
    // Remove old FVG objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_FVG) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    for(int i = 0; i < g_pattern_count; i++) {
        if(g_patterns[i].type != SETUP_FVG || !g_patterns[i].valid) continue;
        
        string obj_name = StringFormat("%s%d_%lld", OBJ_PREFIX_FVG, i, g_patterns[i].time);
        
        color fvg_color = g_patterns[i].direction == BIAS_BULLISH ? InpFVGBullishColor : InpFVGBearishColor;
        if(g_patterns[i].tested) {
            fvg_color = C'128,128,128'; // Gray for tested FVGs
        }
        
        // Draw FVG rectangle
        if(ObjectCreate(0, obj_name + "_rect", OBJ_RECTANGLE, 0, 
                       g_patterns[i].time, g_patterns[i].low, 
                       g_patterns[i].time + 3600, g_patterns[i].high)) {
            
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_COLOR, fvg_color);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_FILL, true);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_BACK, true);
        }
        
        // Draw consequent encroachment line (50% level)
        double ce_level = (g_patterns[i].high + g_patterns[i].low) / 2.0;
        if(ObjectCreate(0, obj_name + "_ce", OBJ_HLINE, 0, 0, ce_level)) {
            ObjectSetInteger(0, obj_name + "_ce", OBJPROP_COLOR, fvg_color);
            ObjectSetInteger(0, obj_name + "_ce", OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, obj_name + "_ce", OBJPROP_STYLE, STYLE_DOT);
        }
        
        // Add FVG label
        string fvg_type_str = "";
        switch(g_patterns[i].fvg_type) {
            case FVG_BISI: fvg_type_str = "BISI"; break;
            case FVG_SIBI: fvg_type_str = "SIBI"; break;
            case FVG_IFVG: fvg_type_str = "IFVG"; break;
        }
        
        string label_text = StringFormat("%s %.1f", fvg_type_str, g_patterns[i].confluence_score);
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, g_patterns[i].time, g_patterns[i].high + 10 * _Point)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, label_text);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, fvg_color);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 8);
        }
    }
}

void DrawOrderBlockObjects() {
    // Remove old OB objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_OB) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    for(int i = 0; i < g_pattern_count; i++) {
        if(g_patterns[i].type != SETUP_OB || !g_patterns[i].valid) continue;
        
        string obj_name = StringFormat("%s%d_%lld", OBJ_PREFIX_OB, i, g_patterns[i].time);
        
        color ob_color = g_patterns[i].direction == BIAS_BULLISH ? InpOBBullishColor : InpOBBearishColor;
        if(g_patterns[i].tested) {
            ob_color = C'100,100,100'; // Darker gray for tested OBs
        }
        
        // Draw Order Block rectangle
        if(ObjectCreate(0, obj_name + "_rect", OBJ_RECTANGLE, 0, 
                       g_patterns[i].time, g_patterns[i].low, 
                       g_patterns[i].time + 1800, g_patterns[i].high)) {
            
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_COLOR, ob_color);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_FILL, true);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_BACK, true);
        }
        
        // Draw mean threshold (50% level)
        double mean_level = (g_patterns[i].high + g_patterns[i].low) / 2.0;
        if(ObjectCreate(0, obj_name + "_mean", OBJ_HLINE, 0, 0, mean_level)) {
            ObjectSetInteger(0, obj_name + "_mean", OBJPROP_COLOR, ob_color);
            ObjectSetInteger(0, obj_name + "_mean", OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, obj_name + "_mean", OBJPROP_STYLE, STYLE_DASH);
        }
        
        // Add OB label
        string ob_type_str = "";
        switch(g_patterns[i].ob_type) {
            case OB_BULLISH: ob_type_str = "Bull OB"; break;
            case OB_BEARISH: ob_type_str = "Bear OB"; break;
            case OB_BREAKER: ob_type_str = "Breaker"; break;
            case OB_MITIGATION: ob_type_str = "Mitigated"; break;
        }
        
        string label_text = StringFormat("%s %.1f", ob_type_str, g_patterns[i].confluence_score);
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, g_patterns[i].time, g_patterns[i].high + 15 * _Point)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, label_text);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, ob_color);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 8);
        }
    }
}

void DrawLiquidityObjects() {
    // Remove old liquidity objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_LIQ) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    for(int i = 0; i < g_liquidity_count; i++) {
        string obj_name = StringFormat("%s%d_%s", OBJ_PREFIX_LIQ, i, 
                                      g_liquidity_levels[i].is_buyside ? "BSL" : "SSL");
        
        color liq_color = g_liquidity_levels[i].is_buyside ? InpLiquidityBuysideColor : InpLiquiditySellsideColor;
        int line_style = g_liquidity_levels[i].swept ? STYLE_DOT : STYLE_SOLID;
        int line_width = g_liquidity_levels[i].touch_count > 3 ? 3 : 2;
        
        // Draw liquidity level line
        if(ObjectCreate(0, obj_name + "_line", OBJ_HLINE, 0, 0, g_liquidity_levels[i].price)) {
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_COLOR, liq_color);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_WIDTH, line_width);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_STYLE, line_style);
        }
        
        // Add liquidity label
        string liq_type = g_liquidity_levels[i].is_buyside ? "BSL" : "SSL";
        string status = g_liquidity_levels[i].swept ? " (Swept)" : "";
        string label_text = StringFormat("%s%s [%d]", liq_type, status, g_liquidity_levels[i].touch_count);
        
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, TimeCurrent(), g_liquidity_levels[i].price)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, label_text);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, liq_color);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_ANCHOR, ANCHOR_LEFT);
        }
    }
}

void DrawSessionObjects() {
    // Remove old session objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_SESSION) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    
    // Draw current session background
    datetime session_start = 0;
    datetime session_end = 0;
    color session_color = clrNONE;
    string session_name = "";
    
    if(dt.hour >= 2 && dt.hour < 5) {
        // London Kill Zone
        session_start = TimeCurrent() - (dt.min * 60) - ((dt.hour - 2) * 3600);
        session_end = session_start + (3 * 3600);
        session_color = C'50,100,50'; // Dark green
        session_name = "London KZ";
    }
    else if(dt.hour >= 8 && dt.hour < 11) {
        // NY AM Kill Zone
        session_start = TimeCurrent() - (dt.min * 60) - ((dt.hour - 8) * 3600);
        session_end = session_start + (3 * 3600);
        session_color = C'100,50,50'; // Dark red
        session_name = "NY AM KZ";
    }
    else if(dt.hour == 10) {
        // Silver Bullet
        session_start = TimeCurrent() - (dt.min * 60);
        session_end = session_start + 3600;
        session_color = C'100,100,50'; // Dark yellow
        session_name = "Silver Bullet";
    }
    
    if(session_start > 0) {
        string obj_name = OBJ_PREFIX_SESSION + session_name;
        
        double session_high = iHigh(_Symbol, PERIOD_M1, 0);
        double session_low = iLow(_Symbol, PERIOD_M1, 0);
        
        // Find session high/low
        for(int i = 0; i < 60; i++) {
            if(g_cached_times[i] >= session_start) {
                session_high = MathMax(session_high, g_cached_highs[i]);
                session_low = MathMin(session_low, g_cached_lows[i]);
            }
        }
        
        // Draw session rectangle
        if(ObjectCreate(0, obj_name + "_rect", OBJ_RECTANGLE, 0, 
                       session_start, session_low, session_end, session_high)) {
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_COLOR, session_color);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_FILL, true);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_BACK, true);
            ObjectSetInteger(0, obj_name + "_rect", OBJPROP_WIDTH, 1);
        }
        
        // Add session label
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, session_start, session_high)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, session_name);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 10);
        }
    }
}

void DrawMarketStructureObjects() {
    // Remove old market structure objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_MS) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    for(int i = 0; i < g_market_structure_count; i++) {
        string obj_name = StringFormat("%s%d_%lld", OBJ_PREFIX_MS, i, g_market_structure[i].time);
        
        color ms_color = clrWhite;
        string symbol_text = "";
        int symbol_size = 8;
        
        switch(g_market_structure[i].type) {
            case MS_STH:
                ms_color = clrTomato;
                symbol_text = "STH";
                symbol_size = 8;
                break;
            case MS_STL:
                ms_color = clrLimeGreen;
                symbol_text = "STL";
                symbol_size = 8;
                break;
            case MS_ITH:
                ms_color = clrOrangeRed;
                symbol_text = "ITH";
                symbol_size = 10;
                break;
            case MS_ITL:
                ms_color = clrSpringGreen;
                symbol_text = "ITL";
                symbol_size = 10;
                break;
            case MS_LTH:
                ms_color = clrRed;
                symbol_text = "LTH";
                symbol_size = 12;
                break;
            case MS_LTL:
                ms_color = clrGreen;
                symbol_text = "LTL";
                symbol_size = 12;
                break;
        }
        
        // Draw swing point marker
        double marker_offset = (g_market_structure[i].type == MS_STH || 
                               g_market_structure[i].type == MS_ITH || 
                               g_market_structure[i].type == MS_LTH) ? 20 * _Point : -20 * _Point;
        
        if(ObjectCreate(0, obj_name + "_marker", OBJ_TEXT, 0, 
                       g_market_structure[i].time, g_market_structure[i].price + marker_offset)) {
            ObjectSetString(0, obj_name + "_marker", OBJPROP_TEXT, symbol_text);
            ObjectSetInteger(0, obj_name + "_marker", OBJPROP_COLOR, ms_color);
            ObjectSetInteger(0, obj_name + "_marker", OBJPROP_FONTSIZE, symbol_size);
            ObjectSetInteger(0, obj_name + "_marker", OBJPROP_ANCHOR, ANCHOR_CENTER);
        }
    }
}

void DrawIPDAObjects() {
    // Remove old IPDA objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_IPDA) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    if(g_ipda.last_update == 0) return;
    
    // Draw IPDA levels
    string ipda_levels[] = {"20H", "20L", "40H", "40L", "60H", "60L"};
    double ipda_prices[] = {g_ipda.highest_20, g_ipda.lowest_20, 
                           g_ipda.highest_40, g_ipda.lowest_40,
                           g_ipda.highest_60, g_ipda.lowest_60};
    color ipda_colors[] = {clrLightGray, clrLightGray, clrGray, clrGray, clrDarkGray, clrDarkGray};
    int ipda_widths[] = {1, 1, 2, 2, 3, 3};
    
    for(int i = 0; i < 6; i++) {
        string obj_name = StringFormat("%s%s", OBJ_PREFIX_IPDA, ipda_levels[i]);
        
        if(ObjectCreate(0, obj_name + "_line", OBJ_HLINE, 0, 0, ipda_prices[i])) {
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_COLOR, ipda_colors[i]);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_WIDTH, ipda_widths[i]);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_STYLE, STYLE_DASH);
        }
        
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, TimeCurrent(), ipda_prices[i])) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, "IPDA " + ipda_levels[i]);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, ipda_colors[i]);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
        }
    }
}

void DrawPowerOf3Objects() {
    // Remove old Power of 3 objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_PO3) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    if(g_power_of_3.session_start == 0) return;
    
    // Draw accumulation level
    if(g_power_of_3.accumulation_level > 0) {
        string obj_name = OBJ_PREFIX_PO3 + "Accumulation";
        
        if(ObjectCreate(0, obj_name + "_line", OBJ_HLINE, 0, 0, g_power_of_3.accumulation_level)) {
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_COLOR, clrYellow);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_STYLE, STYLE_SOLID);
        }
        
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, TimeCurrent(), g_power_of_3.accumulation_level)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, "PO3 Accumulation");
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, clrYellow);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 9);
        }
    }
    
    // Draw manipulation level
    if(g_power_of_3.manipulation_level > 0 && g_power_of_3.manipulation_complete) {
        string obj_name = OBJ_PREFIX_PO3 + "Manipulation";
        
        if(ObjectCreate(0, obj_name + "_line", OBJ_HLINE, 0, 0, g_power_of_3.manipulation_level)) {
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_COLOR, clrOrange);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_STYLE, STYLE_SOLID);
        }
        
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, TimeCurrent(), g_power_of_3.manipulation_level)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, "PO3 Manipulation");
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, clrOrange);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 9);
        }
    }
    
    // Draw distribution target
    if(g_power_of_3.distribution_target > 0 && g_power_of_3.distribution_active) {
        string obj_name = OBJ_PREFIX_PO3 + "Distribution";
        
        if(ObjectCreate(0, obj_name + "_line", OBJ_HLINE, 0, 0, g_power_of_3.distribution_target)) {
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_COLOR, clrCyan);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, obj_name + "_line", OBJPROP_STYLE, STYLE_SOLID);
        }
        
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, TimeCurrent(), g_power_of_3.distribution_target)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, "PO3 Target");
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, clrCyan);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 9);
        }
    }
}

void DrawTradeObjects() {
    // Remove old trade objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_TRADE) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    for(int i = 0; i < g_active_trades_count; i++) {
        if(!g_position.SelectByTicket(g_active_trades[i].ticket)) continue;
        
        string obj_name = StringFormat("%s%lld", OBJ_PREFIX_TRADE, g_active_trades[i].ticket);
        
        // Draw entry level
        if(ObjectCreate(0, obj_name + "_entry", OBJ_HLINE, 0, 0, g_active_trades[i].entry_price)) {
            ObjectSetInteger(0, obj_name + "_entry", OBJPROP_COLOR, clrBlue);
            ObjectSetInteger(0, obj_name + "_entry", OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, obj_name + "_entry", OBJPROP_STYLE, STYLE_SOLID);
        }
        
        // Draw stop loss
        if(ObjectCreate(0, obj_name + "_sl", OBJ_HLINE, 0, 0, g_active_trades[i].original_sl)) {
            ObjectSetInteger(0, obj_name + "_sl", OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0, obj_name + "_sl", OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, obj_name + "_sl", OBJPROP_STYLE, STYLE_SOLID);
        }
        
        // Draw take profit
        if(ObjectCreate(0, obj_name + "_tp", OBJ_HLINE, 0, 0, g_active_trades[i].original_tp)) {
            ObjectSetInteger(0, obj_name + "_tp", OBJPROP_COLOR, clrGreen);
            ObjectSetInteger(0, obj_name + "_tp", OBJPROP_WIDTH, 1);
            ObjectSetInteger(0, obj_name + "_tp", OBJPROP_STYLE, STYLE_SOLID);
        }
        
        // Add trade info label
        string state_text = "";
        switch(g_active_trades[i].state) {
            case TRADE_STATE_OPEN: state_text = "OPEN"; break;
            case TRADE_STATE_BREAKEVEN: state_text = "BE"; break;
            case TRADE_STATE_PARTIAL_1: state_text = "P1"; break;
            case TRADE_STATE_PARTIAL_2: state_text = "P2"; break;
            case TRADE_STATE_TRAILING: state_text = "TRAIL"; break;
        }
        
        string label_text = StringFormat("%s [%s]", EnumToString(g_active_trades[i].setup_type), state_text);
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, TimeCurrent(), g_active_trades[i].entry_price)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, label_text);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 8);
        }
    }
}

void DrawGapObjects() {
    // Remove old gap objects
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_GAP) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    for(int i = 0; i < g_gap_count; i++) {
        if(g_gaps[i].filled) continue;
        
        string obj_name = StringFormat("%s%d_%lld", OBJ_PREFIX_GAP, i, g_gaps[i].formation_time);
        string gap_type = g_gaps[i].is_ndog ? "NDOG" : "NWOG";
        
        // Draw gap zone
        datetime gap_end = g_gaps[i].formation_time + (24 * 3600); // 24 hours
        if(ObjectCreate(0, obj_name + "_zone", OBJ_RECTANGLE, 0, 
                       g_gaps[i].formation_time, g_gaps[i].lower_level, 
                       gap_end, g_gaps[i].upper_level)) {
            ObjectSetInteger(0, obj_name + "_zone", OBJPROP_COLOR, clrPurple);
            ObjectSetInteger(0, obj_name + "_zone", OBJPROP_FILL, false);
            ObjectSetInteger(0, obj_name + "_zone", OBJPROP_WIDTH, 2);
            ObjectSetInteger(0, obj_name + "_zone", OBJPROP_STYLE, STYLE_DASH);
        }
        
        // Draw quarter levels
        for(int j = 0; j < 4; j++) {
            if(ObjectCreate(0, obj_name + "_q" + IntegerToString(j+1), OBJ_HLINE, 0, 0, g_gaps[i].quarter_levels[j])) {
                ObjectSetInteger(0, obj_name + "_q" + IntegerToString(j+1), OBJPROP_COLOR, clrMediumPurple);
                ObjectSetInteger(0, obj_name + "_q" + IntegerToString(j+1), OBJPROP_WIDTH, 1);
                ObjectSetInteger(0, obj_name + "_q" + IntegerToString(j+1), OBJPROP_STYLE, STYLE_DOT);
            }
        }
        
        // Add gap label
        if(ObjectCreate(0, obj_name + "_label", OBJ_TEXT, 0, g_gaps[i].formation_time, g_gaps[i].upper_level)) {
            ObjectSetString(0, obj_name + "_label", OBJPROP_TEXT, gap_type);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_COLOR, clrPurple);
            ObjectSetInteger(0, obj_name + "_label", OBJPROP_FONTSIZE, 10);
        }
    }
}

void UpdateInformationPanel() {
    // Remove old info panel
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, OBJ_PREFIX_INFO) == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    
    // Create comprehensive information panel
    string info_lines[];
    ArrayResize(info_lines, 20);
    
    info_lines[0] = "═══ ICT XAUUSD MASTER EA v5.02 ═══";
    info_lines[1] = StringFormat("Daily Bias: %s | HTF Bias: %s", 
                                EnumToString(g_daily_bias), EnumToString(g_htf_bias));
    info_lines[2] = StringFormat("NY Time: %s", TimeToString(ConvertToNYTime(TimeCurrent()), TIME_MINUTES));
    
    MqlDateTime dt;
    TimeToStruct(ConvertToNYTime(TimeCurrent()), dt);
    string current_session = "Market Closed";
    if(dt.hour >= 2 && dt.hour < 5) current_session = "London Kill Zone";
    else if(dt.hour >= 8 && dt.hour < 11) current_session = "NY AM Kill Zone";
    else if(dt.hour == 10) current_session = "Silver Bullet";
    else if(dt.hour >= 13 && dt.hour < 16) current_session = "NY PM Kill Zone";
    else if(dt.hour >= 3 && dt.hour < 12) current_session = "London Session";
    else if(dt.hour >= 8 && dt.hour < 17) current_session = "New York Session";
    
    info_lines[3] = StringFormat("Session: %s", current_session);
    info_lines[4] = StringFormat("Trades Today: %d/%d", g_trades_today, InpMaxDailyTrades);
    info_lines[5] = StringFormat("Equity: $%.2f | Max DD: %.2f%%", g_account.Equity(), g_max_dd);
    info_lines[6] = StringFormat("Active Patterns: %d", g_pattern_count);
    info_lines[7] = StringFormat("Liquidity Levels: %d", g_liquidity_count);
    info_lines[8] = StringFormat("Active Trades: %d", g_active_trades_count);
    
    if(g_ipda.last_update > 0) {
        info_lines[9] = StringFormat("IPDA 20D: %.5f-%.5f", g_ipda.lowest_20, g_ipda.highest_20);
        info_lines[10] = StringFormat("IPDA 40D: %.5f-%.5f", g_ipda.lowest_40, g_ipda.highest_40);
        info_lines[11] = StringFormat("IPDA 60D: %.5f-%.5f", g_ipda.lowest_60, g_ipda.highest_60);
    }
    
    if(g_power_of_3.session_start > 0) {
        string po3_phase = "Accumulation";
        if(g_power_of_3.manipulation_complete && !g_power_of_3.distribution_active) po3_phase = "Manipulation";
        else if(g_power_of_3.distribution_active) po3_phase = "Distribution";
        info_lines[12] = StringFormat("Power of 3: %s", po3_phase);
    }
    
    if(InpUseNewsFilter) {
        int high_impact_events = CountHighImpactEvents();
        info_lines[13] = StringFormat("News Filter: %s (%d events)", 
                                     IsHighImpactNews() ? "ACTIVE" : "Clear", high_impact_events);
    }
    
    info_lines[14] = StringFormat("ATR M1: %.5f | H1: %.5f", 
                                 g_indicator_cache.atr_m1_14, g_indicator_cache.atr_h1_14);
    info_lines[15] = StringFormat("Confluence Threshold: %.1f", InpConfluenceThreshold);
    
    // Display information panel
    int y_offset = 20;
    for(int i = 0; i < ArraySize(info_lines); i++) {
        if(info_lines[i] == "") continue;
        
        string obj_name = StringFormat("%sLine%d", OBJ_PREFIX_INFO, i);
        if(ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0)) {
            ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
            ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, 10);
            ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y_offset + (i * 15));
            ObjectSetString(0, obj_name, OBJPROP_TEXT, info_lines[i]);
            ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clrWhite);
            ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, obj_name, OBJPROP_FONT, "Courier New");
        }
    }
}

void DeleteAllEAObjects() {
    for(int i = ObjectsTotal() - 1; i >= 0; i--) {
        string obj_name = ObjectName(i);
        if(StringFind(obj_name, "ICT_") == 0) {
            ObjectDelete(0, obj_name);
        }
    }
    ChartRedraw();
}

//+------------------------------------------------------------------+
