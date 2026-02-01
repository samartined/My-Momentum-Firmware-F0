#include "game/game.hpp"
#include "app.hpp"
#include "free_roam_icons.h"
#include "engine/draw.hpp"
#include "engine/game.hpp"
#include "engine/engine.hpp"
#include "game/sprites.hpp"
#include <math.h>

FreeRoamGame::FreeRoamGame()
{
    // nothing to do
}

FreeRoamGame::~FreeRoamGame()
{
    // also nothing to do anymore since I moved the view/timer to the app
}

void FreeRoamGame::debounceInput()
{
    static uint8_t debounceCounter = 0;
    if (shouldDebounce)
    {
        lastInput = InputKeyMAX;
        debounceCounter++;
        if (debounceCounter < 2) // Reduced from 4 to 2 for faster menu response
        {
            return;
        }
        debounceCounter = 0;
        shouldDebounce = false;
        inputHeld = false;
    }
}

void FreeRoamGame::endGame()
{
    shouldReturnToMenu = true;
    isGameRunning = false;

    this->updateSoundToggle();
    this->updateVibrationToggle();

    if (engine)
    {
        engine->stop();
    }

    if (draw)
    {
        draw.reset();
    }
}

bool FreeRoamGame::init(ViewDispatcher **viewDispatcher, void *appContext)
{
    this->viewDispatcherRef = viewDispatcher;
    this->appContext = appContext;

    FreeRoamApp *app = static_cast<FreeRoamApp *>(appContext);
    if (!app)
    {
        FURI_LOG_E("FreeRoamGame", "App context is null");
        return false;
    }

    // Load sound and vibration toggle states from app settings
    soundToggle = app->isSoundEnabled() ? ToggleOn : ToggleOff;
    vibrationToggle = app->isVibrationEnabled() ? ToggleOn : ToggleOff;

    // Check board connection before proceeding
    if (app->isBoardConnected())
    {
        return true;
    }
    else
    {
        FURI_LOG_E("FreeRoamGame", "Board is not connected");
        easy_flipper_dialog("FlipperHTTP Error", "Ensure your WiFi Developer\nBoard or Pico W is connected\nand the latest FlipperHTTP\nfirmware is installed.");
        endGame(); // End the game if board is not connected
        return false;
    }
}

void FreeRoamGame::inputManager()
{
    static int inputHeldCounter = 0;

    // Track input held state
    if (lastInput != InputKeyMAX)
    {
        inputHeldCounter++;
        if (inputHeldCounter > 10)
        {
            this->inputHeld = true;
        }
    }
    else
    {
        inputHeldCounter = 0;
        this->inputHeld = false;
    }

    // Handle input for all views, but don't debounce when game engine is running
    if (player && (player->getCurrentMainView() == GameViewGameLocal || player->getCurrentMainView() == GameViewGameOnline))
    {
        // When game is running, completely skip debouncing to avoid interference
        if (!isGameRunning)
        {
            // Only debounce if game is not actually running (e.g., during startup)
            if (lastInput == InputKeyBack)
            {
                debounceInput();
            }
        }
        // When game is running, let all inputs pass through without any debouncing
    }
    else
    {
        // For menu views, use fast debouncing (much faster than original but prevents menu skipping)
        // Only debounce when shouldDebounce is explicitly set, skip the inputHeld check for speed
        if (shouldDebounce)
        {
            debounceInput();
        }
    }

    // Pass input to player for processing
    if (player)
    {
        player->setInputKey(lastInput);
        player->processInput();
    }
}

