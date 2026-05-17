# 🎰 Scratch Card Rewards API Documentation

## Endpoint: `RouletteService.scratchCardAtfer20Level`

### Request
```
[sessionKey, scratchType, selectScratch, hash]
```

| Parameter | Type | Description |
|-----------|------|-------------|
| sessionKey | String | User session key |
| scratchType | String | `"free"` or `"token"` |
| selectScratch | String | Selected card: `"1"`, `"2"`, or `"3"` |
| hash | String | Client verification hash |

---

## Response JSON Examples

### 1. GOLD Reward
```json
{
  "status": "1",
  "reward_type": "GOLD",
  "reward_amount": "5000",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
Central.main.getMainChar().updateGold(0 + param1.reward_amount);
```

---

### 2. TOKEN Reward
```json
{
  "status": "1",
  "reward_type": "TOKEN",
  "reward_amount": 100,
  "signature": "a1b2c3d4e5f6..."
}
```
> ⚠️ **Note:** TOKEN uses Integer type to prevent string concatenation bug.

**Client Parsing:**
```actionscript
Account.balance = Account.getAccountBalance() + param1.reward_amount;
```

---

### 3. XP Reward
```json
{
  "status": "1",
  "reward_type": "XP",
  "reward_amount": "1000",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
this.isLevelUp = Central.main.getMainChar().updateXP(param1.reward_amount);
```

---

### 4. XP% Reward (Percentage of next level)
```json
{
  "status": "1",
  "reward_type": "XP%",
  "reward_amount": "10",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
// Calculate % of XP needed for next level
var xpNeeded:uint = Formula.getXpByLv(currentLevel + 1) - Formula.getXpByLv(currentLevel);
var xpGain:uint = Math.round(xpNeeded * reward_amount / 100);
this.isLevelUp = Central.main.getMainChar().updateXP(xpGain);
```

---

### 5. TP (Talent/Bloodline Points) Reward
```json
{
  "status": "1",
  "reward_type": "TP",
  "reward_amount": "25",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
Central.main.getMainChar().updateData(DBCharacterData.BLOODLINE, 
    int(param1.reward_amount) + int(Central.main.getMainChar().getData(DBCharacterData.BLOODLINE)));
```

---

### 6. ITEM Reward (Consumable/Material/Essence)
```json
{
  "status": "1",
  "reward_type": "ITEM",
  "reward_amount": "1144",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
var iconData:Object = Central.main.toolkit.getDisplayData(String("item" + param1.reward_amount));
Central.main.toolkit.DisplayDataAddInventory(iconData);
```

**Special Items (Stones):**
- `1144` = Red Stone
- `1145` = Green Stone
- `1146` = Blue Stone
- `1147` = Purple Stone
- `1148` = Yellow Stone
- `1150` = Green Blue Stone

---

### 7. WEAPON Reward
```json
{
  "status": "1",
  "reward_type": "WEAPON",
  "reward_amount": "803",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
Item.getWeaponIcon("wpn" + param1.reward_amount, iconMc);
Central.main.getMainChar().addInventory(InventoryData.TYPE_WEAPON, "wpn" + param1.reward_amount);
```

---

### 8. BACK (Back Item) Reward
```json
{
  "status": "1",
  "reward_type": "BACK",
  "reward_amount": "445",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
Item.getBackItemIcon("back" + param1.reward_amount, iconMc);
Central.main.getMainChar().addInventory(InventoryData.TYPE_BACK_ITEM, "back" + param1.reward_amount);
```

---

### 9. CLOTH (Clothing/Body Set) Reward
```json
{
  "status": "1",
  "reward_type": "CLOTH",
  "reward_amount": "468",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
Item.getClothIcon("set" + param1.reward_amount, iconMc);
Central.main.getMainChar().addInventory(InventoryData.TYPE_BODY_SET, "set" + param1.reward_amount);
```

---

