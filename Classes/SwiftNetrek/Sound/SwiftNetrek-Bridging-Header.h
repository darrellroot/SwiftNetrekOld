//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "Player.h"
#import "Phaser.h"
#import "Plasma.h"
#import "Universe.h"
#import "MTKeyMap.h"
#import "LLNotificationCenter.h"
#import "MessageConstants.h"
#import "LLObject.h"
#import "LLView.h"
#import "PainterFactory.h"
#import "MTMouseMap.h"
#import "SettingsController.h"
#import "MTDistress.h"
#import "MTMacroHandler.h"
#import "PainterFactoryForTac.h"
#import "ClientController.h"
#import "MTTipOfTheDayController.h"
#import "OutfitMenuController.h"
#import "LoginController.h"
#import "GameController.h"
#import "ServerControllerNew.h"
#import "MenuController.h"
#import "SelectServerController.h"
#import "LocalServerController.h"
#import "LLHUDWindowController.h"

//#import "GameView.h"
#define FRAME_RATE  10
#define MAX_WAIT_BEFORE_DRAW  (1/(2*FRAME_RATE))
// 10%
#define GV_SCALE_STEP 0.1
// input modes
#define GV_NORMAL_MODE    0
#define GV_MESSAGE_MODE    1
#define GV_MACRO_MODE    2
#define GV_REFIT_MODE    3
#define GV_WAR_MODE        4


