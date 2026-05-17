# Daily Task System Implementation

## Overview
Complete implementation of daily task tracking system with database persistence.

## Database Setup

```bash
mysql -u root -p ninjasagax < sql/character_daily_tasks.sql
```

## How It Works

### Client Call
```actionscript
// Character.as line 907-920
updateDailyTask(taskData) {
    var hash = getArrayHash([
        sessionKey, 
        characterId, 
        total,        // Total required (e.g., 10 enemies)
        amount,       // Current progress (e.g., 5 enemies killed)
        completeTime, // Timestamp when completed
        type          // Task type (e.g., "kill_enemy", "complete_mission")
    ]);
    
    AMF.call("CharacterDAO.updateDailyTask", [
        sessionKey,
        characterId,
        taskData,  // {type, total, amount, completeTime}
        hash,
        updateSequence
    ]);
}
```

### Backend Processing

```java
updateDailyTask(request) {
    1. Validate session
    2. Parse task data (type, total, amount, completeTime)
    3. Find today's task OR create new task
    4. Update progress
    5. Auto-complete if amount >= total
    6. Save to database
}
```

## Task Data Structure

```javascript
{
  "type": "kill_enemy",     // Task type identifier
  "total": 10,              // Total required
  "amount": 5,              // Current progress
  "completeTime": 123456789 // Unix timestamp (optional)
}
```

## Task Types (Examples)

| Type | Description | Total Example |
|------|-------------|---------------|
| `kill_enemy` | Kill X enemies | 10 |
| `complete_mission` | Complete X missions | 3 |
| `use_skill` | Use skills X times | 20 |
| `win_pvp` | Win X PvP battles | 5 |
| `collect_item` | Collect X items | 15 |

## Database Schema

```sql
character_daily_tasks:
- id: Auto-increment
- character_id: Foreign key
- task_type: Task identifier
- total: Required amount
- amount: Current progress
- complete_time: Completion timestamp
- created_at: Task start time
- updated_at: Last update time
```

## Auto-Completion

Task automatically marked as complete when:
```java
if (amount >= total && total > 0) {
    task.setCompleteTime(LocalDateTime.now());
}
```

## Daily Reset

Tasks are unique per day:
```sql
-- Query finds today's task only
WHERE DATE(created_at) = CURRENT_DATE
```

New day = new task entry automatically created.

## Response

```json
{
  "status": "1",  // Success
  "error": null   // No error
}
```

## Logs

```
[AMF] - updateDailyTask request: characterId=1, type=kill_enemy, amount=5/10
[AMF] - Daily task updated: characterId=1, type=kill_enemy, progress=5/10, completed=false
```

When completed:
```
[AMF] - updateDailyTask request: characterId=1, type=kill_enemy, amount=10/10
[AMF] - Daily task updated: characterId=1, type=kill_enemy, progress=10/10, completed=true
```

## Query Examples

### Get Today's Tasks for Character
```sql
SELECT * FROM character_daily_tasks 
WHERE character_id = 1 
AND DATE(created_at) = CURRENT_DATE;
```

### Get Completed Tasks
```sql
SELECT * FROM character_daily_tasks 
WHERE character_id = 1 
AND complete_time IS NOT NULL;
```

### Get Task Progress
```sql
SELECT task_type, amount, total, 
       (amount * 100.0 / total) as progress_percent
FROM character_daily_tasks 
WHERE character_id = 1 
AND DATE(created_at) = CURRENT_DATE;
```

## Integration Points

### Mission Completion Trigger
```java
// After mission complete
Map<String, Object> dailyTask = new HashMap<>();
dailyTask.put("type", "complete_mission");
dailyTask.put("total", 3);
dailyTask.put("amount", getCompletedMissionsToday() + 1);

updateDailyTask(dailyTask);
```

### PvP Win Trigger
```java
// After PvP win
Map<String, Object> dailyTask = new HashMap<>();
dailyTask.put("type", "win_pvp");
dailyTask.put("total", 5);
dailyTask.put("amount", getPvpWinsToday() + 1);

updateDailyTask(dailyTask);
```

## Cleanup (Optional)

Delete old completed tasks (keep last 30 days):
```sql
DELETE FROM character_daily_tasks 
WHERE complete_time IS NOT NULL 
AND complete_time < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

Or via repository:
```java
LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
dailyTaskRepository.deleteByCompleteTimeBeforeAndCompleteTimeIsNotNull(thirtyDaysAgo);
```

## Testing

1. **Create Task**:
```sql
-- Simulate task creation
-- Client will call updateDailyTask with amount=1
```

2. **Update Progress**:
```sql
-- Client calls updateDailyTask multiple times
-- amount increments: 1, 2, 3, ..., 10
```

3. **Verify Completion**:
```sql
SELECT * FROM character_daily_tasks 
WHERE character_id = 1 
AND complete_time IS NOT NULL;
```

4. **Check Logs**:
```
[AMF] - Daily task updated: characterId=1, type=kill_enemy, progress=10/10, completed=true
```

## Status

✅ **COMPLETE** - Fully functional with database persistence
