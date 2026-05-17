# Mission Reward System

## Overview
Sistem reward untuk mission completion dengan support untuk:
- First-clear bonus (reward hanya sekali)
- Random drop dengan configurable drop rate
- Multiple items dengan quantity
- Level requirements (optional)

## Cara Kerja

### 1. **Hardcoded Config** (Sederhana - Sudah Implemented)

File: `MissionRewardsConfig.java`

```java
// Define rewards untuk setiap mission
MISSION_REWARDS.put("1", Arrays.asList(
    new RewardItem("item100", 1, 100.0, true),  // First clear: guaranteed
    new RewardItem("item101", 1, 50.0, false),  // 50% drop
    new RewardItem("item102", 3, 25.0, false)   // 25% drop, quantity 3
));
```

**Cara Add Mission Baru:**
1. Edit `MissionRewardsConfig.java`
2. Add entry di `MISSION_REWARDS` map
3. Restart server

**Kelebihan:**
- ✅ Simple & cepat
- ✅ No database needed
- ✅ Easy to test

**Kekurangan:**
- ❌ Perlu restart server untuk update
- ❌ Tidak flexible

### 2. **Database Config** (Flexible - Optional)

File: `sql/mission_rewards.sql`

```sql
INSERT INTO mission_rewards 
  (mission_id, reward_type, reward_id, reward_quantity, 
   is_guaranteed, drop_chance, is_first_clear) 
VALUES
  ('1', 'item', 'item100', 1, 1, 100.00, 1);  -- First clear bonus
```

**Cara Add Mission Baru:**
1. Insert ke database
2. No restart needed (jika implement caching)

**Kelebihan:**
- ✅ Update tanpa restart
- ✅ Easy to manage via admin panel
- ✅ Can track reward statistics

**Kekurangan:**
- ❌ Need database queries
- ❌ Need to implement repository/entity

## Reward Types

| Type | Format | Contoh | Keterangan |
|------|--------|--------|------------|
| Item | `item{id}` | `item100` | Consumable items |
| Skill | `skill{id}` | `skill50` | Skill scrolls |
| Essence | `item{id}` | `item200` | Ninja essence |
| Pet | `pet{id}` | `pet5` | Pet rewards |

## Drop Chance Calculation

```java
// 100.0 = Guaranteed (always drop)
// 50.0 = 50% chance
// 10.0 = 10% chance
// 0.0 = Never drops

double roll = ThreadLocalRandom.current().nextDouble(100.0);
boolean shouldDrop = (roll < dropChance);
```

## First Clear Detection

```java
boolean isFirstClear = (missionEntity.getSuccessCount() == 1);
```

- `successCount = 1` → First time completing
- `successCount > 1` → Already completed before

## Response Format

Client receives:
```json
{
  "status": 1,
  "reward_items": ["item100", "item101", "item101", "item101"]
}
```

**Note**: Items dengan quantity > 1 akan duplicate:
- `quantity = 3` → `["item102", "item102", "item102"]`

## Client Integration

Client akan show popup dengan rewards (dari `Character.as` line 868-870):
```actionscript
if(param1.reward_items) {
    this.rewardItems = param1.reward_items;
}
if(this.rewardItems.length > 0) {
    Main.popup.showBonusReward(this.rewardItems);
}
```

## Configuration Examples

### Mission 1 - Academy Training
```java
// First clear: Health Potion (guaranteed)
// Random: Kunai (50%), Shuriken x3 (25%)
MISSION_REWARDS.put("1", Arrays.asList(
    new RewardItem("item100", 1, 100.0, true),   // Health Potion
    new RewardItem("item101", 1, 50.0, false),   // Kunai  
    new RewardItem("item102", 3, 25.0, false)    // Shuriken x3
));
```

### Mission 5 - Boss Fight
```java
// First clear: Rare Skill (guaranteed)
// Random: Epic Weapon (5%), Gold Chest (10%)
MISSION_REWARDS.put("5", Arrays.asList(
    new RewardItem("skill100", 1, 100.0, true),  // Rare Skill
    new RewardItem("wpn50", 1, 5.0, false),      // Epic Weapon (5%)
    new RewardItem("item500", 1, 10.0, false)    // Gold Chest (10%)
));
```

## TODO / Future Enhancements

1. **Level-based Rewards**
   - Different rewards based on character level
   - Required level to get certain rewards

2. **Rarity System**
   - Common, Uncommon, Rare, Epic, Legendary
   - Color-coded in UI

3. **Reward History**
   - Track what items player has received
   - Prevent duplicate unique items

4. **Dynamic Drop Rates**
   - Increase drop rate based on failed attempts
   - Pity system for rare drops

5. **Database Implementation**
   - Create Entity & Repository
   - Add caching layer
   - Admin panel for managing rewards
