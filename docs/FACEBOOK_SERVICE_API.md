# FacebookService API Documentation

Service untuk mengelola semua fitur sosial dan pertemanan dalam game Ninja Saga.

## Overview

| Service Name | `FacebookService` |
|--------------|-------------------|
| Package | `co.id.beninjasaga.service.facebookService` |
| AMF Gateway | `FacebookService.*` |

## Daftar Methods

| No | Method | Deskripsi |
|----|--------|-----------|
| 1 | [getFriendList](#1-getfriendlist) | Mengambil daftar teman |
| 2 | [getFriendsData](#2-getfriendsdata) | Mengambil detail data teman untuk Rank panel |
| 3 | [payToRecruit](#3-paytorecruit) | Membayar untuk merekrut teman |
| 4 | [saveRecruitRecord](#4-saverecruitrecord) | Menyimpan catatan rekrutmen |
| 5 | [saveChallengeRecord](#5-savechallengerecord) | Menyimpan hasil challenge |
| 6 | [getInviteRecord](#6-getinviterecord) | Mengambil data invite reward |
| 7 | [claimInviteReward](#7-claiminvitereward) | Mengklaim hadiah invite |
| 8 | [getRecruitRecord](#8-getrecruitrecord) | Mengambil riwayat rekrutmen |
| 9 | [getPartyMembers](#9-getpartymembers) | Mengambil party members tersimpan |
| 10 | [clearPartyMembers](#10-clearpartymembers) | Menghapus party setelah battle |
| 11 | [markPartyAsUsed](#11-markpartyasused) | Menandai party sudah digunakan |

---

## 1. getFriendList

Mengambil daftar teman untuk SNS.as dan panel pertemanan.

### Client Call
```actionscript
Main.amfClient.service("FacebookService.getFriendList", [accessToken], getFriendListResponse);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `accessToken` | String | Access token / session key |

### Response Format
```json
{
    "status": 1,
    "friend_list": [
        {
            "id": "123",
            "uid": "123",
            "name": "PlayerName",
            "pic_square": ""
        }
    ],
    "char_list": [
        {
            "source_id": "123",
            "character_id": 123,
            "character_name": "PlayerName",
            "character_level": 45,
            "character_xp": 50000,
            "character_gender": 1,
            "character_rank": 3,
            "recruit_last_time": null
        }
    ],
    "result": [...]
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = error |
| `friend_list` | Array | Daftar teman untuk SNS usersMap |
| `char_list` | Array | Daftar karakter teman |
| `result` | Array | Alias dari char_list untuk Rank.as |

### Friend Object
| Field | Type | Deskripsi |
|-------|------|-----------|
| `id` | String | ID karakter |
| `uid` | String | UID (sama dengan id) |
| `name` | String | Nama karakter |
| `pic_square` | String | URL foto profil |

### Character Object
| Field | Type | Deskripsi |
|-------|------|-----------|
| `source_id` | String | ID sumber (Facebook UID) |
| `character_id` | Integer | ID karakter |
| `character_name` | String | Nama karakter |
| `character_level` | Integer | Level karakter |
| `character_xp` | Integer | XP karakter |
| `character_gender` | Integer | 1=male, 2=female |
| `character_rank` | Integer | Rank karakter |
| `recruit_last_time` | String/null | Waktu rekrut terakhir (null jika bisa direkrut) |

---

## 2. getFriendsData

Mengambil data detail teman untuk panel Rank.as.

### Client Call
```actionscript
Central.main.amfClient.service("FacebookService.getFriendsData", [sessionKey, uidStr], gotFriendsData);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |
| `uidStr` | String | String berisi UID yang dipisah koma |

### Response Format
Sama dengan [getFriendList](#1-getfriendlist).

---

## 3. payToRecruit

Melakukan pembayaran untuk merekrut karakter teman ke dalam party.

### Client Call
```actionscript
Central.main.amfClient.service("FacebookService.payToRecruit", [sessionKey, charId], getRecruitResponse);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |
| `charId` | Number/String | ID karakter yang akan direkrut |

### Response Format - Success
```json
{
    "status": 1,
    "pay_type": "gold",
    "price": 500,
    "character_gold": 9500,
    "character_token": 100
}
```

### Response Format - Failed
```json
{
    "status": 0,
    "failreason": "Not enough gold"
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = gagal |
| `pay_type` | String | "gold" atau "token" |
| `price` | Integer | Harga yang dibayar |
| `character_gold` | Integer | Sisa gold setelah membayar |
| `character_token` | Integer | Sisa token setelah membayar |
| `failreason` | String | Alasan gagal (jika status=0) |

### Payment Logic
- **Gold** (jika level teman <= level player):
  ```
  price = ceil(1 / (1 + levelDiff) * 5 * pow(myLevel, 1.68363))
  ```
- **Token** (jika level teman > level player):
  ```
  price = ceil(levelDiff * sqrt(friendLevel) / 4)
  ```

---

## 4. saveRecruitRecord

Menyimpan catatan rekrutmen setelah berhasil merekrut teman.

### Client Call
```actionscript
amfClient.service("FacebookService.saveRecruitRecord", [sessionKey, friendId, charId, type], saveRecruitRecordResult);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |
| `friendId` | String | ID teman (source_id) |
| `charId` | Number | ID karakter yang direkrut |
| `type` | Number | Tipe rekrutmen (0 = normal) |

### Response Format
```json
{
    "status": 1
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = gagal |

---

## 5. saveChallengeRecord

Menyimpan hasil battle challenge dengan teman.

### Client Call
```actionscript
amfClient.service("FacebookService.saveChallengeRecord", [sessionKey, friendUID, result, hash], saveChallengeRecordResult);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |
| `friendUID` | String | UID teman yang di-challenge |
| `result` | Number | Hasil battle (1=win, 0=lose) |
| `hash` | String | Hash validasi |

### Response Format
```json
{
    "status": 1
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = gagal |

---

## 6. getInviteRecord

Mengambil data friendship kunai dan daftar reward yang tersedia.

### Client Call
```actionscript
Central.main.amfClient.service("FacebookService.getInviteRecord", [sessionKey], gotInviteRecord);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |

### Response Format
```json
{
    "status": 1,
    "friendship_kunai": 100,
    "reward_list": [
        {
            "rewardId": "1000gold",
            "type": "gold",
            "price": 5,
            "amount": 1000,
            "priority": 1,
            "active": true
        },
        {
            "rewardId": "5token",
            "type": "token",
            "price": 10,
            "amount": 5,
            "priority": 2,
            "active": true
        }
    ]
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = gagal |
| `friendship_kunai` | Integer | Jumlah friendship kunai |
| `reward_list` | Array | Daftar hadiah yang tersedia |

### Reward Object
| Field | Type | Deskripsi |
|-------|------|-----------|
| `rewardId` | String | ID reward (contoh: "1000gold", "5token") |
| `type` | String | Tipe reward ("gold" atau "token") |
| `price` | Integer | Harga dalam friendship kunai |
| `amount` | Integer | Jumlah reward yang didapat |
| `priority` | Integer | Prioritas tampilan |
| `active` | Boolean | Status aktif reward |

### Available Rewards
| Reward ID | Type | Price (Kunai) | Amount |
|-----------|------|---------------|--------|
| 1000gold | gold | 5 | 1,000 |
| 5000gold | gold | 15 | 5,000 |
| 10000gold | gold | 25 | 10,000 |
| 50000gold | gold | 100 | 50,000 |
| 5token | token | 10 | 5 |
| 10token | token | 20 | 10 |
| 25token | token | 45 | 25 |
| 50token | token | 80 | 50 |

---

## 7. claimInviteReward

Mengklaim hadiah menggunakan friendship kunai.

### Client Call
```actionscript
Central.main.amfClient.service("FacebookService.claimInviteReward", [sessionKey, hash, rewardId, lang], claimRewardResponse);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |
| `hash` | String | Hash validasi |
| `rewardId` | String | ID reward yang diklaim |
| `lang` | String | Kode bahasa |

### Response Format
```json
{
    "status": 1
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = gagal |

### Reward Processing
- **Gold rewards**: `character_gold += amount`
- **Token rewards**: `account_balance += amount`

---

## 8. getRecruitRecord

Mengambil riwayat/history karakter yang pernah direkrut.

### Client Call
```actionscript
amfClient.service("FacebookService.getRecruitRecord", [sessionKey], callback);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |

### Response Format
```json
{
    "status": 1,
    "recruit_records": [
        {
            "target_character_id": 123,
            "character_name": "PlayerName",
            "character_level": 45,
            "recruit_time": "2026-01-15T03:30:00"
        }
    ],
    "total_recruits": 1
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = gagal |
| `recruit_records` | Array | Daftar riwayat rekrutmen |
| `total_recruits` | Integer | Total jumlah rekrutmen |

### Recruit Record Object
| Field | Type | Deskripsi |
|-------|------|-----------|
| `target_character_id` | Integer | ID karakter yang direkrut |
| `character_name` | String | Nama karakter |
| `character_level` | Integer | Level karakter |
| `recruit_time` | String | Waktu rekrutmen (ISO format) |

---

## Database Tables

### friends
```sql
CREATE TABLE friends (
    id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    friend_account_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_friendship (account_id, friend_account_id)
);
```

### character_social_logs
```sql
CREATE TABLE character_social_logs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    character_id INT NOT NULL,
    target_character_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    extra_data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_char_type (character_id, type)
);
```

### Log Types
| Type | Deskripsi |
|------|-----------|
| `recruit` | Merekrut teman untuk battle |
| `recruit_record` | Catatan rekrutmen tambahan |
| `challenge` | Challenge/fight dengan teman |

---

## Error Handling

### Common Error Responses
```json
{
    "status": 0,
    "error": "Error message here"
}
```

### Error Codes
| Error Message | Penyebab |
|---------------|----------|
| `Invalid session key` | Session tidak valid atau expired |
| `Character not found` | Karakter tidak ditemukan |
| `Friend not found` | Karakter teman tidak ditemukan |
| `Not enough gold` | Gold tidak cukup untuk merekrut |
| `Not enough tokens` | Token tidak cukup untuk merekrut |

---

## Client Integration

### Rank.as Flow
1. `gotFacebookAppFriends()` - Mendapat daftar teman dari FB
2. `getFriendsData()` - Request data karakter teman
3. `gotFriendsData()` - Update UI dengan data teman
4. `onClickRecruit()` - Player klik tombol Recruit
5. `payToRecruit()` - Bayar dan rekrut
6. `getRecruitResponse()` - Handle response
7. `saveRecruitRecord()` - Simpan record

### InviteReward2.as Flow
1. `getInviteRecord()` - Ambil data kunai dan rewards
2. `gotInviteRecord()` - Tampilkan rewards
3. `onClickClaim()` - Player pilih reward
4. `claimInviteReward()` - Klaim reward
5. `claimRewardResponse()` - Update UI

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-15 | Initial implementation |
| 1.1.0 | 2026-01-15 | Added getRecruitRecord method |
| 1.2.0 | 2026-01-15 | Added party persistence (getPartyMembers, clearPartyMembers, markPartyAsUsed) |

---

## 9. getPartyMembers

Mengambil party members yang tersimpan di database untuk restore setelah page reload.

### Client Call
```actionscript
amfClient.service("FacebookService.getPartyMembers", [sessionKey], callback);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |

### Response Format
```json
{
    "status": 1,
    "party_members": [
        {
            "party_member_id": 123,
            "party_member_type": "friend",
            "character_id": 123,
            "character_name": "FriendName",
            "character_level": 45,
            "character_gender": 1,
            "character_hair": "hair_01",
            "character_equipped_weapon": "weapon_001",
            "character_equipped_skills": "skill1,skill2,skill3"
        }
    ],
    "party_count": 1
}
```

### Response Fields
| Field | Type | Deskripsi |
|-------|------|-----------|
| `status` | Integer | 1 = sukses, 0 = gagal |
| `party_members` | Array | Daftar party members yang tersimpan |
| `party_count` | Integer | Jumlah party members |

### Party Member Object
| Field | Type | Deskripsi |
|-------|------|-----------|
| `party_member_id` | Integer | ID karakter/NPC |
| `party_member_type` | String | "friend" atau "npc" |
| `character_*` | Various | Data karakter untuk restore |

---

## 10. clearPartyMembers

Menghapus semua party members setelah battle selesai.

### Client Call
```actionscript
amfClient.service("FacebookService.clearPartyMembers", [sessionKey], callback);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |

### Response Format
```json
{
    "status": 1
}
```

### Usage
Panggil method ini setelah battle selesai untuk membersihkan party.

---

## 11. markPartyAsUsed

Menandai party members sebagai sudah digunakan saat memasuki battle.

### Client Call
```actionscript
amfClient.service("FacebookService.markPartyAsUsed", [sessionKey], callback);
```

### Request Parameters
| Parameter | Type | Deskripsi |
|-----------|------|-----------|
| `sessionKey` | String | Session key player |

### Response Format
```json
{
    "status": 1
}
```

### Usage
Panggil method ini saat player masuk ke battle dengan party.

---

## Party Persistence Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    PARTY PERSISTENCE FLOW                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Player recruits friend                                       │
│     └─> payToRecruit()                                          │
│         └─> Party member saved to character_party table         │
│                                                                  │
│  2. Player reloads page                                          │
│     └─> getPartyMembers()                                       │
│         └─> Returns saved party members                         │
│         └─> Client restores party from response                 │
│                                                                  │
│  3. Player enters battle                                         │
│     └─> markPartyAsUsed()                                       │
│         └─> Marks party as used (won't restore again)           │
│                                                                  │
│  4. Battle completes                                             │
│     └─> clearPartyMembers()                                     │
│         └─> Deletes party from database                         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Database Tables (Updated)

### character_party
```sql
CREATE TABLE IF NOT EXISTS character_party (
    id INT PRIMARY KEY AUTO_INCREMENT,
    character_id INT NOT NULL,
    party_member_type ENUM('friend', 'npc') NOT NULL DEFAULT 'friend',
    party_member_id INT NOT NULL,
    party_data JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used_in_battle BOOLEAN DEFAULT FALSE,
    UNIQUE KEY unique_party_member (character_id, party_member_type, party_member_id),
    INDEX idx_character (character_id),
    INDEX idx_unused (character_id, used_in_battle)
);
```

### Party Data JSON Structure
```json
{
    "character_id": 123,
    "character_name": "FriendName",
    "character_level": 45,
    "character_gender": 1,
    "character_hair": "hair_01",
    "character_face": "face_01",
    "character_skin_color": "#FFD5A0",
    "character_hair_color": "#3E270E",
    "character_equipped_weapon": "weapon_001",
    "character_equipped_body_set": "body_001",
    "character_equipped_back_item": "back_001",
    "character_equipped_skills": "skill1,skill2,skill3"
}
```

