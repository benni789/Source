# Database-Based Mission Rewards - Setup Guide

## Setup Steps

### 1. Run SQL Schema

```bash
mysql -u root -p ninjasagax < /Users/ferry/Desktop/Ninja\ Saga/back/backend-java/sql/mission_rewards.sql
```

### 2. Add Example Rewards

```sql
-- Mission 1 - Academy Training
INSERT INTO mission_rewards 
  (mission_id, reward_type, reward_id, reward_quantity, is_guaranteed, drop_chance, is_first_clear) 
VALUES
  ('1', 'item', 'item100', 1, 1, 100.00, 1),     -- First clear: Health Potion
  ('1', 'item', 'item101', 1, 0, 50.00, 0),      -- 50% drop: Kunai
  ('1', 'item', 'item102', 3, 0, 25.00, 0);      -- 25% drop: Shuriken x3

-- Mission 2 - Forest Patrol
INSERT INTO mission_rewards 
  (mission_id, reward_type, reward_id, reward_quantity, is_guaranteed, drop_chance, is_first_clear) 
VALUES
  ('2', 'item', 'item150', 1, 1, 100.00, 1),     -- First clear bonus
  ('2', 'skill', 'skill50', 1, 0, 10.00, 0);     -- 10% skill drop

-- Mission 5 - Boss Fight (Level 10+ only)
INSERT INTO mission_rewards 
  (mission_id, reward_type, reward_id, reward_quantity, is_guaranteed, drop_chance, min_level, is_first_clear) 
VALUES
  ('5', 'item', 'item200', 1, 1, 100.00, 10, 1), -- First clear: Rare item (min level 10)
  ('5', 'item', 'item500', 1, 0, 5.00, 10, 0);   -- 5% epic drop (min level 10)
```

### 3. Restart Backend

```bash
# Backend will auto-load rewards into cache on first mission completion
```

## Features

### ✅ Implemented

1. **Database Storage**
   - All rewards stored in `mission_rewards` table
   - Easy to manage via SQL

2. **In-Memory Caching**
   - First load from database
   - Cached for fast access
   - Auto-loads on first request

3. **Level-Based Filtering**
   - `min_level`: Minimum character level required
   - `max_level`: Maximum character level (optional)
   - Auto-filtered by service

4. **Drop Chances**
   - `is_guaranteed = 1`: Always drops
   - `drop_chance`: % chance (0.00-100.00)
   - Random roll per item

5. **First-Clear Bonus**
   - `is_first_clear = 1`: Only on first completion
   - `is_first_clear = 0`: Can drop multiple times

6. **Quantity Support**
   - `reward_quantity`: Number of items to give
   - Duplicates in response array

## How It Works

```java
// 1. Character completes mission
updateCharacter(request) {
    
    // 2. Check if first clear
    boolean isFirstClear = (successCount == 1);
    
    // 3. Get rewards from database (cached)
    List<String> rewards = missionRewardService.getRewards(
        missionId,           // "1", "2", etc.
        characterLevel,      // For level filtering
        isFirstClear         // First-clear check
    );
    
    // 4. Return to client
    response.setReward_items(rewards);
}
```

## Cache Management

### Clear Cache for One Mission
```java
missionRewardService.clearCache("1");  // Clear mission 1 cache
```

### Clear All Cache
```java
missionRewardService.clearAllCache();  // Clear everything
```

### Reload Rewards
```java
missionRewardService.reloadRewards("1");  // Clear + reload mission 1
```

**Note**: Cache clears automatically on server restart.

## Adding New Rewards

### Option 1: Direct SQL Insert

```sql
INSERT INTO mission_rewards 
  (mission_id, reward_type, reward_id, reward_quantity, 
   is_guaranteed, drop_chance, min_level, is_first_clear) 
VALUES
  ('10', 'item', 'item999', 1, 0, 15.00, 20, 0);
```

Then clear cache:
```sql
-- No cache clear needed! Will auto-load on next completion
```

### Option 2: Via Admin Panel (TODO)

Create admin interface to manage rewards:
- Add/Edit/Delete rewards
- Set drop chances
- Configure level requirements
- Auto-refresh cache

## Example Configurations

### Basic Mission (No Level Requirement)
```sql
-- Guaranteed first clear + random drops
INSERT INTO mission_rewards VALUES
  (NULL, '1', 'item', 'item100', 1, 1, 100.00, NULL, NULL, 1, NOW()),
  (NULL, '1', 'item', 'item101', 1, 0, 50.00, NULL, NULL, 0, NOW());
```

### Level-Locked Mission  
```sql
-- Only for level 15-30 characters
INSERT INTO mission_rewards VALUES
  (NULL, '8', 'item', 'item300', 1, 1, 100.00, 15, 30, 1, NOW());
```

### Rare Drop Mission
```sql
-- Very low drop rate for epic item
INSERT INTO mission_rewards VALUES
  (NULL, '20', 'item', 'item999', 1, 0, 1.00, 50, NULL, 0, NOW());
```

## Testing

1. **Add test rewards**:
```sql
INSERT INTO mission_rewards 
  (mission_id, reward_type, reward_id, reward_quantity, is_guaranteed, drop_chance, is_first_clear) 
VALUES
  ('1', 'item', 'test_item', 5, 1, 100.00, 0);
```

2. **Complete mission 1**
3. **Check response**:
```json
{
  "status": 1,
  "reward_items": ["test_item", "test_item", "test_item", "test_item", "test_item"]
}
```

4. **Verify in logs**:
```
[Rewards] Mission 1 gave 5 items to level 5 character
```

## Performance

- **First Load**: ~10-50ms (database query)
- **Cached**: <1ms (memory lookup)
- **Cache Size**: ~1KB per mission
- **Memory Usage**: Negligible (100 missions = ~100KB)

## Troubleshooting

### No Rewards Dropping?

1. Check database:
```sql
SELECT * FROM mission_rewards WHERE mission_id = '1';
```

2. Check logs:
```
[Rewards] Loading rewards for mission 1 from database
[Rewards] Mission 1 gave 0 items to level 5 character
```

3. Verify drop chance:
```sql
-- Set to 100% for testing
UPDATE mission_rewards SET drop_chance = 100.00 WHERE mission_id = '1';
```

### Cache Not Updating?

```java
// Clear cache via code or restart server
missionRewardService.clearAllCache();
```

### Level Filtering Not Working?

```sql
-- Check min/max level settings
SELECT mission_id, reward_id, min_level, max_level 
FROM mission_rewards 
WHERE mission_id = '1';
```

## Migration from Hardcoded Config

1. Extract rewards from `MissionRewardsConfig.java`
2. Convert to SQL INSERT statements
3. Run SQL
4. Delete `MissionRewardsConfig.java` (no longer needed)
5. Restart server

**Done!** All rewards now managed via database.