### 10. SKILL Reward
```json
{
  "status": "1",
  "reward_type": "SKILL",
  "reward_amount": "376",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
var skillIcon:MovieClip = Central.main.getLib("skill_" + param1.reward_amount);
// If replacing old skill
if(this.skillBase != "" && Central.main.getMainChar().hasSkill(this.skillBase)) {
    Central.main.getMainChar().removeEquippedSkill(this.skillBase);
    Central.main.getMainChar().removeInventory(InventoryData.TYPE_SKILL, this.skillBase);
}
Central.main.getMainChar().addInventory(InventoryData.TYPE_SKILL, "skill" + param1.reward_amount);
```

---

### 11. EMBLEM Reward (Grand Prize)
```json
{
  "status": "1",
  "reward_type": "EMBLEM",
  "reward_amount": "1",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
var emblemIcon:MovieClip = Central.main.getLib("emblemIcon");
// Display only - special account upgrade
```

---

### 12. PET Reward 🐾
```json
{
  "status": "1",
  "reward_type": "PET",
  "reward_amount": "14",
  "signature": "a1b2c3d4e5f6...",
  "pet_data": {
    "id": 52,
    "name": "Wolf",
    "level": 1,
    "xp": 0,
    "swfName": "pet_wolf",
    "clsName": "Wolf",
    "equipped": true,
    "skills": [],
    "maturity": 100,
    "ep": 100,
    "hp": 100,
    "hash": "abc123def456..."
  }
}
```
**Client Parsing:**
```actionscript
var iconData:Object = Central.main.toolkit.getDisplayData(String("pet" + param1.reward_amount));
var iconMc:MovieClip = iconData.mc;

if(param1.pet_data) {
    this.petObject = param1.pet_data as Object;
}

// Initialize pet if equipped
if(petObject && petObject.equipped) {
    var petData:* = Central.main.dataParser.parsePetData(petObject);
    Central.main.getMainChar().initStandbyPet(petData, petObject.swfName, petObject.clsName);
    
    // Load pet SWF
    var swfArr:Array = ["swf/pets/" + petObject.swfName + ".swf"];
    Central.main.loadSwf(swfArr, loadPetFinish);
}
```

---

### 13. PACKAGE Reward (Multiple Items)
```json
{
  "status": "1",
  "reward_type": "PACKAGE",
  "reward_amount": "1",
  "signature": "a1b2c3d4e5f6..."
}
```
**Client Parsing:**
```actionscript
// Package contains pre-defined items (hair, clothing, back item)
Central.main.getMainChar().addInventory(InventoryData.TYPE_HAIR, this.package_hair);
Central.main.getMainChar().addInventory(InventoryData.TYPE_BODY_SET, this.package_clothing);
Central.main.getMainChar().addInventory(InventoryData.TYPE_BACK_ITEM, this.package_backitem);
```

---

## Database Table: `scratch_card_rewards`

```sql
CREATE TABLE IF NOT EXISTS scratch_card_rewards (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reward_type VARCHAR(50) NOT NULL,
    reward_amount VARCHAR(100) NOT NULL,
    weight INT NOT NULL DEFAULT 10,
    is_grand_prize TINYINT(1) DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1
);
```

### Reward Type Reference

| Type | Amount Meaning | Weight Range | Grand Prize |
|------|---------------|--------------|-------------|
| GOLD | Amount of gold | 20-100 | No |
| TOKEN | Amount of tokens | 2-40 | No |
| XP | Amount of XP | 50-80 | No |
| XP% | Percentage of next level | 30-60 | No |
| TP | Talent points | 15-30 | No |
| ITEM | Item ID (e.g., 1144) | 10-15 | No |
| WEAPON | Weapon ID (e.g., 803) | 2-5 | No |
| BACK | Back item ID | 2-8 | No |
| CLOTH | Clothing set ID | 3-5 | No |
| SKILL | Skill ID (e.g., 376) | 1-2 | Yes |
| EMBLEM | Emblem ID | 1 | Yes |
| PET | Pet master ID | 1 | Yes |

---

## Signature Verification

Client verifies response using:
```actionscript
var hash:String = String(response.reward_type) + String(response.reward_amount);
if(response.signature != Central.main.getHash(String(hash))) {
    Central.main.onError("1216", "");
    return;
}
```

Server generates signature:
```java
String hashInput = response.reward_type + response.reward_amount;
response.signature = HashUtil.getHash(sessionKey, hashInput);
```
