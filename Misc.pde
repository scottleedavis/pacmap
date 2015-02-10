boolean debug = true;

static int  SCREEN_WIDTH = 1024;
static int SCREEN_HEIGHT = 768;

static String FONT_FILE = "CrackMan-Regular-48.vlw";

color   MOUSE_COLOR = color(255,255,255,255);
float    MOUSE_SIZE = 20.0f;
int    MOUSE_WEIGHT = 7;

static float        GAME_WAIT_TIMEOUT = 5000.0f;
static float        GAME_OVER_TIMEOUT = 5000.0f;
static float        GAME_RESET_TIMEOUT = 8000.0f;
static int               GHOST_POINTS = 200;
static int        POWER_PELLET_POINTS = 200;
static float ROUTE_CONTINUATION_ANGLE = 30;


int             lMapIndex = -1;
static float snapDistance = 25f;
static int          GRIDX = 0;
static int          GRIDY = 0;


static int   LN_DIVISIONS = 4;
static float LV_DIVISIONS = 23;
static float     LV_CHUNK = 360f / LV_DIVISIONS;
static float  MINI_LV_CHUNK = LV_CHUNK / 7f;
static float   LINE_WIDTH = 5.0f;

static int       max_chomp      = 5;
static float      PAC_DIVISIONS = 18;
static float          PAC_CHUNK = 360f / PAC_DIVISIONS;
static float   PAC_ANI_STEPSIZE = 62f;
static float PAC_GHOST_DISTANCE = 22f;
static float   PAC_DEAD_TIMEOUT = 5000.0f;
static int        PAC_MAN_SPEED = 7;
static  int     PAC_MAN_WIIMOTE = 1;


static int           GHOST_COUNT = 4;
static float         GHOST_WIDTH = 50.0f;
static float GHOST_SEARCH_RADIUS = 200.0f;
static float  GHOST_DEAD_TIMEOUT = 5000.0f;
static   int        GHOST_SCARED_SPEED = (int)((float)PAC_MAN_SPEED*0.8f);
static   int        GHOST_DEAD_SPEED = (int)((float)PAC_MAN_SPEED*1.5f);
static   int       GHOST_WIIMOTE = 2;

static float            PELLET_WIDTH = 15.0f;
static float          PELLET_SPACING = 50.0f;
static float         PELLET_DISTANCE = PAC_MAN_SPEED;
static int             POWER_PELLETS = 3;
static float    POWER_PELLET_TIMEOUT = 5000.0f;
static float POWER_PELLET_PERCENTAGE = 0.03;//3% are power pellets.

static float PORTAL_WIDTH = 50.0f;
static int        PORTALS = 0;  //DIVISABLE BY 2


float distance(double x1, double y1, double x2, double y2) {
 return (float)Math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
}



