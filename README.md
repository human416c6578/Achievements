# Achievement API: Core

## Introduction
Achievement API: Core is a plugin for AMX Mod X that provides a flexible and extensible system for managing and tracking achievements in-game. This plugin allows server administrators to create and register achievements, monitor player progress, and reward players for completing achievements.

## Features
- **Dynamic Achievement System:** Create and register achievements on the fly with flexible parameters.
- **Client-Side Achievement Notifications:** Inform players when they complete achievements.
- **Persistent Storage:** Achievements are stored using NVault to ensure persistence across server restarts.
- **Debug Mode:** Toggle debug mode to print achievement information for testing purposes.

## Usage
### Console Commands
- **achievements_debug** - Debug mode to print achievement information.

### Plugin Natives
- **RegisterAchievement** - Register a new achievement with a name, description, key, and a completion value.
- **ClientAchievementCompleted** - Notify the server when a client completes an achievement.
- **GetClientAchievementStatus** - Check the status of a client's progress on a specific achievement.
- **GetClientAchievementsCompleted** - Get the total number of achievements completed by a client.
- **GetMaxAchievements** - Get the total number of registered achievements.
- **GetAchievementKey** - Get the key associated with a specific achievement.
- **GetAchievementMaxValue** - Get the maximum value for a specific achievement.

### Examples
#### Register an Achievement
```pawn
new achievementIndex = RegisterAchievement("My Achievement", "Description of the achievement.", "achievement_key", 10);
```

#### Notify Server of Completed Achievement
```pawn
ClientAchievementCompleted(client, achievementIndex);
```

#### Check Client Achievement Status
```pawn
if (GetClientAchievementStatus(client, achievementIndex) == _Unlocked) {
    // Achievement unlocked logic here
}
```