bool FreeRoamGame::startGame()
{
    draw->fillScreen(ColorWhite);
    draw->text(Vector(0, 10), "Initializing game...", ColorBlack);

    if (isGameRunning || engine)
    {
        FURI_LOG_E("FreeRoamGame", "Game already running, skipping start");
        return true;
    }

    // Create the game instance with 3rd person perspective
    auto game = std::make_unique<Game>("Free Roam", Vector(128, 64), draw.get(), ColorBlack, ColorWhite, CAMERA_THIRD_PERSON);
    if (!game)
    {
        FURI_LOG_E("FreeRoamGame", "Failed to create Game object");
        return false;
    }

    // Create the player instance if it doesn't exist
    if (!player)
    {
        player = std::make_unique<Player>();
        if (!player)
        {
            FURI_LOG_E("FreeRoamGame", "Failed to create Player object");
            return false;
        }
    }

    // set sound/vibration toggle states
    player->setSoundToggle(soundToggle);
    player->setVibrationToggle(vibrationToggle);

    draw->fillScreen(ColorWhite);
    draw->text(Vector(0, 10), "Adding levels and player...", ColorBlack);

    // add levels and player to the game
    std::unique_ptr<Level> level1 = std::make_unique<Level>("Tutorial", Vector(128, 64), game.get());
    std::unique_ptr<Level> level2 = std::make_unique<Level>("First", Vector(128, 64), game.get());
    std::unique_ptr<Level> level3 = std::make_unique<Level>("Second", Vector(128, 64), game.get());

    level1->entity_add(player.get());
    level2->entity_add(player.get());
    level3->entity_add(player.get());

    // add some 3D sprites
    std::unique_ptr<Entity> tutorialGuard1 = std::make_unique<Sprite>("Tutorial Guard 1", Vector(3, 7), SPRITE_3D_HUMANOID, 1.7f, M_PI / 4, 0.f, Vector(9, 7));
    std::unique_ptr<Entity> tutorialGuard2 = std::make_unique<Sprite>("Tutorial Guard 2", Vector(6, 2), SPRITE_3D_HUMANOID, 1.7f, M_PI / 4, 0.f, Vector(1, 2));
    level1->entity_add(tutorialGuard1.release());
    level1->entity_add(tutorialGuard2.release());

    game->level_add(level1.release());
    game->level_add(level2.release());
    game->level_add(level3.release());

    this->engine = std::make_unique<GameEngine>(game.release(), 240);
    if (!this->engine)
    {
        FURI_LOG_E("FreeRoamGame", "Failed to create GameEngine");
        return false;
    }

    draw->fillScreen(ColorWhite);
    draw->text(Vector(0, 10), "Starting game engine...", ColorBlack);

    isGameRunning = true; // Set the flag to indicate game is running
    return true;
}

void FreeRoamGame::switchToLevel(int levelIndex)
{
    if (!isGameRunning || !engine || !engine->getGame())
        return;

    // Ensure the level index is within bounds
    if (levelIndex < 0 || levelIndex >= totalLevels)
    {
        FURI_LOG_E("FreeRoamGame", "Invalid level index: %d", levelIndex);
        return;
    }

    currentLevelIndex = levelIndex;

    // Switch to the specified level using the engine's game instance
    engine->getGame()->level_switch(currentLevelIndex);

    // Force the Player to update its currentDynamicMap on next render
    if (player)
    {
        player->forceMapReload();
    }
}

void FreeRoamGame::switchToNextLevel()
{
    if (!isGameRunning || !engine || !engine->getGame())
    {
        FURI_LOG_W("FreeRoamGame", "Cannot switch level - game not running or engine not ready");
        return;
    }

    // Cycle to next level
    currentLevelIndex = (currentLevelIndex + 1) % totalLevels;

    // Switch to the new level using the engine's game instance
    engine->getGame()->level_switch(currentLevelIndex);

    // Force the Player to update its currentDynamicMap on next render
    if (player)
    {
        player->forceMapReload();
    }
}

void FreeRoamGame::updateDraw(Canvas *canvas)
{
    // set Draw instance
    if (!draw)
    {
        draw = std::make_unique<Draw>(canvas);
    }

    // Initialize player if not already done
    if (!player)
    {
        player = std::make_unique<Player>();
        if (player)
        {
            player->setFreeRoamGame(this);
            player->setSoundToggle(soundToggle);
            player->setVibrationToggle(vibrationToggle);
        }
    }

    // Let the player handle all drawing
    if (player)
    {
        player->drawCurrentView(draw.get());

        if (player->shouldLeaveGame())
        {
            this->soundToggle = player->getSoundToggle();
            this->vibrationToggle = player->getVibrationToggle();
            this->endGame(); // End the game if the player wants to leave
        }
    }
}

void FreeRoamGame::updateInput(InputEvent *event)
{
    if (!event)
    {
        FURI_LOG_E("FreeRoamGame", "updateInput: no event available");
        return;
    }

    this->lastInput = event->key;

    // Only run inputManager when not in an active game to avoid input conflicts
    if (!(player && player->getCurrentMainView() == GameViewGameLocal && this->isGameRunning))
    {
        this->inputManager();
    }
}

void FreeRoamGame::updateSoundToggle()
{
    FreeRoamApp *app = static_cast<FreeRoamApp *>(appContext);
    if (app)
    {
        app->setSoundEnabled(soundToggle == ToggleOn);
    }
}

void FreeRoamGame::updateVibrationToggle()
{
    FreeRoamApp *app = static_cast<FreeRoamApp *>(appContext);
    if (app)
    {
        app->setVibrationEnabled(vibrationToggle == ToggleOn);
    }
}
